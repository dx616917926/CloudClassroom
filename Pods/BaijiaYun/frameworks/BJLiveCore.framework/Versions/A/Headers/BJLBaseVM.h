//
//  BJLBaseVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-11-29.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLConstants.h"
#import "NSError+BJLError.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLBaseVM: NSObject

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
