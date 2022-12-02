/***********************
auth: cszdlt@qq.com
date: 2020-05-11 11:19:09
name: VloudUsersPageInfo.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudUsersPageInfo : NSObject

/// 当前房间中的用户总数
@property(nonatomic, readonly) NSInteger total;

/// 一页内，用户信息数量的最大值
@property(nonatomic, readonly) NSInteger pageSize;

/// 分页的索引
@property(nonatomic, readonly) NSInteger index;

/// 当前用户页的所有用户
@property(nonatomic, readonly) NSArray * users;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
