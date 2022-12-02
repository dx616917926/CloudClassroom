/***********************
auth: cszdlt@qq.com
date: 2020-03-26 17:18:51
name: VloudRoomInfo.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudRoomInfo : NSObject

/// 房间ID
@property(nonatomic, readonly) NSString *roomId;

/// callID
@property(nonatomic, readonly) NSString *callId;

/// 本地用户的 userId
@property(nonatomic, readonly) NSString *localUserId;

/// 房间内的总人数
@property(nonatomic, readonly) NSInteger total;

/// 是否上报统计信息
@property(nonatomic, readonly) BOOL report;

/// 房间创建时间 单位秒
@property(nonatomic, readonly) NSInteger startup;

/// 房间持续时间 单位秒
@property(nonatomic, readonly) NSInteger duration;

/// 房间剩余时间 单位秒
@property(nonatomic, readonly) NSInteger lastTime;

/// 房间内用户数量的最大值
@property(nonatomic, readonly) NSInteger limit;

/// 加入房间时，最新的消息的 seq。可用于调用[VloudClient getMessageListForStartSeq:endSeq:]获取历史消息
@property(nonatomic, readonly) NSInteger msgSeq;

/// 房间创建者的 userId
@property(nonatomic, readonly) NSString *creatorId;

/// 房间主持人的 userId
@property(nonatomic, readonly) NSString *masterId;

/// 当前房间是否锁定
@property(nonatomic, assign) BOOL lock;

/// 是否允许用户自行打开麦克风
@property(nonatomic, assign) BOOL selfOpenAudio;

/// 当前房间是否已启动全员禁用麦克风
@property(nonatomic, readonly) BOOL audioOff;

/// 当前房间是否已启动全员禁用摄像头
@property(nonatomic, readonly) BOOL videoOff;

/// 当前房间是否已启动全员禁止发送消息
@property(nonatomic, readonly) BOOL msgOff;

/// 当前房间是否有密码
@property(nonatomic, readonly) BOOL secret;

/// 当前房间是否允许加入
@property(nonatomic, readonly) BOOL doorOpen;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
