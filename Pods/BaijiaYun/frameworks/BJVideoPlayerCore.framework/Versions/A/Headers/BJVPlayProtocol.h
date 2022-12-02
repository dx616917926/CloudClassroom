//
//  BJVPlayProtocol.h
//  BJPlayerManagerCore
//
//  Created by HuangJie on 2018/5/5.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#ifndef BJVPlayProtocol_h
#define BJVPlayProtocol_h

#import <AVKit/AVKit.h>
#import "BJVPlayerMacro.h"
#import "BJVPlayInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BJVPlayProtocol <NSObject>

@required

#pragma mark - 播放设置

/**
 第三方用户名和编号
 
 #discussion 需要在调用 setup video 之前设置
 */
@property (nonatomic, strong, nullable) NSString *userName;
@property (nonatomic, strong, nullable) NSString *userNumber;

/**
 视频的起始播放时间
 
 #discussion 需要在实例化 playerManager 对象后设置
 #discussion 设置为大于 0 的值时，记忆播放 playTimeRecordEnabled 无效
 #discussion !!!: 使用同一个 playerManager 播放不同视频时，该值不会自动重置，需要根据实际情况重新设置
 */
@property (nonatomic, assign) NSTimeInterval initialPlayTime;

/**
 播放倍速
 
 #discussion 有效区间：[0.5, 2.0]
 */
@property (nonatomic, assign) CGFloat rate;

/**
 偏好清晰度列表
 
 #discussion 优先使用此列表中的清晰度播放在线视频，优先级按数组元素顺序递减
 #discussion preferredDefinitionList 列表元素为清晰度的标识字符串，现有标识符：low（标清），high（高清），superHD（超清），720p，1080p，audio（纯音频），可根据实际情况动态扩展
 #discussion 此设置对播放本地视频无效
 */
@property (nonatomic, strong) NSArray<NSString *> *preferredDefinitionList;

/**
 进入后台时，是否继续播放音频，必须在工程的 background modes 中添加 audio 才会生效
 note: 当设置 backgroundAudioEnabled 为 YES 时, 内部会把 pictureInPictureEnabled 置为 NO
 */
@property (nonatomic, assign) BOOL backgroundAudioEnabled;

/** 是否开启记忆播放 */
@property (nonatomic, assign) BOOL playTimeRecordEnabled;

/** 记忆播放时间，当播放器设置正确的播放数据源后才能返回正常数据 */
@property (nonatomic, readonly) NSTimeInterval playTimeRecord;

/** 清除播放记录 */
- (void)clearPlayTimeRecords;

/**
 开启记忆播放时，视频剩余时间不足 ignorableRemainingTimeInterval 秒时，
 视为播放结束，清除该视频的播放进度纪录，默认 5s，可根据需要自行设置
 */
@property (nonatomic, assign) NSTimeInterval ignorableRemainingTimeInterval;

#pragma mark - remote control

/** 进入后台或锁屏时，是否支持开启远程控制，仅在使用后台播放时有效，默认关闭 */
@property (nonatomic, assign) BOOL remoteControlEnabled;

/** 设置远程控制状态下的封面 */
@property (nonatomic, strong) UIImage *remoteControlImage;

#pragma mark - view

/** 播放视图 */
@property (nonatomic, readonly, nullable) UIView *playerView;

/** 播放视图显示模式 */
@property (nonatomic) BJVPlayerViewScalingMode scalingMode;

#pragma mark - play control：在 setup video 之后调用

/** 播放 */
- (void)play;

/** 暂停 */
- (void)pause;

/**
 跳转时间
 
 #param time 目标时间
 */
- (void)seek:(NSTimeInterval)time;

/**
 切换清晰度
 
 #param index 目标清晰度 在 BJVPlayInfo 的 definitionList 数组中的序号
 */
- (void)changeDefinitionWithIndex:(NSUInteger)index;

/** 切换字幕文件
 #param index 目标字幕 在 BJVPlayInfo 的 subtitleInfo 数组中的序号
 */
- (void)changeSubtitleWithIndex:(NSUInteger)index;

#pragma mark - 播放信息

/** 当前播放状态 */
@property (nonatomic, readonly) BJVPlayerStatus playStatus;

/** 视频的时长 */
@property (nonatomic, readonly) NSTimeInterval duration;

/** 视频缓存时长 */
@property (nonatomic, readonly) NSTimeInterval cachedDuration;

/** 正片的当前的播放时间 */
@property (nonatomic, readonly) NSTimeInterval currentTime;

/** 视频信息 */
@property (nonatomic, readonly, nullable) BJVPlayInfo *playInfo;

/** 当前播放清晰度 */
@property (nonatomic, readonly, nullable) BJVDefinitionInfo *currDefinitionInfo;

/** 当前使用的字幕信息 */
@property (nonatomic, readonly, nullable) BJVSubtitleInfo *currentSubtitleInfo;

/** 当前时间点的字幕内容 */
@property (nonatomic, readonly, nullable) BJVSubtitle *currentSubtitle;

#pragma mark - reset & destroy

/**
 清理播放器，重置状态、清空数据
 */
- (void)reset;

/**
 销毁播放器
 
 #discussion 调用后彻底销毁播放器，不可恢复
 #discussion 可在退出播放界面前调用
 */
- (void)destroy;

#pragma mark - 可监听方法

/**
 视频播放出错
 
 #param playInfo 出错视频信息
 #param error 错误信息
 */
- (BJLObservable)video:(BJVPlayInfo *)playInfo playFailedWithError:(NSError *)error;

#pragma mark - 画中画

/**
 开启画中画
 note: 当前的播放器类型为 BJVPlayerType_AVPlayer 且 backgroundAudioEnabled == NO 时, 设置 pictureInPictureEnabled 才有效
 note: 当设置 backgroundAudioEnabled 为 YES 时, 内部会把 pictureInPictureEnabled 置为 NO
 */
@property (nonatomic, assign) BOOL pictureInPictureEnabled;

/** 画中画视图控制器, 可能为空 */
@property (nonatomic, strong, nullable, readonly) AVPictureInPictureController *pipViewContrller;

/** 启动画中画, 仅 AVPlayer 有效  */
- (void)startPictureInPicture;

/** 关闭画中画, 仅 AVPlayer 有效 */
- (void)stopPictureInPicture;

@end

NS_ASSUME_NONNULL_END

#endif /* BJVPlayProtocol_h */
