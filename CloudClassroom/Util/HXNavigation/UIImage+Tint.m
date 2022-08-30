//
//  UIImage+Tint.m
//  HXNavigationController
//
//  Created by iMac on 16/7/21.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

@dynamic imageForCurrentTheme;

- (UIImage *)imageForCurrentTheme {
    UIImage *image = self;
    if (@available(iOS 13.0, *)) {
        image = [image imageWithTintColor:[UIColor whiteColor]];
    }
    return image;
}



- (CGSize)fitWidth:(CGFloat)fitWidth {
    
    CGFloat height = self.size.height;
    CGFloat width = self.size.width;
    
    if (width > fitWidth) {
        height *= fitWidth/width;
        width = fitWidth;
    }
    
    return CGSizeMake(width, height);
}

@end
