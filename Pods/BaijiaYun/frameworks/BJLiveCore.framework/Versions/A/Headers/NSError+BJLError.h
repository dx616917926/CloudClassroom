//
//  NSError+BJLError.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-11-30.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 BJLError 可用属性
 .domain                    BJLErrorDomain
 .code                      BJLErrorCode - 错误码
 .localizedDescription      NSString * - 错误描述
 .localizedFailureReason    NSString * - 错误原因，可能为空 - TODO: 干掉，如果有具体错误信息则替换调默认的错误描述
 .bjl_sourceError           NSError * - 引起当前错误的错误，可能为空
 TODO: server errorCode, message
 */

FOUNDATION_EXPORT const NSErrorDomain BJLErrorDomain;

typedef NS_ENUM(NSInteger, BJLErrorCode) {
    /** 成功 */
    BJLErrorCode_success = 0,
    //// common ////
    /** 网络错误 */
    BJLErrorCode_networkError,
    /** 请求失败 */
    BJLErrorCode_requestFailed,
    /** 主动调用取消 */
    BJLErrorCode_cancelled,
    /** 非法用户角色 */
    BJLErrorCode_invalidUserRole,
    /** 非法调用 */
    BJLErrorCode_invalidCalling,
    /** 参数错误 */
    BJLErrorCode_invalidArguments,
    /** 操作过于频繁 */
    BJLErrorCode_areYouRobot,
    //// enter room ////
    /** 直播间已满 */
    BJLErrorCode_enterRoom_roomIsFull,
    /** 不支持 iOS 端进入直播间 */
    BJLErrorCode_enterRoom_unsupportedClient,
    /** 不支持当前设备进入直播间 */
    BJLErrorCode_enterRoom_unsupportedDevice,
    /** 用户被禁止进入直播间 */
    BJLErrorCode_enterRoom_forbidden,
    /** 用户已经在其它设备登录 */
    BJLErrorCode_enterRoom_loginConflict,
    /** 试听结束 */
    BJLErrorCode_enterRoom_auditionTimeout,
    /** 直播间时间到期 */
    BJLErrorCode_enterRoom_timeExpire,
    //// exit room ////
    /** 连接断开 */
    BJLErrorCode_exitRoom_disconnected,
    /** 用户在其它设备登录 */
    BJLErrorCode_exitRoom_loginConflict,
    /** 用户被请出直播间 */
    BJLErrorCode_exitRoom_kickout,
    /** 试听结束 */
    BJLErrorCode_exitRoom_auditionTimeout,
    /** 直播间时间到期 */
    BJLErrorCode_exitRoom_timeExpire,
    /** 主讲离开，直播间关闭 */
    BJLErrorCode_exitRoom_presenterLeave,
    /** 不存在可以作为外接摄像头的用户 */
    BJLErrorCode_exitRoom_noReplacedUser,
    /** 用户被请出直播间，并没有加入黑名单 */
    BJLErrorCode_exitRoom_kickout_notAddBlackList,
    /** 下课后自动退出 */
    BJLErrorCode_exitRoom_class_end,
    /** 强制禁用直播间, 此错误码的des由服务端传过来 */
    BJLErrorCode_exitRoom_enforceForbid,
    /** 日志记录为空 */
    BJLErrorCode_invalidLog,
    /* !!!: 
     1、在此之前增加错误码；
     2、不要设置错误码取值；
     3、同步增删 BJLErrorDescriptions； */
    BJLErrorCode_unknown // 未知错误
};

FOUNDATION_EXPORT NSString *const BJLErrorDescription_unknown;
FOUNDATION_EXPORT NSString *_Nonnull const BJLErrorDescriptions[];

static inline BJLError *_Nullable BJLErrorMakeFromError(BJLErrorCode errorCode, NSString *_Nullable reason, NSError *_Nullable sourceError) {
    if (errorCode == BJLErrorCode_success) {
        return nil;
    }
    BJLErrorCode titleIndex = (BJLErrorCode)MIN(MAX(0, errorCode), BJLErrorCode_unknown);
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    [userInfo setObject:BJLLocalizedString(BJLErrorDescriptions[titleIndex]) ?: BJLErrorDescription_unknown forKey:NSLocalizedDescriptionKey];
    if (reason) {
        [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    if (sourceError) {
        [userInfo setObject:sourceError forKey:BJLErrorSourceErrorKey];
    }
    return (BJLError *)[NSError errorWithDomain:BJLErrorDomain code:errorCode userInfo:userInfo];
}

static inline BJLError *_Nullable BJLErrorMake(BJLErrorCode errorCode, NSString *_Nullable reason) {
    return BJLErrorMakeFromError(errorCode, reason, nil);
}

#define bjl_isRobot(LIMIT) ({                                     \
    static NSTimeInterval LAST = 0.0;                             \
    NSTimeInterval NOW = [NSDate timeIntervalSinceReferenceDate]; \
    BOOL isRobot = NOW - LAST < LIMIT;                            \
    if (!isRobot) {                                               \
        LAST = NOW;                                               \
    }                                                             \
    isRobot;                                                      \
})

#define bjl_returnIfRobot(LIMIT)                                      \
    {                                                                 \
        static NSTimeInterval LAST = 0.0;                             \
        NSTimeInterval NOW = [NSDate timeIntervalSinceReferenceDate]; \
        if (NOW - LAST < LIMIT) {                                     \
            return;                                                   \
        }                                                             \
        LAST = NOW;                                                   \
    }

#define bjl_returnErrorIfRobot(LIMIT)                                                             \
    {                                                                                             \
        static NSTimeInterval LAST = 0.0;                                                         \
        NSTimeInterval NOW = [NSDate timeIntervalSinceReferenceDate];                             \
        if (NOW - LAST < LIMIT) {                                                                 \
            return BJLErrorMake(BJLErrorCode_areYouRobot,                                         \
                [NSString stringWithFormat:BJLLocalizedString(@"每 %g 秒只能操作 1 次"), LIMIT]); \
        }                                                                                         \
        LAST = NOW;                                                                               \
    }

#pragma mark -

@interface BJLRobotCatcher: NSObject

@property (nonatomic) NSInteger limit;
@property (nonatomic) NSTimeInterval duration;

+ (instancetype)robotCatcherWithLimit:(NSInteger)limit duration:(NSTimeInterval)duration;
- (nullable BJLError *)tryCatch;

// 用于统计
@property (nonatomic, readonly) NSInteger maxCatchCount, currentCatchCount, maxCount, currentCount;

@end

NS_ASSUME_NONNULL_END
