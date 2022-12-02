//
//  BJVDownloadManager.h
//  BJVideoPlayerCore
//
//  Created by MingLQ on 2018-04-03.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJVPlayInfo.h"

NS_ASSUME_NONNULL_BEGIN

@compatibility_alias BJVDownloadFile BJLDownloadFile;
@compatibility_alias BJVDownloadManager BJLDownloadManager;

#pragma mark -

@interface BJVDownloadItem: BJLDownloadItem

/** 点播视频 ID*/
@property (nonatomic, readonly, nullable) NSString *videoID;
/** 回放课程、课节 ID*/
@property (nonatomic, readonly, nullable) NSString *classID, *sessionID;
/** 是否为回放 item*/
@property (nonatomic, readonly) BOOL isPlayback;
/** 文件是否加密*/
@property (nonatomic, readonly) BOOL isEncrypted;
/** 裁剪过的回放视频的version, 0: 裁剪前的原始视频, -1: 裁剪后的主版本视频 */
@property (nonatomic, readonly) NSInteger clipedVersion;
/** 视频播放信息*/
@property (nonatomic, readonly, nullable) BJVPlayInfo *playInfo;

/** 视频、信令文件 */
@property (nonatomic, readonly, nullable) BJVDownloadFile *videoFile, *signalFile;
/** 封面、水印图片*/
@property (nonatomic, readonly, nullable) BJVDownloadFile *coverImageFile, *watermarkImageFile;
/** 字幕 */
@property (nonatomic, readonly, nullable) NSArray<BJVDownloadFile *> *subtitleFiles;
/** 视频清晰度*/
@property (nonatomic, readonly) BJVDefinitionInfo *currentDefinitionInfo;

#pragma mark - readwrite

/** token、集成方鉴权参数*/
@property (nonatomic, nullable) NSString *token, *accessKey;
/** 集成方自定义信息*/
@property (nonatomic, nullable) NSDictionary *userInfo;

@end

#pragma mark -

@interface BJVDownloadManager (BJVDownloadItem)

/**
 校验下载任务对象是否可以添加
 
 #return 是否可添加
 #discussion clipedVersion，裁剪后的回放视频的version,   -1: 裁剪后的主版本,  0: 裁剪前的原始视频
 #discussion 已经添加过/已下载完成 的任务，方法返回 NO
 */
- (BOOL)validateItemWithVideoID:(NSString *)videoID;
- (BOOL)validateItemWithClassID:(NSString *)classID sessionID:(nullable NSString *)sessionID;
- (BOOL)validateItemWithClassID:(NSString *)classID sessionID:(nullable NSString *)sessionID clipedVersion:(NSInteger)clipedVersion;
- (BOOL)validateItemWithPlayInfo:(BJVPlayInfo *)playInfo;

/**
 点播
 #param videoID      视频 ID
 #param encrypted    是否加密
 #param preferredDefinitionList 下载清晰度列表，按顺序匹配、没有匹配将导致下载失败，传 nil 使用默认清晰度
 #discussion preferredDefinitionList 列表元素为清晰度的标识字符串，现有标识符：low（标清），high（高清），superHD（超清），720p，1080p，audio（纯音频），可根据实际情况动态扩展
 #param setting      添加成功后用于设置 item 属性的回调
 #return 添加成功返回 BJVDownloadItem 实例，videoID 已存在会返回 nil
 */
- (nullable BJVDownloadItem *)addDownloadItemWithVideoID:(NSString *)videoID
                                               encrypted:(BOOL)encrypted
                                 preferredDefinitionList:(nullable NSArray<NSString *> *)preferredDefinitionList;
- (nullable BJVDownloadItem *)addDownloadItemWithVideoID:(NSString *)videoID
                                               encrypted:(BOOL)encrypted
                                 preferredDefinitionList:(nullable NSArray<NSString *> *)preferredDefinitionList
                                                 setting:(nullable void (^)(BJVDownloadItem *item))setting;

/**
 回放
 #param classID      课程 ID
 #param sessionID    课节 ID
 #param encrypted    是否加密
 #param preferredDefinitionList  下载清晰度列表，列表元素为 NSNumber<BJVDefinitionType> *，按顺序匹配、没有匹配将导致下载失败，传 nil 使用默认清晰度
 #discussion preferredDefinitionList 列表元素为清晰度的标识字符串，现有标识符：low（标清），high（高清），superHD（超清），720p，1080p，audio（纯音频），可根据实际情况动态扩展
 #param clipedVersion  裁剪后的回放视频的version,   -1: 裁剪后的主版本,  0: 裁剪前的原始视频
 #param setting      添加成功后用于设置 item 属性的回调
 #return 添加成功返回 BJVDownloadItem 实例，classID+sessionID 已存在会返回 nil
 */
- (nullable BJVDownloadItem *)addDownloadItemWithClassID:(NSString *)classID
                                               sessionID:(nullable NSString *)sessionID
                                               encrypted:(BOOL)encrypted
                                 preferredDefinitionList:(nullable NSArray<NSString *> *)preferredDefinitionList;

- (nullable BJVDownloadItem *)addDownloadItemWithClassID:(NSString *)classID
                                               sessionID:(nullable NSString *)sessionID
                                               encrypted:(BOOL)encrypted
                                 preferredDefinitionList:(nullable NSArray<NSString *> *)preferredDefinitionList
                                                 setting:(nullable void (^)(BJVDownloadItem *item))setting;

- (nullable BJVDownloadItem *)addDownloadItemWithClassID:(NSString *)classID
                                               sessionID:(nullable NSString *)sessionID
                                               encrypted:(BOOL)encrypted
                                 preferredDefinitionList:(nullable NSArray<NSString *> *)preferredDefinitionList
                                           clipedVersion:(NSInteger)clipedVersion
                                                 setting:(nullable void (^)(BJVDownloadItem *item))setting;

@end

NS_ASSUME_NONNULL_END
