//
//  BJRTC.h
//  BJRTCSDK
//
//  Created by Chengchao on 8/10/18.
//  Copyright © 2018 xinyapeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJRTCSDK/BJRTCDefines.h>
#import <BJRTCSDK/BJRTCSFUOptions.h>
#import <BJRTCSDK/BJRTCSFUPublisher.h>
#import <BJRTCSDK/BJRTCSFUSubscriber.h>
#import <BJRTCSDK/BJRTCSfUAudioPlayer.h>

@class BJRTC;

@protocol BJRTCDelegate <NSObject>

@optional;
///
- (void)rtc:(BJRTC *)rtc error:(NSError *)error;
///
- (void)rtc:(BJRTC *)rtc publish:(NSString *)userID withSessionID:(NSString *)sessionID;
/// unpublish 要区分是 success or caused by error
- (void)rtc:(BJRTC *)rtc unpublish:(NSString *)userID withSessionID:(NSString *)sessionID;
///
- (void)rtc:(BJRTC *)rtc mediaChanged:(NSString *)userID withSessionID:(NSString *)sessionID;
///
- (void)rtc:(BJRTC *)rtc receivedStreamWithUserID:(NSString *)userID withSessionID:(NSString *)sessionID subscriber:(BJRTCSFUSubscriber *)subscriber;

- (void)rtc:(BJRTC *)rtc didFailWithError:(NSError *)error;

- (void)rtc:(BJRTC *)rtc didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

- (void)rtc:(BJRTC *)rtc subscriber:(BJRTCSFUSubscriber *)subscriber log:(NSDictionary *)log withSessionID:(NSString *)sessionID;
- (void)rtc:(BJRTC *)rtc subscriber:(BJRTCSFUSubscriber *)subscriber error:(NSError *)error withSessionID:(NSString *)sessionID;
- (void)rtc:(BJRTC *)rtc subscriber:(BJRTCSFUSubscriber *)subscriber webrtcStatsLog:(NSDictionary *)log withSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc publisher:(BJRTCSFUPublisher *)publisher error:(NSError *)error withSessionID:(NSString *)sessionID;
- (void)rtc:(BJRTC *)rtc publisher:(BJRTCSFUPublisher *)publisher log:(NSDictionary *)log withSessionID:(NSString *)sessionID;
- (void)rtc:(BJRTC *)rtc publisher:(BJRTCSFUPublisher *)publisher webrtcStatsLog:(NSDictionary *)log withSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc localSdpDescription:(NSDictionary *)dic withSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc localStreamPublishTimeoutWithSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc mediaServerDic:(NSDictionary *)serverDic withSessionID:(NSString *)sessionID;
- (void)rtc:(BJRTC *)rtc serverErrorCode:(NSNumber *)errorCode withSessionID:(NSString *)sessionID;
- (void)rtc:(BJRTC *)rtc statsDataError:(NSString *)key videoOrAudio:(NSString *)videoOrAudio upOrDown:(NSString *)upOrDown withSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc publishIceConnectionStateFailedWithSessionID:(NSString *)sessionID;
- (void)rtc:(BJRTC *)rtc subscribeIceConnectionStateFailedWithUserId:(NSString *)userId withSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc signalingInteraction:(NSDictionary *)dic isSend:(BOOL)isSend withSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc subscriberOnBlockOrBlackScreen:(NSUInteger)blockOrBlackScreen userId:(NSString *)userId node:(NSString *)node switchTimes:(NSNumber *)times withSessionID:(NSString *)sessionID;

- (void)rtc:(BJRTC *)rtc licodeLog:(NSString *)log;

- (void)rtc:(BJRTC *)rtc subscriber:(BJRTCSFUSubscriber *)subscriber notAutoSwitchNodeWithUserID:(NSString *)userID withSessionID:(NSString *)sessionID;

// 针对sub
- (void)rtc:(BJRTC *)rtc mdediaServerDownWithUserID:(NSString *)userID sessionID:(NSString *)sessionID;
@end

typedef void (^BJRTCSuccessBlock)(NSDictionary *result);
typedef void (^BJRTCFailureBlock)(NSError *error);
typedef void (^BJRTCPublishSuccessBlock)(NSDictionary *result, BJRTCSFUPublisher *publisher);
typedef void (^BJRTCSubscribeSuccessBlock)(NSDictionary *result, BJRTCSFUSubscriber *subscriber);

@interface BJRTC : NSObject

@property (nonatomic, weak) id<BJRTCDelegate> delegate;

/// 单例模式创建 BJRTC 对象 (为确保引入改动最小，只增加参数Codec，而不是sfuOption)
+ (instancetype)sharedInstanceWithCodec:(BJRTCSupportedCodec)codec;

+ (instancetype)sharedInstanceByMixAudio;

/// 回收 RTCat
+ (void)release;

- (void)setupToken:(NSString *)token userID:(NSString *)userID options:(BJRTCSFUOptions *)options;
- (void)setupToken:(NSString *)token userID:(NSString *)userID options:(BJRTCSFUOptions *)options didCloseCvo:(BOOL)didCloseCvo;

- (void)connectWithSuccess:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
- (void)disconnect;

/// 切换音频输出设备
- (void)switchAudioOutputDevice;

/**
 * 系统音量模式切换
 */
- (BOOL)switchVolumeType:(BJRTCSystemVolumeType)volumeType;

///
- (BJRTCSFUPublisher *)createPublisherWithVideo:(BOOL)video audio:(BOOL)audio;
- (BJRTCSFUPublisher *)createPublisherWithVideo:(BOOL)video audio:(BOOL)audio facing:(BJRTCCameraFacing)facing fps:(unsigned int)fps height:(unsigned int)height width:(unsigned int)width videoSupportedCodec:(BJRTCSupportedCodec)codec;

- (BJRTCSFUAudioPlayer *)createAudioPlayerWithDelegate:(id<BJRTCSFUAudioPlayerSourceDelegate>)delegate;

/**
publish options:
{
    bandwidth: number
    disableRR: boolean
    server: {
        [prefer: array]
        [exclude: array]
    }// omission
    stream_props : {
        video:{}|false
        audio:{}|false
    }
    codec: string
    video: boolean
    audio: boolean
    firPeriod: number
}
*/
//- (NSDictionary *)publishOptionsWithCodec:(BJRTCSupportedCodec)codec bandwidth:(NSNumber *)bandwidth video:(BOOL)video audio:(BOOL)audio;

#pragma mark -
///
- (void)getAreasWithSuccess:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)getServersWithSuccess:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)switchAreaWithSessionID:(NSString *)sessionID success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)joinSeessionID:(NSString *)sessionID isMaster:(BOOL)isMaster success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)joinSeessionID:(NSString *)sessionID isMaster:(BOOL)isMaster area:(NSString *)area success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)quitSessionID:(NSString *)sessionID success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
//- (void)publishWithSessionID:(NSString *)sessionID success:(BJRTCPublishSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
//- (void)publishWithSessionID:(NSString *)sessionID options:(NSDictionary *)options success:(BJRTCPublishSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
//- (void)publishWithPublisher:(BJRTCSFUPublisher *)publisher sessionID:(NSString *)sessionID options:(NSDictionary *)options success:(BJRTCPublishSuccessBlock)success failure:(BJRTCFailureBlock)failure;

/// todo : publish参数做成一个单独的类进行配置,  否则类似接口越加越多
- (void)publishWithPublisher:(BJRTCSFUPublisher *)publisher sessionID:(NSString *)sessionID codec:(BJRTCSupportedCodec)codec minBandwidth:(NSNumber *)minBandwidth maxBandwidth:(NSNumber *)maxBandwidth video:(BOOL)video audio:(BOOL)audio success:(BJRTCPublishSuccessBlock)success failure:(BJRTCFailureBlock)failure;

- (void)publishWithPublisher:(BJRTCSFUPublisher *)publisher sessionID:(NSString *)sessionID codec:(BJRTCSupportedCodec)codec minBandwidth:(NSNumber *)minBandwidth maxBandwidth:(NSNumber *)maxBandwidth video:(BOOL)video audio:(BOOL)audio changeArea:(BOOL)isChangeArea success:(BJRTCPublishSuccessBlock)success failure:(BJRTCFailureBlock)failure;

- (void)publishWithPublisher:(BJRTCSFUPublisher *)publisher sessionID:(NSString *)sessionID codec:(BJRTCSupportedCodec)codec minBandwidth:(NSNumber *)minBandwidth maxBandwidth:(NSNumber *)maxBandwidth video:(BOOL)video audio:(BOOL)audio changeArea:(BOOL)isChangeArea degradationPreference:(BJRTCDegradationPreference)degradationPreference success:(BJRTCPublishSuccessBlock)success failure:(BJRTCFailureBlock)failure;

///
- (void)unpublishWithSessionID:(NSString *)sessionID success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)subscribe:(NSString *)userId withSessionID:(NSString *)sessionID success:(BJRTCSubscribeSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)unsubscribe:(NSString *)userId withSessionID:(NSString *)sessionID success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)muteAudio:(BOOL)muteAudio video:(BOOL)muteVideo withUserid:(NSString *)userId onSessionID:(NSString *)sessionID success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)changeMediaWithSessionID:(NSString *)sessionID args:(NSDictionary *)args success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;
///
- (void)preferredLayerWithSessionID:(NSString *)sessionID userID:(NSString *)userID spatialLayer:(NSNumber *)spatialLayer temporalLayer:(NSNumber *)temporalLayer success:(BJRTCSuccessBlock)success failure:(BJRTCFailureBlock)failure;

@end
