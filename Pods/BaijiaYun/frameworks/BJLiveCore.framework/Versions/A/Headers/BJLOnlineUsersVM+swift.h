//
//  BJLOnlineUsersVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLOnlineUsersVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLOnlineUsersVM (swift)
- (id<BJLObservation>)sw_onlineUserWillAdd:(BJLControlObserving (^)(BJLUser *user))block NS_SWIFT_NAME(sw_onlineUserWillAdd(_:));
- (id<BJLObservation>)sw_onlineUserDidEnter:(BJLControlObserving (^)(BJLUser *user))block NS_SWIFT_NAME(sw_onlineUserDidEnter(_:));
- (id<BJLObservation>)sw_onlineUserDidExit:(BJLControlObserving (^)(BJLUser *user))block NS_SWIFT_NAME(sw_onlineUserDidExit(_:));
- (id<BJLObservation>)sw_didRecieveUserCameraCoverUserNumber:(BJLControlObserving (^)(NSString *_Nullable imageURLString, NSString *userNumber))block NS_SWIFT_NAME(sw_didRecieveUserCameraCoverUserNumber(_:));
- (id<BJLObservation>)sw_didRecieveUserStateUpdateWithUserNumberAudioStateVideoState:(BJLControlObserving (^)(NSString *userNumber, BJLUserMediaState audioState, BJLUserMediaState videoState))block NS_SWIFT_NAME(sw_didRecieveUserStateUpdateWithUserNumberAudioStateVideoState(_:));
- (id<BJLObservation>)sw_onlineUserGroupCountDidChange:(BJLControlObserving (^)(NSDictionary *groupCountDic))block NS_SWIFT_NAME(sw_onlineUserGroupCountDidChange(_:));
- (id<BJLObservation>)sw_onlineUserGroupInfoDidChangeWithUserNumbersGroupInfo:(BJLControlObserving (^)(NSArray<NSString *> *userNumbers, BJLUserGroup *_Nullable groupInfo))block NS_SWIFT_NAME(sw_onlineUserGroupInfoDidChangeWithUserNumbersGroupInfo(_:));
- (id<BJLObservation>)sw_didBlockUser:(BJLControlObserving (^)(BJLUser *blockedUser))block NS_SWIFT_NAME(sw_didBlockUser(_:));
- (id<BJLObservation>)sw_didReceiveBlockedUserList:(BJLControlObserving (^)(NSArray<BJLUser *> *userList))block NS_SWIFT_NAME(sw_didReceiveBlockedUserList(_:));
- (id<BJLObservation>)sw_didFreeBlockedUserWithNumber:(BJLControlObserving (^)(NSString *userNumber))block NS_SWIFT_NAME(sw_didFreeBlockedUserWithNumber(_:));
- (id<BJLObservation>)sw_didFreeAllBlockedUsers:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didFreeAllBlockedUsers(_:));
@end

NS_ASSUME_NONNULL_END
