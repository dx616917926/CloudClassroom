//
//  BJLRoom+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLRoom.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLRoom (swift)
- (id<BJLObservation>)sw_enterRoomSuccess:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_enterRoomSuccess(_:));
- (id<BJLObservation>)sw_enterRoomFailureWithError:(BJLControlObserving (^)(BJLError *error))block NS_SWIFT_NAME(sw_enterRoomFailureWithError(_:));
- (id<BJLObservation>)sw_roomWillExitWithError:(BJLControlObserving (^)(BJLError *_Nullable error))block NS_SWIFT_NAME(sw_roomWillExitWithError(_:));
- (id<BJLObservation>)sw_roomDidExitWithError:(BJLControlObserving (^)(BJLError *_Nullable error))block NS_SWIFT_NAME(sw_roomDidExitWithError(_:));
@end

NS_ASSUME_NONNULL_END
