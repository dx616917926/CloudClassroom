//
//  BJVSubtitle.h
//  BJVideoPlayerCore
//
//  Created by xijia dai on 2019/12/20.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BJVSubtitle: NSObject

@property (nonatomic, readonly) NSTimeInterval startTime; // format second . millisecond, Accurate to thousands
@property (nonatomic, readonly) NSTimeInterval endTime; // format second . millisecond, Accurate to thousands
@property (nonatomic, readonly) NSString *content; // maybe muti rows, separated by '\n'

@end

@interface BJVSubtitleInfo: NSObject <BJLYYModel>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *ID;
@property (nonatomic, readonly) NSString *urlString;
@property (nonatomic, readonly) BOOL isDefaultSubtitle;
@property (nonatomic, nullable, readonly) NSArray<BJVSubtitle *> *subtitles;

@end

NS_ASSUME_NONNULL_END
