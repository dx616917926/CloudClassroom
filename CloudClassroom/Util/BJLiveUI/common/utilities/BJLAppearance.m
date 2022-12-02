//
//  BJLAppearance.m
//  BJLiveUI
//
//  Created by xijia dai on 2021/1/11.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLAppearance.h"

@interface BJLAppearance ()

// popover
@property (nonatomic) CGFloat popoverViewWidth;
@property (nonatomic) CGFloat popoverViewHeight;
@property (nonatomic) CGFloat popoverImageSize;
@property (nonatomic) CGFloat popoverViewSpace;
@property (nonatomic) CGFloat promptCellSmallSpace;
@property (nonatomic) NSInteger chatPromptDuration;
@property (nonatomic) CGFloat promptCellLargeSpace;
@property (nonatomic) NSInteger chatPromptCellMaxCount;

// document
@property (nonatomic) CGFloat documentFileCellWidth;
@property (nonatomic) CGFloat documentFileCellHeight;
@property (nonatomic) CGFloat documentFileCellImageSize;
@property (nonatomic) CGFloat documentFileDisplayListWidth;
@property (nonatomic) CGFloat documentFileButtonCornerRadius;
@property (nonatomic) CGFloat documentFileButtonHeight;
@property (nonatomic) CGFloat documentFileButtonWidth;

// toolbox
@property (nonatomic) CGFloat toolboxHeightFraction;
@property (nonatomic) CGFloat toolboxWidth;
@property (nonatomic) CGFloat toolboxOffset;
@property (nonatomic) CGFloat toolboxButtonSize;
@property (nonatomic) CGFloat toolboxButtonSpace;
@property (nonatomic) CGFloat toolboxLineLength; // 分割线长度
@property (nonatomic) CGFloat toolboxButtonImageInset;
@property (nonatomic) CGFloat toolboxColorSize;
@property (nonatomic) CGFloat toolboxColorLength;
@property (nonatomic) CGFloat toolboxCornerRadius;
@property (nonatomic) CGFloat toolboxDrawSpace;
@property (nonatomic) CGFloat toolboxDrawButtonSize;
@property (nonatomic) CGFloat toolboxDrawFontIconSize;
@property (nonatomic) CGFloat toolboxDrawFontSize;

// window
@property (nonatomic) CGFloat userWindowDefaultBarHeight;
@property (nonatomic) CGFloat blackboardAspectRatio;

// questionAnswer
@property (nonatomic) CGFloat questionAnswerOptionButtonWidth;
@property (nonatomic) CGFloat questionAnswerOptionButtonHeight;

// corner
@property (nonatomic) CGFloat cornerRadius;

@end

@implementation BJLAppearance

static BJLAppearance *_Nullable sharedInstance = nil;

+ (void)initialize {
    sharedInstance = [BJLAppearance new];
}

- (instancetype)init {
    if (self = [super init]) {
        BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        // popover
        self.popoverViewWidth = 422.0;
        self.popoverViewHeight = 216.0;
        self.popoverImageSize = 24.0;
        self.popoverViewSpace = 20.0;
        self.promptCellSmallSpace = 6.0;
        self.chatPromptDuration = 5;
        self.promptCellLargeSpace = 12.0;
        self.chatPromptCellMaxCount = 3;
        // document
        self.documentFileCellWidth = 96.0;
        self.documentFileCellHeight = 106.0;
        self.documentFileCellImageSize = 64.0;
        self.documentFileDisplayListWidth = 142.0;
        self.documentFileButtonCornerRadius = 4.0;
        self.documentFileButtonHeight = 28.0;
        self.documentFileButtonWidth = 96.0;
        // toolbox
        self.toolboxWidth = iPhone ? 24.0 : 44.0;
        self.toolboxButtonSize = iPhone ? 18.0 : 32.0;
        self.toolboxButtonSpace = iPhone ? 6.0 : 8.0;
        self.toolboxCornerRadius = iPhone ? 2.0 : 4.0;
        self.toolboxOffset = 4.0;
        self.toolboxColorSize = 3.0;
        self.toolboxColorLength = self.toolboxButtonSize * 0.75;
        self.toolboxDrawSpace = 6.0;
        self.toolboxDrawButtonSize = 32.0;
        self.toolboxDrawFontIconSize = 20.0;
        self.toolboxDrawFontSize = 24.0;
        // window
        self.userWindowDefaultBarHeight = 24.0;
        self.blackboardAspectRatio = 4.0 / 3.0;
        // questionAnswer
        self.questionAnswerOptionButtonWidth = 34.0;
        self.questionAnswerOptionButtonHeight = 37.0;
        // corner
        self.cornerRadius = iPhone ? 2.0 : 4.0;
    }
    return self;
}

#pragma mark -

+ (void)updateBlackboardAspectRatio:(CGFloat)blackboardAspectRatio {
    sharedInstance.blackboardAspectRatio = blackboardAspectRatio;
}

#pragma mark -

// popover
+ (CGFloat)popoverViewWidth {
    return sharedInstance.popoverViewWidth;
}
+ (CGFloat)popoverViewHeight {
    return sharedInstance.popoverViewHeight;
}
+ (CGFloat)popoverImageSize {
    return sharedInstance.popoverImageSize;
}
+ (CGFloat)popoverViewSpace {
    return sharedInstance.popoverViewSpace;
}
+ (CGFloat)promptCellSmallSpace {
    return sharedInstance.promptCellSmallSpace;
}
+ (NSInteger)chatPromptDuration {
    return sharedInstance.chatPromptDuration;
}
+ (CGFloat)promptCellLargeSpace {
    return sharedInstance.promptCellLargeSpace;
}
+ (NSInteger)chatPromptCellMaxCount {
    return sharedInstance.chatPromptCellMaxCount;
}
// document
+ (CGFloat)documentFileCellWidth {
    return sharedInstance.documentFileCellWidth;
}
+ (CGFloat)documentFileCellHeight {
    return sharedInstance.documentFileCellHeight;
}
+ (CGFloat)documentFileCellImageSize {
    return sharedInstance.documentFileCellImageSize;
}
+ (CGFloat)documentFileDisplayListWidth {
    return sharedInstance.documentFileDisplayListWidth;
}
+ (CGFloat)documentFileButtonCornerRadius {
    return sharedInstance.documentFileButtonCornerRadius;
}
+ (CGFloat)documentFileButtonHeight {
    return sharedInstance.documentFileButtonHeight;
}
+ (CGFloat)documentFileButtonWidth {
    return sharedInstance.documentFileButtonWidth;
}
// toolbox
+ (CGFloat)toolboxHeightFraction {
    return sharedInstance.toolboxHeightFraction;
}
+ (CGFloat)toolboxWidth {
    return sharedInstance.toolboxWidth;
}
+ (CGFloat)toolboxOffset {
    return sharedInstance.toolboxOffset;
}
+ (CGFloat)toolboxButtonSize {
    return sharedInstance.toolboxButtonSize;
}
+ (CGFloat)toolboxButtonSpace {
    return sharedInstance.toolboxButtonSpace;
}
+ (CGFloat)toolboxLineLength {
    return sharedInstance.toolboxLineLength;
}
+ (CGFloat)toolboxButtonImageInset {
    return sharedInstance.toolboxButtonImageInset;
}
+ (CGFloat)toolboxColorSize {
    return sharedInstance.toolboxColorSize;
}
+ (CGFloat)toolboxColorLength {
    return sharedInstance.toolboxColorLength;
}
+ (CGFloat)toolboxCornerRadius {
    return sharedInstance.toolboxCornerRadius;
}
+ (CGFloat)toolboxDrawSpace {
    return sharedInstance.toolboxDrawSpace;
}
+ (CGFloat)toolboxDrawButtonSize {
    return sharedInstance.toolboxDrawButtonSize;
}
+ (CGFloat)toolboxDrawFontIconSize {
    return sharedInstance.toolboxDrawFontIconSize;
}
+ (CGFloat)toolboxDrawFontSize {
    return sharedInstance.toolboxDrawFontSize;
}
// window
+ (CGFloat)userWindowDefaultBarHeight {
    return sharedInstance.userWindowDefaultBarHeight;
}
+ (CGFloat)blackboardAspectRatio {
    return sharedInstance.blackboardAspectRatio;
}
// questionAnswer
+ (CGFloat)questionAnswerOptionButtonWidth {
    return sharedInstance.questionAnswerOptionButtonWidth;
}
+ (CGFloat)questionAnswerOptionButtonHeight {
    return sharedInstance.questionAnswerOptionButtonHeight;
}
// corner
+ (CGFloat)cornerRadius {
    return sharedInstance.cornerRadius;
}

@end

@implementation UIImage (BJLiveUI)

+ (UIImage *)bjl_imageNamed:(NSString *)name {
//    static NSString *const bundleName = @"BJLiveUI", *const bundleType = @"bundle";
//    static NSBundle *bundle = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSBundle *classBundle = [NSBundle bundleForClass:[BJLAppearance class]];
//        NSString *bundlePath = [classBundle pathForResource:bundleName ofType:bundleType];
//        bundle = [NSBundle bundleWithPath:bundlePath];
//    });
//    return [self imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    
    return [self imageNamed:name];
}

@end

#pragma mark - NSObject

@implementation NSObject (BJLiveUI)

- (CGSize)bjl_suitableSizeWithText:(nullable NSString *)text attributedText:(nullable NSAttributedString *)attributedText maxWidth:(CGFloat)maxWidth {
    __block CGFloat messageLabelHeight = 0.0;
    __block CGFloat messageLabelWidth = 0.0;
    if (text) {
        [text enumerateLinesUsingBlock:^(NSString *_Nonnull line, BOOL *_Nonnull stop) {
            CGRect rect = [line boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} context:nil];
            messageLabelHeight += rect.size.height;
            messageLabelWidth = rect.size.width > messageLabelWidth ? rect.size.width : messageLabelWidth;
        }];
    }
    else if (attributedText) {
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
        messageLabelHeight = rect.size.height;
        messageLabelWidth = rect.size.width > messageLabelWidth ? rect.size.width : messageLabelWidth;
    }
    return CGSizeMake(ceil(messageLabelWidth), ceil(messageLabelHeight));
}

- (CGSize)bjl_oneRowSizeWithText:(nullable NSString *)text attributedText:(nullable NSAttributedString *)attributedText fontSize:(CGFloat)fontSize {
    __block CGFloat messageLabelHeight = 0.0;
    __block CGFloat messageLabelWidth = 0.0;
    if (text) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, fontSize) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil];
        messageLabelWidth = rect.size.width;
        messageLabelHeight = rect.size.height;
    }
    else if (attributedText) {
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, fontSize) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
        messageLabelWidth = rect.size.width;
        messageLabelHeight = rect.size.height;
    }
    return CGSizeMake(ceil(messageLabelWidth), ceil(messageLabelHeight));
}

@end

#pragma mark - button

@implementation BJLCornerImageButton

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self drawBackgroundCorner];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self drawBackgroundCorner];
}

- (void)drawBackgroundCorner {
    CGFloat xOffset = (self.bounds.size.width - self.backgroundSize.width) / 2.0;
    CGFloat yOffset = (self.bounds.size.height - self.backgroundSize.height) / 2.0;
    CGRect rect = CGRectMake(xOffset, yOffset, self.backgroundSize.width, self.backgroundSize.height);
    if (self.selected) {
        [self bjl_drawBackgroundViewWithColor:self.selectedColor rect:rect cornerRadius:self.backgroundCornerRadius hidden:self.selectedColor ? NO : YES];
    }
    else {
        [self bjl_drawBackgroundViewWithColor:self.normalColor rect:rect cornerRadius:self.backgroundCornerRadius hidden:self.normalColor ? NO : YES];
    }
}

@end

#pragma mark - view

@implementation UIView (BJLiveUI)

// [d7b5ccda]: 尝试解决 32bit 设备 + iOS 10.3.3/4 removeFromSuperview 崩溃问题
#if !defined(__LP64__) || !__LP64__ // #see CGFloat
+ (void)load {
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    if (BJLVersionGE(systemVersion, @"10")
        && BJLVersionLT(systemVersion, @"11")) {
        BJLSwizzleMethod(self, @selector(removeFromSuperview), @selector(_bjl_removeFromSuperview));
    }
}
- (void)_bjl_removeFromSuperview {
    [self _bjl_removeSuperviewConstraints];
    [self _bjl_removeFromSuperview];
}
- (void)_bjl_removeSuperviewConstraints {
    UIView *superview = self;
    while ((superview = superview.superview)) {
        if ([superview isKindOfClass:[UINavigationBar class]]) {
            continue;
        }
        for (NSLayoutConstraint *constraint in superview.constraints) {
            if (constraint.firstItem == self || constraint.secondItem == self) {
                [superview removeConstraint:constraint];
            }
        }
    }
}
#endif

- (CAShapeLayer *)bjl_borderLayer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBjl_borderLayer:(nullable CAShapeLayer *)borderLayer {
    objc_setAssociatedObject(self, @selector(bjl_borderLayer), borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)bjl_shadowLayer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBjl_shadowLayer:(nullable CAShapeLayer *)shadowLayer {
    objc_setAssociatedObject(self, @selector(bjl_shadowLayer), shadowLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)bjl_backgroundLayer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBjl_backgroundLayer:(nullable CAShapeLayer *)backgroundLayer {
    objc_setAssociatedObject(self, @selector(bjl_backgroundLayer), backgroundLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 绘制圆角
- (void)bjl_drawRectCorners:(UIRectCorner)coners cornerRadii:(CGSize)cornerRadii {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:coners cornerRadii:cornerRadii];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;
}

- (void)bjl_drawRectCorners:(UIRectCorner)coners radius:(CGFloat)radius backgroundColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(contextRef, 1.0);
    CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
    CGContextSetFillColorWithColor(contextRef, color.CGColor);

    CGFloat width = size.width;
    CGFloat height = size.height;

    CGContextMoveToPoint(contextRef, 0, 0);
    if (coners & UIRectCornerTopRight) {
        CGContextAddArcToPoint(contextRef, width, 0, width, height, radius); // 右上角
    }
    else {
        CGContextAddLineToPoint(contextRef, width, 0);
    }
    if (coners & UIRectCornerBottomRight) {
        CGContextAddArcToPoint(contextRef, width, height, 0, height, radius); // 右下角
    }
    else {
        CGContextAddLineToPoint(contextRef, width, height);
    }
    if (coners & UIRectCornerBottomLeft) {
        CGContextAddArcToPoint(contextRef, 0, height, 0, 0, radius); // 左下角
    }
    else {
        CGContextAddLineToPoint(contextRef, 0, height);
    }
    if (coners & UIRectCornerTopLeft) {
        CGContextAddArcToPoint(contextRef, 0, 0, width, 0, radius); // 左上角
    }
    else {
        CGContextAddLineToPoint(contextRef, 0, 0);
    }
    CGContextDrawPath(contextRef, kCGPathFillStroke);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.layer.contents = (__bridge id _Nullable)(image.CGImage);
}

- (void)bjl_removeCorners {
    self.layer.contents = nil;
}

// 绘制内阴影，绘制新的内阴影时会自动移除上一个内阴影
- (CAShapeLayer *)bjl_drawInnerShadowAlpha:(CGFloat)alpha cornerRadius:(CGFloat)cornerRadius {
    if (self.bjl_shadowLayer && self.bjl_shadowLayer.superlayer) {
        [self.bjl_shadowLayer removeFromSuperlayer];
        self.bjl_shadowLayer = nil;
    }
    CAShapeLayer *shadowLayer = [CAShapeLayer layer];
    shadowLayer.frame = self.bounds;
    shadowLayer.shadowOpacity = alpha;
    shadowLayer.shadowColor = [UIColor colorWithWhite:1.0 alpha:alpha].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 0.0);
    shadowLayer.fillRule = kCAFillRuleEvenOdd;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectInset(self.bounds, cornerRadius, cornerRadius));
    CGPathRef innerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius].CGPath;
    CGPathAddPath(path, NULL, innerPath);
    CGPathCloseSubpath(path);
    shadowLayer.path = path;
    CGPathRelease(path);
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = innerPath;
    shadowLayer.mask = maskLayer;
    [self.layer addSublayer:shadowLayer];
    self.bjl_shadowLayer = shadowLayer;
    return shadowLayer;
}

// 绘制边框，绘制新的边框的时候会自动移除上一个边框
- (CAShapeLayer *)bjl_drawBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor corners:(UIRectCorner)coners cornerRadii:(CGSize)cornerRadii {
    if (self.bjl_borderLayer && self.bjl_borderLayer.superlayer) {
        [self.bjl_borderLayer removeFromSuperlayer];
        self.bjl_borderLayer = nil;
    }
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:coners cornerRadii:cornerRadii];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = borderColor.CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = borderWidth;
    [self.layer addSublayer:shapeLayer];
    self.bjl_borderLayer = shapeLayer;
    return shapeLayer;
}

- (CAShapeLayer *)bjl_drawBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor position:(BJLRectPosition)position {
    if (self.bjl_borderLayer && self.bjl_borderLayer.superlayer) {
        [self.bjl_borderLayer removeFromSuperlayer];
        self.bjl_borderLayer = nil;
    }
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    if (position & BJLRectPosition_top) {
        CALayer *topLayer = [CALayer layer];
        topLayer.frame = CGRectMake(0.0, 0.0, width, borderWidth);
        topLayer.backgroundColor = borderColor.CGColor;
        [shapeLayer addSublayer:topLayer];
    }

    if (position & BJLRectPosition_bottom) {
        CALayer *bottomLayer = [CALayer layer];
        bottomLayer.frame = CGRectMake(0.0, height, width, borderWidth);
        bottomLayer.backgroundColor = borderColor.CGColor;
        [shapeLayer addSublayer:bottomLayer];
    }

    if (position & BJLRectPosition_left) {
        CALayer *leftLayer = [CALayer layer];
        leftLayer.frame = CGRectMake(0.0, 0.0, borderWidth, height);
        leftLayer.backgroundColor = borderColor.CGColor;
        [shapeLayer addSublayer:leftLayer];
    }

    if (position & BJLRectPosition_right) {
        CALayer *rightLayer = [CALayer layer];
        rightLayer.frame = CGRectMake(width, 0.0, borderWidth, height);
        rightLayer.backgroundColor = borderColor.CGColor;
        [shapeLayer addSublayer:rightLayer];
    }

    [self.layer addSublayer:shapeLayer];
    self.bjl_borderLayer = shapeLayer;
    return shapeLayer;
}

// 绘制圆形背景
- (CAShapeLayer *)bjl_drawCircleBackgroundViewWithColor:(nullable UIColor *)color hidden:(BOOL)hidden {
    return [self bjl_drawBackgroundViewWithColor:color rect:self.bounds cornerRadius:self.bounds.size.height / 2.0 hidden:hidden];
}

- (CAShapeLayer *)bjl_drawBackgroundViewWithColor:(nullable UIColor *)color rect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius hidden:(BOOL)hidden {
    if (hidden) {
        self.bjl_backgroundLayer.hidden = hidden;
        return self.bjl_backgroundLayer;
    }
    if (self.bjl_backgroundLayer && self.bjl_backgroundLayer.superlayer) {
        [self.bjl_backgroundLayer removeFromSuperlayer];
        self.bjl_backgroundLayer = nil;
    }
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = color.CGColor;
    shapeLayer.path = path.CGPath;
    [self.layer insertSublayer:shapeLayer atIndex:0];
    self.bjl_backgroundLayer = shapeLayer;
    return shapeLayer;
}

// 通用分割线, 色值: #9FA8B5, 0.1透明度
+ (UIView *)bjl_createSeparateLine {
    UIView *view = [UIView new];
    view.backgroundColor = BJLTheme.separateLineColor;
    return view;
}

@end
