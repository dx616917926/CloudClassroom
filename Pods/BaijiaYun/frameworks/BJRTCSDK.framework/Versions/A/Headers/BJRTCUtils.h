//
//  BJRTCUtils.h
//  BJRTCSDK
//
//  Created by Chengchao on 8/9/18.
//  Copyright © 2018 xinyapeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJRTCUtils : NSObject

+ (NSString *)uuidString;
+ (NSNumber *)doubleToNSNumber:(double)d;
+ (NSInteger)ARDGetCpuUsagePercentage;

@end

@interface NSDictionary (BJRTCUtils)

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString;

@end
