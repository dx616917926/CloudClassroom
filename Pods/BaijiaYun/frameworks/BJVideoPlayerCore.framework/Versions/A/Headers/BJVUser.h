//
//  BJVUser.h
//  BJVideoPlayerCore
//
//  Created by xyp on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJVConstants.h"

NS_ASSUME_NONNULL_BEGIN

/** 用户分组的信息 */
@interface BJVUserGroup: NSObject

@property (nonatomic, readonly) NSInteger groupID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *color;

@end

/** 用户基本信息 - 内部使用 */
@interface _BJVBaseUser: NSObject

@property (nonatomic, readonly) NSString *number, *ID;
@property (nonatomic, readonly) NSInteger groupID;
@property (nonatomic, readonly) BJVUserRole role;
@property (nonatomic, readonly) BJVClientType clientType;

@end

/** 用户 */
@interface BJVUser: _BJVBaseUser

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly, nullable) NSString *avatar;
@property (nonatomic, readonly, nullable) NSString *cameraCover; // 关闭摄像头的占位图
@property (nonatomic, readonly) BJVOnlineState onlineState;
@property (nonatomic, readonly) BJVUserMediaState audioState, videoState;

@property (nonatomic, readonly) BOOL isAudition;
@property (nonatomic, readonly) NSInteger auditionDurationInSeconds;
@property (nonatomic, readonly, nullable) NSString *replaceNumber; // 目标替换用户的 number，默认为 nil

/**
 初始化 user
 groupID 传 NSNotFound 时表示此字段不参与签名计算，创建后 user.groupID 被设置为 0
 */
+ (instancetype)userWithNumber:(NSString *)number
                          name:(NSString *)name
                       groupID:(NSInteger)groupID
                        avatar:(nullable NSString *)avatar
                          role:(BJVUserRole)role;

/**
 初始化用户对象
 groupID 传 NSNotFound 时表示此字段不参与签名计算，创建后 user.groupID 被设置为 0
 replaceUserNumber 不为空时，当前用户将作为外接设备使用
 replaceRole 是被替换的用户的角色，不传时认为是当前用户的角色
 */
+ (instancetype)userWithNumber:(NSString *)number
                          name:(NSString *)name
                       groupID:(NSInteger)groupID
                        avatar:(nullable NSString *)avatar
                          role:(BJVUserRole)role
                 replaceNumber:(nullable NSString *)replaceNumber;
+ (instancetype)userWithNumber:(NSString *)number
                          name:(NSString *)name
                       groupID:(NSInteger)groupID
                        avatar:(nullable NSString *)avatar
                          role:(BJVUserRole)role
                 replaceNumber:(nullable NSString *)replaceNumber
                   replaceRole:(BJVUserRole)replaceRole;

@end

/** 用户扩展属性、方法 */
@interface BJVUser (ext)

@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) BOOL isTeacher, isAssistant, isStudent, isGuest;
@property (nonatomic, readonly) BOOL isTeacherOrAssistant;
@property (nonatomic, readonly) BOOL noGroup;

- (BOOL)isSameUser:(__kindof BJVUser *)user;
- (BOOL)isSameUserWithID:(nullable NSString *)userID number:(nullable NSString *)userNumber;

/**「老师/助教」或「对象用户所在小组的 老师/助教」*/
- (BOOL)canManageUser:(__kindof BJVUser *)user;

- (BOOL)containedInUsers:(NSArray<__kindof BJVUser *> *)users;

- (BOOL)containsMediaWithID:(NSString *)mediaID;

+ (nullable NSString *)displayNameOfName:(nullable NSString *)name;
+ (nullable NSString *)descriptionWithUserMediaState:(BJVUserMediaState)mediaState;

@end

NS_ASSUME_NONNULL_END
