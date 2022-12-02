//
//  BJLiveUIBase.m
//  BJLiveUIBase
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLiveUIBase.h"

NSString *BJLiveUIBaseName(void) {
    return BJLStringFromPreprocessor(BJLIVEUI_BASE_NAME, @"BJLiveUIBase");
}

NSString *BJLiveUIBaseVersion(void) {
    return BJLStringFromPreprocessor(BJLIVEUI_BASE_VERSION, @"-");
}
