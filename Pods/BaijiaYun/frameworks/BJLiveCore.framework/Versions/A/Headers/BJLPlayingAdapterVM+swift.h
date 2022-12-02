//
//  BJLPlayingAdapterVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLPlayingAdapterVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPlayingAdapterVM (swift)
- (id<BJLObservation>)sw_playingUserDidUpdateOld:(BJLControlObserving (^)(BJLMediaUser *_Nullable now, BJLMediaUser *_Nullable old))block NS_SWIFT_NAME(sw_playingUserDidUpdateOld(_:));
- (id<BJLObservation>)sw_playingUserDidUpdateVideoDefinitionsOld:(BJLControlObserving (^)(BJLMediaUser *_Nullable now, BJLMediaUser *_Nullable old))block NS_SWIFT_NAME(sw_playingUserDidUpdateVideoDefinitionsOld(_:));
- (id<BJLObservation>)sw_playingUsersDidOverwrite:(BJLControlObserving (^)(NSArray<BJLMediaUser *> *_Nullable playingUsers))block NS_SWIFT_NAME(sw_playingUsersDidOverwrite(_:));
- (id<BJLObservation>)sw_playingUserDidStartLoadingVideo:(BJLControlObserving (^)(BJLMediaUser *_Nullable playingUser))block NS_SWIFT_NAME(sw_playingUserDidStartLoadingVideo(_:));
- (id<BJLObservation>)sw_playingUserDidFinishLoadingVideo:(BJLControlObserving (^)(BJLMediaUser *_Nullable playingUser))block NS_SWIFT_NAME(sw_playingUserDidFinishLoadingVideo(_:));
- (id<BJLObservation>)sw_playLagWithPlayingUser:(BJLControlObserving (^)(BJLMediaUser *user))block NS_SWIFT_NAME(sw_playLagWithPlayingUser(_:));
- (id<BJLObservation>)sw_playingViewAspectRatioChangedForUser:(BJLControlObserving (^)(CGFloat videoAspectRatio, BJLMediaUser *user))block NS_SWIFT_NAME(sw_playingViewAspectRatioChangedForUser(_:));
@end

NS_ASSUME_NONNULL_END
