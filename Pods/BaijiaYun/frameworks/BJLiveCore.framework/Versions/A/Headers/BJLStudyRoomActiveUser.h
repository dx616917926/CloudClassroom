//
//  BJLStudyRoomActiveUser.h
//  BJLiveCore
//
//  Created by Ney on 12/9/20.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

/** ### 自习室用户列表信息 */
@interface BJLStudyRoomActiveUser: NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSString *userNumber;
@property (nonatomic, copy, readonly) NSString *userName;

/// 挂机或自习时间。具体是挂机还是自习时间根据isActive状态来区分。单位为秒
@property (nonatomic, assign, readonly) CGFloat duration;

/// 是否正在挂机
@property (nonatomic, assign, readonly) BOOL isHangUp;

/// 是否离开直播间
@property (nonatomic, assign, readonly) BOOL isLeave;

/// 是否在台上
@property (nonatomic, assign, readonly) BOOL isActive;

/// 是否处于辅导模式
@property (nonatomic, assign, readonly) BOOL isTutor;

/**
 获取递增的时间数值，注意，这个时间不是时间戳。（类似于uptime的时间）主要用于计算本地时间差。iOS10以上是clock_gettime的封装不会被用户的设置影响，iOS10以下是基于 NSDate.date 会受用户设置影响
 */
- (NSTimeInterval)getMonotonicIncreasingDuration;
@end

NS_ASSUME_NONNULL_END
