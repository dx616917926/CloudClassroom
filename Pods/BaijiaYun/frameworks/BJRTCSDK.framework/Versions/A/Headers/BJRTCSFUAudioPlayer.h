//
//  BJRTCSFUAudioPlayer.h
//  BJRTCSDK
//
//  Created by lw0717 on 2020/7/27.
//  Copyright © 2020 BJY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJRTCSFUAudioPlayerSourceDelegate <NSObject>

- (int)getPCMDataWithCallback_:(void(^)(int16_t* data, size_t samples_per_channel, int sample_rate_hz, size_t num_channels))callback ssrc:(NSNumber *)ssrc;

@end

@interface BJRTCSFUAudioPlayer : NSObject

@property (nonatomic, weak) id <BJRTCSFUAudioPlayerSourceDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;

- (void)startWithSSRC:(int)ssrc sample:(int)sample;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
