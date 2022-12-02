/***********************
auth: cszdlt@qq.com
date: 2020-05-11 11:21:10
name: VloudUserRejoinedInfo.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudUserRejoinedInfo : NSObject

/// 用户的 userId
@property(nonatomic, readonly) NSString *userId;

/// 用户扩展信息
@property(nonatomic, readonly) NSString *info;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
