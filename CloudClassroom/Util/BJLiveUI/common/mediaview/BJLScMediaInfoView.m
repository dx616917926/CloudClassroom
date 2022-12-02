//
//  BJLScMediaInfoView.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/19.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScMediaInfoView.h"
#import "BJLScVideoPlaceholderView.h"
#import "BJLAppearance.h"
#import "BJLMutableAwardsView.h"

@interface BJLScMediaInfoView () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) BOOL recording;
@property (nonatomic, readwrite) BJLUser *user;
@property (nonatomic, readwrite, nullable) BJLMediaUser *mediaUser;
@property (nonatomic) UIView *containerView;
@property (nonatomic) BJLScVideoPlaceholderView *videoPlaceholderView;
@property (nonatomic, weak) UIView *videoView;
@property (nonatomic) UIButton *likeButton;
@property (nonatomic) UIView *infoView;
@property (nonatomic, strong) CAGradientLayer *infoViewGradientLayer;
@property (nonatomic) UILabel *nameLabel, *definitionLabel;
@property (nonatomic, nullable) NSString *imageURLString; // 用户未开视频时的占位图url
@property (nonatomic) CGFloat ratio;
@property (nonatomic) BOOL likeButtonHidden;

// 用于强制更新视图，主要合流模式切换
@property (nonatomic) BOOL needUpdateView;

// 加载中的loading
@property (nonatomic) id<BJLObservation> mediaUserObservation;
@property (nonatomic) UIView *videoLoadingView;
@property (nonatomic) UIImageView *videoLoadingImageView;
@property (nonatomic) BOOL animating, needStopAnimation;

@property (nonatomic, weak) UIViewController *parentViewController;

/// 点赞ui vc
@property (nonatomic) UIViewController *awardsViewController;

@end

@implementation BJLScMediaInfoView

- (instancetype)initWithRoom:(BJLRoom *)room user:(__kindof BJLUser *)user {
    if (self = [super init]) {
        if (!user.ID || [user.ID isEqualToString:room.loginUser.ID]) {
            self.recording = YES;
        }
        else {
            self.recording = NO;
            self.mediaUser = bjl_as(user, BJLMediaUser);
        }
        self.room = room;
        self.user = user;
        self.imageURLString = user.cameraCover;
        self.positionType = BJLScPositionType_none;
        self.isFullScreen = NO;
        self.needUpdateView = NO;
        self.needStopAnimation = YES;
        [self makeSubviewsAndConstraints];
        [self makeObserving];
    }
    return self;
}

- (void)destroyView {
    [self bjl_stopAllKeyValueObserving];
    [self bjl_stopAllMethodParametersObserving];
    [self stopLoadingAnimation];
}

#pragma mark - subview

- (void)makeSubviewsAndConstraints {
    self.containerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_colorWithHex:0X313847];
        view.accessibilityIdentifier = BJLKeypath(self, containerView);
        view;
    });
    [self addSubview:self.containerView];
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self);
    }];

    // 视频加载占位图
    self.videoLoadingView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, videoLoadingView);
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        view.hidden = YES;
        view;
    });
    [self addSubview:self.videoLoadingView];
    [self.videoLoadingView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self);
    }];
    self.videoLoadingImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_user_loading"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.accessibilityIdentifier = BJLKeypath(self, videoLoadingImageView);
        imageView;
    });
    [self.videoLoadingView addSubview:self.videoLoadingImageView];
    [self.videoLoadingImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.videoLoadingView);
        make.width.height.equalTo(self.videoLoadingView).multipliedBy(0.4);
    }];

    // 占位图
    self.videoPlaceholderView = ({
        BJLScVideoPlaceholderView *view = [[BJLScVideoPlaceholderView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_sc_videoClose"] tip:BJLLocalizedString(@"已关闭摄像头")];
        view.accessibilityIdentifier = BJLKeypath(self, videoPlaceholderView);
        view.hidden = YES;
        view;
    });
    [self addSubview:self.videoPlaceholderView];
    [self.videoPlaceholderView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self);
    }];

    self.infoView = ({
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.clearColor;
        view.accessibilityIdentifier = BJLKeypath(self, infoView);

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0.0 alpha:0].CGColor,
            (__bridge id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor];
        [view.layer addSublayer:gradientLayer];
        self.infoViewGradientLayer = gradientLayer;

        view;
    });
    [self addSubview:self.infoView];
    [self.infoView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(@24.0);
    }];

    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.accessibilityIdentifier = BJLKeypath(self, nameLabel);
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor whiteColor];
        label;
    });
    [self.infoView addSubview:self.nameLabel];

    if (!self.isSellUI) {
        [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.infoView).offset(8.0);
            make.top.bottom.equalTo(self.infoView);
            make.right.lessThanOrEqualTo(self.infoView);
        }];
    }
    else {
        [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.bottom.equalTo(self.infoView);
            make.centerX.equalTo(self.infoView);
            make.left.greaterThanOrEqualTo(self.infoView);
            make.right.lessThanOrEqualTo(self.infoView);
        }];
    }

    self.definitionLabel = ({
        UILabel *label = [UILabel new];
        label.hidden = YES;
        label.backgroundColor = [UIColor clearColor];
        label.accessibilityIdentifier = BJLKeypath(self, definitionLabel);
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor whiteColor];
        label;
    });
    [self.infoView addSubview:self.definitionLabel];
    [self.definitionLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.infoView).offset(-10.0);
        make.top.bottom.equalTo(self.infoView);
        make.left.greaterThanOrEqualTo(self.nameLabel);
        make.hugging.compressionResistance.required();
    }];

    self.likeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.accessibilityIdentifier = BJLKeypath(self, likeButton);
        button.titleLabel.font = [UIFont systemFontOfSize:10.0];
        button.layer.cornerRadius = 8.0;
        button.layer.masksToBounds = YES;
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 4.0, 0.0, 4.0);
        [button setTitle:nil forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage bjl_imageWithColor:[UIColor colorWithWhite:0.0 alpha:0.5]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor bjl_colorWithHexString:@"#F7E123"] forState:UIControlStateNormal];
        if ([BJLAward allAwards].count > 1) {
            [button setImage:[UIImage bjl_imageNamed:@"bjl_sc_award_mediainfo"] forState:UIControlStateNormal];
        }
        else {
            [button setImage:[UIImage bjl_imageNamed:@"bjl_sc_like_icon"] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(sendLikeForCurrentUser) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self addSubview:self.likeButton];
    [self.likeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self).offset(4.0);
        make.bottom.equalTo(self.infoView.bjl_top).offset(-3.0);
        make.height.equalTo(@(16.0));
    }];

    [self updateCurrentUserAndUpdateViewIfNeed:YES];
    [self updateVideoPlaceholderViewImage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /* 1、老师助教隐藏点赞按钮，
       2、登录用户是学生，视频是学生视频，并且点赞数为0，隐藏点赞按钮 */
    NSInteger likeCount = [self.room.roomVM.likeList bjl_integerForKey:self.user.number];
    BOOL hideLikeButton = !self.user || self.user.isTeacherOrAssistant || (self.room.loginUser.isStudent && !likeCount);
    [self updateWithLikeCount:likeCount hidden:hideLikeButton];
    self.infoViewGradientLayer.frame = self.infoView.bounds;
}

#pragma mark - observing

- (void)makeObserving {
    bjl_weakify(self);

    // mediaUser 更新
    if (self.recording) {
        [self bjl_kvoMerge:@[BJLMakeProperty(self.room.recordingVM, recordingAudio),
            BJLMakeProperty(self.room.recordingVM, recordingVideo)]
                  observer:(BJLPropertiesObserver) ^ (id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                      bjl_strongify(self);
                      [self updateCurrentUserAndUpdateViewIfNeed:YES];
                  }];
        [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, inputVideoAspectRatio)
             observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 self.ratio = self.room.recordingVM.inputVideoAspectRatio;
                 return YES;
             }];
    }
    else {
        // 无 mediaUser 的情况认为是未开音视频的主摄像头用户
        if (self.mediaUser.cameraType == BJLCameraType_main || !self.mediaUser) {
            [self bjl_kvo:BJLMakeProperty(self.room.mainPlayingAdapterVM, playingUsers)
                 observer:^BOOL(NSArray<BJLMediaUser *> *_Nullable playingUsers, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                     bjl_strongify(self);
                     [self updateCurrentUserWithPlayingUsers:playingUsers];
                     return YES;
                 }];
        }
        else {
            [self bjl_kvo:BJLMakeProperty(self.room.extraPlayingAdapterVM, playingUsers)
                 observer:^BOOL(NSArray<BJLMediaUser *> *_Nullable playingUsers, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                     bjl_strongify(self);
                     [self updateCurrentUserWithPlayingUsers:playingUsers];
                     return YES;
                 }];
        }
        // 一开始在 playingUsers 中就打开摄像头和麦克风，但是还未加入到 videoPlayingUsers 中的情况
        [self bjl_kvo:BJLMakeProperty(self.room.playingVM, videoPlayingUsers)
             observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 [self updateCloseVideoPlaceholderHidden:[self isVideoPlayingUser]];
                 return YES;
             }];

        // 合流模式切换会更新 videoview
        [self bjl_kvo:BJLMakeProperty(self.room.playingVM, playMixedVideo)
             observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 self.needUpdateView = YES;
                 return YES;
             }];

        // 视频比例
        [self bjl_observe:BJLMakeMethod(self.room.playingVM, playingViewAspectRatioChanged:forUser:)
                 observer:(BJLMethodObserver) ^ BOOL(CGFloat ratio, BJLMediaUser * user) {
                     bjl_strongify(self);
                     if ([user isSameCameraUser:self.mediaUser]) {
                         self.ratio = ratio;
                         [self.room.playingVM updateWatermarkWithUser:self.mediaUser size:CGSizeMake(self.ratio, 1.0) videoContentMode:BJLVideoContentMode_aspectFit];
                     }
                     return YES;
                 }];

        [self bjl_kvoMerge:@[BJLMakeProperty(self.room.playingVM, playMixedVideo),
            BJLMakeProperty(self.room.onlineUsersVM, currentPresenter)]
                  observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                      bjl_strongify(self);
                      self.definitionLabel.hidden = !([self enableSwitchMixedVideoDefinition] && [self.user isSameUser:self.room.onlineUsersVM.currentPresenter]);
                      if (self.definitionLabel.hidden) {
                          self.definitionLabel.text = nil;
                      }
                      else {
                          self.definitionLabel.text = self.room.playingVM.originCDNVideoDefinition ? BJLLocalizedString(@"原画") : BJLLocalizedString(@"高清");
                      }

                      if (self.isPortraitMode || self.isSellUI) {
                          self.definitionLabel.hidden = YES;
                      }
                  }];
        [self bjl_kvo:BJLMakeProperty(self.room.playingVM, originCDNVideoDefinition)
             observer:^BJLControlObserving(NSNumber *_Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 self.definitionLabel.text = value.bjl_boolValue ? BJLLocalizedString(@"原画") : BJLLocalizedString(@"高清");
                 return YES;
             }];
    }

    // 大屏状态
    [self bjl_kvoMerge:@[BJLMakeProperty(self, isFullScreen),
        BJLMakeProperty(self, positionType)]
        filter:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            return value != oldValue;
        }
        observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self updateInfoViewHidden];
        }];

    // 切换主讲
    [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, currentPresenter)
        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
        filter:^BOOL(BJLUser *_Nullable now, BJLUser *_Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return (old // 默认主讲不提示
                    && now // 老师掉线不提示
                    && old != now
                    && ![now isSameUser:old]);
        }
        observer:^BOOL(BJLUser *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self updateInfoViewWithCurrentUser];
            return YES;
        }];

    // loading 状态
    [self bjl_kvo:BJLMakeProperty(self, mediaUser)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.mediaUser) {
                 [self remakeObservingForUser:self.mediaUser];
             }
             return BJLKeep;
         }];

    // 收到点赞
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveLikeForUserNumber:records:)
             observer:^BOOL(NSString *userNumber, NSDictionary<NSString *, NSNumber *> *records) {
                 bjl_strongify(self);
                 if ([self.user.number isEqualToString:userNumber]) {
                     NSInteger likeCount = [self.room.roomVM.likeList bjl_integerForKey:userNumber];
                     BOOL hideLikeButton = self.user.isTeacherOrAssistant || (self.room.loginUser.isStudent && !likeCount);
                     [self updateWithLikeCount:likeCount hidden:hideLikeButton];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, likeRecordsDidOverwrite:)
             observer:^BOOL {
                 bjl_strongify(self);
                 NSInteger likeCount = [self.room.roomVM.likeList bjl_integerForKey:self.user.number];
                 BOOL hideLikeButton = !self.user || self.user.isTeacherOrAssistant || (self.room.loginUser.isStudent && !likeCount);
                 [self updateWithLikeCount:likeCount hidden:hideLikeButton];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.onlineUsersVM, didRecieveUserCameraCover:userNumber:)
             observer:^BOOL(NSString *imageURLString, NSString *userNumber) {
                 bjl_strongify(self);
                 // 目前限制只有老师助教背景可以修改
                 if ([userNumber isEqualToString:self.user.number] && self.user.isTeacherOrAssistant) {
                     self.imageURLString = imageURLString;
                     [self updateVideoPlaceholderViewImage];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.onlineUsersVM, didRecieveUserStateUpdateWithUserNumber:audioState:videoState:)
             observer:^BOOL(NSString *userNumber, BJLUserMediaState audioState, BJLUserMediaState videoState) {
                 bjl_strongify(self);
                 if ([userNumber isEqualToString:self.user.number]) {
                     [self updateVideoPlaceholderViewImage];
                 }
                 return YES;
             }];
}

- (void)remakeObservingForUser:(BJLMediaUser *)mediaUser {
    [self.mediaUserObservation stopObserving];
    self.mediaUserObservation = nil;
    bjl_weakify(self);
    self.mediaUserObservation = [self bjl_kvo:BJLMakeProperty(self.mediaUser, isLoading)
                                     observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                                         bjl_strongify(self);
                                         [self updateLoadingViewHidden:!self.mediaUser.isLoading];
                                         return BJLKeep;
                                     }];
}

#pragma mark - action

- (void)sendLikeForCurrentUser {
    if (!self.room.roomVM.liveStarted) { return; }

    // !!!: [BJLAward allAwards]里面至少有一个, 当大于1的时候, 把图标换成钻石, 点击显示多种奖励
    if ([BJLAward allAwards].count > 1) {
        BJLMutableAwardsView *mutableAwardsView = [[BJLMutableAwardsView alloc] initWithRoom:self.room user:self.user];
        self.awardsViewController = ({
            UIViewController *viewController = [[UIViewController alloc] init];
            viewController.view.backgroundColor = [UIColor clearColor];
            viewController.modalPresentationStyle = UIModalPresentationPopover;
            viewController.preferredContentSize = mutableAwardsView.size;
            viewController.popoverPresentationController.backgroundColor = BJLTheme.toolboxBackgroundColor;
            viewController.popoverPresentationController.delegate = self;
            viewController.popoverPresentationController.sourceView = self;
            viewController.popoverPresentationController.sourceRect = CGRectMake(self.likeButton.center.x, self.likeButton.center.y, 1.0, 1.0);
            viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
            viewController;
        });

        [self.awardsViewController.view addSubview:mutableAwardsView];
        [mutableAwardsView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.awardsViewController.view.bjl_safeAreaLayoutGuide ?: self.awardsViewController.view);
        }];

        bjl_weakify(self);
        [mutableAwardsView setAwardKeyCallback:^(NSString *_Nonnull key) {
            bjl_strongify(self);
            [self.room.roomVM sendLikeForUserNumber:self.user.number key:key];
            [self hideAwardsViewController];
        }];

        [self.parentViewController presentViewController:self.awardsViewController animated:YES completion:nil];
    }
    else {
        [self.room.roomVM sendLikeForUserNumber:self.user.number];
    }
}

- (void)hideAwardsViewController {
    [self.awardsViewController bjl_dismissAnimated:YES completion:nil];
}

#pragma mark - <UIPopoverPresentationControllerDelegate>
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

- (void)updateParentViewController:(UIViewController *)parentViewController {
    self.parentViewController = parentViewController;
    if (self.awardsViewController) {
        [self hideAwardsViewController];
    }
}

#pragma mark - update

- (void)updateCurrentUserWithPlayingUsers:(NSArray<BJLMediaUser *> *)playingUsers {
    BOOL findCurrentUser = NO;
    for (BJLMediaUser *user in playingUsers) {
        if ([self.mediaUser.ID isEqualToString:user.ID]
            || (!self.mediaUser && [self.user.ID isEqualToString:user.ID])) {
            findCurrentUser = YES;
            if (!self.mediaUser || self.mediaUser != user || self.needUpdateView) {
                BOOL needUpdateView = [self needUpdateVideoViewWithMediaUser:user];
                if (self.needUpdateView) {
                    needUpdateView = YES;
                    self.needUpdateView = NO;
                }
                self.mediaUser = user;
                [self updateCurrentUserAndUpdateViewIfNeed:needUpdateView];
            }
            break;
        }
    }
    // 处理用户列表置空时，仍需要显示的 mediaInfoView 的状态不正确的情况，目前一般是主讲人的 mediaInfoView 在主讲人停止推流后仍然需要显示
    if (!findCurrentUser && !self.recording && self.mediaUser) {
        self.mediaUser = nil;
        [self updateCurrentUserAndUpdateViewIfNeed:YES];
    }
}

- (void)updateCurrentUserAndUpdateViewIfNeed:(BOOL)needUpdateView {
    if (needUpdateView) {
        [self.videoView removeFromSuperview];
        self.videoView = nil;
        if (self.recording) {
            self.videoView = self.room.recordingView;
            self.ratio = self.room.recordingVM.inputVideoAspectRatio;
        }
        else {
            self.videoView = [self.room.playingVM playingViewForUserWithID:self.mediaUser.ID mediaSource:self.mediaUser.mediaSource];
            self.ratio = [self.room.playingVM playingViewAspectRatioForUserWithID:self.mediaUser.ID mediaSource:self.mediaUser.mediaSource];
            [self.room.playingVM updateWatermarkWithUser:self.mediaUser size:CGSizeMake(self.ratio, 1.0) videoContentMode:BJLVideoContentMode_aspectFit];
            [self updateCloseVideoPlaceholderHidden:[self isVideoPlayingUser]];
        }
        if (self.videoView) {
            if (self.videoView.superview != self.containerView) {
                [self.videoView removeFromSuperview];
            }
            [self.containerView insertSubview:self.videoView atIndex:0];
        }
    }
    [self updateInfoViewHidden];
    [self updateInfoViewWithCurrentUser];
    // 未添加到当前视图不处理
    if (!self.videoView || self.videoView.superview != self.containerView) {
        return;
    }
    // update
    [self.videoView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.containerView);
    }];
}

- (void)updateInfoViewHidden {
    if (!self.isSellUI) {
        self.likeButton.hidden = self.likeButtonHidden || self.positionType == BJLScPositionType_major || self.isFullScreen;
        self.infoView.hidden = self.positionType == BJLScPositionType_major || self.isFullScreen;
    }
    else {
        self.likeButton.hidden = YES;
    }
}

- (void)updateInfoViewWithCurrentUser {
    self.nameLabel.text = [self getShowingTitleOfUser:self.user];
    [self updateVideoPlaceholderViewImage];
}

- (void)updateCloseVideoPlaceholderHidden:(BOOL)hidden {
    [self updateVideoPlaceholderViewImage];
}

- (void)updateVideoPlaceholderViewImage {
    BOOL videoOn = self.recording ? self.room.recordingVM.recordingVideo : self.mediaUser.videoOn;
    BOOL closeVideo = !videoOn;
    if (!self.recording) {
        closeVideo = ![self isVideoPlayingUser];
    }
    BOOL hidden = videoOn && !closeVideo;
    BJLUserMediaState videoState = self.mediaUser ? self.mediaUser.videoState : self.user.videoState;

    NSString *imageName = @"bjl_sc_user_video_off";
    if (!videoOn) {
        if (videoState == BJLUserMediaState_backstage) {
            imageName = @"bjl_sc_user_enterbackground";
        }
        else if (videoState != BJLUserMediaState_available) {
            imageName = @"bjl_sc_user_mediaState_unavaliable";
        }
        else {
            imageName = @"bjl_sc_user_video_off";
        }
    }
    else if (closeVideo) {
        imageName = @"bjl_sc_user_audioOnly";
    }
    UIImage *placeholder = [UIImage bjl_imageNamed:imageName];

    NSString *tip = BJLLocalizedString(@"已关闭摄像头");
    if (videoState != BJLUserMediaState_available) {
        tip = [BJLUser descriptionWithUserMediaState:videoState];
    }

    if (self.imageURLString.length) {
        [self.videoPlaceholderView updateImageWithURLString:self.imageURLString placeholder:nil];
    }
    else {
        [self.videoPlaceholderView updateImage:placeholder];
    }
    [self.videoPlaceholderView updateTip:tip font:[UIFont systemFontOfSize:self.isFullScreen ? 24.0 : 12.0]];
    self.videoPlaceholderView.hidden = hidden;
}

- (void)updateWithLikeCount:(NSInteger)count hidden:(BOOL)hidden {
    self.likeButtonHidden = hidden;
    [self.likeButton setTitle:count ? [NSString stringWithFormat:@"%ld", (long)count] : nil forState:UIControlStateNormal];
    self.likeButton.hidden = hidden || self.positionType == BJLScPositionType_major || self.isFullScreen || self.isSellUI;
}

#pragma mark - loading

- (void)updateLoadingViewHidden:(BOOL)hidden {
    if (!self.videoLoadingView) {
        return;
    }
    if (self.videoLoadingView.hidden == hidden) {
        return;
    }
    if (![self isVideoPlayingUser]) {
        return;
    }
    self.videoLoadingView.hidden = hidden;
    if (hidden) {
        self.animating = NO;
        self.needStopAnimation = YES;
        [self stopLoadingAnimation];
    }
    else {
        if (self.animating || !self.needStopAnimation) {
            return;
        }
        self.needStopAnimation = NO;
        bjl_weakify(self);
        [self startLoadingAnimationWithAngle:0 completion:^{
            bjl_strongify(self);
            if (!self.needStopAnimation) {
                self.animating = YES;
            }
        }];
    }
}

- (void)startLoadingAnimationWithAngle:(NSInteger)angle completion:(void (^__nullable)(void))completion {
    NSInteger nextAngle = angle + 20;
    if (nextAngle > 360) {
        nextAngle = 0;
    }
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    // 预期不会出现顺序调用，后调用的先回调 completion
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.videoLoadingImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        if (self.animating && self.mediaUser.isLoading) {
            [self startLoadingAnimationWithAngle:nextAngle completion:nil];
        }
        else {
            [self stopLoadingAnimation];
        }
    }];
}

- (void)stopLoadingAnimation {
    self.animating = NO;
    self.videoLoadingView.hidden = YES;
    [self.videoLoadingView.layer removeAllAnimations];
    [self.videoLoadingImageView.layer removeAllAnimations];
    self.videoLoadingImageView.transform = CGAffineTransformIdentity;
}

#pragma mark - getter

/**
 老师用户永远展示备注，优先展示标签，没有标签则展示 (老师)
 助教为主讲时，展示(主讲), 否则展示标签,没有标签就不展示
 */
- (NSString *)getShowingTitleOfUser:(__kindof BJLUser *)user {
    NSString *roleName = [self roleNameOfUser:user];
    if (roleName) {
        return [NSString stringWithFormat:@"%@(%@)", user.displayName, roleName];
    }
    return user.displayName;
}

- (NSString *_Nullable)roleNameOfUser:(__kindof BJLUser *)user {
    BJLFeatureConfig *config = self.room.featureConfig;
    if (user.isTeacher) {
        return config.teacherLabel ?: BJLLocalizedString(@"老师");
    }
    else if (user.isAssistant && [user isSameCameraUser:self.room.onlineUsersVM.currentPresenter]) {
        return BJLLocalizedString(@"主讲");
    }
    else if (user.isAssistant && ![user isSameCameraUser:self.room.onlineUsersVM.currentPresenter]) {
        return (config.assistantLabel) ?: nil;
    }
    return nil;
}

// 是否需要更新 user 数据
- (BOOL)needUpdateWithMediaUser:(BJLMediaUser *)mediaUser {
    // 如果当前是未开音视频的主摄像头用户，更新数据
    if (!self.mediaUser) {
        return YES;
    }
    if ([self.mediaUser.mediaID isEqualToString:mediaUser.mediaID]
        && self.mediaUser.videoOn == mediaUser.videoOn
        && self.mediaUser.audioOn == mediaUser.audioOn
        && [self.mediaUser.name isEqualToString:mediaUser.name]) {
        return NO;
    }
    return YES;
}

- (BOOL)needUpdateVideoViewWithMediaUser:(BJLMediaUser *)mediaUser {
    // 如果当前是未开音视频的主摄像头用户，更新数据
    if (!self.mediaUser) {
        return YES;
    }
    if ([self.mediaUser.mediaID isEqualToString:mediaUser.mediaID]
        && self.mediaUser.mediaSource == mediaUser.mediaSource
        && self.mediaUser.videoOn == mediaUser.videoOn) {
        return NO;
    }
    return YES;
}

- (BOOL)isSameCameraTypeUser:(BJLMediaUser *)user {
    if (self.recording) {
        return [self.user.ID isEqualToString:user.ID];
    }
    else {
        return [self.user.ID isEqualToString:user.ID] && (self.mediaUser.cameraType == user.cameraType);
    }
}

- (BOOL)isVideoPlayingUser {
    if (!self.mediaUser.videoOn) {
        return NO;
    }
    // 判断是否是正在播放视频的用户必须存在 mediaUser
    for (BJLMediaUser *user in [self.room.playingVM.videoPlayingUsers copy]) {
        if ([user isSameMediaUser:self.mediaUser]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)enableSwitchMixedVideoDefinition {
    BOOL enableSwitchMixedVideoDefinition = self.room.featureConfig.enableSwitchMixedVideoDefinition;
    if (enableSwitchMixedVideoDefinition) {
        enableSwitchMixedVideoDefinition = self.room.playingVM.playMixedVideo || self.room.roomInfo.isMockLive || self.room.roomInfo.isPushLive;
    }
    return enableSwitchMixedVideoDefinition;
}

- (BOOL)is1V1Class {
    return self.room.roomInfo.roomType == BJLRoomType_1v1Class;
}

- (void)setIsSellUI:(BOOL)isSellUI {
    _isSellUI = isSellUI;

    self.likeButton.hidden = isSellUI;

    if (self.nameLabel.superview) {
        if (!self.isSellUI) {
            [self.nameLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.equalTo(self.infoView).offset(8.0);
                make.top.bottom.equalTo(self.infoView);
                make.right.lessThanOrEqualTo(self.infoView);
            }];
        }
        else {
            [self.nameLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.top.bottom.equalTo(self.infoView);
                make.centerX.equalTo(self.infoView);
                make.left.greaterThanOrEqualTo(self.infoView);
                make.right.lessThanOrEqualTo(self.infoView);
            }];
        }
    }
}
@end
