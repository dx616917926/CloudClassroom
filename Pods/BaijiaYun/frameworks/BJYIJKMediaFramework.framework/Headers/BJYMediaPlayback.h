/*
 * BJYMediaPlayback.h
 *
 * Copyright (c) 2013 Bilibili
 * Copyright (c) 2013 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BJYMPMovieScalingMode) {
    BJYMPMovieScalingModeNone,       // No scaling
    BJYMPMovieScalingModeAspectFit,  // Uniform scale until one dimension fits
    BJYMPMovieScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    BJYMPMovieScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds
};

typedef NS_ENUM(NSInteger, BJYMPMoviePlaybackState) {
    BJYMPMoviePlaybackStateStopped,
    BJYMPMoviePlaybackStatePlaying,
    BJYMPMoviePlaybackStatePaused,
    BJYMPMoviePlaybackStateInterrupted,
    BJYMPMoviePlaybackStateSeekingForward,
    BJYMPMoviePlaybackStateSeekingBackward
};

typedef NS_OPTIONS(NSUInteger, BJYMPMovieLoadState) {
    BJYMPMovieLoadStateUnknown        = 0,
    BJYMPMovieLoadStatePlayable       = 1 << 0,
    BJYMPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    BJYMPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
};

typedef NS_ENUM(NSInteger, BJYMPMovieFinishReason) {
    BJYMPMovieFinishReasonPlaybackEnded,
    BJYMPMovieFinishReasonPlaybackError,
    BJYMPMovieFinishReasonUserExited
};

// -----------------------------------------------------------------------------
// Thumbnails

typedef NS_ENUM(NSInteger, BJYMPMovieTimeOption) {
    BJYMPMovieTimeOptionNearestKeyFrame,
    BJYMPMovieTimeOptionExact
};

@protocol BJYMediaPlayback;

#pragma mark BJYMediaPlayback

@protocol BJYMediaPlayback <NSObject>

- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
- (void)shutdown;
- (void)setPauseInBackground:(BOOL)pause;

@property(nonatomic, readonly)  UIView *view;
@property(nonatomic)            NSTimeInterval currentPlaybackTime;
@property(nonatomic, readonly)  NSTimeInterval duration;
@property(nonatomic, readonly)  NSTimeInterval playableDuration;
@property(nonatomic, readonly)  NSInteger bufferingProgress;

@property(nonatomic, readonly)  BOOL isPreparedToPlay;
@property(nonatomic, readonly)  BJYMPMoviePlaybackState playbackState;
@property(nonatomic, readonly)  BJYMPMovieLoadState loadState;
@property(nonatomic, readonly) int isSeekBuffering;
@property(nonatomic, readonly) int isAudioSync;
@property(nonatomic, readonly) int isVideoSync;

@property(nonatomic, readonly) int64_t numberOfBytesTransferred;

@property(nonatomic, readonly) CGSize naturalSize;
@property(nonatomic) BJYMPMovieScalingMode scalingMode;
@property(nonatomic) BOOL shouldAutoplay;

@property (nonatomic) BOOL allowsMediaAirPlay;
@property (nonatomic) BOOL isDanmakuMediaAirPlay;
@property (nonatomic, readonly) BOOL airPlayMediaActive;

@property (nonatomic) float playbackRate;
@property (nonatomic) float playbackVolume;

- (UIImage *)thumbnailImageAtCurrentTime;

#pragma mark Notifications

#ifdef __cplusplus
#define BJY_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define BJY_EXTERN extern __attribute__((visibility ("default")))
#endif

// -----------------------------------------------------------------------------
//  MPMediaPlayback.h

// Posted when the prepared state changes of an object conforming to the MPMediaPlayback protocol changes.
// This supersedes MPMoviePlayerContentPreloadDidFinishNotification.
BJY_EXTERN NSString *const BJYMPMediaPlaybackIsPreparedToPlayDidChangeNotification;

// -----------------------------------------------------------------------------
//  MPMoviePlayerController.h
//  Movie Player Notifications

// Posted when the scaling mode changes.
BJY_EXTERN NSString* const BJYMPMoviePlayerScalingModeDidChangeNotification;

// Posted when movie playback ends or a user exits playback.
BJY_EXTERN NSString* const BJYMPMoviePlayerPlaybackDidFinishNotification;
BJY_EXTERN NSString* const BJYMPMoviePlayerPlaybackDidFinishReasonUserInfoKey; // NSNumber (BJYMPMovieFinishReason)

// Posted when the playback state changes, either programatically or by the user.
BJY_EXTERN NSString* const BJYMPMoviePlayerPlaybackStateDidChangeNotification;

// Posted when the network load state changes.
BJY_EXTERN NSString* const BJYMPMoviePlayerLoadStateDidChangeNotification;

// Posted when the movie player begins or ends playing video via AirPlay.
BJY_EXTERN NSString* const BJYMPMoviePlayerIsAirPlayVideoActiveDidChangeNotification;

// -----------------------------------------------------------------------------
// Movie Property Notifications

// Calling -prepareToPlay on the movie player will begin determining movie properties asynchronously.
// These notifications are posted when the associated movie property becomes available.
BJY_EXTERN NSString* const BJYMPMovieNaturalSizeAvailableNotification;

// -----------------------------------------------------------------------------
//  Extend Notifications

BJY_EXTERN NSString *const BJYMPMoviePlayerAudioOpenNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerVideoDecoderOpenNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerFirstVideoFrameRenderedNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerFirstAudioFrameRenderedNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerFirstAudioFrameDecodedNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerFirstVideoFrameDecodedNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerOpenInputNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerFindStreamInfoNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerComponentOpenNotification;

BJY_EXTERN NSString *const BJYMPMoviePlayerDidSeekCompleteNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerDidSeekCompleteTargetKey;
BJY_EXTERN NSString *const BJYMPMoviePlayerDidSeekCompleteErrorKey;
BJY_EXTERN NSString *const BJYMPMoviePlayerDidAccurateSeekCompleteCurPos;
BJY_EXTERN NSString *const BJYMPMoviePlayerAccurateSeekCompleteNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerSeekAudioStartNotification;
BJY_EXTERN NSString *const BJYMPMoviePlayerSeekVideoStartNotification;

BJY_EXTERN NSString *const BJYFFMoviePlayerDidShutdownNotification;

BJY_EXTERN NSString *const BJYMPMoviePlayerAudioSSRC;
BJY_EXTERN NSString *const BJYMPMoviePlayerAudioSample;

BJY_EXTERN NSString *const BJYMPMoviePlayerMonitorAppStateNotification;

@end

#pragma mark BJYMediaUrlOpenDelegate

// Must equal to the defination in ijkavformat/ijkavformat.h
typedef NS_ENUM(NSInteger, BJYMediaEvent) {

    // Notify Events
    BJYMediaEvent_WillHttpOpen         = 1,       // attr: url
    BJYMediaEvent_DidHttpOpen          = 2,       // attr: url, error, http_code
    BJYMediaEvent_WillHttpSeek         = 3,       // attr: url, offset
    BJYMediaEvent_DidHttpSeek          = 4,       // attr: url, offset, error, http_code
    // Control Message
    BJYMediaCtrl_WillTcpOpen           = 0x20001, // BJYMediaUrlOpenData: no args
    BJYMediaCtrl_DidTcpOpen            = 0x20002, // BJYMediaUrlOpenData: error, family, ip, port, fd
    BJYMediaCtrl_WillHttpOpen          = 0x20003, // BJYMediaUrlOpenData: url, segmentIndex, retryCounter
    BJYMediaCtrl_WillLiveOpen          = 0x20005, // BJYMediaUrlOpenData: url, retryCounter
    BJYMediaCtrl_WillConcatSegmentOpen = 0x20007, // BJYMediaUrlOpenData: url, segmentIndex, retryCounter
};

#define BJYMediaEventAttrKey_url            @"url"
#define BJYMediaEventAttrKey_host           @"host"
#define BJYMediaEventAttrKey_error          @"error"
#define BJYMediaEventAttrKey_time_of_event  @"time_of_event"
#define BJYMediaEventAttrKey_http_code      @"http_code"
#define BJYMediaEventAttrKey_offset         @"offset"
#define BJYMediaEventAttrKey_file_size      @"file_size"

// event of BJYMediaUrlOpenEvent_xxx
@interface BJYMediaUrlOpenData: NSObject

- (id)initWithUrl:(NSString *)url
            event:(BJYMediaEvent)event
     segmentIndex:(int)segmentIndex
     retryCounter:(int)retryCounter;

@property(nonatomic, readonly) BJYMediaEvent event;
@property(nonatomic, readonly) int segmentIndex;
@property(nonatomic, readonly) int retryCounter;

@property(nonatomic, retain) NSString *url;
@property(nonatomic, assign) int fd;
@property(nonatomic, strong) NSString *msg;
@property(nonatomic) int error; // set a negative value to indicate an error has occured.
@property(nonatomic, getter=isHandled)    BOOL handled;     // auto set to YES if url changed
@property(nonatomic, getter=isUrlChanged) BOOL urlChanged;  // auto set to YES by url changed

@end

@protocol BJYMediaUrlOpenDelegate <NSObject>

- (void)willOpenUrl:(BJYMediaUrlOpenData*) urlOpenData;

@end

@protocol BJYMediaNativeInvokeDelegate <NSObject>

- (int)invoke:(BJYMediaEvent)event attributes:(NSDictionary *)attributes;

@end
