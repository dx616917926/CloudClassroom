/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import "RTCMacros.h"
#import "RTCMediaSource.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE(RTCAudioSource) : RTC_OBJC_TYPE(RTCMediaSource)

- (instancetype)init NS_UNAVAILABLE;

// Sets the volume for the RTCMediaSource. |volume| is a gain value in the range
// [0, 10].
// Temporary fix to be able to modify volume of remote audio tracks.
// TODO(kthelgason): Property stays here temporarily until a proper volume-api
// is available on the surface exposed by webrtc.
@property(nonatomic, assign) double volume;

@end

#pragma mark -

@protocol RTC_OBJC_TYPE(RTCAudioPlayerSourceDelegate) <NSObject>

- (int)getPCMDataWithCallback:(void(^)(int16_t* data, size_t samples_per_channel, int sample_rate_hz, size_t num_channels))callback;

@end

@interface RTC_OBJC_TYPE(RTCAudioPlayerSource) : NSObject

@property (nonatomic, weak) id<RTC_OBJC_TYPE(RTCAudioPlayerSourceDelegate)> delegate;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END