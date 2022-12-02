//
//  BJLUser.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-11-15.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJLConstants.h"

NS_ASSUME_NONNULL_BEGIN

/** 用户分组的信息 */
@interface BJLUserGroup: NSObject

@property (nonatomic, readonly) NSInteger groupID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *color;

@end

/** 用户基本信息 - 内部使用 */
@interface _BJLBaseUser: NSObject

@property (nonatomic, readonly) NSString *number, *ID;
@property (nonatomic, readonly) NSInteger groupID;
@property (nonatomic, readonly) BJLUserRole role;
@property (nonatomic, readonly) BJLClientType clientType;

@end

/** 用户 */
@interface BJLUser: _BJLBaseUser

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly, nullable) NSString *avatar;
@property (nonatomic, readonly, nullable) NSString *cameraCover; // 关闭摄像头的占位图
@property (nonatomic, readonly) BJLOnlineState onlineState;
@property (nonatomic, readonly) BJLUserMediaState audioState, videoState;

@property (nonatomic, readonly) BOOL isAudition;
@property (nonatomic, readonly) NSInteger auditionDurationInSeconds;
@property (nonatomic, readonly, nullable) NSString *replaceNumber; // 目标替换用户的 number，默认为 nil

/**
 初始化 user
 #param number       用户编号，合作方账号体系下的用户 ID 号，必须是数字
 #param name         用户名
 #param groupID      分组 ID，不分组参与了签名计算时传 0，未参与签名计算时传 NSNotFound
 #param avatar       用户头像 URL(nullable)
 #param role         用户角色:老师、学生等
*/
+ (instancetype)userWithNumber:(NSString *)number
                          name:(NSString *)name
                       groupID:(NSInteger)groupID
                        avatar:(nullable NSString *)avatar
                          role:(BJLUserRole)role;

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
                          role:(BJLUserRole)role
                 replaceNumber:(nullable NSString *)replaceNumber;
+ (instancetype)userWithNumber:(NSString *)number
                          name:(NSString *)name
                       groupID:(NSInteger)groupID
                        avatar:(nullable NSString *)avatar
                          role:(BJLUserRole)role
                 replaceNumber:(nullable NSString *)replaceNumber
                   replaceRole:(BJLUserRole)replaceRole;

@end

/** 用户扩展属性、方法 */
@interface BJLUser (ext)

@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) BOOL isTeacher, isAssistant, isStudent, isGuest;
@property (nonatomic, readonly) BOOL isTeacherOrAssistant;
@property (nonatomic, readonly) BOOL noGroup;

- (BOOL)isSameUser:(__kindof BJLUser *)user;
- (BOOL)isSameUserWithID:(nullable NSString *)userID number:(nullable NSString *)userNumber;

/**「老师/助教」或「对象用户所在小组的 老师/助教」*/
- (BOOL)canManageUser:(__kindof BJLUser *)user;

- (BOOL)containedInUsers:(NSArray<__kindof BJLUser *> *)users;

- (BOOL)containsMediaWithID:(NSString *)mediaID;

+ (nullable NSString *)displayNameOfName:(nullable NSString *)name;
+ (nullable NSString *)descriptionWithUserMediaState:(BJLUserMediaState)mediaState;

@end

NS_ASSUME_NONNULL_END
