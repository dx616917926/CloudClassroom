//
//  BJYRTCKeys.h
//  BJYRTCEngine
//
//  Created by lw0717 on 2019/3/22.
//  Copyright © 2019年 BaiJiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const BJYRTCEngineVersion;

// key about qosDic qos-质量参数
FOUNDATION_EXPORT NSString *const BJYQosVideoBandwidthKey;
FOUNDATION_EXPORT NSString *const BJYQosVideoLossRateKey;
FOUNDATION_EXPORT NSString *const BJYQosVideoBufferLengthKey;
FOUNDATION_EXPORT NSString *const BJYQosVideoInterframeDelayMax;
FOUNDATION_EXPORT NSString *const BJYQosAudioBandwidthKey;
FOUNDATION_EXPORT NSString *const BJYQosAudioLossRateKey;
FOUNDATION_EXPORT NSString *const BJYQosAudioBufferLengthKey;

// 后端配置及本地存储分辨率对应key值
FOUNDATION_EXPORT NSString *const BJYVideoResolution_320_180_key;
FOUNDATION_EXPORT NSString *const BJYVideoResolution_320_240_key;
FOUNDATION_EXPORT NSString *const BJYVideoResolution_480_360_key;
FOUNDATION_EXPORT NSString *const BJYVideoResolution_640_360_key;
FOUNDATION_EXPORT NSString *const BJYVideoResolution_640_480_key;
FOUNDATION_EXPORT NSString *const BJYVideoResolution_1280_720_key;
FOUNDATION_EXPORT NSString *const BJYVideoResolution_1920_1080_key;

// sessionType标识
FOUNDATION_EXPORT NSString *const BJYSessionType_Camera_Main_key;
FOUNDATION_EXPORT NSString *const BJYSessionType_Camera_Extra_key;
FOUNDATION_EXPORT NSString *const BJYSessionType_ScreenSharing_Main_key;
FOUNDATION_EXPORT NSString *const BJYSessionType_ScreenSharing_Extra_key;
FOUNDATION_EXPORT NSString *const BJYSessionType_File_Main_key;
FOUNDATION_EXPORT NSString *const BJYSessionType_File_Extra_key;
