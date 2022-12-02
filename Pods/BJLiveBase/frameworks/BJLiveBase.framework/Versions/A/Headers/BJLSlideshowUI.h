//
//  BJLSlideshowUI.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-19.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLDocument.h"
#import "BJLSlidePage.h"
#import "BJLError.h"

/** 画笔操作模式 */
typedef NS_ENUM(NSInteger, BJLBrushOperateMode) {
    /** 默认状态，无操作 */
    BJLBrushOperateMode_defaut,
    /** 选中，选中后可进行拖动、缩放 */
    BJLBrushOperateMode_select,
    /** 画 */
    BJLBrushOperateMode_draw,
    /** 擦除 */
    BJLBrushOperateMode_erase
};

/** 画笔类型 */
typedef NS_ENUM(NSInteger, BJLDrawingShapeType) {
    /** 涂鸦 */
    BJLDrawingShapeType_doodle,
    /** 线段 */
    BJLDrawingShapeType_segment,
    /** 箭头 */
    BJLDrawingShapeType_arrow,
    /** 双向箭头 */
    BJLDrawingShapeType_doubleSideArrow,
    /** 三角形 */
    BJLDrawingShapeType_triangle,
    /** 长方形 */
    BJLDrawingShapeType_rectangle,
    /** 圆、椭圆 */
    BJLDrawingShapeType_oval,
    /** 图片 */
    BJLDrawingShapeType_image,
    /** 文字 */
    BJLDrawingShapeType_text,
    /** 激光笔 */
    BJLDrawingShapeType_laserPoint
};

/** 画笔线条类型 */
typedef NS_ENUM(NSInteger, BJLDrawingLineType) {
    /** 实线 */
    BJLDrawingLineType_RealLine,
    /** 虚线 */
    BJLDrawingLineType_DottedLine
};

/** 画笔压缩类型 */
typedef NS_ENUM(NSInteger, BJLPointsCompressType) {
    BJLPointsCompressTypeNone = 0,
    BJLPointsCompressTypeCustomized = 1,
    BJLPointsCompressTypeCustomizedV2 = 2
};

/** 课件视图类型 */
typedef NS_ENUM(NSInteger, BJLPPTViewType) {
    /** 通过原生视图加载的静态课件 */
    BJLPPTViewType_Native,
    /** 通过 webview 视图加载的动态课件 */
    BJLPPTViewType_H5
};

NS_ASSUME_NONNULL_BEGIN

/** ### 课件视图控制器 API */
@protocol BJLSlideshowUI <NSObject>

#pragma mark - init

/// 通过课件数据初始化视图
/// #param document 课件，类型为 BJLDocument
/// #discussion 参数为空时，需要通过 `updateDocuments:` 更新课件数据
/// #discussion 参数不为空时，视图固定为该课件的视图，无法通过 `updateDocuments` 更新视图内容
- (instancetype)initWithDocument:(nullable BJLDocument *)document;

/// 使用文档初始化
/// @param document BJLDocument
/// @param isPlayback 是否为回放
- (instancetype)initWithDocument:(nullable BJLDocument *)document isPlayback:(BOOL)isPlayback;

/// 更新课件数据
/// #param allDocuments 视图需要处理的全部课件数据
- (void)updateDocuments:(nullable NSArray<BJLDocument *> *)allDocuments;

/// 是否是预览课件，默认 NO，作为预览课件时任何数据将不会同步，也没有任何翻页的限制
@property (nonatomic, readonly) BOOL isPreview;
- (void)updatePreview:(BOOL)isPreview;

#pragma mark - view type

/// 当前课件视图类型，不固定，根据 BJLDocument 的数据内容会发生改变
@property (nonatomic, readonly) BJLPPTViewType viewType;

/// 禁用课件的动效，默认为 NO，开启后 `viewType` 只会是 `BJLPPTViewType_H5`
@property (nonatomic) BOOL disablePPTAnimation;

#pragma mark - page control

/// 设置当前允许翻到的最大页码，在未主动翻页前作为当前页码，在 `disableOverMaxPage` 为 YES 时，否则仅作为当前的页码使用
/// #param slidePage BJLSlidePage
- (void)updateMaxSlidePage:(BJLSlidePage *)slidePage;

/// 是否需要同步控制直播间内页码，默认为 NO，设置为 YES 时，本地的翻页等操作都会同步给直播间内其他用户
@property (nonatomic, readonly) BOOL syncPageChange;
- (void)updateSyncPageChange:(BOOL)syncPageChange;

/// 是否禁止超过翻页超过最大页码，默认 YES
@property (nonatomic, readonly) BOOL disableOverMaxPage;
- (void)updateDisableOverMaxPage:(BOOL)disableOverMaxPage;

/// 当前课件是否支持滑动翻页，默认可滑动
/// #discussion 开启画笔或者动态课件可交互的情况下，仍然不能滑动翻页
@property (nonatomic, readonly) BOOL scrollEnabled;
- (void)updateScrollEnabled:(BOOL)scrollEnabled;

/// 当前页码
/// #discussion 不能滑动翻页时，参考 `scrollEnabled`，设置 pageIndex 无效
@property (nonatomic, readonly) NSInteger pageIndex;
- (nullable BJLError *)updatePageIndex:(NSInteger)pageIndex;

/// 能否向前翻页，或者存在前一步
@property (nonatomic, readonly) BOOL canStepForward;

/// 能否向后翻页，或者存在后一步
@property (nonatomic, readonly) BOOL canStepBackward;

/// 向前翻页
- (nullable BJLError *)pageStepForward;

/// 向后翻页
- (nullable BJLError *)pageStepBackward;

/// 课件视图处理多个 BJLDocument 数据时: 是否禁用跨越课件翻页
/// #discussion 默认允许跨课件，不同课件之间的 pageStepForward 和 pageStepBackward 是可用的
/// #discussion 如果禁用，在多个 pageStepForward 和 pageStepBackward 不可用，只能通过设置页码 index 进行翻页
@property (nonatomic) BOOL disableCrossDoc;

#pragma mark - customize

/// 自定义白板样式
@property (nonatomic) BJLWhiteboard *whiteboard;

/// 自定义页面控制按钮
@property (nonatomic) UIButton *pageControlButton;

#pragma mark - remark

/// 是否显示课件备注，默认显示
@property (nonatomic, readonly) BOOL showPPTRemarkInfo;
- (void)updateShowPPTRemarkInfo:(BOOL)show;

#pragma mark - draw

/// 画笔开关状态，默认为 NO，不可使用画笔
@property (nonatomic) BOOL drawingEnabled;

/// 课件当前页图像在视图中的布局信息
@property (nonatomic, readonly) CGRect imageFrameInPPTView;

/// 清除当前画布上所有画笔
- (void)clearDrawing;

#pragma mark - BJLPPTViewType_Native

/// 静态课件尺寸
/// #discussion 加载课件图片时对图片做等比缩放，长边小于/等于 `imageSize`，放大时加载 1.5 倍尺寸的图片
/// #discussion 单位为像素，默认初始加载 720、放大加载 1080，取值在 `BJLAliIMGMinSize` 到 `BJLAliIMGMaxSize` 之间 (1 ~ 4096)
/// #discussion 不建议进直播间成功后设置此参数，因为会导致已经加载过的图片缓存失效
@property (nonatomic) NSInteger imageSize;

/// 静态课件占位图
@property (nonatomic, nullable) UIImage *placeholderImage;

/// 静态课件白板图片
@property (nonatomic, nullable) UIImage *whiteboardBackgroundImage;

/// 回放设置本地图片路径
@property (nonatomic, nullable) NSArray *localPPTImagePaths;

/// 是否加载课件原图，默认不加载原图，设置后改变 imageSize 无效
@property (nonatomic, readonly) BOOL useOriginalImage;
- (void)updateUseOriginalImage:(BOOL)useOriginalImage;

/// 静态课件显示模式，每次动态和静态课件切换时都会重置成 BJLContentMode_scaleAspectFit 完整显示
@property (nonatomic, readonly) BJLContentMode contentMode;
- (void)updateContentMode:(BJLContentMode)contentMode;

/// 静态课件是否支持缩放
/// #param scaleEnabled 是否支持缩放
/// #discussion 默认支持缩放
@property (nonatomic, readonly) BOOL scaleEnabled;
- (void)updateScaleEnabled:(BOOL)scaleEnabled;

#pragma mark - BJLPPTViewType_H5

/// 动态课件加载成功
@property (nonatomic, readonly) BOOL webPPTLoadSuccess;

/// 动态课件加载失败时,是否要切静态课件
@property (nonatomic, copy, nullable) void (^shouldSwitchNativePPTBlock)(NSString *_Nullable documentID, void (^callback)(BOOL shouldSwitch));

/// 动态课件翻页指示图标
@property (nonatomic) UIImage *prevPageIndicatorImage, *nextPageIndicatorImage;

/// 动态课件手势触发的翻页是否能够向前翻页，默认能翻页
/// 不能滑动翻页时，参考 `scrollEnabled`，也不能手势翻页
@property (nonatomic) BOOL pageGestureCanStepForward;

/// 动态课件手势触发的翻页是否能够向后翻页，默认能翻页
/// 不能滑动翻页时，参考 `scrollEnabled`，也不能手势翻页
@property (nonatomic) BOOL pageGestureCanStepBackward;

/// 动态课件交互状态，默认不可交互
/// #discussion 不能滑动翻页时，参考 `scrollEnabled`，也无法交互
@property (nonatomic, readonly) BOOL webPPTInteractable;
- (void)updateWebPPTInteractable:(BOOL)interactable;

/// 是否允许在可以滑动翻页时翻页动态课件，默认可以，
/// #discussion 设置为 NO 时，只能操作课件中动效，不能滑动翻页
/// #discussion 即使设置为 NO，如果课件中的动效会触发翻页，也将会成功翻页
@property (nonatomic, readonly) BOOL enableWebPPTChangePage;
- (void)updateEnableWebPPTChangePage:(BOOL)enableWebPPTChangePage;

@end

NS_ASSUME_NONNULL_END
