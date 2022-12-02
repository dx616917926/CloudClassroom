//
//  BJYRTMPMediaView.h
//  TestIJKPlayer
//
//  Created by lw0717 on 2019/3/15.
//  Copyright © 2019年 lw0717. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJYAudioMixerManager.h"

NS_ASSUME_NONNULL_BEGIN

/// stopped -> loading -> playing -> stopped/End/Interrupted -> stopped
typedef NS_ENUM(NSInteger, BJYRTCMPMoviePlaybackState) {
    BJYRTCMPMoviePlaybackStateStopped,
    BJYRTCMPMoviePlaybackStateLoading,
    BJYRTCMPMoviePlaybackStatePlaying,
    BJYRTCMPMoviePlaybackStatePaused,
    BJYRTCMPMoviePlaybackStateEnd,
    BJYRTCMPMoviePlaybackStateInterrupted,
    BJYRTCMPMoviePlaybackStateFailed,
    BJYRTCMPMoviePlaybackStateSeekingForward,
    BJYRTCMPMoviePlaybackStateSeekingBackward
};

typedef NS_ENUM(NSUInteger, BJYRTCMPMovieFinishReason) {
    BJYRTCMPMovieFinishReasonPlaybackEnded,
    BJYRTCMPMovieFinishReasonPlaybackError,
    BJYRTCMPMovieFinishReasonUserExited
};

typedef NS_ENUM(NSUInteger, BJYRTCLoadState) {
    /// 加载状态未知
    BJYRTCLoadStateUnknown,
    /// 加载开始
    BJYRTCLoadStateLoadStart,
    /// 加载完成
    BJYRTCLoadStateLoadEnd,
};

typedef NS_ENUM(NSUInteger, BJYRTCMPScalingMode) {
    /// No scaling
    BJYRTCMPScalingModeNone,
    /// Uniform scale until one dimension fits
    BJYRTCMPScalingModeAspectFit,
    /// Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    BJYRTCMPScalingModeAspectFill,
    /// Non-uniform scale. Both render dimensions will exactly match the visible bounds
    BJYRTCMPScalingModeFill,
};

@class BJYRTMPMediaView;

@protocol BJYRTMPMediaViewDelegate <NSObject>

@optional
- (void)rtmpMediaView:(BJYRTMPMediaView *)rtmpMediaView playBackStateDidChange:(BJYRTCMPMoviePlaybackState)state;
- (void)rtmpMediaView:(BJYRTMPMediaView *)rtmpMediaView loadStateDidChange:(BJYRTCLoadState)state;
- (void)rtmpMediaView:(BJYRTMPMediaView *)rtmpMediaView moviePlayBackDidFinish:(BJYRTCMPMovieFinishReason)state;

- (void)mediaFirstVideoFrameDecoded:(BJYRTMPMediaView *)rtmpMediaView;

- (void)mediaNaturalSizeDidChange:(BJYRTMPMediaView *)rtmpMediaView;

- (void)mediaDidShutdown:(BJYRTMPMediaView *)rtmpMediaView;

- (void)mediaBlock:(BJYRTMPMediaView *)rtmpMediaView;

@end

@interface BJYRTMPMediaView : UIView

@property (nonatomic, weak) id<BJYRTMPMediaViewDelegate> delegate;

@property (nonatomic, readonly) NSURL *liveURL;
/// 视频原始大小
@property (nonatomic, readonly) CGSize naturalSize;

@property (nonatomic, readonly) int ssrc;

@property (nonatomic, readonly) int sample;

@property (nonatomic, readonly) BJYRTCMPMoviePlaybackState state;
@property (nonatomic, assign) NSTimeInterval initialPlayTime;

/// isMixer: NO
- (instancetype)initWithLiveURL:(NSURL *)liveURL;

/// 混音模式不支持动态设置，要在 audio open 之前设置好
- (instancetype)initWithLiveURL:(NSURL *)liveURL isMixer:(BOOL)isMixer;

/// 设置缓存最大延迟时间
- (void)setMaxBufferTime:(int)maxBufferTime;
- (int)getMaxBufferTime;

- (BOOL)isVideoToolboxOpen;

- (BOOL)isPreparedToPlay;
- (void)prepareToPlay;
- (BOOL)isPlaying;
- (void)play;

- (void)pause;
- (void)stop;
- (void)shutdown;

- (void)seekToTime:(NSTimeInterval)time;
- (void)changeRate:(CGFloat)rate;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;
- (NSTimeInterval)cachedDuration;
- (CGFloat)rate;

- (void)setPauseInBackground:(BOOL)pause;

- (BOOL)muteVideo:(BOOL)isMute;
- (BOOL)muteAudio:(BOOL)isMute;

- (void)setScalingMode:(BJYRTCMPScalingMode)scalingMode;

- (BOOL)switchAudioTransport2Media:(BOOL)isMediaTransport;

@end

@interface BJYRTMPMediaView (BJYRTCAudioPlayerSourceDelegate) <BJYRTCAudioPlayerSourceDelegate>

- (int)getPCMDataWithCallback:(void(^)(int16_t* data, size_t samples_per_channel, int sample_rate_hz, size_t num_channels))callback;

@end

NS_ASSUME_NONNULL_END
