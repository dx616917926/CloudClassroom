//
//  BJYRTCAdapter.h
//  BJYRTCEngine
//
//  Created by bjy on 2018/11/7.
//  Copyright © 2018 BaiJiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLive/BLive.h>
#import <AVFoundation/AVFoundation.h>
#import "BJYPlayerView.h"
#import "BJYRTCEngineDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class BJYRoomOptions;

@interface BJYRTCAdapter : NSObject

@property (nonatomic, readonly) BJYRoomOptions *roomOptions;

- (void)updateWithOptions:(BJYRoomOptions *)roomOptions sessionType:(BJYRTCSessionType)sessionType;

#pragma mark ------------- Project Func Start -------------
///
- (void)setEngineDelegate:(id<BJYRTCEngineDelegate>)engineDelegate;
- (id<BJYRTCEngineDelegate>)engineDelegate;

/// 视频分辨率
- (BJYVideoResolution)videoResolution;
///初始化时本地视频分辨率时使用
- (void)setVideoResolution:(BJYVideoResolution)videoResolution;

- (BOOL)facingBack;
- (void)setFacingBack:(BOOL)facingBack;

/// simulcast开关
- (void)setSimulcastSwitch:(BOOL)simulcastSwitch;
- (BOOL)simulcastSwitch;

/// 支持的视频编码
- (void)setCodec:(BJYVideoSupportedCodec)codec;
- (BJYVideoSupportedCodec)codec;

- (void)setRtcEngine:(BJYRTCEngine *)rtcEngine;

- (void)setRoomOptions:(BJYRoomOptions *)roomOptions;

#pragma mark ------------- Project Func End ---------------

#pragma mark ------------- Public Func Start --------------

/// 进入房间
- (void)joinRoom;

/// 获取playerview
- (BJYPlayerView *)getPlayerViewWithUserId:(NSString *)userId  sessionType:(BJYRTCSessionType)sessionType;

/// 开启本地预览
- (void)startPreview;

/// 关闭本地预览
- (void)stopPreview;

/// 离开房间
- (void)leaveRoom;

/// 推流
- (void)publish;
- (void)bjy_publishWithChangeArea:(BOOL)isChangeArea;
- (void)publishAudio:(BOOL)isAudio video:(BOOL)isVideo;
- (void)bjy_publishAudio:(BOOL)isAudio video:(BOOL)isVideo changeArea:(BOOL)isChangeArea;
- (void)bjy_publishAudio:(BOOL)isAudio video:(BOOL)isVideo changeArea:(BOOL)isChangeArea degradationPreference:(BJYDegradationPreference)degradationPreference;

/// 取消推流
- (void)unpublish;

/// 订阅
- (void)subscribeUserId:(NSString *)userId sessionType:(BJYRTCSessionType)sessionType;

/// 取消订阅
- (void)unsubscribeUserId:(NSString *)userId sessionType:(BJYRTCSessionType)sessionType;

/// 音频流是否推出去
- (BOOL)isAudioAttached;

/// 视频流是否推出去
- (BOOL)isVideoAttached;

/// 本地流是否静音
- (void)muteLocalAudio:(BOOL)isMute;

/// 本地流是否推黑帧
- (void)muteLocalVideo:(BOOL)isMute;

/// 是否启用听筒（扬声器）
- (void)enableSpeakerphone:(BOOL)isEnable;

/// 切换前后摄像头
- (void)switchCamera;

/// 是否推流成功
- (BOOL)isPublished;

/// 是否禁用远端音频流
- (void)muteRemoteAudioWithUserId:(NSString *)userId isMute:(BOOL)isMute sessionType:(BJYRTCSessionType)sessionType;

/// 是否禁用远端视频流
- (void)muteRemoteVideoWithUserId:(NSString *)userId isMute:(BOOL)isMute sessionType:(BJYRTCSessionType)sessionType;

/// 禁掉所有远端音频流
- (void)muteAllRemoteAudio:(BOOL)isMute sessionType:(BJYRTCSessionType)sessionType;

/// 禁用所有远端视频流
- (void)muteAllRemoteVideo:(BOOL)isMute sessionType:(BJYRTCSessionType)sessionType;

/// 获得当前摄像头方向
- (BJYCameraFace)cameraFacing;

// 切换本地流的分辨率
- (void)switchResolution:(BJYVideoResolution)videoResolution;

///
- (void)setCapturePreviewMode:(BJYCapturePreviewMode)capturePreviewMode;

/// 设置推流码率 最小码率 最大码率
- (void)setBandwidthWithMin:(NSNumber *)min_bitrate max:(NSNumber *)max_bitrate;

// 视频横竖屏采集模式
@property (nonatomic, assign) BJYRTCOrientation pubOrientationMode;
- (void)setOrientation:(BJYRTCOrientation)orientation;

/// 动态切节点
- (void)switchMediaServerWithArea:(NSString *)area node:(NSString *)node;
- (void)switchMediaServer:(NSString *)mediaServer;

///
- (void)firstFrameRenderedWithSessionType:(BJYRTCSessionType)sessionType userID:(NSString *)userID;

/// 获取推拉流服务器列表
- (NSDictionary *)mediaServerList:(BJYRTCSessionType)sessionType;

/// 查询上行fps
- (NSInteger)bjy_pubFps;

/// 设置卡顿阈值相关参数
- (void)adaptBlockThreshold:(BlocakThreshold)blockThreshold at:(BJYRTCSessionType)sessionType;

/// 使用宽高设置本地推流分辨率
- (BJYVideoResolution)adjustResolutionWidth:(NSInteger)width height:(NSInteger)height;

/// 获取底层分辨率-码率-帧率配置字典(对声网无效)
- (NSDictionary *)getVideoResolutionDic;

- (void)renderFlipType:(BJYVideoFlipType)type userID:(NSString *)userID at:(BJYRTCSessionType)sessionType;

- (void)videoFlipType:(BJYVideoFlipType)type;

/// 设置小流level
- (void)setSmallVideoLevel:(BJYSmallVideoLevel)level;

/// 开关视频双流模式 (YES: 双流模式 NO: 单流模式（默认）)
- (void)enableDualStreamMode:(BOOL)enabled;

/// 设置订阅的视频流类型
- (void)setRemoteVideoStream:(NSString *)userID type:(BJYVideoStreamType)streamType at:(BJYRTCSessionType)sessionType;

/// 设置订阅远端流的默认类型
- (void)setRemoteDefaultVideoStreamType:(BJYVideoStreamType)streamType;

/// 切换音频通道
- (BOOL)switchAudioTransport2Media:(BOOL)isMediaTransport;

/// 设置音频采集质量
- (void)setLocalAudioQuality:(BJYAudioQuality)audioQuality;

/// 调用实验性 API 接口
- (void)callExperimentalAPI:(NSString *)jsonStr;

#pragma mark - 美颜

/// 设置磨皮级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
- (void)setBeautyLevel:(float)level;

/// 设置美白级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显
- (void)setWhitenessLevel:(float)level;

#pragma mark ------------- Public Func End ----------------

#pragma mark - 合流

@property (nonatomic) BJYEngineType engineType;
- (void)enterBLiveRoom;
- (void)playMixStream:(BLivePlayStreamInfo *)info completion:(void (^_Nullable)(BLiveView * _Nullable view))completion;

#pragma mark - base

- (NSString *)sessionIDWithSessionType:(BJYRTCSessionType)sessionType;
- (NSString *)getIdentificationWithUserID:(NSString *)userID sessionID:(NSString *)sessionID;
- (NSArray<NSString *> *)componentsSeparatedByIdentification:(NSString *)identification;
@end

NS_ASSUME_NONNULL_END
