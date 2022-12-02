//
//  BRTCSCreenCaptureLaunch.h
//  BRTC-i
//
//  Created by DeskMac on 2021/1/5.
//  Copyright © 2021 BJY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCMacros.h"
RTC_OBJC_EXPORT

NS_ASSUME_NONNULL_BEGIN

@interface VloudReplaykitLaunch : NSObject
+ (instancetype)sharedInstance;
- (void)launchWithBundleID:(NSString *)bundleID;
@end

NS_ASSUME_NONNULL_END
