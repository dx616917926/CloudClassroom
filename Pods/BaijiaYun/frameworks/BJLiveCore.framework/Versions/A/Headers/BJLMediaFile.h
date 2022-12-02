//
//  BJLMediaFile.h
//  BJLiveCore
//
//  Created by xijia dai on 2021/7/28.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLMediaFileInfo: NSObject

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly) NSInteger duration;
@property (nonatomic, readonly) NSString *urlString;
@property (nonatomic, readonly) NSInteger size;

@end

@interface BJLMediaFile: NSObject

@property (nonatomic, readonly) NSString *fileID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *format;
@property (nonatomic, readonly) NSString *cover;
@property (nonatomic, readonly) NSArray<BJLMediaFileInfo *> *infos;
@property (nonatomic, readonly) BOOL isRelatedDocument;

@end

NS_ASSUME_NONNULL_END
