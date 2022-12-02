//
//  BJLAnimatedImageView+emoticon.m
//  BJLiveUI
//
//  Created by 凡义 on 2021/12/27.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/NSData+ImageContentType.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLAnimatedImageView+emoticon.h"
#import "BJLAnimatedImage.h"

typedef void (^BJLSDVersion4SetImageBlock)(UIImage *_Nullable image, NSData *_Nullable imageData);
typedef void (^BJLSDVersion5SetImageBlock)(UIImage *_Nullable image, NSData *_Nullable imageData, SDImageCacheType cacheType, NSURL *_Nullable imageURL);

typedef void (^BJLSDVersion4CompletionBlock)(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL);
typedef void (^BJLSDVersion5CompletionBlock)(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL);

@implementation BJLAnimatedImageView (emoticon)

- (void)updateBJLAnimatedImageViewEmotion:(nullable BJLEmoticon *)emoticon
                         emotionURLString:(nullable NSString *)emotionURLString
                                loopCount:(NSUInteger)loopCount
                                completed:(nullable void (^)(UIImage *_Nullable image, NSError *_Nullable error, NSURL *_Nullable imageURL))completedCallback {
    if (!self) {
        return;
    }

    self.image = nil;
    self.animatedImage = nil;

    if (emoticon.cachedAnimatedImageData && [NSData sd_imageFormatForImageData:emoticon.cachedAnimatedImageData] == SDImageFormatGIF) {
        BJLAnimatedImage *animatedImage = [BJLAnimatedImage animatedImageWithGIFData:emoticon.cachedAnimatedImageData loopCount:loopCount];
        self.image = animatedImage.posterImage;
        self.animatedImage = animatedImage;
        if (completedCallback) {
            completedCallback(emoticon.cachedImage, nil, nil);
        }
    }
    else if (emoticon.cachedImage && ![self isGIFURL:emoticon.urlString]) {
        self.image = emoticon.cachedImage;
        if (completedCallback) {
            completedCallback(emoticon.cachedImage, nil, nil);
        }
    }
    else {
        NSString *urlString = emoticon.urlString ?: emotionURLString;
        if (!urlString) {
            return;
        }
        bjl_weakify(self, emoticon);
        NSURL *imageURL = [NSURL URLWithString:urlString];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        // SDWebImage 5.x
        if ([self respondsToSelector:@selector(sd_internalSetImageWithURL:placeholderImage:options:context:setImageBlock:progress:completed:)]) {
            SDWebImageOptions options = 1 << 14 | 1 << 12; // SDWebImageQueryDiskDataSync | SDWebImageQueryMemoryData
            BJLSDVersion5SetImageBlock imageBlock = ^(UIImage *_Nullable image, NSData *_Nullable imageData, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                bjl_strongify(self, emoticon);
                if (!image && !imageData) {
                    return;
                }
                if (imageData && [NSData sd_imageFormatForImageData:imageData] == SDImageFormatGIF) {
                    if (loopCount >= 0) {
                        self.animatedImage = [BJLAnimatedImage animatedImageWithGIFData:imageData loopCount:loopCount];
                    }
                    else {
                        self.animatedImage = [BJLAnimatedImage animatedImageWithGIFData:imageData];
                    }
                }
                else {
                    self.image = image;
                }

                if (emoticon) {
                    emoticon.cachedImage = image;
                    emoticon.cachedAnimatedImageData = imageData;
                }
            };
            BJLSDVersion5CompletionBlock completion = ^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                if (completedCallback) {
                    completedCallback(image, error, imageURL);
                }
            };
            SEL setImage = NSSelectorFromString(@"sd_internalSetImageWithURL:placeholderImage:options:context:setImageBlock:progress:completed:");
            if ([self respondsToSelector:setImage]) {
                [self bjl_invokeWithSelector:setImage arguments:&imageURL, nil, &options, nil, &imageBlock, nil, &completion];
            }
        }
        // SDWebImage 4.x
        else if ([self respondsToSelector:@selector(sd_internalSetImageWithURL:placeholderImage:options:operationKey:setImageBlock:progress:completed:)]) {
            SDWebImageOptions options = 1 << 13 | 1 << 14; // SDWebImageQueryDataWhenInMemory | SDWebImageQueryDiskSync
            BJLSDVersion4SetImageBlock imageBlock = ^(UIImage *_Nullable image, NSData *_Nullable imageData) {
                bjl_strongify(self, emoticon);
                if (!image || !imageData) {
                    return;
                }
                if (imageData && [NSData sd_imageFormatForImageData:imageData] == SDImageFormatGIF) {
                    if (loopCount >= 0) {
                        self.animatedImage = [BJLAnimatedImage animatedImageWithGIFData:imageData loopCount:loopCount];
                    }
                    else {
                        self.animatedImage = [BJLAnimatedImage animatedImageWithGIFData:imageData];
                    }
                }
                else {
                    self.image = image;
                }

                if (emoticon) {
                    emoticon.cachedImage = image;
                    emoticon.cachedAnimatedImageData = imageData;
                }
            };
            BJLSDVersion4CompletionBlock completion = ^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                if (completedCallback) {
                    completedCallback(image, error, imageURL);
                }
            };
            SEL setImage = NSSelectorFromString(@"sd_internalSetImageWithURL:placeholderImage:options:operationKey:setImageBlock:progress:completed:");
            if ([self respondsToSelector:setImage]) {
                [self bjl_invokeWithSelector:setImage arguments:&imageURL, nil, &options, nil, &imageBlock, nil, &completion];
            }
        }
#pragma clang diagnostic pop
        else {
            [self bjl_setImageWithURL:imageURL placeholder:nil completion:completedCallback];
        }
    }
}

/// 初步判断链接是不是gif
- (BOOL)isGIFURL:(NSString *)urlString {
    if (!urlString.length) {
        return NO;
    }

    NSString *format = [urlString pathExtension];
    format = [format componentsSeparatedByString:@"?"].firstObject;

    return [format isEqualToString:@"gif"];
}

@end
