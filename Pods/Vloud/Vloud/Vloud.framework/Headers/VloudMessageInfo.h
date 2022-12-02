/***********************
auth: cszdlt@qq.com
date: 2020-05-11 11:18:14
name: VloudMessageInfo.h
************************/
#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudMessageInfo : NSObject

/// 房间ID
@property(nonatomic, readonly) NSString *roomId;

/// 消息发送者
@property(nonatomic, readonly) NSString *userId;

///
@property (nonatomic, readonly) NSInteger cmdID;

/// 消息接收者。为 nullptr 时表示当前消息为房间广播
@property(nonatomic, readonly) NSString *to;

/// 消息信息
@property(nonatomic, readonly) NSString *msg;

/// 是否是发送给其他用户的私聊消息。只在获取消息列表的回调中被使用
@property(nonatomic, readonly) BOOL privateMsg;

/// 消息序列号
@property(nonatomic, readonly) NSInteger seq;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
