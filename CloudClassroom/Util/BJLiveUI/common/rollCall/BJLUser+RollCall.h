//
//  RollCall.h
//  BJLiveUIBase
//
//  Created by 凡义 on 2022/4/21.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLUser (RollCall)

- (BOOL)canLaunchRollCallWithRoom:(BJLRoom *)room;

@end

NS_ASSUME_NONNULL_END
