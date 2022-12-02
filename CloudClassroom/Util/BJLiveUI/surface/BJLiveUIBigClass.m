//
//  BJLiveUIBigClass.m
//  BJLiveUIBigClass
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLiveUIBigClass.h"

NSString *BJLiveUIBigClassName(void) {
    return BJLStringFromPreprocessor(BJLIVEUI_BIG_CLASS_NAME, @"BJLiveUIBigClass");
}

NSString *BJLiveUIBigClassVersion(void) {
    return BJLStringFromPreprocessor(BJLIVEUI_BIG_CLASS_VERSION, @"-");
}
