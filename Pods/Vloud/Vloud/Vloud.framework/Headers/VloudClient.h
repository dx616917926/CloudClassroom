/***********************
auth: cszdlt@qq.com
date: 2020-03-26 17:16:50
name: VloudClient.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"
#import "VloudAudioEffecter.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VloudMethod) {
    VloudMethod_Unknow,
    VloudMethod_Publish,
    VloudMethod_UnPublish,
    VloudMethod_Subscribe,
    VloudMethod_UnSubscribe,
    VloudMethod_RefreshToken,
    VloudMethod_JoinRoom,
    VloudMethod_LeaveRoom,
    VloudMethod_UpdateUser,
    VloudMethod_ChangeMaster,
    VloudMethod_GetUserList,
    VloudMethod_GetMessageList,
    VloudMethod_ResetStream,
    VloudMethod_SyncRoom,
    VloudMethod_StartBridge,
    VloudMethod_StopBridge,
    VloudMethod_ReleaseRoom,
    VloudMethod_OnMediaError,
    VloudMethod_EvictUser,
    VloudMethod_UpdateRoom,
    VloudMethod_OnIceTimeOut,
    VloudMethod_AddTrackStreamToLocal,
    VloudMethod_InitEnv,
    VloudMethod_AddStream,
    VloudMethod_FindStreamByConnectionId
};



@class VloudConnectConfig;
@class VloudJoinConfig;
@class VloudStream;
@class VloudUser;
@class VloudMessageInfo;
@class VloudMessageListInfo;
@class VloudRoomInfo;
@class VloudRoomState;
@class VloudUserInfo;
@class VloudUserRejoinedInfo;
@class VloudUsersPageInfo;

RTC_OBJC_EXPORT
@protocol VloudClientDelegate <NSObject>
@optional

/**
 * SDK 会在与服务器的连接断开时抛出此事件回调
 *
 * 在抛出此事件之后，SDK 会努力跟服务器重新建立连接，重连过程中会抛出 vloudClientTryToReconnect，连接恢复后会抛出 vloudClientDidReConnect 。
 
 */
- (void)vloudClientConnectLost;

/**
 * SDK 正在尝试重新连接到云端
 * 连接恢复后会抛出 vloudClientDidReConnect 。
 */
- (void)vloudClientTryToReconnect;

/**
 * [VloudClient reConnectForToken:reconnectCount:] 重连成功的回调
 */
- (void)vloudClientDidReConnect;

/**
 * [VloudClient reConnectForToken:reconnectCount:] 重连失败的回调
 */
- (void)vloudClientDidReConnectFailed;

/**
 * 调用 [VloudClient joinRoom:token:] 后会连接服务器，该方法为连接成功的回调
 */
- (void)vloudClientDidConnect;

/**
 * 调用 [VloudClient joinRoom:token:] 后会连接服务器，该方法为连接失败的回调
 * @param code  错误代码
 * @param msg   错误信息
 */
- (void)vloudClientDidConnectFailed:(NSInteger)code message:(NSString *)msg;

/**
 * 调用 [VloudClient leaveRoom] 后会断开与服务器的连接，该方法为与服务端连接断开后的回调
 */
- (void)vloudClientDidDisConnect;

/**
 * client 连接状态发生变化是，会回调此函数
 * @param code 状态码
 * @param msg 状态信息
 */
- (void)didClientStateChanged:(NSInteger)code message:(NSString *)msg;

/**
 * VloudClient 的错误回调
 * @param code 错误代码
 * @param msg 错误信息
 * @param method 方法名
 * @param streamId 流id
 */
- (void)failedCode:(NSInteger)code message:(NSString *)msg method:(VloudMethod)method streamId:(NSString *)streamId;

/**
 * [VloudClient joinRoom:token:] 完成与服务器的连接并且加入了房间之后，会调用此方法
 * @param roomId 加入的房间ID VloudJoinConfig.roomId
 * @param info 当前房间的配置参数 @see <VloudJoinConfig>
 */
- (void)didJoinRoomForRoomId:(NSString *)roomId info:(VloudRoomInfo *)info;

/**
 * 与服务器断开连接之后会发送该通知
 * @param roomId 房间ID
 */
- (void)didLeaveRoom:(NSString *)roomID;

/**
 * 断网重连后会调用此方法用于同步数据，并会回调 didGetUserListForRoomId:users:total:pageSize:index:
 * 和 didGetUserListForRoomId:info: 同步第一页的人员数据
 * @param roomId 加入的房间ID VloudJoinConfig.roomId
 * @param info  当前房间的配置参数 @see <VloudJoinConfig>
 */
- (void)didSyncRoomForRoomId:(NSString *)roomId info:(VloudRoomInfo *)info;

/**
 * 该回调已过时，推荐使用 didGetUserListForRoomId:info:
 *
 * 调用 [VloudClient joinRoom:token:] 完成与服务器的连接并且加入了房间之后，会调用一次此方法
 * 调用 [VloudClient reConnectForToken:reconnectCount:] 重连完成之后，会调用一次此方法
 * 调用 [VloudClient getUserListForPageSize:index:] 完成后，会调用一次此方法
 * @param roomId 当前房间的ID
 * @param users 当前用户页的所有用户
 * @param total 当前房间中的用户总数
 * @param pageSize 一页内，用户信息数量的最大值
 * @param index 分页的索引
 */
- (void)didGetUserListForRoomId:(NSString *)roomId
                          users:(NSArray<VloudUser *> *)users
                          total:(NSInteger)total
                       pageSize:(NSInteger)pageSize
                          index:(NSInteger)index;

/**
 * 调用 [VloudClient joinRoom:token:] 完成与服务器的连接并且加入了房间之后，会调用一次此方法
 * 调用 [VloudClient reConnectForToken:reconnectCount:] 重连完成之后，会调用一次此方法
 * 调用 [VloudClient getUserListForPageSize:index:] 完成后，会调用一次此方法
 * @param roomId 当前房间的ID
 * @param info   当前房间页的用户列表的信息
 */
- (void)didGetUserListForRoomId:(NSString *)roomId info:(VloudUsersPageInfo *)info;

/**
 * 该回调已过时，推荐使用 statsChangeForRoomId:roomState:
 *
 * 当收到了服务器传来的房间状态变更的信息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param catorId 当前房间的创建者
 * @param masterId 当前房间的主持人
 * @param audioOff 当前房间是否启用了全员禁言
 * @param secret 当前房间是否带有密码
 * @param doorOpen 当前房间是否允许用户加入（开门）
 */
- (void)statsChangeForRoomId:(NSString *)roomId
                   creatorId:(NSString *)catorId
                    masterId:(NSString *)masterId
                    audioOff:(BOOL)audioOff
                      secret:(BOOL)secret
                    doorOpen:(BOOL)doorOpen;

/**
 * 当收到了服务器传来的房间状态变更的信息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param roomState 当前房间的状态信息
 */
- (void)statsChangeForRoomId:(NSString *)roomId roomState:(VloudRoomState *)roomState;

/**
 * 当收到了服务器传来的用户状态变更的信息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param user   信息变更了的用户
 * @param userInfo 用户变更的信息
 */
- (void)userInfoChangeForRoomId:(NSString *)roomId
                           user:(VloudUser *)user
                       userInfo:(VloudUserInfo *)userInfo;

/**
 * 该回调已过时，推荐使用 receiveMessageForRoomId:info:
 * 接收到其他用户发送的消息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param user 发送消息的用户
 * @param msg 接收到的信息
 */
- (void)receiveMessageForRoomId:(NSString *)roomId user:(VloudUser *)user message:(NSString *)msg;

/**
 * 接收到其他用户发送的消息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param info   消息信息
 */
- (void)receiveMessageForRoomId:(NSString *)roomId info:(VloudMessageInfo *)info;

/**
 * 调用 [VloudClient getMessageListForStartSeq:endSeq:] 完成后，会调用一次此方法
 * @param roomId 当前房间的 ID
 * @param info  消息列表的信息
 */
- (void)didGetMessageListForRoomId:(NSString *)roomId info:(VloudMessageListInfo *)info;

/**
 * 接收到其他用户发送的 Custom 消息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param info   消息信息
 */
- (void)receiveCustomMessageForRoomId:(NSString *)roomId info:(VloudMessageInfo *)info;

/**
 * 主持人被更改时会回调此方法
 * @param roomId 当前房间的 ID
 * @param masterId 新主持人的 userId
 */
- (void)masterChangeForRoomId:(NSString *)roomId masterId:(NSString *)masterId;

/**
 * 收到其他用户加入房间的消息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param user 加入当前房间的用户
 */
- (void)participantJoinForRoomId:(NSString *)roomId user:(VloudUser *)user;

/**
 * 收到其他用户离开房间的消息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param user 离开当前房间的用户
 */
- (void)participantLeaveForRoomId:(NSString *)roomId user:(VloudUser *)user;

/**
 * 收到用户被踢的消息时，会调用此方法
 * @param roomId 当前房间的ID
 * @param user 被踢的用户
 */
- (void)evictedForRoomId:(NSString *)roomId user:(VloudUser *)user;

/**
 * 当前用户在其他地方加入了当前房间时，会回调此方法（当前用户被顶掉了）
 *
 * @param roomId 当前房间的 ID
 * @param info   顶号的用户加入房间时附带的信息
 */
- (void)userRejoinedForRoomId:(NSString *)roomId info:(VloudUserRejoinedInfo *)info;

/**
 * 收到其他用户的推流消息时，会调用此方法
 * @param stream 远端流
 */
- (void)publishedStreamForStream:(VloudStream *)stream;

/**
 * 收到其他用户取消推流的消息时，会调用此方法
 * @param stream 源端流
 */
- (void)unpublishedStreamForStream:(VloudStream *)stream;

/**
 * 当前房间关闭时，会调用此方法
 * @param roomId 关闭的房间
 */
- (void)roomClosedForRoomId:(NSString *)roomId;

/**
 * 房间报错时，会调用这个方法
 * @param paramsValue 报错的具体字段
 */
- (void)roomError:(NSString *)paramsValue;

/**
 * token 即将过期时，会调用此方法
 * @param roomId 关闭的房间
 * @param seconds token 有效期剩余时间，单位是秒
 */
- (void)tokenWillExpireForRoomId:(NSString *)roomId seconds:(NSInteger)seconds;

/**
 * token 已经过期时，会调用此方法
 * @param roomId 关闭的房间
 */
- (void)tokenAlreadyExpireForRoomId:(NSString *)roomId;

@end

RTC_OBJC_EXPORT
@interface VloudClient : NSObject

/// 用于接收 VloudClient 事件回调
@property(nonatomic, weak, nullable) id<VloudClientDelegate> delegate;

+ (instancetype)alloc __attribute__((unavailable("use VloudClientManager create")));

+ (instancetype)new __attribute__((unavailable("use VloudClientManager create")));

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) VloudAudioEffecter *audioEffecter;

/**
 * 更新 token
 * @param token 服务端用于校验身份信息
 */
- (void)refreshToken:(NSString *)token;

/**
 * 通过 userId 获取 VloudUser
 * @param userId 需要获取的用户的UserId
 */
- (VloudUser *)getUserByUserId:(NSString *)userId;

/**
 *
 */
- (void)setupConnectConfig:(VloudConnectConfig *)config;

/**
 * 加入房间
 * @param config 加入房间需要的信息
 * @param token 服务端用于校验身份信息
 */
- (void)joinRoom:(VloudJoinConfig *)config token:(NSString *)token;

/**
 * 该方法已过时，推荐使用 updateRoomForState
 * 设置全员禁言，当前用户为主持人时才可使用此方法
 * @param mute 为 YES 时开启全员禁言，为 NO 时关闭全员禁言
 */
- (void)setAllMemberAudioMute:(BOOL)mute;

/**
 * 该方法已过时，推荐使用 updateRoomForState
 * 是否允许用户加入，当前用户为主持人时才可使用此方法
 * @param allow 为 YES 时允许用户加入，为 NO 时禁止用户加入
 */
- (void)setAllowJoin:(BOOL)allow;

/**
 * 该方法已过时，推荐使用 updateRoomForState
 * 设置房间密码，当前用户为主持人时才可使用此方法
 * @param password 值为 @"" 时表示不使用密码
 */
- (void)setRoomPassword:(NSString *)password;

/**
 * 更新房间状态
 * @param state 当前房间的状态信息 [VloudRoomState] 被赋值的属性才会修改相应的配置
 */
- (void)updateRoomForState:(VloudRoomState *)state;

/**
 * 更新用户信息。非主持人只可更新自己的用户信息，主持人可更新其他用户的信息
 * @param userId 需要修改状态的用户的 userId
 * @param info  需要更改的状态信息 [VloudUserInfo]
 */
- (void)updateUserForUserId:(NSString *)userId info:(VloudUserInfo *)info;

/**
 * 移交主持人权限，移交完成后，本地用户将失去主持人权限
 * @param userId 主持人权限将移交给用户ID为 userId 的用户
 */
- (void)changeMasterForUserId:(NSString *)userId;

/**
 * 通知 BRTCCore 前后台切换事件
 * @param 是否在后台
 */
- (void)appToggleBackground:(BOOL)isBackground;

/**
 * 获取用户列表，将当前房间内的用户按照 pageSize 设置的大小分页，返回 index
 * 页的用户（index最小值为0）
 * @param pageSize 一页内容的用户数
 * @param index 页数的索引
 */
- (void)getUserListForPageSize:(NSInteger)pageSize index:(NSInteger)index;

/**
 * 获取消息列表，将当前房间内的历史消息的 seq 为 [startSeq,endSeq) 区间内的消息返回
 * @param startSeq 起始 seq
 * @param endSeq 结束 seq
 */
- (void)getMessageListForStartSeq:(NSInteger)startSeq endSeq:(NSInteger)endSeq;

/**
 * 将 userId 用户踢出房间。当前用户为主持人时才可使用此方法，被踢出的用户无法再次进入当前房间。
 * @param userId 要踢出房间的用户的 userId
 */
- (void)evictUser:(NSString *)userId;

/**
 * 初始化状态统计功能
 * @param enable 是否启用状态统计功能
 * @param delay 状态统计间隔，间隔 delay 毫秒统计一次状态
 * @param updateInterval 状态上报间隔，间隔 updateInterval
 * 秒向服务器上报一次状态，需服务端开启report 标记
 */
- (void)statisticsStatus:(BOOL)enable
                   delay:(NSInteger)delay
          updateInterval:(NSInteger)updateInterval;

/**
 * 断网重连，收到 [VloudClientDelegate vloudClientDidConnectFailed:message:] 回调后可调用该函数
 * @param token 服务端用于校验身份信息
 * @param reconnectCount 重连次数
 */
- (void)reConnectForToken:(NSString *)token reconnectCount:(NSInteger)reconnectCount;

/**
 * 向当前房间中发送消息
 * @param cmdId 消息ID
 * @param userId 接收消息的用户的 userId，为 nil 则向房间中的所有用户发送消息
 * @param msg 发送的消息
 */
- (void)sendMessageForCmdId:(NSNumber *)cmdId userId:(NSString *)userId message:(NSString *)msg;

/**
 * 向当前房间中发送Custom消息。不会被过滤敏感词
 * @param userId 接收消息的用户的 userId，为 nil 则向房间中的所有用户发送消息
 * @param msg 发送的消息
 */
- (void)sendCustomMessageForUserId:(NSString *)userId message:(NSString *)msg;

/**
 * 发送音视频统计质量参数
 *
 * @param statistics 发送的音视频统计质量参数
 */
- (void)sendStatistics:(NSString *)statistics;

/**
 *
 */
- (void)setComments:(NSString *)comments;

/**
 * 向当前房间添加媒体流
 * @param stream 添加的流
 */
- (void)addStream:(VloudStream *)stream;

/**
 * 在当前房间中移除媒体流
 * @param stream 移除的流
 */
- (void)removeStream:(VloudStream *)stream;

/**
 * 退出房间
 */
- (void)leaveRoom;

/**
 * 释放房间
 */
- (void)releaseRoom;

@end

NS_ASSUME_NONNULL_END
