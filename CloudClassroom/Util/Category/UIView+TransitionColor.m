//
//  UIView+TransitionColors.h
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "UIView+TransitionColor.h"

@implementation UIView (TransitionColor)

//左右渐变
- (void)addTransitionColorLeftToRight:(UIColor *)startColor endColor:(UIColor *)endColor {
    [self addTransitionColor:startColor endColor:endColor startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
}

//上下渐变
- (void)addTransitionColorTopToBottom:(UIColor *)startColor endColor:(UIColor *)endColor {
    [self addTransitionColor:startColor endColor:endColor startPoint:CGPointMake(0.5, 0) endPoint:CGPointMake(0.5, 1)];
}

//斜渐变
- (void)addTransitionColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    [self addTransitionColor:startColor endColor:endColor startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
}

- (void)addTransitionColor:(UIColor *)startColor
                  endColor:(UIColor *)endColor
                startPoint:(CGPoint)startPoint
                  endPoint:(CGPoint)endPoint {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    gradientLayer.locations = @[@0, @1];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end
