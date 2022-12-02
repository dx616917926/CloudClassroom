//
//  BJPRoomViewController+ui.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/11.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPRoomViewController+ui.h"
#import "BJPRoomViewController+protected.h"

@implementation BJPRoomViewController (ui)

#pragma mark - subViews

// 默认创建普通大班课的布局
- (void)setupSubviews {
    [self bjl_addChildViewController:self.room.blackboardPPTViewController];
    [self.fullScreenContainerView replaceContentWithPPTView:self.room.blackboardPPTViewController.view];

    // 动态PPT加载失败时自动切静态
    bjl_weakify(self);
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

    // fullScreenContainerView: 默认显示 根据playbackOptions
    [self.view addSubview:self.fullScreenContainerView];

    // play back control
    [self.view addSubview:self.playbackControlView];
    [self.playbackControlView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.bottom.right.equalTo(self.fullScreenContainerView);
    }];

    // messageView
    self.messageViewContrller = [[BJPChatMessageViewController alloc] init];
    [self.messageViewContrller setupObserversWithRoom:self.room];
    [self bjl_addChildViewController:self.messageViewContrller superview:self.view];

    // userlist
    self.usersViewController = [[BJPUsersViewController alloc] init];
    [self.usersViewController setupObserversWithRoom:self.room];

    // catalogue
    self.catalogueViewController = [[BJPCatalogueViewController alloc] init];
    [self.catalogueViewController setupObserversWithRoom:self.room];

    // thumbnailContainerView: 默认显示播放器视图
    [self.view addSubview:self.thumbnailContainerView];
    [self.thumbnailContainerView replaceContentWithPlayerView:self.room.playerManager.playerView ratio:self.videoRatio];

    // video off image view
    [self.room.playerManager.playerView addSubview:self.audioOnlyImageView];
    [self.audioOnlyImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.room.playerManager.playerView);
    }];

    [self.view addSubview:self.cloudVideoLayer];
    [self.cloudVideoLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    // media setting view
    [self.view addSubview:self.mediaSettingView];
    [self.mediaSettingView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.fullScreenContainerView);
    }];

    // contols view
    [self.view addSubview:self.controlLayer];
    [self.controlLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    // pptcatalogue 底部不能遮盖住进度条
    [self.view addSubview:self.pptcatalogueLayer];
    [self.pptcatalogueLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(-BJPButtonSizeL);
    }];

    [self bjl_addChildViewController:self.catalogueViewController superview:self.pptcatalogueLayer];
    [self.catalogueViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.pptcatalogueLayer);
        make.right.equalTo(self.pptcatalogueLayer.bjl_safeAreaLayoutGuide ?: self.pptcatalogueLayer);
        make.bottom.equalTo(self.pptcatalogueLayer);
        make.width.equalTo(@(280.0));
    }];

    // overlayViewController
    [self bjl_addChildViewController:self.overlayViewController superview:self.view];
    [self.overlayViewController.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // quiz and question
    [self.view addSubview:self.quizContainLayer];
    [self.quizContainLayer bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // lamp
    [self.view addSubview:self.lampView];
    [self.lampView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - public

// 首次触发时不能获取到正确班型
- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal {
    CGFloat statusBarHeight = MAX(20.0, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));

    CGSize thumbnailSize = CGSizeMake(100.0, 76.0);

    BOOL is1v1WebRTC = (self.room.playbackInfo.roomType == BJVRoomType_1v1Class && self.room.playbackInfo.recordType == BJRecordType_CompositeVideo);
    BOOL isInteractiveClass1v1SignalingRecord = self.room.playbackInfo.isInteractiveClass1v1SignalingRecord;

    if (is1v1WebRTC || isInteractiveClass1v1SignalingRecord) {
        //基础1v1改成了16：9，并且是把两个人的视频窗口垂直叠加。所以视频比例如下
        thumbnailSize = CGSizeMake(178.0, 100.0 * 2);
    }
    // fullScreenContainerView
    [self.fullScreenContainerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        if (isHorizontal) {
            make.edges.equalTo(self.view);
        }
        else {
            make.top.equalTo(self.view).offset(statusBarHeight);
            make.left.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);

            if (!(is1v1WebRTC || isInteractiveClass1v1SignalingRecord)) {
                make.height.equalTo(self.fullScreenContainerView.bjl_width).multipliedBy(3.0 / 4.0);
            }
            else {
                make.height.equalTo(self.fullScreenContainerView.bjl_width).multipliedBy(9.0 / 16.0);
            }
        }
    }];

    // play control view
    [self.playbackControlView updateConstraintsForHorizontal:isHorizontal];

    if (!self.disablePortrait) {
        // messageView
        [self.messageViewContrller.view bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            if (isHorizontal) {
                make.top.equalTo(self.fullScreenContainerView).offset(statusBarHeight + thumbnailSize.height + BJPViewSpaceS);
                make.right.equalTo(self.view.bjl_centerX);
                make.bottom.equalTo(self.playbackControlView.bjl_safeAreaLayoutGuide ?: self.playbackControlView).offset(-BJPButtonSizeL - BJPButtonSizeM - BJPViewSpaceM);
            }
            else {
                make.top.equalTo(self.fullScreenContainerView.bjl_bottom).offset(BJPViewSpaceS).priorityHigh();
                make.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(-thumbnailSize.width - BJPViewSpaceS);
                make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            }
            make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        }];

        // thumbnailContainerView
        [self.thumbnailContainerView setTouchMoveEnable:isHorizontal];
        [self.thumbnailContainerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            if (isHorizontal) {
                make.top.equalTo(self.fullScreenContainerView).offset(statusBarHeight);
                make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            }
            else {
                make.top.equalTo(self.fullScreenContainerView.bjl_bottom);
                make.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
            }
            make.size.equal.sizeOffset(thumbnailSize);
        }];

        // controls
        [self.controlView updateConstraintsForHorizontal:isHorizontal];
    }

    // overlayViewController
    [self.overlayViewController updateConstraintsForHorizontal:isHorizontal];

    if (!isHorizontal) {
        self.pptcatalogueLayer.hidden = YES;
    }

    // 用户在移动云插播view的时候，可能会在竖屏上移动到特定位置，在翻转到横屏后，可能到屏幕外了，这里需要重置位置
    [self resetCloudVideoWrapperViewPosition];
}

- (void)updatePlayerViewConstraint {
    UIView *playerView = self.room.playerManager.playerView;
    UIView *superview = playerView.superview;
    CGFloat ratio = self.videoRatio;
    if (!superview) {
        return;
    }
    [playerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        if (ratio > 0) {
            make.edges.equalTo(superview).priorityHigh();
            make.center.equalTo(superview);
            make.top.left.greaterThanOrEqualTo(superview);
            make.bottom.right.lessThanOrEqualTo(superview);
            make.width.equalTo(playerView.bjl_height).multipliedBy(ratio);
        }
        else {
            make.edges.equalTo(superview);
        }
    }];
}

- (void)switchViewToFullScreen:(UIView *)view {
    UIView *pptView = self.room.blackboardPPTViewController.view;
    UIView *playerView = self.room.playerManager.playerView;
    if (view == pptView) {
        [self.thumbnailContainerView replaceContentWithPlayerView:playerView ratio:self.videoRatio];
        [self.fullScreenContainerView replaceContentWithPPTView:pptView];
    }
    else if (view == playerView) {
        [self.thumbnailContainerView replaceContentWithPPTView:pptView];
        [self.fullScreenContainerView replaceContentWithPlayerView:playerView ratio:self.videoRatio];
    }
}

- (void)closeThumbnailViewWithContentView:(UIView *)contentView {
    self.thumbnailContainerView.hidden = YES;
    self.controlView.thumbnailButton.selected = (contentView != self.room.playerManager.playerView);
    self.controlView.thumbnailButton.hidden = self.playbackControlView.controlsHidden;
}

- (void)cleanOverlayViews {
    self.mediaSettingView.hidden = YES;
    [self.playbackControlView hideReloadView];
}

- (void)updateAudioOnlyImageViewHidden {
    if (self.room.playerManager.currDefinitionInfo.isAudio) {
        // 播放纯音频时，显示占位图
        self.audioOnlyImageView.hidden = NO;
        return;
    }

    if (self.room.playerManager.playInfo.recordType == BJRecordType_Mixed
        || self.room.playerManager.playInfo.recordType == BJRecordType_CompositeVideo) {
        // 合流视频 和 录制视频 一直不显示占位图
        self.audioOnlyImageView.hidden = YES;
        return;
    }

    // 播放视频时，根据老师是否打开摄像头来显示占位图
    self.audioOnlyImageView.hidden = self.room.onlineUsersVM.currentPresenter.videoOn || self.room.roomVM.isMediaPlaying || self.room.roomVM.isDesktopSharing || self.room.playbackInfo.isInteractiveClass1v1SignalingRecord;
}

- (void)updateRateSettingViewAndShow:(BOOL)show {
    NSMutableArray *rateOptions = [NSMutableArray array];
    NSUInteger selectIndex = 0;
    for (int i = 0; i < self.rateList.count; i++) {
        CGFloat rate = [[self.rateList objectAtIndex:i] bjl_floatValue];
        NSString *optionKey = [NSString stringWithFormat:@"%.1fx", rate];
        [rateOptions addObject:optionKey ?: @""];
        if (fabs(rate - self.room.playerManager.rate) < 0.1) {
            selectIndex = i;
        }
    }

    if (show) {
        [self.mediaSettingView showWithSettingOptons:rateOptions
                                                type:BJPMediaSettingType_Rate
                                         selectIndex:selectIndex];
    }
    else {
        [self.mediaSettingView updateWithSettingOptons:rateOptions
                                                  type:BJPMediaSettingType_Rate
                                           selectIndex:selectIndex];
    }
}

- (void)updateDefinitionSettingViewAndShow:(BOOL)show {
    NSArray *definitionList = self.room.playerManager.playInfo.definitionList;
    BJVDefinitionInfo *currDefinitionInfo = self.room.playerManager.currDefinitionInfo;
    NSMutableArray *definitionOptions = [NSMutableArray array];
    NSUInteger selectIndex = 0;
    for (int i = 0; i < definitionList.count; i++) {
        BJVDefinitionInfo *definitionInfo = [[definitionList bjl_objectAtIndex:i] bjl_as:[BJVDefinitionInfo class]];
        [definitionOptions addObject:definitionInfo.definitionName ?: @""];
        if ([definitionInfo.definitionKey isEqualToString:currDefinitionInfo.definitionKey]) {
            selectIndex = i;
        }
    }

    if (show) {
        [self.mediaSettingView showWithSettingOptons:definitionOptions
                                                type:BJPMediaSettingType_Definition
                                         selectIndex:selectIndex];
    }
    else {
        [self.mediaSettingView updateWithSettingOptons:definitionOptions
                                                  type:BJPMediaSettingType_Definition
                                           selectIndex:selectIndex];
    }
}

// 获取到配置信息，调整布局
- (void)updateConstraintsWhenEnterRoomSuccess {
    self.disablePortrait = self.room && self.room.isInteractiveClass;

    // 小班课 1v1 信令录制，允许竖屏
    if (self.room.playbackInfo.isInteractiveClass1v1SignalingRecord) {
        self.disablePortrait = NO;
    }

    if (self.disablePortrait) {
        BOOL isHorizontal = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
        if (!isHorizontal) {
            UIDevice *device = [UIDevice currentDevice];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([device respondsToSelector:@selector(setOrientation:)]) {
#pragma clang diagnostic pop
                [device setValue:@(UIDeviceOrientationPortraitUpsideDown)
                          forKey:@"orientation"];
                [device setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
            }
        }

        // fullScreenContainerView
        [self.fullScreenContainerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [self.fullScreenContainerView replaceContentWithPlayerView:self.room.playerManager.playerView ratio:self.videoRatio];

        self.thumbnailContainerView.hidden = YES;

        if (self.messageViewContrller) {
            [self.messageViewContrller bjl_removeFromParentViewControllerAndSuperiew];
        }

        if (self.room.blackboardPPTViewController) {
            [self.room.blackboardPPTViewController bjl_removeFromParentViewControllerAndSuperiew];
        }

        // play control view
        [self.playbackControlView updateViewForInteractiveClass];

        // overlayViewController
        [self.overlayViewController updateConstraintsForHorizontal:YES];
    }
    else {
        self.controlView = [[BJPControlView alloc] initWithRoom:self.room];
        [self setControlViewCallback];
        [self.controlLayer addSubview:self.controlView];
        [self.controlView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.controlLayer.bjl_safeAreaLayoutGuide ?: self.controlLayer);
        }];

        // question
        if (self.room.playbackInfo.enableQuestion) {
            self.questionViewController = [[BJPQuestionViewController alloc] initWithRoom:self.room];
            bjl_weakify(self);
            [self.questionViewController setShowRedDotCallback:^(BOOL show) {
                bjl_strongify(self);
                self.controlView.questionRedDot.hidden = !show;
            }];
        }

        // notice
        self.noticeViewController = [[BJPNoticeViewController alloc] initWithRoom:self.room];
        bjl_weakify(self);
        [self.noticeViewController setNoticeLinkCallback:^(NSURL *_Nullable linkURL) {
            bjl_strongify(self);
            if (self.noticeLinkCallback) {
                self.noticeLinkCallback(linkURL);
            }
        }];

        [self.noticeViewController setNoticeChangeCallback:^{
            bjl_strongify(self);
            [self.overlayViewController showWithChildViewController:self.noticeViewController title:BJLLocalizedString(@"公告")];
        }];

        BOOL isShowUserList = self.room.isLocalVideo ? self.room.downloadItem.playInfo.isShowUserList : self.room.playbackInfo.isShowUserList;
        BOOL isShowChatList = self.room.isLocalVideo ? self.room.downloadItem.playInfo.isShowChatList : self.room.playbackInfo.isShowChatList;

        // user
        if (!isShowUserList) {
            [self.usersViewController bjl_removeFromParentViewControllerAndSuperiew];
            self.usersViewController = nil;
        }

        // chat
        if (!isShowChatList) {
            [self.messageViewContrller bjl_removeFromParentViewControllerAndSuperiew];
            self.messageViewContrller = nil;
        }
    }

    BOOL isHorizontal = BJPIsHorizontalUI(self);
    [self updateConstraintsForHorizontal:isHorizontal];

    //纯视频回放: 默认横屏展示视频，并隐藏PPT与PPT入口
    if (self.room.playbackInfo.layoutTemplate == BJVTemplateVideoOnly) {
        [self switchViewToFullScreen:self.room.playerManager.playerView];
        self.thumbnailContainerView.hidden = YES;
        self.controlView.thumbnailButton.hidden = YES;
        [self setOrientationAsHorizontal:YES];
    }
    //视频墙回放: 点开回放默认以视频为主，隐藏PPT，可点击展开PPT，并支持PPT与视频切换
    else if (self.room.playbackInfo.layoutTemplate == BJVTemplateLiveWall) {
        [self switchViewToFullScreen:self.room.playerManager.playerView];
        [self closeThumbnailViewWithContentView:self.room.blackboardPPTViewController.view];
    }
}

- (UIPanGestureRecognizer *)addPanGestureToView:(UIView *)view movableItemView:(UIView *)movableItemView {
    if (view == nil || movableItemView == nil) { return nil; }

    bjl_weakify(movableItemView);
    __block CGPoint originPoint = CGPointZero;
    __block CGPoint movingTranslation = CGPointZero;
    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(movableItemView);

        if (gesture.state == UIGestureRecognizerStateBegan) {
            originPoint = movableItemView.frame.origin;
            [gesture setTranslation:CGPointMake(0.0, 0.0) inView:movableItemView];
            movingTranslation = [gesture translationInView:movableItemView];
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            movingTranslation = [gesture translationInView:movableItemView];
        }
        else {
            return;
        }

        CGRect frame = bjl_set(movableItemView.frame, {
            set.origin = CGPointMake(originPoint.x + movingTranslation.x,
                originPoint.y + movingTranslation.y);
        }), superBounds = movableItemView.superview.bounds;
        if (CGRectGetMinX(frame) < 0.0) {
            frame.origin.x = 0.0;
        }
        if (CGRectGetMinY(frame) < 0.0) {
            frame.origin.y = 0.0;
        }
        if (CGRectGetMaxX(frame) > CGRectGetMaxX(superBounds)) {
            frame.origin.x = CGRectGetMaxX(superBounds) - CGRectGetWidth(frame);
        }
        if (CGRectGetMaxY(frame) > CGRectGetMaxY(superBounds)) {
            frame.origin.y = CGRectGetMaxY(superBounds) - CGRectGetHeight(frame);
        }

        [movableItemView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.equalTo(@(frame.origin.x));
            make.top.equalTo(@(frame.origin.y));
            make.width.equalTo(@(frame.size.width));
            make.height.equalTo(@(frame.size.height));
        }];
    }];

    [view addGestureRecognizer:pan];

    return pan;
}

- (void)resetCloudVideoWrapperViewPosition {
    [self.cloudVideoWrapperView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.cloudVideoLayer);
        CGFloat vw = self.room.roomVM.cloudVideoPlayer.videoSize.width;
        CGFloat vh = self.room.roomVM.cloudVideoPlayer.videoSize.height;
        BOOL validSize = vw > 0.0 && vh > 0.0;
        CGFloat ratio = validSize ? (vw / vh) : (16.0 / 9.0);
        make.width.equalTo(self.cloudVideoLayer).multipliedBy(0.5).priority(UILayoutPriorityRequired - 1);
        make.height.equalTo(self.cloudVideoWrapperView.bjl_width).dividedBy(ratio);
        make.height.lessThanOrEqualTo(self.cloudVideoLayer).multipliedBy(0.7);
    }];
}
@end
