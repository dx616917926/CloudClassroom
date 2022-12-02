//
//  VloudSniffer.h
//  sources
//
//  Created by lw0717 on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudSniffer : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

- (void)destroy;

- (void)startWithUrl:(NSString *)url;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
