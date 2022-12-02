//
//  BJLPhotoListViewController.m
//  BJLiveUI
//
//  Created by Ney on 3/5/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLPhotoListViewController.h"
#import "BJLPhotoListCell.h"
#import "BJLPhotoPicker.h"

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveBase/BJLAuthorization.h>
#import "BJL_iCloudLoading.h"
#import "BJLPhotoBrowserView.h"

/**
 *  图片中间的间距
 */
#define kNewImageIdentifier @"kNewImageIdentifier"
#define kCellIdentifier     @"kCellIdentifier"

@implementation BJLPhotoMode
+ (instancetype)modeWithURLString:(NSString *)urlString {
    BJLPhotoMode *m = [self new];
    m.urlMode = urlString;
    return m;
}
+ (instancetype)modeWithICLImageFile:(ICLImageFile *)imageFile {
    BJLPhotoMode *m = [self new];
    m.rawImageMode = imageFile;
    return m;
}
@end

@implementation BJLPhotoListConfiguration
@end

@interface BJLPhotoListViewController () <BJLPhotoPickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) BJLPhotoListConfiguration *configurationStorage;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) BJLPhotoPicker *picker;
@property (nonatomic, strong) BJLPhotoBrowserView *browserView;
@end

@implementation BJLPhotoListViewController
- (instancetype)init {
    return [self initWithConfiguration:nil];
}

- (instancetype)initWithConfiguration:(BJLPhotoListConfiguration *)configuration {
    self = [super init];
    if (self) {
        if (!configuration) {
            configuration = [self defaultConfiguration];
        }

        if (configuration.selectionLimit < 1) {
            return nil;
        }

        self.configurationStorage = configuration;
        BJLPhotoPickerConfiguration *cfg = [[BJLPhotoPickerConfiguration alloc] init];
        cfg.selectionLimit = 1;
        cfg.filter = self.configurationStorage.filter;
        self.picker = [[BJLPhotoPicker alloc] initWithConfiguration:cfg];
        self.picker.delegate = self;
    }
    return self;
}

- (void)cleanData {
    [self.dataSource removeAllObjects];
    [self.collectionView reloadData];
}

- (void)hidePhotosBrowserView {
    [_browserView removeFromSuperview];
}

- (NSArray *)photoData {
    return self.dataSource.copy;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.collectionView];
    [self.collectionView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.width.height.equalTo(self.view);
        make.top.left.equalTo(self.view);
    }];
}

- (void)setReadonlyMode:(BOOL)readonlyMode {
    _readonlyMode = readonlyMode;
    [self.collectionView reloadData];
}

- (void)setImageURLData:(NSArray<NSString *> *)imageURLData {
    _imageURLData = [imageURLData copy];

    [self.dataSource removeAllObjects];
    for (NSString *url in _imageURLData) {
        BJLPhotoMode *m = [BJLPhotoMode modeWithURLString:url];
        [self.dataSource addObject:m];
    }
    [self.collectionView reloadData];
    [self updatePhotoBrowserData];
}

#pragma mark - helper
- (BJLPhotoListConfiguration *)defaultConfiguration {
    BJLPhotoListConfiguration *configuration = [BJLPhotoListConfiguration new];
    configuration.selectionLimit = 5;
    configuration.filter = BJLPhotoPickerFilterImages;
    return configuration;
}

- (void)addNewImage:(BJLPhotoListAddNewCell *)cell {
    [self chooseImagePickerSourceTypeFromButton:cell];
}

- (void)deleteImageAtIndex:(NSInteger)index {
    [self.dataSource bjl_removeObjectAtIndex:index];
    [self.collectionView reloadData];

    [self updatePhotoBrowserData];
}

- (void)addImage:(ICLImageFile *)image {
    if (image) {
        if (![self checkImageFielSize:image]) { return; }

        BJLPhotoMode *mode = [BJLPhotoMode modeWithICLImageFile:image];
        [self.dataSource addObject:mode];
        [self.collectionView reloadData];

        [self updatePhotoBrowserData];

        if (self.photoDataDidChangeCallback) {
            self.photoDataDidChangeCallback(self, self.photoData);
        }
    }
}

- (void)resetImages:(NSArray<ICLImageFile *> *)images {
    if (images.count != 0) {
        [self.dataSource removeAllObjects];
        for (ICLImageFile *file in images) {
            if ([self checkImageFielSize:file]) {
                BJLPhotoMode *mode = [BJLPhotoMode modeWithICLImageFile:file];
                [self.dataSource addObject:mode];
            }
        }
        [self.collectionView reloadData];

        [self updatePhotoBrowserData];

        if (self.photoDataDidChangeCallback) {
            self.photoDataDidChangeCallback(self, self.photoData);
        }
    }
}

- (BOOL)checkImageFielSize:(ICLImageFile *)image {
    BOOL valid = NO;
    if (self.configurationStorage.maxFileSizeForImages > 0) {
        NSError *err = nil;
        NSDictionary<NSFileAttributeKey, id> *attr = [NSFileManager.defaultManager attributesOfItemAtPath:image.fileURL.path error:&err];
        if (!err) {
            NSInteger fileSize = [[attr objectForKey:NSFileSize] integerValue];
            valid = fileSize <= self.configurationStorage.maxFileSizeForImages;
        }
    }

    if (!valid) {
        if (self.showErrorMessageCallback) {
            CGFloat max = self.configurationStorage.maxFileSizeForImages / (1024 * 1024.0);
            NSString *msg = [NSString stringWithFormat:BJLLocalizedString(@"文件需要小于%.2fMB"), max];
            self.showErrorMessageCallback(msg);
        }
    }

    return valid;
}

- (void)updatePhotoBrowserData {
    [self.browserView updatePhotos:self.dataSource];
}

- (void)chooseImagePickerSourceTypeFromButton:(BJLPhotoListAddNewCell *)button {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:nil
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [alert bjl_addActionWithTitle:BJLLocalizedString(@"拍照")
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  [self chooseImageWithSourceType:sourceType];
                              }];
    }

    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [alert bjl_addActionWithTitle:BJLLocalizedString(@"从相册中选取")
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
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
        [self.picker requestAuthorizationIfNeededAndPresentPickerControllerFrom:self.parentVC];
    }
}

- (void)chooseImageWithCamera {
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
    bjl_weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        bjl_strongify(self);
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
            if (self.showErrorMessageCallback) {
                self.showErrorMessageCallback(BJLLocalizedString(@"照片获取出错"));
            }
            else {
                NSLog(BJLLocalizedString(@"照片获取出错"));
            }
            return;
        }

        [self addImage:imageFile];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UIPopoverPresentationControllerDelegate>
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource.count < self.configurationStorage.selectionLimit) {
        return self.dataSource.count + (self.readonlyMode ? 0 : 1);
    }
    return self.configurationStorage.selectionLimit;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = indexPath.item < self.dataSource.count ? kCellIdentifier : kNewImageIdentifier;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    bjl_weakify(self);
    if (indexPath.item < self.dataSource.count) {
        [(BJLPhotoListCell *)cell setImageData:self.dataSource[indexPath.item]];
        [(BJLPhotoListCell *)cell setIndexPath:indexPath];
        [(BJLPhotoListCell *)cell setShowDeleteIcon:!self.readonlyMode];
        [(BJLPhotoListCell *)cell setDeleteEventCallBack:^(BJLPhotoListCell *_Nonnull cell) {
            bjl_strongify(self);
            [self deleteImageAtIndex:cell.indexPath.item];
            if (self.photoDataDidChangeCallback) {
                self.photoDataDidChangeCallback(self, self.photoData);
            }
        }];
        [(BJLPhotoListCell *)cell setTapEventCallBack:^(BJLPhotoListCell *_Nonnull cell) {
            bjl_strongify(self);
            [self showPhotoBrowserAtIndexPath:cell.indexPath];
        }];
    }
    else {
        [(BJLPhotoListAddNewCell *)cell setAddNewImageEventCallBack:^(BJLPhotoListAddNewCell *_Nonnull cell) {
            bjl_strongify(self);
            [self addNewImage:cell];
        }];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = self.view.bounds.size.height;
    return CGSizeMake(1.5 * h, h);
}

- (void)showPhotoBrowserAtIndexPath:(NSIndexPath *)indexPath {
    BJLPhotoMode *data = self.dataSource[indexPath.item];
    [self.browserView updateCurrentPhoto:data];
    if (self.photoBrowserParentView) {
        [self.photoBrowserParentView addSubview:self.browserView];
        [self.browserView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.photoBrowserParentView).priorityHigh();
        }];
    }
}

#pragma mark - photopicker
- (void)photoPicker:(BJLPhotoPicker *)BJLPhotoPicker didFinishPicking:(BJLPhotoPickerResult *)result {
    if (result == nil || result.empty) {
        [BJLPhotoPicker dismissPickerController];
    }
}

- (void)photoPicker:(BJLPhotoPicker *)BJLPhotoPicker didFinishLoadImageData:(NSArray<ICLImageFile *> *)data failureItems:(NSArray<NSError *> *)failureItems originResult:(BJLPhotoPickerResult *)result {
    [self addImage:data.firstObject];
    [BJLPhotoPicker dismissPickerController];
}

#pragma mark - Getter
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 6;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;

        [_collectionView registerClass:BJLPhotoListCell.class forCellWithReuseIdentifier:kCellIdentifier];
        [_collectionView registerClass:BJLPhotoListAddNewCell.class forCellWithReuseIdentifier:kNewImageIdentifier];
    }
    return _collectionView;
}

- (BJLPhotoBrowserView *)browserView {
    if (!_browserView) {
        _browserView = [[BJLPhotoBrowserView alloc] initWithPhotos:nil currentPhoto:nil];
        _browserView.hideCallback = ^(BJLPhotoBrowserView *view) {
            [view removeFromSuperview];
        };
    }
    return _browserView;
}
@end
