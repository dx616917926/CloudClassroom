/***********************
auth: cszdlt@qq.com
date: 2020-03-23 16:23:29
name: VloudStreamConfigBuilder.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"
#import "VloudStreamConfig.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudStreamConfigBuilder : NSObject

+ (VloudStreamConfigBuilder *)builder;

- (instancetype)init;

- (VloudStreamConfig *)createVloudStreamConfig;

- (void)setStreamId:(NSString *)streamId;
- (void)setHasAudio:(BOOL)hasAudio;
- (void)setHasVideo:(BOOL)hasVideo;
- (void)setAudioEnable:(BOOL)audioEnable;
- (void)setVideoEnable:(BOOL)videoEnable;
- (void)setAudioCodec:(NSString *)audioCodec;
- (void)setVideoCodec:(NSString *)videoCodec;
- (void)setAudioBandWidth:(NSInteger)audioBandWidth;
- (void)setVideoBandWidth:(NSInteger)videoBandWidth;
// deprecated
- (void)addVideoResolution:(VideoResolution *)videoResolution;
- (void)addVideoInfoWithWidth:(NSInteger)width
                       height:(NSInteger)height
                    bandWidth:(NSInteger)bandWidth;
- (void)setVideoStreamCount:(NSInteger)videoStreamCount;
- (void)setFps:(NSInteger)fps;
- (void)setAudioNack:(BOOL)enable;
- (void)setAudioRedundancy:(BOOL)enable;
- (void)setVideoLevel:(VloudVideoLevel)videoLevel;
- (void)setAudioProcessConfig:(NSDictionary *)audioProcessConfig;

@end

NS_ASSUME_NONNULL_END
