//
//  BLiveDelegate.h
//  BLive
//
//  Created by xijia dai on 2022/3/23.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <BRTC/BRTC.h>
#import <Foundation/Foundation.h>

#import "BLiveDef.h"

@class BLive;

NS_ASSUME_NONNULL_BEGIN

/**
 ### 直播场景回调代理
 回调直播场景状态等变化
 */
@protocol BLiveDelegate <NSObject>

@optional

/**
 进入直播场景回调
 @param error 成功进入时字段为 nil
 @param duration 进入场景用时
 */
- (void)onEnterRoom:(nullable NSError *)error duration:(NSTimeInterval)duration;

/**
 离开直播场景回调
 @param error 离开时的原因，主动离开时 error 为 nil
 @param duration 在场景中的停留用时
 */
- (void)onExitRoom:(nullable NSError *)error duration:(NSTimeInterval)duration;

/**
 切换直播场景的用户角色
 @param role 直播场景的角色为 BLiveRoleType_anchor 时 BRTCDelegate 可用
 */
- (void)onSwitchRole:(BLiveRoleType)role;

/**
 用户加入直播场景
 */
- (void)onRemoteLiveUserEnterRoom:(NSString *)userID role:(BLiveRoleType)role;

/**
 用户离开直播场景
 */
- (void)onRemoteLiveUserLeaveRoom:(NSString *)userID role:(BLiveRoleType)role;

/**
 收到合流被添加
 仅在直播场景的角色为 BLiveRoleType_audience 时回调
 */
- (void)onMixStreamAdded:(NSString *)mixStreamID mixStreamInfo:(nullable NSArray<BLiveMixStreamDefinitionInfo *> *)mixStreamInfo;

/**
 收到合流被移除
 主播主动移除以及直播场景角色从 BLiveRoleType_audience 切换成 BLiveRoleType_anchor 时回调
 仅在直播场景的角色为 BLiveRoleType_audience 时回调
 */
- (void)onMixStreamRemoved:(NSString *)mixStreamID mixStreamInfo:(nullable NSArray<BLiveMixStreamDefinitionInfo *> *)mixStreamInfo;

/**
 收到合流更新
 合流更新时如果已经调用了播放视频，内部会更新视图的内容
 */
- (void)onMixStreamUpdate:(NSString *)mixStreamID mixStreamInfo:(nullable NSArray<BLiveMixStreamDefinitionInfo *> *)mixStreamInfo;

/**
 收到当前用户发起的合流任务开始，仅用于发起者管理自己发起的合流状况
 */
- (void)onStartMixStreamTranscode:(NSString *)mixStreamID;

/**
 收到当前用户停止合流任务，仅用于发起者管理自己发起的合流状况
 */
- (void)onStopMixStreamTranscode:(NSString *)mixStreamID;

#if DEBUG
- (void)onLog:(NSString *)log;
#endif

#pragma mark - 主播回调

/////////////////////////////////////////////////////////////////////////////////
//
//                      错误事件和警告事件
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 错误回调：SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示。
 *
 * @param errCode 错误码
 * @param errMsg  错误信息
 */
- (void)onError:(int)errCode errMsg:(nullable NSString *)errMsg extInfo:(nullable NSDictionary *)extInfo;


/////////////////////////////////////////////////////////////////////////////////
//
//                      成员事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 有用户加入当前房间
 * @note 注意 onRemoteUserEnterRoom 和 onRemoteUserLeaveRoom 只适用于维护当前房间里的“成员列表”，如果需要显示远程画面，建议使用监听 onUserVideoAvailable() 事件回调。
 *
 * @param userId 用户标识
 */
- (void)onRemoteUserEnterRoom:(NSString *)userId;

/**
 * 远端用户离开房间的回调
 *
 * @param userId 用户标识
 * @param reason 离开原因，0 表示用户主动退出房间，1 表示用户超时退出，2 表示被踢出房间。
 */
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason;

/**
 *  远端用户是否存在可播放的主路画面（一般用于摄像头）
 *
 * 当您收到 onUserVideoAvailable(userid, YES) 通知时，表示该路画面已经有可用的视频数据帧到达。
 * 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。
 * 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
 *
 * 当您收到 onUserVideoAvailable(userid, NO) 通知时，表示该路远程画面已被关闭，
 * 可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
 *
 * @param userId 用户标识
 * @param available 画面是否开启
 */
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available;

/**
 * 远端用户是否存在可播放的音频数据
 *
 * @param userId 用户标识
 * @param available 声音是否开启
 */
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available;

/**
 * 开始渲染本地或远程用户的首帧画面
 *
 * 如果 userId == nil，代表开始渲染本地采集的摄像头画面，需要您先调用 startLocalPreview 触发。
 * 如果 userId != nil，代表开始渲染远程用户的首帧画面，需要您先调用 startRemoteView 触发。
 *
 * @note 只有当您调用 startLocalPreivew()、startRemoteView() 或 startRemoteSubStreamView() 之后，才会触发该回调。
 *
 * @param userId 本地或远程用户 ID，如果 userId == nil 代表本地，userId != nil 代表远程。
 * @param streamType 视频流类型：摄像头或屏幕分享。
 * @param width  画面宽度
 * @param height 画面高度
 */
- (void)onFirstVideoFrame:(NSString *)userId streamType:(BRTCVideoStreamType)streamType width:(int)width height:(int)height;

/**
 * 开始播放远程用户的首帧音频（本地声音暂不通知）
 *
 * @param userId 远程用户 ID。
 */
- (void)onFirstAudioFrame:(NSString *)userId;

/**
 * 首帧本地视频数据已经被送出
 *
 * SDK 会在 enterRoom() 并 startLocalPreview() 成功后开始摄像头采集，并将采集到的画面进行编码。
 * 当 SDK 成功向云端送出第一帧视频数据后，会抛出这个回调事件。
 *
 * @param streamType 视频流类型，主画面、小画面或辅流画面（屏幕分享）
 */
- (void)onSendFirstLocalVideoFrame:(BRTCVideoStreamType)streamType;

/**
 * 首帧本地音频数据已经被送出
 *
 * SDK 会在 enterRoom() 并 startLocalAudio() 成功后开始麦克风采集，并将采集到的声音进行编码。
 * 当 SDK 成功向云端送出第一帧音频数据后，会抛出这个回调事件。
 */
- (void)onSendFirstLocalAudioFrame;


/////////////////////////////////////////////////////////////////////////////////
//
//                      统计和质量回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 技术指标统计回调
 *
 * 如果您是熟悉音视频领域相关术语，可以通过这个回调获取 SDK 的所有技术指标。
 *
 * @param statistics 统计数据，包括本地和远程的
 * @note 每2秒回调一次
 */
- (void)onStatistics:(BRTCStatistics *_Nonnull)statistics;


/////////////////////////////////////////////////////////////////////////////////
//
//                      硬件设备事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 用于提示音量大小的回调,包括每个 userId 的音量和远端总音量
 *
 * 您可以通过调用 BRTC 中的 enableAudioVolumeEvaluation 接口来开关这个回调或者设置它的触发间隔。
 * 需要注意的是，调用 enableAudioVolumeEvaluation 开启音量回调后，无论频道内是否有人说话，都会按设置的时间间隔调用这个回调;
 * 如果没有人说话，则 userVolumes 为空，totalVolume 为0。
 *
 * @param userVolumes 所有正在说话的房间成员的音量，取值范围0 - 100。
 * @param totalVolume 所有远端成员的总音量, 取值范围0 - 100。
 * @note userId 为 nil 时表示自己的音量，userVolumes 内仅包含正在说话（音量不为0）的用户音量信息。
 */
- (void)onUserVoiceVolume:(NSArray<BRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume;


/////////////////////////////////////////////////////////////////////////////////
//
//                      服务器事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  SDK 跟服务器的连接断开
 */
- (void)onConnectionLost;

/**
 *  SDK 尝试重新连接到服务器
 */
- (void)onTryToReconnect;

/**
 *  SDK 跟服务器的连接恢复
 */
- (void)onConnectionRecovery;


/////////////////////////////////////////////////////////////////////////////////
//
//                      自定义消息的接收回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  收到自定义消息回调
 *
 * 当房间中的某个用户使用 sendCustomCmdMsg 发送自定义消息时，房间中的其它用户可以通过 onRecvCustomCmdMsg 接口接收消息
 *
 * @param userId 用户标识
 * @param cmdID 命令 ID
 * @param seq   消息序号
 * @param message 消息数据
 */
- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message;

/**
 *  自定义消息丢失回调
 *
 * 实时音视频使用 UDP 通道，即使设置了可靠传输（reliable），也无法确保100@%不丢失，只是丢消息概率极低，能满足常规可靠性要求。
 * 在发送端设置了可靠运输（reliable）后，SDK 都会通过此回调通知过去时间段内（通常为5s）传输途中丢失的自定义消息数量统计信息。
 *
 * @note  只有在发送端设置了可靠传输（reliable），接收方才能收到消息的丢失回调
 * @param userId 用户标识
 * @param cmdID 命令 ID
 * @param errCode 错误码
 * @param missed 丢失的消息数量
 */
- (void)onMissCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID errCode:(NSInteger)errCode missed:(NSInteger)missed;

/**
 * 收到 SEI 消息的回调
 *
 * 当房间中的某个用户使用 sendSEIMsg 发送数据时，房间中的其它用户可以通过 onRecvSEIMsg 接口接收数据。
 *
 * @param userId   用户标识
 * @param message  数据
 */
- (void)onRecvSEIMsg:(NSString *)userId message:(NSData *)message;


/////////////////////////////////////////////////////////////////////////////////
//
//                      屏幕分享回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 当屏幕分享开始时，SDK 会通过此回调通知
 */
- (void)onScreenCaptureStarted;

/**
 * 当屏幕分享暂停时，SDK 会通过此回调通知
 *
 * @param reason 原因，0：用户主动暂停；1：屏幕窗口不可见暂停
 */
- (void)onScreenCapturePaused:(int)reason;

/**
 * 当屏幕分享恢复时，SDK 会通过此回调通知
 *
 * @param reason 恢复原因，0：用户主动恢复；1：屏幕窗口恢复可见从而恢复分享
 */
- (void)onScreenCaptureResumed:(int)reason;

/**
 * 当屏幕分享停止时，SDK 会通过此回调通知
 *
 * @param reason 停止原因，0：用户主动停止；1：屏幕窗口关闭导致停止  2: 其他异常原因
 */
- (void)onScreenCaptureStoped:(int)reason;

@end

NS_ASSUME_NONNULL_END
