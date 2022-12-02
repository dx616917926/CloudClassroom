//
//  BJVUserVideo.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2020/3/9.
//  Copyright © 2020 BaijiaYun. All rights reserved.

//  上麦学生的视频回放

#import <Foundation/Foundation.h>

#import "BJVDefinitionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJVUserVideo: NSObject

// 发言学生的id
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *format;
@property (nonatomic, readonly) NSString *cover;
@property (nonatomic, readonly) NSString *videoId;
@property (nonatomic, readonly) NSInteger audioSize;
@property (nonatomic, readonly) NSString *defaultDefinition;

@property (nonatomic, readonly) NSArray<BJVDefinitionInfo *> *definitionList;

@end

NS_ASSUME_NONNULL_END
