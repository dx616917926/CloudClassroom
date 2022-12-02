/***********************
auth: cszdlt@qq.com
date: 2020-05-11 11:16:11
name: VloudUserInfo.h
************************/
#import <Foundation/Foundation.h>

#import "RTCMacros.h"

@class VloudUserPermission;

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudUserInfo : NSObject

/// 用户昵称
@property(nonatomic, copy) NSString *nickName;

/// 自定义用户扩展信息
@property(nonatomic, copy) NSString *extendInfo;

/// 用户加入房间时附带的可被解析的完整信息
@property(nonatomic, copy) NSString *info;

/// 用户权限
@property(nonatomic, copy) VloudUserPermission *permission;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNickName:(NSString *)nickName
                      extendInfo:(NSString *)extendInfo
                            info:(NSString *)info
                      permission:(NSString *)permission;
@end

NS_ASSUME_NONNULL_END
