/*
 * BJYFFMoviePlayerController.h
 *
 * Copyright (c) 2013 Bilibili
 * Copyright (c) 2013 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import "BJYMediaPlayback.h"
#import "BJYFFMonitor.h"
#import "BJYFFOptions.h"
#import "BJYSDLGLViewProtocol.h"
#import "IJKBRTCNetwork.h"
#import "IJKBRTCUtils.h"
#import "BJYIJKClientInfoPackage.h"

// media meta
#define k_BJYM_KEY_FORMAT         @"format"
#define k_BJYM_KEY_DURATION_US    @"duration_us"
#define k_BJYM_KEY_START_US       @"start_us"
#define k_BJYM_KEY_BITRATE        @"bitrate"

// stream meta
#define k_BJYM_KEY_TYPE           @"type"
#define k_BJYM_VAL_TYPE__VIDEO    @"video"
#define k_BJYM_VAL_TYPE__AUDIO    @"audio"
#define k_BJYM_VAL_TYPE__UNKNOWN  @"unknown"

#define k_BJYM_KEY_CODEC_NAME      @"codec_name"
#define k_BJYM_KEY_CODEC_PROFILE   @"codec_profile"
#define k_BJYM_KEY_CODEC_LONG_NAME @"codec_long_name"

// stream: video
#define k_BJYM_KEY_WIDTH          @"width"
#define k_BJYM_KEY_HEIGHT         @"height"
#define k_BJYM_KEY_FPS_NUM        @"fps_num"
#define k_BJYM_KEY_FPS_DEN        @"fps_den"
#define k_BJYM_KEY_TBR_NUM        @"tbr_num"
#define k_BJYM_KEY_TBR_DEN        @"tbr_den"
#define k_BJYM_KEY_SAR_NUM        @"sar_num"
#define k_BJYM_KEY_SAR_DEN        @"sar_den"
// stream: audio
#define k_BJYM_KEY_SAMPLE_RATE    @"sample_rate"
#define k_BJYM_KEY_CHANNEL_LAYOUT @"channel_layout"

#define kk_BJYM_KEY_STREAMS       @"streams"

typedef enum BJYLogLevel {
    k_BJY_LOG_UNKNOWN = 0,
    k_BJY_LOG_DEFAULT = 1,

    k_BJY_LOG_VERBOSE = 2,
    k_BJY_LOG_DEBUG   = 3,
    k_BJY_LOG_INFO    = 4,
    k_BJY_LOG_WARN    = 5,
    k_BJY_LOG_ERROR   = 6,
    k_BJY_LOG_FATAL   = 7,
    k_BJY_LOG_SILENT  = 8,
} BJYLogLevel;

typedef int (^ijk_pcm_data_callback)(uint8_t * data, int samples_per_channel, int sample_rate_hz, size_t num_channels);

@interface BJYFFMoviePlayerController : NSObject <BJYMediaPlayback>

- (id)initWithContentURL:(NSURL *)aUrl
             withOptions:(BJYFFOptions *)options;

- (id)initWithContentURLString:(NSString *)aUrlString
                   withOptions:(BJYFFOptions *)options;

- (id)initWithMoreContent:(NSURL *)aUrl
             withOptions:(BJYFFOptions *)options
              withGLView:(UIView<BJYSDLGLViewProtocol> *)glView;

- (id)initWithMoreContentString:(NSString *)aUrlString
                 withOptions:(BJYFFOptions *)options
                  withGLView:(UIView<BJYSDLGLViewProtocol> *)glView;

- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
- (int64_t)trafficStatistic;
- (float)dropFrameRate;

- (int)getAudioIsBlock;
- (int)getVideoQueueHasEmpty;

- (void)setPauseInBackground:(BOOL)pause;
- (BOOL)isVideoToolboxOpen;
- (BOOL)muteVideo:(BOOL)isMute;
- (BOOL)muteAudio:(BOOL)isMute;

- (BOOL)isAlive;

/// 设置最大缓存时间
- (void)setMaxBufferTime:(int)maxBufferTime;
- (int)getMaxBufferTime;

+ (void)setLogReport:(BOOL)preferLogReport;
+ (void)setLogLevel:(BJYLogLevel)logLevel;
/// 数据上报接口
- (void)_clientInfoInit:(NSString *)url sampleTime:(int)sampleTime reportInterval:(int)reportInterval appId:(NSString *)appId  roomId:(NSString *)roomId  userId:(NSString *)userId userNumber:(NSString *)userNumber comments:(NSString *)comments;
- (void)setReportURL:(NSString *)url sampleTime:(int)sampleTime reportInterval:(int)reportInterval appId:(NSString *)appId  roomId:(NSString *)roomId  userId:(NSString *)userId userNumber:(NSString *)userNumber comments:(NSString *)comments;
@property(nonatomic) BJYIJKClientInfoPackage *clientInfo;
@property(nonatomic) NSDateFormatter* dataFormat;
@property(nonatomic) dispatch_source_t ijkReportTimer;
@property(nonatomic) NSMutableArray *ijkReportDataArray;
@property(nonatomic) NSMutableDictionary *ijkActionReportDic;
@property(nonatomic) NSMutableDictionary *ijkStatsReportDic;
@property(nonatomic) NSLock *ijkReportArrayLock;
@property(nonatomic, readonly) CGFloat fpsInMeta;
@property(nonatomic, readonly) CGFloat fpsAtOutput;


- (void)setOptionValue:(NSString *)value
                forKey:(NSString *)key
            ofCategory:(BJYFFOptionCategory)category;

- (void)setOptionIntValue:(int64_t)value
                   forKey:(NSString *)key
               ofCategory:(BJYFFOptionCategory)category;



- (void)setFormatOptionValue:       (NSString *)value forKey:(NSString *)key;
- (void)setCodecOptionValue:        (NSString *)value forKey:(NSString *)key;
- (void)setSwsOptionValue:          (NSString *)value forKey:(NSString *)key;
- (void)setPlayerOptionValue:       (NSString *)value forKey:(NSString *)key;

- (void)setFormatOptionIntValue:    (int64_t)value forKey:(NSString *)key;
- (void)setCodecOptionIntValue:     (int64_t)value forKey:(NSString *)key;
- (void)setSwsOptionIntValue:       (int64_t)value forKey:(NSString *)key;
- (void)setPlayerOptionIntValue:    (int64_t)value forKey:(NSString *)key;

@property (nonatomic, retain) id<BJYMediaUrlOpenDelegate> segmentOpenDelegate;
@property (nonatomic, retain) id<BJYMediaUrlOpenDelegate> tcpOpenDelegate;
@property (nonatomic, retain) id<BJYMediaUrlOpenDelegate> httpOpenDelegate;
@property (nonatomic, retain) id<BJYMediaUrlOpenDelegate> liveOpenDelegate;

@property (nonatomic, retain) id<BJYMediaNativeInvokeDelegate> nativeInvokeDelegate;

- (void)getPCMDataWithCallback:(ijk_pcm_data_callback)callback;
- (void)setMixerMode:(BOOL)isMixerMode;

#pragma mark KVO properties
@property (nonatomic, readonly) BJYFFMonitor *monitor;

@end

#define BJY_FF_IO_TYPE_READ (1)
void BJYFFIOStatDebugCallback(const char *url, int type, int bytes);
void BJYFFIOStatRegister(void (*cb)(const char *url, int type, int bytes));

void BJYFFIOStatCompleteDebugCallback(const char *url,
                                      int64_t read_bytes, int64_t total_size,
                                      int64_t elpased_time, int64_t total_duration);
void BJYFFIOStatCompleteRegister(void (*cb)(const char *url,
                                            int64_t read_bytes, int64_t total_size,
                                            int64_t elpased_time, int64_t total_duration));
