//
//  BJLQuestionResponderWindowViewController.m
//  BJLiveUI
//
//  Created by 凡义 on 2019/5/22.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLiveCore.h>

#import "BJLQuestionResponderWindowViewController.h"
#import "BJLQuestionResponderWindowViewController+protected.h"
#import "BJLQuestionResponderWindowViewController+historyList.h"
#import "BJLWindowTopBar.h"
#import "BJLWindowBottomBar.h"
#import "BJLAppearance.h"
#import "BJLTheme.h"

#define onePixel (1.0 / [UIScreen mainScreen].scale)

@interface BJLQuestionResponderWindowViewController () <UITextFieldDelegate>

@property (nonatomic) BJLQuestionResponderWindowLayout layout;

@property (nonatomic) BJLWindowTopBar *topBar;
@property (nonatomic) BJLWindowBottomBar *bottomBar;

@property (nonatomic) BOOL isPortrait;

@end

@implementation BJLQuestionResponderWindowViewController

- (instancetype)initWithRoom:(BJLRoom *)room
                      layout:(BJLQuestionResponderWindowLayout)layout
         historeQuestionList:(NSArray *_Nullable)recordList {
    self = [super init];
    if (self) {
        self.isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;
        self.layout = layout;
        self->_room = room;
        self.questionResponderList = recordList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;

    self.topBar.backgroundView.hidden = YES;
    self.bottomBar.backgroundView.hidden = YES;

    [self makeCommanConstraints];
    [self updateConstraints];
    [self makeObserving];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 仅用于通知上一层是否也要显示一个 overlay 来隐藏键盘，无论上层有没有，控制器内始终会显示一个 overlay
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrameWithNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrameWithNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self hideKeyboardView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self.touchBarrierWrapper bjl_removeFromParentViewControllerAndSuperiew];
}

#pragma mark - private
- (void)keyboardChangeFrameWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) {
        return;
    }
    CGRect keyboardFrame = bjl_as(userInfo[UIKeyboardFrameEndUserInfoKey], NSValue).CGRectValue;
    if (self.keyboardFrameChangeCallback) {
        self.keyboardFrameChangeCallback(keyboardFrame);
    }
}

- (CGSize)getSize {
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat relativeWidth, relativeHeight;

    BOOL isIphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (isIphone) {
        relativeWidth = 0.5;
        relativeHeight = 0.6;
    }
    else {
        relativeWidth = 0.4;
        relativeHeight = 0.3;
    }
    return CGSizeMake(relativeWidth * screenSize.width, relativeHeight * screenSize.height);
}

- (void)makeCommanConstraints {
    // top bar
    self.topBar = ({
        BJLWindowTopBar *view = [BJLWindowTopBar new];
        view.accessibilityIdentifier = BJLKeypath(self, topBar);
        view.captionLabel.text = BJLLocalizedString(@"抢答器");
        view.fullscreenButton.hidden = YES;
        view.maximizeButton.hidden = YES;
        view.closeButton.hidden = NO;
        [view.closeButton addTarget:self action:@selector(closeUI) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:view];
        bjl_return view;
    });
    [self.topBar bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(BJLAppearance.userWindowDefaultBarHeight));
    }];

    self.topGapLine = ({
        UIView *view = [UIView bjl_createSeparateLine];
        view.accessibilityIdentifier = BJLKeypath(self, topGapLine);
        bjl_return view;
    });
    [self.topBar addSubview:self.topGapLine];
    [self.topGapLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.left.right.equalTo(self.topBar);
        make.height.equalTo(@(onePixel));
    }];

    // bottom bar
    self.bottomBar = ({
        BJLWindowBottomBar *view = [BJLWindowBottomBar new];
        view.resizeHandleImageView.hidden = self.isPortrait;
        view.accessibilityIdentifier = BJLKeypath(self, bottomBar);
        [self.view insertSubview:view belowSubview:self.topBar];
        bjl_return view;
    });
    [self.bottomBar bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(self.isPortrait ? -50.0 : 0.0);
        make.height.equalTo(@40.0);
    }];

    self.bottomGapLine = ({
        UIView *view = [UIView bjl_createSeparateLine];
        view.accessibilityIdentifier = BJLKeypath(self, bottomGapLine);
        bjl_return view;
    });
    [self.bottomBar addSubview:self.bottomGapLine];
    [self.bottomGapLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.bottomBar);
        make.height.equalTo(@(onePixel));
    }];

    UITapGestureRecognizer *tapGesture = ({
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardView)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture;
    });
    // overlay
    self.overlayView = ({
        UIView *view = [UIView new];
        view.userInteractionEnabled = YES;
        view.backgroundColor = [UIColor clearColor];
        [view addGestureRecognizer:tapGesture];
        view.accessibilityIdentifier = BJLKeypath(self, overlayView);
        view;
    });

    // normal
    self.editContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, editContainerView);
        [self.view addSubview:view];
        bjl_return view;
    });
    [self.editContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.topBar.bjl_bottom);
        make.left.right.equalTo(self.view);
        if (self.isPortrait) {
            make.bottom.equalTo(self.bottomBar);
        }
        else {
            make.bottom.equalTo(self.bottomBar.bjl_top);
        }
    }];

    UIView *cornerView = ({
        UIView *view = [BJLHitTestView new];
        view.clipsToBounds = YES;
        view.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        view.layer.borderWidth = onePixel;
        view.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
        [self.editContainerView addSubview:view];
        bjl_return view;
    });

    self.minusButton = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"-" forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateHighlighted];
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateHighlighted | UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:28]];
        [button addTarget:self action:@selector(minusTime) forControlEvents:UIControlEventTouchUpInside];
        [cornerView addSubview:button];
        bjl_return button;
    });
    self.plusButton = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"+" forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateHighlighted];
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateHighlighted | UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:28]];
        [button addTarget:self action:@selector(plusTime) forControlEvents:UIControlEventTouchUpInside];
        [cornerView addSubview:button];
        bjl_return button;
    });

    self.timeTextField = ({
        BJLTextField *textField = [BJLTextField new];
        textField.accessibilityIdentifier = BJLKeypath(self, timeTextField);
        textField.textColor = BJLTheme.viewTextColor;
        textField.font = [UIFont systemFontOfSize:16];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.layer.borderWidth = onePixel;
        textField.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
        textField.textInsets = textField.editingInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        textField.delegate = self;
        textField.text = @"0";
        [cornerView addSubview:textField];
        bjl_return textField;
    });

    UILabel *leftLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"倒计时: ");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentRight;
        [self.editContainerView addSubview:label];
        bjl_return label;
    });

    UILabel *rightLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"秒后开始抢答");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentLeft;
        [self.editContainerView addSubview:label];
        bjl_return label;
    });

    UILabel *tipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"倒计时结束后开始抢答，设置为0时发起后立即开始抢答");
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [self.editContainerView addSubview:label];
        bjl_return label;
    });

    [cornerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.editContainerView);
        make.height.equalTo(@34.0);
        if (self.isPortrait) {
            make.top.equalTo(self.editContainerView).offset(30.0);
        }
        else {
            make.bottom.equalTo(self.editContainerView.bjl_centerY).offset(-5.0);
        }
        make.left.greaterThanOrEqualTo(self.editContainerView);
        make.right.lessThanOrEqualTo(self.editContainerView);
    }];
    [tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.editContainerView);
        if (self.isPortrait) {
            make.top.equalTo(cornerView.bjl_bottom).offset(20.0);
            make.height.equalTo(@16.0);
        }
        else {
            make.top.equalTo(self.editContainerView.bjl_centerY).offset(5.0);
        }
        make.left.greaterThanOrEqualTo(self.editContainerView);
        make.right.lessThanOrEqualTo(self.editContainerView);
    }];

    [self.timeTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.hugging.compressionResistance.required();
        make.center.equalTo(cornerView);
        make.top.bottom.equalTo(cornerView);
        make.width.equalTo(@(44)).priorityHigh();
    }];
    [self.plusButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.timeTextField);
        make.left.equalTo(self.timeTextField.bjl_right);
        make.height.equalTo(self.timeTextField.bjl_height);
        make.width.equalTo(@(32));
        make.right.equalTo(cornerView.bjl_right);
    }];
    [self.minusButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.timeTextField);
        make.right.equalTo(self.timeTextField.bjl_left);
        make.height.equalTo(self.timeTextField.bjl_height);
        make.width.equalTo(@(32));
        make.left.equalTo(cornerView.bjl_left);
    }];
    [leftLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.timeTextField);
        make.right.equalTo(cornerView.bjl_left).offset(-10);
        make.height.equalTo(self.timeTextField);
        make.left.greaterThanOrEqualTo(self.editContainerView);
    }];
    [rightLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.timeTextField);
        make.left.equalTo(cornerView.bjl_right).offset(10);
        make.height.equalTo(self.timeTextField);
        make.right.lessThanOrEqualTo(self.editContainerView);
    }];

    self.bottomEditContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, bottomEditContainerView);
        [self.bottomBar addSubview:view];
        view.hidden = YES;
        bjl_return view;
    });

    self.publishButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, publishButton);
        button.backgroundColor = [BJLTheme brandColor];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"发布") forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
        if (self.isPortrait) {
            [self.editContainerView addSubview:button];
        }
        else {
            [self.bottomEditContainerView addSubview:button];
        }
        button;
    });
    self.resetButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, resetButton);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"重置") forState:UIControlStateNormal];
        [button setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
        button.backgroundColor = [BJLTheme subButtonBackgroundColor];
        [button addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
        if (self.isPortrait) {
            [self.editContainerView addSubview:button];
        }
        else {
            [self.bottomEditContainerView addSubview:button];
        }
        button;
    });
    self.editHistoryButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = BJLKeypath(self, editHistoryButton);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"查看记录") forState:UIControlStateNormal];
        [button setTitle:BJLLocalizedString(@"返回") forState:UIControlStateSelected];
        [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [button addTarget:self action:@selector(showHistoryList) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomEditContainerView addSubview:button];
        button;
    });
    [self.bottomEditContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.bottomBar);
    }];
    if (self.isPortrait) {
        [self.publishButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.width.equalTo(@96.0);
            make.height.equalTo(@32.0);
            make.top.equalTo(tipLabel.bjl_bottom).offset(60.0);
            make.left.equalTo(self.editContainerView.bjl_centerX).offset(15.0);
        }];

        [self.resetButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.width.height.equalTo(self.publishButton);
            make.right.equalTo(self.editContainerView.bjl_centerX).offset(-15.0);
        }];
    }
    else {
        [self.publishButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.equalTo(self.bottomBar);
            make.right.equalTo(self.bottomBar).offset(-10);
            make.top.bottom.equalTo(self.bottomBar).inset(8.0);
            make.width.equalTo(@80.0);
        }];

        [self.resetButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.equalTo(self.bottomBar);
            make.right.equalTo(self.publishButton.bjl_left).offset(-10);
            make.left.greaterThanOrEqualTo(self.editHistoryButton.bjl_right).offset(10);
            make.top.bottom.equalTo(self.publishButton);
            make.width.equalTo(self.publishButton);
        }];
    }

    [self.editHistoryButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.bottomBar);
        make.width.height.equalTo(self.publishButton);
        make.left.equalTo(self.bottomBar).offset(12);
    }];

    // publish
    self.publishingContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, publishingContainerView);
        [self.view addSubview:view];
        bjl_return view;
    });
    [self.publishingContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.topBar.bjl_bottom);
        make.left.right.equalTo(self.view);
        if (self.isPortrait) {
            make.bottom.equalTo(self.bottomBar);
        }
        else {
            make.bottom.equalTo(self.bottomBar.bjl_top);
        }
    }];

    UILabel *publishTipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"发布成功,正在抢答...");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        [self.publishingContainerView addSubview:label];
        bjl_return label;
    });
    [publishTipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        if (self.isPortrait) {
            make.centerX.equalTo(self.publishingContainerView);
            make.top.equalTo(self.publishingContainerView).offset(60.0);
        }
        else {
            make.center.equalTo(self.publishingContainerView);
        }
        make.left.greaterThanOrEqualTo(self.publishingContainerView);
        make.right.lessThanOrEqualTo(self.publishingContainerView);
    }];

    self.bottomPublishignContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, bottomPublishignContainerView);
        [self.bottomBar addSubview:view];
        view.hidden = YES;
        bjl_return view;
    });

    self.endButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, endButton);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"结束") forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        button.backgroundColor = [BJLTheme brandColor];
        [button addTarget:self action:@selector(end) forControlEvents:UIControlEventTouchUpInside];
        if (self.isPortrait) {
            [self.publishingContainerView addSubview:button];
        }
        else {
            [self.bottomPublishignContainerView addSubview:button];
        }
        button;
    });
    self.revokeButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, revokeButton);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"撤销") forState:UIControlStateNormal];
        [button setTitleColor:[BJLTheme subButtonTextColor] forState:UIControlStateNormal];
        button.backgroundColor = [BJLTheme subButtonBackgroundColor];
        [button addTarget:self action:@selector(revoke) forControlEvents:UIControlEventTouchUpInside];
        if (self.isPortrait) {
            [self.publishingContainerView addSubview:button];
        }
        else {
            [self.bottomPublishignContainerView addSubview:button];
        }
        button;
    });
    self.publishingHistoryButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, publishingHistoryButton);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"查看记录") forState:UIControlStateNormal];
        [button setTitle:BJLLocalizedString(@"返回") forState:UIControlStateSelected];
        [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showHistoryList) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomPublishignContainerView addSubview:button];
        button;
    });

    [self.bottomPublishignContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.bottomBar);
    }];

    if (self.isPortrait) {
        [self.endButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.width.equalTo(@96.0);
            make.height.equalTo(@32.0);
            make.top.equalTo(publishTipLabel.bjl_bottom).offset(64.0);
            make.left.equalTo(self.publishingContainerView.bjl_centerX).offset(15.0);
        }];

        [self.revokeButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.height.width.equalTo(self.endButton);
            make.right.equalTo(self.publishingContainerView.bjl_centerX).offset(-15.0);
        }];
    }
    else {
        [self.endButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.equalTo(self.bottomBar);
            make.right.equalTo(self.bottomBar).offset(-10);
            make.top.bottom.equalTo(self.bottomBar).inset(8.0);
            make.width.equalTo(@80.0);
        }];
        [self.revokeButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.equalTo(self.bottomBar);
            make.right.equalTo(self.endButton.bjl_left).offset(-10);
            make.left.greaterThanOrEqualTo(self.publishingHistoryButton.bjl_right).offset(10);
            make.top.bottom.equalTo(self.endButton);
            make.width.equalTo(self.endButton);
        }];
    }

    [self.publishingHistoryButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.bottomBar);
        make.width.height.equalTo(self.endButton);
        make.left.equalTo(self.bottomBar).offset(12);
    }];

    // end
    self.resultContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, resultContainerView);
        [self.view addSubview:view];
        bjl_return view;
    });
    [self.resultContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.topBar.bjl_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomBar.bjl_top);
    }];

    UIView *containerView = ({
        UIView *view = [BJLHitTestView new];
        view.backgroundColor = [UIColor clearColor];
        [self.resultContainerView addSubview:view];
        bjl_return view;
    });

    self.userNameLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.accessibilityIdentifier = BJLKeypath(self, userNameLabel);
        [containerView addSubview:label];
        bjl_return label;
    });
    self.noneSuccessLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"没有人抢到哦~");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.accessibilityIdentifier = BJLKeypath(self, noneSuccessLabel);
        label.hidden = YES;
        [self.resultContainerView addSubview:label];
        bjl_return label;
    });

    self.successImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_questionResponder_winner"]];
        [containerView addSubview:imageView];
        bjl_return imageView;
    });

    self.groupColorLabel = ({
        UILabel *label = [UILabel new];
        label.layer.cornerRadius = 6.0;
        label.layer.masksToBounds = YES;
        label.accessibilityIdentifier = BJLKeypath(self, groupColorLabel);
        [containerView addSubview:label];
        bjl_return label;
    });
    self.groupNameLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"--";
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.viewSubTextColor;
        [label setAlpha:0.5];
        label.textAlignment = NSTextAlignmentLeft;
        label.accessibilityIdentifier = BJLKeypath(self, groupNameLabel);
        [containerView addSubview:label];
        bjl_return label;
    });
    self.inviteSpeakButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, inviteSpeakButton);
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [button setTitle:BJLLocalizedString(@"邀请回答") forState:UIControlStateNormal];
        [button bjl_setBackgroundColor:[BJLTheme separateLineColor] forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.width.equalTo(@80);
            make.height.equalTo(@24);
        }];
        [containerView addSubview:button];
        button;
    });

    [containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.resultContainerView);
        make.left.right.equalTo(self.resultContainerView);
    }];

    [self.successImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(containerView);
        make.centerX.equalTo(containerView);
    }];
    [self.userNameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(containerView);
        make.top.equalTo(self.successImageView.bjl_bottom).offset(4);
    }];
    [self.groupNameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(containerView);
        make.top.equalTo(self.userNameLabel.bjl_bottom).offset(4);
    }];
    [self.groupColorLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.groupNameLabel);
        make.right.equalTo(self.groupNameLabel.bjl_left).offset(-5);
        make.width.height.equalTo(@(12.0));
    }];
    [self.inviteSpeakButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(containerView);
        make.top.equalTo(self.userNameLabel.bjl_bottom).offset(25);
        make.bottom.equalTo(@-12);
    }];

    [self.noneSuccessLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.resultContainerView);
        make.left.greaterThanOrEqualTo(self.resultContainerView).offset(10);
        make.right.lessThanOrEqualTo(self.resultContainerView).offset(-10);
    }];

    self.bottomResultContainerView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, bottomResultContainerView);
        [self.bottomBar addSubview:view];
        view.hidden = YES;
        bjl_return view;
    });

    self.reeditButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, reeditButton);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"重新编辑") forState:UIControlStateNormal];
        button.backgroundColor = [BJLTheme brandColor];
        [button setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reedit) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomResultContainerView addSubview:button];
        button;
    });
    self.resultHistoryButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, resultHistoryButton);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitle:BJLLocalizedString(@"查看记录") forState:UIControlStateNormal];
        [button setTitle:BJLLocalizedString(@"返回") forState:UIControlStateSelected];
        [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showHistoryList) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomResultContainerView addSubview:button];
        button;
    });

    [self.bottomResultContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.bottomBar);
    }];
    [self.reeditButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.bottomBar);
        make.right.equalTo(self.bottomBar).offset(-10);
        make.top.bottom.equalTo(self.bottomBar).inset(8.0);
        make.width.equalTo(@80.0);
    }];
    [self.resultHistoryButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.bottomBar);
        make.top.bottom.equalTo(self.reeditButton);
        make.left.equalTo(self.bottomBar).offset(12);
    }];
}

- (void)updateResultContainerViewWithShouldHiddenWinnerName:(nullable BJLUser *)user {
    self.noneSuccessLabel.hidden = !!user;
    self.successImageView.hidden = !user;
    self.userNameLabel.hidden = !user;
    self.inviteSpeakButton.hidden = self.userNameLabel.hidden;

    [self.inviteSpeakButton bjl_removeAllHandlers];
    if (user) {
        bjl_weakify(self);
        [self.inviteSpeakButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.inviteSpeakCallback) {
                self.inviteSpeakCallback(user);
            }
        }];
    }

    UIColor *groupColor = nil;
    NSString *groupName = nil;
    for (BJLUserGroup *group in self.room.onlineUsersVM.groupList) {
        if (group.groupID == user.groupID) {
            groupColor = [UIColor bjl_colorWithHexString:group.color];
            groupName = group.name;
            break;
        }
    }

    if (!user.noGroup && !groupColor) {
        NSString *colorStr = [self.room.onlineUsersVM getGroupColorWithID:user.groupID];
        groupColor = [UIColor bjl_colorWithHexString:colorStr];
    }

    self.groupNameLabel.text = groupName;
    self.groupColorLabel.backgroundColor = groupColor;
    self.groupNameLabel.hidden = !groupName;
    self.groupColorLabel.hidden = !groupName;

    [self.inviteSpeakButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        CGFloat offset = groupName ? 25 : 4;
        make.top.equalTo(self.userNameLabel.bjl_bottom).offset(offset);
    }];
}

- (void)updateConstraints {
    self.bottomEditContainerView.hidden = (self.layout != BJLQuestionResponderWindowLayout_normal);
    self.bottomEditContainerView.userInteractionEnabled = (self.layout == BJLQuestionResponderWindowLayout_normal);
    self.editContainerView.userInteractionEnabled = (self.layout == BJLQuestionResponderWindowLayout_normal);
    self.editHistoryButton.hidden = ![self.questionResponderList count];
    self.editHistoryButton.selected = NO;

    self.bottomPublishignContainerView.hidden = (self.layout != BJLQuestionResponderWindowLayout_publish);
    self.bottomPublishignContainerView.userInteractionEnabled = (self.layout == BJLQuestionResponderWindowLayout_publish);
    self.publishingContainerView.userInteractionEnabled = (self.layout == BJLQuestionResponderWindowLayout_publish);
    self.publishingHistoryButton.hidden = ![self.questionResponderList count];
    self.publishingHistoryButton.selected = NO;

    self.bottomResultContainerView.hidden = (self.layout != BJLQuestionResponderWindowLayout_end);
    self.bottomResultContainerView.userInteractionEnabled = (self.layout == BJLQuestionResponderWindowLayout_end);
    self.resultContainerView.userInteractionEnabled = (self.layout == BJLQuestionResponderWindowLayout_end);
    self.resultHistoryButton.hidden = ![self.questionResponderList count];
    self.resultHistoryButton.selected = NO;

    if (self.layout == BJLQuestionResponderWindowLayout_normal) {
        if (self.isPortrait) {
            self.bottomBar.hidden = YES;
        }
        self.editContainerView.hidden = NO;
        self.publishingContainerView.hidden = YES;
        self.resultContainerView.hidden = YES;
        [self stopResponderTimer];
    }
    else if (self.layout == BJLQuestionResponderWindowLayout_publish) {
        if (self.isPortrait) {
            self.bottomBar.hidden = YES;
        }
        self.editContainerView.hidden = YES;
        self.publishingContainerView.hidden = NO;
        self.resultContainerView.hidden = YES;
        [self startResponderTimer];
    }
    else if (self.layout == BJLQuestionResponderWindowLayout_end) {
        self.bottomBar.hidden = NO;
        self.editContainerView.hidden = YES;
        self.publishingContainerView.hidden = YES;
        self.resultContainerView.hidden = NO;
        [self stopResponderTimer];
    }
    else {
        //        [self setContentViewController:nil contentView:nil];
    }
}

- (void)makeObserving {
    bjl_weakify(self);

    //    开始
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveQuestionResponderWithTime:) observer:^BOOL(NSInteger time) {
        bjl_strongify(self);
        if (!self.room.loginUser.isTeacherOrAssistant) {
            return YES;
        }

        self.layout = BJLQuestionResponderWindowLayout_publish;
        [self updateConstraints];
        return YES;
    }];

    //    结束
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveEndQuestionResponderWithWinner:) observer:^BOOL(BJLUser *user) {
        bjl_strongify(self);
        if (!self.room.loginUser.isTeacherOrAssistant || (self.layout != BJLQuestionResponderWindowLayout_publish)) {
            return YES;
        }

        self.layout = BJLQuestionResponderWindowLayout_end;
        self.userNameLabel.text = user.displayName ?: @"";
        [self updateResultContainerViewWithShouldHiddenWinnerName:user];
        if (user) {
            self.responderSuccessCallback(user, self.reeditButton);
        }
        [self storeQuestionRecordWithWinner:user];
        [self updateConstraints];
        return YES;
    }];

    //    撤销
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveRevokeQuestionResponder) observer:^BOOL {
        bjl_strongify(self);
        if (!self.room.loginUser.isTeacherOrAssistant || (self.layout != BJLQuestionResponderWindowLayout_publish)) {
            return YES;
        }

        self.layout = BJLQuestionResponderWindowLayout_normal;
        self.userNameLabel.text = nil;
        [self updateConstraints];
        return YES;
    }];
}

- (void)startResponderTimer {
    bjl_weakify(self);

    __block NSInteger countDownTime = 30;
    [self.endButton setTitle:[NSString stringWithFormat:BJLLocalizedString(@"结束(%td)"), countDownTime] forState:UIControlStateNormal];
    self.responderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        countDownTime--;

        if (!self || ![self.responderTimer isValid] || !self.responderTimer) {
            [timer invalidate];
        }
        else if (countDownTime < 1) {
            [self end];
        }
        else {
            [self.endButton setTitle:[NSString stringWithFormat:BJLLocalizedString(@"结束(%td)"), countDownTime] forState:UIControlStateNormal];
        }
    }];

    [[NSRunLoop currentRunLoop] addTimer:self.responderTimer forMode:NSRunLoopCommonModes];
}

// 销毁倒计时
- (void)stopResponderTimer {
    if (self.responderTimer || [self.responderTimer isValid]) {
        [self.responderTimer invalidate];
        self.responderTimer = nil;
    }
}

#pragma mark - overrite
// 点击右上角x时, 如果已发布,则需要调用callback->弹框->发布撤回抢答器的广播, 否则直接关闭即可
- (void)closeUI {
    if (self.layout == BJLQuestionResponderWindowLayout_publish) {
        if (self.closeQuestionResponderCallback) {
            self.closeQuestionResponderCallback();
        }
    }
    else {
        if (self.closeCallback) {
            self.closeCallback();
        }
    }
}

#pragma mark - public
- (BOOL)keyboardDidShow {
    if ([self.timeTextField isFirstResponder]) {
        [self hideKeyboardView];
        return NO;
    }
    return YES;
}

- (void)destroyQuestionResponder {
    // 答题中关闭 revoke + 组件销毁同步广播
    if (self.layout == BJLQuestionResponderWindowLayout_publish) {
        if (self.endQuestionResponderCallback) {
            self.endQuestionResponderCallback(YES);
        }
    }
    else {
        //        非答题中关闭则发送组件销毁同步广播
        if (self.closeCallback) {
            self.closeCallback();
        }
    }
}

- (void)hideKeyboardView {
    [self.timeTextField resignFirstResponder];

    if ([self.overlayView respondsToSelector:@selector(removeFromSuperview)]) {
        [self.overlayView removeFromSuperview];
    }
}

#pragma mark - action

- (void)storeQuestionRecordWithWinner:(BJLUser *)user {
    if (!user) {
        return;
    }

    NSMutableArray<NSDictionary *> *list = [self.questionResponderList mutableCopy];
    if (!list) {
        list = [NSMutableArray new];
    }

    NSUInteger onlineUserCount = 0;
    for (BJLUser *user in self.room.onlineUsersVM.onlineUsers) {
        if (user.role == BJLUserRole_student) {
            onlineUserCount++;
        }
    }

    NSDictionary *dictionary = @{
        kQuestionRecordUserKey: [[user bjlyy_modelToJSONObject] bjl_asDictionary] ?: @{},
        kQuestionRecordCountKey: @(onlineUserCount)
    };
    [list bjl_addObject:dictionary];
    self.questionResponderList = [list copy];
}

- (void)minusTime {
    NSString *time = self.timeTextField.text;
    int timeInsteger = time.intValue;
    timeInsteger = MIN(MAX(timeInsteger - 1, 0), 10);
    self.timeTextField.text = [NSString stringWithFormat:@"%i", timeInsteger];
}

- (void)plusTime {
    NSString *time = self.timeTextField.text;
    int timeInsteger = time.intValue;
    timeInsteger = MIN(MAX(timeInsteger + 1, 0), 10);
    self.timeTextField.text = [NSString stringWithFormat:@"%i", timeInsteger];
}

// 发布
- (void)publish {
    if (self.layout != BJLQuestionResponderWindowLayout_normal) {
        return;
    }

    NSString *timeString = self.timeTextField.text;
    NSInteger time = timeString.integerValue;
    if (time < 0 || time > 10) {
        if (self.errorCallback) {
            self.errorCallback(BJLLocalizedString(@"请输入0~10的抢答时间"));
        }
        return;
    }

    if (self.publishQuestionResponderCallback) {
        if (!self.publishQuestionResponderCallback(time)) {
            return;
        }
    }
}

// 重置
- (void)reset {
    if (self.layout != BJLQuestionResponderWindowLayout_normal) {
        return;
    }

    self.timeTextField.text = @"0";
    self.userNameLabel.text = @"";
}

- (void)showHistoryList {
    BOOL hidden = !self.questionRecordView.hidden;

    if (hidden) {
        [self updateConstraints];
        self.questionRecordView.hidden = YES;
    }
    else {
        [self.view addSubview:self.questionRecordView];
        self.editContainerView.hidden = YES;
        self.publishingContainerView.hidden = YES;
        self.resultContainerView.hidden = YES;
        self.questionRecordView.hidden = NO;
        [self.questionRecordView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.topBar.bjl_bottom);
            make.bottom.equalTo(self.bottomBar.bjl_top);
        }];

        [self.questionRecordView reloadData];
        self.editHistoryButton.selected = (self.layout == BJLQuestionResponderWindowLayout_normal);
        self.publishingHistoryButton.selected = (self.layout == BJLQuestionResponderWindowLayout_publish);
        self.resultHistoryButton.selected = (self.layout == BJLQuestionResponderWindowLayout_end);
    }
}

// 结束
- (void)end {
    if (self.layout != BJLQuestionResponderWindowLayout_publish) {
        return;
    }

    [self stopResponderTimer];

    if (self.endQuestionResponderCallback) {
        if (!self.endQuestionResponderCallback(NO)) {
            return;
        }
    }
}

// 撤销
- (void)revoke {
    if (self.layout != BJLQuestionResponderWindowLayout_publish) {
        return;
    }

    [self stopResponderTimer];

    if (self.revokeQuestionResponderCallback) {
        if (!self.revokeQuestionResponderCallback()) {
            return;
        }
    }
}

// 重新编辑
- (void)reedit {
    if (self.layout != BJLQuestionResponderWindowLayout_end) {
        return;
    }

    self.layout = BJLQuestionResponderWindowLayout_normal;
    self.userNameLabel.text = @"";
    [self updateConstraints];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.timeTextField) {
        [self.view addSubview:self.overlayView];
        [self.overlayView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.timeTextField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *text = textField.text;
    int number = text.intValue;
    if (number >= 0 && number <= 10) {
        textField.text = [NSString stringWithFormat:@"%i", number];
    }
    else {
        textField.text = @"0";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (![self isValidDuration:newString]) {
        return NO;
    }
    int number = newString.intValue;
    if (number >= 0 && number <= 10) {
        return YES;
    }
    return NO;
}

- (BOOL)isValidDuration:(NSString *)durationString {
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:durationString]) {
        return YES;
    }
    return NO;
}

#pragma mark - get

- (UITableView *)questionRecordView {
    if (!_questionRecordView) {
        _questionRecordView = [UITableView new];
        _questionRecordView.delegate = self;
        _questionRecordView.dataSource = self;
        _questionRecordView.backgroundColor = [UIColor clearColor];
        _questionRecordView.hidden = YES;
        _questionRecordView.tableFooterView = [UIView new];
        _questionRecordView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_questionRecordView registerClass:[BJLQuestionRecordCell class] forCellReuseIdentifier:NSStringFromClass([BJLQuestionRecordCell class])];
    }
    return _questionRecordView;
}

@end
