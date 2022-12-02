//
//  BJLGiftVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLGiftVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLGiftVM (swift)
- (id<BJLObservation>)sw_receivedGiftsDidOverwrite:(BJLControlObserving (^)(NSArray<NSObject<BJLReceivedGift> *> *_Nullable receivedGifts))block NS_SWIFT_NAME(sw_receivedGiftsDidOverwrite(_:));
- (id<BJLObservation>)sw_didReceiveGift:(BJLControlObserving (^)(NSObject<BJLReceivedGift> *receivedGift))block NS_SWIFT_NAME(sw_didReceiveGift(_:));
@end

NS_ASSUME_NONNULL_END
