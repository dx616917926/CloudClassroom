//
//  VloudConnectConfig.h
//  BRTC
//
//  Created by lw0717 on 2020/12/16.
//  Copyright © 2020 BJY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudConnectConfig : NSObject

/// 重试的最大次数
@property(nonatomic, assign) int count;

/// 重试的时间 ms
@property(nonatomic, assign) int ms;

- (instancetype)init;

- (instancetype)initWithReconnectCount:(int)count ms:(int)ms;

@end

NS_ASSUME_NONNULL_END
