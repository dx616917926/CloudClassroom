//
//  BJLDocumentFileManagerViewController+private.h
//  BJLiveUI
//
//  Created by 凡义 on 2020/8/26.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLDocumentFileManagerViewController.h"
#import "BJLDocumentFileManagerViewController+homework.h"
#import "BJLDocumentFileManagerViewController+transcode.h"
#import "BJLDocumentFileManagerViewController+doc.h"
#import "BJLDocumentFileManagerViewController+cloud.h"
#import "BJLDocumentFileView.h"
#import "BJLDocumentFile.h"
#import "BJLAppearance.h"
#import "BJLiveUIBase.h"

NS_ASSUME_NONNULL_BEGIN

static NSUInteger const kCloudPageSize = 20;

@interface BJLDocumentFileManagerViewController () <UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, BJLDownloadManagerDelegate, BJLDocumentFileCloudDirectoryDelegate, UITextViewDelegate, BJLPhotoPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) BJLRoom *room;
// 文档管理视图
@property (nonatomic) BJLDocumentFileView *documentFileView;
// 区分动态和静态PPT调用按钮
@property (nonatomic) BOOL isSelectAnimatedDocumentFile;
// 轮询转码进度 timer
@property (nonatomic, nullable) NSTimer *pollTimer;

@property (nonatomic) NSMutableArray<BJLDocumentFile *> *mutableAllDocumentFileList, *mutableTranscodeDocumentFileList;
@property (nonatomic) NSMutableArray<BJLDocumentFile *> *mutableDocumentSearchResultFileList;
@property (nonatomic, nullable) NSURLSessionUploadTask *uploadDocumentRequest;

// 媒体文件
@property (nonatomic) NSMutableArray<BJLDocumentFile *> *mutableMediaFileList;

// 云盘
@property (nonatomic) NSMutableArray<BJLDocumentFile *> *mutableCloudFileList, *mutableTranscodeCloudFileList, *mutableCloudSearchResultFileList;
@property (nonatomic, nullable) NSURLSessionDataTask *requestCloudListTask, *searchCloudTask;
@property (nonatomic, nullable) NSURLSessionUploadTask *uploadCloudFileRequest;
@property (nonatomic, nullable) NSMutableArray<NSString *> *syncCloudFidArray; // 同步中的云盘文件fid
@property (nonatomic, nullable) NSMutableArray<BJLDocumentFile *> *currentDirectoryStack; // 云盘面包文件目录结构
@property (nonatomic, nullable) BJLProgressHUD *loadingCloudHud;
@property (nonatomic, assign) NSUInteger currrentPage, currentSearchPage;

// homework
@property (nonatomic, nullable) UIDocumentInteractionController *documentController;
@property (nonatomic) NSMutableArray<BJLDocumentFile *> *mutableHomeworkFileList, *mutableTranscodeHomeworkFileList, *mutableHomeworkSearchResultFileList;
@property (nonatomic, nullable) NSURLSessionUploadTask *uploadHomeworkRequest;
@property (nonatomic, nullable) BJLHomework *homeworkCursor;
@property (nonatomic) BOOL hasmoreHomework;
@property (nonatomic) BOOL shouldShowHomeworkSupportView;
@property (nonatomic, nullable) NSMutableArray<NSString *> *syncHomeworkFidArray; // 同步中的作业文件fid

// 文档/作业成功添加列表
@property (nonatomic) NSMutableArray<NSString *> *finishDocumentFileIDList;

// 直播间内文档上传视图
@property (nonatomic, readwrite) UIView *addDocumentContainerView, *chooseDocumentLayer;
@property (nonatomic, readwrite) UIButton *addAnimatedDocumentFileEmptyButton;
@property (nonatomic, readwrite) UIButton *addNormalDocumentFileEmptyButton;

// keyboard input
@property (nonatomic) UIView *overlayView;

#pragma mark - download

@property (nonatomic) BJLDownloadManager *manager;

@property (nonatomic, nullable) NSTimer *progressTimer;

@property (nonatomic, strong) BJLPhotoPicker *photoPicker;

@property (nonatomic) BOOL interruptedRecordingVideo;

#pragma mark -

- (BJLDocumentFileLayoutType)documentFileLayoutType;

- (BOOL)shouldShowSearchResult;

- (void)reloadTableViewWithLayoutType:(BJLDocumentFileLayoutType)layoutType;

- (nullable BJLDocumentFile *)documentFileWithIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
