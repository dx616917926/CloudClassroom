//
//  BJYAudioMixerManager.h
//  BJYRTCEngine
//
//  Created by lw0717 on 2020/7/31.
//  Copyright © 2020 BaiJiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJYRTCAudioPlayerSourceDelegate <NSObject>

- (int)getPCMDataWithCallback:(void(^)(int16_t* data, size_t samples_per_channel, int sample_rate_hz, size_t num_channels))callback;

@end

@interface BJYAudioMixerManager : NSObject

+ (instancetype)sharedInstance;
+ (void)release;

- (void)startMixerWithSSRC:(int)ssrc sample:(int)sample audioPlayerSource:(id<BJYRTCAudioPlayerSourceDelegate>)audioPlayerSource;
- (void)stopMixerWithSsrc:(NSNumber *)ssrc;

- (int)correctSsrc:(int)ssrc;

- (BOOL)switchAudioTransport2Media:(BOOL)isMediaTransport;

@end

NS_ASSUME_NONNULL_END
