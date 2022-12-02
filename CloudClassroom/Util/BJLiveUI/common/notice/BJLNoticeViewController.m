//
//  BJLNoticeViewController.m
//  BJLiveUI
//
//  Created by fanyi on 2019/9/18.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLNoticeViewController.h"
#import "BJLScAppearance.h"
#import "UIView+panGesture.h"

@interface BJLNoticeViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic) UIView *emptyView, *classNoticeTitleView, *groupNoticeTitleView;
@property (nonatomic) UITextView *classNoticeTextView, *groupNoticeTextView;
@property (nonatomic) UILabel *classTipsLabel, *groupTipLabel;
@property (nonatomic) UIButton *editButton;

@end

@implementation BJLNoticeViewController

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
    [self makeActions];
    [self makeObserving];

    self.view.bjl_titleBarHeight = 30.0;
    [self.view bjl_addTitleBarPanGesture];
}

- (void)makeSubviews {
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
        textView.scrollEnabled = NO;
        textView.layer.cornerRadius = BJLScButtonCornerRadius;
        textView.layer.masksToBounds = YES;
        textView.accessibilityIdentifier = BJLKeypath(self, classNoticeTextView);
        [self.scrollView addSubview:textView];
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
        textView.scrollEnabled = NO;
        textView.bounces = NO;
        textView.layer.cornerRadius = BJLScButtonCornerRadius;
        textView.layer.masksToBounds = YES;
        textView.accessibilityIdentifier = BJLKeypath(self, groupNoticeTextView);
        [self.scrollView addSubview:textView];
        textView;
    });

    self.classTipsLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"点击公告可以跳转");
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.toolButtonTitleColor;
        label.textAlignment = NSTextAlignmentRight;
        label.accessibilityIdentifier = BJLKeypath(self, classTipsLabel);
        [self.scrollView addSubview:label];
        label;
    });
    self.groupTipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"点击通知可以跳转");
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.toolButtonTitleColor;
        label.textAlignment = NSTextAlignmentRight;
        label.accessibilityIdentifier = BJLKeypath(self, groupTipLabel);
        [self.scrollView addSubview:label];
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
            make.right.equalTo(view.bjl_right).offset(-5);
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
        [self.scrollView addSubview:view];
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
        [self.scrollView addSubview:view];
        view;
    });

    self.editButton = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = BJLTheme.brandColor;
        button.layer.cornerRadius = 4.0;
        [button bjl_setTitle:BJLLocalizedString(@"编辑") forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        button.hidden = self.room.loginUser.isStudent;
        bjl_weakify(self);
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.presentingViewController) {
                [self bjl_dismissAnimated:YES completion:nil];
            }
            else {
                [self bjl_removeFromParentViewControllerAndSuperiew];
            }
            if (self.editCallback) {
                self.editCallback();
            }
        }];
        [self.view addSubview:button];
        button;
    });
}

- (void)makeConstraints {
    [self.classNoticeTitleView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.scrollView).with.inset(0);
        make.height.equalTo(@(30));
        make.left.right.equalTo(self.view);
    }];
    [self.classNoticeTextView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.classNoticeTitleView.bjl_bottom).with.offset(BJLScViewSpaceL);
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
        make.left.right.equalTo(self.view);
    }];

    [self.groupNoticeTextView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.groupNoticeTitleView.bjl_bottom).with.offset(BJLScViewSpaceL);
        make.left.right.equalTo(@[self.view, self.scrollView]).with.inset(BJLScViewSpaceL);
    }];

    [self.groupTipLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.groupNoticeTitleView);
        make.right.equalTo(self.groupNoticeTitleView).offset(-10.0);
        make.top.equalTo(self.groupNoticeTextView.bjl_bottom).with.offset(BJLScViewSpaceM);
    }];

    [self.scrollView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.bottom.equalTo(self.groupTipLabel.bjl_bottom).with.offset(BJLScViewSpaceL * 2);
    }];

    [self.editButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@120.0);
        make.height.equalTo(@32.0);
        make.bottom.equalTo(self.view).offset(-20.0);
    }];
}

- (void)makeActions {
    bjl_weakify(self);
    UITapGestureRecognizer *classTapGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.room.roomVM.notice.linkURL) {
            [UIApplication.sharedApplication bjl_openURL:self.room.roomVM.notice.linkURL];
        }
    }];
    [self.classNoticeTextView addGestureRecognizer:classTapGesture];

    UITapGestureRecognizer *groupTapGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        BJLNoticeModel *myGroupNotice = nil;
        for (NSInteger i = 0; i < [self.room.roomVM.notice.groupNoticeList count]; i++) {
            BJLNoticeModel *item = [self.room.roomVM.notice.groupNoticeList objectAtIndex:i];
            if (item.groupID == self.room.loginUser.groupID) {
                myGroupNotice = item;
                break;
            }
        }

        if (myGroupNotice.linkURL) {
            [UIApplication.sharedApplication bjl_openURL:myGroupNotice.linkURL];
        }
    }];
    [self.groupNoticeTextView addGestureRecognizer:groupTapGesture];
}

- (void)makeObserving {
    bjl_weakify(self);
    [self bjl_kvoMerge:@[BJLMakeProperty(self.view, bounds),
        BJLMakeProperty(self.room.roomVM, notice)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updateNotice];
              }];
}

- (void)updateNotice {
    BJLNotice *notice = self.room.roomVM.notice;

    self.classNoticeTextView.text = notice.noticeText.length ? notice.noticeText : nil;
    self.classTipsLabel.hidden = !notice.linkURL;

    BJLNoticeModel *myGroupNotice = nil;
    for (NSInteger i = 0; i < [notice.groupNoticeList count]; i++) {
        BJLNoticeModel *item = [notice.groupNoticeList bjl_objectAtIndex:i];
        if (item.groupID == self.room.loginUser.groupID) {
            myGroupNotice = item;
            break;
        }
    }
    // 小组通知
    self.groupNoticeTextView.text = myGroupNotice.noticeText.length ? myGroupNotice.noticeText : nil;

    self.groupNoticeTextView.hidden = (self.room.loginUser.groupID == 0);
    self.groupNoticeTitleView.hidden = (self.room.loginUser.groupID == 0);
    self.groupTipLabel.hidden = !myGroupNotice.linkURL;
}

- (void)closeWindow {
    if (self.closeCallback) {
        self.closeCallback();
    }
}

@end
