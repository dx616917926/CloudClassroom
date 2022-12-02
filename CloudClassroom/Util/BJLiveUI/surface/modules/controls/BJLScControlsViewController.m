//
//  BJLScControlsViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2020/12/21.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLScControlsViewController.h"
#import "BJLAnnularProgressView.h"
#import "BJLHandWritingBoardDeviceViewController.h"

@interface BJLScControlsViewController ()

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) BJLScWindowType windowType;
@property (nonatomic) BOOL fullScreen;
@property (nonatomic, weak) UIView *toolView, *fullScreenView;

// 所有可能需要重新布局的视图
@property (nonatomic) NSMutableArray<UIView *> *reLayoutViews;

// 内容视图
@property (nonatomic) UIView *containerView;

// 右侧按钮
@property (nonatomic) NSArray<UIView *> *currentRightViews;
@property (nonatomic) UIButton *handUpButton, *videoButton, *audioButton, *handWritingBoardButton;
@property (nonatomic) UIImageView *handWritingBoardConnectingImageView;

// 右上侧按钮
@property (nonatomic, readwrite) UIButton *moreOptionButton;

// 左侧按钮
@property (nonatomic) NSArray<UIView *> *currentLeftViews;
@property (nonatomic) UIButton *collapseButton, *scaleButton, *noticeButton, *questionButton, *eyeProtectedButton, *studentHomeworkButton, *webPPTAuthButton, *asCameraButton, *doubleClassSwitchButton, *switchRouteButton, *chatInputButton;
@property (nonatomic, readwrite) UIButton *bonusButton;

// 辅助视图
@property (nonatomic) UILabel *handRedDot, *questionRedDot;
@property (nonatomic) BJLAnnularProgressView *handProgressView;
@property (nonatomic) UIView *controlsTopPlaceholderView;
@end

@implementation BJLScControlsViewController

- (instancetype)initWithRoom:(BJLRoom *)room windowType:(BJLScWindowType)windowType fullScreen:(BOOL)fullScreen {
    if (self = [super init]) {
        self.room = room;
        self.windowType = windowType;
        self.fullScreen = fullScreen;
        self.controlsHidden = NO;
        self.controlsTopOffset = BJLScViewSpaceM;
        self.chatPanelViewController = [[BJLChatPanelViewController alloc] initWithRoomType:self.room.roomInfo.roomType];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [BJLHitTestView viewWithHitTestBlock:^UIView *_Nullable(UIView *_Nullable hitView, CGPoint point, UIEvent *_Nullable event) {
        if ([hitView isKindOfClass:[UIButton class]]) {
            return hitView;
        }
        return nil;
    }];
    [self makeSubviews];
    [self makeConstraints];
    [self makeObserving];
}

- (void)makeSubviews {
    CGFloat redDotSpace = 10.0;
    CGFloat redDotSize = 8.0;
    self.containerView = [BJLHitTestView new];
    [self.view addSubview:self.containerView];
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self.containerView addSubview:self.controlsTopPlaceholderView];
    [self.controlsTopPlaceholderView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.right.equalTo(self.containerView);
        make.height.equalTo(@(self.controlsTopOffset));
    }];

    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self, controlsTopOffset)
         observer:^BOOL(id now, id old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);

             [self.controlsTopPlaceholderView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                 make.left.top.right.equalTo(self.containerView);
                 make.height.equalTo(@(self.controlsTopOffset));
             }];

             return YES;
         }];

    self.moreOptionButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_alert_more"]
                                        selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_alert_more"]
                              accessibilityIdentifier:BJLKeypath(self, moreOptionButton)
                                             selector:@selector(moreOptionButtonEventHandler)];
    // right view
    self.handUpButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_handup"]
                                    selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_handup_selected"]
                          accessibilityIdentifier:BJLKeypath(self, handUpButton)
                                         selector:@selector(handUp)];
    self.handProgressView = [self makeProgressView];
    [self.handUpButton addSubview:self.handProgressView];
    [self.handProgressView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.handUpButton);
    }];
    self.handRedDot = [self makeRedDotWithSize:BJLScRedDotWidth];
    [self.handUpButton addSubview:self.handRedDot];
    [self.handRedDot bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.handUpButton).offset(redDotSpace);
        make.left.equalTo(self.handUpButton.bjl_centerX).offset(redDotSpace);
        make.height.width.equalTo(@(BJLScRedDotWidth));
    }];
    self.videoButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_videoOff"]
                                   selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_videoOn"]
                         accessibilityIdentifier:BJLKeypath(self, videoButton)
                                        selector:@selector(updateRecordingVideo)];
    self.audioButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_audioOff"]
                                   selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_audioOn"]
                         accessibilityIdentifier:BJLKeypath(self, audioButton)
                                        selector:@selector(updateRecordingAudio)];
    self.handWritingBoardButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_handwritingboard_normal"]
                                              selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_handwritingboard_connected"]
                                    accessibilityIdentifier:BJLKeypath(self, handWritingBoardButton)
                                                   selector:@selector(updateHandWritingBoardConnect:)];
    [self.handWritingBoardButton bjl_setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_handwritingboard_dormant"]
                                     forState:UIControlStateDisabled
                               possibleStates:UIControlStateSelected];
    [self makeHandWritingBoardConnectingImageView];
    [self.handWritingBoardButton addSubview:self.handWritingBoardConnectingImageView];
    [self.handWritingBoardConnectingImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.handWritingBoardButton);
    }];

    // left view
    self.collapseButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_collapse_off"]
                                      selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_collapse_on"]
                            accessibilityIdentifier:BJLKeypath(self, collapseButton)
                                           selector:@selector(collapseButtonEventHanlder:)];
    self.scaleButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_view_full"]
                                   selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_view_restore"]
                         accessibilityIdentifier:BJLKeypath(self, scaleButton)
                                        selector:@selector(scale)];
    self.noticeButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_notice"]
                                    selectedImage:nil
                          accessibilityIdentifier:BJLKeypath(self, noticeButton)
                                         selector:@selector(showNotice)];
    self.questionButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_question"]
                                      selectedImage:nil
                            accessibilityIdentifier:BJLKeypath(self, questionButton)
                                           selector:@selector(showQuestion)];
    self.questionRedDot = [self makeRedDotWithSize:redDotSize];
    [self.questionButton addSubview:self.questionRedDot];
    [self.questionRedDot bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.questionButton).offset(redDotSpace);
        make.left.equalTo(self.questionButton.bjl_centerX).offset(redDotSpace);
        make.height.width.equalTo(@(redDotSize));
    }];
    self.eyeProtectedButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_eyeProtected_close"]
                                          selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_eyeProtected_open"]
                                accessibilityIdentifier:BJLKeypath(self, eyeProtectedButton)
                                               selector:@selector(switchEyeProtectedMode)];
    self.studentHomeworkButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_homework"]
                                             selectedImage:nil
                                   accessibilityIdentifier:BJLKeypath(self, studentHomeworkButton)
                                                  selector:@selector(showHomeworkView)];
    self.webPPTAuthButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_h5_auth_off"]
                                        selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_h5_auth_on"]
                              accessibilityIdentifier:BJLKeypath(self, webPPTAuthButton)
                                             selector:@selector(switchWebPPTAuth)];
    self.asCameraButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_ascamera_normal"]
                                      selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_ascamera_selected"]
                            accessibilityIdentifier:BJLKeypath(self, asCameraButton)
                                           selector:@selector(updateAsCamera)];

    self.bonusButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_bonus"]
                                   selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_bonus"]
                         accessibilityIdentifier:BJLKeypath(self, bonusButton)
                                        selector:@selector(bonusEvent)];

    self.doubleClassSwitchButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_doubleClass_tosmall"]
                                               selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_doubleClass_tobig"]
                                     accessibilityIdentifier:BJLKeypath(self, doubleClassSwitchButton)
                                                    selector:@selector(switchDoubleClass)];
    self.switchRouteButton = [self makeButtonWithImage:[UIImage bjlsc_imageNamed:@"bjl_sc_student_route"]
                                         selectedImage:[UIImage bjlsc_imageNamed:@"bjl_sc_student_route"]
                               accessibilityIdentifier:BJLKeypath(self, switchRouteButton)
                                              selector:@selector(showSwitchRouteView)];

    self.chatInputButton = ({
        UIButton *button = [UIButton new];
        [button setBackgroundImage:[UIImage bjlsc_imageNamed:@"bjl_sc_chat_input"] forState:UIControlStateNormal];
        [button setTitle:@"输入聊天内容" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.chatIputButtonClickCallback) {
                self.chatIputButtonClickCallback();
            }
        }];
        button;
    });
}

- (void)clearControls {
    for (UIView *view in self.reLayoutViews) {
        if ([view respondsToSelector:@selector(removeFromSuperview)]) {
            [view removeFromSuperview];
        }
    }
}

- (void)makeConstraints {
    [self updateControlsForWindowType:self.windowType fullScreen:self.fullScreen];
}

- (void)updateControlsForWindowType:(BJLScWindowType)windowType fullScreen:(BOOL)fullScreen {
    self.windowType = windowType;
    UIView *superView = fullScreen ? self.fullScreenView : self.toolView;
    if (self.fullScreen != fullScreen || self.view.superview != superView) {
        if (![self.view.superview isEqual:superView]) {
            [self.view removeFromSuperview];
            [superView addSubview:self.view];
            [self.view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(superView);
            }];
        }
        self.fullScreen = fullScreen;
    }
    // 试听用户无功能
    if (self.room.loginUser.isAudition) {
        return;
    }

    [self makeConstraintsForCommonViews];
    [self makeConstraintsForRightViews];
    [self makeConstraintsForLeftViews];
}

- (void)makeConstraintsForCommonViews {
    //右上方的按钮
    [self.containerView addSubview:self.moreOptionButton];
    [self.moreOptionButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.controlsTopPlaceholderView.bjl_bottom);
        make.right.equalTo(self.containerView).offset(-BJLScViewSpaceS);
        make.width.height.equalTo(@(BJLScControlSize));
    }];
}

- (void)makeConstraintsForRightViews {
    NSMutableArray<UIView *> *rightViews = [@[self.scaleButton, self.handUpButton, self.videoButton, self.audioButton, self.handWritingBoardButton] mutableCopy];
    // 大班课学生发言要老师允许，此外的班型允许任何人自由发言
    BOOL needNotHandUp = self.room.roomInfo.roomType != BJLRoomType_1vNClass;
    BOOL freeToSpeak = self.room.speakingRequestVM.speakingEnabled || needNotHandUp;
    BOOL hasStudentRaise = self.room.featureConfig.isWebRTC ? self.room.roomInfo.hasStudentRaise : YES;
    BOOL disableSpeak = self.room.roomInfo.isPushLive || self.room.roomInfo.isMockLive || (self.room.loginUser.isStudent && !hasStudentRaise);

    // 老师、可以发言的学生、非全屏显示音视频按钮
    BOOL speakingEnabled = !disableSpeak && (self.room.loginUser.isTeacherOrAssistant || (self.room.loginUser.isStudent && freeToSpeak));
    BOOL audioButtonHidden = !speakingEnabled || self.fullScreen;
    BOOL videoButtonHidden = audioButtonHidden || (!self.room.loginUser.isTeacherOrAssistant && self.room.featureConfig.hideStudentCamera);
    // 学生和举手列表人数大于 0 时老师或者助教显示举手按钮
    BOOL needHandleSpeakRequest = (self.room.loginUser.isTeacherOrAssistant && self.room.speakingRequestVM.speakingRequestUsers.count > 0);
    BOOL handUpButtonHidden = disableSpeak || needNotHandUp || (self.room.loginUser.isTeacherOrAssistant && !needHandleSpeakRequest);
    // 配置了支持使用手写板，并且有上次记录 或者 当前已经连上, 则显示手写板
    BOOL showWritingBoardButton = self.room.featureConfig.enableUseHandWritingBoard && (!![BJLHandWritingBoardDeviceViewController prevConnectedWritingBoard] || self.room.drawingVM.connectedHandWritingBoard);
    if (audioButtonHidden) {
        [rightViews bjl_removeObject:self.audioButton];
    }
    if (videoButtonHidden) {
        [rightViews bjl_removeObject:self.videoButton];
    }
    if (handUpButtonHidden) {
        [rightViews bjl_removeObject:self.handUpButton];
    }
    if (!showWritingBoardButton) {
        [rightViews bjl_removeObject:self.handWritingBoardButton];
    }
    if ([self sameViews:rightViews withViews:self.currentRightViews]) {
        return;
    }
    [self removeViews:self.currentRightViews];
    self.currentRightViews = rightViews;
    UIView *last = nil;
    for (UIView *view in self.currentRightViews) {
        [self.containerView addSubview:view];
        [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.bottom.equalTo(self.containerView).offset(-BJLScViewSpaceM);
            make.right.equalTo(last.bjl_left ?: self.containerView).offset(last ? 0.0 : -BJLScViewSpaceS);
            make.width.height.equalTo(@(BJLScControlSize));
        }];
        last = view;
    }
}

- (void)makeConstraintsForLeftViews {
    NSMutableArray<UIView *> *leftViews = [@[self.noticeButton, self.questionButton, self.eyeProtectedButton, self.webPPTAuthButton, self.asCameraButton, self.studentHomeworkButton, self.bonusButton, self.doubleClassSwitchButton, self.switchRouteButton] mutableCopy];
    // 1v1、全屏无公告
    BOOL noticeHidden = self.is1V1Class || self.fullScreen;
    NSString *liveTabs = self.room.loginUser.isTeacherOrAssistant ? self.room.featureConfig.liveTabs : self.room.featureConfig.liveTabsOfStudent;
    // 1v1、全屏、配置了没有问答
    BOOL questionHidden = self.is1V1Class || ![liveTabs containsString:@"answer"] || !self.room.featureConfig.enableQuestion || self.fullScreen;
    // 学生或者配置了不显示课件授权
    BOOL webPPTAuthHidden = !self.room.loginUser.isTeacherOrAssistant || !self.room.featureConfig.canShowH5PPTAuthButton || (!self.fullScreen && self.windowType != BJLScWindowType_ppt);
    // 不是主讲人或者配置不使用外接设备
    BOOL asCameraHidden = !self.room.featureConfig.enableAttachPhoneCamera || !self.room.loginUserIsPresenter || self.windowType != BJLScWindowType_teacherVideo;
    // 学生 & 配置了支持作业才展示 & 非全屏
    BOOL showHomework = self.room.featureConfig.enableHomework && self.room.loginUser.isStudent && !self.fullScreen;
    // 后台配置的 CDN 数量大于一个时，学生和助教显示切换线路按钮，上课后不是合流则隐藏 CDN 切换按钮
    BOOL showSwitchRoute = (((self.room.loginUser.isStudent || self.room.loginUser.isAssistant) && self.room.playingVM.playMixedVideo)
                               || !self.room.roomVM.liveStarted)
                           && self.room.mediaVM.downLinkCDNCount > 1 && !self.room.loginUserIsPresenter;

    if (noticeHidden) {
        [leftViews bjl_removeObject:self.noticeButton];
    }
    if (questionHidden) {
        [leftViews bjl_removeObject:self.questionButton];
    }
    if (webPPTAuthHidden) {
        [leftViews bjl_removeObject:self.webPPTAuthButton];
    }
    if (asCameraHidden) {
        [leftViews bjl_removeObject:self.asCameraButton];
    }
    if (!showHomework) {
        [leftViews bjl_removeObject:self.studentHomeworkButton];
    }
    if (!self.room.featureConfig.enableUseBonusPoints) {
        [leftViews bjl_removeObject:self.bonusButton];
    }
    if (![self shouldShowSwitchClassButton]) {
        [leftViews bjl_removeObject:self.doubleClassSwitchButton];
    }
    if (!showSwitchRoute) {
        [leftViews bjl_removeObject:self.switchRouteButton];
    }

    if ([self sameViews:leftViews withViews:self.currentLeftViews]) {
        return;
    }
    [self removeViews:self.currentLeftViews];
    self.currentLeftViews = leftViews;
    [self buildLeftSideButtonConstraints:NO];
}

- (void)buildLeftSideButtonConstraints:(BOOL)animation {
    if (!self.collapseButton.superview) {
        [self.containerView addSubview:self.collapseButton];
        [self.collapseButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.containerView);
            make.bottom.equalTo(self.containerView).offset(-BJLScViewSpaceM);
            make.width.height.equalTo(@(BJLScControlSize));
        }];
    }

    [self.containerView setNeedsLayout];
    [self.containerView layoutIfNeeded];

    UIView *last = self.collapseButton;
    for (UIView *view in self.currentLeftViews) {
        if (!view.superview) {
            [self.containerView addSubview:view];
            [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                if (self.collapseButton.isSelected) {
                    make.left.equalTo(last);
                }
                else {
                    make.left.equalTo(last.bjl_right);
                }
                make.bottom.equalTo(self.containerView).offset(-BJLScViewSpaceM);
                make.width.height.equalTo(@(BJLScControlSize));
            }];
        }
        else {
            [view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                if (self.collapseButton.isSelected) {
                    make.left.equalTo(last);
                }
                else {
                    make.left.equalTo(last.bjl_right);
                }
                make.bottom.equalTo(self.containerView).offset(-BJLScViewSpaceM);
                make.width.height.equalTo(@(BJLScControlSize));
            }];
        }
        view.alpha = self.collapseButton.isSelected ? 0 : 1;
        last = view;
    }
    [self updateChatPanelViewWithLastView:last];

    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.containerView setNeedsLayout];
            [self.containerView layoutIfNeeded];
        }];
    }
    [self.containerView bringSubviewToFront:self.collapseButton];
}

- (void)updateChatPanelViewWithLastView:(UIView *)lastView {
    if (self.fullScreen && self.room.featureConfig.enableAutoVideoFullscreen
        && (self.windowType == BJLScWindowType_teacherVideo || self.windowType == BJLScWindowType_userVideo)
        && self.room.roomInfo.isVideoWall) {
        if (!self.chatInputButton.superview) {
            [self.containerView addSubview:self.chatInputButton];
            [self.chatInputButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.equalTo(lastView.bjl_right);
                make.centerY.equalTo(lastView);
                make.height.equalTo(@(BJLScControlSize));
                make.width.equalTo(@140);
            }];
        }
        else {
            [self.chatInputButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.equalTo(lastView.bjl_right);
                make.centerY.equalTo(lastView);
                make.height.equalTo(@(BJLScControlSize));
                make.width.equalTo(@140);
            }];
        }

        if (!self.chatPanelViewController.view.superview) {
            [self.containerView addSubview:self.chatPanelViewController.view];
            [self.chatPanelViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.equalTo(self.containerView.bjl_safeAreaLayoutGuide);
                make.top.equalTo(self.controlsTopPlaceholderView.bjl_bottom);
                make.bottom.equalTo(self.containerView).offset(-70.0);
                make.width.equalTo(@220.0);
            }];
        }
    }
    else {
        [self.chatInputButton removeFromSuperview];
        [self.chatPanelViewController.view removeFromSuperview];
    }
}

#pragma mark -

- (void)makeObserving {
    bjl_weakify(self);

    [self bjl_kvoMerge:@[BJLMakeProperty(self, controlsHidden),
        BJLMakeProperty(self, fullScreen)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  self.containerView.hidden = self.controlsHidden && !self.fullScreen;
              }];

    if (self.room.loginUser.isTeacherOrAssistant) {
        [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingRequestUsers)
            filter:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                // 目前分组的老师助教不处理举手
                return self.room.loginUser.groupID == 0;
            } observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                NSInteger count = [self.room.speakingRequestVM.speakingRequestUsers count];
                self.handUpButton.hidden = (count <= 0);
                self.handRedDot.hidden = (count <= 0);
                self.handRedDot.text = count > 99 ? @"···" : [NSString stringWithFormat:@"%td", count];
                return YES;
            }];
    }
    else {
        [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingEnabled)
             observer:^BJLControlObserving(NSNumber *_Nullable now, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 self.handUpButton.selected = now.boolValue;
                 return YES;
             }];

        [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingRequestTimeRemaining)
            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
            filter:^BOOL(NSNumber *_Nullable timeRemaining, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                // bjl_strongify(self);
                return timeRemaining.doubleValue != old.doubleValue;
            }
            observer:^BOOL(NSNumber *_Nullable timeRemaining, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                if (timeRemaining.doubleValue <= 0.0) {
                    self.handProgressView.progress = 0.0;
                }
                else {
                    CGFloat progress = timeRemaining.doubleValue / self.room.speakingRequestVM.speakingRequestTimeoutInterval; // 1.0 ~ 0.0
                    self.handProgressView.progress = progress;
                }
                return YES;
            }];
    }

    BJLPropertyFilter ifIntegerChanged = ^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
        // bjl_strongify(self);
        return now.integerValue != old.integerValue;
    };

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingAudio)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:ifIntegerChanged
         observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.audioButton.selected = now.boolValue;
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingVideo)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:ifIntegerChanged
         observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.videoButton.selected = now.boolValue;
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, connectedHandWritingBoard)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             // 连上手写板时, 如果ui上没有 handWritingBoardButton, 则先添加按钮
             if (self.room.drawingVM.connectedHandWritingBoard
                 && ![self.currentRightViews containsObject:self.handWritingBoardButton]) {
                 [self makeConstraintsForRightViews];
             }
             self.handWritingBoardButton.selected = (self.room.drawingVM.connectedHandWritingBoard != nil);
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, isConnectingHandWritingBoard)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.handWritingBoardConnectingImageView.hidden = !self.room.drawingVM.isConnectingHandWritingBoard;
             self.handWritingBoardButton.userInteractionEnabled = !self.room.drawingVM.isConnectingHandWritingBoard;
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, connectedDeviceSleep)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.handWritingBoardButton.enabled = !self.room.drawingVM.connectedDeviceSleep;
             if (!self.room.drawingVM.connectedDeviceSleep
                 && self.room.drawingVM.connectedHandWritingBoard) {
                 self.handWritingBoardButton.selected = YES;
             }
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self, fullScreen)
         observer:^BJLControlObserving(NSNumber *_Nullable now, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.scaleButton.selected = now.boolValue;
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.documentVM, authorizedH5PPT)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.webPPTAuthButton.selected = self.room.documentVM.authorizedH5PPT;
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, hasAsCameraUser)
         observer:^BJLControlObserving(NSNumber *_Nullable now, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.asCameraButton.selected = now.boolValue;
             return YES;
         }];

    // 影响按钮的显示和隐藏的监听
    if (self.room.loginUser.isTeacherOrAssistant) {
        [self bjl_kvoMerge:@[BJLMakeProperty(self.room.speakingRequestVM, speakingRequestUsers),
            BJLMakeProperty(self.room.onlineUsersVM, currentPresenter)]
                  observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                      bjl_strongify(self);
                      [self makeConstraints];
                  }];
    }
    else {
        [self bjl_kvoMerge:@[BJLMakeProperty(self.room.speakingRequestVM, speakingEnabled)]
                  observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                      bjl_strongify(self);
                      [self makeConstraints];
                  }];
    }

    [self bjl_kvoMerge:@[BJLMakeProperty(self.room, switchingRoom),
        BJLMakeProperty(self.room, onlineDoubleRoomType)]
        filter:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            return (!self.room.switchingRoom && [self shouldShowSwitchClassButton]);
        } observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            self.doubleClassSwitchButton.selected = self.room.onlineDoubleRoomType == BJLOnlineDoubleRoomType_group;
        }];
}

#pragma mark -

- (void)setupToolView:(UIView *)view fullScreenView:(UIView *)fullScreenView {
    self.toolView = view;
    self.fullScreenView = fullScreenView;
}

- (void)updateQuestionRedDotHidden:(BOOL)hidden {
    self.questionRedDot.hidden = hidden;
}

#pragma mark -
- (void)moreOptionButtonEventHandler {
    if (self.moreOptionEventCallback) {
        self.moreOptionEventCallback();
    }
}

- (void)handUp {
    if (self.handUpCallback) {
        self.handUpCallback();
    }
}

- (void)updateRecordingVideo {
    if (self.updateRecordingVideoCallback) {
        self.updateRecordingVideoCallback();
    }
}

- (void)updateRecordingAudio {
    if (self.updateRecordingAudioCallback) {
        self.updateRecordingAudioCallback();
    }
}

- (void)updateHandWritingBoardConnect:(UIButton *)button {
    if (self.updateHandWritingBoardCallback) {
        self.updateHandWritingBoardCallback(!button.isSelected);
    }
}

- (void)collapseButtonEventHanlder:(UIButton *)button {
    button.selected = !button.isSelected;
    [self buildLeftSideButtonConstraints:YES];
}

- (void)scale {
    if (self.scaleCallback) {
        self.scaleCallback();
    }
}

- (void)showNotice {
    if (self.showNoticeCallback) {
        self.showNoticeCallback();
    }
}

- (void)showQuestion {
    [self updateQuestionRedDotHidden:YES];
    if (self.showQuestionCallback) {
        self.showQuestionCallback();
    }
}

- (void)switchEyeProtectedMode {
    self.eyeProtectedButton.selected = !self.eyeProtectedButton.selected;
    if (self.switchEyeProtectedCallback) {
        self.switchEyeProtectedCallback();
    }
}

- (void)showHomeworkView {
    self.studentHomeworkButton.selected = !self.studentHomeworkButton.selected;
    if (self.showHomeworkViewCallback) {
        self.showHomeworkViewCallback();
    }
}

- (void)switchWebPPTAuth {
    if (self.switchWebPPTAuthCallback) {
        self.switchWebPPTAuthCallback();
    }
}

- (void)updateAsCamera {
    if (self.updateAsCameraCallback) {
        self.updateAsCameraCallback();
    }
}

- (void)bonusEvent {
    if (self.bonusEventCallback) {
        self.bonusEventCallback();
    }
}

- (void)switchDoubleClass {
    if (self.switchDoubleClassCallback) {
        self.switchDoubleClassCallback();
    }
}

- (void)showSwitchRouteView {
    if (self.showSwitchRouteCallback) {
        self.showSwitchRouteCallback();
    }
}

#pragma mark -

- (void)startAnimationWhenConnectingHandWritingBoard {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    animation.duration = 1.0;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    [self.handWritingBoardConnectingImageView.layer addAnimation:animation forKey:@"rotate"];
}

- (void)stopstartHandWritingBoardAnimation {
    [self.handWritingBoardConnectingImageView.layer removeAllAnimations];
}

#pragma mark -

- (void)removeViews:(NSArray<UIView *> *)views {
    for (UIView *view in views) {
        if ([view respondsToSelector:@selector(removeFromSuperview)]) {
            [view removeFromSuperview];
        }
    }
}

- (BOOL)sameViews:(NSArray<UIView *> *)views withViews:(NSArray<UIView *> *)otherViews {
    if (views.count != otherViews.count) {
        return NO;
    }
    for (NSInteger i = 0; i < views.count; i++) {
        UIView *view = [views bjl_objectAtIndex:i];
        UIView *otherView = [otherViews bjl_objectAtIndex:i];
        if (view != otherView) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -

- (UIButton *)makeButtonWithImage:(nullable UIImage *)image
                    selectedImage:(nullable UIImage *)selectedImage
          accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                         selector:(nullable SEL)action {
    UIButton *button = [UIButton new];
    button.accessibilityIdentifier = accessibilityIdentifier;
    if (image) {
        [button bjl_setImage:image forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    }
    if (selectedImage) {
        [button bjl_setImage:selectedImage forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
    }
    if (button) {
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [self.reLayoutViews addObject:button];
    return button;
}

- (UILabel *)makeRedDotWithSize:(CGFloat)dotSize {
    UILabel *view = [UILabel new];
    view.hidden = YES;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = dotSize / 2;
    view.backgroundColor = BJLTheme.warningColor;
    view.textColor = [UIColor whiteColor];
    view.textAlignment = NSTextAlignmentCenter;
    view.adjustsFontSizeToFitWidth = YES;
    view.font = [UIFont systemFontOfSize:8.0];
    [self.reLayoutViews addObject:view];
    return view;
}

- (BJLAnnularProgressView *)makeProgressView {
    BJLAnnularProgressView *progressView = [BJLAnnularProgressView new];
    progressView.size = BJLScButtonSizeS;
    progressView.annularWidth = 2.0;
    progressView.color = [UIColor whiteColor];
    progressView.userInteractionEnabled = NO;
    [self.handUpButton addSubview:progressView];
    [self.reLayoutViews addObject:progressView];
    return progressView;
}

- (void)makeHandWritingBoardConnectingImageView {
    self.handWritingBoardConnectingImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage bjlsc_imageNamed:@"bjl_sc_handWritingBoard_connecting"];
        imageView.hidden = YES;
        imageView;
    });
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.handWritingBoardConnectingImageView, hidden)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.handWritingBoardConnectingImageView.hidden) {
                 [self stopstartHandWritingBoardAnimation];
             }
             else {
                 [self startAnimationWhenConnectingHandWritingBoard];
             }
             return YES;
         }];
}

- (UIView *)controlsTopPlaceholderView {
    if (!_controlsTopPlaceholderView) {
        _controlsTopPlaceholderView = [[UIView alloc] init];
        _controlsTopPlaceholderView.backgroundColor = [UIColor clearColor];
        _controlsTopPlaceholderView.accessibilityIdentifier = @"_scTopBarVCPlaceholderView";
    }
    return _controlsTopPlaceholderView;
}

- (BOOL)is1V1Class {
    return self.room.roomInfo.roomType == BJLRoomType_1v1Class;
}

/**
 1. 线上双师的班型
 2. 读取小班进入大版是通过大班老师还是通过小班老师
 2. 读取是否允许课中切班的配置项
 */
- (BOOL)shouldShowSwitchClassButton {
    if (!self.room.loginUser.isTeacherOrAssistant) {
        return NO;
    }

    // 分组讨论中的线上双师小班老师
    if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_normal
        && self.room.onlineDoubleRoomType == BJLOnlineDoubleRoomType_group
        && self.room.loginUser.noGroup
        && !self.room.featureConfig.switchRoomRoleByDoubleOnlineTeacher) {
        return YES;
    }

    if (self.room.roomInfo.newRoomGroupType != BJLRoomNewGroupType_onlinedoubleTeachers) {
        return NO;
    }

    // 由线上双师的大班老师控制
    if (self.room.featureConfig.switchRoomRoleByDoubleOnlineTeacher) {
        if (!self.room.loginUser.noGroup) {
            return NO;
        }

        if (self.room.featureConfig.disableSwitchClass && self.room.roomVM.liveStarted) {
            return NO;
        }
        return YES;
    }
    else {
        // 由线上双师的小班老师控制
        if (self.room.loginUser.noGroup) {
            return NO;
        }
        return YES;
    }
}

@end
