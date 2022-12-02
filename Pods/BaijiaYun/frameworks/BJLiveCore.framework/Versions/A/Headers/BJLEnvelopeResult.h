//
//  BJLEnvelopeResult.h
//  BJLiveCore
//
//  Created by xijia dai on 2019/5/10.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLEnvelopeResult: NSObject

@property (nonatomic, readonly) NSInteger totalScore;
@property (nonatomic, readonly) NSInteger totalEnvelopeAmount;
@property (nonatomic, readonly) NSInteger totalUsedScore;
@property (nonatomic, readonly) NSInteger totalUsedEnvelopeAmount;

@end

@interface BJLEnvelopeRank: NSObject

@property (nonatomic, readonly) NSInteger rank;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *userNumber;
@property (nonatomic, readonly) NSInteger score;

@end

NS_ASSUME_NONNULL_END
