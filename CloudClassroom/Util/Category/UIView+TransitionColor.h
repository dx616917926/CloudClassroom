//
//  UIView+TransitionColors.h
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import <UIKit/UIKit.h>

@interface UIView (TransitionColor)

//斜渐变
- (void)addTransitionColor:(UIColor *)startColor endColor:(UIColor *)endColor;
//左右渐变
- (void)addTransitionColorLeftToRight:(UIColor *)startColor endColor:(UIColor *)endColor;
//上下渐变
- (void)addTransitionColorTopToBottom:(UIColor *)startColor endColor:(UIColor *)endColor;
- (void)addTransitionColor:(UIColor *)startColor
                  endColor:(UIColor *)endColor
                startPoint:(CGPoint)startPoint
                  endPoint:(CGPoint)endPoint;

@end

