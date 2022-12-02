
#import <Foundation/Foundation.h>
#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@protocol VloudAudioEffecterDelegate <NSObject>
@optional

/*
 伴音错误码:
 kOk = 0,
 kErrMusicFileEof = -99,
 kErrMusicInit = -100,
 kErrMusicDecode = -101,
 kErrMusicFormat = -102,
 kErrResample = -103,
 kErrResamplerInit = -104,
 */
// 背景音乐开始播放
- (void)musicOnStart:(int)musicID errorCode:(int)errorCode;

// 背景音乐的播放进度
- (void)musicOnPlayProgress:(int)musicID curPtsMS:(long)curPtsMS durationMS:(long)durationMS;

// 背景音乐已播放完毕
- (void)musicOnComplete:(int)musicID errorCode:(int)errorCode;

@end

RTC_OBJC_EXPORT
@interface VloudAudioMusicParam : NSObject

@property (nonatomic, assign) int musicID;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) int loopCount;
@property (nonatomic, assign) BOOL publish;
@property (nonatomic, assign) BOOL isShortFile;
@property (nonatomic, assign) long startTimeMS;
@property (nonatomic, assign) long endTimeMS;

@end

@interface VloudAudioEffecter : NSObject

- (instancetype)init NS_UNAVAILABLE;

//  是否开启耳麦
- (void)earMonitorEnable:(BOOL)enable;

- (void)addMusicDlegate:(id<VloudAudioEffecterDelegate>)delegate musicID:(int)musicID;

// 开始播放音乐
- (void)startPlayMusic:(VloudAudioMusicParam *)para;

// 停止背景音乐播放
- (void)stopPlayMusic:(int)musicID;

// 暂停背景音乐播放
- (void)pausePlayMusic:(int)musicID;

// 恢复背景音乐播放
- (void)resumePlayMusic:(int)musicID;

// 设置音乐音调，原始是 0.0f，[-1 ~ 1]
- (void)setMusicPitch:(int)pitch musicID:(float)musicID;

// 设置音乐变速播放，原始是 1.0f，[0.5 ~ 2.0]
- (void)setMusicSpeedRate:(int)speedRate musicID:(float)musicID;

// 设置所有背景音乐的本地和远端音量。取值 0 - 150，默认 100
- (void)setAllMusicVolume:(int)volume;

// 设置指定背景音乐的远端音量。取值 0 - 150，默认 100
- (void)setMusicPublishVolume:(int)volume musicID:(int)musicID;

// 设置指定背景音乐的本地音量。取值 0 - 150，默认 100
- (void)setMusicPlayoutVolume:(int)volume musicID:(int)musicID;

// 跳转到指定进度 ms
- (void)seekMusicToPosInTime:(int)pts musicID:(int)musicID;

// 获取当前播放进度 ms
- (long)getMusicCurrentPosInMS:(int)musicID;

// 获取音频总时长 ms
- (long)getMusicDurationInMS:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
