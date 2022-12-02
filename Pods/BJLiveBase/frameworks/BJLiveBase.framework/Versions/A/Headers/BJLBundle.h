//
//  BJLBundle.h
//  BJLiveBase
//
//  Created by xijia dai on 2020/12/10.
//  Copyright (c) 2020 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLBundle: NSObject
+ (NSBundle *)localizeBundle;
+ (NSBundle *)metalBundle;
@end

static inline NSString *BJLLocalizedString(NSString *key) NS_FORMAT_ARGUMENT(1);
static inline NSString *BJLLocalizedString(NSString *key) {
    return [[BJLBundle localizeBundle] localizedStringForKey:(key) value:@"" table:@"Localizable"] ?: key;
}

#define BJLConstantString(key) key

NS_ASSUME_NONNULL_END
