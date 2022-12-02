//
//  BJYRTCEngineDefines.h
//  BJYRTCEngine
//
//  Created by bjy on 2018/11/5.
//  Copyright © 2018 BaiJiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef BJYRTCEngineDefines_h
#define BJYRTCEngineDefines_h

// 多家引擎
typedef NS_ENUM(NSInteger, BJYEngineType) {
    BJYEngineType_AVSDK            = 0,     //AVSDK,目前适配层不支持
    BJYEngineType_BJRTC            = 1,     //百家云
    BJYEngineType_AGORA            = 2,     //声网
    BJYEngineType_TRTC             = 3,     //腾讯云TRTC
    BJYEngineType_BRTC_TRTC        = 4,     //BRTC-TRTC
    BJYEngineType_BRTC_VLOUD       = 5,     //BRTC-VLOUD
};

typedef NS_ENUM(NSUInteger, BJYRTCSessionType) {
    BJYRTCSessionType_Camera_Main,
    BJYRTCSessionType_Camera_Extra,
    BJYRTCSessionType_ScreenSharing_Main,
    BJYRTCSessionType_ScreenSharing_Extra,
    BJYRTCSessionType_File_Main,
    BJYRTCSessionType_File_Extra,
};

typedef NS_ENUM(NSUInteger, BJYRTCOrientation) {
    /** 自动
     */
    BJYRTCOrientation_Auto = 0,
    /** 竖屏采集
     */
    BJYRTCOrientation_Portrait = 1,
    /** 横屏采集
     */
    BJYRTCOrientation_Landscape = 2,
};

/**
 *  当前 iOS SDK 支持的编码
 */
typedef NS_ENUM(NSUInteger, BJYVideoSupportedCodec) {
    /**
     *  vp8 (默认)
     */
    BJY_CODEC_VP8 = 0,
    /**
     *  h264
     */
    BJY_CODEC_H264 = 1,
};

/**
 * 视频分辨率
 */
typedef NS_ENUM(NSInteger, BJYVideoResolution) {
    BJYVideoResolution_320x180     = 0,
    BJYVideoResolution_320x240     = 1,
    BJYVideoResolution_480x360     = 2,
    BJYVideoResolution_640x360     = 3,
    BJYVideoResolution_640x480     = 4,
    BJYVideoResolution_1280x720    = 5,
    BJYVideoResolution_1920x1080   = 6,
    BJYVideoResolution_UnKnow      = 100,
};

/**
 * 摄像头方向
 */
typedef NS_ENUM(NSInteger, BJYCameraFace) {
    BJYCameraFacing_FRONT,  //前置摄像头
    BJYCameraFacing_BACK    //后置摄像头
};

/**
 * 视频方向
 */
typedef NS_ENUM(NSUInteger, BJYAVCaptureVideoOrientation) {
    BJYAVCaptureVideoOrientation_Portrait           = 1,
    BJYAVCaptureVideoOrientation_PortraitUpsideDown = 2,
    BJYAVCaptureVideoOrientation_LandscapeRight     = 3,
    BJYAVCaptureVideoOrientation_LandscapeLeft      = 4,
};

typedef NS_ENUM(NSUInteger, BJYCapturePreviewMode) {
    BJYCapturePreviewMode_Adaptative, // 自动
    BJYCapturePreviewMode_Landscape, // 横屏，可能会裁剪
    BJYCapturePreviewMode_Portrait, // 竖屏，可能会裁剪
};

/**
 * 用户下行网络质量
 */
typedef NS_ENUM(NSInteger, BJYRTCEngineNetworkQuality) {
    BJYRTCEngineStatus_NetworkQualityUnknown    = 0,   //网络质量未知
    BJYRTCEngineStatus_NetworkQualityExcellent  = 1,   //网络质量极好
    BJYRTCEngineStatus_NetworkQualityGood       = 2,   //用户主观感觉和 excellent 差不多，但码率可能略低于 excellent
    BJYRTCEngineStatus_NetworkQualityPoor       = 3,   //用户主观感受有瑕疵但不影响沟通
    BJYRTCEngineStatus_NetworkQualityBad        = 4,   //勉强能沟通但不顺畅
    BJYRTCEngineStatus_NetworkQualityVBad       = 5,   //网络质量非常差，基本不能沟通
    BJYRTCEngineStatus_NetworkQualityDown       = 6    //完全无法沟通
};

/**
 * 卡顿类型
 */
typedef NS_ENUM(NSInteger, BJYBlockType) {
    BJYBlockType_Up    = 0, // 上行
    BJYBlockType_Down  = 1 // 下行
};

/**
 *  卡顿阈值相关参数
 */
typedef struct BlocakThreshold {
    unsigned int blockArrCountThreshold; // 卡顿相关数组元素总个数阈值
    unsigned int videoLostThreshold; // 视频丢包率判断卡顿阈值
    unsigned int audioLostThreshold; // 音频丢包率判断卡顿阈值
    unsigned int sentFrameThreshold; // 发送帧率判断卡顿阈值
    unsigned int renderFrameThreshold; // 渲染帧率判断卡顿阈值
} BlocakThreshold;

/**
 * 双流类型
 */
typedef NS_ENUM(NSUInteger, BJYVideoStreamType) {
    /**
     *  未知流类型
     */
    BJYVideoStreamType_Unknow = 0,
    /**
     *  大流
     */
    BJYVideoStreamType_High = 1,
    /**
     *  小流
     */
    BJYVideoStreamType_Low = 2,
};

/**
 * webrtc内部分辨率帧率调节模式
 * 仅针对百家云
 */
typedef NS_ENUM(NSUInteger, BJYDegradationPreference) {
    BJYDegradationPreference_Force_Disabled, // 关闭
    BJYDegradationPreference_Force_Maintain_Framerate, // 保帧率
    BJYDegradationPreference_Force_Maintain_Resolution, // 保分辨率
    BJYDegradationPreference_Force_Balanced, // 设置这个会走webrtc自己的判断逻辑
};

/**
 * 翻转类型
 */
typedef NS_ENUM(NSUInteger, BJYVideoFlipType) {
    BJYVideoFlipType_Normal = 0, // 正常
    BJYVideoFlipType_Horizontal = 1, // 水平翻转
    BJYVideoFlipType_Vertical = 2, // 垂直翻转
    BJYVideoFlipType_Vertical_Horizontal = 3, // 垂直镜像翻转
};

/**
 * 小流level
 */
typedef NS_ENUM(NSUInteger, BJYSmallVideoLevel) {
    BJYSmallVideoLevel_320_240 = 0,
    BJYSmallVideoLevel_640_480 = 1,
    BJYSmallVideoLevel_1280_720 = 2,
    BJYSmallVideoLevel_1920_1080 = 3,
    BJYSmallVideoLevel_480_360 = 4, //与安卓保持同步
};

/**
 * 采集音频质量
 */
typedef NS_ENUM(NSInteger, BJYAudioQuality) {
    ///人声模式：采样率：16k；单声道；编码码率：16kbps；具备几个模式中最强的网络抗性，适合语音通话为主的场景，比如在线会议，语音通话等。
    BJYAudioQualitySpeech  = 1,

    ///默认模式：采样率：48k；单声道；编码码率：50kbps；介于 Speech 和 Music 之间的档位，SDK 默认档位，推荐选择。
    BJYAudioQualityDefault  = 2,

    ///音乐模式：采样率：48k；全频带立体声；编码码率：128kbps；适合需要高保真传输音乐的场景，比如在线K歌、音乐直播等。
    BJYAudioQualityMusic  = 3,
};

#endif /* BJYRTCEngineDefines_h */
