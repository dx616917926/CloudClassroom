//
//  BJLButton.h
//  M9Dev
//
//  Created by MingLQ on 2015-10-21.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** Avoid subclassing UIButton AMAP */
@interface BJLButton: UIButton

@property (nonatomic) CGFloat midSpace; // auto adjusting `titleRect`, `imageRect` and `intrinsicContentSize`
@property (nonatomic) CGSize intrinsicContentSize;
@property (nonatomic) UIEdgeInsets alignmentRectInsets;

@property (nonatomic, copy) CGRect (^titleRectForContentRectBlock)(CGRect contentRect, CGRect superRect);
@property (nonatomic, copy) CGRect (^imageRectForContentRectBlock)(CGRect contentRect, CGRect superRect);
@property (nonatomic, copy) CGSize (^intrinsicContentSizeBlock)(CGSize superSize);
- (CGRect)_UIButton_titleRectForContentRect:(CGRect)contentRect;
- (CGRect)_UIButton_imageRectForContentRect:(CGRect)contentRect;
- (CGSize)_UIButton_intrinsicContentSize;

@property (nonatomic, copy) CGRect (^contentRectForBoundsBlock)(CGRect bounds, CGRect superRect);
@property (nonatomic, copy) CGRect (^backgroundRectForBoundsBlock)(CGRect bounds, CGRect superRect);
- (CGRect)_UIButton_contentRectForBounds:(CGRect)bounds;
- (CGRect)_UIButton_backgroundRectForBounds:(CGRect)bounds;

@property (nonatomic, copy) void (^layoutSubviewsBlock)(UIButton *button);

@end

/** Image Right, Title Left */
@interface BJLImageRightButton: BJLButton
@end

/** Image Top, Title Bottom */
@interface BJLVerticalButton: BJLButton
@end

/** Title Only */
@interface BJLTitleButton: BJLButton
@end

/** Image Only */
@interface BJLImageButton: BJLButton
@end

NS_ASSUME_NONNULL_END
