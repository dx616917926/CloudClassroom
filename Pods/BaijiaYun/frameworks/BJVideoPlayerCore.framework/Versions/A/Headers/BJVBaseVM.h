//
//  BJVBaseVM.h
//  BJVideoPlayerCore
//
//  Created by HuangJie on 2018/5/19.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

@class BJVContext;

@interface BJVBaseVM: NSObject

NS_ASSUME_NONNULL_BEGIN

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)instanceWithContext:(BJVContext *)context;
- (instancetype)initWithContext:(BJVContext *)context NS_DESIGNATED_INITIALIZER;

NS_ASSUME_NONNULL_END

@end
