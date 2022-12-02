//
//  BJLScAppearance.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScAppearance.h"

#pragma mark -

@implementation UIColor (BJLSurfaceClass)

+ (UIColor *)bjlsc_darkGrayBackgroundColor {
    return [UIColor bjl_colorWithHex:0x1D1D1E];
}

+ (instancetype)bjlsc_lightGrayBackgroundColor {
    return [UIColor bjl_colorWithHex:0xF8F8F8];
}

+ (UIColor *)bjlsc_darkGrayTextColor {
    return [UIColor bjl_colorWithHex:0x3D3D3E];
}

+ (instancetype)bjlsc_grayTextColor {
    return [UIColor bjl_colorWithHex:0x6D6D6E];
}

+ (instancetype)bjlsc_lightGrayTextColor {
    return [UIColor bjl_colorWithHex:0x9D9D9E];
}

+ (instancetype)bjlsc_grayBorderColor {
    return [UIColor bjl_colorWithHex:0xCDCDCE];
}

+ (instancetype)bjlsc_grayLineColor {
    return [UIColor bjl_colorWithHex:0xDDDDDE];
}

+ (instancetype)bjlsc_grayImagePlaceholderColor {
    return [UIColor bjl_colorWithHex:0xEDEDEE];
}

+ (instancetype)bjlsc_blueBrandColor {
    return [UIColor bjl_colorWithHex:0x37A4F5];
}

+ (instancetype)bjlsc_orangeBrandColor {
    return [UIColor bjl_colorWithHex:0xFF9100];
}

+ (instancetype)bjlsc_redColor {
    return [UIColor bjl_colorWithHex:0xFF5850];
}

#pragma mark -

+ (UIColor *)bjlsc_lightDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.2];
}

+ (instancetype)bjlsc_dimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.5];
}

+ (instancetype)bjlsc_darkDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.6];
}

@end

#pragma mark -

@implementation UIImage (BJLSurfaceClass)

+ (UIImage *)bjlsc_imageNamed:(NSString *)name {
    static NSString *const bundleName = @"BJLSurfaceClass", *const bundleType = @"bundle";
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *classBundle = [NSBundle bundleForClass:NSClassFromString(@"BJLScRoomViewController")];
        NSString *bundlePath = [classBundle pathForResource:bundleName ofType:bundleType];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return [self imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end

#pragma mark -

@implementation UIButton (BJLButtons)

+ (instancetype)makeTextButtonDestructive:(BOOL)destructive {
    UIButton *button = [self new];
    UIColor *titleColor = destructive ? [UIColor bjlsc_redColor] : [UIColor bjlsc_blueBrandColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:[titleColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    return button;
}

+ (instancetype)makeRoundedRectButtonHighlighted:(BOOL)highlighted {
    UIButton *button = [self new];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    if (highlighted) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor bjlsc_blueBrandColor];
    }
    else {
        [button setTitleColor:[UIColor bjlsc_grayTextColor] forState:UIControlStateNormal];
        button.layer.borderWidth = BJLScOnePixel;
        button.layer.borderColor = [UIColor bjlsc_grayBorderColor].CGColor;
    }
    button.layer.cornerRadius = BJLScButtonCornerRadius;
    button.layer.masksToBounds = YES;
    return button;
}

@end
