/***********************
auth: cszdlt@qq.com
date: 2020-03-30 15:11:43
name: VloudCapture.h
************************/

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "RTCMacros.h"
#import "RTCVideoCapturer.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
/**
 * 该 protocol 用于向 SDK 传递视频帧
 */
@protocol VloudVideoCapturerDelegate <NSObject>
@property(nonatomic, weak, readonly) id <RTC_OBJC_TYPE(RTCVideoCapturerDelegate)> delegate;

- (void)captureVideoFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame;
@end

RTC_OBJC_EXPORT
/**
 * 可继承该 protocol 并实现相应的接口，创建自定义 Capture
 */
@protocol VloudVideoCapture <NSObject>

/**
 * 设置获取视频帧的委托，需要使用该委托向 SDK 传递视频帧。该方法会由 SDK 内部调用
 * @param delegate 委托
 */
- (void)setVideoCapturerDelegate:(id <VloudVideoCapturerDelegate> __nullable)delegate;

/**
 * 设置获取视频帧的委托，需要使用该委托向 SDK 传递视频帧。该方法会由 SDK 内部调用
 * @param delegate 委托
 * @param personalControlDirection 自定义消息处理视频方向
 */
- (void)setVideoCapturerDelegate:(id<VloudVideoCapturerDelegate> __nullable)delegate personalControlDirection:(BOOL)personalControlDirection;

/**
 * 开始申请视频帧。该方法会由 SDK 内部调用
 * @param width 期望的视频帧宽度
 * @param height 期望的视频帧高度
 * @param fps 期望的视频帧帧率
 */
- (void)startCaptureWithWidth:(NSInteger)width
                       height:(NSInteger)height
                          fps:(NSInteger)fps;

/**
 * 停止申请视频帧
 */
- (void)stopCapture;

@end

NS_ASSUME_NONNULL_END
