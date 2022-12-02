//
//  BJLAvatarBackgroundColorGenerator.m
//  testOC
//
//  Created by HuXin on 2021/9/10.
//

#import "BJLAvatarBackgroundColorGenerator.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//http://ewiki.baijiashilian.com/%E7%99%BE%E5%AE%B6%E4%BA%91/%E5%89%8D%E7%AB%AF/%E7%9B%B4%E6%92%AD/%E5%A4%B4%E5%83%8F%E8%89%B2%E5%80%BC%E8%A7%84%E5%88%99.md
//助教头像背景色规则
//基础色板
//20个主色，每个主色又包含5个衍生色，共计100个颜色，计算衍生色时输入亮度[3, 7]，3为最亮，7为最淡，5为分界线，5为主色。
//
//#f5222d   #fa541c   #fa8c16   #faad14   #fadb14
//#a0d911   #52c41a   #13c2c2   #1890ff   #2f54eb
//#722ed1   #eb2f96   #833d41   #835a3d   #77833d
//#3d8379   #3d6183   #3f3d83   #7f3d83   #607d8d
//颜色从0开始，从左往右，从上往下依次递增，#f5222d为0，#a0d911为5，#607d8d为19。
//
//根据用户number的最后两位数取主色与衍生色的亮度，number不够两位数的用0补位。number的十位除十向下取整，再根据个位是否大于等于五加十，个位取5的余数加三表示亮度。例如number最后两位为28，主色为Math.floor(2 / 10) + 10 = 12(#833d41)，亮度为6
//HSV颜色模型
//色调（H），饱和度（S），明度（V）
//
//色调
//用角度度量，取值范围[0, 360]度，从红色开始按逆时针方向计算，红色为0°，绿色为120°，蓝色为240°。
//
//饱和度
//饱和度S表示颜色接近光谱色的程度。一种颜色，可以看成是某种光谱色与白色混合的结果。其中光谱色所占的比例愈大，颜色接近光谱色的程度就愈高，颜色的饱和度也就愈高。饱和度高，颜色则深而艳。光谱色的白光成分为0，饱和度达到最高。通常取值范围为0%～100%，值越大，颜色越饱和。
//
//明度
//明度表示颜色明亮的程度，对于光源色，明度值与发光体的光亮度有关；对于物体色，此值和物体的透射比或反射比有关。通常取值范围为0%（黑）到100%（白）。
//
//转换
//把输入的16进制表示颜色字符串值转换成RGB颜色模型，再转换成HSV颜色模型，通过HSV去计算衍生色的HSV，再转化为RGB，最后转换成16进制表示的颜色字符串

//案例
//以color: #fadb14, light: 4为例
//
//1. isLight = true, i = 2
//2. #fadb14 -> { r: 250, g: 219, b: 20 }
//3. [0, 255] -> [0, 1]: { r: 0.9803921568627451, g: 0.8588235294117647, b: 0.0784313725490196 }
//4. r,g,b取max和min,max: 0.9803921568627451, min: 0.0784313725490196
//5. 计算h, s, v的值，v = 0.9803921568627451, d = 0.9019607843137254, s = 0.9199999999999999, h = 0.8652173913043478
//6. 转换为标准HSV值 { H: h * 360, S: s, V: v } -> { H: 51.91304347826087, S: 0.9199999999999999, V: 0.9803921568627451 }
//7. 计算衍生色HSV
//   1.计算衍生色的H，H = 56
//   2.计算衍生色的S，S = 0.6
//   3.计算衍生色的V，V = 1
//8. 转出为RGB
//   1.[0, 1]之间的rgb，{ r: 1, g: 0.96: b: 0.4 }
//   2.[0, 255]之间的rgb，{ r: 255, g: 244.79999999999998, b: 102 }
//9.转成16进制#fff566

#define kHueStep         2
#define kSaturationStep1 0.16
#define kSaturationStep2 0.05
#define kBrightnessStep1 0.05
#define kBrightnessStep2 0.15
#define kLightColorCount 5
#define kDarkColorCount  4

@implementation BJLAvatarBackgroundColorGenerator
#pragma mark - api
+ (nullable UIColor *)backgroundColorWithUserNumber:(NSString *)userNumber {
    if (userNumber == nil || userNumber.length < 1) {
        return nil;
    }
    NSString *number = userNumber;
    if (number.length < 2) {
        number = [@"0" stringByAppendingString:number];
    }
    else {
        number = [number substringWithRange:NSMakeRange(number.length - 2, 2)];
    }
    NSInteger light = (number.integerValue % 10) % 5 + 3;
    NSInteger majorNumber = floor(number.integerValue / 10) + ((number.integerValue % 10) >= 5 ? 10 : 0);
    NSArray *colorPalette = @[@"f5222d", @"fa541c", @"fa8c16", @"faad14", @"fadb14", @"a0d911", @"52c41a", @"13c2c2", @"1890ff", @"2f54eb", @"722ed1", @"eb2f96", @"833d41", @"835a3d", @"77833d", @"3d8379", @"3d6183", @"3f3d83", @"7f3d83", @"607d8d"];
    NSString *mainColor = colorPalette[majorNumber];
    NSString *red = [mainColor substringWithRange:NSMakeRange(0, 2)];
    NSString *green = [mainColor substringWithRange:NSMakeRange(2, 2)];
    NSString *blue = [mainColor substringWithRange:NSMakeRange(4, 2)];

    unsigned int r, g, b;
    [[NSScanner scannerWithString:red] scanHexInt:&r];
    [[NSScanner scannerWithString:green] scanHexInt:&g];
    [[NSScanner scannerWithString:blue] scanHexInt:&b];

    NSArray *hsv = [self hsvFromR:r / 255.0 G:g / 255.0 B:b / 255.0];
    bool isLight = light <= kLightColorCount;
    NSInteger offset = isLight ? kLightColorCount - light : light - kLightColorCount;

    CGFloat hue = [self hueWithHSV:hsv offset:offset light:isLight] / 360;
    CGFloat saturation = [self saturationWithHSV:hsv offset:offset light:isLight];
    CGFloat value = [self valueWithHSV:hsv offset:offset light:isLight];

    //下面两行把 HSV 转换成 hexstring ，目前只需要用到 UIColor ，所以先注释掉
    //    NSArray<NSNumber *> *rgb = [self rgbFromH:hue S:saturation * 100 V:value * 100];
    //    NSString *colorString = [NSString stringWithFormat:@"#%.2lx%.2lx%.2lx",(NSInteger)round(rgb[0].floatValue), (NSInteger)round(rgb[1].floatValue), (NSInteger)round(rgb[2].floatValue)];
    return [UIColor colorWithHue:hue saturation:saturation brightness:value alpha:1.0];
}

#pragma mark - helper
+ (NSArray<NSNumber *> *)hsvFromR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b {
    CGFloat max = MAX(r, MAX(g, b));
    CGFloat min = MIN(r, MIN(g, b));
    CGFloat d = max - min;
    CGFloat h = max;
    CGFloat s = max;
    CGFloat v = max;
    if (max == 0) {
        s = 0;
    }
    else {
        s = d / max;
    }
    if (max == min) {
        h = 0;
    }
    else {
        if (max == r) {
            h = (g - b) / d + (g < b ? 6 : 0);
        }
        else if (max == g) {
            h = (b - r) / d + 2;
        }
        else {
            h = (r - g) / d + 4;
        }
        h = (h / 6) * 360;
    }
    return @[@(h), @(s), @(v)];
}

+ (NSArray<NSNumber *> *)rgbFromH:(CGFloat)h S:(CGFloat)s V:(CGFloat)v {
    CGFloat hue = (h / 360) * 6;
    CGFloat saturation = s / 100;
    CGFloat value = v / 100;
    NSInteger i = floor(hue);
    CGFloat f = hue - i;
    CGFloat p = value * (1 - saturation);
    CGFloat q = value * (1 - f * saturation);
    CGFloat t = value * (1 - (1 - f) * saturation);
    NSInteger mod = i % 6;
    CGFloat r = [@[@(value), @(q), @(p), @(p), @(t), @(value)][mod] floatValue] * 255;
    CGFloat g = [@[@(t), @(value), @(value), @(q), @(p), @(p)][mod] floatValue] * 255;
    CGFloat b = [@[@(p), @(p), @(t), @(value), @(value), @(q)][mod] floatValue] * 255;

    return @[@(r), @(g), @(b)];
}

+ (CGFloat)hueWithHSV:(NSArray<NSNumber *> *)hsv offset:(NSInteger)i light:(BOOL)isLight {
    CGFloat hue;
    CGFloat h = hsv[0].floatValue;
    if (h >= 60 && h <= 240) {
        hue = isLight ? h - (kHueStep * i) : h + (kHueStep * i);
    }
    else {
        hue = isLight ? h + kHueStep * i : h - kHueStep * i;
    }
    if (hue < 0) {
        hue += 360;
    }
    else if (hue >= 360) {
        hue -= 360;
    }
    return hue;
}

+ (CGFloat)saturationWithHSV:(NSArray<NSNumber *> *)hsv offset:(NSInteger)i light:(BOOL)isLight {
    CGFloat saturation;
    CGFloat s = hsv[1].floatValue;
    if (isLight) {
        saturation = s - kSaturationStep1 * i;
    }
    else if (i == kDarkColorCount) {
        saturation = s + kSaturationStep1;
    }
    else {
        saturation = s + kSaturationStep2 * i;
    }
    if (saturation > 1) {
        saturation = 1;
    }
    if (isLight && i == kLightColorCount && saturation > 0.1) {
        saturation = 0.1;
    }
    if (saturation < 0.06) {
        saturation = 0.06;
    }
    return saturation;
}

+ (CGFloat)valueWithHSV:(NSArray<NSNumber *> *)hsv offset:(NSInteger)i light:(BOOL)isLight {
    CGFloat value;
    CGFloat v = hsv[2].floatValue;
    if (isLight) {
        value = v + kBrightnessStep1 * i;
    }
    else {
        value = v - kBrightnessStep2 * i;
    }
    if (value > 1) {
        value = 1;
    }
    return value;
}
@end
