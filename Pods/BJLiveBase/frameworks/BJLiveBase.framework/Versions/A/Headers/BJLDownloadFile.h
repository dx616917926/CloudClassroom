//
//  BJLDownloadFile.h
//  BJLiveCore
//
//  Created by MingLQ on 2018-08-22.
//  Copyright (c) 2018 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

#import "BJL_M9Dev.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLDownloadFile: NSObject

@property (nonatomic, readonly) NSInteger fileID; // auto-generated and 1-based
@property (nonatomic, readonly) long long expectedFileSize, actualFileSize; // 0: unknown, maybe changed while downloading 
@property (nonatomic, readonly, nullable) NSURL *sourceURL;
@property (nonatomic, readonly) BJLProgress progress;
@property (nonatomic, readonly) BOOL skipped, completed;

@property (nonatomic, readonly, copy, nullable) NSString *fileName, *filePath;
@property (nonatomic, readonly, nullable) NSError *error;

/**
 *  #return YES if file exists at `filePath`
 */
- (BOOL)fileExistsAsDirectory:(nullable BOOL *)isDirectory;

+ (nullable instancetype)fileWithSourceURL:(NSURL *)sourceURL
                          expectedFileSize:(long long)expectedFileSize; // 0: unknown

@end

NS_ASSUME_NONNULL_END
