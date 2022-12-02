//
//  BJLScMediaControlView.m
//  BJLiveCore
//
//  Created by 辛亚鹏 on 2021/7/20.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLScMediaControlView.h"
#import "BJLScProgressView.h"

#import "BJLScAppearance.h"

@interface BJLScMediaControlView ()

@property (nonatomic) UILabel *currentTimeLabel, *durationLabel;
@property (nonatomic) UIButton *playButton, *scaleButton;
@property (nonatomic) BJLScProgressView *progressView;
@property (nonatomic) BOOL stopUpdateProgress;
@property (nonatomic, nullable) CAGradientLayer *gradientLayer;

@end

@implementation BJLScMediaControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSubview];
        [self addAction];
        [self addObserver];
    }
    return self;
}

#pragma mark - public

- (void)updateCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    if (self.stopUpdateProgress) {
        return;
    }
    BOOL durationInvalid = (ceil(duration) <= 0);
    self.currentTimeLabel.text = durationInvalid ? @"" : [self stringFromTimeInterval:currentTime totalTimeInterval:duration];
    self.durationLabel.text = durationInvalid ? @"" : [self stringFromTimeInterval:duration totalTimeInterval:duration];
    [self.progressView updateCurrentTime:currentTime duration:duration];
}

- (void)updateScaleButtonSelected:(BOOL)isSelected {
    self.scaleButton.selected = isSelected;
}

- (void)updatePlayButtonSelected:(BOOL)isSelected {
    self.playButton.selected = isSelected;
}

#pragma mark -

- (void)makeSubview {
    self.playButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.accessibilityIdentifier = BJLKeypath(self, playButton);
        [button setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_warming_play"] forState:UIControlStateNormal];
        [button setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_warming_pause"] forState:UIControlStateSelected];
        button;
    });

    self.scaleButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.accessibilityIdentifier = BJLKeypath(self, scaleButton);
        [button setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_warming_full"] forState:UIControlStateNormal];
        [button setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_warming_normal"] forState:UIControlStateSelected];
        button;
    });

    self.currentTimeLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, currentTimeLabel);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.0];
        label.text = @"00:00";
        label;
    });

    self.durationLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, durationLabel);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.0];
        label.text = @"00:00";
        label;
    });

    self.progressView = ({
        BJLScProgressView *view = [[BJLScProgressView alloc] init];
        view.accessibilityIdentifier = BJLKeypath(self, progressView);
        [view.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [view.slider addTarget:self action:@selector(touchSlider:) forControlEvents:UIControlEventTouchDragInside];
        [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpInside];
        [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpOutside];
        [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchCancel];
        view;
    });

    [self addSubview:self.playButton];
    [self addSubview:self.scaleButton];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.durationLabel];
    [self addSubview:self.progressView];

    [self.playButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.bjl_safeAreaLayoutGuide ?: self).offset(6.0);
        make.bottom.equalTo(self).offset(-6.0);
        make.height.width.equalTo(@32.0);
    }];

    [self.scaleButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.bjl_safeAreaLayoutGuide ?: self).offset(-6.0);
        make.bottom.equalTo(self).offset(-6.0);
        make.height.width.equalTo(@32.0);
    }];

    [self.currentTimeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self).offset(12);
        make.left.equalTo(self.playButton);
        make.width.greaterThanOrEqualTo(@40);
        make.bottom.equalTo(self.playButton.bjl_top).offset(-2);
        make.height.equalTo(@18);
    }];
    [self.durationLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.scaleButton);
        make.top.bottom.width.equalTo(self.currentTimeLabel);
    }];

    [self.progressView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.currentTimeLabel);
        make.left.equalTo(self.currentTimeLabel.bjl_right).offset(6);
        make.right.equalTo(self.durationLabel.bjl_left).offset(-6);
        make.height.equalTo(@18);
    }];
}

- (void)addObserver {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self, bounds) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        if (!CGRectEqualToRect(self.bounds, CGRectZero)) {
            [self addGradientLayer];
        }
        return YES;
    }];
}

- (void)addGradientLayer {
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
    }
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;

    UIColor *color1 = [UIColor colorWithWhite:0 alpha:0.9];
    UIColor *color2 = [UIColor colorWithWhite:0 alpha:0.38];
    UIColor *color3 = [UIColor colorWithWhite:0 alpha:0.01];
    self.gradientLayer.colors = @[(id)color1.CGColor, (id)color2.CGColor, (id)color3.CGColor];
    self.gradientLayer.startPoint = CGPointMake(0.5, 1);
    self.gradientLayer.endPoint = CGPointMake(0.5, 0);
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

#pragma mark -

- (void)addAction {
    bjl_weakify(self);
    [self.playButton bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        button.selected = !button.isSelected;
        if (self.playCallback) {
            self.playCallback(!button.selected);
        }
    }];

    [self.scaleButton bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        button.selected = !button.isSelected;
        if (self.scaleCallback) {
            self.scaleCallback(button.isSelected);
        }
    }];
}

#pragma mark - progress view actions

- (void)sliderChanged:(UISlider *)slider {
    self.stopUpdateProgress = YES;
    if (slider.maximumValue > 0.0) {
        self.currentTimeLabel.text = [self stringFromTimeInterval:slider.value totalTimeInterval:slider.maximumValue];
    }
    [self.progressView updateCurrentTime:slider.value duration:slider.maximumValue];
}

- (void)touchSlider:(UISlider *)slider {
    self.stopUpdateProgress = YES;
    if (slider.maximumValue > 0.0) {
        self.currentTimeLabel.text = [self stringFromTimeInterval:slider.value totalTimeInterval:slider.maximumValue];
    }
    [self.progressView updateCurrentTime:slider.value duration:slider.maximumValue];
}

- (void)dragSlider:(UISlider *)slider {
    self.stopUpdateProgress = NO;
    if (self.mediaSeekCallback) {
        self.mediaSeekCallback(slider.value);
    }
    [self.progressView updateCurrentTime:slider.value duration:slider.maximumValue];
}

#pragma mark - tools

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval totalTimeInterval:(NSTimeInterval)total {
    int hours = interval / 3600;
    int minums = ((long long)interval % 3600) / 60;
    int seconds = (long long)interval % 60;
    int totalHours = total / 3600;

    if (totalHours > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minums, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02d:%02d", minums, seconds];
    }
}

@end
