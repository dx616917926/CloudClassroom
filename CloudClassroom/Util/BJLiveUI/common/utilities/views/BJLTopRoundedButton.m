//
//  BJLTopRoundedButton.m
//  BJLTopRoundedButton
//
//  Created by Ney on 7/26/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLTopRoundedButton.h"
@interface BJLTopRoundedButton ()
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) CALayer *borderLayer;
@end

@implementation BJLTopRoundedButton
- (void)layoutSubviews {
    [super layoutSubviews];

    if (!(self.bounds.size.width > 0 && self.bounds.size.height > 0)) {
        return;
    }

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(4, 4)];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;

    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.path = path.CGPath;
    borderLayer.fillColor = UIColor.clearColor.CGColor;
    borderLayer.strokeColor = [UIColor colorWithRed:159 / 255.0 green:168 / 255.0 blue:181 / 255.0 alpha:0.50].CGColor;
    borderLayer.lineWidth = 1;
    borderLayer.lineJoin = kCALineJoinRound;
    borderLayer.lineCap = kCALineCapRound;
    borderLayer.frame = self.bounds;
    [self.layer addSublayer:borderLayer];

    self.maskLayer = shapeLayer;

    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
    }
    self.borderLayer = borderLayer;
}
@end
