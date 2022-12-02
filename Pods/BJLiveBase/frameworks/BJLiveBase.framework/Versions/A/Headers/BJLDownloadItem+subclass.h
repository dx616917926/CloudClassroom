//
//  BJLDownloadItem+subclass.h
//  BJLiveBase
//
//  Created by MingLQ on 2018-08-22.
//  Copyright (c) 2018 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

#import "BJLDownloadItem.h"

/**
 *  for subclasses
 */

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * BJLDownloadItemStateString(BJLDownloadItemState state);

FOUNDATION_EXPORT BJLError * BJLDownloadErrorMakeFromError(BJLDownloadErrorCode errorCode,
                                                           NSString * _Nullable description,
                                                           NSError * _Nullable sourceError);
FOUNDATION_EXPORT BJLError * BJLDownloadErrorMake(BJLDownloadErrorCode errorCode,
                                                  NSString * _Nullable description);

#pragma mark -

@protocol BJLDownloadItem <NSObject, BJLYYModel>

@required

/**
 *  subclasses MUST override this method, and MUST call completion
 *  #completion-param downloadFiles single or multiple files to download
 *  #completion-param error         complete with error
 */
- (void)requestDownloadFilesWithCompletion:(void (NS_NOESCAPE ^)(NSArray<BJLDownloadFile *> * _Nullable downloadFiles, NSError * _Nullable error))completion;

@optional

/**
 *  subclasses override to handle file download failure with task.response or file.error ?: task.error
 *  #completion-param sourceURL     retry download with sourceURL, or nil - complete with error / complete by skipping file
 *  #completion-param skipOrFail    effective if sourceURL is nil, NO - complete with error, YES - skip this file
 */
- (void)didFailToDownloadFile:(BJLDownloadFile *)file
                         task:(nullable NSURLSessionTask *)task
                   completion:(void (^)(NSURL * _Nullable sourceURL, BOOL skip))completion;

/**
 *  subclasses override to handle file download success
 *  e.g. validate file with MD5 checksum
 *  e.g. uncompress a new file to the `file.filePath`
 *  internal validating:
 *      valide = fileSize > 0 && (expectedFileSize <= 0 || fileSize == expectedFileSize)
 *  #completion-param success   success or failure
 *  #completion-param error     error
 */
- (void)didDownloadFile:(BJLDownloadFile *)file
                   task:(nullable NSURLSessionTask *)task
             completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@end

#pragma mark -

@interface BJLDownloadItem () <BJLYYModel>

- (instancetype)initWithItemIdentifier:(NSString *)itemIdentifier;

- (void)serializeDownloadFiles;
- (BOOL)deserializeDownloadFiles;

/**
 *  <YYModel>
 *  !!!: subclasses must call super when override methods of <YYModel>
 *      + (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
 *          Class superClass = self.superclass;
 *          NSMutableDictionary<NSString *, id> *mapper = ([superClass respondsToSelector:_cmd]
 *                                                         ? [superClass.modelCustomPropertyMapper mutableCopy]
 *                                                         : [NSMutableDictionary new]);
 *          [mapper addEntriesFromDictionary:@{ BJLInstanceKeypath(BJLCustomDownloadItem, userInfo): @"userInfo",
 *                                              ... }];
 *          return mapper;
 *      }
 */

@end

NS_ASSUME_NONNULL_END
