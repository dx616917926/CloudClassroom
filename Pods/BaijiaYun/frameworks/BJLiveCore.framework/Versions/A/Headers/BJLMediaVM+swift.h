//
//  BJLMediaVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLMediaVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLMediaVM (swift)
- (id<BJLObservation>)sw_enterLiveChannelFailed:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_enterLiveChannelFailed(_:));
- (id<BJLObservation>)sw_didLiveChannelDisconnectWithError:(BJLControlObserving (^)(NSError *_Nullable error))block NS_SWIFT_NAME(sw_didLiveChannelDisconnectWithError(_:));
- (id<BJLObservation>)sw_mediaNetworkStatusDidUpdateWithUserStatus:(BJLControlObserving (^)(BJLMediaUser *user, BJLMediaNetworkStatus status))block NS_SWIFT_NAME(sw_mediaNetworkStatusDidUpdateWithUserStatus(_:));
- (id<BJLObservation>)sw_mediaLossRateDidUpdateWithUserVideoLossRateAudioLossRate:(BJLControlObserving (^)(BJLMediaUser *user, CGFloat videoLossRate, CGFloat audioLossRate))block NS_SWIFT_NAME(sw_mediaLossRateDidUpdateWithUserVideoLossRateAudioLossRate(_:));
- (id<BJLObservation>)sw_volumeDidUpdateWithUserVolume:(BJLControlObserving (^)(BJLMediaUser *user, CGFloat volume))block NS_SWIFT_NAME(sw_volumeDidUpdateWithUserVolume(_:));
- (id<BJLObservation>)sw_didReceivePresenterLossRateIsVideoUserIDMediaSource:(BJLControlObserving (^)(CGFloat lossRate, BOOL isVideo, NSString *userID, BJLMediaSource mediaSource))block NS_SWIFT_NAME(sw_didReceivePresenterLossRateIsVideoUserIDMediaSource(_:));
- (id<BJLObservation>)sw_didReceiveQosDicMediaSource:(BJLControlObserving (^)(NSDictionary *qosDic, BJLMediaSource mediaSource))block NS_SWIFT_NAME(sw_didReceiveQosDicMediaSource(_:));
@end

NS_ASSUME_NONNULL_END
