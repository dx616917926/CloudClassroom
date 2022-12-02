//
//  BJLPopoverViewController.m
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/20.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLPopoverViewController.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPopoverViewController ()

@property (nonatomic, readwrite) BJLPopoverViewType type;
@property (nonatomic, nullable) NSString *message, *detailMessage;
@property (nonatomic) UIView *backgroundView;
@property (nonatomic, readwrite) BJLPopoverView *popoverView;
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, assign, readwrite) NSTimeInterval timeInterval;
@end

@implementation BJLPopoverViewController

- (instancetype)init {
    return [self initWithPopoverViewType:BJLPopoverViewDefaultType];
}

- (instancetype)initWithPopoverViewType:(BJLPopoverViewType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (instancetype)initWithPopoverViewType:(BJLPopoverViewType)type message:(nullable NSString *)message {
    if (self = [super init]) {
        self.type = type;
        self.message = message;
    }
    return self;
}

- (instancetype)initWithPopoverViewType:(BJLPopoverViewType)type message:(nullable NSString *)message detailMessage:(NSString *)detailMessage {
    if (self = [super init]) {
        self.type = type;
        self.message = message;
        self.detailMessage = detailMessage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self makeSubviewsAndConstraints];
    [self makeActions];
}

- (void)makeSubviewsAndConstraints {
    self.view.backgroundColor = [UIColor clearColor];
    // 毛玻璃效果
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.view addSubview:self.backgroundView];
    [self.backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.popoverView = [[BJLPopoverView alloc] initWithType:self.type];
    if (self.message) {
        self.popoverView.messageLabel.text = self.message;
    }
    if (self.detailMessage) {
        self.popoverView.detailMessageLabel.text = self.detailMessage;
    }

    [self.view addSubview:self.popoverView];
    [self.popoverView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(self.popoverView.viewSize.width));
        make.height.equalTo(@(self.popoverView.viewSize.height));
        make.height.width.lessThanOrEqualTo(self.view);
    }];
}

- (void)makeActions {
    bjl_weakify(self);

    if (self.popoverView.cancelButton) {
        [self.popoverView.cancelButton bjl_addHandler:^(__kindof UIControl *_Nullable sender) {
            bjl_strongify(self);
            if (self.cancelCallback) {
                self.cancelCallback();
            }
            [self bjl_removeFromParentViewControllerAndSuperiew];
            [self stopTimer];
        }];
    }

    if (self.popoverView.confirmButton) {
        [self.popoverView.confirmButton bjl_addHandler:^(__kindof UIControl *_Nullable sender) {
            bjl_strongify(self);
            if (self.popoverView.checkboxButton) {
                if (self.checkConfirmCallback) {
                    self.checkConfirmCallback(self.popoverView.checkboxButton.selected);
                }
            }
            if (self.confirmCallback) {
                self.confirmCallback();
            }
            [self bjl_removeFromParentViewControllerAndSuperiew];
            [self stopTimer];
        }];
    }

    if (self.popoverView.appendButton) {
        [self.popoverView.appendButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.appendCallback) {
                self.appendCallback();
            }
            [self bjl_removeFromParentViewControllerAndSuperiew];
            [self stopTimer];
        }];
    }
}

- (void)updateEffectHidden:(BOOL)hidden {
    self.backgroundView.hidden = hidden;
}

- (void)runTimerWithInterval:(NSTimeInterval)timeInterval {
    if (timeInterval < 0) { return; }
    self.timeInterval = timeInterval;

    if (self.type == BJLExitViewEnforceForbidClass) {
        NSString *title = [NSString stringWithFormat:@"%@(%.0fs)", BJLLocalizedString(@"确定"), self.timeInterval];
        [self.popoverView.confirmButton setTitle:title forState:UIControlStateNormal];
    }

    bjl_weakify(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify_ifNil(self) {
            [timer invalidate];
            return;
        }

        self.timeInterval = MAX(0.0, self.timeInterval - 1);
        if (self.type == BJLExitViewEnforceForbidClass) {
            NSString *title = [NSString stringWithFormat:@"%@(%.0fs)", BJLLocalizedString(@"确定"), self.timeInterval];
            [self.popoverView.confirmButton setTitle:title forState:UIControlStateNormal];
        }

        if (self.timeInterval <= 0.0) {
            [self stopTimer];
            [self.popoverView.confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        if (self.timerCallback) {
            self.timerCallback(self, self.timeInterval);
        }
    }];

    if (self.timerCallback) {
        self.timerCallback(self, self.timeInterval);
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

@end

NS_ASSUME_NONNULL_END
