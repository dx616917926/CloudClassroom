//
//  BJLLamp.h
//  BJLiveCore
//
//  Created by 凡义 on 2019/10/16.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLLampDisplayMode) {
    BJLLampDisplayModeRoll = 1,
    BJLLampDisplayModeBlink = 2,
};

@interface BJLLamp: NSObject

@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) CGFloat fontSize;
@property (nonatomic, readonly) NSString *color;
@property (nonatomic, readonly) BOOL isBold;
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSString *backgroundColor;
@property (nonatomic, readonly) BJLLampDisplayMode displayMode;
@property (nonatomic, readonly) CGFloat rollDuration;
@property (nonatomic, readonly) CGFloat blinkDuration;
/** 透明度 取值范围[0, 1] */
@property (nonatomic, readonly) CGFloat alpha;
/** 背景透明度 取值范围[0, 1] */
@property (nonatomic, readonly) CGFloat backgroundAlpha;

/**
 跑马灯
 #param content 跑马灯内容
 #param fontSize 跑马灯字体大小，默认 10.0
 #param color 跑马灯字体颜色，默认 #FFFFFF
 #param alpha 跑马灯字体透明度，默认 1.0
*/
- (instancetype)initWithContent:(NSString *)content
                       fontSize:(CGFloat)fontSize
                          color:(nullable NSString *)color
                          alpha:(CGFloat)alpha;

/**
 跑马灯
 #param content 跑马灯内容
 #param fontSize 跑马灯字体大小，默认 10.0
 #param color 跑马灯字体颜色，默认 #FFFFFF
 #param alpha 跑马灯字体透明度，默认 1.0
 #param alpha 跑马灯字体是否加粗
 #param count 跑马灯数量，默认 1.0
 #param displayMode 跑马灯显示模式，roll 滚动 、 blink闪烁
 #param backgroundColor 跑马灯背景颜色，默认 #FFFFFF
 #param backgroundAlpha 跑马灯背景透明度，默认 1.0
 #param roillDuration 跑马灯滚动模式间隔时长，3~120正整数，默认 3
 #param blinkDuration 跑马灯闪烁模式停留时长，3~120正整数，默认 3
 
 */
- (instancetype)initWithContent:(NSString *)content
                       fontSize:(CGFloat)fontSize
                          color:(nullable NSString *)color
                          alpha:(CGFloat)alpha
                         isBold:(BOOL)isBold
                          count:(NSInteger)count
                    displayMode:(BJLLampDisplayMode)displayMode
                backgroundColor:(NSString *)backgroundColor
                backgroundAlpha:(CGFloat)backgroundAlpha
                   rollDuration:(CGFloat)rollDuration
                  blinkDuration:(CGFloat)blinkDuration;

@end

NS_ASSUME_NONNULL_END
