//
//  BJLAward.h
//  BJLiveCore
//
//  Created by xyp on 2020/7/30.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 多种奖励配置
@interface BJLAward: NSObject <NSCopying>

@property (nonatomic, readonly) BOOL enable;
@property (nonatomic, readonly, copy) NSString *key, *logo, *name, *picture;

+ (nullable instancetype)awardForKey:(NSString *)key;
+ (nullable instancetype)awardForName:(NSString *)name;

+ (NSArray<BJLAward *> *)allAwards;
+ (void)setAllAwards:(NSArray<BJLAward *> *)allAwards;

@end

NS_ASSUME_NONNULL_END
