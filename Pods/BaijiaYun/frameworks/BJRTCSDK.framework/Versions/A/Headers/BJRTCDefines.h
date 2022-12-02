//
//  BJRTCDefines.h
//  RTCatDemo
//
//  Created by lw0717 on 2019/8/13.
//  Copyright © 2019 BJY. All rights reserved.
//

#ifndef BJRTCDefines_h
#define BJRTCDefines_h

#import <Foundation/Foundation.h>

static const int BJRTC_DEFAULT_VIDEO_HEIGHT = 240;
static const int BJRTC_DEFAULT_VIDEO_WIDTH = 320;
static const int BJRTC_DEFAULT_VIDEO_FPS = 15;
static const int BJRTC_MAX_VIDEO_HEIGHT = 1080;
static const int BJRTC_MAX_VIDEO_WIDTH = 1920;
static const int BJRTC_MAX_VIDEO_FPS = 30;

/// 摄像头
typedef NS_ENUM(NSUInteger, BJRTCCameraFacing) {
    /// 前置摄像头
    BJRTC_CAMERA_FRONT,
    /// 后置摄像头
    BJRTC_CAMERA_BACK
};

///
typedef NS_ENUM(NSUInteger, BJRTCSFUPublisherState) {
    BJRTCSFUPublisherState_Unpublish,
    BJRTCSFUPublisherState_WaitToPublishing,
    BJRTCSFUPublisherState_Publishing,
};

/// 当前支持的编码
typedef NS_ENUM(NSUInteger, BJRTCSupportedCodec) {
    /// vp8 (默认)
    BJRTC_CODEC_VP8     = 0,
    /// h264
    BJRTC_CODEC_H264    = 1,
};

/// Session类型
typedef NS_ENUM(NSUInteger, BJRTCSessionType) {
    /// publish
    BJRTC_SESSION_TYPE_PUBLISH      = 0,
    /// subscribe
    BJRTC_SESSION_TYPE_SUBSCRIBE    = 1,
};

/**
 * webrtc内部分辨率帧率调节模式
 */
typedef NS_ENUM(NSUInteger, BJRTCDegradationPreference) {
    BJRTC_DegradationPreference_Force_Disabled, // 关闭
    BJRTC_DegradationPreference_Force_Maintain_Framerate, // 保帧率
    BJRTC_DegradationPreference_Force_Maintain_Resolution, // 保分辨率
    BJRTC_DegradationPreference_Force_Balanced, // 设置这个会走webrtc自己的判断逻辑
};

/**
 * 系统音量类型
 */
typedef NS_ENUM(NSUInteger, BJRTCSystemVolumeType) {
    BJRTCSystemVolumeType_VOIP              = 0,
    BJRTCSystemVolumeType_VOIP_No_Mic       = 1,
    BJRTCSystemVolumeType_Media_Has_Mic     = 2,
    BJRTCSystemVolumeType_Media_No_Mic      = 3,
};

#endif /* BJRTCDefines_h */
