//
//  BJLSettingBeautyView.m
//  BJLiveUIBigClass
//
//  Created by 辛亚鹏 on 2021/10/8.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLSettingBeautyView.h"
#import "BJLAppearance.h"

@interface BJLScBeautySlider: UISlider

@end

@implementation BJLScBeautySlider

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

// 增大响应区域
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -24, -24);
    return CGRectContainsPoint(bounds, point);
}

@end

@interface BJLSettingBeautyView ()

@property (nonatomic) BJLVerticalButton *imageButton;
@property (nonatomic) UILabel *label;
@property (nonatomic) BJLScBeautySlider *slider;
@property (nonatomic, nullable) UIView *sliderBgView;
@property (nonatomic, nullable) UIView *progressView;
@property (nonatomic, nullable) UIView *durationView;
// 开启美颜时, 是否需要给默认值
@property (nonatomic) BOOL shouldDefaultValue;
@property (nonatomic) float sliderValue;

@end

@implementation BJLSettingBeautyView

- (instancetype)initWithTitle:(NSString *)title normalImage:(NSString *)normalImage disableImage:(NSString *)disableImage value:(float)value {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // 只有当value为0时才需要给默认值
        self.shouldDefaultValue = value == 0;
        self.sliderValue = value;
        self.imageButton = [BJLVerticalButton new];
        self.imageButton.midSpace = 2.0;
        self.imageButton.accessibilityIdentifier = BJLKeypath(self, imageButton);
        [self.imageButton bjl_setImage:[UIImage bjl_imageNamed:normalImage] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [self.imageButton bjl_setImage:[UIImage bjl_imageNamed:disableImage] forState:UIControlStateDisabled];
        [self.imageButton bjl_setTitle:title forState:UIControlStateNormal];
        [self.imageButton bjl_setTitleColor:[BJLTheme brandColor] forState:UIControlStateNormal];
        [self.imageButton bjl_setTitleColor:[BJLTheme viewTextColor] forState:UIControlStateDisabled];
        self.imageButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.imageButton.enabled = NO;
        [self makeSubview];
        [self makeObserver];
    }
    return self;
}

- (void)dealloc {
    [self bjl_stopAllKeyValueObserving];
}

- (void)beautyOn:(BOOL)isOn {
    if (isOn) {
        // 首次开启美颜需要给定默认值
        if (self.shouldDefaultValue) {
            self.slider.value = self.slider.maximumValue / 2.0;
            self.shouldDefaultValue = NO;
        }
        [self.slider setThumbImage:[UIImage bjl_imageNamed:@"bjl_setting_slider"] forState:UIControlStateNormal];
        self.slider.userInteractionEnabled = YES;
        self.label.hidden = NO;
        self.imageButton.enabled = YES;
        [self.progressView bjl_updateConstraints:^(BJLConstraintMaker *make) {
            make.width.equalTo(@(0.5));
        }];
        [self updateSubviewConstraints];
        if (self.valueChangeCallback) {
            self.valueChangeCallback(self.slider.value);
        }
    }
    else {
        [self.slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        self.slider.userInteractionEnabled = NO;
        self.label.hidden = YES;
        self.imageButton.enabled = NO;
        [self.progressView bjl_updateConstraints:^(BJLConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
        if (self.valueChangeCallback) {
            self.valueChangeCallback(0);
        }
    }
}

- (void)makeObserver {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.sliderBgView, bounds) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        if (![value isEqual:oldValue]) {
            [self updateSubviewConstraints];
        }
        return YES;
    }];
}

- (void)makeSubview {
    [self addSubview:self.imageButton];
    [self.imageButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(@36);
    }];

    // slider
    self.sliderBgView = ({
        UIView *view = [[UIView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, sliderBgView);
        view.layer.cornerRadius = 2.0;
        view.layer.masksToBounds = YES;
        view;
    });

    self.slider = ({
        BJLScBeautySlider *slider = [[BJLScBeautySlider alloc] init];
        slider.maximumValue = 9.0;
        slider.value = self.sliderValue;
        slider.accessibilityIdentifier = BJLKeypath(self, slider);
        slider.backgroundColor = [UIColor clearColor];
        slider.minimumTrackTintColor = [UIColor clearColor];
        slider.maximumTrackTintColor = [UIColor clearColor];
        [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        slider;
    });

    self.progressView = ({
        UIView *view = [[UIImageView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, progressView);
        view.layer.cornerRadius = 3.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor bjl_colorWithHexString:@"#1795FF"];
        view;
    });

    self.durationView = ({
        UIView *view = [[UIImageView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, durationView);
        view.layer.cornerRadius = 3.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [BJLTheme separateLineColor];
        view;
    });

    [self.sliderBgView addSubview:self.durationView];
    [self.sliderBgView addSubview:self.progressView];

    [self addSubview:self.sliderBgView];
    [self addSubview:self.slider];

    [self.sliderBgView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.imageButton.bjl_right).offset(32);
        make.right.equalTo(self);
        make.top.equalTo(self.bjl_centerY);
        make.height.equalTo(@6.0);
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
    }];

    [self.slider bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.sliderBgView).offset(1.0);
        make.right.equalTo(self.sliderBgView).offset(-1.0);
        make.centerY.equalTo(self.sliderBgView);
    }];

    self.label = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [BJLTheme brandColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self addSubview:self.label];
    [self.label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.lessThanOrEqualTo(self);
    }];

    bjl_weakify(self);
    [self.slider bjl_addHandler:^(__kindof UISlider *_Nonnull sender, UIControlEvents event) {
        bjl_strongify(self);
        if (self.valueChangeCallback) {
            self.valueChangeCallback(sender.value);
        }
        [self updateSubviewConstraints];
    } forControlEvents:UIControlEventValueChanged];
}

- (void)updateSubviewConstraints {
    CGFloat offset = self.slider.value / self.slider.maximumValue * self.sliderBgView.bounds.size.width;
    self.label.text = [NSString stringWithFormat:@"%.f", self.slider.value / self.slider.maximumValue * 100];

    [self.progressView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.width.equalTo(@(offset));
    }];
    [self.label bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.progressView.bjl_right);
    }];
}

@end
