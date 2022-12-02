//
//  BJLHelpVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLHelpVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLHelpVM (swift)
- (id<BJLObservation>)sw_requestForHelpDidFinish:(BJLControlObserving (^)(BOOL success))block NS_SWIFT_NAME(sw_requestForHelpDidFinish(_:));
@end

NS_ASSUME_NONNULL_END
