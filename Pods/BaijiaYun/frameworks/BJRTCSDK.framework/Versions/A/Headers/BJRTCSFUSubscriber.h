//
//  BJRTCSFUSubscriber.h
//  BJRTCSDK
//
//  Created by Chengchao on 8/14/18.
//  Copyright © 2018 xinyapeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJRTCSDK/BJRTCVideoPlayer.h>
#import <BJRTCSDK/BJRTCDefines.h>

@interface BJRTCSFUSubscriber : NSObject

/// 所在 session 的 sessionID
@property (nonatomic, copy) NSString *sessionID;
/// 订阅的 userID
@property (nonatomic, copy) NSString *userID;
///
@property (nonatomic, copy) NSString *userNumber;
///
@property (nonatomic, strong) BJRTCVideoPlayer *videoPlayer;
///
@property (nonatomic, strong) UIView *view;
///
@property (nonatomic, assign) BOOL isAutoSwitch;
///
@property (nonatomic, assign, readonly) BOOL isPlaying;

/// 流是否含有音频
- (BOOL)hasAudio;
/// 流是否含有视频
- (BOOL)hasVideo;

/// 获得视频轨道状态
- (BOOL)videoIsLive;
/// 获得音频轨道状态
- (BOOL)audioIsLive;
/// 播放音视频
- (void)play;
///
- (void)stop;

- (void)close;

/// 设置卡顿相关数组元素总数阈值
- (void)adaptBlockArrCountThreshold:(double)blockArrCountThreshold;
/// 视频丢包率阈值
- (void)adaptVideoLostThreshold:(double)videoLostThreshold;
/// 音频丢包率阈值
- (void)adaptAudioLostThreshold:(double)audioLostThreshold;
/// 接收视频帧率阈值
- (void)adaptRecvVideoFrameThreshold:(double)recvVideoFrameThreshold;

/** 设置使用帧间隔判断拉流视频卡顿所需参数
 @param recvStreamFrameDelay 卡顿帧间隔
 @param numOnRecvStreamBlockSwitch 卡顿次数
 @param recvFrameDelayArrCount 卡顿数组大小
 */
- (void)setupRecvStreamFrameDelay:(NSInteger)recvStreamFrameDelay numOnRecvStreamBlockSwitch:(NSInteger)numOnRecvStreamBlockSwitch recvFrameDelayArrCount:(NSInteger)recvFrameDelayArrCount;

@end
