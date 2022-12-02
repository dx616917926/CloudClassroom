//
//  BJLAppearance.h
//  BJLiveUI
//
//  Created by xijia dai on 2021/1/11.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLiveCore.h>

#import "BJLTheme.h"

#define BJLScOnePixel ({                                    \
    static CGFloat _BJLScOnePixel;                          \
    static dispatch_once_t onceToken;                       \
    dispatch_once(&onceToken, ^{                            \
        _BJLScOnePixel = 1.0 / [UIScreen mainScreen].scale; \
    });                                                     \
    _BJLScOnePixel;                                         \
})

/** 窗口所在的位置的类型 */
typedef NS_ENUM(NSInteger, BJLScPositionType) {
    BJLScPositionType_none, // 空类型
    BJLScPositionType_major, // 主视图窗口
    BJLScPositionType_minor, // 老师窗口
    BJLScPositionType_videoList, // 视频列表区域
    BJLScPositionType_secondMinor, // 第二个次要的窗口，目前仅用于 1v1
};

NS_ASSUME_NONNULL_BEGIN

@interface BJLAppearance: NSObject

// popover
@property (class, nonatomic, readonly) CGFloat popoverViewWidth;
@property (class, nonatomic, readonly) CGFloat popoverViewHeight;
@property (class, nonatomic, readonly) CGFloat popoverImageSize;
@property (class, nonatomic, readonly) CGFloat popoverViewSpace;
@property (class, nonatomic, readonly) CGFloat promptCellSmallSpace;
@property (class, nonatomic, readonly) NSInteger chatPromptDuration;
@property (class, nonatomic, readonly) CGFloat promptCellLargeSpace;
@property (class, nonatomic, readonly) NSInteger chatPromptCellMaxCount;

// document
@property (class, nonatomic, readonly) CGFloat documentFileCellWidth;
@property (class, nonatomic, readonly) CGFloat documentFileCellHeight;
@property (class, nonatomic, readonly) CGFloat documentFileCellImageSize;
@property (class, nonatomic, readonly) CGFloat documentFileDisplayListWidth;
@property (class, nonatomic, readonly) CGFloat documentFileButtonCornerRadius;
@property (class, nonatomic, readonly) CGFloat documentFileButtonHeight;
@property (class, nonatomic, readonly) CGFloat documentFileButtonWidth;

// toolbox
@property (class, nonatomic, readonly) CGFloat toolboxHeightFraction;
@property (class, nonatomic, readonly) CGFloat toolboxWidth;
@property (class, nonatomic, readonly) CGFloat toolboxOffset;
@property (class, nonatomic, readonly) CGFloat toolboxButtonSize;
@property (class, nonatomic, readonly) CGFloat toolboxButtonSpace;
@property (class, nonatomic, readonly) CGFloat toolboxLineLength; // 分割线长度
@property (class, nonatomic, readonly) CGFloat toolboxButtonImageInset;
@property (class, nonatomic, readonly) CGFloat toolboxColorSize;
@property (class, nonatomic, readonly) CGFloat toolboxColorLength;
@property (class, nonatomic, readonly) CGFloat toolboxCornerRadius;
@property (class, nonatomic, readonly) CGFloat toolboxDrawSpace;
@property (class, nonatomic, readonly) CGFloat toolboxDrawButtonSize;
@property (class, nonatomic, readonly) CGFloat toolboxDrawFontIconSize;
@property (class, nonatomic, readonly) CGFloat toolboxDrawFontSize;

// window
@property (class, nonatomic, readonly) CGFloat userWindowDefaultBarHeight;
@property (class, nonatomic, readonly) CGFloat blackboardAspectRatio;
+ (void)updateBlackboardAspectRatio:(CGFloat)blackboardAspectRatio;

// questionAnswer
@property (class, nonatomic, readonly) CGFloat questionAnswerOptionButtonWidth;
@property (class, nonatomic, readonly) CGFloat questionAnswerOptionButtonHeight;

// corner
@property (class, nonatomic, readonly) CGFloat cornerRadius;

@end

#pragma mark - UIImage

@interface UIImage (BJLiveUI)

+ (UIImage *)bjl_imageNamed:(NSString *)name;

@end

#pragma mark - NSObject

@interface NSObject (BJLiveUI)

// 根据文本和尺寸限制获取预期的尺寸，目前仅用于计算文本的高度来决定是否完全显示文本，布局使用系统控件的自适应布局
- (CGSize)bjl_suitableSizeWithText:(nullable NSString *)text attributedText:(nullable NSAttributedString *)attributedText maxWidth:(CGFloat)maxWidth;
- (CGSize)bjl_oneRowSizeWithText:(nullable NSString *)text attributedText:(nullable NSAttributedString *)attributedText fontSize:(CGFloat)fontSize;

@end

#pragma mark - button

@interface BJLCornerImageButton: BJLImageButton

// 通常态背景色
@property (nonatomic) UIColor *normalColor;
// 选中态背景色
@property (nonatomic) UIColor *selectedColor;
// 背景色大小，默认居中显示
@property (nonatomic) CGSize backgroundSize;
// 背景色圆角值
@property (nonatomic) CGFloat backgroundCornerRadius;

@end

#pragma mark - UIView

typedef NS_OPTIONS(NSInteger, BJLRectPosition) {
    BJLRectPosition_top = 1 << 0,
    BJLRectPosition_bottom = 1 << 1,
    BJLRectPosition_left = 1 << 2,
    BJLRectPosition_right = 1 << 3,
    BJLRectPosition_all = (1 << 4) - 1
};

@interface UIView (BJLiveUI)

// 绘制圆角
- (void)bjl_drawRectCorners:(UIRectCorner)coners cornerRadii:(CGSize)cornerRadii;

// 绘制视图指定颜色的圆角
- (void)bjl_drawRectCorners:(UIRectCorner)coners radius:(CGFloat)radius backgroundColor:(UIColor *)color size:(CGSize)size;
- (void)bjl_removeCorners;

// 绘制内阴影，绘制新的内阴影时会自动移除上一个内阴影
- (CAShapeLayer *)bjl_drawInnerShadowAlpha:(CGFloat)alpha cornerRadius:(CGFloat)cornerRadius;

// 绘制边框，绘制新的边框的时候会自动移除上一个边框
- (CAShapeLayer *)bjl_drawBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor corners:(UIRectCorner)coners cornerRadii:(CGSize)cornerRadii;
- (CAShapeLayer *)bjl_drawBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor position:(BJLRectPosition)position;

// 绘制圆形背景
- (CAShapeLayer *)bjl_drawCircleBackgroundViewWithColor:(nullable UIColor *)color hidden:(BOOL)hidden;
- (CAShapeLayer *)bjl_drawBackgroundViewWithColor:(nullable UIColor *)color rect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius hidden:(BOOL)hidden;

// 通用分割线, 色值: #9FA8B5, 0.1透明度
+ (UIView *)bjl_createSeparateLine;

@end

NS_ASSUME_NONNULL_END
