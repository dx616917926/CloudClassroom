//
//  BJLWeakArray.h
//  BJLiveBase
//
//  Created by MingLQ on 2020-06-17.
//  Copyright (c) 2020 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLWeakArray: NSMutableArray

- (void)compact; // eliminate NULLs

@end

NS_ASSUME_NONNULL_END
