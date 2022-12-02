//
//  BJLPhotoListViewController.h
//  BJLiveUI
//
//  Created by Ney on 3/5/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJLPhotoPicker.h"
#import "BJL_iCloudLoading.h"

@interface BJLPhotoMode: NSObject
@property (nonatomic, copy) NSString *urlMode; //仅仅只有图片url
@property (nonatomic, strong) UIImage *urlDownloadedImage; //url下载后的图片对象
@property (nonatomic, strong) ICLImageFile *rawImageMode; //ICLImageFile，一般从相册获取

+ (instancetype)modeWithURLString:(NSString *)urlString;
+ (instancetype)modeWithICLImageFile:(ICLImageFile *)imageFile;
@end

@interface BJLPhotoListConfiguration: NSObject
@property (nonatomic, assign) NSInteger selectionLimit;
@property (nonatomic, assign) BJLPhotoPickerFilter filter;
@property (nonatomic, assign) NSUInteger maxFileSizeForImages; /// 最大文件体积 byte, 默认0 表示不限制
@end

@interface BJLPhotoListViewController: UIViewController
/**
 *  最终选择的大图数组
 */
@property (nonatomic, strong, readonly) NSArray<BJLPhotoMode *> *photoData;

/**
 *  用于present其他控制器时的入参
 */
@property (nonatomic, weak) UIViewController *parentVC;

/**
 *  用于展示大图模式的父view
 */
@property (nonatomic, weak) UIView *photoBrowserParentView;

/**
 *  是否是只读模式，否则可以增删图片
 */
@property (nonatomic, assign) BOOL readonlyMode;

/**
 *  可以设置这个url数组来展示网络图片。对应的photoData 就是下载好的图片数据
 */
@property (nonatomic, copy) NSArray<NSString *> *imageURLData;

/**
 显示错误信息
 */
@property (nonatomic) void (^showErrorMessageCallback)(NSString *message);

/**
 图片数据变更
 */
@property (nonatomic) void (^photoDataDidChangeCallback)(BJLPhotoListViewController *vc, NSArray<BJLPhotoMode *> *photoData);

- (instancetype)initWithConfiguration:(BJLPhotoListConfiguration *)configuration;
- (void)cleanData;
- (void)hidePhotosBrowserView;
@end
