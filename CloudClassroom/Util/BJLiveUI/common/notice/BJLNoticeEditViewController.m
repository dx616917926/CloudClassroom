//
//  BJLNoticeEditViewController.m
//  BJLiveUI
//
//  Created by fanyi on 2019/9/18.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLNoticeEditViewController.h"
#import "BJLScAppearance.h"
#import "UIView+panGesture.h"

@interface BJLNoticeEditViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic) UIView *contentView;
@property (nonatomic) UIView *classNoticeTitleView, *groupNoticeTitleView, *editNoticeTitleView, *editNoticeClassTitleView;
@property (nonatomic) UITextView *classNoticeTextView, *groupNoticeTextView, *editNoticeClassTextView;

@property (nonatomic) UIView *editView;
//@property (nonatomic) UIImageView *editImageView;
@property (nonatomic) UITextView *editNoticeTextView;
@property (nonatomic) UILabel *editTitleLabel, *noticeTextCountLabel, *classTipsLabel, *groupTipsLabel;
@property (nonatomic, nullable) UITextField *linkTextField;

@property (nonatomic) UIButton *doneButton, *giveupEditButton, *editTitleCloseButton;

@end

@implementation BJLNoticeEditViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.accessibilityIdentifier = NSStringFromClass(self.class);
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    self.view.layer.cornerRadius = 3;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = UIColor.blackColor.CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowRadius = 2;
    self.scrollView.alwaysBounceVertical = YES;

    [self makeSubviews];
    [self makeConstraints];
    [self makeObserving];

    // 这里禁用掉，避免拖动窗口时，scroll view的内容在safe area边缘就不能再往外拖动了
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.view.bjl_titleBarHeight = 30.0;
    [self.view bjl_addTitleBarPanGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)makeSubviews {
    self.contentView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, contentView);
        [self.scrollView addSubview:view];
        view;
    });

    self.classNoticeTextView = ({
        UITextView *textView = [UITextView new];
        textView.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.1];
        textView.font = [UIFont systemFontOfSize:12.0];
        textView.textColor = BJLTheme.viewTextColor;
        textView.bjl_placeholder = BJLLocalizedString(@"暂无公告");
        textView.bjl_placeholderColor = BJLTheme.toolButtonTitleColor;
        textView.textContainer.lineFragmentPadding = 0.0;
        textView.textContainerInset = UIEdgeInsetsMake(BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM);
        textView.returnKeyType = UIReturnKeyDefault;
        textView.enablesReturnKeyAutomatically = NO;
        textView.editable = NO;
        textView.bounces = NO;
        // textView.delegate = self;
        textView.layer.cornerRadius = 3;
        textView.layer.masksToBounds = YES;
        textView.accessibilityIdentifier = BJLKeypath(self, classNoticeTextView);
        [self.contentView addSubview:textView];
        textView;
    });
    self.groupNoticeTextView = ({
        UITextView *textView = [UITextView new];
        textView.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.1];
        textView.font = [UIFont systemFontOfSize:12.0];
        textView.textColor = BJLTheme.viewTextColor;
        textView.bjl_placeholder = BJLLocalizedString(@"暂无通知");
        textView.bjl_placeholderColor = BJLTheme.toolButtonTitleColor;
        textView.textContainer.lineFragmentPadding = 0.0;
        textView.textContainerInset = UIEdgeInsetsMake(BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM);
        textView.returnKeyType = UIReturnKeyDefault;
        textView.enablesReturnKeyAutomatically = NO;
        textView.editable = NO;
        textView.bounces = NO;
        // textView.delegate = self;
        textView.layer.cornerRadius = 3;
        textView.layer.masksToBounds = YES;
        textView.accessibilityIdentifier = BJLKeypath(self, groupNoticeTextView);
        [self.contentView addSubview:textView];
        textView;
    });

    self.classTipsLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"点击公告可以跳转");
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.toolButtonTitleColor;
        label.textAlignment = NSTextAlignmentRight;
        label.accessibilityIdentifier = BJLKeypath(self, classTipsLabel);
        [self.contentView addSubview:label];
        label;
    });

    self.groupTipsLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"点击通知可以跳转");
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.toolButtonTitleColor;
        label.textAlignment = NSTextAlignmentRight;
        label.accessibilityIdentifier = BJLKeypath(self, groupTipsLabel);
        [self.contentView addSubview:label];
        label;
    });

    self.classNoticeTitleView = ({
        UIView *view = [UIView new];

        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"公告");
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(view).offset(10);
            make.centerY.equalTo(view);
        }];

        UIButton *closeButton = [UIButton new];
        [closeButton setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:closeButton];
        [closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(view).offset(-5);
            make.centerY.equalTo(view);
        }];

        UIView *line = [UIView new];
        line.backgroundColor = BJLTheme.separateLineColor;
        [view addSubview:line];
        [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.bottom.equalTo(view);
            make.height.equalTo(@(BJLScOnePixel));
        }];

        view.accessibilityIdentifier = BJLKeypath(self, classNoticeTitleView);
        [self.contentView addSubview:view];
        view;
    });

    self.groupNoticeTitleView = ({
        UIView *view = [UIView new];

        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"通知");
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(view).offset(10);
            make.centerY.equalTo(view);
        }];

        UIView *line = [UIView new];
        line.backgroundColor = BJLTheme.separateLineColor;
        [view addSubview:line];
        [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.bottom.equalTo(view);
            make.height.equalTo(@(BJLScOnePixel));
        }];

        view.accessibilityIdentifier = BJLKeypath(self, groupNoticeTitleView);
        [self.contentView addSubview:view];
        view;
    });

    self.doneButton = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = BJLTheme.brandColor;
        button.layer.cornerRadius = 4.0;
        // if self.doneButton.selected then save
        // otherwise show valid error
        [button bjl_setTitle:BJLLocalizedString(@"编辑") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

        // self.doneButton.selected = self.doneButton.enabled && [self isValid];
        [button bjl_setTitle:BJLLocalizedString(@"保存并发布") forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];

        [button setTitleColor:[UIColor bjlsc_lightGrayTextColor] forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });

    self.editView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, editView);
        view.hidden = YES;
        [self.scrollView addSubview:view];
        view;
    });

    self.editNoticeClassTitleView = ({
        UIView *view = [UIView new];

        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"公告");
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(view).offset(10);
            make.centerY.equalTo(view);
            make.right.lessThanOrEqualTo(view);
        }];

        UIButton *closeButton = [UIButton new];
        [closeButton setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:closeButton];
        [closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(view).offset(-5);
            make.centerY.equalTo(view);
        }];

        UIView *line = [UIView new];
        line.backgroundColor = BJLTheme.separateLineColor;
        [view addSubview:line];
        [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.bottom.equalTo(view);
            make.height.equalTo(@(BJLScOnePixel));
        }];

        view;
    });

    self.editNoticeClassTextView = ({
        UITextView *textView = [UITextView new];
        textView.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.1];
        textView.font = [UIFont systemFontOfSize:12.0];
        textView.textColor = BJLTheme.viewTextColor;
        textView.bjl_placeholder = BJLLocalizedString(@"暂无公告");
        textView.bjl_placeholderColor = BJLTheme.toolButtonTitleColor;
        textView.textContainer.lineFragmentPadding = 0.0;
        textView.textContainerInset = UIEdgeInsetsMake(BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM);
        textView.returnKeyType = UIReturnKeyDefault;
        textView.enablesReturnKeyAutomatically = NO;
        textView.editable = NO;
        textView.bounces = NO;
        // textView.delegate = self;
        textView.layer.cornerRadius = 3;
        textView.layer.masksToBounds = YES;
        [self.editView addSubview:textView];
        textView;
    });

    self.editNoticeTitleView = [UIView new];

    self.editTitleLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"通知");
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14];
        [self.editNoticeTitleView addSubview:label];
        [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.editNoticeTitleView.bjl_left).offset(10);
            make.centerY.equalTo(self.editNoticeTitleView);
        }];
        label;
    });

    self.editTitleCloseButton = [UIButton new];
    [self.editTitleCloseButton setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
    [self.editTitleCloseButton addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
    [self.editNoticeTitleView addSubview:self.editTitleCloseButton];
    [self.editTitleCloseButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.editNoticeTitleView).offset(-5);
        make.centerY.equalTo(self.editNoticeTitleView);
    }];

    UIView *line = [UIView new];
    line.backgroundColor = BJLTheme.separateLineColor;
    [self.editNoticeTitleView addSubview:line];
    [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.editNoticeTitleView);
        make.height.equalTo(@(BJLScOnePixel));
    }];

    [self.editView addSubview:self.editNoticeTitleView];
    [self.editNoticeTitleView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.editView);
        make.height.equalTo(@(30));
    }];

    self.editNoticeTextView = ({
        UITextView *textView = [UITextView new];
        textView.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.1];
        textView.font = [UIFont systemFontOfSize:12.0];
        textView.textColor = BJLTheme.viewTextColor;
        textView.bjl_placeholder = BJLLocalizedString(@"输入公告内容");
        textView.bjl_placeholderColor = BJLTheme.toolButtonTitleColor;
        textView.textContainer.lineFragmentPadding = 0.0;
        textView.textContainerInset = UIEdgeInsetsMake(BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM, BJLScViewSpaceM);
        textView.returnKeyType = UIReturnKeyDefault;
        textView.enablesReturnKeyAutomatically = NO;
        textView.bounces = NO;
        textView.delegate = self;
        textView.layer.cornerRadius = 3;
        textView.layer.masksToBounds = YES;
        textView.layer.borderColor = BJLTheme.separateLineColor.CGColor;
        textView.layer.borderWidth = 1;
        textView.accessibilityIdentifier = BJLKeypath(self, groupNoticeTextView);
        [self.editView addSubview:textView];
        textView;
    });

    self.noticeTextCountLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"0/140";
        label.textColor = BJLTheme.toolButtonTitleColor;
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:12];
        label.accessibilityIdentifier = BJLKeypath(self, noticeTextCountLabel);
        [self.editView addSubview:label];
        bjl_return label;
    });

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (MIN(screenSize.width, screenSize.height) > 320.0) {
        self.linkTextField = ({
            BJLTextField *textField = [BJLTextField new];
            textField.font = [UIFont systemFontOfSize:12.0];
            textField.textColor = BJLTheme.viewTextColor;
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"请输入跳转链接") attributes:@{NSForegroundColorAttributeName: BJLTheme.toolButtonTitleColor}];
            textField.textInsets = textField.editingInsets = UIEdgeInsetsMake(0.0, BJLScViewSpaceM, 0.0, 0.0);
            textField.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.1];
            textField.rightView = ({
                UILabel *label = [UILabel new];
                label.text = BJLLocalizedString(@"选填  ");
                label.font = [UIFont systemFontOfSize:12.0];
                label.textColor = BJLTheme.toolButtonTitleColor;
                label.textAlignment = NSTextAlignmentLeft;
                label;
            });
            textField.rightViewMode = UITextFieldViewModeAlways;
            // textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.keyboardType = UIKeyboardTypeURL;
            textField.returnKeyType = UIReturnKeyDefault;
            textField.enablesReturnKeyAutomatically = NO;
            textField.layer.cornerRadius = 3;
            textField.layer.masksToBounds = YES;
            textField.layer.borderColor = BJLTheme.separateLineColor.CGColor;
            textField.layer.borderWidth = 1;
            textField.delegate = self;
            [self.editView addSubview:textField];
            textField;
        });
    }
    self.giveupEditButton = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = BJLTheme.subButtonBackgroundColor;
        button.layer.cornerRadius = 4.0;
        button.layer.borderColor = BJLTheme.separateLineColor.CGColor;
        button.layer.borderWidth = 1;
        [button setTitle:BJLLocalizedString(@"放弃编辑") forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal];
        button.hidden = YES;
        [button addTarget:self action:@selector(returnShowNotice) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
}

- (void)makeConstraints {
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.scrollView);
    }];

    [self.classNoticeTitleView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.contentView).with.inset(0);
        make.height.equalTo(@(30));
        make.left.right.equalTo(self.contentView);
    }];
    [self.classNoticeTextView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.classNoticeTitleView.bjl_bottom).offset(10);
        make.left.right.equalTo(@[self.view, self.scrollView]).with.inset(BJLScViewSpaceL);
    }];

    [self.classTipsLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.classNoticeTitleView);
        make.right.equalTo(self.classNoticeTitleView).offset(-10.0);
        make.top.equalTo(self.classNoticeTextView.bjl_bottom).with.offset(BJLScViewSpaceM);
    }];

    [self.groupNoticeTitleView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.classTipsLabel.bjl_bottom).with.offset(0);
        make.height.equalTo(@(30));
        make.left.right.equalTo(self.contentView);
    }];

    [self.groupNoticeTextView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.groupNoticeTitleView.bjl_bottom).with.offset(BJLScViewSpaceL);
        make.left.right.equalTo(self.classNoticeTextView);
    }];

    [self.groupTipsLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.groupNoticeTitleView);
        make.right.equalTo(self.groupNoticeTitleView).offset(-10.0);
        make.top.equalTo(self.groupNoticeTextView.bjl_bottom).with.offset(BJLScViewSpaceM);
        make.bottom.equalTo(self.contentView).offset(-10.0);
    }];

    [self.scrollView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.bottom.equalTo(self.contentView).with.offset(BJLScViewSpaceL * 2);
    }];
}

- (void)updateEditView {
    BJLNotice *notice = self.room.roomVM.notice;
    if (self.room.loginUser.groupID == 0) {
        [self.editTitleLabel setText:BJLLocalizedString(@"公告")];
        self.editNoticeTextView.text = notice.noticeText.length ? notice.noticeText : nil;
        self.linkTextField.text = [notice.linkURL absoluteString];
        self.editNoticeTextView.bjl_placeholder = BJLLocalizedString(@"输入公告内容");
    }
    else {
        BJLNoticeModel *myGroupNotice = nil;
        for (NSInteger i = 0; i < [notice.groupNoticeList count]; i++) {
            BJLNoticeModel *item = [notice.groupNoticeList objectAtIndex:i];
            if (item.groupID == self.room.loginUser.groupID) {
                myGroupNotice = item;
                break;
            }
        }

        [self.editTitleLabel setText:BJLLocalizedString(@"通知")];
        self.editNoticeTextView.text = myGroupNotice.noticeText.length ? myGroupNotice.noticeText : nil;
        self.linkTextField.text = [myGroupNotice.linkURL absoluteString];
        self.editNoticeTextView.bjl_placeholder = BJLLocalizedString(@"输入通知内容");
    }
    self.giveupEditButton.hidden = NO;
    [self updateEditNoticeTextView];

    [self makeEditViewConstraints];

    [self.editNoticeTextView setNeedsLayout];
    [self.linkTextField setNeedsLayout];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    self.scrollView.contentSize = self.editView.bounds.size;
}

- (void)makeEditViewConstraints {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);

    [self.editView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.scrollView);
    }];

    self.editNoticeClassTitleView.hidden = (self.room.loginUser.groupID == 0);
    self.editNoticeClassTextView.hidden = (self.room.loginUser.groupID == 0);
    self.editTitleCloseButton.hidden = (self.room.loginUser.groupID != 0);

    if (self.room.loginUser.groupID == 0) {
        [self.editNoticeTitleView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.editView).with.inset(0);
            make.height.equalTo(@(30));
            make.left.right.equalTo(self.editView);
        }];
    }
    else {
        if (self.editNoticeClassTitleView.superview == nil) {
            [self.editView addSubview:self.editNoticeClassTitleView];
        }

        [self.editNoticeClassTitleView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.editView).with.inset(0);
            make.height.equalTo(@(30));
            make.left.right.equalTo(self.editView);
        }];

        [self.editNoticeClassTextView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.editNoticeClassTitleView.bjl_bottom).offset(10);
            make.centerX.equalTo(self.editView);
            make.size.equalTo(self.classNoticeTextView);
        }];

        [self.editNoticeTitleView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.editNoticeClassTextView.bjl_bottom).offset(0);
            make.left.right.equalTo(self.editView);
            make.height.equalTo(@(30));
        }];
    }

    [self.editNoticeTextView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.editNoticeTitleView.bjl_bottom).offset(10);
        make.left.equalTo(self.view).offset(BJLScViewSpaceL);
        make.right.equalTo(self.view).offset(-BJLScViewSpaceL);
        make.height.equalTo(@(100));
    }];
    [self.noticeTextCountLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.right.equalTo(self.editNoticeTextView).offset(-2);
    }];

    [self.linkTextField bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.editNoticeTextView.bjl_bottom).with.offset(BJLScViewSpaceL);
        make.left.right.equalTo(self.editNoticeTextView);
        make.height.equalTo(@(35));
        make.bottom.equalTo(self.editView).offset(iPhone ? -20 : -40);
    }];

    [self.giveupEditButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.view).offset(iPhone ? 12.0 : 50.0);
        make.bottom.equalTo(self.doneButton);
        make.width.equalTo(self.doneButton);
        make.height.equalTo(self.doneButton);
    }];

    [self.scrollView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.doneButton.bjl_top).offset(-10);
    }];
}

- (void)makeObserving {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.doneButton.titleLabel, text)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if ([self.doneButton.titleLabel.text isEqualToString:BJLLocalizedString(@"编辑")] || [self.doneButton.titleLabel.text isEqualToString:BJLLocalizedString(@"编辑组内通知")]) {
                 [self.doneButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                     make.centerX.equalTo(self.view);
                     make.width.equalTo(@110);
                     make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(-10);
                     make.height.equalTo(@32);
                 }];
             }
             else {
                 [self.doneButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                     make.right.equalTo(self.view).offset(iPhone ? -12.0 : -50.0);
                     make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(-10);
                     make.width.equalTo(@110);
                     make.height.equalTo(@32);
                 }];
             }
             return YES;
         }];

    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.roomVM, notice)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updateNotice];
                  if (self.editView.isHidden == NO) {
                      [self updateEditView];
                  }
              }];

    UITapGestureRecognizer *tagGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        [self.editNoticeTextView resignFirstResponder];
        [self.linkTextField resignFirstResponder];
    }];
    [self.scrollView addGestureRecognizer:tagGesture];

    UITapGestureRecognizer *classTapGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.room.roomVM.notice.linkURL) {
            [UIApplication.sharedApplication bjl_openURL:self.room.roomVM.notice.linkURL];
        }
    }];
    [self.classNoticeTextView addGestureRecognizer:classTapGesture];
}

- (BOOL)isChanged {
    BJLNotice *notice = self.room.roomVM.notice;
    return (![self.classNoticeTextView.text ?: @"" isEqualToString:notice.noticeText ?: @""]
            || ![self.linkTextField.text ?: @"" isEqualToString:notice.linkURL.absoluteString ?: @""]);
}

- (BOOL)isValid {
    return !self.linkTextField.text.length || [self validURLWithFromString:self.linkTextField.text];
}

- (NSURL *)validURLWithFromString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (urlString.length && !url.scheme.length) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:urlString]];
    }
    return [@[@"http", @"https", @"tel", @"mailto"] containsObject:[url.scheme lowercaseString]] ? url : nil;
}

- (void)returnShowNotice {
    bjl_returnIfRobot(BJLScRobotDelayS);

    self.doneButton.selected = NO;
    self.editView.hidden = YES;
    self.contentView.hidden = NO;
    self.giveupEditButton.hidden = YES;
    [self updateNotice];
}

- (void)done {
    bjl_returnIfRobot(BJLScRobotDelayS);

    if (self.doneButton.selected) {
        NSURL *url = [self validURLWithFromString:self.linkTextField.text];
        if (url) {
            self.linkTextField.text = [url absoluteString];
        }

        BJLError *error = [self.room.roomVM sendNoticeWithText:self.editNoticeTextView.text linkURL:url];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            return;
        }
        else {
            [self returnShowNotice];
        }
    }
    else {
        [self showEditView];
    }
}

- (void)showEditView {
    if (self.room.loginUser.isAssistant && self.room.loginUser.noGroup && ![self.room.roomVM getAssistantaAuthorityWithNotice]) {
        [self showProgressHUDWithText:BJLLocalizedString(@"公告编辑权限已被禁用")];
        return;
    }

    self.doneButton.selected = YES;
    self.editView.hidden = NO;
    self.contentView.hidden = YES;
    [self updateEditView];
}

- (void)closeWindow {
    if (self.closeCallback) {
        self.closeCallback();
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.keyboardShowCallback) {
        self.keyboardShowCallback();
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.keyboardHideCallback) {
        self.keyboardHideCallback();
    }
}

- (BOOL)closeKeyboardIfNeeded {
    if (self.editNoticeTextView.isFirstResponder || self.linkTextField.isFirstResponder) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)updateNotice {
    BJLNotice *notice = self.room.roomVM.notice;

    [self.view setNeedsLayout];
    //    [self.view layoutIfNeeded]; fix iOS 15.0 crash on this line
    //大班公告
    self.classNoticeTextView.text = notice.noticeText.length ? notice.noticeText : nil;
    self.editNoticeClassTextView.text = self.classNoticeTextView.text;
    self.classTipsLabel.hidden = !notice.linkURL;
    [self.classNoticeTextView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        CGFloat height = [self.classNoticeTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.classNoticeTextView.frame), 0.0)].height;
        make.height.equalTo(@(height + BJLScViewSpaceM));
    }];

    [self.classNoticeTextView setNeedsLayout];
    [self.classNoticeTextView layoutIfNeeded];
    CGRect textContainerRect = UIEdgeInsetsInsetRect(self.classNoticeTextView.bounds,
        self.classNoticeTextView.textContainerInset);
    self.classNoticeTextView.textContainer.size = textContainerRect.size;

    BJLNoticeModel *myGroupNotice = nil;
    for (NSInteger i = 0; i < [notice.groupNoticeList count]; i++) {
        BJLNoticeModel *item = [notice.groupNoticeList objectAtIndex:i];
        if (item.groupID == self.room.loginUser.groupID) {
            myGroupNotice = item;
            break;
        }
    }
    // 小组通知
    self.groupNoticeTextView.text = myGroupNotice.noticeText.length ? myGroupNotice.noticeText : nil;
    [self.groupNoticeTextView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        CGFloat height = [self.groupNoticeTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.groupNoticeTextView.frame), 0.0)].height;
        make.height.equalTo(@(height + BJLScViewSpaceS));
    }];

    [self.groupNoticeTextView setNeedsLayout];
    [self.groupNoticeTextView layoutIfNeeded];
    textContainerRect = UIEdgeInsetsInsetRect(self.groupNoticeTextView.bounds,
        self.groupNoticeTextView.textContainerInset);
    self.groupNoticeTextView.textContainer.size = textContainerRect.size;

    if (!self.doneButton.selected) {
        if (self.room.loginUser.groupID == 0) {
            //            大班直播间，只允许编辑公告
            [self.doneButton setTitle:BJLLocalizedString(@"编辑") forState:UIControlStateNormal];
        }
        else {
            //            分组只允许编辑通知
            [self.doneButton setTitle:BJLLocalizedString(@"编辑组内通知") forState:UIControlStateNormal];
        }

        self.groupNoticeTextView.hidden = (self.room.loginUser.groupID == 0);
        self.groupNoticeTitleView.hidden = (self.room.loginUser.groupID == 0);
        self.groupTipsLabel.hidden = !myGroupNotice.linkURL;

        [self.scrollView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.doneButton.bjl_top).offset(-10);
        }];
    }
    else {
        [self.scrollView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.doneButton.bjl_top).offset(-10);
        }];
    }
}

#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    /*
     if (textField == self.linkTextField) {
     [self.view endEditing:YES];
     } */
    return NO;
}

#pragma mark - <UITextViewDelegate>

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (void)textViewDidEndEditing:(UITextView *)textView {
}

- (void)textViewDidChange:(UITextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        // max length
        [self updateEditNoticeTextView];
    });
}

- (void)updateEditNoticeTextView {
    if (self.editNoticeTextView.text.length > BJLTextMaxLength_notice) {
        UITextRange *markedTextRange = self.editNoticeTextView.markedTextRange;
        if (!markedTextRange || markedTextRange.isEmpty) {
            self.editNoticeTextView.text = [self.editNoticeTextView.text substringToIndex:BJLTextMaxLength_notice];
            [self.editNoticeTextView.undoManager removeAllActions];
        }
        self.noticeTextCountLabel.text = [NSString stringWithFormat:@"%td/%td", BJLTextMaxLength_notice, BJLTextMaxLength_notice];
    }
    else {
        self.noticeTextCountLabel.text = [NSString stringWithFormat:@"%td/%td", self.editNoticeTextView.text.length, BJLTextMaxLength_notice];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    /*
     if ([text isEqualToString:@"\n"]) {
     return NO;
     } */
    return YES;
}

@end
