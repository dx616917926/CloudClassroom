//
//  BRTCAudioPlayer.h
//  BRTC
//
//  Created by 辛亚鹏 on 2022/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJRTAudioPlayerMixSourceDelegate <NSObject>

- (int)getPCMDataWithCallback:(void(^)(int16_t* data, size_t samples_per_channel, int sample_rate_hz, size_t num_channels))callback ssrc:(NSNumber *)ssrc;

@end


@interface BRTCAudioPlayer : NSObject

@property (nonatomic, weak) id <BJRTAudioPlayerMixSourceDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;

- (void)startWithSSRC:(int)ssrc sample:(int)sample;

- (void)stop;

- (BOOL)switchAudioTransport2Media:(BOOL)isMediaTransport;

@end

NS_ASSUME_NONNULL_END
