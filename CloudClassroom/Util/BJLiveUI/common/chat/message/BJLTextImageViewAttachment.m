//
//  BJLTextImageViewAttachment.m
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/12/24.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/NSData+ImageContentType.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLTextImageViewAttachment.h"
#import "BJLAnimatedImage.h"

typedef void (^BJLSDVersion4AttachmentSetImageBlock)(UIImage *_Nullable image, NSData *_Nullable imageData);
typedef void (^BJLSDVersion5AttachmentSetImageBlock)(UIImage *_Nullable image, NSData *_Nullable imageData, SDImageCacheType cacheType, NSURL *_Nullable imageURL);

@interface BJLTextImageViewAttachment ()

@property (nonatomic, strong) BJLAnimatedImageView *imageView;

@end

@implementation BJLTextImageViewAttachment

- (void)setContent:(id)content {
    _imageView = content;
}

- (id)content {
    if (_imageView)
        return _imageView;

    _imageView = [BJLAnimatedImageView new];
    _imageView.backgroundColor = [UIColor clearColor];
    CGRect imageFrame = CGRectZero;
    imageFrame.size = _size;
    _imageView.frame = imageFrame;

    bjl_weakify(self);
    NSURL *imageURL = self.imageURL;
    UIImageView *imageView = self.imageView;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // SDWebImage 5.x
    if ([imageView respondsToSelector:@selector(sd_internalSetImageWithURL:placeholderImage:options:context:setImageBlock:progress:completed:)]) {
        SDWebImageOptions options = 1 << 14 | 1 << 12; // SDWebImageQueryDiskDataSync | SDWebImageQueryMemoryData
        BJLSDVersion5AttachmentSetImageBlock imageBlock = ^(UIImage *_Nullable image, NSData *_Nullable imageData, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
            bjl_strongify(self);
            if (!image && !imageData) {
                return;
            }
            if ([NSData sd_imageFormatForImageData:imageData] != SDImageFormatGIF) {
                self.imageView.image = image;
            }
            else {
                self.imageView.animatedImage = [BJLAnimatedImage animatedImageWithGIFData:imageData loopCount:0];
            }
        };
        SEL setImage = NSSelectorFromString(@"sd_internalSetImageWithURL:placeholderImage:options:context:setImageBlock:progress:completed:");
        if ([imageView respondsToSelector:setImage]) {
            [imageView bjl_invokeWithSelector:setImage arguments:&imageURL, nil, &options, nil, &imageBlock, nil, nil];
        }
    }
    // SDWebImage 4.x
    else if ([imageView respondsToSelector:@selector(sd_internalSetImageWithURL:placeholderImage:options:operationKey:setImageBlock:progress:completed:)]) {
        SDWebImageOptions options = 1 << 13 | 1 << 14; // SDWebImageQueryDataWhenInMemory | SDWebImageQueryDiskSync
        BJLSDVersion4AttachmentSetImageBlock imageBlock = ^(UIImage *_Nullable image, NSData *_Nullable imageData) {
            bjl_strongify(self);
            if (!image || !imageData) {
                return;
            }
            if ([NSData sd_imageFormatForImageData:imageData] != SDImageFormatGIF) {
                self.imageView.image = image;
            }
            else {
                self.imageView.animatedImage = [BJLAnimatedImage animatedImageWithGIFData:imageData loopCount:0];
            }
        };
        SEL setImage = NSSelectorFromString(@"sd_internalSetImageWithURL:placeholderImage:options:operationKey:setImageBlock:progress:completed:");
        if ([imageView respondsToSelector:setImage]) {
            [imageView bjl_invokeWithSelector:setImage arguments:&imageURL, nil, &options, nil, &imageBlock, nil, nil];
        }
    }
#pragma clang diagnostic pop
    else {
        [_imageView bjl_setImageWithURL:imageURL];
    }
    return _imageView;
}

@end
