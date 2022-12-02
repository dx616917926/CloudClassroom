//
//  BJLLottery.h
//  BJLiveCore
//
//  Created by xyp on 2020/8/25.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//
//  标准抽奖 和 口令抽奖 的model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLLotteryType) {
    BJLLotteryType_Standard = 0, // 标准抽奖
    BJLLotteryType_Command = 1, // 口令抽奖
};

@interface BJLLotteryUser: NSObject <NSCopying>

@property (nonatomic, readonly) NSString *userName, *userNumber;

@end

#pragma mark -

/// 口令抽奖 开始的model
@interface BJLCommandLotteryBegin: NSObject <NSCopying>

/// 抽奖类型
@property (nonatomic, readonly) BJLLotteryType type;
/// 口令
@property (nonatomic, readonly) NSString *command;
/// 口令抽奖的时长
@property (nonatomic, readonly) NSInteger duration;

@property (nonatomic, readonly) NSTimeInterval beginTime;
@property (nonatomic, readonly) NSString *clssID;

@end

#pragma mark -

/// 标准抽奖 和 口令抽奖 开奖结果的model
@interface BJLLottery: NSObject <NSCopying>

/// 抽奖类型
@property (nonatomic, readonly) BJLLotteryType type;

@property (nonatomic, readonly) NSTimeInterval beginTime;
/// 中奖名单
@property (nonatomic, readonly) NSArray<BJLLotteryUser *> *userList;
/// 奖品
@property (nonatomic, readonly) NSString *lotteryName;

@end

NS_ASSUME_NONNULL_END
