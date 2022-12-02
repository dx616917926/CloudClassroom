//
//  BJLPopoverBaseViewController.m
//  BJLiveUI
//
//  Created by Ney on 3/2/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLPopoverBaseViewController.h"
#import "BJLAppearance.h"
#import "BJLTheme.h"
#import "UIView+panGesture.h"

@interface BJLPopoverBaseViewController ()
@property (nonatomic, weak, readwrite) BJLRoom *room;
@property (nonatomic, readwrite) UIView *contentView;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *windowContaienrView;
@property (nonatomic, strong) UIView *windowHeadView;
@property (nonatomic, strong) UIImageView *windowIconImageView;
@property (nonatomic, strong) UILabel *windowTitleLabel;
@property (nonatomic, strong) UIButton *windowCloseButton;
@property (nonatomic, strong) UIView *windowHeadSeparatorLineView;

@property (nonatomic, strong) UIView *contentContaienrView;
@end

@implementation BJLPopoverBaseViewController
- (instancetype)initWithRoom:(BJLRoom *)room {
    if (!room) { return nil; }

    self = [super init];
    if (self) {
        self.room = room;
        _showHeadBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
    self.windowContaienrView.bjl_titleBarHeight = 30.0;
    [self.windowContaienrView bjl_addTitleBarPanGesture];
    bjl_weakify(self);
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.backgroundViewTapEventCallback) {
            self.backgroundViewTapEventCallback(self);
        }
    }];
    [self.view addGestureRecognizer:tap];
}

- (void)showOverParentView {
    if (self.view.superview != self.parentView) {
        [self bjl_removeFromParentViewControllerAndSuperiew];
        [self.parentView addSubview:self.view];
        if (self.parentVC) {
            [self.parentVC addChildViewController:self];
            [self didMoveToParentViewController:self.parentVC];
        }
        if (self.view.superview) {
            [self.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
                make.edges.equalTo(self.view.superview);
            }];
        }
    }
}

- (void)hide {
    [self closeButtonHandler:nil];
}

- (void)setIcon:(UIImage *)icon {
    _icon = icon;
    self.windowIconImageView.image = _icon;

    [self.windowTitleLabel bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.windowHeadView).offset(icon ? 20.0 : 5.0);
    }];
}

- (void)setHeadTitle:(NSString *)headTitle {
    _headTitle = [headTitle copy];
    self.windowTitleLabel.text = _headTitle;
}

- (void)setShowHeadBar:(BOOL)showHeadBar {
    if (showHeadBar != _showHeadBar) {
        if (self.viewLoaded) {
            [self.windowHeadView bjl_updateConstraints:^(BJLConstraintMaker *make) {
                make.height.equalTo(showHeadBar ? @30.0 : @0.0);
            }];
        }
    }
    _showHeadBar = showHeadBar;
}

#pragma mark - helper
- (void)buildUI {
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.windowContaienrView];
    [self.windowContaienrView addSubview:self.windowHeadView];
    [self.windowContaienrView addSubview:self.contentContaienrView];

    [self.backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.windowContaienrView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        if (self.positionBlock) {
            self.positionBlock(self, self.windowContaienrView, self.windowContaienrView.superview);
        }
        else {
            make.center.equalTo(self.view);
        }
        make.top.equalTo(self.windowHeadView);
        make.left.bottom.right.equalTo(self.contentContaienrView);
    }];

    [self.windowHeadView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.top.right.equalTo(self.windowContaienrView);
        make.height.equalTo(self.showHeadBar ? @30.0 : @0.0);
    }];
    [self.contentContaienrView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.windowHeadView.bjl_bottom);
        make.left.bottom.right.equalTo(self.windowContaienrView);
    }];

    [self.contentContaienrView addSubview:self.contentView];
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.contentContaienrView);
    }];
}

#pragma mark - event handler
- (void)closeButtonHandler:(UIButton *)button {
    if (self.closeEventBlock) {
        self.closeEventBlock(self);
    }
    [self bjl_removeFromParentViewControllerAndSuperiew];
}

#pragma mark - getter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.accessibilityIdentifier = @"backgroundView";
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundView;
}

- (UIView *)windowContaienrView {
    if (!_windowContaienrView) {
        _windowContaienrView = [[UIView alloc] init];
        _windowContaienrView.accessibilityIdentifier = @"windowContaienrView";
        _windowContaienrView.backgroundColor = BJLTheme.windowBackgroundColor;
        _windowContaienrView.clipsToBounds = YES;
        _windowContaienrView.layer.cornerRadius = 3;
    }
    return _windowContaienrView;
}

- (UIView *)windowHeadView {
    if (!_windowHeadView) {
        _windowHeadView = [[UIView alloc] init];
        _windowHeadView.accessibilityIdentifier = @"windowHeadView";
        _windowHeadView.backgroundColor = [UIColor clearColor];
        _windowHeadView.clipsToBounds = YES;

        [_windowHeadView addSubview:self.windowIconImageView];
        [_windowHeadView addSubview:self.windowTitleLabel];
        [_windowHeadView addSubview:self.windowCloseButton];
        [_windowHeadView addSubview:self.windowHeadSeparatorLineView];

        [self.windowIconImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(_windowHeadView);
            make.width.height.equalTo(@15.0);
            make.left.equalTo(@(5.0));
        }];
        [self.windowTitleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(_windowHeadView);
            make.left.equalTo(_windowHeadView).offset(20.0);
            make.right.lessThanOrEqualTo(self.windowCloseButton.bjl_left).offset(-2.0);
        }];
        [self.windowCloseButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(_windowHeadView);
            make.right.equalTo(@(-5.0));
        }];
        [self.windowHeadSeparatorLineView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.left.bottom.right.equalTo(_windowHeadView);
            make.height.equalTo(@(BJL1Pixel()));
        }];
    }
    return _windowHeadView;
}

- (UIImageView *)windowIconImageView {
    if (!_windowIconImageView) {
        _windowIconImageView = [[UIImageView alloc] init];
        _windowIconImageView.accessibilityIdentifier = @"windowIconImageView";
        _windowIconImageView.image = [UIImage bjl_imageNamed:@"bjl_rollcall_window_head"];
        _windowIconImageView.backgroundColor = [UIColor clearColor];
    }
    return _windowIconImageView;
}

- (UILabel *)windowTitleLabel {
    if (!_windowTitleLabel) {
        _windowTitleLabel = [[UILabel alloc] init];
        _windowTitleLabel.accessibilityIdentifier = @"windowTitleLabel";
        _windowTitleLabel.text = BJLLocalizedString(@"点名");
        _windowTitleLabel.font = [UIFont systemFontOfSize:14];
        _windowTitleLabel.textColor = BJLTheme.viewTextColor;
        _windowTitleLabel.backgroundColor = UIColor.clearColor;
    }
    return _windowTitleLabel;
}

- (UIButton *)windowCloseButton {
    if (!_windowCloseButton) {
        _windowCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _windowCloseButton.accessibilityIdentifier = @"windowCloseButton";

        [_windowCloseButton setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
        //        [_windowCloseButton setImage:[UIImage bjl_imageNamed:@"window_close"] forState:UIControlStateNormal];

        bjl_weakify(self);
        [_windowCloseButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self closeButtonHandler:button];
        }];
    }
    return _windowCloseButton;
}

- (UIView *)windowHeadSeparatorLineView {
    if (!_windowHeadSeparatorLineView) {
        _windowHeadSeparatorLineView = [[UIView alloc] init];
        _windowHeadSeparatorLineView.backgroundColor = BJLTheme.separateLineColor;
        _windowHeadSeparatorLineView.accessibilityIdentifier = @"windowHeadSeparatorLineView";
    }
    return _windowHeadSeparatorLineView;
}

- (UIView *)contentContaienrView {
    if (!_contentContaienrView) {
        _contentContaienrView = [[UIView alloc] init];
        _contentContaienrView.backgroundColor = [UIColor clearColor];
        _contentContaienrView.accessibilityIdentifier = @"contentContaienrView";
    }
    return _contentContaienrView;
}
@end
