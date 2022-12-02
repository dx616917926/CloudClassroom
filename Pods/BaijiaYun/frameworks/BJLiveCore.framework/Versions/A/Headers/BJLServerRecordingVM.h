//
//  BJLServerRecordingVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-06.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

/** 云端录制状态 */
typedef NS_ENUM(NSInteger, BJLServerRecordingState) {
    /** 未开启云端录制 */
    BJLServerRecordingState_ready,
    /** 开启过云端录制并且未转码或者正在云端录制中，可继续录制。如果现在在录制中，长期课可以停止录制，请求转码后开启新的录制 */
    BJLServerRecordingState_recording,
    /** 云端录制转码中，只能开启新的云端录制，不能继续录制。短期课不会有这个状态 */
    BJLServerRecordingState_transcoding,
    /** 云端录制不可用，是短期课已经录制过。长期课不会有这个状态 */
    BJLServerRecordingState_disable,
};

/** ### 云端录课 */
@interface BJLServerRecordingVM: BJLBaseVM

/** 云端录课状态，当前云端录课是否开启以这个属性为准 */
@property (nonatomic, readonly) BOOL serverRecording;

/** 云端录制详细状态，具体的云端录课状态 */
@property (nonatomic, readonly) BJLServerRecordingState state;

// 大班课下课后是否立马生成回放
@property (nonatomic, readonly) BOOL shouldGeneratePlaybackAfterClass;

/**
 开始/停止云端录课，配置了自动开启录制时将在允许自动录制的情况下自动开启录制
 #discussion 老师或者助教才能开启录课，参考 `BJLErrorCode_invalidUserRole`
 #discussion 上课状态才能开启录课，参考 `roomVM.liveStarted`
 #discussion 此方法需要发起网络请求、检查云端录课是否可用
 #discussion - 如果可以录课则开始、并设置 `serverRecording`
 #discussion - 否则发送失败通知 `requestServerRecordingDidFailed:`
 #param on YES：打开录制，NO：关闭录制
 #return BJLError:
 BJLErrorCode_invalidCalling    错误调用，如在非上课状态下调用此方法；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)requestServerRecording:(BOOL)on;

/**
 收到云端录制开启或关闭
 #param serverRecording 开启或关闭
 #param fromUser 发起云端录制的用户，仅 number、ID、groupID、role、clientType 可用
 */
- (BJLObservable)didReceiveServerRecording:(BOOL)serverRecording fromUser:(BJLUser *)fromUser;

/**
 请求当前云端录制转码状态
 #param completion 状态更新完成，可以根据状态来进行云端录制
 BJLErrorCode_invalidCalling  错误调用，如当前直播间录制类型不是云端录制；
 */
- (nullable BJLError *)requestServerRecordState:(void (^__nullable)(BOOL success))completion;

/**
 请求立刻转码回放
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)requestServerRecordingTranscode;

/** 转码回放请求被接受 */
- (BJLObservable)requestServerRecordingTranscodeAccept;

/**
 通知清晰度改变
 #param size 分辨率
 #return BJLError:
 BJLErrorCode_invalidCalling    错误调用，如在非上课状态下调用此方法；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)requestServerRecordingChangeResolution:(CGSize)size;

/** 通知清晰度改变被接收 */
- (BJLObservable)requestServerRecordingChangeResolutionAccept;

/**
 检查云端录课不可用的通知
 #discussion 包括网络请求失败
 #param message 错误信息
 */
- (BJLObservable)requestServerRecordingDidFailed:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
