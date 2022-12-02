/***********************
auth: cszdlt@qq.com
date: 2020-05-11 11:20:02
name: VloudMessageListInfo.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudMessageListInfo : NSObject

/// 起始 seq
@property(nonatomic, readonly) NSInteger startSeq;

/// 结束 seq
@property(nonatomic, readonly) NSInteger endSeq;

/// seq 在 [startSeq, endSeq) 区间内的消息
@property(nonatomic, readonly) NSArray *messages;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
