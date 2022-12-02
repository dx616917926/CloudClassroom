//
//  NSData+BJLImageFormat.h
//  BJLImageFormat
//
//  Created by Ney on 9/6/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BJLImageFormat) {
    BJLImageFormatUndefined = -1,
    BJLImageFormatJPEG = 0,
    BJLImageFormatPNG,
    BJLImageFormatGIF,
    BJLImageFormatTIFF,
    BJLImageFormatWebP,
    BJLImageFormatHEIC,
    BJLImageFormatHEIF
};

NS_ASSUME_NONNULL_BEGIN

@interface NSData (BJLImageFormat)
- (BJLImageFormat)bjl_imageFormat;
- (NSString *)bjl_imageFormatString;
@end

NS_ASSUME_NONNULL_END
