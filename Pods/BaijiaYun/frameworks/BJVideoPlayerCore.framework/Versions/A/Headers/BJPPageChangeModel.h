//
//  BJPPageChangeModel.h
//  BJVideoPlayerCore
//
//  Created by 凡义 on 2021/1/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BJPPageChangeModel: NSObject <BJLYYModel>

@property (readonly, nonatomic) NSString *documentID;
@property (readonly, nonatomic) NSUInteger page; // 在当前课件中的页码, 从0开始
@property (readonly, nonatomic) NSUInteger step;
@property (readonly, nonatomic) NSDictionary *event;
@property (readonly, nonatomic) NSInteger msOffsetTimestamp; // 毫秒级翻页时间

@end

NS_ASSUME_NONNULL_END
