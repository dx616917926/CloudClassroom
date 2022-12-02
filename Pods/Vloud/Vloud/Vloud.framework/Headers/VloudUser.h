/***********************
auth: cszdlt@qq.com
date: 2020-03-21 17:52:04
name: VloudUser.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

#import "VloudStream.h"

NS_ASSUME_NONNULL_BEGIN

@class VloudUserInfo;

RTC_OBJC_EXPORT
@interface VloudUser : NSObject

/// 当前用户的 userId
@property(nonatomic, readonly) NSString *userId;

/// 当前用户的所有 VloudStream
@property(nonatomic, readonly) NSArray *streams;

/// 当前用户的用户信息
@property(nonatomic, readonly) VloudUserInfo *info;

/**
 * 根据 streamId 获取 VloudStream
 * @param streamId 需要获取的 VloudStream 的 streamId
 * @return VloudStream
 */
- (VloudStream *)getStreamForStreamId:(NSString *)streamId;

- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
