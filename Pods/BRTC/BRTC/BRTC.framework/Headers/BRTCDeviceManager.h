/*
* Module: BRTCDeviceManager 设备管理类
*
* Function: 用于管理 iOS 的硬件设备
*
*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IPHONE
typedef NS_ENUM(NSUInteger, BRTCAudioRoute) {
    BRTCAudioRouteSpeakerphone  = 0, ///< 扬声器，位于手机底部，声音偏大，适合外放音乐。
    BRTCAudioRouteEarpiece      = 1, ///< 听筒，位于手机顶部，声音偏小，适合通话。
};

typedef NS_ENUM(NSUInteger, BRTCSystemVolumeType) {
    BRTCSystemVolumeTypeAuto   = 0,  /// “麦上通话，麦下媒体”，即主播上麦时使用通话音量，观众不上麦则使用媒体音量
    BRTCSystemVolumeTypeMedia  = 1,  /// 通话全程使用媒体音量，不常用，适合个别有特殊需求（如主播外接声卡）的应用场景。
    BRTCSystemVolumeTypeVOIP   = 2,  ///全程使用通话音量，适合多人会议场景。
};
#endif

@interface BRTCDeviceManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

#if TARGET_OS_IPHONE
/**
 * 切换摄像头
 */
- (NSInteger)switchCamera:(BOOL)frontCamera;

/**
 * 查询当前摄像头是否支持缩放
 */
- (BOOL)isCameraZoomSupported;

/**
 * 设置当前摄像头的缩放比例
 *
 * @param zoomRatio 取值范围1 - 5，取值为1表示最远视角（正常镜头），取值为5表示最近视角（放大镜头）。
 * 最大值推荐为5，若超过5，视频数据会变得模糊不清。默认值为1。
 */
- (NSInteger)setCameraZoomRatio:(CGFloat)zoomRatio;

/**
 * 查询是否支持开关闪光灯（手电筒模式）
 */
- (BOOL)isCameraTorchSupported;

/**
 * 开关闪光灯
 *
 * enabled YES：开启；NO：关闭，默认值：NO
 */
- (NSInteger)enableCameraTorch:(BOOL)enabled;

/**
 * 设置通话时使用的系统音量类型
 *
 * @note
 *   1. 需要在调用 startLocalAudio() 之前调用该接口。
 *   2. 如无特殊需求，不推荐您自行设置，您只需通过 enterRoom 设置好适合您的场景，SDK 内部会自动选择相匹配的音量类型。
 *
 * @param type 系统音量类型，参见 BRTCSystemVolumeType 说明。如无特殊需求，不推荐您自行设置。
 */
- (NSInteger)setSystemVolumeType:(BRTCSystemVolumeType)type;

/**
 * 设置音频路由
 *
 * 微信和手机 QQ 视频通话功能的免提模式就是基于音频路由实现的。
 * 一般手机都有两个扬声器，一个是位于顶部的听筒扬声器，声音偏小；一个是位于底部的立体声扬声器，声音偏大。
 * 设置音频路由的作用就是决定声音使用哪个扬声器播放。
 *
 * @param route 音频路由，即声音由哪里输出（扬声器、听筒），默认值：BRTCAudioRouteSpeakerphone
 */
- (NSInteger)setAudioRoute:(BRTCAudioRoute)route;
#endif

@end


NS_ASSUME_NONNULL_END
