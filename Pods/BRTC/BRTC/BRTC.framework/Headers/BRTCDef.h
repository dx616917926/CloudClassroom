/*
 * Module:   BRTC 关键类型定义
 *
 * Function: 分辨率、质量等级等枚举和常量值的定义
 *
 */

#import <Foundation/Foundation.h>
#import <BRTC/BRTCDeviceManager.h>
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
typedef UIView BRTCView;
#endif

#pragma mark -
/////////////////////////////////////////////////////////////////////////////////
//
//                    【视频相关枚举值定义】
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 视频分辨率
 *
 * 此处仅定义横屏分辨率，如需使用竖屏分辨率（例如360 × 640），需要同时指定 BRTCVideoResolutionMode 为 Portrait。
 */
typedef NS_ENUM(NSInteger, BRTCVideoResolution) {
    // 宽高比1:1
    BRTCVideoResolution_120_120     = 1,    ///< [C] 建议码率 VideoCall:80kbps   LIVE:120kbps
    BRTCVideoResolution_160_160     = 3,    ///< [C] 建议码率 VideoCall:100kbps  LIVE:150kbps
    BRTCVideoResolution_270_270     = 5,    ///< [C] 建议码率 VideoCall:200kbps  LIVE:120kbps
    BRTCVideoResolution_480_480     = 7,    ///< [C] 建议码率 VideoCall:350kbps  LIVE:120kbps

    // 宽高比4:3
    BRTCVideoResolution_160_120     = 50,   ///< [C] 建议码率 VideoCall:100kbps  LIVE:150kbps
    BRTCVideoResolution_240_180     = 52,   ///< [C] 建议码率 VideoCall:150kbps  LIVE:225kbps
    BRTCVideoResolution_280_210     = 54,   ///< [C] 建议码率 VideoCall:200kbps  LIVE:300kbps
    BRTCVideoResolution_320_240     = 56,   ///< [C] 建议码率 VideoCall:250kbps  LIVE:375kbps
    BRTCVideoResolution_400_300     = 58,   ///< [C] 建议码率 VideoCall:300kbps  LIVE:450kbps
    BRTCVideoResolution_480_360     = 60,   ///< [C] 建议码率 VideoCall:400kbps  LIVE:600kbps
    BRTCVideoResolution_640_480     = 62,   ///< [C] 建议码率 VideoCall:600kbps  LIVE:900kbps
    BRTCVideoResolution_960_720     = 64,   ///< [C] 建议码率 VideoCall:1000kbps LIVE:1500kbps

    // 宽高比16:9
    BRTCVideoResolution_160_90      = 100,  ///< [C] 建议码率 VideoCall:150kbps  LIVE:250kbps
    BRTCVideoResolution_256_144     = 102,  ///< [C] 建议码率 VideoCall:200kbps  LIVE:300kbps
    BRTCVideoResolution_320_180     = 104,  ///< [C] 建议码率 VideoCall:250kbps  LIVE:400kbps
    BRTCVideoResolution_480_270     = 106,  ///< [C] 建议码率 VideoCall:350kbps  LIVE:550kbps
    BRTCVideoResolution_640_360     = 108,  ///< [C] 建议码率 VideoCall:550kbps  LIVE:900kbps
    BRTCVideoResolution_960_540     = 110,  ///< [C] 建议码率 VideoCall:850kbps  LIVE:1300kbps
    BRTCVideoResolution_1280_720    = 112,  ///< [C] 建议码率 VideoCall:1200kbps LIVE:1800kbps
    BRTCVideoResolution_1920_1080   = 114,  ///< [S] 建议码率 VideoCall:2000kbps LIVE:3000kbps
};

/**
 * 视频宽高比模式
 *
 * - 横屏分辨率：BRTCVideoResolution_640_360 + BRTCVideoResolutionModeLandscape = 640 × 360
 * - 竖屏分辨率：BRTCVideoResolution_640_360 + BRTCVideoResolutionModePortrait  = 360 × 640
 */
typedef NS_ENUM(NSInteger, BRTCVideoResolutionMode) {
    BRTCVideoResolutionModeLandscape = 0,  ///< 横屏分辨率
    BRTCVideoResolutionModePortrait  = 1,  ///< 竖屏分辨率

};

/**
 * 视频流类型
 *
 * BRTC 内部有三种不同的音视频流，分别是：
 * - 主画面：最常用的一条线路，一般用来传输摄像头的视频数据。
 * - 小画面：跟主画面的内容相同，但是分辨率和码率更低。
 * - 辅流画面：一般用于屏幕分享，以及远程播片（例如老师放一段视频给学生）。
 *
 * @note - 如果主播的上行网络和性能比较好，则可以同时送出大小两路画面。
 * @note - SDK 不支持单独开启小画面，小画面必须依附于主画面而存在。
 */

typedef NS_ENUM(NSInteger, BRTCVideoStreamType) {
    BRTCVideoStreamTypeBig   = 0,     ///< 主画面视频流
    BRTCVideoStreamTypeSmall = 1,     ///< 小画面视频流
    BRTCVideoStreamTypeSub   = 2,     ///< 辅流（屏幕分享）
};

/**
 *  视频画面填充模式
 *
 * 如果画面的显示分辨率不等于画面的原始分辨率，就需要您设置画面的填充模式:
 * - BRTCVideoFillMode_Fill，图像铺满屏幕，超出显示视窗的视频部分将被裁剪，画面显示可能不完整。
 * - BRTCVideoFillMode_Fit，图像长边填满屏幕，短边区域会被填充黑色，画面的内容完整。
 */
typedef NS_ENUM(NSInteger, BRTCVideoFillMode) {
    BRTCVideoFillMode_Fill   = 0,  ///< 图像铺满屏幕，超出显示视窗的视频部分将被裁剪
    BRTCVideoFillMode_Fit    = 1,  ///< 图像长边填满屏幕，短边区域会被填充黑色
};

/**
 *  视频画面旋转方向
 *
 * BRTC SDK 提供了对本地和远程画面的旋转角度设置 API，下列的旋转角度都是指顺时针方向的。
 */
typedef NS_ENUM(NSInteger, BRTCVideoRotation) {
    BRTCVideoRotation_0      = 0,  ///< 不旋转
    BRTCVideoRotation_90     = 1,  ///< 顺时针旋转90度
    BRTCVideoRotation_180    = 2,  ///< 顺时针旋转180度
    BRTCVideoRotation_270    = 3,  ///< 顺时针旋转270度
};

/**
 * 本地视频预览镜像类型
 *
 * iOS 的本地画面提供下列设置模式
 */
typedef NS_ENUM(NSUInteger, BRTCVideoMirrorType) {
    BRTCVideoMirrorTypeAuto    = 0,       ///< 前置摄像头镜像，后置摄像头不镜像
    BRTCVideoMirrorTypeEnable  = 1,       ///< 前后置摄像头画面均镜像
    BRTCVideoMirrorTypeDisable = 2,       ///< 前后置摄像头画面均不镜像
};

/**
 *  视频截图来源
 */
typedef NS_ENUM(NSUInteger, BRTCSnapshotSourceType) {
    BRTCSnapshotSourceTypeStream  = 0,    ///< 从视频流上截取视频画面
    BRTCSnapshotSourceTypeView    = 1,    ///< 从渲染 View 上截取视频画面
};

/**
 *  视频渲染设置
 */
@interface BRTCRenderParams : NSObject

/// 【字段含义】画面朝向
/// 【推荐取值】支持90、180以及270旋转角度，默认值：BRTCVideoRotation_0
@property (nonatomic) BRTCVideoRotation rotation;

/// 【字段含义】画面填充模式
/// 【推荐取值】填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值：BRTCVideoFillMode_Fill
@property (nonatomic) BRTCVideoFillMode fillMode;

/// 【字段含义】画面镜像模式
/// 【推荐取值】默认值：BRTCVideoMirrorType_Auto
@property (nonatomic) BRTCVideoMirrorType mirrorType;

@end

#pragma mark -
/////////////////////////////////////////////////////////////////////////////////
//
//                    【网络相关枚举值定义】
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 流控模式
 *
 * BRTC SDK 内部需要时刻根据网络情况调整内部的编解码器和网络模块，以便能够对网络的变化做出反应。
 * 为了支持快速算法升级，SDK 内部设置了两种不同的流控模式：
 * - ModeServer：云端控制，默认模式，推荐选择。
 * - ModeClient：本地控制，用于 SDK 开发内部调试，客户请勿使用。
 *
 * @note 推荐您使用云端控制，这样每当我们升级 Qos 算法时，您无需升级 SDK 即可体验更好的效果。
 */
typedef NS_ENUM(NSInteger, BRTCQosControlMode) {
    BRTCQosControlModeClient,        ///< 客户端控制（用于 SDK 开发内部调试，客户请勿使用）
    BRTCQosControlModeServer,        ///< 云端控制 （默认）
};


/**
 *  画质偏好
 *
 * 指当 BRTC SDK 在遇到弱网络环境时，您期望“保清晰”或“保流畅”，两种模式均会优先保障声音数据的传输。
 *
 * - Smooth：弱网下优先流畅性，当用户网络较差的时候画面也会比较模糊。
 * - Clear：默认值，弱网下优先清晰度，当用户网络较差的时候会出现卡顿，但画面清晰度不会大幅缩水。
 */
typedef NS_ENUM(NSInteger, BRTCVideoQosPreference) {
    BRTCVideoQosPreferenceSmooth = 1,      ///< 弱网下保流畅
    BRTCVideoQosPreferenceClear  = 2,      ///< 弱网下保清晰，默认值
};

/**
 *  角色
 *
 * 仅适用于直播类场景，把用户区分成两种不同的身份：
 * - 主播：可以随时发布自己的音视频。
 * - 观众：只能观看其他用户的音视频流，要发布音视频流，需要先通过 {@link switchRole} 切换成主播，同一个房间中最多能容纳10万观众。
 */
typedef NS_ENUM(NSInteger, BRTCRoleType) {

    ///主播：可以随时发布自己的音视频流，但人数有限制，同一个房间中最多只允许 50 个主播同时发布自己的音视频流。
    BRTCRoleAnchor = 20,

    ///观众：只能观看其他用户的音视频流，要发布音视频流，需要先通过 {@link switchRole} 切换成主播，同一个房间中最多能容纳10万观众。
    BRTCRoleAudience = 21,

};

#pragma mark -
/////////////////////////////////////////////////////////////////////////////////
//
//                    【声音相关枚举值定义】
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  声音音质
 *
 * BRTC 提供了三种精心校调好的模式，用来满足各种垂直场景下对音质的差异化追求：
 * - 人声模式（Speech）：适用于以人声沟通为主的应用场景，该模式下音频传输的抗性较强，BRTC 会通过各种人声处理技术保障在弱网络环境下的流畅度最佳。
 * - 音乐模式（Music）：适用于对声乐要求很苛刻的场景，该模式下音频传输的数据量很大，BRTC 会通过各项技术确保音乐信号在各频段均能获得高保真的细节还原度。
 * - 默认模式（Default）：介于 Speech 和 Music 之间的档位，对音乐的还原度比人声模式要好，但传输数据量比音乐模式要低很多，对各种场景均有不错的适应性。
 */
typedef NS_ENUM(NSInteger, BRTCAudioQuality) {
    ///人声模式：采样率：16k；单声道；编码码率：16kbps；具备几个模式中最强的网络抗性，适合语音通话为主的场景，比如在线会议，语音通话等。
    BRTCAudioQualitySpeech  = 1,

    ///默认模式：采样率：48k；单声道；编码码率：50kbps；介于 Speech 和 Music 之间的档位，SDK 默认档位，推荐选择。
    BRTCAudioQualityDefault  = 2,

    ///音乐模式：采样率：48k；全频带立体声；编码码率：128kbps；适合需要高保真传输音乐的场景，比如在线K歌、音乐直播等。
    BRTCAudioQualityMusic  = 3,
};


#pragma mark -
/////////////////////////////////////////////////////////////////////////////////
//
//                    【更多枚举值定义】
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * Log 级别
 *
 * 不同的日志等级定义了不同的详实程度和日志数量，推荐一般情况下将日志等级设置为：BRTCLogLevelInfo。
 */
typedef NS_ENUM(NSUInteger, BRTCLogLevel) {
    BRTCLogLevelVerbose = 0, ///< 输出所有级别的 Log
    BRTCLogLevelDebug   = 1, ///< 输出 DEBUG，INFO，WARNING，ERROR 级别的 Log
    BRTCLogLevelInfo    = 2, ///< 输出 INFO，WARNING，ERROR 级别的 Log
    BRTCLogLevelWarn    = 3, ///< 只输出WARNING，ERROR  级别的 Log
    BRTCLogLevelError   = 4, ///< 只输出ERROR  级别的 Log
};


/////////////////////////////////////////////////////////////////////////////////
//
//                      【核心类型定义】
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@class BRTCUser;
@interface BRTCParams : NSObject

/// （必传）appkey
@property (nonnull, nonatomic, copy) NSString *appID;

/// （必传）用户签名sign
@property (nonnull, nonatomic, copy) NSString *sign;

/// （必传）房间号
@property (nonnull, nonatomic, copy) NSString *roomID;

/// （必传）用户数据
@property (nonnull, nonatomic, strong) BRTCUser *user;

///【字段含义】直播场景下的角色，仅适用于直播场景.
///【推荐取值】默认值：主播（{@link BRTCRoleAnchor}）
@property (nonatomic, assign) BRTCRoleType role;

@end


#pragma mark -
@interface BRTCVideoEncParam : NSObject

/// （非必传）视频码率，单位为 Kb。不设置默认值为，不设置默认为400
@property (nonatomic, assign) int bandWidth;

/// （非必传）视频的宽。不设置默认值是640
@property (nonatomic, assign) int width;

/// （非必传）视频的宽。不设置默认值是360
@property (nonatomic, assign) int height;

/// （非必传）视频的帧率。不设置默认值是15
@property (nonatomic, assign) int fps;

/// （非必传）视频宽高比模式。
@property (nonatomic, assign) BRTCVideoResolutionMode resolutionMode;

@end

#pragma mark -
@interface BRTCNetworkQosParam : NSObject

///【字段含义】弱网下是“保清晰”或“保流畅”
///【特别说明】
///   - 弱网下保流畅：在遭遇弱网环境时，画面会变得模糊，且出现较多马赛克，但可以保持流畅不卡顿
///   - 弱网下保清晰：在遭遇弱网环境时，画面会尽可能保持清晰，但可能会更容易出现卡顿
@property (nonatomic, assign) BRTCVideoQosPreference preference;

///【字段含义】视频分辨率（云端控制 - 客户端控制）
///【推荐取值】云端控制
///【特别说明】
///   - Server 模式（默认）：云端控制模式，若无特殊原因，请直接使用该模式
///   - Client 模式：客户端控制模式，用于 SDK 开发内部调试，客户请勿使用
@property (nonatomic, assign) BRTCQosControlMode controlMode;

@end


#pragma mark -
/**
 * 音量大小
 *
 * 表示语音音量的评估大小，通过这个数值，您可以在 UI 界面上用图标表征 userId 是否有在说话
 */
@interface BRTCVolumeInfo : NSObject <NSCopying>

/// 说话者的 userId, nil 为自己
@property (strong, nonatomic, nullable) NSString *userId;
/// 说话者的音量, 取值范围0 - 100
@property (assign, nonatomic) NSUInteger volume;

@end

#pragma mark -
NS_ASSUME_NONNULL_BEGIN
@interface BRTCUser : NSObject

@property (nonatomic, copy) NSString *userId;

@end
NS_ASSUME_NONNULL_END
