//
//  BJLLoadingVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLLoadingVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLLoadingVM (swift)
- (id<BJLObservation>)sw_loadingUpdateProgress:(BJLControlObserving (^)(CGFloat progress))block NS_SWIFT_NAME(sw_loadingUpdateProgress(_:));
- (id<BJLObservation>)sw_loadingSuccess:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_loadingSuccess(_:));
- (id<BJLObservation>)sw_loadingFailureWithError:(BJLControlObserving (^)(BJLError *_Nullable error))block NS_SWIFT_NAME(sw_loadingFailureWithError(_:));
@end

NS_ASSUME_NONNULL_END
