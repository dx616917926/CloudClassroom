//
//  BRTCAudioEffecter.h
//  BRTC
//
//  Created by 辛亚鹏 on 2022/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BRTCAudioEffecterDelegate <NSObject>

/*
 errorCode 释义:
 kOk = 0,
 kErrMusicFileEof = -99,    // 文件结束
 kErrMusicInit = -100,      // 相关变量初始化失败
 kErrMusicDecode = -101,    // 解码出错
 kErrMusicFormat = -102,    // 音频文件格式错误
 kErrResample = -103,       // 重采样出错
 kErrResamplerInit = -104,  // 初始化重采样器失败
 kErrMusicIdInvalid = 105,  // 用户指定的 ID 已经被内部使用
 */

- (void)onMusicStart:(int)musicID errorCode:(int)errorCode;
- (void)onMusicPlayProgress:(int)musicID curPtsMS:(long)curPtsMS durationMS:(long)durationMS;
- (void)onMusicComplete:(int)musicID errorCode:(int)errorCode;

@end

@interface BRTCAudioMusicParameter: NSObject

/// 【字段含义】音乐 ID （必传）
/// 【特殊说明】SDK 允许播放多路音乐，因此需要音乐 ID
/// 进行标记，用于控制音乐的开始、停止等
@property (nonatomic, assign) int musicID;
/// 【字段含义】音乐文件的绝对路径（必传）
@property (nonatomic, strong) NSString *path;

/// 【字段含义】是否将音乐传到远端
/// 【推荐取值】YES：音乐在本地播放的同时，会上行至云端，因此远端用户也能听到该音乐；NO：音乐不会上行至云端，因此只能在本地听到该音乐。默认值：NO
@property (nonatomic, assign) BOOL publish;
/// 【字段含义】音乐循环播放的次数
/// 【推荐取值】取值范围为0 - 任意正整数，默认值：0。0表示播放音乐一次；1表示播放音乐两次；以此类推
@property (nonatomic, assign) uint loopCount;
/// 【字段含义】播放的文件是否需要重复播放
/// 【推荐取值】YES：短音乐文件会主动重复播放；NO：正常的音乐文件。默认值：NO
@property (nonatomic, assign) BOOL isShortFile;
/// 【字段含义】音乐开始播放时间点，单位毫秒
@property (nonatomic, assign) long startTimeMS;
/// 【字段含义】音乐结束播放时间点，单位毫秒，0表示播放至文件结尾。
@property (nonatomic, assign) long endTimeMS;

@end

@interface BRTCAudioEffecter: NSObject

- (instancetype)init NS_UNAVAILABLE;

- (void)addDeleagte:(id<BRTCAudioEffecterDelegate>)delegate musicID:(int)musicID;

// 开始播放音乐
- (void)startPlayMusic:(BRTCAudioMusicParameter *)para;

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
