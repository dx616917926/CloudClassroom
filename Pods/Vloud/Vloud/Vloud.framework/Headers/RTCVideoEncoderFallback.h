/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
#ifdef WEBRTC_H264_SIMULCAST

#import <Foundation/Foundation.h>

#import "RTCMacros.h"
#import "RTCVideoCodecInfo.h"
#import "RTCVideoEncoder.h"

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE(RTCVideoEncoderFallback) : NSObject

+ (id<RTC_OBJC_TYPE(RTCVideoEncoder)>)instanceWithFallback:(id<RTC_OBJC_TYPE(RTCVideoEncoder)>)fallback
                                 andPrimary:(id<RTC_OBJC_TYPE(RTCVideoEncoder)>)primary;

@end

#endif