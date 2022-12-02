//
//  BJLPKStatusModel.h
//  BJLiveCore
//
//  Created by xijia dai on 2022/7/6.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLPKStatus) {
    BJLPKStatus_end = 0,
    BJLPKStatus_process = 1,
    BJLPKStatus_vote = 2,
};

@interface BJLPKUserInfo: BJLUser

@property (nonatomic, readonly) NSInteger voteCount;

@end

@interface BJLPKStatusModel : NSObject

@property (nonatomic, readonly) BJLPKStatus status;
@property (nonatomic, readonly) NSArray<BJLPKUserInfo *> *pkUsers;
@property (nonatomic, readonly) NSTimeInterval startTimeInterval;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly, nullable) NSString *hasVoteUserNumber;

@end

NS_ASSUME_NONNULL_END
