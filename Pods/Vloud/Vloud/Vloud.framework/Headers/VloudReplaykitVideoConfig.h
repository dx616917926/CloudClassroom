//
//  VloudReplaykitVideoConfig.h
//  products
//
//  Created by DeskMac on 2021/2/4.
//

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudReplaykitVideoConfig : NSObject

/// 视频宽 默认1280
@property (nonatomic, assign) int32_t width;

/// 视频高 默认720
@property (nonatomic, assign) int32_t height;

/// 视频码率 kbps 默认1200
@property (nonatomic, assign) int32_t bandWidth;

/// 帧率 默认10
@property (nonatomic, assign) int32_t fps;

/// 方向 默认横屏
@property (nonatomic, assign) BOOL isLanscape;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
