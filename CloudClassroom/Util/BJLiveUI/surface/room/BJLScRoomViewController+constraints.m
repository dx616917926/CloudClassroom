//
//  BJLScRoomViewController+constraints.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScRoomViewController+constraints.h"
#import "BJLScRoomViewController+private.h"

@implementation BJLScRoomViewController (constraints)

#pragma mark - layout

- (void)makeConstraints {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);

    self.containerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view.accessibilityIdentifier = BJLKeypath(self, containerView);
        bjl_return view;
    });
    self.topBarView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, topBarView);
        bjl_return view;
    });
    self.seperatorView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, seperatorView);
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        view.layer.masksToBounds = NO;
        view.layer.shadowOpacity = 0.1;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(-2.0, 0.0);
        view.layer.shadowRadius = 2.0;
        bjl_return view;
    });
    self.minorContentView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, minorContentView);
        view.backgroundColor = [UIColor blackColor];
        if (!self.is1V1Class || !iPhone) {
            view.layer.masksToBounds = NO;
            view.layer.shadowOpacity = 0.1;
            view.layer.shadowColor = [UIColor blackColor].CGColor;
            view.layer.shadowOffset = CGSizeMake(-2.0, 0.0);
            view.layer.shadowRadius = 2.0;
        }
        bjl_return view;
    });
    self.secondMinorContentView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, secondMinorContentView);
        view.backgroundColor = [UIColor blackColor];
        if (!self.is1V1Class || !iPhone) {
            view.layer.masksToBounds = NO;
            view.layer.shadowOpacity = 0.1;
            view.layer.shadowColor = [UIColor blackColor].CGColor;
            view.layer.shadowOffset = CGSizeMake(-2.0, 0.0);
            view.layer.shadowRadius = 2.0;
        }
        bjl_return view;
    });

    self.teacherVideoPlaceholderView = ({
        BJLScVideoPlaceholderView *view = [[BJLScVideoPlaceholderView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_sc_noteacher"] tip:BJLLocalizedString(@"暂无直播")];
        view.accessibilityIdentifier = BJLKeypath(self, teacherVideoPlaceholderView);
        view.hidden = YES;
        bjl_return view;
    });
    self.secondMinorVideoPlaceholderView = ({
        BJLScVideoPlaceholderView *view = [[BJLScVideoPlaceholderView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_sc_noteacher"] tip:BJLLocalizedString(@"当前没有学生发言")];
        view.accessibilityIdentifier = BJLKeypath(self, secondMinorVideoPlaceholderView);
        view.hidden = YES;
        bjl_return view;
    });

    self.segmentView = ({
        UIView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, segmentView);
        bjl_return view;
    });
    self.videosView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, videosView);
        bjl_return view;
    });
    self.majorContentView = ({
        UIView *view = [UIView new];
        view.clipsToBounds = YES;
        view.accessibilityIdentifier = BJLKeypath(self, majorContentView);
        bjl_return view;
    });
    self.toolView = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, toolView);
        bjl_return view;
    });
    self.lampView = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, lampView);
        view.clipsToBounds = YES;
        bjl_return view;
    });
    self.majorNoticeView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, majorNoticeView);
        view.clipsToBounds = YES;
        bjl_return view;
    });
    self.imageViewLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, imageViewLayer);
        bjl_return view;
    });
    self.fullscreenLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, fullscreenLayer);
        bjl_return view;
    });
    self.timerLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, timerLayer);
        bjl_return view;
    });
    self.teachAidLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, teachAidLayer);
        bjl_return view;
    });
    self.overlayView = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, overlayView);
        bjl_return view;
    });
    self.lotteryLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, lotteryLayer);
        bjl_return view;
    });
    self.popoversLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, popoversLayer);
        bjl_return view;
    });
    [self.view insertSubview:self.containerView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.majorContentView belowSubview:self.loadingLayer];
    if (self.is1V1Class) {
        [self.view insertSubview:self.seperatorView belowSubview:self.loadingLayer];
    }
    [self.view insertSubview:self.minorContentView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.secondMinorContentView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.teacherVideoPlaceholderView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.secondMinorVideoPlaceholderView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.videosView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.segmentView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.majorContentOperationView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.toolView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.topBarView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.imageViewLayer belowSubview:self.loadingLayer];
    [self.view insertSubview:self.fullscreenLayer belowSubview:self.loadingLayer];
    [self.view insertSubview:self.lampView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.majorNoticeView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.timerLayer belowSubview:self.loadingLayer];
    [self.view insertSubview:self.teachAidLayer belowSubview:self.loadingLayer];
    [self.view insertSubview:self.overlayView belowSubview:self.loadingLayer];
    [self.view insertSubview:self.lotteryLayer belowSubview:self.loadingLayer];
    [self.view insertSubview:self.popoversLayer belowSubview:self.loadingLayer];

    if (iPhone) {
        [self makePhoneConstraints];
    }
    else {
        [self makePadConstraints];
    }

    [self makeCommonConstraints];
}

/**   pad 结构 基于 4:3 布局，视频基于 16:9 布局，1V1 使用 4:3，课件基于 4:3 显示最优
                     状态栏
            包含标题等自定义的topbar，固定高度
            视频列表，固定高度       老师主摄像头，固定宽度
            课件                  聊天等内容，固定宽度
                常显示操作按钮，可点击隐藏
 */
- (void)makePadConstraints {
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.center.bottom.equalTo(self.view);
        make.width.equalTo(self.view.bjl_height).multipliedBy(4.0 / 3.0);
    }];

    [self.topBarView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        // 仅处理状态栏，此处也可以都直接替换成状态栏高度
        make.top.equalTo(self.containerView.bjl_safeAreaLayoutGuide ?: self.bjl_topLayoutGuide);
        make.left.right.equalTo(self.containerView);
        make.height.equalTo(@(BJLScTopBarHeight));
    }];

    [self.majorNoticeView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.equalTo(self.majorContentView);
        make.right.equalTo(self.majorContentView);
        make.height.equalTo(@(30));
    }];

    if (self.is1V1Class) {
        [self.seperatorView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.bottom.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.width.equalTo(@(BJLScSegmentWidth));
        }];

        [self.minorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom).offset(0.0);
            make.width.equalTo(@(BJLScSegmentWidth));
            make.height.equalTo(self.minorContentView.bjl_width).multipliedBy(9.0 / 16.0);
        }];

        [self.secondMinorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.containerView);
            make.top.equalTo(self.minorContentView.bjl_bottom).offset(1.0);
            make.width.equalTo(@(BJLScSegmentWidth));
            make.height.equalTo(self.secondMinorContentView.bjl_width).multipliedBy(9.0 / 16.0);
        }];

        [self.segmentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.bottom.equalTo(self.containerView);
            make.top.equalTo(self.secondMinorContentView.bjl_bottom).offset(1.0);
            make.width.equalTo(@(BJLScSegmentWidth));
        }];

        [self.majorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.bottom.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.right.equalTo(self.segmentView.bjl_left);
        }];
    }
    else {
        [self.minorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.width.equalTo(@(BJLScSegmentWidth));
            if (!self.room.roomInfo.isPureVideo) {
                make.height.equalTo(self.minorContentView.bjl_width).multipliedBy(9.0 / 16.0);
            }
            else {
                make.height.equalTo(@0.0);
            }
        }];

        [self.segmentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.bottom.equalTo(self.containerView);
            make.top.equalTo(self.minorContentView.bjl_bottom);
            make.width.equalTo(@(BJLScSegmentWidth));
        }];

        [self.videosView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.left.equalTo(self.containerView);
            make.right.equalTo(self.segmentView.bjl_left);
            make.height.equalTo(@0.0);
        }];

        [self.majorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.bottom.equalTo(self.containerView);
            make.top.equalTo(self.videosView.bjl_bottom);
            make.right.equalTo(self.segmentView.bjl_left);
        }];
    }
}

/**   phone 结构 基于 16:9 布局，视频基于 16:9 布局，1V1 使用 4:3，课件基于 4:3 显示最优
                    状态栏隐藏
           包含标题等自定义的topbar，固定高度，但不占据布局高度，可点击隐藏
           视频列表，固定高度                 老师主摄像头，宽度为设备宽度的 4/16
           课件，宽度为设备宽度的 12/16        聊天等内容，宽度为设备宽度的 4/16
               常显示操作按钮，可点击隐藏
*/
- (void)makePhoneConstraints {
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.center.bottom.equalTo(self.view);
        make.width.equalTo(self.view.bjl_height).multipliedBy(16.0 / 9.0);
    }];

    [self.topBarView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        // 仅处理状态栏，此处也可以都直接替换成状态栏高度
        make.top.equalTo(self.containerView.bjl_safeAreaLayoutGuide ?: self.bjl_topLayoutGuide);
        make.left.right.equalTo(self.containerView);
        make.height.equalTo(@(BJLScTopBarHeight));
    }];

    [self.majorNoticeView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.majorContentView);
        make.right.equalTo(self.majorContentView);
        make.top.equalTo(self.topBarView.bjl_bottom);
        make.height.equalTo(@(30));
    }];

    if (self.is1V1Class) {
        [self.majorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.bottom.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.width.equalTo(self.majorContentView.bjl_height).multipliedBy(4.0 / 3.0);
        }];

        [self.seperatorView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.bottom.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.left.equalTo(self.majorContentView.bjl_right);
        }];

        [self.minorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.right.left.equalTo(self.seperatorView);
            make.height.equalTo(self.minorContentView.bjl_width).multipliedBy(9.0 / 16.0);
        }];

        [self.secondMinorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.minorContentView.bjl_bottom).offset(1.0);
            make.left.right.equalTo(self.seperatorView);
            make.height.equalTo(self.secondMinorContentView.bjl_width).multipliedBy(9.0 / 16.0);
        }];

        [self.segmentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.seperatorView);
        }];
    }
    else {
        [self.minorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.width.equalTo(self.containerView).multipliedBy(4.0 / 16.0);
            if (!self.room.roomInfo.isPureVideo) {
                make.height.equalTo(self.minorContentView.bjl_width).multipliedBy(9.0 / 16.0);
            }
            else {
                make.height.equalTo(@0.0);
            }
        }];

        [self.segmentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.bottom.equalTo(self.containerView);
            make.top.equalTo(self.minorContentView.bjl_bottom);
            make.width.equalTo(self.containerView).multipliedBy(4.0 / 16.0);
        }];

        [self.videosView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.containerView);
            make.top.equalTo(self.topBarView.bjl_bottom);
            make.right.equalTo(self.segmentView.bjl_left);
            make.height.equalTo(@0.0);
        }];

        [self.majorContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.bottom.equalTo(self.containerView);
            make.top.equalTo(self.videosView.bjl_bottom);
            make.right.equalTo(self.segmentView.bjl_left);
        }];
    }
}

/** 不是一直显示的视图 一般铺满整个设备，不局限于布局的比例 */
- (void)makeCommonConstraints {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    [self.teacherVideoPlaceholderView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.minorContentView);
    }];

    [self.secondMinorVideoPlaceholderView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.secondMinorVideoPlaceholderView);
    }];

    [self.toolView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.majorContentView);
        make.top.equalTo(iPhone ? self.view : self.topBarView.bjl_bottom);
    }];

    [self.lampView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.majorContentView);
    }];

    [self.imageViewLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self.fullscreenLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self.timerLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.containerView);
    }];

    [self.teachAidLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self.overlayView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self.lotteryLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self.popoversLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self.majorContentOperationView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.majorContentView);
    }];
}

#pragma mark - controllers

- (void)makeViewControllers {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    bjl_weakify(self);
    // top bar
    self.topBarViewController = [[BJLScTopBarViewController alloc] initWithRoom:self.room];
    // 需要在布局前设置block，否则无法判断是否显示分享
    if (self.delegate && [self.delegate respondsToSelector:@selector(roomViewControllerToShare:)]) {
        [self.topBarViewController setShareCallback:^{
            bjl_strongify(self);
            if (!self.enableShare) {
                return;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(roomViewControllerToShare:)]) {
                UIViewController *content = [self.delegate roomViewControllerToShare:self];
                if (content) {
                    [self.overlayViewController showWithContentViewController:content contentView:nil];
                    [content.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                        make.top.equalTo(self.topBarView.bjl_bottom);
                        make.right.equalTo(self.overlayViewController.view).offset(-64);
                        make.height.equalTo(iPhone ? @160 : @270);
                        make.width.equalTo(iPhone ? @240 : @310);
                    }];
                }
            }
        }];
    }
    [self bjl_addChildViewController:self.topBarViewController superview:self.topBarView];
    [self.topBarViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.topBarView);
    }];

    if (!self.is1V1Class) {
        // videos
        self.videosViewController = [[BJLScVideosViewController alloc] initWithRoom:self.room];
    }

    // sildeshow
    UIView *targetView = (self.majorWindowType == BJLScWindowType_ppt) ? self.majorContentView : self.minorContentView;
    [self bjl_addChildViewController:self.room.slideshowViewController superview:targetView];
    self.room.slideshowViewController.shouldSwitchNativePPTBlock = ^(NSString *_Nullable documentID, void (^_Nonnull callback)(BOOL)) {
        bjl_strongify(self);
        UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:@"PPT动画加载失败！\n网络较差建议跳过动画"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertViewController bjl_addActionWithTitle:BJLLocalizedString(@"重新加载")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *_Nonnull action) {
                                                callback(NO);
                                            }];
        [alertViewController bjl_addActionWithTitle:BJLLocalizedString(@"跳过动画")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *_Nonnull action) {
                                                callback(YES);
                                            }];
        bjl_weakify(alertViewController);
        [alertViewController bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, webPPTLoadSuccess)
                            observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                                bjl_strongify(alertViewController);
                                if (self.room.slideshowViewController.webPPTLoadSuccess) {
                                    [alertViewController bjl_dismissAnimated:YES completion:nil];
                                    return NO;
                                }
                                return YES;
                            }];
        if (self.presentedViewController) {
            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self presentViewController:alertViewController animated:YES completion:nil];
    };
    self.room.slideshowViewController.imageSize = 1080;
    self.room.slideshowViewController.view.backgroundColor = BJLTheme.roomBackgroundColor; // 课件背景色和直播间整个底色一致
    self.room.slideshowViewController.placeholderImage = [UIImage bjl_imageWithColor:BJLTheme.blackboardColor ?: [UIColor bjlsc_grayImagePlaceholderColor]];
    self.room.slideshowViewController.whiteboardBackgroundImage = [UIImage bjl_imageWithColor:BJLTheme.blackboardColor];
    self.room.slideshowViewController.prevPageIndicatorImage = [UIImage bjl_imageNamed:@"bjl_sc_ppt_prev"];
    self.room.slideshowViewController.nextPageIndicatorImage = [UIImage bjl_imageNamed:@"bjl_sc_ppt_next"];
    self.room.slideshowViewController.pageControlButton = ({
        const CGFloat buttonWidth = 72.0, buttonHeight = 32.0;
        UIButton *button = [UIButton new];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        // !!!: should be same to `BJLContentView.clearDrawingButton.backgroundColor`
        [button setBackgroundImage:[UIImage bjl_imageWithColor:[UIColor bjlsc_dimColor]]
                          forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage bjl_imageWithColor:[UIColor bjl_colorWithHexString:@"#89899C" alpha:0.5]]
                          forState:UIControlStateDisabled];
        button.layer.cornerRadius = buttonHeight / 2;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(showQuickSlideViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.room.slideshowViewController.view addSubview:button];
        [button bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equalTo(self.room.slideshowViewController.view);
            make.bottom.equalTo(self.room.slideshowViewController.view).offset(-8.0);
            make.size.equal.sizeOffset(CGSizeMake(buttonWidth, buttonHeight));
        }];
        button;
    });
    [self.room.slideshowViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(targetView);
    }];
    [self bjl_kvo:BJLMakeProperty(self.room.documentVM, forbidStudentChangePPT)
         observer:^BJLControlObserving(NSNumber *_Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (!self.room.loginUser.isTeacherOrAssistant) {
                 self.room.slideshowViewController.pageControlButton.hidden = value.bjl_boolValue;
                 if (value.bjl_boolValue && self.overlayViewController.viewController == self.pptQuickSlideViewController) {
                     [self.overlayViewController hide];
                 }
             }
             return YES;
         }];

    if (self.is1V1Class) {
        self.chatViewController = [[BJLScChatViewController alloc] initWithRoom:self.room];
        // only chat
        BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        if (iPad) {
            [self bjl_addChildViewController:self.chatViewController superview:self.segmentView];
            [self.chatViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.segmentView);
            }];
        }
        else {
            self.chatButton = ({
                UIButton *button = [UIButton new];
                button.backgroundColor = BJLTheme.windowBackgroundColor;
                button.layer.masksToBounds = YES;
                button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                button.layer.cornerRadius = 2.0;
                button.layer.borderColor = [UIColor bjl_colorWithHexString:@"#9FA8B5"].CGColor;
                button.layer.borderWidth = 1.0;
                button.titleLabel.font = [UIFont systemFontOfSize:12.0];
                [button setTitle:BJLLocalizedString(@"聊天") forState:UIControlStateNormal];
                [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
                [button setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_chat"] forState:UIControlStateNormal];
                button;
            });
            [self.segmentView addSubview:self.chatButton];
            [self.chatButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.top.equalTo(self.secondMinorContentView.bjl_bottom).offset(10.0);
                make.left.equalTo(self.segmentView).offset(6.0).priorityHigh();
                make.right.equalTo(self.segmentView).offset(-6.0).priorityHigh();
                make.height.equalTo(@28.0).priority(UILayoutPriorityDefaultHigh - 1);
                make.bottom.lessThanOrEqualTo(self.segmentView).priorityHigh();
            }];
        }
    }
    else {
        // segment
        self.segmentViewController = [[BJLScSegmentViewController alloc] initWithRoom:self.room];
        [self bjl_addChildViewController:self.segmentViewController superview:self.segmentView];
        [self.segmentViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.segmentView);
        }];
    }

    // tool
    [self makeToolView];

    // overlay
    self.overlayViewController = [[BJLScOverlayViewController alloc] initWithRoom:self.room];
    self.fullscreenOverlayViewController = [[BJLScOverlayViewController alloc] initWithRoom:self.room];

    // placeholder
    [self updateTeacherVideoPlaceholderView];
    if (self.is1V1Class) {
        [self updateSecondMinorVideoPlaceholderView];
    }

    [self makeQuestionNaire];
}

- (void)makeToolView {
    bjl_weakify(self);

    self.liveStartButton = ({
        UIButton *button = [UIButton new];
        button.hidden = YES;
        button.layer.cornerRadius = 8.0;
        button.layer.masksToBounds = YES;
        button.accessibilityIdentifier = BJLKeypath(self, liveStartButton);
        button.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0.0, 0.0, 220.0, 56.0);
        gradientLayer.colors = @[(__bridge id)BJLTheme.brandColor.CGColor, (__bridge id)[UIColor bjl_colorWithHexString:@"#33C7FF" alpha:1.0].CGColor];
        gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        gradientLayer.endPoint = CGPointMake(0.0, 1.0);
        gradientLayer.locations = @[@(0), @(1)];
        [button.layer insertSublayer:gradientLayer atIndex:0];
        button.titleLabel.font = [UIFont systemFontOfSize:24.0];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:BJLLocalizedString(@"开始上课") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            BJLError *error = [self.room.roomVM sendLiveStarted:YES];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        }];
        button;
    });

    // 因为会出现老师进入直播间视频自动全屏的情况，所以上课按钮需要移到更上层
    [self.popoversLayer addSubview:self.liveStartButton];
    [self.liveStartButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.popoversLayer);
        make.width.equalTo(@220.0);
        make.height.equalTo(@56.0);
    }];

    // controlsViewController
    self.controlsViewController = [[BJLScControlsViewController alloc] initWithRoom:self.room windowType:self.majorWindowType fullScreen:self.fullscreenWindowType != BJLScWindowType_none];
    [self.controlsViewController setupToolView:self.majorContentOperationView fullScreenView:self.fullscreenLayer];
    [self bjl_addChildViewController:self.controlsViewController superview:self.majorContentOperationView];
    [self.controlsViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.majorContentOperationView);
    }];

    // toolViewController
    self.toolViewController = ({
        BJLScToolViewController *toolViewController = [[BJLScToolViewController alloc] initWithRoom:self.room];
        toolViewController.view.accessibilityIdentifier = BJLKeypath(self, toolViewController);
        toolViewController;
    });

    [self bjl_addChildViewController:self.toolViewController superview:self.toolView];
    [self.toolViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.toolView);
    }];

    [self.toolView bringSubviewToFront:self.liveStartButton];

    // handWritingBoard
    self.handWritingBoardViewController = [[BJLHandWritingBoardDeviceViewController alloc] initWithRoom:self.room];
}

#pragma mark - update

- (void)showQuickSlideViewController {
    self.pptQuickSlideViewController = [[BJLScPPTQuickSlideViewController alloc] initWithRoom:self.room];
    [self.overlayViewController showWithContentViewController:self.pptQuickSlideViewController contentView:nil];
    [self.pptQuickSlideViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.overlayViewController.view);
        make.height.equalTo(@110.0);
    }];
}

- (void)showQuestionInputView {
    // 输入控制器约束了高度，不需要在外部控制
    [self.questionInputViewController updateWithQuestion:nil];
    [self.overlayViewController showWithContentViewController:self.questionInputViewController contentView:nil];
    [self.questionInputViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.overlayViewController.view);
    }];
}

- (void)updateVideosViewHidden:(BOOL)hidden {
    if (hidden == self.videosView.hidden) {
        return;
    }
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    CGFloat videoHeight = iPhone ? 72.0 : 135.0; // 240 * 9.0 / 16.0 = 135.0
    [self.toolViewController updateToolViewOffset:hidden ? 0.0 : videoHeight];
    if (hidden) {
        [self.videosViewController bjl_removeFromParentViewControllerAndSuperiew];
        [self.videosView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.height.equalTo(@0.0);
        }];
        self.videosView.hidden = YES;
        // 视频列表隐藏时，复原视频位置
        [self.videosViewController resetVideo];

        if (self.majorWindowType != BJLScWindowType_ppt
            && self.minorWindowType != BJLScWindowType_ppt) {
            [self replaceMajorContentViewWithPPTView];
        }
    }
    else {
        [self.videosView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.height.equalTo(@(videoHeight));
        }];
        [self bjl_addChildViewController:self.videosViewController superview:self.videosView];
        [self.videosViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.videosView);
        }];
        self.videosView.hidden = NO;
    }

    // 视频窗口显示或者隐藏时, 同时更新一下主屏公告的布局
    [self resetMajorNoticeWhenFullScreenStateChanged];
}

- (void)updateMinorViewRatio:(CGFloat)ratio {
    if (ratio <= 0 || !self.room.onlineUsersVM.onlineTeacher || self.minorWindowType != BJLScWindowType_teacherVideo) {
        return;
    }

    [self.minorContentView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.view);
        make.top.equalTo(self.topBarView.bjl_bottom);
        make.width.equalTo(@(BJLScSegmentWidth));
        make.height.equalTo(self.minorContentView.bjl_width).multipliedBy(1.0 / ratio);
    }];
}

#pragma mark - mediaInfoView

// teacher
- (void)updateTeacherVideoView {
    // 老师窗口保证主摄像头的user数据来初始化即可，除此之外只有在老师ID变更时才需要更新
    if (!self.teacherMediaInfoView
        || ![self.teacherMediaInfoView.user.ID isEqualToString:self.room.onlineUsersVM.currentPresenter.ID]) {
        // 切换老师用户时需要移除
        if (self.teacherMediaInfoView) {
            [self.teacherMediaInfoView removeFromSuperview];
            [self.teacherMediaInfoView destroyView];
            self.teacherMediaInfoView = nil;
        }

        if (self.room.loginUserIsPresenter) {
            self.teacherMediaInfoView = [[BJLScMediaInfoView alloc] initWithRoom:self.room user:self.room.loginUser];
        }
        // 当没有上课 且 没有主讲人的时候 且 有暖场视频, 需要实例化 teacherMediaInfoView
        else if (!self.room.roomVM.liveStarted && !self.room.onlineUsersVM.currentPresenter && self.warmingUpView) {
            self.teacherMediaInfoView = [[BJLScMediaInfoView alloc] initWithRoom:self.room user:[BJLUser new]];
        }
        else if (self.room.onlineUsersVM.currentPresenter) {
            self.teacherMediaInfoView = [[BJLScMediaInfoView alloc] initWithRoom:self.room user:self.room.onlineUsersVM.currentPresenter];
        }
    }

    if (self.fullscreenWindowType == BJLScWindowType_teacherVideo && !self.teacherMediaInfoView.isFullScreen) {
        [self replaceFullscreenWithWindowType:BJLScWindowType_teacherVideo mediaInfoView:self.teacherMediaInfoView];
    }
    else if (self.minorWindowType == BJLScWindowType_teacherVideo
             && self.teacherMediaInfoView.positionType != BJLScPositionType_minor) {
        [self replaceMinorContentViewWithTeacherMediaInfoView];
    }
    else if (self.majorWindowType == BJLScWindowType_teacherVideo
             && self.teacherMediaInfoView.positionType != BJLScPositionType_major) {
        [self replaceMajorContentViewWithTeacherMediaInfoView];
    }
}

// extra teacher
- (void)updateTeacherExtraVideoViewWithMediaUser:(nullable BJLMediaUser *)user {
    // 没有改变用户ID的情况不需要处理，其他的变化在 mediaInfoView 内部处理
    if ((!self.teacherExtraMediaInfoView && !user)
        || (self.teacherExtraMediaInfoView && [self.teacherExtraMediaInfoView.user.ID isEqualToString:user.ID])) {
        return;
    }

    BOOL isTeacherExtraMediaInfoViewFullScreen = self.teacherExtraMediaInfoView.isFullScreen;
    if (self.teacherExtraMediaInfoView) {
        [self.teacherExtraMediaInfoView removeFromSuperview];
        [self.teacherExtraMediaInfoView destroyView];
        self.teacherExtraMediaInfoView = nil;
    }
    if (!user) {
        // 辅助摄像头在全屏区域时消失了，重置全屏区域
        if (isTeacherExtraMediaInfoViewFullScreen) {
            [self restoreCurrentFullscreenWindow];
        }
        // 如果当前设置了课件和辅助摄像头同时显示时，刷新视频列表区域
        if (!self.showTeacherExtraMediaInfoViewCoverPPT) {
            [self.videosViewController reloadVideoWithTeacherExtraMediaInfoView:nil];
        }
        return;
    }
    self.teacherExtraMediaInfoView = [[BJLScMediaInfoView alloc] initWithRoom:self.room user:user];
    self.teacherExtraMediaInfoView.accessibilityIdentifier = BJLKeypath(self, teacherExtraMediaInfoView);

    if (self.room.featureConfig.enablePPTShowWithAssistCamera || !self.room.roomInfo.isDoubleCamera) {
        self.teacherExtraMediaInfoView.positionType = BJLScPositionType_videoList;
        [self.videosViewController reloadVideoWithTeacherExtraMediaInfoView:self.teacherExtraMediaInfoView];
    }
    else {
        // 触发覆盖白板逻辑
        if (self.majorWindowType == BJLScWindowType_ppt
            && self.teacherExtraMediaInfoView.positionType != BJLScPositionType_major) {
            self.teacherExtraMediaInfoView.positionType = BJLScPositionType_major;
            if (self.fullscreenWindowType == BJLScWindowType_ppt) {
                [self replaceFullscreenWithWindowType:BJLScWindowType_ppt mediaInfoView:self.teacherExtraMediaInfoView];
            }
            else {
                [self replaceMajorContentViewWithPPTView];
            }
        }
        else if (self.minorWindowType == BJLScWindowType_ppt
                 && self.teacherExtraMediaInfoView.positionType != BJLScPositionType_minor) {
            self.teacherExtraMediaInfoView.positionType = BJLScPositionType_minor;
            if (self.fullscreenWindowType == BJLScWindowType_ppt) {
                [self replaceFullscreenWithWindowType:BJLScWindowType_ppt mediaInfoView:self.teacherExtraMediaInfoView];
            }
            else {
                [self replaceMinorContentViewWithPPTView];
            }
        }
        else if (self.secondMinorWindowType == BJLScWindowType_ppt
                 && self.teacherExtraMediaInfoView.positionType != BJLScPositionType_secondMinor) {
            self.teacherExtraMediaInfoView.positionType = BJLScPositionType_secondMinor;
            if (self.fullscreenWindowType == BJLScWindowType_ppt) {
                [self replaceFullscreenWithWindowType:BJLScWindowType_ppt mediaInfoView:self.teacherExtraMediaInfoView];
            }
            else {
                [self replaceSecondMinorContentViewWithPPTView];
            }
        }
        else {
            if (self.videosViewController.majorMediaInfoView) {
                self.teacherExtraMediaInfoView.positionType = BJLScPositionType_videoList;
                [self.videosViewController reloadVideoWithTeacherExtraMediaInfoView:self.teacherExtraMediaInfoView];
            }
        }
    }
}

// 1v1
- (void)updateSecondMinorContentViewWithUser:(nullable BJLMediaUser *)user recording:(BOOL)recording {
    self.secondMinorVideoPlaceholderView.hidden = user || recording;
    if (self.secondMinorMediaInfoView) {
        // 用户摄像头在大屏区域
        if (self.secondMinorMediaInfoView.positionType == BJLScPositionType_major) {
            // 并且是全屏状态，先复原全屏位置，然后替换新的用户视频到用户默认位置
            if (self.secondMinorMediaInfoView.isFullScreen) {
                [self restoreCurrentFullscreenWindow];
            }
            [self replaceMajorContentViewWithPPTView];
            [self replaceSecondMinorContentViewWithSecondMinorMediaInfoView];
        }
        // 如果视频在非大屏区域进入全屏状态，只要复原即可
        else if (self.secondMinorMediaInfoView.isFullScreen) {
            [self restoreCurrentFullscreenWindow];
        }

        [self.secondMinorMediaInfoView removeFromSuperview];
        [self.secondMinorMediaInfoView destroyView];
        self.secondMinorMediaInfoView = nil;
    }
    if (recording) {
        // 添加媒体信息视图
        self.secondMinorMediaInfoView = [[BJLScMediaInfoView alloc] initWithRoom:self.room user:self.room.loginUser];
    }
    else if (user) {
        self.secondMinorMediaInfoView = [[BJLScMediaInfoView alloc] initWithRoom:self.room user:user];
    }

    if (self.secondMinorWindowType == BJLScWindowType_userVideo
        && self.secondMinorMediaInfoView.positionType != BJLScPositionType_secondMinor) {
        [self replaceSecondMinorContentViewWithSecondMinorMediaInfoView];
    }
    else if (self.majorWindowType == BJLScPositionType_major
             && self.secondMinorMediaInfoView.positionType != BJLScPositionType_major) {
        [self replaceMajorContentViewWithSecondMinorMediaInfoView];
    }
    else {
        // unsupported
    }
}

#pragma mark - placeholder

- (void)updateTeacherVideoPlaceholderView {
    BOOL needFullScreen = self.room.featureConfig.enableAutoVideoFullscreen && self.fullscreenWindowType == BJLScWindowType_teacherVideo;
    BOOL largeSize = self.majorWindowType == BJLScWindowType_teacherVideo;
    UIView *targetView = needFullScreen ? self.fullscreenLayer : (largeSize ? self.majorContentView : self.minorContentView);
    [self.teacherVideoPlaceholderView updateTip:nil font:[UIFont systemFontOfSize:largeSize ? 24 : 12]];
    [self.teacherVideoPlaceholderView removeFromSuperview];
    [self.teacherVideoPlaceholderView updateImage:[UIImage bjl_imageNamed:@"bjl_sc_noteacher"]];
    [targetView insertSubview:self.teacherVideoPlaceholderView atIndex:0];
    [self.teacherVideoPlaceholderView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(targetView);
    }];
    self.teacherVideoPlaceholderView.hidden = !!self.teacherMediaInfoView;
}

- (void)updateSecondMinorVideoPlaceholderView {
    BOOL largeSize = self.majorWindowType == BJLScWindowType_userVideo;
    UIView *targetView = largeSize ? self.majorContentView : self.secondMinorContentView;
    [self.secondMinorVideoPlaceholderView updateTip:nil font:[UIFont systemFontOfSize:largeSize ? 24 : 12]];
    [self.secondMinorVideoPlaceholderView removeFromSuperview];
    [self.secondMinorVideoPlaceholderView updateImage:[UIImage bjl_imageNamed:@"bjl_sc_noteacher"]];
    [targetView addSubview:self.secondMinorVideoPlaceholderView];
    [self.secondMinorVideoPlaceholderView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(targetView);
    }];
    self.secondMinorVideoPlaceholderView.hidden = !!self.secondMinorMediaInfoView;
}

#pragma mark - 点播暖场

- (void)updateWarmingUpView {
    // 非webrtc底层, 屏蔽点播预热功能
    if (!self.room.featureConfig.isWebRTC) {
        return;
    }
    if (self.room.roomVM.liveStarted) {
        [self.warmingUpView removeFromSuperview];
        self.warmingUpView = nil;
        if (self.controlsViewController.controlsHidden) {
            self.controlsViewController.controlsHidden = NO;
        }
    }
    else {
        [self getWarmingUpVideoList];
    }
}

- (void)getWarmingUpVideoList {
    bjl_weakify(self);
    [self.room.roomVM getWarmingUpVideoListWithCompletion:^(BOOL success, BOOL isLoop, NSArray<NSString *> *_Nonnull videoList) {
        bjl_strongify(self);
        if (!success || !videoList) {
            return;
        }
        if (!self.warmingUpView) {
            self.warmingUpView = [[BJLScWarmingUpView alloc] initWithList:videoList isLoop:isLoop room:self.room];
            if (!self.teacherMediaInfoView) {
                [self updateTeacherVideoView];
            }
            // 强制用大窗口播放点播暖场视频
            [self switchTeacherViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:NO];
            [self setWarmingUpViewCallback];
        }
    }];
}

- (void)setWarmingUpViewCallback {
    bjl_weakify(self);
    [self.warmingUpView setScaleCallback:^(BOOL shoudFullScreen) {
        bjl_strongify(self);
        if (self.fullscreenWindowType != BJLScWindowType_none) {
            [self restoreCurrentFullscreenWindow];
        }
        else {
            [self replaceFullscreenWithWindowType:BJLScWindowType_teacherVideo mediaInfoView:self.teacherMediaInfoView];
        }
    }];

    [self bjl_kvo:BJLMakeProperty(self.teacherMediaInfoView, isFullScreen) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        [self.warmingUpView updateView:self.teacherMediaInfoView.isFullScreen];
        return YES;
    }];
}

- (void)makeQuestionNaire {
    [self.room.roomVM getQuestionNaireWithCompletion:^(BOOL isNeedFill, NSString *_Nonnull questionURL) {
        if (isNeedFill && questionURL.length) {
            self.questionNaire = [[BJLQuestionNaire alloc] initWithURL:[NSURL URLWithString:questionURL]];
            bjl_weakify(self);
            [self.questionNaire setQuestionUrlSubmitCallback:^{
                bjl_strongify(self);
                self.questionNaire = nil;
            }];
            [self.questionNaire setCloseWebViewCallback:^{
                bjl_strongify(self);
                self.questionNaire = nil;
                [self exit];
            }];
            [self bjl_addChildViewController:self.questionNaire superview:self.lotteryLayer];
            [self.questionNaire.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.view);
            }];
        }
    }];
}

@end
