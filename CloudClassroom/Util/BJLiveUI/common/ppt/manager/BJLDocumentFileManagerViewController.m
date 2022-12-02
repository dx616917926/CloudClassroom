//
//  BJLDocumentFileManagerViewController.m
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/26.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveBase/BJLNetworking+BaijiaYun.h>
#import <BJLiveBase/BJLError.h>
#import <BJLiveCore/BJLiveCore.h>
#import "BJLiveUIBase.h"

#import "BJLDocumentFileManagerViewController.h"
#import "BJLDocumentFileManagerViewController+private.h"
#import "BJLPopoverViewController.h"
#import "BJLAppearance.h"
#import "BJLDocumentFileCell.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const directoryNameMaxLenth = 8.0;

@implementation BJLDocumentFileManagerViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super init]) {
        self.room = room;
        self.mutableAllDocumentFileList = [NSMutableArray new];
        self.mutableTranscodeDocumentFileList = [NSMutableArray new];
        self.mutableDocumentSearchResultFileList = [NSMutableArray new];
        self.mutableCloudFileList = [NSMutableArray new];
        self.mutableTranscodeCloudFileList = [NSMutableArray new];
        self.mutableCloudSearchResultFileList = [NSMutableArray new];
        self.syncCloudFidArray = [NSMutableArray new];
        self.currentDirectoryStack = [NSMutableArray new];
        self.mutableHomeworkFileList = [NSMutableArray new];
        self.mutableHomeworkSearchResultFileList = [NSMutableArray new];
        self.syncHomeworkFidArray = [NSMutableArray new];
        self.homeworkCursor = nil;
        self.shouldShowHomeworkSupportView = YES;
        self.finishDocumentFileIDList = [NSMutableArray new];
        self.mutableTranscodeHomeworkFileList = [NSMutableArray new];
        [self makeObserving];
        if (self.room.state == BJLRoomState_connected) {
            [self loadAllRemoteDocuments:self.room.documentVM.allDocuments];
            [self loadAllRemoteHomeworks:self.room.homeworkVM.allHomeworks];
        }
    }
    return self;
}

- (void)hideDocumentPickerViewControllerIfNeeded {
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    if (_chooseDocumentLayer) {
        _chooseDocumentLayer.hidden = YES;
    }
}

- (void)dealloc {
    self.documentFileView.tableView.delegate = nil;
    self.documentFileView.tableView.dataSource = nil;
    [self bjl_stopAllMethodParametersObserving];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopPollTimer];
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [BJLDownloadManager downloadManagerWithIdentifier:@"homeworkDownloadManager"];
    self.manager.delegate = self;

    [self makeSubviewsAndConstraints];
    [self makeActions];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadTableViewWithLayoutType:self.documentFileLayoutType];
}

- (void)makeSubviewsAndConstraints {
    self.view.backgroundColor = [UIColor clearColor];
    // 毛玻璃效果
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.view addSubview:backgroundView];
    [backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.documentFileView = [[BJLDocumentFileView alloc] initWithRoom:self.room];
    self.documentFileView.tableView.delegate = self;
    self.documentFileView.tableView.dataSource = self;
    self.documentFileView.delegate = self;
    self.documentFileView.cloudDirectoryTextView.delegate = self;
    for (NSString *cellIdentifier in [BJLDocumentFileCell allCellIdentifiers]) {
        [self.documentFileView.tableView registerClass:[BJLDocumentFileCell class] forCellReuseIdentifier:cellIdentifier];
    }
    [self.view addSubview:self.documentFileView];
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    UIEdgeInsets edgeinset = iPhone ? UIEdgeInsetsMake(20, 20, 20, 20) : UIEdgeInsetsMake(72, 44, 72, 44);
    [self.documentFileView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(edgeinset);
    }];
    [self updateDocumentFileViewHidden];
    [self makeDocumentFileViewCallback];
    [self makeObservingForDocumentFileView];

    UITapGestureRecognizer *tapGesture = ({
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardView)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture;
    });
    // overlay
    self.overlayView = ({
        UIView *view = [UIView new];
        view.userInteractionEnabled = YES;
        view.backgroundColor = [UIColor clearColor];
        [view addGestureRecognizer:tapGesture];
        view.accessibilityIdentifier = BJLKeypath(self, overlayView);
        view;
    });

    if (self.room.loginUser.isTeacherOrAssistant) {
        [self makeDocumentChooseView];
    }
}

#pragma mark - observing

- (void)makeObserving {
    bjl_weakify(self);
    [self bjl_kvoMerge:@[BJLMakeProperty(self, uploadDocumentRequest),
        BJLMakeProperty(self, uploadHomeworkRequest),
        BJLMakeProperty(self, uploadCloudFileRequest)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  BOOL hasDocumentUpload = self.uploadDocumentRequest && (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument);
                  BOOL hasCloudUpload = self.uploadCloudFileRequest && (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud);
                  BOOL hasHomeworkUpload = self.uploadHomeworkRequest && (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework);
                  self.documentFileView.uploadFileButton.enabled = !(hasDocumentUpload || hasCloudUpload || hasHomeworkUpload);
              }];

    [self makeObservingForDoc];
    [self makeObservingForHomework];
}

- (void)makeObservingForDocumentFileView {
    bjl_weakify(self);

    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify_ifNil(self) {
            [timer invalidate]; // or invalidate in dealloc
            return;
        }
        NSArray<NSIndexPath *> *indexPaths = [self.documentFileView.tableView indexPathsForVisibleRows];

        if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden
            || ![indexPaths count] || self.shouldShowSearchResult) {
            return;
        }

        for (NSIndexPath *indexPath in indexPaths) {
            BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
            BJLDocumentFileCell *cell = [[self.documentFileView.tableView cellForRowAtIndexPath:indexPath] bjl_as:[BJLDocumentFileCell class]];
            if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
                BJLHomeworkDownloadItem *downloadItem = [self localDownloadItemWithHomeworkFile:file];
                [cell updateWithDocumentFile:file downloadItem:downloadItem loginUser:self.room.loginUser isCloudSync:NO];
            }
            else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
                [cell updateWithDocumentFile:file downloadItem:nil loginUser:self.room.loginUser isCloudSync:NO];
            }
            else {
                [cell updateWithDocumentFile:file downloadItem:nil loginUser:self.room.loginUser isCloudSync:[self.syncCloudFidArray containsObject:file.remoteCloudFile.fileID]];
            }
        }
    }];

    [self.documentFileView setWillshowFilelistCallback:^{
        bjl_strongify(self);
        [self reloadTableViewWithLayoutType:self.documentFileLayoutType];
        [self cancelAllRemoteCloudLoadRequest];

        BOOL hasDocumentUpload = self.uploadDocumentRequest && (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument);
        BOOL hasCloudUpload = self.uploadCloudFileRequest && (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud);
        BOOL hasHomeworkUpload = self.uploadHomeworkRequest && (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework);
        self.documentFileView.uploadFileButton.enabled = !(hasDocumentUpload || hasCloudUpload || hasHomeworkUpload);

        NSString *title = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) ? BJLLocalizedString(@"上传作业") : BJLLocalizedString(@"上传文件");
        [self.documentFileView.uploadFileButton setTitle:title forState:UIControlStateNormal];
        [self.documentFileView.uploadFileButton setTitle:title forState:UIControlStateNormal | UIControlStateHighlighted];
        [self.documentFileView updateCloudDirectoryHidden:(![self.currentDirectoryStack count] || self.documentFileLayoutType != BJLDocumentFileLayoutTypeCloud)];

        if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
            [self loadAllRemoteCloudDocuments];
        }
    }];

    [self.documentFileView setUploadFileCallback:^{
        bjl_strongify(self);
        if (self.room.roomVM.isReceiveLiveBroadcast) {
            self.showErrorMessageCallback(BJLLocalizedString(@"转播时禁用音视频和管理课件相关操作"));
            return;
        }

        if (self.room.loginUser.isAssistant && !self.room.roomVM.getAssistantaAuthorityWithDocumentUpload) {
            if (self.showErrorMessageCallback) {
                self.showErrorMessageCallback(BJLLocalizedString(@"文档上传权限已被禁用"));
            }
            return;
        }

        if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
            [self showHomeWorkPickerViewController];
        }
        else {
            [self showChooseAnimatedOrNormalFileView];
        }
    }];

    [self.documentFileView setUploadImageCallback:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        if (self.room.roomVM.isReceiveLiveBroadcast) {
            self.showErrorMessageCallback(BJLLocalizedString(@"转播时禁用音视频和管理课件相关操作"));
            return;
        }

        if (self.room.loginUser.isAssistant && !self.room.roomVM.getAssistantaAuthorityWithDocumentUpload) {
            if (self.showErrorMessageCallback) {
                self.showErrorMessageCallback(BJLLocalizedString(@"文档上传权限已被禁用"));
            }
            return;
        }

        [self chooseImagePickerSourceTypeFromButton:button];
    }];

    [self.documentFileView setRefreshCallback:^{
        bjl_strongify(self);
        if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
            if (!self.room.loginUser.isTeacherOrAssistant) {
                BJLError *error = [self.room.homeworkVM reloadAllHomeworks];
                if (error) {
                    self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
                }
            }
            else {
                [self.room.homeworkVM requestForceRefreshHomeworkListWithCompletion:^(BOOL success, BJLError *_Nullable error) {
                    bjl_strongify(self);
                    if (error) {
                        self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
                    }
                }];
            }
        }
        else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
            bjl_returnIfRobot(1);
            [self.room.documentVM loadAllDocuments];
        }
        else {
            [self loadAllRemoteCloudDocuments];
        }
    }];
}

- (void)chooseImagePickerSourceTypeFromButton:(UIButton *)button {
    bjl_weakify(self);
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:button.currentTitle ?: BJLLocalizedString(@"发送图片")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [alert bjl_addActionWithTitle:BJLLocalizedString(@"拍照")
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  bjl_strongify(self);
                                  [self chooseImageWithSourceType:sourceType];
                              }];
    }

    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [alert bjl_addActionWithTitle:BJLLocalizedString(@"从相册中选取")
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  bjl_strongify(self);
                                  [self chooseImageWithSourceType:sourceType];
                              }];
    }

    [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消")
                            style:UIAlertActionStyleCancel
                          handler:nil];

    alert.popoverPresentationController.sourceView = button;
    alert.popoverPresentationController.sourceRect = button.bounds;
    alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)chooseImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        [BJLAuthorization checkCameraAccessAndRequest:YES callback:^(BOOL granted, UIAlertController *_Nullable alert) {
            if (granted) {
                [self chooseImageWithCamera];
            }
            else if (alert) {
                if (self.presentedViewController) {
                    [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
                }
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    else {
        [self.photoPicker requestAuthorizationIfNeededAndPresentPickerControllerFrom:self];
    }
}

#pragma mark - UIImagePickerController

- (void)chooseImageWithCamera {
    self.interruptedRecordingVideo = self.room.recordingVM.recordingVideo;
    if (self.interruptedRecordingVideo && !self.room.recordingVM.hasAsCameraUser) {
        [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                  recordingVideo:NO];
    }

    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.allowsEditing = NO;
    imagePickerController.delegate = self;
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self bjl_presentFullScreenViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.interruptedRecordingVideo && !self.room.recordingVM.hasAsCameraUser) {
            [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingVideo
                                      recordingVideo:YES];
            self.interruptedRecordingVideo = NO;
        }

        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImage *thumbnail = [image bjl_imageFillSize:BJLAspectFillSize([UIScreen mainScreen].bounds.size,
                                                          image.size.width / image.size.height)
                                              enlarge:NO];
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        NSError *error = nil;
        ICLImageFile *imageFile = [ICLImageFile imageFileWithImage:image
                                                         thumbnail:thumbnail
                                                         mediaType:mediaType
                                                             error:&error];
        if (!imageFile) {
            [BJLProgressHUD bjl_showHUDForText:BJLLocalizedString(@"照片获取出错") superview:self.view animated:YES];
            return;
        }

        [self uploadImage:imageFile];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.interruptedRecordingVideo && !self.room.recordingVM.hasAsCameraUser) {
            [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingVideo
                                      recordingVideo:YES];
            self.interruptedRecordingVideo = NO;
        }
    }];
}

#pragma mark - bjl photo picker
- (void)photoPicker:(BJLPhotoPicker *)BJLPhotoPicker didFinishPicking:(BJLPhotoPickerResult *)result {
    if (result == nil || result.empty) {
        [BJLPhotoPicker.viewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)photoPicker:(BJLPhotoPicker *)BJLPhotoPicker didFinishLoadImageData:(NSArray<ICLImageFile *> *)data failureItems:(NSArray<NSError *> *)failureItems originResult:(BJLPhotoPickerResult *)result {
    bjl_weakify(self);
    [BJLPhotoPicker.viewController dismissViewControllerAnimated:YES completion:^{
        bjl_strongify(self)

            [self uploadImage:data.firstObject];
    }];
}

- (void)uploadImage:(ICLImageFile *)image {
    if (!image.filePath) { return; }

    UIDocument *document = [[UIDocument alloc] initWithFileURL:[NSURL fileURLWithPath:image.filePath]];
    BJLDocumentFile *documentFile = [[BJLDocumentFile alloc] initWithLocalDocument:document];
    if (![documentFile shouldSupportUploadAndPlay]) {
        if (self.showErrorMessageCallback) {
            self.showErrorMessageCallback(BJLLocalizedString(@"上传文件格式不支持"));
        }
        return;
    }

    if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
        [self uploadDocumentFile:documentFile];
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
        [self uploadHomeWorkFile:documentFile];
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
        [self uploadCloudDocumentFile:documentFile];
    }
}

#pragma mark - actions

- (void)makeActions {
    // close button
    [self.documentFileView.closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    // add animate document file
    [self.addAnimatedDocumentFileEmptyButton addTarget:self action:@selector(addAnimatedDocumentFile) forControlEvents:UIControlEventTouchUpInside];
    // add normal document file
    [self.addNormalDocumentFileEmptyButton addTarget:self action:@selector(addNormalDocumentFile) forControlEvents:UIControlEventTouchUpInside];
    self.documentFileView.searchTextField.delegate = self;
    [self.documentFileView.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

// 隐藏
- (void)hide {
    if (self.hideCallback) {
        self.hideCallback();
    }
    [self bjl_removeFromParentViewControllerAndSuperiew];
}

#pragma mark - choose Animated/Normal file

- (void)showChooseAnimatedOrNormalFileView {
    self.chooseDocumentLayer.hidden = NO;
}

// 添加动态PPT
- (void)addAnimatedDocumentFile {
    self.chooseDocumentLayer.hidden = YES;
    self.isSelectAnimatedDocumentFile = YES;
    [self showDocumentPickerViewController];
}

// 添加普通PPT
- (void)addNormalDocumentFile {
    self.chooseDocumentLayer.hidden = YES;
    self.isSelectAnimatedDocumentFile = NO;
    [self showDocumentPickerViewController];
}

- (void)showDocumentPickerViewController {
    if (@available(iOS 11.0, *)) {
        // open 仅限于打开自己的文件, import 可以导入共享的文件
        NSArray *array = @[@"public.data"];
        if (self.isSelectAnimatedDocumentFile) {
            array = @[@"org.openxmlformats.presentationml.presentation", @"com.microsoft.powerpoint.ppt"];
        }
        UIDocumentPickerViewController *vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:array
                                                                                                    inMode:UIDocumentPickerModeImport];
        vc.delegate = self;
        vc.allowsMultipleSelection = NO;
        if (self.presentedViewController) {
            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self bjl_presentFullScreenViewController:vc animated:YES completion:nil];
    }
    else {
        if (self.showErrorMessageCallback) {
            self.showErrorMessageCallback(BJLLocalizedString(@"当前系统版本不支持，请升级到11.0以上版本"));
        }
    }
}

- (void)reloadTableViewWithLayoutType:(BJLDocumentFileLayoutType)layoutType {
    if (!self || !self.isViewLoaded || !self.view.window || self.view.hidden
        || (self.documentFileLayoutType != layoutType)) {
        return;
    }

    [self updateDocumentFileViewHidden];
    [self.documentFileView.tableView reloadData];

    if (self.documentFileLayoutType != BJLDocumentFileLayoutTypeHomework) {
        return;
    }

    // 仅针对作业特殊处理的自动加载更多
    NSArray<NSIndexPath *> *indexPaths = [self.documentFileView.tableView indexPathsForVisibleRows];
    if ([indexPaths count] == [self allDocumentFileListCountOfTableView] && [indexPaths count] > 0) {
        if (self.shouldShowSearchResult && self.hasmoreHomework) {
            bjl_returnIfRobot(1.0);
            BJLError *error = [self.room.homeworkVM searchHomeworksWithKeyword:self.documentFileView.searchTextField.text lastHomework:self.homeworkCursor count:20];
            if (error) {
                self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
            }
        }
        else if (!self.shouldShowSearchResult && self.room.homeworkVM.hasMoreHomeworks) {
            bjl_returnIfRobot(1.0);
            BJLError *error = [self.room.homeworkVM loadMoreHomeworksWithCount:20];
            if (error) {
                self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
            }
        }
    }
}

- (NSInteger)allDocumentFileListCountOfTableView {
    if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
        if (self.shouldShowSearchResult) {
            return self.mutableCloudSearchResultFileList.count;
        }
        else {
            return self.mutableCloudFileList.count + self.mutableTranscodeCloudFileList.count;
        }
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
        if (self.shouldShowSearchResult) {
            return self.mutableDocumentSearchResultFileList.count;
            ;
        }
        else {
            return self.mutableAllDocumentFileList.count + self.mutableTranscodeDocumentFileList.count + self.mutableMediaFileList.count;
        }
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
        if (self.shouldShowSearchResult) {
            return self.mutableHomeworkSearchResultFileList.count;
        }
        else {
            return self.mutableHomeworkFileList.count + self.mutableTranscodeHomeworkFileList.count;
        }
    }
    return 0;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.documentFileView.searchTextField) {
        if (self.overlayView.superview && self.overlayView.superview != self.view) {
            if ([self.overlayView respondsToSelector:@selector(removeFromSuperview)]) {
                [self.overlayView removeFromSuperview];
            }
        }

        if (!self.overlayView.superview) {
            [self.view addSubview:self.overlayView];
            [self.overlayView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.view);
            }];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([self.overlayView respondsToSelector:@selector(removeFromSuperview)]) {
        [self.overlayView removeFromSuperview];
    }
    [self reloadSearchResultTableViewWith:textField.text];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    UITextRange *selectedRange = textField.markedTextRange;
    if (selectedRange == nil || selectedRange.empty) {
        NSString *text = textField.text;
        [self reloadSearchResultTableViewWith:text];
    }
}

- (void)reloadSearchResultTableViewWith:(NSString *)keyWord {
    self.documentFileView.clearSearchButton.hidden = !keyWord.length;
    if (!keyWord.length) {
        [self.mutableDocumentSearchResultFileList removeAllObjects];
        [self.mutableHomeworkSearchResultFileList removeAllObjects];
        [self.mutableCloudSearchResultFileList removeAllObjects];
        self.homeworkCursor = nil;
        self.documentFileView.shouldShowSearchResult = NO;
        [self reloadTableViewWithLayoutType:self.documentFileLayoutType];
        [self.documentFileView updateCloudDirectoryHidden:(![self.currentDirectoryStack count] || self.documentFileLayoutType != BJLDocumentFileLayoutTypeCloud)];
        return;
    }

    NSMutableArray<BJLDocumentFile *> *resultArray = [NSMutableArray new];

    if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
        for (BJLDocumentFile *documentFile in [self.mutableAllDocumentFileList copy]) {
            if ([documentFile.name containsString:keyWord]) {
                [resultArray bjl_addObject:documentFile];
            }
        }
        for (BJLDocumentFile *documentFile in [self.mutableTranscodeDocumentFileList copy]) {
            if ([documentFile.name containsString:keyWord]) {
                [resultArray bjl_addObject:documentFile];
            }
        }
        for (BJLDocumentFile *documentFile in self.mutableMediaFileList) {
            if ([documentFile.name containsString:keyWord]) {
                [resultArray bjl_addObject:documentFile];
            }
        }
        self.mutableDocumentSearchResultFileList = resultArray;
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
        self.homeworkCursor = nil;
        [self.mutableHomeworkSearchResultFileList removeAllObjects];
        [self.room.homeworkVM searchHomeworksWithKeyword:keyWord lastHomework:self.homeworkCursor count:20];
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
        bjl_weakify(self);
        self.documentFileView.shouldShowSearchResult = YES; // 面包屑依赖搜索状态, 需要提前先更新
        [self.mutableCloudSearchResultFileList removeAllObjects];
        [self.currentDirectoryStack removeAllObjects];
        [self.documentFileView updateCloudDirectoryHidden:NO];

        if (self.searchCloudTask) {
            [self.searchCloudTask cancel];
            self.searchCloudTask = nil;
        }
        self.currentSearchPage = 1;
        [self cancelAllRemoteCloudLoadRequest];
        self.loadingCloudHud = [BJLProgressHUD bjl_showHUDForLoadingWithSuperview:self.documentFileView.progressHUDLayer animated:NO];

        self.searchCloudTask = [self.room.cloudDiskVM requestSearchCloudFileListWithKeyword:keyWord
                                                                             targetFinderID:nil
                                                                                       page:self.currentSearchPage
                                                                                   pagesize:kCloudPageSize
                                                                                 completion:^(NSString *_Nonnull keyword, NSArray<BJLCloudFile *> *_Nullable documentList, BJLError *_Nullable error) {
                                                                                     bjl_strongify(self);
                                                                                     self.searchCloudTask = nil;
                                                                                     [self.loadingCloudHud hideAnimated:YES];
                                                                                     self.loadingCloudHud = nil;

                                                                                     if (error) {
                                                                                         if (self.showErrorMessageCallback) {
                                                                                             self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
                                                                                         }
                                                                                         return;
                                                                                     }

                                                                                     self.currentSearchPage++;
                                                                                     NSMutableArray<BJLDocumentFile *> *mutableCloudFileList = [NSMutableArray new];

                                                                                     for (BJLCloudFile *cloudFile in documentList) {
                                                                                         BJLDocumentFile *file = [[BJLDocumentFile alloc] initWithRemoteCloudFile:cloudFile];
                                                                                         BOOL mediaFile = file.type == BJLDocumentFileAudio || file.type == BJLDocumentFileVideo;
                                                                                         if (mediaFile && self.room.roomInfo.roomType != BJLRoomType_interactiveClass) {
                                                                                             continue;
                                                                                         }
                                                                                         [mutableCloudFileList bjl_addObject:file];
                                                                                     }

                                                                                     self.mutableCloudSearchResultFileList = mutableCloudFileList;
                                                                                     [self reloadTableViewWithLayoutType:self.documentFileLayoutType];
                                                                                 }];
    }
    self.documentFileView.shouldShowSearchResult = YES;
    [self reloadTableViewWithLayoutType:self.documentFileLayoutType];
}

#pragma mark - tableview view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.shouldShowSearchResult) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self documentFileListWithSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
    NSString *cellIdentifier = [BJLDocumentFileCell cellIdentifierForCellType:(BJLDocumentFileCellType)self.documentFileLayoutType];
    BJLDocumentFileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    BJLHomeworkDownloadItem *downloadItem = [self localDownloadItemWithHomeworkFile:file];

    BOOL isCloudSync = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) ? [self.syncCloudFidArray containsObject:file.remoteCloudFile.fileID] : NO;
    [cell updateWithDocumentFile:file downloadItem:downloadItem loginUser:self.room.loginUser isCloudSync:isCloudSync];
    bjl_weakify(self)
        [cell setShowDocumentCallback:^{
            bjl_strongify(self);
            BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
            if (![file shouldSupportUploadAndPlay]) {
                if (self.showErrorMessageCallback) {
                    self.showErrorMessageCallback(BJLLocalizedString(@"只支持PC端打开"));
                }
                return;
            }

            BOOL mediaFile = file.type == BJLDocumentFileAudio || file.type == BJLDocumentFileVideo;
            BOOL bdsFile = file.type == BJLDocumentFileBDS;
            if (mediaFile || bdsFile) {
                if (self.selectDocumentFileCallback) {
                    self.selectDocumentFileCallback(file, nil);
                }
                return;
            }

            if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
                if (self.selectDocumentFileCallback) {
                    self.selectDocumentFileCallback(file, nil);
                }
            }
            else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
                [self syncAndOpenCloudDocumentFile:file];
            }
            else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
                [self syncAndOpenHomeworkDocumentFile:file];
            }
        }];

    [cell setDownloadDocumentCallback:^(UIButton *button) {
        bjl_strongify(self);
        CGRect rectForOpenInIpad = [button.superview convertRect:button.frame toView:self.view];
        BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
        [self downloadActionWithHomeworkFile:file withRect:rectForOpenInIpad];
    }];

    [cell setDeleteDocumentCallback:^{
        bjl_strongify(self);
        BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
        [self deleteActionInCellWithFile:file];
    }];

    [cell setShowErrorCallback:^(UIButton *button) {
        bjl_strongify(self);
        BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
        UILabel *errorLabel = [self makeErrorTipLableWithText:file.errorMessage];
        CGSize size = [self bjl_suitableSizeWithText:errorLabel.text attributedText:nil maxWidth:300];
        UIViewController *optionViewController = ({
            UIViewController *viewController = [[UIViewController alloc] init];
            viewController.view.backgroundColor = BJLTheme.windowBackgroundColor;
            viewController.modalPresentationStyle = UIModalPresentationPopover;
            viewController.preferredContentSize = CGSizeMake(size.width + 20.0, 50);
            viewController.popoverPresentationController.backgroundColor = BJLTheme.windowBackgroundColor;
            viewController.popoverPresentationController.delegate = self;
            viewController.popoverPresentationController.sourceView = button;
            viewController.popoverPresentationController.sourceRect = CGRectMake(button.bounds.origin.x + 5, button.bounds.origin.y, 1.0, 1.0);
            viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
            viewController;
        });
        [optionViewController.view addSubview:errorLabel];
        [errorLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(optionViewController.view).insets(UIEdgeInsetsMake(10, 10, 20, 10));
        }];
        if (self.parentViewController.presentedViewController) {
            [self.parentViewController.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self.parentViewController presentViewController:optionViewController animated:YES completion:nil];
    }];

    [cell setReuploadCallback:^{
        bjl_strongify(self);
        BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
        BJLDocumentFileType fileType = file.type;
        [self deleteFile:file];

        if (!file.localPathURL) {
            if (self.showErrorMessageCallback) {
                self.showErrorMessageCallback(BJLLocalizedString(@"请重新上传"));
            }
            return;
        }
        UIDocument *document = [[UIDocument alloc] initWithFileURL:file.localPathURL];
        BJLDocumentFile *documentFile = [[BJLDocumentFile alloc] initWithLocalDocument:document];
        documentFile.type = fileType;
        if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
            [self uploadDocumentFile:documentFile];
        }
        else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
            [self uploadCloudDocumentFile:documentFile];
        }
    }];

    [cell setTurnToNormalDocumentCallback:^{
        bjl_strongify(self);
        BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
        [self deleteSelectedDocumentFile:file];
        if (!file.localPathURL) {
            if (self.showErrorMessageCallback) {
                self.showErrorMessageCallback(BJLLocalizedString(@"请重新上传"));
            }
            return;
        }
        UIDocument *document = [[UIDocument alloc] initWithFileURL:file.localPathURL];
        BJLDocumentFile *documentFile = [[BJLDocumentFile alloc] initWithLocalDocument:document];
        documentFile.type = BJLDocumentFileNormalPPT;
        if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
            [self uploadDocumentFile:documentFile];
        }
        else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
            [self uploadCloudDocumentFile:documentFile];
        }
    }];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
    return (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud && file.remoteCloudFile.isDirectory);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BJLDocumentFile *file = [self documentFileWithIndexPath:indexPath];
    if (file.remoteCloudFile.isDirectory) {
        [self.mutableCloudFileList removeAllObjects];
        [self reloadTableViewWithLayoutType:self.documentFileLayoutType];
        [self.currentDirectoryStack bjl_addObject:file];
        [self loadAllRemoteCloudDocuments];
    }
}

- (void)deleteActionInCellWithFile:(BJLDocumentFile *)file {
    // 如果是上传中的文档 , 取消上传
    if (file.state == BJLDocumentFileUploading || file.state == BJLDocumentFileUploadError || file.state == BJLDocumentFileTranscodeError) {
        [self deleteFile:file];
        return;
    }

    NSString *tipMessage = nil;
    if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
        tipMessage = BJLLocalizedString(@"确定删除课件吗?");
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
        tipMessage = BJLLocalizedString(@"确定删除云盘文件吗?");
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
        tipMessage = BJLLocalizedString(@"确定删除作业吗?");
    }

    BJLPopoverViewController *popoverViewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLDeletePPT message:tipMessage];
    [self bjl_addChildViewController:popoverViewController superview:self.view];
    [popoverViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];
    bjl_weakify(self);
    [popoverViewController setConfirmCallback:^{
        bjl_strongify(self);
        [self deleteFile:file];
    }];
}

- (void)deleteFile:(BJLDocumentFile *)file {
    if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
        [self deleteSelectedDocumentFile:file];
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
        [self deleteSelectedCloudDocumentFile:file];
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
        [self deleteSelectedHomework:file];
    }
}

#pragma mark - load more user

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.dragging && !scrollView.decelerating) {
        return;
    }
    // 作业/云盘都是分页的
    if (!self.documentFileView.tableView.hidden
        && [self atTheBottomOfTableView]) {
        // 作业加载更多
        if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
            if (self.shouldShowSearchResult && self.hasmoreHomework) {
                bjl_returnIfRobot(1.0);
                BJLError *error = [self.room.homeworkVM searchHomeworksWithKeyword:self.documentFileView.searchTextField.text lastHomework:self.homeworkCursor count:20];
                if (error) {
                    self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
                }
            }
            else if (!self.shouldShowSearchResult && self.room.homeworkVM.hasMoreHomeworks) {
                bjl_returnIfRobot(1.0);
                BJLError *error = [self.room.homeworkVM loadMoreHomeworksWithCount:20];
                if (error) {
                    self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
                }
            }
        }
        else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) { // 云盘加载更多
            bjl_returnIfRobot(1.0);
            if ((self.shouldShowSearchResult && !self.searchCloudTask)
                || (!self.shouldShowSearchResult && !self.requestCloudListTask)) {
                [self loadMoreCloudList];
            }
        }
    }
}

- (BOOL)atTheBottomOfTableView {
    UITableView *tableView = self.documentFileView.tableView;
    CGFloat contentOffsetY = tableView.contentOffset.y;
    CGFloat bottom = tableView.contentInset.bottom;
    CGFloat viewHeight = CGRectGetHeight(tableView.frame);
    CGFloat contentHeight = tableView.contentSize.height;
    CGFloat bottomOffset = contentOffsetY + viewHeight - bottom - contentHeight;
    return bottomOffset >= 0.0 - 50;
}

#pragma mark - UIDocumentPicker Delegate

// TODO:选取的文件存在没有预览图的警告
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    self.chooseDocumentLayer.hidden = YES;
    for (NSURL *url in urls) {
        UIDocument *document = [[UIDocument alloc] initWithFileURL:url];
        BJLDocumentFile *documentFile = [[BJLDocumentFile alloc] initWithLocalDocument:document];
        documentFile.type = self.isSelectAnimatedDocumentFile ? BJLDocumentFileAnimatedPPT : documentFile.type;
        if (![documentFile shouldSupportUploadAndPlay]) {
            if (self.showErrorMessageCallback) {
                self.showErrorMessageCallback(BJLLocalizedString(@"上传文件格式不支持"));
            }
            return;
        }

        if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
            [self uploadDocumentFile:documentFile];
        }
        else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
            [self uploadHomeWorkFile:documentFile];
        }
        else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
            [self uploadCloudDocumentFile:documentFile];
        }
    }
    self.isSelectAnimatedDocumentFile = NO;
}

#pragma mark - <UIPopoverPresentationControllerDelegate>

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

#pragma mark -

- (nullable NSArray<BJLDocumentFile *> *)documentFileListWithSection:(NSInteger)section {
    NSArray<BJLDocumentFile *> *fileList = nil;
    if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) {
        if (self.shouldShowSearchResult) {
            fileList = self.mutableCloudSearchResultFileList;
        }
        else {
            if (section == 0) {
                fileList = self.mutableCloudFileList;
            }
            else {
                if (![self.currentDirectoryStack count]) {
                    fileList = self.mutableTranscodeCloudFileList;
                }
            }
        }
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) {
        if (self.shouldShowSearchResult) {
            fileList = self.mutableDocumentSearchResultFileList;
        }
        else {
            if (section == 0) {
                fileList = [self sortedDocumentFileList];
            }
            else {
                fileList = self.mutableTranscodeDocumentFileList;
            }
        }
    }
    else if (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) {
        if (self.shouldShowSearchResult) {
            fileList = self.mutableHomeworkSearchResultFileList;
        }
        else {
            if (section == 0) {
                fileList = self.mutableHomeworkFileList;
            }
            else {
                fileList = self.mutableTranscodeHomeworkFileList;
            }
        }
    }
    return fileList;
}

- (NSArray<BJLDocumentFile *> *)sortedDocumentFileList {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.mutableAllDocumentFileList];
    [array addObjectsFromArray:self.mutableMediaFileList];
    [array sortUsingComparator:^NSComparisonResult(BJLDocumentFile *_Nonnull file1, BJLDocumentFile *_Nonnull file2) {
        if (file1.isRelatedDocument && !file2.isRelatedDocument) {
            return NSOrderedAscending;
        }
        else if (file2.isRelatedDocument && !file1.isRelatedDocument) {
            return NSOrderedDescending;
        }
        else {
            if (file1.isRelatedDocument && file2.isRelatedDocument) {
                if ((file1.type == BJLDocumentFileAudio || file1.type == BJLDocumentFileVideo)
                    && (file2.type != BJLDocumentFileAudio || file2.type != BJLDocumentFileVideo)) {
                    return NSOrderedAscending;
                }
                else if ((file1.type != BJLDocumentFileAudio || file1.type != BJLDocumentFileVideo)
                         && (file2.type == BJLDocumentFileAudio || file2.type == BJLDocumentFileVideo)) {
                    return NSOrderedDescending;
                }
                else {
                    switch ([file1.remoteID compare:file2.remoteID]) {
                        case NSOrderedAscending:
                            return NSOrderedAscending;

                        case NSOrderedSame:
                            return NSOrderedAscending;

                        case NSOrderedDescending:
                            return NSOrderedDescending;

                        default:
                            break;
                    }
                }
            }
            else {
                switch ([file1.remoteID compare:file2.remoteID]) {
                    case NSOrderedAscending:
                        return NSOrderedAscending;

                    case NSOrderedSame:
                        return NSOrderedAscending;

                    case NSOrderedDescending:
                        return NSOrderedDescending;

                    default:
                        break;
                }
            }
        }
    }];
    return array;
}

- (nullable BJLDocumentFile *)documentFileWithIndexPath:(NSIndexPath *)indexPath {
    NSArray<BJLDocumentFile *> *fileList = [self documentFileListWithSection:indexPath.section];
    return [fileList bjl_objectAtIndex:indexPath.row];
}

- (void)updateDocumentFileViewHidden {
    NSInteger cloudFileCount = (self.mutableTranscodeCloudFileList.count && !self.currentDirectoryStack.count) + self.mutableCloudFileList.count;
    BOOL hasCloudFile = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeCloud) && (self.shouldShowSearchResult ? self.mutableCloudSearchResultFileList.count : cloudFileCount);

    NSInteger documentCount = self.mutableAllDocumentFileList.count + self.mutableTranscodeDocumentFileList.count + self.mutableMediaFileList.count;
    BOOL hasDocument = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeDocument) && (self.shouldShowSearchResult ? self.mutableDocumentSearchResultFileList.count : documentCount);

    NSInteger homeworkFileCount = self.mutableTranscodeHomeworkFileList.count + self.mutableHomeworkFileList.count;
    BOOL hasHomework = (self.documentFileLayoutType == BJLDocumentFileLayoutTypeHomework) && (self.shouldShowSearchResult ? self.mutableHomeworkSearchResultFileList.count : homeworkFileCount);

    [self.documentFileView updateDocumentFileViewHidden:!hasDocument && !hasCloudFile && !hasHomework];
}

- (BJLDocumentFileLayoutType)documentFileLayoutType {
    return self.documentFileView.documentFileLayoutType;
}

- (BOOL)shouldShowSearchResult {
    return self.documentFileView.shouldShowSearchResult;
}

- (void)hideKeyboardView {
    [self.documentFileView.searchTextField resignFirstResponder];

    if ([self.overlayView respondsToSelector:@selector(removeFromSuperview)]) {
        [self.overlayView removeFromSuperview];
    }
}

- (UILabel *)makeErrorTipLableWithText:(NSString *)errorMessage {
    UILabel *label = [UILabel new];
    label.textColor = BJLTheme.viewTextColor;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = errorMessage;
    return label;
}

#pragma mark - BJLDocumentFileCloudDirectoryDelegate

/*
 self.currentDirectoryStack 为当前目录结构栈
 面包屑展示要求:每一级目录文字不超过8个字. 展示不下使用…缩略, 面包屑展示最大宽度为cloudDirectoryTextView.width.
 对self.currentDirectoryStack 从后向前遍历, 减去计算每一级目录文字宽度, 当剩余值<0 时,表示当前目录已展示不下, 遍历完可以拿到一个最多能展示的目录数组shouldShowDirectoryStack.
 使用shouldShowDirectoryStack保存的目录name,编辑得到一个支持点击事件的富文本,即为功能所需要的面包屑路径
 */
- (nullable NSAttributedString *)currentCloudDirectoryString {
    // 在当前根目录
    if (![self.currentDirectoryStack count] && !self.documentFileView.shouldShowSearchResult) {
        return nil;
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    NSAttributedString *rootDirectoryString = [self attributedStringWithString:BJLLocalizedString(@"我的云盘") foregroundColor:BJLTheme.viewTextColor url:[NSURL URLWithString:@"root"]];
    NSAttributedString *gapString = [self attributedStringWithString:@" | " foregroundColor:BJLTheme.viewTextColor url:nil];
    [attributedText appendAttributedString:rootDirectoryString];
    [attributedText appendAttributedString:gapString];

    if (self.documentFileView.shouldShowSearchResult) {
        NSAttributedString *searchString = [self attributedStringWithString:[NSString stringWithFormat:BJLLocalizedString(@"搜索“%@”"), self.documentFileView.searchTextField.text]
                                                            foregroundColor:BJLTheme.brandColor
                                                                        url:nil];
        [attributedText appendAttributedString:searchString];
        self.documentFileView.cloudDirectoryTextView.attributedText = attributedText;
        self.documentFileView.cloudDirectoryTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        self.documentFileView.cloudDirectoryTextView.linkTextAttributes = @{NSForegroundColorAttributeName: BJLTheme.viewTextColor};
        self.documentFileView.cloudDirectoryTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        return attributedText;
    }

    NSAttributedString *abbreviationString = [self attributedStringWithString:@"…/ " foregroundColor:BJLTheme.viewTextColor url:nil];
    NSAttributedString *gapLineString = [self attributedStringWithString:@" / " foregroundColor:BJLTheme.viewTextColor url:nil];

    CGFloat maxWidth = CGRectGetWidth(self.documentFileView.cloudDirectoryTextView.bounds);
    CGFloat headWidth = [self oneRowSizeWithText:nil attributedText:attributedText fontSize:12.0].width;
    CGFloat remainWidth = maxWidth - headWidth;
    NSArray<BJLDocumentFile *> *currentDirectoryStack = [self.currentDirectoryStack copy];
    NSMutableArray<BJLDocumentFile *> *shouldShowDirectoryStack = [NSMutableArray new];
    BOOL needAbbreviationString = NO;

    for (BJLDocumentFile *documentFile in [currentDirectoryStack reverseObjectEnumerator]) {
        NSString *directoryName = [self abbreviationDirectoryNameWithDocumentFile:documentFile];
        NSAttributedString *directoryString = [self attributedStringWithString:directoryName
                                                               foregroundColor:BJLTheme.viewTextColor
                                                                           url:[NSURL URLWithString:documentFile.remoteCloudFile.finderID]];
        CGFloat width = [self oneRowSizeWithText:nil attributedText:directoryString fontSize:12.0].width;
        remainWidth = remainWidth - width;
        if (remainWidth < 0) {
            remainWidth = remainWidth + width;
            break;
        }
        if (![documentFile.remoteCloudFile.finderID isEqualToString:self.currentDirectoryStack.lastObject.remoteCloudFile.finderID]) {
            CGFloat gapLineStringWidth = [self oneRowSizeWithText:nil attributedText:gapLineString fontSize:12.0].width;
            remainWidth = remainWidth - gapLineStringWidth;
            if (remainWidth < 0) {
                remainWidth = remainWidth + width + gapLineStringWidth;
                break;
            }
        }
        [shouldShowDirectoryStack bjl_addObject:documentFile];
    }

    if (![shouldShowDirectoryStack count]) {
        [shouldShowDirectoryStack bjl_addObject:self.currentDirectoryStack.lastObject];
    }
    if ([shouldShowDirectoryStack count] < [currentDirectoryStack count]) {
        needAbbreviationString = YES;
        CGFloat width = [self oneRowSizeWithText:nil attributedText:abbreviationString fontSize:12.0].width;
        remainWidth = remainWidth - width;
        if (remainWidth<0 && [shouldShowDirectoryStack count]> 1) {
            [shouldShowDirectoryStack removeLastObject];
        }
    }

    if (needAbbreviationString) {
        [attributedText appendAttributedString:abbreviationString];
    }
    for (BJLDocumentFile *documentFile in [shouldShowDirectoryStack reverseObjectEnumerator]) {
        NSString *directoryName = [self abbreviationDirectoryNameWithDocumentFile:documentFile];
        if (![documentFile.remoteCloudFile.finderID isEqualToString:self.currentDirectoryStack.lastObject.remoteCloudFile.finderID]) {
            NSAttributedString *directoryString = [self attributedStringWithString:directoryName
                                                                   foregroundColor:BJLTheme.viewTextColor
                                                                               url:[NSURL URLWithString:documentFile.remoteCloudFile.finderID]];
            [attributedText appendAttributedString:directoryString];
            [attributedText appendAttributedString:gapLineString];
        }
        else {
            NSAttributedString *directoryString = [self attributedStringWithString:directoryName
                                                                   foregroundColor:BJLTheme.brandColor
                                                                               url:nil];
            [attributedText appendAttributedString:directoryString];
        }
    }
    self.documentFileView.cloudDirectoryTextView.attributedText = attributedText;
    self.documentFileView.cloudDirectoryTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.documentFileView.cloudDirectoryTextView.linkTextAttributes = @{NSForegroundColorAttributeName: BJLTheme.viewTextColor};

    return attributedText;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSString *finerID = URL.absoluteString;
    if ([finerID isEqualToString:@"root"]) {
        // 点击跳转回根目录
        [self.currentDirectoryStack removeAllObjects];
        if (self.documentFileView.shouldShowSearchResult) {
            self.documentFileView.shouldShowSearchResult = NO;
            self.documentFileView.searchTextField.text = nil;
        }
        [self loadAllRemoteCloudDocuments];
        return YES;
    }
    else if (finerID.length) {
        __block NSInteger targetIndex = NSNotFound;
        NSArray *currentDirectoryStack = [self.currentDirectoryStack copy];
        [currentDirectoryStack enumerateObjectsUsingBlock:^(BJLDocumentFile *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([finerID isEqualToString:obj.remoteCloudFile.finderID]) {
                targetIndex = idx;
                *stop = YES;
            }
        }];
        if (targetIndex != NSNotFound) {
            self.currentDirectoryStack = [[currentDirectoryStack subarrayWithRange:NSMakeRange(0, targetIndex + 1)] mutableCopy];
            [self loadAllRemoteCloudDocuments];
        }
        return YES;
    }
    return NO;
}

- (CGSize)oneRowSizeWithText:(nullable NSString *)text attributedText:(nullable NSAttributedString *)attributedText fontSize:(CGFloat)fontSize {
    __block CGFloat messageLabelHeight = 0.0;
    __block CGFloat messageLabelWidth = 0.0;
    if (text) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, fontSize) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil];
        messageLabelWidth = rect.size.width;
        messageLabelHeight = rect.size.height;
    }
    else if (attributedText) {
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, fontSize) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
        messageLabelWidth = rect.size.width;
        messageLabelHeight = rect.size.height;
    }
    return CGSizeMake(ceil(messageLabelWidth), ceil(messageLabelHeight));
}

- (NSString *)abbreviationDirectoryNameWithDocumentFile:(BJLDocumentFile *)documentFile {
    if (documentFile.remoteCloudFile.fileName.length > directoryNameMaxLenth) {
        return [NSString stringWithFormat:BJLLocalizedString(@"%@…"), [documentFile.remoteCloudFile.fileName substringToIndex:directoryNameMaxLenth]];
    }
    return documentFile.remoteCloudFile.fileName;
}

- (NSAttributedString *)attributedStringWithString:(NSString *)string
                                   foregroundColor:(UIColor *)foregroundColor
                                               url:(nullable NSURL *)url {
    NSMutableDictionary *attributedDic = [@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
        NSForegroundColorAttributeName: foregroundColor} mutableCopy];
    if (url) {
        [attributedDic bjl_setObject:url forKey:NSLinkAttributeName];
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributedDic];
    return attributedString;
}

#pragma mark - getter
- (BJLPhotoPicker *)photoPicker {
    if (!_photoPicker) {
        BJLPhotoPickerConfiguration *config = [[BJLPhotoPickerConfiguration alloc] init];
        config.selectionLimit = 1;
        config.highQualityMode = NO;
        _photoPicker = [[BJLPhotoPicker alloc] initWithConfiguration:config];
        _photoPicker.delegate = self;
    }
    return _photoPicker;
}
@end

NS_ASSUME_NONNULL_END
