/***********************
auth: cszdlt@qq.com
date: 2020-03-26 16:57:15
name: VloudRTCStatsReport.h
************************/

#import <Foundation/Foundation.h>
#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudStatsBandWidth : NSObject
@property(nonatomic, assign) long long upload;
@property(nonatomic, assign) long long download;

- (NSString *)description;
@end

RTC_OBJC_EXPORT
@interface VloudStatsBitrateData : NSObject
@property(nonatomic, assign) double upload;
@property(nonatomic, assign) double download;

- (NSString *)description;
@end

RTC_OBJC_EXPORT
@interface VloudStatsBitrate : NSObject
@property(nonatomic, strong) VloudStatsBitrateData *total;
@property(nonatomic, strong) VloudStatsBitrateData *audio;
@property(nonatomic, strong) VloudStatsBitrateData *video;

- (NSString *)description;
@end

RTC_OBJC_EXPORT
@interface VloudStatsPacketLoss : NSObject
@property(nonatomic, assign) double total;
@property(nonatomic, assign) double audioUpload;
@property(nonatomic, assign) double audioDownload;
@property(nonatomic, assign) double videoUpload;
@property(nonatomic, assign) double videoDownload;

- (NSString *)description;
@end

RTC_OBJC_EXPORT
@interface VloudStatsResolution : NSObject
@property(nonatomic, assign) long long width;
@property(nonatomic, assign) long long height;

- (NSString *)description;
@end

RTC_OBJC_EXPORT
@interface VloudStatsTransport : NSObject
@property(nonatomic, copy) NSString *localAddress;
@property(nonatomic, copy) NSString *remoteAddress;
@property(nonatomic, copy) NSString *transportType;
@property(nonatomic, copy) NSString *localCandidateType;
@property(nonatomic, copy) NSString *remoteCandidateType;
@property(nonatomic, copy) NSString *networkType;
@property(nonatomic, assign) long long RTT;

- (NSString *)description;
@end

//RTC_OBJC_EXPORT
//@interface VloudStatsQualityData : NSObject
//@property(nonatomic, copy) NSString *codec;
//@property(nonatomic, assign) long long ssrc;
//@property(nonatomic, assign) int nacks;
//@property(nonatomic, assign) int plis;
//@property(nonatomic, assign) int firs;
//@property(nonatomic, assign) int delay;
//@property(nonatomic, assign) long long jitter;
//
//- (NSString *)description;
//@end

//RTC_OBJC_EXPORT
//@interface VloudStatsQuality : NSObject
//@property(nonatomic, strong) VloudStatsQualityData *audio;
//@property(nonatomic, strong) VloudStatsQualityData *video;
//
//- (NSString *)description;
//@end

RTC_OBJC_EXPORT
@interface VloudStatsStatisticsData : NSObject
@property(nonatomic, assign) long long bytesReceived;
@property(nonatomic, assign) long long bytesSent;
@property(nonatomic, assign) long long packetsReceived;
@property(nonatomic, assign) long long packetsSent;

- (NSString *)description;
@end

RTC_OBJC_EXPORT
@interface VloudStatsStatistics : NSObject
@property(nonatomic, strong) VloudStatsStatisticsData *audio;
@property(nonatomic, strong) VloudStatsStatisticsData *video;

- (NSString *)description;
@end

RTC_OBJC_EXPORT
@interface VloudStatsReport : NSObject

@property(nonatomic, strong) VloudStatsBandWidth *bandwidth;
@property(nonatomic, strong) VloudStatsBitrate *bitrate;
@property(nonatomic, strong) VloudStatsPacketLoss *packetLoss;
@property(nonatomic, strong) VloudStatsResolution *resolution;
//@property(nonatomic, strong) VloudStatsQuality *quality;
@property(nonatomic, assign) long long framerate;
@property(nonatomic, assign) double avgAudioLevel;
@property(nonatomic, assign) double audioLevel;
/**
 * VloudStatsTransport 数组
 */
@property(nonatomic, strong) NSArray<VloudStatsTransport *> *transports;
@property(nonatomic, strong) VloudStatsStatistics *statistics;

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
