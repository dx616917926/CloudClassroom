//
//  BJRTCSFUPublisher.h
//  BJRTCSDK
//
//  Created by Chengchao on 8/10/18.
//  Copyright © 2018 xinyapeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJRTCSDK/BJRTCVideoPlayer.h>
#import <BJRTCSDK/BJRTCDefines.h>

typedef void (^BJRTCSFUPublisherSuccessBlock)(UIImage *image);
typedef void (^BJRTCSFUPublisherFailureBlock)(NSError *error);

/// SFU发送器
@interface BJRTCSFUPublisher : NSObject

/// 所在 session 的 sessionID
@property (nonatomic, copy) NSString *sessionID;
/// 推流的 userID
@property (nonatomic, copy) NSString *userID;

@property (nonatomic, readonly) BJRTCSFUPublisherState state;

@property (nonatomic, readonly) BJRTCSupportedCodec codec;

///
@property (nonatomic, strong) BJRTCVideoPlayer *videoPlayer;
///
@property (nonatomic, readonly) UIView *view;
///
@property (nonatomic, assign, readonly) BOOL isPlaying;

/// 切换摄像头
- (void)switchCamera;

/// 关闭摄像头
- (void)stopCapture;

/// 开启摄像头
- (void)startCapture;

/// 当前摄像头是否为前置
- (BOOL)isCameFacingFront;

/// 摄像头是否运行
- (BOOL)isCameraRunning;

/// 动态设置本地流分辨率
- (void)setLocalResolutionWidth:(int)width height:(int)height fps:(int)fps;
- (void)setLocalResolutionWidth:(int)width height:(int)height;

/// 动态设置本地推流码率范围
- (void)setMinBandwidth:(NSNumber *)minBandwidth maxBandwidth:(NSNumber *)maxBandwidth;

/// 禁用音频
- (void)disableAudio;

/// 禁用视频
- (void)disableVideo;

/// 打开音频
- (void)enableAudio;

/// 打开视频
- (void)enableVideo;

/// 切换音频
- (void)toggleAudio;

/// 切换视频
- (void)toggleVideo;

/// 流是否含有音频
- (BOOL)hasAudio;

/// 流是否含有视频
- (BOOL)hasVideo;

///
- (CGSize)videoDimensions;

/// 开始播放渲染
- (void)play;
///
- (void)stop;

- (void)currentFrameWithSuccess:(BJRTCSFUPublisherSuccessBlock)success failure:(BJRTCSFUPublisherFailureBlock)failure;

///
- (void)unpublish;

///
- (void)close;

/// 设置卡顿相关数组元素总数阈值
- (void)adaptBlockArrCountThreshold:(double)blockArrCountThreshold;
/// 视频丢包率阈值
- (void)adaptVideoLostThreshold:(double)videoLostThreshold;
/// 音频丢包率阈值
- (void)adaptAudioLostThreshold:(double)audioLostThreshold;
/// 发送视频帧率阈值
- (void)adaptSentVideoFrameThreshold:(double)sentVideoFrameThreshold;

- (void)videoFlipType:(int)type;

/**
 * 推流宽高比控制
 * @param orientation  0:自动 1:竖屏  2:横屏
 */
- (void)setOrientation:(int)orientation;

@end
