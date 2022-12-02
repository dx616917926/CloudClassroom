//
//  BJLMediaVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-17.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLMediaUser.h"

FOUNDATION_EXPORT NSString *_Nonnull const BJYQosDicVideoBandwidthKey;
FOUNDATION_EXPORT NSString *_Nonnull const BJYQosDicAudioBandwidthKey;

NS_ASSUME_NONNULL_BEGIN

/** 音视频网络状态 */
typedef NS_ENUM(NSInteger, BJLMediaNetworkStatus) {
    /** 优秀 */
    BJLMediaNetworkStatus_excellent,
    /** 良好 */
    BJLMediaNetworkStatus_good,
    /** 差 */
    BJLMediaNetworkStatus_bad,
    /** 极差 */
    BJLMediaNetworkStatus_terrible
};

/** ### 音视频设置 */
@interface BJLMediaVM: BJLBaseVM

/**
 是否允许设置上、下行链路类型
 #discussion `upLinkTypeReadOnly`/`downLinkTypeReadOnly` 为 YES 时设置 `upLinkType`/`downLinkType` 无效
 */
@property (nonatomic, readonly) BOOL upLinkTypeReadOnly, downLinkTypeReadOnly;

/** 当前是否控制音频 */
@property (nonatomic, readonly) BOOL isAudioSessionActive;

/** 是否支持后台音频, 默认支持 */
@property (nonatomic, readonly) BOOL supportBackgroundAudio;
- (nullable BJLError *)updateSupportBackgroundAudio:(BOOL)supportBackgroundAudio;

/** 是否支持后台采集声音, 默认不支持 */
@property (nonatomic, readonly) BOOL supportBackgroundRecordingAudio;
- (nullable BJLError *)updateSupportBackgroundRecordingAudio:(BOOL)supportBackgroundRecordingAudio;

/** 是否播放视频静音, 默认不静音 */
@property (nonatomic, readonly) BOOL needMutePlayingAudio;
- (nullable BJLError *)updateNeedMutePlayingAudio:(BOOL)needMutePlayingAudio;

/** 上、下行链路类型 */
@property (nonatomic, readonly) BJLLinkType upLinkType, downLinkType;
- (nullable BJLError *)updateUpLinkType:(BJLLinkType)upLinkType;
- (nullable BJLError *)updateDownLinkType:(BJLLinkType)downLinkType;

/** 调试: 获取音视频流信息 */
- (NSArray<NSString *> *)debugInfo;

#pragma mark -  TCP 上行 CDN 切换

/** TCP 上行线路可用 CDN 数 */
@property (nonatomic, readonly) NSUInteger upLinkCDNCount;

/**
 TCP 上行线路优先使用的 CDN index
 #discussion 调用用 updatePrefferedCDNWithIndex: 设置该值
 #discussion 指定线路推流时可设置该值为范围 [0, availableCDN] 内的整数，每一个数对应一个 CDN 线路。指定 CDN 不可用时，服务器将自动分配。
 #discussion 设置该值为 [0, availableCDN] 外的任意值代表不指定 CDN，由服务器自动分配。
 #discussion 默认值为 NSNotFound, 即服务器自动分配。
 #discussion 改变该值将导致重新推流
 */
@property (nonatomic, readonly) NSInteger upLinkCDNIndex;

/**
 设置 upLinkCDNIndex 并重新推流
 #param index CDN 序号，取值范围参考 downLinkCDNCount
 #discussion 调用该方法会将上行链路切换到 TCP
 */
- (nullable BJLError *)updateTCPUpLinkCDNWithIndex:(NSInteger)index;

#pragma mark - TCP 下行 CDN 切换

/** TCP 下行线路可用 CDN 数 */
@property (nonatomic, readonly) NSUInteger downLinkCDNCount;

/**
 TCP 下行线路优先使用的 CDN index
 #discussion 调用 updateTCPDownLinkCDNWithIndex: 设置该值
 #discussion 指定线路推流时可设置该值为范围 [0, availableCDN] 内的整数，每一个数对应一个 CDN 线路。指定 CDN 不可用时，服务器将自动分配。
 #discussion 设置该值为 [0, availableCDN] 外的任意值代表不指定 CDN，由服务器自动分配。
 #discussion 默认值为 NSNotFound, 即服务器自动分配。
 #discussion 改变该值将导致重新推流
 */
@property (nonatomic, readonly) NSInteger downLinkCDNIndex;

/**
 设置  downLinkCDNIndex 并重新拉流
 #param index CDN 序号，取值范围参考 downLinkCDNCount
 #discussion 调用该方法会将下行链路切换到 TCP
 */
- (nullable BJLError *)updateTCPDownLinkCDNWithIndex:(NSInteger)index;

#pragma mark - webRTC 直播间 API

/** webRTC：是否已进入直播频道 */
@property (nonatomic, readonly) BOOL inLiveChannel;

/** webRTC：进入直播频道失败 */
- (BJLObservable)enterLiveChannelFailed;

/**
 webRTC：直播频道断开连接
 #param error 断开连接的错误信息
 */
- (BJLObservable)didLiveChannelDisconnectWithError:(nullable NSError *)error;

/**
 音视频网络状态更新回调
 #param user    用户实例
 #param status  网络状态
 */
- (BJLObservable)mediaNetworkStatusDidUpdateWithUser:(BJLMediaUser *)user status:(BJLMediaNetworkStatus)status;

/**
 音视频丢包率更新回调
 #param user            用户
 #param videoLossRate   视频丢包率 [0, 100]
 #param audioLossRate   音频丢包率 [0, 100]
 */
- (BJLObservable)mediaLossRateDidUpdateWithUser:(BJLMediaUser *)user videoLossRate:(CGFloat)videoLossRate audioLossRate:(CGFloat)audioLossRate;

/**
 音量更新回调
 #param user   用户 
 #param volume 音量, 取值范围 0~255
 */
- (BJLObservable)volumeDidUpdateWithUser:(BJLMediaUser *)user volume:(CGFloat)volume;

#pragma mark - weaknet

- (BJLObservable)didReceivePresenterLossRate:(CGFloat)lossRate
                                     isVideo:(BOOL)isVideo
                                      userID:(NSString *)userID
                                 mediaSource:(BJLMediaSource)mediaSource;

/**
 是否支持音视频统计信息回调
 */
- (BOOL)supportQosStatsInfo;

/**
 返回音视频推拉流的相关统计信息，仅仅当 supportQosStatsInfo 返回YES时才会工作
 @param qosDic <userid:qosinfoDic, userid:qosinfoDic...> 这种形式的字典，包含当前推流用户
 qosinfoDic 中 key 是 BJYQosDicAudioBandwidthKey / BJYQosDicVideoBandwidthKey 等
 qosinfoDic 未在当前头文件中暴露的key在未来升级中可能会移除，请确保只使用暴露出来的key
 @param mediaSource 当前只支持BJLMediaSource_mainCamera
 */
- (BJLObservable)didReceiveQosDic:(NSDictionary *)qosDic mediaSource:(BJLMediaSource)mediaSource;
@end

NS_ASSUME_NONNULL_END
