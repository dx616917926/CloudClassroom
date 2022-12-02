//
//  BJLPlayingVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLPlayingVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPlayingVM (swift)
- (id<BJLObservation>)sw_playingUserDidUpdateOld:(BJLControlObserving (^)(BJLMediaUser *_Nullable now, BJLMediaUser *_Nullable old))block NS_SWIFT_NAME(sw_playingUserDidUpdateOld(_:));
- (id<BJLObservation>)sw_playingUserDidUpdateVideoDefinitionsOld:(BJLControlObserving (^)(BJLMediaUser *_Nullable now, BJLMediaUser *_Nullable old))block NS_SWIFT_NAME(sw_playingUserDidUpdateVideoDefinitionsOld(_:));
- (id<BJLObservation>)sw_playingUsersDidOverwriteExtraPlayingUsers:(BJLControlObserving (^)(NSArray<BJLMediaUser *> *_Nullable playingUsers, NSArray<BJLMediaUser *> *_Nullable extraPlayingUsers))block NS_SWIFT_NAME(sw_playingUsersDidOverwriteExtraPlayingUsers(_:));
- (id<BJLObservation>)sw_playingUserDidStartLoadingVideo:(BJLControlObserving (^)(BJLMediaUser *_Nullable playingUser))block NS_SWIFT_NAME(sw_playingUserDidStartLoadingVideo(_:));
- (id<BJLObservation>)sw_playingUserDidFinishLoadingVideo:(BJLControlObserving (^)(BJLMediaUser *_Nullable playingUser))block NS_SWIFT_NAME(sw_playingUserDidFinishLoadingVideo(_:));
- (id<BJLObservation>)sw_playLagWithPlayingUser:(BJLControlObserving (^)(BJLMediaUser *user))block NS_SWIFT_NAME(sw_playLagWithPlayingUser(_:));
- (id<BJLObservation>)sw_playingViewAspectRatioChangedForUser:(BJLControlObserving (^)(CGFloat videoAspectRatio, BJLMediaUser *user))block NS_SWIFT_NAME(sw_playingViewAspectRatioChangedForUser(_:));
- (id<BJLObservation>)sw_didUpdateVideoWindowWithModelShouldReset:(BJLControlObserving (^)(BJLWindowUpdateModel *updateModel, BOOL shouldReset))block NS_SWIFT_NAME(sw_didUpdateVideoWindowWithModelShouldReset(_:));
- (id<BJLObservation>)sw_didAddActiveUser:(BJLControlObserving (^)(BJLUser *user))block NS_SWIFT_NAME(sw_didAddActiveUser(_:));
- (id<BJLObservation>)sw_didAddActiveUserDenyResponseCode:(BJLControlObserving (^)(BJLUser *user, NSInteger responseCode))block NS_SWIFT_NAME(sw_didAddActiveUserDenyResponseCode(_:));
- (id<BJLObservation>)sw_didRemoveActiveUser:(BJLControlObserving (^)(BJLUser *user))block NS_SWIFT_NAME(sw_didRemoveActiveUser(_:));
- (id<BJLObservation>)sw_didStopCloudVideo:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didStopCloudVideo(_:));
@end

NS_ASSUME_NONNULL_END
