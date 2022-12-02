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

#import "RTCDtmfSender.h"
#import "RTCMacros.h"
#import "RTCMediaStreamTrack.h"
#import "RTCRtpParameters.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * webrtc码率帧率调节模式枚举值
 */
typedef NS_ENUM(NSInteger, BJYRTCDegradationPreference) {
    BJYRTCDegradationPreference_Force_Disabled,
    BJYRTCDegradationPreference_Force_Maintain_Framerate,
    BJYRTCDegradationPreference_Force_Maintain_Resolution,
    BJYRTCDegradationPreference_Force_Balanced, // 设置这个会走webrtc自己的判断逻辑
};

RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE(RTCRtpSender)<NSObject>

/** A unique identifier for this sender. */
@property(nonatomic, readonly) NSString *senderId;

/** The currently active RTCRtpParameters, as defined in
 *  https://www.w3.org/TR/webrtc/#idl-def-RTCRtpParameters.
 */
@property(nonatomic, copy) RTC_OBJC_TYPE(RTCRtpParameters) *parameters;

/** The RTCMediaStreamTrack associated with the sender.
 *  Note: reading this property returns a new instance of
 *  RTCMediaStreamTrack. Use isEqual: instead of == to compare
 *  RTCMediaStreamTrack instances.
 */
@property(nonatomic, copy, nullable) RTC_OBJC_TYPE(RTCMediaStreamTrack) *track;

/** The RTCDtmfSender accociated with the RTP sender. */
@property(nonatomic, readonly, nullable) id<RTC_OBJC_TYPE(RTCDtmfSender)> dtmfSender;

@end

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE(RTCRtpSender) : NSObject <RTC_OBJC_TYPE(RTCRtpSender)>

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)adjustDegradationPreference:(BJYRTCDegradationPreference)preference;

@end

NS_ASSUME_NONNULL_END
