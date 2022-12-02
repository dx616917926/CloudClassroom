//
//  BJYRTCEngine.h
//  BJYRTCEngine
//
//  Created by bjy on 2018/11/1.
//  Copyright © 2018 BaiJiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BLive/BLive.h>

#import "BJYPlayerView.h"
#import "BJYRoomOptions.h"
#import "BJYRTCEngineDefines.h"
#import "BJYRTCEngineDelegate.h"
#import "BJYRTCKeys.h"
#import "BJYRTCLog.h"
#import "BJYRTCMessage.h"
#import "BJYRTCAdapter.h"
#import "BJYRTMPMediaView.h"

NS_ASSUME_NONNULL_BEGIN

//! Project version number for BJYRTCEngine.
FOUNDATION_EXPORT double BJYRTCEngineVersionNumber;

//! Project version string for BJYRTCEngine.
FOUNDATION_EXPORT const unsigned char BJYRTCEngineVersionString[];

@interface BJYRTCEngine : NSObject

/// 适配层引擎类型
@property (nonatomic, readonly) BJYEngineType engineType;
/// 适配层引擎代理
@property (nonatomic, weak, nullable) id <BJYRTCEngineDelegate> engineDelegate;
/// 视频分辨率
@property (nonatomic, readonly) BJYVideoResolution videoResolution;

/// 房间配置项
@property (nonatomic, strong) BJYRoomOptions *roomOptions;

/// 进入房间 目前这个还透传不了，差很多字段 eg. RoomID UserID engineType 还有一些功能性的字段
// - (void)joinRoomWithWebRTCInfo:(NSDictionary *)webRTCInfo;

/// 进入房间
- (void)joinRoomWithOptions:(BJYRoomOptions *)options;

/// 重连某个sessionType 只有在房间里面调用才有用
- (void)bjy_reloadSessionType:(BJYRTCSessionType)sessionType;

/// 离开房间
- (void)leaveRoom;

/// 获取playerview视频视图 userId 用户信息  userid 统一使用NSInteger类型
- (BJYPlayerView *)getPlayerViewWithUserId:(NSString *)userId at:(BJYRTCSessionType)sessionType;

/// 开启本地预览 针对主摄像头
- (void)startPreview;

/// 关闭本地预览 针对主摄像头
- (void)stopPreview;

/// 推流 publishAudio:YES video:YES
- (void)publish;
/// 推流 publishAudio:YES video:YES  isChangeArea:NO代表不主动切上行节点，YES代表主动切  只针对百家云
- (void)bjy_publishWithChangeArea:(BOOL)isChangeArea;
/// 推流 针对主摄像头
- (void)publishAudio:(BOOL)isAudio video:(BOOL)isVideo;
/// 推流 针对主摄像头 isChangeArea:NO代表不主动切上行节点，YES代表主动切  只针对百家云
- (void)bjy_publishAudio:(BOOL)isAudio video:(BOOL)isVideo changeArea:(BOOL)isChangeArea;
/// 推流 针对主摄像头 degradationPreference:设置webrtc内部帧率分辨率调节模式
- (void)bjy_publishAudio:(BOOL)isAudio video:(BOOL)isVideo changeArea:(BOOL)isChangeArea degradationPreference:(BJYDegradationPreference)degradationPreference;

/// 取消推流  针对主摄像头
- (void)unpublish;

/// 订阅 userId 用户信息
- (void)subscribeUserId:(NSString *)userId at:(BJYRTCSessionType)sessionType;

/// 取消订阅 userId 用户信息
- (void)unsubscribeUserId:(NSString *)userId at:(BJYRTCSessionType)sessionType;

/// 本地音频流是否推出去 针对主摄像头 YES代表本地流音频推出去  NO代表本地流音频没有推出去
- (BOOL)isAudioAttached;

/// 本地视频流是否推出去 针对主摄像头 YES代表本地流视频推出去  NO代表本地流视频没有推出去
- (BOOL)isVideoAttached;

/// 本地流是否静音 针对主摄像头 isMute YES代表本地流不推音频   NO代表本地流推音频
- (void)muteLocalAudio:(BOOL)isMute;

/// 本地流是否推黑帧 针对主摄像头 isMute YES代表推黑帧   NO代表推黑帧
- (void)muteLocalVideo:(BOOL)isMute;

/// 是否启用听筒 针对主摄像头（扬声器 isEnable YES代表启用听筒   NO代表启用扬声器
- (void)enableSpeakerphone:(BOOL)isEnable;

/// 切换前后摄像头 针对主摄像头
- (void)switchCamera;

/// 是否推流成功 针对主摄像头 YES表示推流成功 NO表示推流失败
- (BOOL)isPublished;

/// 是否禁用远端音频流 userId 用户信息 isMute YES代表禁用远端音频流   NO代表接受远端音频流
- (void)muteRemoteAudioWithUserId:(NSString *)userId isMute:(BOOL)isMute at:(BJYRTCSessionType)sessionType;

/// 是否禁用远端视频流 userId 用户信息 isMute YES代表禁用远端视频流   NO代表接受远端视频流
- (void)muteRemoteVideoWithUserId:(NSString *)userId isMute:(BOOL)isMute at:(BJYRTCSessionType)sessionType;

/// 禁掉所有远端音频流 isMute YES代表禁用所有远端音频   NO代表接受所有远端音频
- (void)muteAllRemoteAudio:(BOOL)isMute at:(BJYRTCSessionType)sessionType;

/// 禁用所有远端视频流 isMute YES代表禁用所有远端视频   NO代表接受所有远端视频
- (void)muteAllRemoteVideo:(BOOL)isMute at:(BJYRTCSessionType)sessionType;

/// 获得当前摄像头方向 针对主摄像头
- (BJYCameraFace)cameraFacing;

/// 推流后动态设置推流码率 码率范围：0.75 * bandwidth ~ 1.25 * bandwidth
//- (void)bjy_setBandwidth:(NSNumber *)bandwidth;

/// 推流后动态设置推流码率 最小码率  最大码率
//- (void)bjy_setBandwidthWithMin:(NSNumber *)min_bitrate max:(NSNumber *)max_bitrate;

/// 推流后动态切换推流分辨率
- (void)bjy_switchResolution:(BJYVideoResolution)videoResolution;

/// 设置推流方向
- (void)bjy_setOrientation:(BJYRTCOrientation)orientation;

/// 动态切节点, 只能在进房间后调用
- (void)bjy_switchMediaServerWithArea:(NSString *)area node:(NSString *)node;

- (void)bjy_switchMediaServer:(NSString *)mediaServer;

/// 查询服务器列表
- (NSDictionary *)bjy_mediaServerList:(BJYRTCSessionType)sessionType;

/// 查询上行fps
- (NSInteger)bjy_pubFps;

/// 设置卡顿阈值相关参数
- (void)adaptBlockThreshold:(BlocakThreshold)blockThreshold at:(BJYRTCSessionType)sessionType;

/// 设置本地推流分辨率(进房间后设置有效,宽高设置合理会选择最接近的分辨率)
- (BJYVideoResolution)adjustResolutionWidth:(NSInteger)width height:(NSInteger)height;

/// 获取底层分辨率-码率-帧率配置字典(对声网无效)
- (NSDictionary *)getVideoResolutionDic;

/// 渲染翻转模式
- (void)renderFlipType:(BJYVideoFlipType)type userID:(NSString *)userID at:(BJYRTCSessionType)sessionType;

/// 推流翻转模式
- (void)videoFlipType:(BJYVideoFlipType)type;

/// 设置小流level
- (void)setSmallVideoLevel:(BJYSmallVideoLevel)level;

/// 开关视频双流模式(进房间后，推流前设置)
- (void)enableDualStreamMode:(BOOL)enabled;

/// 设置订阅的视频流类型(支持进房前设置)
- (void)setRemoteVideoStream:(NSString *)userID type:(BJYVideoStreamType)streamType at:(BJYRTCSessionType)sessionType;

/// 设置订阅远端流的默认类型(支持进房前设置)
- (void)setRemoteDefaultVideoStreamType:(BJYVideoStreamType)streamType;

/// 切换音频通道 (进房间后调用有效)
- (BOOL)switchAudioTransport2Media:(BOOL)isMediaTransport;

/// 切换音频质量
- (void)setLocalAudioQuality:(BJYAudioQuality)audioQuality;

/// 调用实验性 API 接口
- (void)callExperimentalAPI:(NSString *)jsonStr;

#pragma mark - 美颜

/// 设置磨皮级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。 仅BRTC底层有效
- (void)setBeautyLevel:(float)level;

/// 设置美白级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。 仅BRTC底层有效
- (void)setWhitenessLevel:(float)level;

#pragma mark - 合流

/// 进入 BLive 的观众角色，如果已经是主播角色，将会切换成观众
- (void)enterBLiveRoomWithOptions:(BJYRoomOptions *)options;

/// 播放合流，成功播放合流会回调 view，合流的视图更新等都会回调
- (void)playMixStream:(BLivePlayStreamInfo *)info completion:(void (^_Nullable)(BLiveView * _Nullable view))completion;

/// 离开 BLive 房间，由于 BLive 被要求使用单例，因此需要在退出时释放
- (void)leaveBLive;

@end

NS_ASSUME_NONNULL_END
