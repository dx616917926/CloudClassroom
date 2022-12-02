//
//  BJLSellVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLSellVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLSellVM (swift)
- (id<BJLObservation>)sw_didReceiveSellGoodsUpdate:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveSellGoodsUpdate(_:));
- (id<BJLObservation>)sw_didReceiveSellGoodsOnshelfStateUpdate:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveSellGoodsOnshelfStateUpdate(_:));
- (id<BJLObservation>)sw_didReceiveShowShopping:(BJLControlObserving (^)(BOOL showShopping))block NS_SWIFT_NAME(sw_didReceiveShowShopping(_:));
- (id<BJLObservation>)sw_didReceiveStreamerLikeCountUpdate:(BJLControlObserving (^)(NSInteger likeCount))block NS_SWIFT_NAME(sw_didReceiveStreamerLikeCountUpdate(_:));
- (id<BJLObservation>)sw_didReceiveResponseOfGiftIDSuccess:(BJLControlObserving (^)(NSInteger giftID, BOOL success))block NS_SWIFT_NAME(sw_didReceiveResponseOfGiftIDSuccess(_:));
- (id<BJLObservation>)sw_didReceiveGiftUpdate:(BJLControlObserving (^)(NSArray<NSDictionary<NSString *, NSNumber *> *> *gitInfoArray))block NS_SWIFT_NAME(sw_didReceiveGiftUpdate(_:));
- (id<BJLObservation>)sw_didReceiveNewGift:(BJLControlObserving (^)(NSArray<NSDictionary *> *newGiftArray))block NS_SWIFT_NAME(sw_didReceiveNewGift(_:));
- (id<BJLObservation>)sw_didReceiveUserInWithName:(BJLControlObserving (^)(NSString *userName))block NS_SWIFT_NAME(sw_didReceiveUserInWithName(_:));
@end

NS_ASSUME_NONNULL_END
