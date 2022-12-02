//
//  BJLDownloadManager.h
//  BJLiveBase
//
//  Created by MingLQ on 2018-02-09.
//  Copyright (c) 2018 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

// BJLiveBase/Base
#import "BJL_M9Dev.h"
#import "NSObject+BJLObserving.h"

#import "BJLDownloadItem.h"
#import "BJLDownloadItem+subclass.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BJLDownloadManagerClassDelegate, BJLDownloadManagerDelegate;

/**
 *  !!!: NOT Thread-Safe
 */
@interface BJLDownloadManager: NSObject

#pragma mark - items

@property (nonatomic, readonly, copy) NSArray<__kindof BJLDownloadItem *> *downloadItems;
- (nullable NSMutableArray<__kindof BJLDownloadItem *> *)downloadItemsWithStates:(BJLDownloadItemState)state, ...; // !!!: REQUIRES NSNotFound TERMINATION
- (nullable NSMutableArray<__kindof BJLDownloadItem *> *)downloadItemsWithStatesArray:(NSArray<NSNumber *> *)statesArray; // for Swift

/**
 *  #param itemIdentifier       MUST be unique in the instance of `BJLDownloadManager`
 *  #param downloadItemClass    MUST be a subclass of #class `BJLDownloadItem` and conforms to #protocol `BJLDownloadItem`
 *  #param setting              setting properties of instance after alloc-init
 *  #return instance of `downloadItemClass`, or nil if any param is invalid
 *  #see methods `validateItemIdentifier:` and `validateItemClass:`
 *  #discussion call `resume` of `BJLDownloadItem` to start downloading
 */
- (nullable __kindof BJLDownloadItem *)addDownloadItemWithIdentifier:(NSString *)itemIdentifier
                                                           itemClass:(Class)itemClass
                                                             setting:(void (^)(__kindof BJLDownloadItem *item))setting;
/**
 *  #param itemIdentifier       `itemIdentifier` of `BJLDownloadItem` to remove
 *  #discussion cancel tasks, remove files and remove download item
 */
- (void)removeDownloadItemWithIdentifier:(NSString *)itemIdentifier;

- (BOOL)validateItemIdentifier:(NSString *)itemIdentifier;
- (BOOL)validateItemClass:(Class)itemClass;

#pragma mark - managers

/** identifier for `BJLDownloadManager` and `NSURLSession` */
@property (nonatomic, readonly, copy) NSString *identifier;
/** download files into `Library/Application Support/` by default, or `Library/Caches/` if `inCaches` is YES */
@property (nonatomic, readonly) BOOL inCaches;

/**
 *  #discussion instance delegate for observing `BJLDownloadItem` changes
 */
@property (nonatomic, weak, nullable) id<BJLDownloadManagerDelegate> delegate;

/**
 *  #param identifier   identifier for `BJLDownloadManager` and `NSURLSession`
 *  #param inCaches     download files into `Library/Application Support/` by default, or `Library/Caches/` if `inCaches` is YES
 *  #discussion Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed.
 *  #see <Where You Should Put Your App’s Files> - https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28
 *  #see <Accessing Files and Directories> - https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/AccessingFilesandDirectories/AccessingFilesandDirectories.html
 */
+ (instancetype)downloadManagerWithIdentifier:(NSString *)identifier;
+ (instancetype)downloadManagerWithIdentifier:(NSString *)identifier inCaches:(BOOL)inCaches;

/**
 *  #return all managers
 */
+ (NSArray<BJLDownloadManager *> *)downloadManagers;

/**
 *  #param completion   refresh completion, DONOT add, remove, resume, pause, restart or suspend any task before completion is called
 *  #discussion refresh url session for changing configuration, will call `downloadManager:configuration:` of `BJLDownloadManagerClassDelegate`
 */
- (void)refreshURLSessionWithCompletion:(void (^)(BJLDownloadManager *downloadManager))completion;

/**
 *  #discussion destroy manager, cancel tasks and remove files
 */
- (void)destroyAndRemoveFiles;

/**
 *  !!!: if implemented this method in `UIApplicationDelegate`, MUST forward to `BJLDownloadManager`:
 *  - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
 *      [BJLDownloadManager handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
 *  }
 */
+ (void)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

/**
 *  #discussion class delegate for configuring `NSURLSessionConfiguration`
 */
+ (nullable id<BJLDownloadManagerClassDelegate>)classDelegate;
+ (void)setClassDelegate:(nullable id<BJLDownloadManagerClassDelegate>)classDelegate;

@end

@protocol BJLDownloadManagerClassDelegate <NSObject>
@optional
/**
 *  #discussion called before creating NSURLSession
 *  #param downloadManager  BJLDownloadManager instance
 *  #param configuration    NSURLSessionConfiguration for configuring NSURLSession which created by `backgroundSessionConfigurationWithIdentifier:`
 *      #see <Downloading Files in the Background> - https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background
 */
- (void)downloadManager:(BJLDownloadManager *)downloadManager
URLSessionConfiguration:(NSURLSessionConfiguration *)configuration;
@end

@protocol BJLDownloadManagerDelegate <NSObject>
@optional
/**
 *  #discussion notify changes of BJLDownloadItem properties, except `progress` and `bytesPerSecond`
 *  #param downloadManager  BJLDownloadManager instance
 *  #param downloadItem     BJLDownloadItem or subclass instance
 *  #param change           change info of downloadItem property
 */
- (void)downloadManager:(BJLDownloadManager *)downloadManager
           downloadItem:(__kindof BJLDownloadItem *)downloadItem
              didChange:(BJLPropertyChange *)change;
@end

NS_ASSUME_NONNULL_END
