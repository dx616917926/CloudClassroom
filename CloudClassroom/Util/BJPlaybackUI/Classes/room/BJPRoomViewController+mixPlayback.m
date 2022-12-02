//
//  BJPRoomViewController+mixPlayback.m
//  BJPlaybackUI
//
//  Created by Ney on 8/28/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJPRoomViewController+mixPlayback.h"
#import "BJPRoomViewController+protected.h"
#import "BJPRoomViewController+observer.h"

@implementation BJPRoomViewController (mixPlayback)
- (void)setupSubviewsForMixPlaybackUI {
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

    // overlayViewController
    [self bjl_addChildViewController:self.overlayViewController superview:self.view];
    [self.overlayViewController.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // notice
    self.noticeViewController = [[BJPNoticeViewController alloc] initWithRoom:self.room];
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

- (void)updateMixPlaybackUIForNewSlice {
    if (self.controlView) {
        [self.controlView removeFromSuperview];
        self.controlView = nil;
    }
    self.controlView = [[BJPControlView alloc] initWithRoom:self.room];
    [self setControlViewCallback];
    [self.controlLayer addSubview:self.controlView];
    [self.controlView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.controlLayer.bjl_safeAreaLayoutGuide ?: self.controlLayer);
    }];

    //message
    BOOL isShowChatList = self.room.isLocalVideo ? self.room.downloadItem.playInfo.isShowChatList : self.room.playbackInfo.isShowChatList;
    if (!isShowChatList) {
        [self.messageViewContrller bjl_removeFromParentViewControllerAndSuperiew];
        self.messageViewContrller = nil;
    }
    else {
        if (self.messageViewContrller) {
            [self.messageViewContrller bjl_removeFromParentViewControllerAndSuperiew];
            self.messageViewContrller = nil;
        }
        self.messageViewContrller = [[BJPChatMessageViewController alloc] init];
        [self.messageViewContrller setupObserversWithRoom:self.room];
        [self bjl_addChildViewController:self.messageViewContrller superview:self.view];
    }

    // user
    [self.usersViewController bjl_removeFromParentViewControllerAndSuperiew];
    self.usersViewController = nil;

    // question
    if (self.questionViewController) {
        [self.questionViewController bjl_removeFromParentViewControllerAndSuperiew];
        self.questionViewController = nil;
    }

    [self updateLamp];

    [self.view bringSubviewToFront:self.thumbnailContainerView];
    [self.view bringSubviewToFront:self.mediaSettingView];
    [self.view bringSubviewToFront:self.controlLayer];
    [self.view bringSubviewToFront:self.pptcatalogueLayer];
    [self.view bringSubviewToFront:self.overlayViewController.view];
    [self.view bringSubviewToFront:self.quizContainLayer];
    [self.view bringSubviewToFront:self.lampView];

    BOOL isHorizontal = BJPIsHorizontalUI(self);
    [self updateConstraintsForHorizontal:isHorizontal];
}
@end
