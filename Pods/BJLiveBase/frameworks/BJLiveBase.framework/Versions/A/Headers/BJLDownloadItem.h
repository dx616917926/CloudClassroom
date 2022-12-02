//
//  BJLDownloadItem.h
//  BJLiveBase
//
//  Created by MingLQ on 2018-06-13.
//  Copyright (c) 2018 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

// BJLiveBase/Base
#import "BJL_M9Dev.h"
#import "BJLError.h"
#import "NSObject+BJLObserving.h"

// BJLiveBase/Networking
#import "BJLNetworking.h"

// BJLiveBase/YYModel
#import "BJLYYModel.h"

#import "BJLDownloadFile.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLDownloadItemState) {
    BJLDownloadItemState_invalid = - 1, // NOT be added to any BJLDownloadManager, or be invalidated
    BJLDownloadItemState_running,
    BJLDownloadItemState_paused, // paused + error = error occurred
    BJLDownloadItemState_completed // completed + error = file lost
};

FOUNDATION_EXPORT NSErrorDomain const BJLDownloadErrorDomain;
typedef NS_ERROR_ENUM(BJLDownloadErrorDomain, BJLDownloadErrorCode) {
    BJLDownloadErrorCode_requestFileInfoFailed,
    BJLDownloadErrorCode_noSpaceLeft,
    BJLDownloadErrorCode_invalidFileInfo,
    BJLDownloadErrorCode_invalidFileSize,
    BJLDownloadErrorCode_invalidFileData,
    BJLDownloadErrorCode_downloadFileFailed,
    BJLDownloadErrorCode_fileLost
};

FOUNDATION_EXPORT NSString * const BJLDownloadItemClassKey;

#pragma mark -

/**
 *  abstract class
 *  #see protocol `BJLDownloadItem`
 *  !!!: NOT Thread-Safe
 */
@interface BJLDownloadItem: NSObject

@property (nonatomic, readonly, copy) NSString *itemIdentifier;

/** totalSize
 *  totalSize maybe changed while downloading
 */
@property (nonatomic, readonly) long long totalSize;
/** progress
 *  progress.totalUnitCount maybe changed while downloading
 *  download-finished != download-completed
 *  - download-finished: progress.finished (progress.totalUnitCount == totalSize)
 *  - download-completed: state == BJLDownloadItemState_completed && !error
 */
@property (nonatomic, readonly) BJLProgress progress;
/** bytesPerSecond */
@property (nonatomic, readonly) long long bytesPerSecond; // available when `state == running`

/** state
 *  completed: success if no error, or lost file with error
 *  paused: pause if no error, or failed with error
 */
@property (nonatomic, readonly) BJLDownloadItemState state;
@property (nonatomic, readonly, nullable) BJLError *error; // available when state changed

/** priority
 *  0.0 - 1.0, NSURLSessionTaskPriorityDefault by default
 *  #see NSURLSessionTask.priority
 */
@property (nonatomic) float priority;

@property (nonatomic, readonly, copy, nullable) NSArray<BJLDownloadFile *> *downloadFiles;

- (void)resume;
- (void)pause;

/**
 *  #return NO if any file is invalid, update the `state` and `error`
 *  #see `state` and `error`
 */
- (BOOL)validateStateAndDownloadFiles;

- (BOOL)compareWithProgress:(BJLProgress)progress bytesPerSecond:(long long)bytesPerSecond;

@end

NS_ASSUME_NONNULL_END
