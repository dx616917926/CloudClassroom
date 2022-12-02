//
//  BJLScCountDownViewController.h
//  BJLiveUI
//
//  Created by 凡义 on 2019/10/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>
#import "BJLWindowViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** 三分屏直播间的倒计时 */
@interface BJLScCountDownViewController: BJLWindowViewController

@property (nonatomic, readonly) BOOL isDecrease;
@property (nonatomic, readonly) BOOL shouldPause;
@property (nonatomic, readonly) NSUInteger originCountDownTime;
@property (nonatomic, readonly) NSUInteger currentCountDownTime;
@property (nonatomic, copy, nullable) void (^showCountDownEditViewCallback)(void);

- (instancetype)initWithRoom:(BJLRoom *)room;

- (void)updateTimerWithTotalTime:(NSUInteger)time
            currentCountDownTime:(NSUInteger)currentCountDownTime
                      isDecrease:(BOOL)isDecrease
                     shouldPause:(BOOL)shouldPause;

@end

NS_ASSUME_NONNULL_END
