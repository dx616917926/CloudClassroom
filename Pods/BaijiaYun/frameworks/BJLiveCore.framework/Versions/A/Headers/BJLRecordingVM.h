//
//  BJLRecordingVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-10.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, BJLEncoderMirrorMode) {
    BJLEncoderMirrorModeHorizontal = 1 << 0,
    BJLEncoderMirrorModeVertical = 1 << 1,
};

/** ### 音视频采集 */
@interface BJLRecordingVM: BJLBaseVM

/** 音视频开关状态 */
@property (nonatomic, readonly) BOOL recordingAudio, recordingVideo;
/** 声音输入级别 */
@property (nonatomic, readonly) CGFloat inputVolumeLevel; // [0.0 - 1.0]
/** 采集视频宽高比 */
@property (nonatomic, readonly) CGFloat inputVideoAspectRatio;

/**
 学生: 是否禁止当前用户打开音频 - 个人实际状态
 #discussion 用于判断当前用户是否能打开音频
 #discussion 参考 `forbidAllRecordingAudio`
 */
@property (nonatomic, readonly) BOOL forbidRecordingAudio;

/**
 是否禁止所有人打开音频 - 全局开关状态
 #discussion 用于判断直播间内开关状态
 #discussion 如果学生正在采集音频，收到此事件时会被自动关闭
 #discussion 课程类型为小班课、新版小班课、双师课时可用，参考 `room.roomInfo.roomType`、`BJLRoomType`
 #discussion 1. 当老师禁止所有人打开音频时，`forbidAllRecordingAudio` 和 `forbidRecordingAudio` 同时被设置为 YES，
 #discussion 2. 当老师取消禁止所有人打开音频时，`forbidAllRecordingAudio` 和 `forbidRecordingAudio` 同时被设置为 NO，
 #discussion 3. 当老师邀请/强制当前用户发言时，`forbidAllRecordingAudio` 被设置成 NO，`forbidRecordingAudio` 依然是 YES，
 #discussion 4. 当老师取消邀请/强制结束当前用户发言时，`forbidAllRecordingAudio` 会被设置为与 `forbidRecordingAudio` 一样的取值
 */
@property (nonatomic, readonly) BOOL forbidAllRecordingAudio;

/**
 老师: 设置全体禁音状态
 #param forbidAll YES：全体禁音，NO：取消禁音
 #discussion 设置成功后修改 `forbidAllRecordingAudio`、`forbidRecordingAudio`
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限
 */
- (nullable BJLError *)sendForbidAllRecordingAudio:(BOOL)forbidAll;

/**
老师/助教: 设置所有开启视频的用户的推流镜像模式，只对 WebRTC 课程有效
#param mode BJLEncoderMirrorMode 翻转的类型
#param user 对象用户，只能是老师或者助教
#return BJLError:
BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限
*/
- (nullable BJLError *)updateVideoEncoderMirrorModeForAllPlayingUser:(BJLEncoderMirrorMode)mode;

/**
老师/助教: 设置指定用户的推流镜像模式，只对 WebRTC 课程有效
#param mode BJLEncoderMirrorMode 翻转的类型
#param user 对象用户，只能是老师或者助教
#return BJLError:
BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限
*/
- (nullable BJLError *)updateVideoEncoderMirrorMode:(BJLEncoderMirrorMode)mode forUser:(BJLUser *)user;

/**
老师/助教: 获取指定用户的推流镜像模式，只对 WebRTC 课程有效
#return BJLEncoderMirrorMode 翻转的类型
#param user 对象用户，只能是老师或者助教
#param BJLError:
BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限
*/
- (BJLEncoderMirrorMode)videoEncoderMirrorModeForUser:(BJLUser *)user error:(BJLError *_Nullable *_Nullable)error;

/**
  视频推流时是否打开了镜像模式
  #discussion 用于判断当前用户是否开启了推流镜像视频
 */
@property (nonatomic, readonly) BJLEncoderMirrorMode currentUserVideoEncoderMirrorMode;

/**
 老师/助教: 上台的用户中，是否存在水平镜像的用户
 */
@property (nonatomic, readonly) BOOL hasHorizontalMirrorUser;

/**
 老师/助教: 上台的用户中，是否存在未水平镜像的用户
 */
@property (nonatomic, readonly) BOOL hasHorizontalUnmirrorUser;

/**
 老师/助教: 上台的用户中，是否存在垂直镜像的用户
 */
@property (nonatomic, readonly) BOOL hasVerticalMirrorUser;

/**
 老师/助教: 上台的用户中，是否存在未垂直镜像的用户
 */
@property (nonatomic, readonly) BOOL hasVerticalUnmirrorUser;

/**
 检测麦克风和摄像头权限回调
 #disussion 在需要开启音视频时，检测对应权限之后的回调，
 #disussion microphone -> YES 需要麦克风权限，camera -> YES 需要摄像头权限，
 #disussion granted -> YES 已授权，可以不做处理，granted -> NO 未授权，抛出 alert，需要展示
 */
@property (nonatomic, nullable) void (^checkMicrophoneAndCameraAccessCallback)(BOOL microphone, BOOL camera, BOOL granted, UIAlertController *_Nullable alert);
/** 检测权限的弹窗操作完成后的回调，但是未决定状态的弹窗不会通过此处回调 */
@property (nonatomic, nullable) void (^checkMicrophoneAndCameraAccessActionCompletion)(void);

/**
 开关音视频
 #param recordingAudio YES：打开音频采集，NO：关闭音频采集
 #param recordingVideo YES：打开视频采集，NO：关闭视频采集
 #discussion 上层自行检查麦克风、摄像头开关权限
 #discussion 上层可通过 `BJLSpeakingRequestVM` 实现学生发言需要举手的逻辑
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求非试听学生权限
 BJLErrorCode_invalidCalling    错误调用，以下情况下开启音视频、在音频直播间开启摄像头均会返回此错误
 登录用户分组 ID 不为 0，参考 `room.loginUser.groupID`
 非上课状态，参考 `room.roomVM.liveStarted`
 直播间禁止打开音频，参考 `self.forbidRecordingAudio`
 音频禁止打开视频，参考 `featureConfig.mediaLimit`
 */
- (nullable BJLError *)setRecordingAudio:(BOOL)recordingAudio
                          recordingVideo:(BOOL)recordingVideo;

/**
 开启音视频被服务端拒绝
 #discussion 可能因为上麦路数达到上限 */
- (BJLObservable)recordingDidDeny;

/** 是否开启 PCM 音频数据回调，默认为 NO，需要在进入直播间前设置，不支持进入直播间后修改 */
@property (nonatomic) BOOL enablePCMData;
/**
 采集到的音频数据，仅支持 AVSDK 的班型
 #param length 音频数据长度
 #param data PCM 音频数据
 */
- (BJLObservable)recordingAudioPCMDataDidUpdate:(uint8_t[_Nullable])data length:(int)length;

/**
 音视频被远程开关通知
 #param recordingAudio YES：打开音频采集，NO：关闭音频采集
 #param recordingVideo YES：打开视频采集，NO：关闭视频采集
 #param recordingAudioChanged 音频采集状态是否发生变化
 #param recordingVideoChanged 视频采集状态是否发生变化
 #discussion 对于学生，音、视频有一个打开就开启发言、全部关闭就结束发言
 #discussion 参考 `BJLSpeakingRequestVM` 的 `speakingDidRemoteControl:`
 */
- (BJLObservable)recordingDidRemoteChangedRecordingAudio:(BOOL)recordingAudio
                                          recordingVideo:(BOOL)recordingVideo
                                   recordingAudioChanged:(BOOL)recordingAudioChanged
                                   recordingVideoChanged:(BOOL)recordingVideoChanged;

/**
 开关全体学生麦克风
 #param mute YES：关闭，NO：打开
 #return BJLError
 */
- (nullable BJLError *)updateAllRecordingAudioMute:(BOOL)mute;

/**
 收到一键开关麦克风
 #param mute YES --> 关闭麦克风，NO --> 开启麦克风
 */
- (BJLObservable)didUpadateAllRecordingAudioMute:(BOOL)mute;

/**
 老师: 远程开关学生音、视频
 #param user 对象用户，不能是老师
 #param audioOn YES：打开音频采集，NO：关闭音频采集
 #param videoOn YES：打开视频采集，NO：关闭视频采集
 #discussion 打开音频、视频会导致对方发言状态开启
 #discussion 同时关闭音频、视频会导致对方发言状态终止
 @see `speakingRequestVM.speakingEnabled`
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)remoteChangeRecordingWithUser:(BJLUser *)user
                                             audioOn:(BOOL)audioOn
                                             videoOn:(BOOL)videoOn;
/**
 老师: 远程开启学生音、视频被自动拒绝，因为上麦路数达到上限
 #param user    开启失败的学生
 */
- (BJLObservable)remoteChangeRecordingDidDenyForUser:(BJLUser *)user;

#pragma mark - 音视频采集权限

/** 被授权辅助摄像头的用户 */
@property (nonatomic, readonly, nullable) NSArray<NSString *> *authorizedExtraCameraUserNumbers;

/**
 授权辅助摄像头
 #param authorized 是否授权
 #param userNumber 用户 number
 #return BJLErrorCode_invalidUserRole 错误角色，仅老师或助教能授权给支持辅助摄像头的学生，目前仅支持一对一专业小班课 PC 端学生
 */
- (nullable BJLError *)updateStudentExtraCameraAuthorized:(BOOL)authorized userNumber:(NSString *)userNumber;

/** 被授权屏幕共享的用户 */
@property (nonatomic, readonly, nullable) NSArray<NSString *> *authorizedScreenShareUserNumbers;

/**
 授权屏幕共享
 #param authorized 是否授权
 #param userNumber 用户 number
 #return BJLErrorCode_invalidUserRole 错误角色，仅老师或助教能授权给支持屏幕共享的学生，目前仅支持一对一专业小班课 PC 端学生
 */
- (nullable BJLError *)updateStudentScreenShareAuthorized:(BOOL)authorized userNumber:(NSString *)userNumber;

#pragma mark - 音视频采集设置

/** 用户是否在录制屏幕，iOS11以上生效，iOS11以下一直是NO */
@property (nonatomic, readonly) BOOL screenCaptured;

/**
 以下设置
 #discussion - 开始采集之前、之后均可调用
 #discussion - 开关音视频后不被重置
 #discussion - 个别设置可能会导致视频流重新发布
 */

/** 当前使用的摄像头，默认使用前置摄像头 */
@property (nonatomic, readonly) BOOL usingRearCamera; // NO: Front, YES Rear(iSight)

/**
 是否使用后置摄像头
 #param usingRearCamera 使用后置摄像头
 #return BJLError:
 BJLErrorCode_invalidCalling  错误调用
 */
- (nullable BJLError *)updateUsingRearCamera:(BOOL)usingRearCamera;

/** 视频采集模式，默认采集横屏画面 */
@property (nonatomic) BJLVideoRecordingOrientation videoRecordingOrientation;

/** 采集画面显示模式，默认 BJLVideoContentMode_aspectFit */
@property (nonatomic) BJLVideoContentMode videoContentMode;

/** 视频采集清晰度，默认标清 */
@property (nonatomic, readonly) BJLVideoDefinition videoDefinition;

/**
 改变视频清晰度
 #discussion AVSDK 的类型，参考 `BJLFeatureConfig` 的 `playerType`，不支持 1080 的清晰度，会变为 720 清晰度
 #param videoDefinition 清晰度
 #return BJLError:
 BJLErrorCode_invalidCalling  错误调用
 */
- (nullable BJLError *)updateVideoDefinition:(BJLVideoDefinition)videoDefinition;

/** 美颜，默认关闭 */
@property (nonatomic, readonly) BJLVideoBeautifyLevel videoBeautifyLevel;

/**
 改变美颜等级
 #param videoBeautifyLevel videoBeautifyLevel
 #return BJLError:
 BJLErrorCode_invalidCalling  错误调用
 */
- (nullable BJLError *)updateVideoBeautifyLevel:(BJLVideoBeautifyLevel)videoBeautifyLevel;

#pragma mark - 外接移动端摄像头

/** 当前用户是否存在外接移动端摄像头 */
@property (nonatomic, readonly) BOOL hasAsCameraUser;

/** 获取外接移动端设备作为摄像头的参数链接，生成链接后将在外接设备进直播间，然后退出之后失效 */
- (nullable NSURLSessionDataTask *)requestAsCameraDataWithCompletion:(nullable void (^)(NSString *_Nullable urlString, UIImage *_Nullable image, BJLError *_Nullable error))completion;

/** 停止外接摄像头的使用，停止完毕后回调 completion，否则不回调 */
- (nullable BJLError *)stopAsCameraUserCompletion:(void (^__nullable)(void))completion;

#pragma mark - webRTC 课程 API

/**
 开启摄像头预览
 #return BJLError:
 BJLErrorCode_invalidCalling  错误调用
 */
- (nullable BJLError *)startCameraPreview;

/**
 关闭摄像头预览
 #return BJError:
 BJLErrorCode_invalidCalling  错误调用
 */
- (nullable BJLError *)stopCameraPreview;

/** 推流重试中 */
- (BJLObservable)republishing;

/** 推流失败 */
- (BJLObservable)publishFailed;

#pragma mark - 美颜

/// 设置磨皮级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。 仅BRTC底层有效
- (nullable BJLError *)updateBeautyLevel:(float)level;
@property (nonatomic, readonly) float beautyLevel;

/// 设置美白级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。 仅BRTC底层有效
- (nullable BJLError *)updateWhitenessLevel:(float)level;
@property (nonatomic, readonly) float whitenessLevel;

#pragma mark - 音频质量

/** 当前采集的音频质量 */
@property (nonatomic, readonly) BJLAudioQuality audioQuality;

/**
 设置采集音频质量
 #param audioQuality 音频质量，参考 BJLAudioQuality，默认为 BJLAudioQualityDefault
 #return error 仅 BJLPlayerType_BRTC_TRTC 和 BJLPlayerType_BRTC 支持，参考 BJLFeatureConfig 的 playerType
 #discussion 尽量在开启音视频之前设置，在开启了音视频之后设置将会重新推流
 */
- (nullable BJLError *)updateAudioQuality:(BJLAudioQuality)audioQuality;

@end

NS_ASSUME_NONNULL_END
