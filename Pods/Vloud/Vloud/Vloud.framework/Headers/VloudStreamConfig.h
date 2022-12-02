/***********************
auth: cszdlt@qq.com
date: 2020-03-21 18:05:16
name: VloudStreamConfig.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum VloudVideoLevel : NSInteger VloudVideoLevel;
enum VloudVideoLevel : NSInteger {
  VloudVideoMain,
  VloudVideoMid,
  VloudVideoLow,
  VloudVideoTiny,
  VloudVideoNone,
};

typedef enum VloudVideoQosPreference : NSInteger VloudVideoQosPreference;
enum VloudVideoQosPreference : NSInteger {
  VloudVideoQosPreferenceDisable,
  VloudVideoQosPreferenceFramerate,
  VloudVideoQosPreferenceResolution,
  VloudVideoQosPreferenceBalanced,
};

typedef enum VloudVideoStreamType : NSInteger VloudVideoStreamType;
enum VloudVideoStreamType : NSInteger {
  VloudVideoStreamTypeBig,
  VloudVideoStreamTypeSmall,
};

RTC_OBJC_EXPORT
@interface VideoResolution : NSObject

/// 视频宽
@property(nonatomic, readonly) int32_t width;

/// 视频高
@property(nonatomic, readonly) int32_t height;

- (instancetype)init NS_UNAVAILABLE;

/**
 * 初始化方法
 * @param width 视频宽
 * @param height 视频高
 * @return VideoResolution
 */
- (instancetype)initWithWidth:(int32_t)width height:(int32_t)height;

@end

RTC_OBJC_EXPORT
@interface VloudVideoInfo : NSObject

/// 视频宽
@property(nonatomic, readonly) int32_t width;

/// 视频高
@property(nonatomic, readonly) int32_t height;

/// 视频码率(启动多流时可用)
@property(nonatomic, readonly) int32_t bandWidth;

- (instancetype)init;

/**
 * 初始化方法
 * @param width 视频宽
 * @param height 视频高
 * @return VideoInfo
 */
- (instancetype)initWithWidth:(int32_t)width height:(int32_t)height bandWidth:(int32_t)bandWidth;

@end

RTC_OBJC_EXPORT
@interface VloudStreamConfig : NSObject

/// 当前 stream 的 id
@property(nonatomic, copy) NSString *streamId;

/// 是否含有音频数据
@property(nonatomic, assign) BOOL hasAudio;

/// 是否含有视频数据
@property(nonatomic, assign) BOOL hasVideo;

/// 是否启用音频
@property(nonatomic, assign, readonly) BOOL audioEnable;

/// 是否启用视频
@property(nonatomic, assign, readonly) BOOL videoEnable;

/// 音频编码
@property(nonatomic, copy) NSString *audioCodec;

/// 视频编码
@property(nonatomic, copy) NSString *videoCodec;

/// 音频码率，单位 KB
@property(nonatomic, assign) NSInteger audioBandWidth;

/// 视频码率，单位 KB
@property(nonatomic, assign) NSInteger videoBandWidth;

/// 视频信息，包含分辨率及码率。如传递多个信息，会启用多流，并且多流的码率会使用设置的值。如设置了该参数，则不使用videoBandWidth的约束
@property(nonatomic, copy) NSArray<VloudVideoInfo *> *videoInfos;

/// 视频流的数量，只读属性
@property(nonatomic, assign, readonly) NSInteger videoStreamCount;

/// 视频流的帧率
@property(nonatomic, assign) NSInteger fps;

/// 是否启用音频丢包重传
@property(nonatomic, assign) BOOL audioNackEnable;

/// 是否启用音频冗余包
@property(nonatomic, assign) BOOL audioRedundancyEnable;

/// 视频清晰度
@property(nonatomic, assign) VloudVideoLevel videoLevel;

/// 视频画质偏好 smooth 弱网下保流畅，clear 弱网下保清晰度 (默认值)
@property(nonatomic, assign) VloudVideoQosPreference preference;

/// 视频质量 big 大流，small 小流
@property(nonatomic, assign) VloudVideoStreamType streamType;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStreamId:(NSString *)streamId
                        hasAudio:(BOOL)hasAudio
                        hasVideo:(BOOL)hasVideo
                     audioEnable:(BOOL)audioEnable
                     videoEnable:(BOOL)videoEnable
                      audioCodec:(NSString *)audioCodec
                      videoCodec:(NSString *)videoCodec
                  audioBandWidth:(NSInteger)audioBandWidth
                  videoBandWidth:(NSInteger)videoBandWidth
                      videoInfos:(NSArray<VloudVideoInfo *> *)videoInfos
                videoStreamCount:(NSInteger)videoStreamCount
                             fps:(NSInteger)fps
                 audioNackEnable:(BOOL)audioNackEnable
           audioRedundancyEnable:(BOOL)audioRedundancyEnable
                      videoLevel:(VloudVideoLevel)videoLevel
              audioProcessConfig:(NSDictionary *)audioProcessConfig;

- (NSString *)description;
@end

NS_ASSUME_NONNULL_END
