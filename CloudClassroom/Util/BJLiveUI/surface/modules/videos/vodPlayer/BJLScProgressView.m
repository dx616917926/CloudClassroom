//
//  BJLScProgressView.m
//  BJLiveUI
//
//  Created by 辛亚鹏 on 2021/7/20.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLScProgressView.h"
#import "BJLScAppearance.h"

@interface BJLScPlayerSlider: UISlider

@property (nonatomic, assign) BOOL touchToChanged;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation BJLScPlayerSlider

- (void)setTouchToChanged:(BOOL)touchToChanged {
    _touchToChanged = touchToChanged;
    self.tapGestureRecognizer.enabled = touchToChanged;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    thumbRect.origin.x = (self.maximumValue > 0 ? (value / self.maximumValue * self.frame.size.width) : 0) - self.currentThumbImage.size.width / 2;
    thumbRect.origin.y = 0;
    thumbRect.size.height = bounds.size.height;

    return thumbRect;
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds {
    return CGRectZero;
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds {
    return CGRectZero;
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    if (self.touchToChanged) {
        CGPoint point = [tapGesture locationInView:tapGesture.view];
        CGFloat percentage = point.x / self.frame.size.width;
        self.value = ceil(MIN(percentage, 1) * self.maximumValue);
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
    self.tapGestureRecognizer.enabled = (!begin && self.touchToChanged);
    return begin;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    self.tapGestureRecognizer.enabled = (YES && self.touchToChanged);
}

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

#pragma mark - get
- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    return _tapGestureRecognizer;
}

@end

#pragma mark -

@interface BJLScProgressView ()

@property (nonatomic, readwrite, nullable) UISlider *slider;
@property (nonatomic, nullable) UIView *sliderBgView;
@property (nonatomic, nullable) UIView *progressView;
@property (nonatomic, nullable) UIView *durationView;

@end

@implementation BJLScProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self makeConstraints];
        [self updateCurrentTime:0 duration:0];
        [self addObserver];
    }
    return self;
}

- (void)dealloc {
    self.sliderBgView = nil;
    self.slider = nil;
    self.progressView = nil;
}

- (void)updateCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    CGFloat progressWidth = CGRectGetWidth(self.frame) - 2.0;
    self.slider.maximumValue = duration;
    self.slider.value = currentTime;
    if (duration) {
        CGFloat progressF = currentTime / duration;
        [self.progressView bjl_updateConstraints:^(BJLConstraintMaker *make) {
            make.width.equalTo(@(progressWidth * progressF));
        }];
    }
}

- (void)addObserver {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self, bounds) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        if (!CGRectEqualToRect(self.bounds, CGRectZero)) {
            [self updateCurrentTime:self.slider.value duration:self.slider.maximumValue];
        }
        return YES;
    }];
}

- (void)setupViews {
    self.sliderBgView = ({
        UIView *view = [[UIView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, sliderBgView);
        view.layer.cornerRadius = 2.0;
        view.layer.masksToBounds = YES;
        view;
    });

    self.slider = ({
        BJLScPlayerSlider *slider = [[BJLScPlayerSlider alloc] init];
        slider.touchToChanged = YES;
        slider.accessibilityIdentifier = BJLKeypath(self, slider);
        slider.backgroundColor = [UIColor clearColor];
        slider.minimumTrackTintColor = [UIColor clearColor];
        slider.maximumTrackTintColor = [UIColor clearColor];
        slider;
    });

    //    [self.slider setMinimumTrackImage:leftStretch forState:UIControlStateNormal];
    //    [self.slider setMaximumTrackImage:rightStretch forState:UIControlStateNormal];

    [self.slider setThumbImage:[UIImage bjlsc_imageNamed:@"bjl_sc_warming_slider"] forState:UIControlStateNormal];

    self.progressView = ({
        UIView *view = [[UIImageView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, progressView);
        view.layer.cornerRadius = 2.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor bjl_colorWithHexString:@"#1795FF"];
        view;
    });

    self.durationView = ({
        UIView *view = [[UIImageView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, durationView);
        view.layer.cornerRadius = 2.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        view;
    });

    [self.sliderBgView addSubview:self.durationView];
    [self.sliderBgView addSubview:self.progressView];

    [self addSubview:self.sliderBgView];
    [self addSubview:self.slider];
}

- (void)makeConstraints {
    [self.sliderBgView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.centerY.equalTo(self);
        make.height.equalTo(@4.0);
    }];

    [self.progressView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.bottom.left.equalTo(self.sliderBgView);
        make.right.lessThanOrEqualTo(self.sliderBgView);
        make.width.equalTo(@0.0);
    }];

    [self.durationView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.sliderBgView).offset(1);
        make.right.equalTo(self.sliderBgView).offset(-1);
        make.top.bottom.equalTo(self.sliderBgView);
        //        make.width.equalTo(self.sliderBgView);
    }];

    [self.slider bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self).offset(1.0);
        make.centerY.equalTo(self).offset(-1.0);
        make.height.width.equalTo(self);
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (CGRectContainsPoint(self.slider.frame, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end
