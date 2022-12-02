
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RTCMacros.h"
#import "RTCVideoRenderer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 视频画面限制方式
 */
typedef NS_ENUM(NSInteger, VloudVideoRendererFit) {
  /// 将视频画面限制在 View 内
  VloudVideoRendererFitContain,
  /// 使用此模式，视频画面可能无法完全展示在 View 上
  VloudVideoRendererFitCover
};

@class VloudVideoRenderer;

@protocol VloudVideoRendererDelegate <NSObject>

- (void)firstFrameRenderedOn:(VloudVideoRenderer *)renderer;

@end

RTC_OBJC_EXPORT
@interface VloudVideoRenderer : UIView <RTC_OBJC_TYPE(RTCVideoViewDelegate)>

///
@property (nonatomic, weak) id<VloudVideoRendererDelegate> delegate;

/// 是否启用镜像
@property (nonatomic) BOOL mirror;

/// 视频画面限制方式
@property (nonatomic) VloudVideoRendererFit fit;

@property (nonatomic, assign) BOOL isDebugView;

/**
 * 初始化渲染 View
 * @param frame 用于调用 UIView 的 initWithFrame
 * @param useMetal 是否使用 Metal 渲染视频画面
 * @return 当前 VloudVideoRenderer 的实例
 */
- (instancetype)initWithFrame:(CGRect)frame useMetal:(BOOL)useMetal;

/**
 * 初始化渲染 View
 * @param frame 用于调用 UIView 的 initWithFrame
 * @param useMetal 是否使用 Metal 渲染视频画面
 * @param isDebug 是否设置调试背景色(蓝色)
 * @return 当前 VloudVideoRenderer 的实例
 */
- (instancetype)initWithFrame:(CGRect)frame useMetal:(BOOL)useMetal isDebug:(BOOL)isDebug;

/**
 * 截图
 */
- (void)snapshotVideoCompletionBlock:(void (^)(UIImage *image))completionBlock;

@end

NS_ASSUME_NONNULL_END
