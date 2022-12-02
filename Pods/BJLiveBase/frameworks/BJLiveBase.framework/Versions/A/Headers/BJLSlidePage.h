//
//  BJLSlidePage.h
//  BJLiveCore
//
//  Created by HuangJie on 2018/9/13.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJLDocument.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLSlidePage: NSObject

@property (nonatomic, readonly) NSInteger slidePageIndex; // slidePageNumber = slidePageIndex + 1
@property (nonatomic, readonly) NSInteger step; // 用于 h5 PPT
@property (nonatomic, readonly) NSString *documentID;
@property (nonatomic, readonly) NSInteger documentPageIndex; // maybe incorrect if allDocuments changed
@property (nonatomic, readonly) NSInteger width, height;
@property (nonatomic, readonly, nullable) NSString *pageURLString; // image

/**
 size:  CGSizeMake(1280.0, 720.0) || CGSizeMake(1920.0, 1080.0) || CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
 scale: 0.0 for screen.scale
 fill:  fill, or fit
 ext:   jpg, png, webp, bmp, gif, src
 */
- (nullable NSURL *)pageURLWithSize:(CGSize)size
                              scale:(CGFloat)scale
                               fill:(BOOL)fill
                             format:(nullable NSString *)ext;
- (nullable NSString *)pageURLStringWithSize:(CGSize)size
                                       scale:(CGFloat)scale
                                        fill:(BOOL)fill
                                      format:(nullable NSString *)ext;

/** scale: 1.0 */
- (nullable NSURL *)pageURLWithSize:(CGSize)size
                               fill:(BOOL)fill
                             format:(nullable NSString *)ext;
- (nullable NSString *)pageURLStringWithSize:(CGSize)size
                                        fill:(BOOL)fill
                                      format:(nullable NSString *)ext;

+ (NSArray<BJLSlidePage *> *)slidePagesWithDocuments:(NSArray<BJLDocument *> *)documents;

#pragma mark -

/** 当前图片品质，YES: 原图，NO: 流畅，默认为 NO */
@property (nonatomic, class) BOOL imageQualityIsOriginal;

#pragma mark -

/** 用于获取当前可用 CDN 加载图片 */
+ (NSURL *)pageURLWithCurrentCDNHost:(NSURL *)imageURL;

/** 用于切换 CDN 重试加载图片 */
+ (NSURL *)pageURLBySwitchingCDNHost:(NSURL *)failedURL;

/** 设置默认 CDN、CDN 列表 */
+ (void)setDefaultHost:(NSString *)defaultHost
              cdnHosts:(NSArray *)cdnHosts;

@end

NS_ASSUME_NONNULL_END
