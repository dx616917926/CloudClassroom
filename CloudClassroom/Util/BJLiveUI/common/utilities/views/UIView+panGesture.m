//
//  UIView+panGesture.m
//  BJLiveUIBase
//
//  Created by ney on 2021/12/23.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "UIView+panGesture.h"

#define bjl_associate_category_primitive_type(TYPE, PROPERTY, GETTER, DECODE, SETTER, ENCODE)           \
    -TYPE GETTER {                                                                                      \
        id PROPERTY = objc_getAssociatedObject(self, @selector(PROPERTY));                              \
        return DECODE;                                                                                  \
    }                                                                                                   \
    -(void)SETTER TYPE PROPERTY {                                                                       \
        objc_setAssociatedObject(self, @selector(PROPERTY), ENCODE, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    }

#define bjl_associate_category_reference_type(TYPE, PROPERTY, GETTER, SETTER, POLICY) \
    -TYPE GETTER {                                                                    \
        return objc_getAssociatedObject(self, @selector(PROPERTY));                   \
    }                                                                                 \
    -(void)SETTER TYPE PROPERTY {                                                     \
        objc_setAssociatedObject(self, @selector(PROPERTY), PROPERTY, POLICY);        \
    }

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

@implementation UIView (panGesture)
bjl_associate_category_reference_type((UIView *),
    panGestureView,
    panGestureView,
    setPanGestureView:,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC);

bjl_associate_category_reference_type((UIPanGestureRecognizer *),
    panGesture,
    panGesture,
    setPanGesture:,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC);

bjl_associate_category_primitive_type((BOOL), titleBarPanGestureEnable, titleBarPanGestureEnable, ({ [titleBarPanGestureEnable boolValue]; }), setTitleBarPanGestureEnable:, ({ titleBarPanGestureEnable ? @(titleBarPanGestureEnable) : nil; }));

bjl_associate_category_primitive_type((CGFloat), titleBarHeight, titleBarHeight, ({ [titleBarHeight floatValue]; }), setTitleBarHeight:, ({ titleBarHeight ? @(titleBarHeight) : nil; }));

- (void)setBjl_titleBarHeight:(CGFloat)bjl_titleBarHeight {
    self.titleBarHeight = bjl_titleBarHeight;
}

- (CGFloat)bjl_titleBarHeight {
    return self.titleBarHeight;
}

- (BOOL)bjl_titleBarPanGestureEnable {
    return self.titleBarPanGestureEnable;
}

- (void)bjl_addTitleBarPanGesture {
    if ([self bjl_titleBarPanGestureEnable]) return;

    if (self.titleBarHeight < CGFLOAT_MIN) {
        self.titleBarHeight = 30;
    }

    if (!self.panGestureView) {
        self.panGestureView = [self buildPanGestureView];
        [self addSubview:self.panGestureView];
        [self.panGestureView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.top.equalTo(self);
            make.right.equalTo(self).offset(-self.titleBarHeight);
            make.height.equalTo(@(self.titleBarHeight));
        }];
    }

    if (!self.panGesture) {
        self.panGesture = [self addTitleBarPanGesture:self.panGestureView];
    }
    else {
        [self.panGestureView addGestureRecognizer:self.panGesture];
    }
    self.titleBarPanGestureEnable = YES;
}

- (void)bjl_removeTitleBarPanGesture {
    if ([self bjl_titleBarPanGestureEnable]) {
        if (self.panGesture) { [self removeGestureRecognizer:self.panGesture]; }
        self.titleBarPanGestureEnable = NO;
    }
}

#pragma mark - helper
- (UIPanGestureRecognizer *)addTitleBarPanGesture:(UIView *)view {
    bjl_weakify(self);
    __block CGPoint originPoint = CGPointZero;
    __block CGPoint movingTranslation = CGPointZero;
    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);

        if (gesture.state == UIGestureRecognizerStateBegan) {
            originPoint = self.frame.origin;
            [gesture setTranslation:CGPointMake(0.0, 0.0) inView:self];
            movingTranslation = [gesture translationInView:self];
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            movingTranslation = [gesture translationInView:self];
        }
        else {
            return;
        }

        CGRect frame = bjl_set(self.frame, {
            set.origin = CGPointMake(originPoint.x + movingTranslation.x,
                originPoint.y + movingTranslation.y);
        }), superBounds = self.superview.bounds;
        if (CGRectGetMinX(frame) < 0.0) {
            frame.origin.x = 0.0;
        }
        if (CGRectGetMinY(frame) < 0.0) {
            frame.origin.y = 0.0;
        }
        if (CGRectGetMaxX(frame) > CGRectGetMaxX(superBounds)) {
            frame.origin.x = CGRectGetMaxX(superBounds) - CGRectGetWidth(frame);
        }
        if (CGRectGetMaxY(frame) > CGRectGetMaxY(superBounds)) {
            frame.origin.y = CGRectGetMaxY(superBounds) - CGRectGetHeight(frame);
        }

        [self updatePositionAndSize:frame];
    }];

    [view addGestureRecognizer:pan];

    return pan;
}

- (UIView *)buildPanGestureView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.clearColor;
    view.accessibilityIdentifier = @"UIView+panGesture.panGestureView";

    return view;
}

- (void)updatePositionAndSize:(CGRect)tempFrame {
    if (!self.superview) { return; }
    if (CGRectEqualToRect(tempFrame, CGRectNull) || CGRectEqualToRect(tempFrame, CGRectZero)) { return; }

    [self bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(@(tempFrame.origin.x));
        make.top.equalTo(@(tempFrame.origin.y));
        make.width.equalTo(@(tempFrame.size.width));
        make.height.equalTo(@(tempFrame.size.height));
    }];
}
@end
