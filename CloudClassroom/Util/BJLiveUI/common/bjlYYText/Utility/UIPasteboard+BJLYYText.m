//
//  UIPasteboard+YYText.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/2.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIPasteboard+BJLYYText.h"
#import "NSAttributedString+BJLYYText.h"
#import <MobileCoreServices/MobileCoreServices.h>

#if __has_include("YYImage.h")
#import "YYImage.h"
#define BJLYYTextAnimatedImageAvailable 1
#elif __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYImage.h>
#define BJLYYTextAnimatedImageAvailable 1
#elif __has_include(<YYWebImage/YYImage.h>)
#import <YYWebImage/YYImage.h>
#define BJLYYTextAnimatedImageAvailable 1
#else
#define BJLYYTextAnimatedImageAvailable 0
#endif

// Dummy class for category
@interface UIPasteboard_BJLYYText: NSObject
@end
@implementation UIPasteboard_BJLYYText
@end

NSString *const BJLYYTextPasteboardTypeAttributedString = @"com.ibireme.NSAttributedString";
NSString *const BJLYYTextUTTypeWEBP = @"com.google.webp";

@implementation UIPasteboard (BJLYYText)

- (void)setBjlyy_PNGData:(NSData *)PNGData {
    [self setData:PNGData forPasteboardType:(id)kUTTypePNG];
}

- (NSData *)bjlyy_PNGData {
    return [self dataForPasteboardType:(id)kUTTypePNG];
}

- (void)setBjlyy_JPEGData:(NSData *)JPEGData {
    [self setData:JPEGData forPasteboardType:(id)kUTTypeJPEG];
}

- (NSData *)bjlyy_JPEGData {
    return [self dataForPasteboardType:(id)kUTTypeJPEG];
}

- (void)setBjlyy_GIFData:(NSData *)GIFData {
    [self setData:GIFData forPasteboardType:(id)kUTTypeGIF];
}

- (NSData *)bjlyy_GIFData {
    return [self dataForPasteboardType:(id)kUTTypeGIF];
}

- (void)setBjlyy_WEBPData:(NSData *)WEBPData {
    [self setData:WEBPData forPasteboardType:BJLYYTextUTTypeWEBP];
}

- (NSData *)bjlyy_WEBPData {
    return [self dataForPasteboardType:BJLYYTextUTTypeWEBP];
}

- (void)setBjlyy_ImageData:(NSData *)imageData {
    [self setData:imageData forPasteboardType:(id)kUTTypeImage];
}

- (NSData *)bjlyy_ImageData {
    return [self dataForPasteboardType:(id)kUTTypeImage];
}

- (void)setBjlyy_AttributedString:(NSAttributedString *)attributedString {
    self.string = [attributedString bjlyy_plainTextForRange:NSMakeRange(0, attributedString.length)];
    NSData *data = [attributedString bjlyy_archiveToData];
    if (data) {
        NSDictionary *item = @{BJLYYTextPasteboardTypeAttributedString: data};
        [self addItems:@[item]];
    }
    [attributedString enumerateAttribute:BJLYYTextAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(BJLYYTextAttachment *attachment, NSRange range, BOOL *stop) {
        // save image
        UIImage *simpleImage = nil;
        if ([attachment.content isKindOfClass:[UIImage class]]) {
            simpleImage = attachment.content;
        }
        else if ([attachment.content isKindOfClass:[UIImageView class]]) {
            simpleImage = ((UIImageView *)attachment.content).image;
        }
        if (simpleImage) {
            NSDictionary *item = @{@"com.apple.uikit.image": simpleImage};
            [self addItems:@[item]];
        }

#if BJLYYTextAnimatedImageAvailable
        // save animated image
        if ([attachment.content isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = attachment.content;
            Class aniImageClass = NSClassFromString(@"YYImage");
            UIImage *image = imageView.image;
            if (aniImageClass && [image isKindOfClass:aniImageClass]) {
                NSData *data = [image valueForKey:@"animatedImageData"];
                NSNumber *type = [image valueForKey:@"animatedImageType"];
                if (data) {
                    switch (type.unsignedIntegerValue) {
                        case YYImageTypeGIF: {
                            NSDictionary *item = @{(id)kUTTypeGIF: data};
                            [self addItems:@[item]];
                        } break;
                        case YYImageTypePNG: { // APNG
                            NSDictionary *item = @{(id)kUTTypePNG: data};
                            [self addItems:@[item]];
                        } break;
                        case YYImageTypeWebP: {
                            NSDictionary *item = @{(id)BJLYYTextUTTypeWEBP: data};
                            [self addItems:@[item]];
                        } break;
                        default:
                            break;
                    }
                }
            }
        }
#endif
    }];
}

- (NSAttributedString *)bjlyy_AttributedString {
    for (NSDictionary *items in self.items) {
        NSData *data = items[BJLYYTextPasteboardTypeAttributedString];
        if (data) {
            return [NSAttributedString bjlyy_unarchiveFromData:data];
        }
    }
    return nil;
}

@end
