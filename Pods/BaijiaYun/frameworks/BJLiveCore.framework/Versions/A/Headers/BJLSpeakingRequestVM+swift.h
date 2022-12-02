//
//  BJLSpeakingRequestVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLSpeakingRequestVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLSpeakingRequestVM (swift)
- (id<BJLObservation>)sw_didReceiveSpeakingRequestFromUser:(BJLControlObserving (^)(BJLUser *user))block NS_SWIFT_NAME(sw_didReceiveSpeakingRequestFromUser(_:));
- (id<BJLObservation>)sw_speakingRequestDidReplyToUserIDAllowedSuccess:(BJLControlObserving (^)(NSString *userID, BOOL allowed, BOOL success))block NS_SWIFT_NAME(sw_speakingRequestDidReplyToUserIDAllowedSuccess(_:));
- (id<BJLObservation>)sw_speakingRequestDidReplyEnabledIsUserCancelledUser:(BJLControlObserving (^)(BOOL speakingEnabled, BOOL isUserCancelled, BJLUser *user))block NS_SWIFT_NAME(sw_speakingRequestDidReplyEnabledIsUserCancelledUser(_:));
- (id<BJLObservation>)sw_didReceiveSpeakingInvite:(BJLControlObserving (^)(BOOL invite))block NS_SWIFT_NAME(sw_didReceiveSpeakingInvite(_:));
- (id<BJLObservation>)sw_didReceiveSpeakingInviteResultWithUserIDAccept:(BJLControlObserving (^)(NSString *userID, BOOL accept))block NS_SWIFT_NAME(sw_didReceiveSpeakingInviteResultWithUserIDAccept(_:));
- (id<BJLObservation>)sw_speakingDidRemoteControl:(BJLControlObserving (^)(BOOL enabled))block NS_SWIFT_NAME(sw_speakingDidRemoteControl(_:));
@end

NS_ASSUME_NONNULL_END
