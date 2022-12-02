//
//  BJLScRoomViewController+actions.m
//  BJLiveUI
//
//  Created by 凡义 on 2019/9/20.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <SafariServices/SafariServices.h>

#import "BJLScRoomViewController+actions.h"
#import "BJLScRoomViewController+private.h"
#import "BJLScImageViewController.h"

@implementation BJLScRoomViewController (actions)

- (void)makeActionsOnViewDidLoad {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    bjl_weakify(self);

#pragma mark - topBar

    [self.topBarViewController setExitCallback:^{
        bjl_strongify(self);
        [self askToExit];
    }];

    [self.topBarViewController setShowSettingCallback:^{
        bjl_strongify(self);
        [self.settingsViewController setShowHandWritingBoardViewCallback:^{
            bjl_strongify(self);
            [self.room.drawingVM checkBluetoothAvailable:^(BOOL available) {
                bjl_strongify(self);
                if (!available) {
                    [self showOpenBluetoothView];
                    return;
                }
                if (self.room.drawingVM.connectedHandWritingBoard) {
                    [self showHandWritingBoardViewController];
                }
                else {
                    [self updateHandWritingBoardConnectState:YES];
                }
            }];
        }];

        [self.settingsViewController setCloseCallback:^{
            bjl_strongify(self);
            [self.overlayViewController hide];
        }];

        [self.overlayViewController showWithContentViewController:self.settingsViewController contentView:nil];
        [self.settingsViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.center.equalTo(self.overlayViewController.view);
            make.width.equalTo(@(520));
            make.height.equalTo(iPhone ? @(300) : @(360));
        }];
    }];

#pragma mark -

    [self.handWritingBoardViewController setConnectFailedCallback:^{
        bjl_strongify(self);
        BJLPopoverViewController *viewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLHandWritingBoardConnectFailed];
        [viewController setConfirmCallback:^{
            bjl_strongify(self);
            [self showHandWritingBoardViewController];
        }];
        [self bjl_addChildViewController:viewController superview:self.popoversLayer];
        [viewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.popoversLayer);
        }];
    }];

    [self.handWritingBoardViewController setDormantCallback:^{
        bjl_strongify(self);
        [BJLProgressHUD bjl_showHUDForText:BJLLocalizedString(@"请按外接手写板上的电源按钮唤醒该设备") superview:self.view animated:YES];
    }];

#pragma mark - videosViewController

    if (self.videosViewController) {
        [self.videosViewController setReplaceMajorWindowCallback:^(BJLScMediaInfoView *_Nullable mediaInfoView, NSInteger index, BJLScWindowType majorWindowType, BOOL recording) {
            bjl_strongify(self);

            // 如果支持同时显示 PPT 和老师辅助摄像头，特殊处理
            BJLScMediaInfoView *teacherMediaInfoView = (mediaInfoView == self.teacherExtraMediaInfoView) && !self.showTeacherExtraMediaInfoViewCoverPPT ? nil : self.teacherExtraMediaInfoView;
            if (majorWindowType == BJLScWindowType_userVideo) {
                // 预期将大屏替换成用户视频
                switch (self.majorWindowType) {
                    case BJLScWindowType_ppt:
                        // 大屏为 PPT 或者老师辅助摄像头
                        [self.videosViewController replaceMajorContentViewAtIndex:index recording:recording teacherExtraMediaInfoView:teacherMediaInfoView];
                        break;

                    case BJLScWindowType_userVideo:
                        // 大屏为用户视频，此时 PPT 或者老师辅助摄像头在视频列表区域
                        [self.videosViewController replaceMajorContentViewAtIndex:index recording:recording teacherExtraMediaInfoView:teacherMediaInfoView];
                        break;

                    case BJLScWindowType_teacherVideo:
                        // 大屏为老师视频，先把老师替换到小屏，把小屏 PPT 或者老师辅助摄像头放到视频列表
                        [self replaceMinorContentViewWithTeacherMediaInfoView];
                        [self.videosViewController replaceMajorContentViewAtIndex:index recording:recording teacherExtraMediaInfoView:teacherMediaInfoView];
                        break;

                    default:
                        break;
                }
                [self replaceMajorContentViewWithUserMediaInfoView:mediaInfoView];
            }
            else if (majorWindowType == BJLScWindowType_ppt) {
                // 收回 PPT 或者老师辅助摄像头
                [self.videosViewController replaceMajorContentViewAtIndex:index recording:recording teacherExtraMediaInfoView:self.showTeacherExtraMediaInfoViewCoverPPT ? nil : teacherMediaInfoView];
                [self replaceMajorContentViewWithPPTView];
            }
        }];

        [self.videosViewController setUpdateVideoCallback:^(BJLMediaUser *_Nonnull user, BOOL on) {
            bjl_strongify(self);
            [self updateAutoPlayVideoBlacklist:user add:on];
        }];

        [self.videosViewController setResetPPTCallback:^{
            bjl_strongify(self);
            [self replaceMajorContentViewWithPPTView];
        }];

        // 由于视频消失，需要重置位置
        [self.videosViewController setRestoreFullscreenOrMajorWindowCallback:^{
            bjl_strongify(self);
            // 如果全屏区域是用户视频，复原全屏
            if (self.fullscreenWindowType == BJLScWindowType_userVideo) {
                [self restoreCurrentFullscreenWindow];
            }
            // 重置视频列表
            if (self.videosViewController) {
                [self.videosViewController resetVideo];
            }
            // 复原 1v1
            if (self.secondMinorMediaInfoView) {
                [self replaceSecondMinorContentViewWithSecondMinorMediaInfoView];
            }
            // 将白板换到大屏位置
            [self replaceMajorContentViewWithPPTView];
        }];
    }

#pragma mark - documentToolView

    [self.toolViewController setShowCoursewareCallback:^{
        bjl_strongify(self);

        [self bjl_addChildViewController:self.pptManagerViewController superview:self.fullscreenLayer];
        [self.pptManagerViewController.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.edges.equalTo(self.fullscreenLayer);
        }];
    }];

    [self.toolViewController setCountDownTimerCallback:^(BJLScToolViewController *_Nonnull vc) {
        bjl_strongify(self);
        [self.countDownManager showCountDownEditViewController];
    }];

    [self.toolViewController setQuestionAnswerCallback:^(BJLScToolViewController *_Nonnull vc) {
        bjl_strongify(self);
        [self.questionAnswerManager openQuestionAnswer];
    }];

    [self.toolViewController setEnvelopeRainCallback:^(BJLScToolViewController *_Nonnull vc) {
        bjl_strongify(self);
        [self addCreateEnvelopeRainView];
    }];

    [self.toolViewController setRollCallCallback:^(BJLScToolViewController *_Nonnull vc) {
        bjl_strongify(self);
        [self showRollCallViewController];
    }];

    [self.toolViewController setQuestionResponderCallback:^(BJLScToolViewController *_Nonnull vc) {
        bjl_strongify(self);
        [self.questionResponderManager openQuestionResponder];
    }];

#pragma mark - overlay

    [self.overlayViewController setShowCallback:^{
        bjl_strongify(self);
        [self bjl_addChildViewController:self.overlayViewController superview:self.overlayView];
        [self.overlayViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.overlayView);
        }];
    }];

    [self.overlayViewController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
        bjl_strongify(self);
        if (viewController && [viewController isKindOfClass:[BJLNoticeEditViewController class]]) {
            if ([self.noticeEditViewController closeKeyboardIfNeeded]) {
                return YES;
            }
            return NO;
        }

        if (viewController && [viewController isKindOfClass:[BJLScQuestionInputViewController class]]) {
            [self.overlayViewController removeContentViewController];
            if (!iPhone) {
                [self.questionViewController.view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                    make.center.equalTo(self.overlayViewController.view);
                    make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                    make.height.equalTo(self.overlayViewController.view).multipliedBy(0.75);
                }];

                [UIView animateWithDuration:0.3 animations:^{
                    [self.overlayViewController.view setNeedsLayout];
                    [self.overlayViewController.view layoutIfNeeded];
                }];
            }
            return NO;
        }
        return YES;
    }];

    [self.fullscreenOverlayViewController setShowCallback:^{
        bjl_strongify(self);
        [self bjl_addChildViewController:self.fullscreenOverlayViewController superview:self.fullscreenLayer];
        [self.fullscreenOverlayViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.fullscreenLayer);
        }];
        [self setNeedsStatusBarAppearanceUpdate];
        [self.toolViewController removeFromView:self.toolView addToSuperView:self.fullscreenLayer shouldFullScreen:YES];
    }];

    [self.fullscreenOverlayViewController setHideCallback:^{
        bjl_strongify(self);
        [self setNeedsStatusBarAppearanceUpdate];
        [self.toolViewController removeFromView:self.fullscreenLayer addToSuperView:self.toolView shouldFullScreen:NO];
    }];

#pragma mark - segmentViewController

    [self.segmentViewController setShowChatInputViewCallback:^(BOOL whisperChatUserExpend, BJLCommandLotteryBegin *_Nullable commandLottery) {
        bjl_strongify(self);
        [self showChatInputViewWithWhisperChatUserExpend:whisperChatUserExpend commandLottery:commandLottery];
    }];
    [self.segmentViewController setTapCommandLotteryCallback:^(BJLCommandLotteryBegin *_Nonnull commandLottery) {
        bjl_strongify(self);
        [self.chatInputViewController setContentWithText:commandLottery.command];
    }];

    [self.segmentViewController setShowImageViewCallback:^(BJLMessage *currentImageMessage, NSArray<BJLMessage *> *imageMessages, BOOL isStickyMessage) {
        bjl_strongify(self);
        [self showFullImageWithMessage:currentImageMessage
                         imageMessages:imageMessages
                       isStickyMessage:isStickyMessage];
    }];

    [self.segmentViewController setChangeChatStatusCallback:^(BJLChatStatus chatStatus, BJLUser *_Nullable targetUser) {
        bjl_strongify(self);
        [self.chatInputViewController updateChatStatus:chatStatus withTargetUser:targetUser];
    }];

    [self.segmentViewController setShowQuestionInputViewCallback:^(BJLQuestion *_Nonnull question) {
        bjl_strongify(self);
        [self.questionInputViewController updateWithQuestion:question];
        [self.overlayViewController showWithContentViewController:self.questionInputViewController contentView:nil];
        [self.questionInputViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.bottom.equalTo(self.overlayViewController.view);
        }];
    }];

    [self.segmentViewController setReceiveNewUnreadMessageCallback:^(NSArray<BJLMessage *> *_Nonnull unreadMessage) {
        bjl_strongify(self);
        // 使用飘窗展示的条件 <chatViewController 隐藏 & chatPanelViewController 显示>
        if (self.room.featureConfig.enableAutoVideoFullscreen && (self.fullscreenWindowType == BJLScWindowType_teacherVideo || self.fullscreenWindowType == BJLScWindowType_userVideo)) {
            for (BJLMessage *message in unreadMessage) {
                [self.controlsViewController.chatPanelViewController enqueueWithNewMessage:message];
            }
        }
    }];

    [self.segmentViewController setRevokeMessageCallback:^(NSString *_Nonnull messageID) {
        bjl_strongify(self);
        if (self.room.featureConfig.enableAutoVideoFullscreen && (self.fullscreenWindowType == BJLScWindowType_teacherVideo || self.fullscreenWindowType == BJLScWindowType_userVideo)) {
            [self.controlsViewController.chatPanelViewController revokeMessageWithMessageID:messageID];
        }
    }];

#pragma mark - controls

    [self.controlsViewController setHandUpCallback:^{
        bjl_strongify(self);
        [self touchHandUp];
    }];

    [self.controlsViewController setUpdateRecordingVideoCallback:^{
        bjl_strongify(self);
        BJLError *error = [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                                    recordingVideo:!self.room.recordingVM.recordingVideo];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        else {
            [self showProgressHUDWithText:(self.room.recordingVM.recordingVideo
                                                  ? BJLLocalizedString(@"摄像头已打开")
                                                  : BJLLocalizedString(@"摄像头已关闭"))];
        }
    }];

    [self.controlsViewController setUpdateRecordingAudioCallback:^{
        bjl_strongify(self);
        BJLError *error = [self.room.recordingVM setRecordingAudio:!self.room.recordingVM.recordingAudio
                                                    recordingVideo:self.room.recordingVM.recordingVideo];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        else {
            [self showProgressHUDWithText:(self.room.recordingVM.recordingAudio
                                                  ? BJLLocalizedString(@"麦克风已打开")
                                                  : BJLLocalizedString(@"麦克风已关闭"))];
        }
    }];

    [self.controlsViewController setUpdateHandWritingBoardCallback:^(BOOL connect) {
        bjl_strongify(self);
        [self.room.drawingVM checkBluetoothAvailable:^(BOOL available) {
            bjl_strongify(self);
            if (!available) {
                [self showOpenBluetoothView];
                return;
            }
            [self updateHandWritingBoardConnectState:connect];
        }];
    }];

    [self.controlsViewController setShowNoticeCallback:^{
        bjl_strongify(self);
        if (self.room.loginUser.isTeacherOrAssistant) {
            [self.overlayViewController showWithContentViewController:self.noticeEditViewController contentView:nil];
            [self.noticeEditViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.center.equalTo(self.overlayViewController.view);
                make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                make.height.equalTo(self.overlayViewController.view).multipliedBy(iPhone ? 0.83 : 0.38);
            }];
        }
        else {
            [self.overlayViewController showWithContentViewController:self.noticeViewController contentView:nil];
            [self.noticeViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.center.equalTo(self.overlayViewController.view);
                make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                make.height.equalTo(self.overlayViewController.view).multipliedBy(iPhone ? 0.83 : 0.38);
            }];
        }
    }];

    [self.noticeEditViewController setCloseCallback:^{
        bjl_strongify(self);
        [self.overlayViewController hide];
    }];

    if (!iPhone) {
        [self.noticeEditViewController setKeyboardShowCallback:^{
            bjl_strongify(self);
            [self.noticeEditViewController.view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.centerX.equalTo(self.overlayViewController.view);
                make.top.equalTo(self.overlayViewController.view).offset(20);
                make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                make.height.equalTo(self.overlayViewController.view).multipliedBy(0.38);
            }];

            [UIView animateWithDuration:0.3 animations:^{
                [self.overlayViewController.view setNeedsLayout];
                [self.overlayViewController.view layoutIfNeeded];
            }];
        }];

        [self.noticeEditViewController setKeyboardHideCallback:^{
            bjl_strongify(self);
            [self.noticeEditViewController.view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.center.equalTo(self.overlayViewController.view);
                make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                make.height.equalTo(self.overlayViewController.view).multipliedBy(0.38);
            }];

            [UIView animateWithDuration:0.3 animations:^{
                [self.overlayViewController.view setNeedsLayout];
                [self.overlayViewController.view layoutIfNeeded];
            }];
        }];
    }

    [self.noticeViewController setCloseCallback:^{
        bjl_strongify(self);
        [self.overlayViewController hide];
    }];

    [self.noticeViewController setEditCallback:^{
        bjl_strongify(self);
        [self.overlayViewController showWithContentViewController:self.noticeEditViewController contentView:nil];
        [self.noticeEditViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.center.equalTo(self.overlayViewController.view);
            make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
            make.height.equalTo(self.overlayViewController.view).multipliedBy(iPhone ? 0.83 : 0.38);
        }];
        [self.noticeEditViewController showEditView];
    }];

    [self.controlsViewController setShowQuestionCallback:^{
        bjl_strongify(self);
        [self showQuestionViewController];
    }];

    [self.questionViewController setCloseCallback:^{
        bjl_strongify(self);
        [self.overlayViewController hide];
    }];

    [self.controlsViewController setScaleCallback:^{
        bjl_strongify(self);
        if (self.fullscreenWindowType != BJLScWindowType_none) {
            [self restoreCurrentFullscreenWindow];
        }
        else {
            [self fullscreenCurrentMajorWindow];
        }
    }];

    [self.controlsViewController setSwitchEyeProtectedCallback:^{
        bjl_strongify(self);
        self.eyeProtectedLayer.hidden = !self.eyeProtectedLayer.hidden;
    }];

    [self.controlsViewController setShowHomeworkViewCallback:^{
        bjl_strongify(self);
        [self bjl_addChildViewController:self.pptManagerViewController superview:self.fullscreenLayer];
        [self.pptManagerViewController.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.edges.equalTo(self.fullscreenLayer);
        }];
    }];

    [self.controlsViewController setSwitchWebPPTAuthCallback:^{
        bjl_strongify(self);
        [self H5AuthButtonEventHandler];
    }];

    [self.controlsViewController setUpdateAsCameraCallback:^{
        bjl_strongify(self);
        if (self.room.recordingVM.hasAsCameraUser) {
            [self stopAsCameraUser];
        }
        else {
            [self showAsCameraQRCode];
        }
    }];

    [self.controlsViewController setMoreOptionEventCallback:^{
        bjl_strongify(self);

        if (self.majorWindowType == BJLScWindowType_teacherVideo && self.teacherMediaInfoView) {
            [self showMenuForTeacherVideoOnMajorAreaWithSourceView:self.controlsViewController.moreOptionButton];
        }
        else if (self.majorWindowType == BJLScWindowType_userVideo) {
            [self.videosViewController showVideoOperationAlertWithSourceView:self.controlsViewController.moreOptionButton];
        }
    }];

    [self.controlsViewController setBonusEventCallback:^{
        bjl_strongify(self);
        if (self.room.loginUser.isTeacherOrAssistant) {
            [self showBonusPointsRankForTeacher];
        }
        else {
            [self showBonusPointsRankForStudent];
        }
    }];

    [self.controlsViewController setSwitchDoubleClassCallback:^{
        bjl_strongify(self);
        BOOL isOnlineDoubleTeacher = self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_onlinedoubleTeachers
                                     && self.room.loginUser.isTeacherOrAssistant
                                     && self.room.loginUser.noGroup;
        NSString *message = isOnlineDoubleTeacher ? BJLLocalizedString(@"确定切换直播间吗?") : ((self.room.onlineDoubleRoomType == BJLOnlineDoubleRoomType_classGathered) ? BJLLocalizedString(@"确定切换到小班直播间吗?") : BJLLocalizedString(@"确定切换到大班直播间吗?"));
        BJLPopoverViewController *viewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLSwitchOnlineDoubleRoom message:message];

        [viewController setConfirmCallback:^{
            bjl_strongify(self);
            BJLError *error = [self.room.roomVM requestSwitchClass];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        }];

        [self bjl_addChildViewController:viewController superview:self.popoversLayer];
        [viewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.popoversLayer);
        }];
    }];

    [self.controlsViewController setShowSwitchRouteCallback:^{
        bjl_strongify(self);
        [self bjl_addChildViewController:self.switchRouteController superview:self.overlayView];
        [self.switchRouteController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.overlayView);
        }];
    }];

    [self.controlsViewController setChatIputButtonClickCallback:^{
        bjl_strongify(self);
        [self showChatInputViewWithWhisperChatUserExpend:NO commandLottery:nil];
    }];
#pragma mark - 1v1

    if (self.is1V1Class) {
        [self.chatViewController setShowImageViewCallback:^(BJLMessage *currentImageMessage, NSArray<BJLMessage *> *imageMessages, BOOL isStickyMessage) {
            bjl_strongify(self);
            [self showFullImageWithMessage:currentImageMessage
                             imageMessages:imageMessages
                           isStickyMessage:isStickyMessage];
        }];

        [self.chatViewController setShowChatInputViewCallback:^(BOOL whisperChatUserExpend, BJLCommandLotteryBegin *_Nullable commandLottery) {
            bjl_strongify(self);
            [self showChatInputViewWithWhisperChatUserExpend:whisperChatUserExpend commandLottery:commandLottery];
        }];

        [self.chatViewController setTapCommandLotteryCallback:^(BJLCommandLotteryBegin *_Nonnull commandLottery) {
            bjl_strongify(self);
            [self.chatInputViewController setContentWithText:commandLottery.command];
        }];

        [self.chatViewController setNewMessageCallback:^(NSInteger count) {
            bjl_strongify(self);
            if (self.chatButton) {
                NSString *title = BJLLocalizedString(@"聊天");
                if (count > 0) {
                    title = [title stringByAppendingFormat:@"(%ld)", (long)count];
                }
                [self.chatButton setTitle:title forState:UIControlStateNormal];
            }
        }];

        [self.chatButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self bjl_addChildViewController:self.chatViewController superview:self.segmentView];
            [self.chatViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.segmentView);
            }];
        }];

        [self.chatViewController setBackToVideoCallback:^{
            bjl_strongify(self);
            [self.chatViewController bjl_removeFromParentViewControllerAndSuperiew];
        }];
    }

    // gesture
    [self makeGestureAction];
}

#pragma mark - question

- (void)showQuestionViewController {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    [self.overlayViewController showWithContentViewController:self.questionViewController contentView:nil];
    [self.questionViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.overlayViewController.view);
        make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
        make.height.equalTo(self.overlayViewController.view).multipliedBy(iPhone ? 0.83 : 0.75);
    }];
}

#pragma mark - gesture

- (void)makeGestureAction {
    bjl_weakify(self);

    UITapGestureRecognizer *minorContentViewGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.teacherMediaInfoView && self.minorWindowType == BJLScWindowType_teacherVideo) {
            [self showMenuForTeacherVideoWithSourceView:self.minorContentView];
        }
        else if (self.minorWindowType == BJLScWindowType_ppt) {
            [self showMenuForPPTViewWithSourceView:self.minorContentView];
        }
    }];
    [self.minorContentView addGestureRecognizer:minorContentViewGesture];

    //    UITapGestureRecognizer *majorContentViewTapGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
    //        bjl_strongify(self);
    //        if (self.room.drawingVM.drawingEnabled || [self.toolViewController pptButtonIsSelect]) {
    //            return ;
    //        }
    //        [self setControlsHidden:!self.controlsHidden animated:NO];
    //
    //        // 当前课程未开始 且 教师视频在大窗口 且 有暖场的点播视频, 则隐藏 controlsViewController
    //        if (!self.room.roomVM.liveStarted
    //            && self.teacherMediaInfoView.positionType == BJLScPositionType_major
    //            && self.warmingUpView != nil) {
    //            self.controlsViewController.controlsHidden = YES;
    //        }
    //    }];
    //[self.majorContentView addGestureRecognizer:majorContentViewTapGesture];

    UITapGestureRecognizer *majorNoticeViewTapGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.majorNoticeView.hidden) {
            return;
        }

        // iOS开发机制，当view在animation的过程中，是不会响应任何事件的
        CGPoint clickPoint = [gesture locationInView:self.majorNoticeView];
        for (UIView *view in [self.majorNoticeView subviews]) {
            if ([view isKindOfClass:[UILabel class]]) {
                //返回point的最上层的layer，其实就是判断point落在这个弹幕view范围内了
                if ([view.layer.presentationLayer hitTest:clickPoint]) {
                    //处理点击事件
                    if (self.currentMajorNotice.linkURLString.length) {
                        NSURL *url = [NSURL URLWithString:self.currentMajorNotice.linkURLString];
                        if (url) {
                            [self openURL:url];
                        }
                    }
                    break;
                }
            }
        }
    }];
    [self.majorNoticeView addGestureRecognizer:majorNoticeViewTapGesture];

    if (self.is1V1Class) {
        UITapGestureRecognizer *secondMinorContentViewGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
            bjl_strongify(self);
            if (self.secondMinorMediaInfoView && self.secondMinorWindowType == BJLScWindowType_userVideo) {
                [self showMenuForStudentVideoWithSourceView:self.secondMinorContentView mediaInfoView:self.secondMinorMediaInfoView];
            }
            else if (self.secondMinorWindowType == BJLScWindowType_ppt) {
                [self showMenuForPPTViewWithSourceView:self.secondMinorContentView];
            }
        }];
        [self.secondMinorContentView addGestureRecognizer:secondMinorContentViewGesture];
    }

    [self.fullscreenOverlayViewController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
        bjl_strongify(self);
        switch (self.fullscreenWindowType) {
            case BJLScWindowType_ppt:
                [self showMenuForPPTViewWithSourceView:self.fullscreenLayer];
                break;

            case BJLScWindowType_teacherVideo:
                [self showMenuForTeacherVideoWithSourceView:self.fullscreenLayer];
                break;

            case BJLScWindowType_userVideo:
                [self showMenuForStudentVideoWithSourceView:self.fullscreenLayer mediaInfoView:self.fullscreenMediaInfoView];
                break;

            default:
                break;
        }
        return YES;
    }];
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated {
    self.controlsHidden = hidden;

    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    BOOL topBarViewHidden = hidden && !iPad && !self.is1V1Class;
    self.topBarView.hidden = topBarViewHidden;
    [self.topBarView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.equalTo(topBarViewHidden ? @(0) : @(BJLScTopBarHeight));
    }];

    self.controlsViewController.controlsHidden = hidden;
}

#pragma mark - handup

- (void)touchHandUp {
    bjl_returnIfRobot(BJLScRobotDelayS);
    if (self.room.loginUser.isStudent) {
        if (self.room.speakingRequestVM.speakingEnabled
            || (self.room.speakingRequestVM.speakingRequestTimeRemaining > 0)) {
            [self.room.speakingRequestVM stopSpeakingRequest];
        }
        else {
            if (self.room.speakingRequestVM.forbidSpeakingRequest) {
                [self showProgressHUDWithText:BJLLocalizedString(@"老师设置了禁止举手")];
                return;
            }

            BJLError *error = [self.room.speakingRequestVM sendSpeakingRequest];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
            else {
                [self showProgressHUDWithText:BJLLocalizedString(@"举手中，等待老师同意")];
            }
        }
    }
    else {
        [self.overlayViewController showWithContentViewController:self.speakRequestUsersViewController contentView:nil];
        [self.speakRequestUsersViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.right.bottom.equalTo(self.overlayViewController.view);
            make.width.equalTo(self.overlayViewController.view).multipliedBy(0.5);
        }];
    }
}

#pragma mark - chat

- (void)showFullImageWithMessage:(BJLMessage *)currentImageMessage imageMessages:(NSArray<BJLMessage *> *)imageMessages isStickyMessage:(BOOL)isStickyMessage {
    BJLScImageViewController *imageViewController = [[BJLScImageViewController alloc] initWithMessage:currentImageMessage imageMessages:imageMessages isStickyMessage:isStickyMessage && self.room.loginUser.isTeacherOrAssistant];
    bjl_weakify(self, imageViewController);
    [imageViewController setCancelStickyCallback:^(BJLMessage *_Nonnull message) {
        bjl_strongify(self, imageViewController);
        if (self.room.loginUser.isTeacherOrAssistant) {
            BJLError *error = [self.room.chatVM cancelStickyMessage:message];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
            else {
                [imageViewController hide];
            }
        }
    }];

    [self bjl_addChildViewController:imageViewController superview:self.imageViewLayer];
    [imageViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.imageViewLayer);
    }];
}

- (void)showChatInputViewWithWhisperChatUserExpend:(BOOL)whisperChatUserExpend commandLottery:(nullable BJLCommandLotteryBegin *)commandLottery {
    [self.chatInputViewController updateCommandLottery:commandLottery];
    BOOL useSecretForbid = self.room.featureConfig.useSecretMsgSendForbid;

    if (whisperChatUserExpend) { // 私聊状态下, 全体禁言有个配置项控制能否找老师助教私聊
        if (!self.room.loginUser.isTeacherOrAssistant && !useSecretForbid
            && (self.room.chatVM.forbidMe
                || (self.room.chatVM.forbidAll && !self.room.featureConfig.enableWhisperToTeacherWhenForbidAll)
                || self.room.chatVM.forbidMyGroup)) {
            return;
        }
    }
    else {
        BOOL forbid = !self.room.loginUser.isTeacherOrAssistant && (self.room.chatVM.forbidMe || self.room.chatVM.forbidAll || self.room.chatVM.forbidMyGroup);
        if (forbid && !useSecretForbid) {
            return;
        }
    }

    if (self.room.loginUser.isAudition) {
        [self showProgressHUDWithText:BJLLocalizedString(@"试听用户不能发送消息")];
        return;
    }

    if (whisperChatUserExpend) {
        [self.chatInputViewController showWhisperChatList];
    }
    else {
        [self.chatInputViewController clearInputView];
    }

    [self.overlayViewController showWithContentViewController:self.chatInputViewController contentView:nil];
    [self.chatInputViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.overlayViewController.view);
    }];
}

#pragma mark - ppt

- (void)updatePPTUserInteractionEnable {
    self.room.slideshowViewController.view.userInteractionEnabled = (self.majorWindowType == BJLScWindowType_ppt) || (self.fullscreenWindowType == BJLScWindowType_ppt);
}

#pragma mark - fullscreen

// 把当前大屏视图全屏
- (void)fullscreenCurrentMajorWindow {
    if (self.majorWindowType == BJLScWindowType_ppt) {
        [self replaceFullscreenWithWindowType:BJLScWindowType_ppt mediaInfoView:self.teacherExtraMediaInfoView];
    }
    else if (self.majorWindowType == BJLScWindowType_teacherVideo) {
        [self replaceFullscreenWithWindowType:BJLScWindowType_teacherVideo mediaInfoView:self.teacherMediaInfoView];
    }
    else if (self.majorWindowType == BJLScWindowType_userVideo) {
        if (self.secondMinorMediaInfoView) {
            [self replaceFullscreenWithWindowType:BJLScWindowType_userVideo mediaInfoView:self.secondMinorMediaInfoView];
        }
        else {
            if (self.videosViewController.majorMediaInfoView) {
                [self replaceFullscreenWithWindowType:BJLScWindowType_userVideo mediaInfoView:self.videosViewController.majorMediaInfoView];
            }
            else {
                // 显示辅助摄像头
                if (self.teacherExtraMediaInfoView && !self.showTeacherExtraMediaInfoViewCoverPPT) {
                    [self replaceFullscreenWithWindowType:BJLScWindowType_userVideo mediaInfoView:self.teacherExtraMediaInfoView];
                }
            }
        }
    }
}

// 全屏视图恢复原始位置
- (void)restoreCurrentFullscreenWindow {
    [self replaceFullscreenWithWindowType:BJLScWindowType_none mediaInfoView:nil];
}

- (void)resetMajorNoticeWhenFullScreenStateChanged {
    BOOL isFullScreen = self.fullscreenWindowType != BJLScWindowType_none;
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (!isFullScreen) {
        // 回到小屏
        [self.majorNoticeView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.majorContentView);
            make.top.equalTo(iPhone ? (self.is1V1Class          ? self.topBarView.bjl_bottom
                                       : self.videosView.hidden ? self.topBarView.bjl_bottom
                                                                : self.videosView.bjl_bottom)
                                    : self.majorContentView);
            make.right.equalTo(self.majorContentView);
            make.height.equalTo(@(30));
        }];
    }
    else {
        // 进入全屏
        [self.majorNoticeView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.majorContentView);
            make.top.equalTo(self.fullscreenLayer);
            make.right.equalTo(self.containerView);
            make.height.equalTo(@(30));
        }];
    }
}

#pragma mark - replaceContentView

/**
 此处穷举了所有当前控制器需要处理的视图切换，注意任何情况下，老师辅助摄像头和PPT区域是重叠的
 包括 大屏的三种可能视图（PPT，老师，其他用户），小屏的二种可能视图（老师，PPT），以及 1v1 的第二个小屏的二种可能（PPT，其他用户）
 但是所有视频列表的替换需要根据实际单独处理
 */

// 替换大屏为PPT
- (void)replaceMajorContentViewWithPPTView {
    [self replaceWithPPTViewInContentView:self.majorContentView];
    if (self.showTeacherExtraMediaInfoViewCoverPPT
        && self.teacherExtraMediaInfoView.positionType != BJLScPositionType_major) {
        self.teacherExtraMediaInfoView.positionType = BJLScPositionType_major;
    }
    if (self.majorWindowType != BJLScWindowType_ppt) {
        self.majorWindowType = BJLScWindowType_ppt;
    }
}

// 替换小屏为PPT
- (void)replaceMinorContentViewWithPPTView {
    [self replaceWithPPTViewInContentView:self.minorContentView];
    if (self.showTeacherExtraMediaInfoViewCoverPPT
        && self.teacherExtraMediaInfoView.positionType != BJLScPositionType_minor) {
        self.teacherExtraMediaInfoView.positionType = BJLScPositionType_minor;
    }
    if (self.minorWindowType != BJLScWindowType_ppt) {
        self.minorWindowType = BJLScWindowType_ppt;
    }
}

// 替换 1v1 第二个小屏为PPT
- (void)replaceSecondMinorContentViewWithPPTView {
    [self replaceWithPPTViewInContentView:self.secondMinorContentView];
    if (self.showTeacherExtraMediaInfoViewCoverPPT
        && self.teacherExtraMediaInfoView.positionType != BJLScPositionType_secondMinor) {
        self.teacherExtraMediaInfoView.positionType = BJLScPositionType_secondMinor;
    }
    if (self.secondMinorWindowType != BJLScWindowType_ppt) {
        self.secondMinorWindowType = BJLScWindowType_ppt;
    }
}

- (void)replaceWithPPTViewInContentView:(UIView *)contentView {
    if (contentView != self.fullscreenLayer
        && self.fullscreenWindowType == BJLScWindowType_ppt) {
        [self resetFullscreenWindowType];
    }

    if (self.room.slideshowViewController) {
        [self.room.slideshowViewController bjl_removeFromParentViewControllerAndSuperiew];
        if (contentView == self.fullscreenLayer) {
            [self.fullscreenOverlayViewController showFillContentViewController:self.room.slideshowViewController contentView:nil ratio:0.0];
        }
        else {
            [self bjl_addChildViewController:self.room.slideshowViewController superview:contentView];
            [self.room.slideshowViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(contentView);
            }];
        }
    }

    if (self.showTeacherExtraMediaInfoViewCoverPPT) {
        // 存在老师辅助摄像头时，盖住白板
        [self.teacherExtraMediaInfoView removeFromSuperview];
        if (contentView == self.fullscreenLayer) {
            [self.fullscreenOverlayViewController showFillContentViewController:self.room.slideshowViewController contentView:self.teacherExtraMediaInfoView ratio:0.0];
        }
        else {
            [contentView addSubview:self.teacherExtraMediaInfoView];
            [self.teacherExtraMediaInfoView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(contentView);
            }];
        }
    }
}

// 替换大屏为老师
- (void)replaceMajorContentViewWithTeacherMediaInfoView {
    [self replaceWithTeacherMediaInfoViewInContentView:self.majorContentView];
    if (self.teacherMediaInfoView.positionType != BJLScPositionType_major) {
        self.teacherMediaInfoView.positionType = BJLScPositionType_major;
    }
    if (self.majorWindowType != BJLScWindowType_teacherVideo) {
        self.majorWindowType = BJLScWindowType_teacherVideo;
    }
}

// 替换小屏为老师
- (void)replaceMinorContentViewWithTeacherMediaInfoView {
    [self replaceWithTeacherMediaInfoViewInContentView:self.minorContentView];
    if (self.teacherMediaInfoView.positionType != BJLScPositionType_minor) {
        self.teacherMediaInfoView.positionType = BJLScPositionType_minor;
    }
    if (self.minorWindowType != BJLScWindowType_teacherVideo) {
        self.minorWindowType = BJLScWindowType_teacherVideo;
    }
}

- (void)replaceWithTeacherMediaInfoViewInContentView:(UIView *)contentView {
    if (contentView != self.fullscreenLayer
        && self.fullscreenWindowType == BJLScWindowType_teacherVideo) {
        [self resetFullscreenWindowType];
    }

    if (self.teacherMediaInfoView) {
        [self.teacherMediaInfoView removeFromSuperview];
        if (contentView == self.fullscreenLayer) {
            [self.fullscreenOverlayViewController showFillContentViewController:nil contentView:self.teacherMediaInfoView ratio:0.0];
        }
        else {
            [contentView addSubview:self.teacherMediaInfoView];
            [self.teacherMediaInfoView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(contentView);
            }];
        }
    }
    if (self.teacherMediaInfoView
        && self.warmingUpView
        && self.teacherMediaInfoView != self.warmingUpView.superview) {
        [self.warmingUpView removeFromSuperview];
        [self.teacherMediaInfoView addSubview:self.warmingUpView];
        [self.warmingUpView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.teacherMediaInfoView);
        }];
    }
}

// 替换大屏为某个用户
- (void)replaceMajorContentViewWithUserMediaInfoView:(BJLScMediaInfoView *)mediaInfoView {
    [self replaceContentView:self.majorContentView mediaInfoView:mediaInfoView];
    if (mediaInfoView.positionType != BJLScPositionType_major) {
        mediaInfoView.positionType = BJLScPositionType_major;
    }
    if (self.majorWindowType != BJLScWindowType_userVideo) {
        self.majorWindowType = BJLScWindowType_userVideo;
    }
}

// 替换 1v1 大屏为某个用户
- (void)replaceMajorContentViewWithSecondMinorMediaInfoView {
    [self replaceContentView:self.majorContentView mediaInfoView:self.secondMinorMediaInfoView];
    if (self.secondMinorMediaInfoView.positionType != BJLScPositionType_major) {
        self.secondMinorMediaInfoView.positionType = BJLScPositionType_major;
    }
    if (self.majorWindowType != BJLScWindowType_userVideo) {
        self.majorWindowType = BJLScWindowType_userVideo;
    }
    [self updateSecondMinorVideoPlaceholderView];
}

// 替换 1v1 第二个小屏为某个用户
- (void)replaceSecondMinorContentViewWithSecondMinorMediaInfoView {
    [self replaceContentView:self.secondMinorContentView mediaInfoView:self.secondMinorMediaInfoView];
    if (self.secondMinorMediaInfoView.positionType != BJLScPositionType_secondMinor) {
        self.secondMinorMediaInfoView.positionType = BJLScPositionType_secondMinor;
    }
    if (self.secondMinorWindowType != BJLScWindowType_userVideo) {
        self.secondMinorWindowType = BJLScWindowType_userVideo;
    }
    [self updateSecondMinorVideoPlaceholderView];
}

- (void)replaceContentView:(UIView *)contentView mediaInfoView:(BJLScMediaInfoView *)mediaInfoView {
    if (contentView != self.fullscreenLayer
        && self.fullscreenWindowType == BJLScWindowType_userVideo
        && self.fullscreenMediaInfoView == mediaInfoView) {
        [self resetFullscreenWindowType];
    }

    if (mediaInfoView) {
        [mediaInfoView removeFromSuperview];
        if (contentView == self.fullscreenLayer) {
            [self.fullscreenOverlayViewController showFillContentViewController:nil contentView:mediaInfoView ratio:0.0];
        }
        else {
            [contentView addSubview:mediaInfoView];
            [mediaInfoView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(contentView);
            }];
        }
    }
}

// 替换全屏区域为某个视图，传空将归还当前全屏区域显示的视图，归还可能会因为其他位置归还，因此归还时将会重置状态，但是设置全屏视图必然通过此处调用，理想情况不会出现一次调用过程中发生全屏存在视图时，新的视图切换到全屏的情况
- (void)replaceFullscreenWithWindowType:(BJLScWindowType)windowType mediaInfoView:(nullable BJLScMediaInfoView *)mediaInfoView {
    // 如果当前全屏区域存在视图，归还当前的全屏视图
    if (self.majorWindowType == self.fullscreenWindowType) {
        // 归还大屏视图，可为任意情况
        switch (self.fullscreenWindowType) {
            case BJLScWindowType_ppt:
                [self replaceMajorContentViewWithPPTView];
                break;

            case BJLScWindowType_teacherVideo:
                [self replaceMajorContentViewWithTeacherMediaInfoView];
                break;

            case BJLScWindowType_userVideo:
                [self replaceMajorContentViewWithUserMediaInfoView:self.fullscreenMediaInfoView];
                break;

            default:
                break;
        }
    }
    else if (self.minorWindowType == self.fullscreenWindowType) {
        // 归还小屏视图，可为PPT和老师
        switch (self.fullscreenWindowType) {
            case BJLScWindowType_ppt:
                [self replaceMinorContentViewWithPPTView];
                break;

            case BJLScWindowType_teacherVideo:
                [self replaceMinorContentViewWithTeacherMediaInfoView];
                break;

            case BJLScWindowType_userVideo:
                // unsupported
                break;

            default:
                break;
        }
    }
    else if (self.secondMinorMediaInfoView && self.secondMinorWindowType == self.fullscreenWindowType) {
        // 归还 1v1 第二个小屏视图，可为学生和PPT，当前设计下与视频列表互斥，如果同时存在，不保证可用
        switch (self.fullscreenWindowType) {
            case BJLScWindowType_ppt:
                [self replaceSecondMinorContentViewWithPPTView];
                break;

            case BJLScWindowType_teacherVideo:
                // unsupported
                break;

            case BJLScWindowType_userVideo:
                [self replaceSecondMinorContentViewWithSecondMinorMediaInfoView];
                break;

            default:
                break;
        }
    }
    else if (self.fullscreenWindowType == BJLScWindowType_userVideo) {
        // 视频列表区域的视频
        [self resetFullscreenWindowType];
        [self.videosViewController updateCurrentMediaInfoViews];
    }
    // 如果需要设置新的全屏设置，设置新的全屏视图
    switch (windowType) {
        case BJLScWindowType_ppt:
            [self replaceWithPPTViewInContentView:self.fullscreenLayer];
            if (self.showTeacherExtraMediaInfoViewCoverPPT) {
                self.teacherExtraMediaInfoView.isFullScreen = YES;
            }
            break;

        case BJLScWindowType_teacherVideo:
            [self replaceWithTeacherMediaInfoViewInContentView:self.fullscreenLayer];
            self.teacherMediaInfoView.isFullScreen = YES;
            break;

        case BJLScWindowType_userVideo:
            mediaInfoView.isFullScreen = YES;
            if (mediaInfoView.positionType == BJLScPositionType_videoList) {
                [self.videosViewController updateCurrentMediaInfoViews];
            }
            [self replaceContentView:self.fullscreenLayer mediaInfoView:mediaInfoView];
            break;

        default:
            break;
    }
    if (self.fullscreenWindowType != windowType) {
        self.fullscreenWindowType = windowType;
    }
    if (self.fullscreenMediaInfoView != mediaInfoView) {
        self.fullscreenMediaInfoView = mediaInfoView;
    }
}

- (void)resetFullscreenWindowType {
    self.fullscreenMediaInfoView.isFullScreen = NO;
    [self.fullscreenOverlayViewController hide];
    self.fullscreenWindowType = BJLScWindowType_none;
    self.fullscreenMediaInfoView = nil;
}

- (void)H5AuthButtonEventHandler {
    if (!self.room.documentVM.authorizedH5PPT) {
        BJLError *error = [self.room.documentVM updateAllStudentH5PPTAuthorized:YES];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        return;
    }

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:BJLLocalizedString(@"您确定取消授权?")
                         message:BJLLocalizedString(@"取消授权后学生将无法操作课件")
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert bjl_addActionWithTitle:BJLLocalizedString(@"保留授权")
                            style:UIAlertActionStyleCancel
                          handler:nil];
    [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消授权")
                            style:UIAlertActionStyleDestructive
                          handler:^(UIAlertAction *_Nonnull action) {
                              [self.room.documentVM updateAllStudentH5PPTAuthorized:NO];
                          }];

    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

// 由于判断是否要同步切换时, 多次重复代码, 故此集中一个方法表示将老师窗口从小屏切换到 PPT 大屏区域
- (void)switchTeacherViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:(BOOL)shouldSyncPPTVideoSwitch {
    if (self.majorWindowType == BJLScWindowType_userVideo) {
        if (self.videosViewController) {
            // 如果是双摄模板并且是允许课件和辅助摄像头同时显示时，把辅助摄像头放回视频列表
            if (self.teacherExtraMediaInfoView.positionType == BJLScPositionType_major && !self.showTeacherExtraMediaInfoViewCoverPPT) {
                [self.videosViewController reloadVideoWithTeacherExtraMediaInfoView:self.teacherExtraMediaInfoView];
            }
            // 大屏是用户视频时，把用户视频放回视频列表
            else {
                [self.videosViewController resetVideo];
            }
        }
        // 如果是 1v1 的班型，放回第二个小屏
        if (self.secondMinorMediaInfoView) {
            [self replaceSecondMinorContentViewWithSecondMinorMediaInfoView];
        }
    }
    [self replaceMinorContentViewWithPPTView];
    [self replaceMajorContentViewWithTeacherMediaInfoView];

    if (shouldSyncPPTVideoSwitch) {
        BJLError *error = [self.room.roomVM exchangeVideoPositonWithPPT:YES];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
    }

    if (!self.room.roomVM.liveStarted
        && self.teacherMediaInfoView.positionType == BJLScPositionType_major
        && self.warmingUpView != nil) {
        self.controlsViewController.controlsHidden = YES;
    }
}

// 由于判断是否要同步切换时, 多次重复代码, 故此集中一个方法表示将 PPT 窗口从小屏切换到大屏区域
- (void)switchPPTViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:(BOOL)shouldSyncPPTVideoSwitch {
    [self replaceMajorContentViewWithPPTView];
    [self replaceMinorContentViewWithTeacherMediaInfoView];

    if (shouldSyncPPTVideoSwitch) {
        BJLError *error = [self.room.roomVM exchangeVideoPositonWithPPT:NO];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
    }
}

#pragma mark - QRCode

- (void)showAsCameraQRCode {
    bjl_weakify(self);
    [self.room.recordingVM requestAsCameraDataWithCompletion:^(NSString *_Nullable urlString, UIImage *_Nullable image, BJLError *_Nullable error) {
        bjl_strongify(self);
        if (image) {
            BJLQRCodeViewController *window = [[BJLQRCodeViewController alloc] initWithQRCodeImage:image];
            [self bjl_addChildViewController:window superview:self.overlayView];
            [window.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.center.equalTo(self.overlayView);
                make.height.equalTo(@360.0);
                make.width.equalTo(@320.0);
            }];
            [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, hasAsCameraUser)
                 observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                     bjl_strongify(self);
                     if (self.room.recordingVM.hasAsCameraUser && window) {
                         [window bjl_removeFromParentViewControllerAndSuperiew];
                     }
                     return YES;
                 }];
        }
    }];
}

#pragma mark - stop as camera

- (void)stopAsCameraUser {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n" message:@"\n\n" preferredStyle:UIAlertControllerStyleAlert];
    UIView *containerView = ({
        UIView *view = [UIView new];
        view;
    });
    __block BOOL openVideo = NO;
    UILabel *label = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"终止外接设备直播");
        label.font = [UIFont systemFontOfSize:16.0];
        label.textColor = [UIColor bjl_colorWithHexString:@"#333333"];
        label;
    });
    [containerView addSubview:label];
    [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(containerView.bjl_top).offset(22.0);
        make.centerX.equalTo(containerView);
        make.height.equalTo(@22.0);
    }];

    UIButton *checkButton = ({
        BJLButton *button = [BJLButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        button.midSpace = 10.0;
        [button setTitle:BJLLocalizedString(@"打开主设备摄像头") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor bjl_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_chat_checkbox_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_chat_checkbox_selected"] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            button.selected = !button.selected;
            openVideo = button.selected;
        }];
        button;
    });
    [containerView addSubview:checkButton];
    [checkButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(label.bjl_bottom).offset(12.0);
        make.centerX.equalTo(containerView);
        make.height.equalTo(@20.0);
    }];

    [alert.view addSubview:containerView];
    [containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(alert.view);
        make.bottom.equalTo(alert.view).offset(-44.0);
        make.height.equalTo(@100.0).priorityHigh();
    }];
    bjl_weakify(self);
    [alert bjl_addActionWithTitle:BJLLocalizedString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        bjl_strongify(self);
        [self.room.recordingVM stopAsCameraUserCompletion:^{
            bjl_strongify(self);
            if (openVideo) {
                [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio recordingVideo:openVideo];
            }
        }];
    }];
    [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:nil];
    [self showAlertViewController:alert sourceView:self.view];
}

#pragma mark - handWritingBoard

- (void)updateHandWritingBoardConnectState:(BOOL)connect {
    if (connect && self.room.drawingVM.isConnectingHandWritingBoard) {
        return;
    }
    bjl_weakify(self);
    if (connect) {
        [self showHandWritingBoardViewController];
        [self.handWritingBoardViewController autoConnectIfFindPrevConnectedDevice:nil];
    }
    else {
        BJLPopoverViewController *viewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLHandWritingBoardDisconnect];
        [viewController setConfirmCallback:^{
            bjl_strongify(self);
            [self.handWritingBoardViewController disConnectCurrentConnectedDevice];
        }];
        [self bjl_addChildViewController:viewController superview:self.popoversLayer];
        [viewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.popoversLayer);
        }];
    }
}

- (void)showHandWritingBoardViewController {
    if (self.handWritingBoardViewController.view.superview) {
        return;
    }
    [self bjl_addChildViewController:self.handWritingBoardViewController superview:self.overlayView];
    [self.handWritingBoardViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.overlayView);
        make.width.equalTo(@460.0);
        make.height.equalTo(@285.0);
    }];
}

- (void)showOpenBluetoothView {
    BJLPopoverViewController *viewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLOpenBluetooth];
    [self bjl_addChildViewController:viewController superview:self.popoversLayer];
    [viewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.popoversLayer);
    }];
}

#pragma mark - bonus rank
// 积分排行榜
- (void)showBonusPointsRankForTeacher {
    if ([self.childViewControllers containsObject:self.bonusListVC]) {
        return;
    }

    [self bjl_addChildViewController:self.bonusListVC superview:self.fullscreenLayer];
    //    bjl_weakify(self);
    self.bonusListVC.closeEventBlock = ^(BJLPopoverBaseViewController *_Nonnull vc) {
        //        bjl_strongify(self);
        //        self.controlsViewController.bonusButton.selected = NO;
    };
    [self.bonusListVC.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.fullscreenLayer);
    }];
}

- (void)showBonusPointsRankForStudent {
    if ([self.childViewControllers containsObject:self.studentBonusListVC]) {
        return;
    }

    [self bjl_addChildViewController:self.studentBonusListVC superview:self.fullscreenLayer];
    //    bjl_weakify(self);
    self.studentBonusListVC.closeEventBlock = ^(BJLPopoverBaseViewController *_Nonnull vc) {
        //        bjl_strongify(self);
        //        self.controlsViewController.bonusButton.selected = NO;
    };
    [self.studentBonusListVC.view bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.fullscreenLayer);
    }];
}

// 积分排行榜
- (void)showBonusPointsIncreasingForStudent:(CGFloat)bonusPoints {
    [self hideBonusPointsIncreasingForStudent];

    //在dismiss之前，这个popover的vc有问题，需要延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.presentedViewController) { return; }

        self.studentBonusIncreasingPopupVC.sourceView = self.controlsViewController.bonusButton;
        self.studentBonusIncreasingLabel.text = [NSString stringWithFormat:@"+%.0f", bonusPoints];
        [self.studentBonusIncreasingPopupVC updatePopoverProperty];
        [self presentViewController:self.studentBonusIncreasingPopupVC animated:YES completion:nil];
    });

    self.studentBonusIncreasingPopupDelayCloseBlock = dispatch_block_create(0, ^{
        [self hideBonusPointsIncreasingForStudent];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.studentBonusIncreasingPopupDelayCloseBlock);
}

- (void)hideBonusPointsIncreasingForStudent {
    if (self.studentBonusIncreasingPopupVC.presentingViewController) {
        [self.studentBonusIncreasingPopupVC dismissViewControllerAnimated:NO completion:nil];
        if (self.studentBonusIncreasingPopupDelayCloseBlock) {
            dispatch_block_cancel(self.studentBonusIncreasingPopupDelayCloseBlock);
            self.studentBonusIncreasingPopupDelayCloseBlock = NULL;
        }
    }
}

#pragma mark - menu

- (void)showMenuForTeacherVideoWithSourceView:(nullable UIView *)sourceView {
    bjl_weakify(self);

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:BJLLocalizedString(@"视频")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    BOOL fullscreen = self.fullscreenWindowType == BJLScWindowType_teacherVideo;

    // 没有开始上课
    if (!self.room.roomVM.liveStarted) {
        [alert bjl_addActionWithTitle:fullscreen ? BJLLocalizedString(@"退出全屏") : BJLLocalizedString(@"全屏") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            bjl_strongify(self);
            if (fullscreen) {
                [self restoreCurrentFullscreenWindow];
            }
            else {
                [self replaceFullscreenWithWindowType:BJLScWindowType_teacherVideo mediaInfoView:self.teacherMediaInfoView];
            }
        }];

        if (!fullscreen) {
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"切换窗口") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                bjl_strongify(self);
                [self switchTeacherViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:NO];
            }];
        }

        [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:nil];
        sourceView = sourceView ?: self.minorContentView;
        [self showAlertViewController:alert sourceView:sourceView];

        return;
    }

    BJLMediaUser *mediaUser = self.teacherMediaInfoView.mediaUser;
    BOOL playingVideo = NO;
    if (self.room.loginUserIsPresenter) {
        playingVideo = self.room.recordingVM.recordingVideo;
    }
    else {
        if (!mediaUser.videoOn) {
            // 未打开摄像头的用户无菜单项
            return;
        }
        playingVideo = mediaUser.videoOn ? [self isVideoPlayingUser:mediaUser] : NO;
    }

    if (playingVideo) {
        // 在播放画面的用户可以全屏和放大
        [alert bjl_addActionWithTitle:fullscreen ? BJLLocalizedString(@"退出全屏") : BJLLocalizedString(@"全屏") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            bjl_strongify(self);
            if (fullscreen) {
                [self restoreCurrentFullscreenWindow];
            }
            else {
                [self replaceFullscreenWithWindowType:BJLScWindowType_teacherVideo mediaInfoView:self.teacherMediaInfoView];
            }
        }];
        if (!fullscreen) {
            // 不在全屏区域的用户可以放大
            BOOL cannotExpandWindowCase = self.room.roomInfo.isPureVideo || (self.room.roomInfo.isVideoWall && self.roomLayout != BJLRoomLayout_blackboard);
            if (!cannotExpandWindowCase) {
                [alert bjl_addActionWithTitle:BJLLocalizedString(@"切换窗口") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                    bjl_strongify(self);
                    if (self.room.loginUser.isTeacherOrAssistant && self.room.featureConfig.shouldSyncPPTVideoSwitch) {
                        UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil
                                                                                                     message:BJLLocalizedString(@"切换视频窗口与白板位置，学生端是否同步切换？")
                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                        [alertViewController bjl_addActionWithTitle:BJLLocalizedString(@"仅本地切换")
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *_Nonnull action) {
                                                                bjl_strongify(self);
                                                                [self switchTeacherViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:NO];
                                                            }];
                        [alertViewController bjl_addActionWithTitle:BJLLocalizedString(@"同步切换")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *_Nonnull action) {
                                                                bjl_strongify(self);
                                                                [self switchTeacherViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:YES];
                                                            }];
                        if (self.presentedViewController) {
                            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
                        }
                        [self presentViewController:alertViewController animated:YES completion:nil];
                    }
                    else {
                        [self switchTeacherViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:NO];
                    }
                }];
            }
        }
    }

    [self addTeacherVideoAlertOptionWithAlert:alert];

    sourceView = sourceView ?: self.minorContentView;
    [self showAlertViewController:alert sourceView:sourceView];
}

- (void)addTeacherVideoAlertOptionWithAlert:(UIAlertController *)alert {
    BOOL fullscreen = self.fullscreenWindowType == BJLScWindowType_teacherVideo;
    BJLMediaUser *mediaUser = self.teacherMediaInfoView.mediaUser;
    BOOL playingVideo = NO;
    if (self.room.loginUserIsPresenter) {
        playingVideo = self.room.recordingVM.recordingVideo;
    }
    else {
        if (!mediaUser.videoOn) {
            // 未打开摄像头的用户无菜单项
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消")
                                    style:UIAlertActionStyleCancel
                                  handler:nil];
            return;
        }
        playingVideo = mediaUser.videoOn ? [self isVideoPlayingUser:mediaUser] : NO;
    }

    bjl_weakify(self);
    if (self.room.loginUser.isTeacher
        && mediaUser.isAssistant
        && self.room.featureConfig.canChangePresenter) {
        if ([mediaUser isSameUser:self.room.onlineUsersVM.currentPresenter]) {
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"收回主讲")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      [self.room.onlineUsersVM requestChangePresenterWithUserID:self.room.loginUser.ID];
                                  }];
        }
    }

    if (self.room.loginUserIsPresenter) {
        if (self.room.featureConfig.enableAttachPhoneCamera && self.room.featureConfig.isWebRTC) {
            [alert bjl_addActionWithTitle:self.room.recordingVM.hasAsCameraUser ? BJLLocalizedString(@"结束扫码直播") : BJLLocalizedString(@"扫码视频直播")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      if (self.room.recordingVM.hasAsCameraUser) {
                                          [self stopAsCameraUser];
                                      }
                                      else {
                                          [self showAsCameraQRCode];
                                      }
                                  }];
        }

        if (!self.room.recordingVM.hasAsCameraUser && self.room.recordingVM.recordingVideo) {
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"切换摄像头")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      if (!self.room.recordingVM.recordingVideo) {
                                          return;
                                      }
                                      BJLError *error = [self.room.recordingVM updateUsingRearCamera:!self.room.recordingVM.usingRearCamera];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                  }];

            BOOL validMirrorRoomType = self.room.featureConfig.isWebRTC && !self.room.roomInfo.isPushLive && !self.room.roomInfo.isMockLive;
            BOOL enableHorizontalMirror = validMirrorRoomType && (self.room.featureConfig.videoMirrorMode == BJLVideoMirrorModeHorizontal || self.room.featureConfig.videoMirrorMode == BJLVideoMirrorModeHorizontalAndVertical);
            if (enableHorizontalMirror && self.room.loginUser.isTeacher) {
                [alert bjl_addActionWithTitle:BJLLocalizedString(@"水平翻转")
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *_Nonnull action) {
                                          bjl_strongify(self);
                                          if (!self.room.recordingVM.recordingVideo) {
                                              return;
                                          }
                                          [self mirrorVideoHorizontally];
                                      }];
            }

            BOOL enableVerticalMirror = validMirrorRoomType && (self.room.featureConfig.videoMirrorMode == BJLVideoMirrorModeVertical || self.room.featureConfig.videoMirrorMode == BJLVideoMirrorModeHorizontalAndVertical);
            if (enableVerticalMirror && self.room.loginUser.isTeacher) {
                [alert bjl_addActionWithTitle:BJLLocalizedString(@"垂直翻转")
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *_Nonnull action) {
                                          bjl_strongify(self);
                                          if (!self.room.recordingVM.recordingVideo) {
                                              return;
                                          }
                                          [self mirrorVideoVertically];
                                      }];
            }

            // WebRTC 暂无美颜
            if (!self.room.featureConfig.isWebRTC) {
                [alert bjl_addActionWithTitle:(self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_off
                                                      ? BJLLocalizedString(@"开启美颜")
                                                      : BJLLocalizedString(@"关闭美颜"))
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *_Nonnull action) {
                                          bjl_strongify(self);
                                          if (!self.room.recordingVM.recordingVideo) {
                                              return;
                                          }
                                          BJLError *error = [self.room.recordingVM updateVideoBeautifyLevel:(self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_off
                                                                                                                    ? BJLVideoBeautifyLevel_on
                                                                                                                    : BJLVideoBeautifyLevel_off)];
                                          if (error) {
                                              [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                          }
                                      }];
            }
        }

        [alert bjl_addActionWithTitle:self.room.recordingVM.recordingVideo ? BJLLocalizedString(@"关闭摄像头") : BJLLocalizedString(@"打开摄像头")
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction *_Nonnull action) {
                                  bjl_strongify(self);
                                  BJLError *error = [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                                                              recordingVideo:!self.room.recordingVM.recordingVideo];
                                  if (error) {
                                      [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                  }
                                  else {
                                      [self showProgressHUDWithText:(self.room.recordingVM.recordingVideo
                                                                            ? BJLLocalizedString(@"摄像头已打开")
                                                                            : BJLLocalizedString(@"摄像头已关闭"))];
                                      if (fullscreen && !self.room.recordingVM.recordingVideo) {
                                          // 关闭摄像头退出全屏
                                          [self restoreCurrentFullscreenWindow];
                                      }
                                  }
                              }];
    }

    if (!self.room.loginUserIsPresenter && mediaUser.videoOn) {
        // 用户开启了摄像头可以选择播放或者关闭画面
        [alert bjl_addActionWithTitle:playingVideo ? BJLLocalizedString(@"关闭视频") : BJLLocalizedString(@"开启视频")
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *_Nonnull action) {
                                  bjl_strongify(self);
                                  BJLError *error = [self.room.playingVM updatePlayingUserWithID:mediaUser.ID videoOn:!playingVideo mediaSource:mediaUser.mediaSource];
                                  if (error) {
                                      [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                  }
                                  else {
                                      // 主动关闭老师视频后不再自动打开
                                      [self.teacherMediaInfoView updateCloseVideoPlaceholderHidden:!playingVideo];
                                      [self updateAutoPlayVideoBlacklist:mediaUser add:playingVideo];
                                      if (fullscreen && playingVideo) {
                                          // 关闭画面退出全屏
                                          [self restoreCurrentFullscreenWindow];
                                      }
                                  }
                              }];
        BOOL enableSwitchMixedVideoDefinition = self.room.featureConfig.enableSwitchMixedVideoDefinition;
        if (enableSwitchMixedVideoDefinition) {
            enableSwitchMixedVideoDefinition = self.room.playingVM.playMixedVideo || self.room.roomInfo.isMockLive || self.room.roomInfo.isPushLive;
        }
        if (enableSwitchMixedVideoDefinition) {
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"原画")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      BJLError *error = [self.room.playingVM useOriginCDNVideoDefinition:YES];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                  }]
                .enabled = !self.room.playingVM.originCDNVideoDefinition;
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"高清")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      BJLError *error = [self.room.playingVM useOriginCDNVideoDefinition:NO];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                  }]
                .enabled = self.room.playingVM.originCDNVideoDefinition;
        }
    }

    [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消")
                            style:UIAlertActionStyleCancel
                          handler:nil];
}

- (void)showMenuForTeacherVideoOnMajorAreaWithSourceView:(nullable UIView *)sourceView {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:BJLLocalizedString(@"视频")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    [self addTeacherVideoAlertOptionWithAlert:alert];

    [self showAlertViewController:alert sourceView:sourceView];
}

- (void)showMenuForPPTViewWithSourceView:(nullable UIView *)sourceView {
    bjl_weakify(self);

    BJLMediaUser *mediaUser = self.showTeacherExtraMediaInfoViewCoverPPT ? self.teacherExtraMediaInfoView.mediaUser : nil;
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:mediaUser ? BJLLocalizedString(@"视频") : BJLLocalizedString(@"白板/课件")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];
    BOOL fullscreen = self.fullscreenWindowType == BJLScWindowType_ppt;
    BOOL playingVideo = !mediaUser; // 无 mediaUser 即 PPT，此时是存在菜单项的
    if (mediaUser) {
        if (mediaUser.videoOn) {
            playingVideo = [self isVideoPlayingUser:mediaUser];
        }
        else {
            // 未打开摄像头的用户无菜单项
            return;
        }
    }

    if (self.room.loginUser.isTeacherOrAssistant
        && self.room.featureConfig.canShowH5PPTAuthButton
        && !mediaUser) {
        BOOL didAuth = self.room.documentVM.authorizedH5PPT;
        [alert bjl_addActionWithTitle:didAuth ? BJLLocalizedString(@"取消课件授权") : BJLLocalizedString(@"课件授权") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            bjl_strongify(self);
            [self H5AuthButtonEventHandler];
        }];
    }

    if (playingVideo) {
        // PPT或者播放辅助摄像头可以全屏或放大
        [alert bjl_addActionWithTitle:fullscreen ? BJLLocalizedString(@"退出全屏") : BJLLocalizedString(@"全屏") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            bjl_strongify(self);
            if (fullscreen) {
                [self restoreCurrentFullscreenWindow];
            }
            else {
                [self replaceFullscreenWithWindowType:BJLScWindowType_ppt mediaInfoView:self.teacherExtraMediaInfoView];
            }
        }];
        if (!fullscreen) {
            // 不在全屏区域可以放大
            BOOL cannotExpandWindowCase = self.room.roomInfo.isPureVideo || (self.room.roomInfo.isVideoWall && self.roomLayout != BJLRoomLayout_blackboard);
            if (!cannotExpandWindowCase) {
                [alert bjl_addActionWithTitle:BJLLocalizedString(@"切换窗口") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                    bjl_strongify(self);
                    if (self.minorWindowType == BJLScWindowType_ppt) {
                        if (self.room.roomVM.liveStarted
                            && self.room.loginUser.isTeacherOrAssistant
                            && self.room.featureConfig.shouldSyncPPTVideoSwitch) {
                            bjl_strongify(self);
                            UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil
                                                                                                         message:BJLLocalizedString(@"切换视频窗口与白板位置，学生端是否同步切换？")
                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                            [alertViewController bjl_addActionWithTitle:BJLLocalizedString(@"仅本地切换")
                                                                  style:UIAlertActionStyleCancel
                                                                handler:^(UIAlertAction *_Nonnull action) {
                                                                    bjl_strongify(self);
                                                                    [self switchPPTViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:NO];
                                                                }];
                            [alertViewController bjl_addActionWithTitle:BJLLocalizedString(@"同步切换")
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *_Nonnull action) {
                                                                    bjl_strongify(self);
                                                                    [self switchPPTViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:YES];
                                                                }];
                            if (self.presentedViewController) {
                                [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
                            }
                            [self presentViewController:alertViewController animated:YES completion:nil];
                        }
                        else {
                            [self switchPPTViewFromMinorToMajorViewWithShouldSyncPPTVideoSwitch:NO];
                        }
                    }
                    else if (self.secondMinorWindowType == BJLScWindowType_ppt) {
                        [self replaceMajorContentViewWithPPTView];
                        [self replaceSecondMinorContentViewWithSecondMinorMediaInfoView];
                    }
                }];
            }
        }
    }

    if (self.showTeacherExtraMediaInfoViewCoverPPT) {
        if (mediaUser.videoOn) {
            // 开启的辅助摄像头可以播放或关闭
            [alert bjl_addActionWithTitle:playingVideo ? BJLLocalizedString(@"关闭视频") : BJLLocalizedString(@"开启视频")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      BJLError *error = [self.room.playingVM updatePlayingUserWithID:mediaUser.ID videoOn:!playingVideo mediaSource:mediaUser.mediaSource];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                      else {
                                          // 主动关闭老师辅助摄像头后不再自动打开
                                          [self.teacherExtraMediaInfoView updateCloseVideoPlaceholderHidden:!playingVideo];
                                          [self updateAutoPlayVideoBlacklist:mediaUser add:playingVideo];
                                          if (fullscreen && playingVideo) {
                                              // 关闭画面退出全屏
                                              [self restoreCurrentFullscreenWindow];
                                          }
                                      }
                                  }];
        }
    }

    [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消")
                            style:UIAlertActionStyleCancel
                          handler:nil];
    sourceView = sourceView ?: self.minorContentView;
    [self showAlertViewController:alert sourceView:sourceView];
}

- (void)showMenuForStudentVideoWithSourceView:(nullable UIView *)sourceView mediaInfoView:(BJLScMediaInfoView *)mediaInfoView {
    bjl_weakify(self);

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:BJLLocalizedString(@"视频")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];
    BOOL fullscreen = self.fullscreenWindowType == BJLScWindowType_userVideo && self.fullscreenMediaInfoView == mediaInfoView;
    BJLMediaUser *mediaUser = mediaInfoView.mediaUser;
    BOOL playingVideo = NO;
    if (!mediaUser && [self.room.loginUser isSameUser:mediaInfoView.user]) {
        playingVideo = self.room.recordingVM.recordingVideo;
    }
    else {
        if (mediaUser.videoOn) {
            playingVideo = [self isVideoPlayingUser:mediaUser];
        }
        else if (self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.noGroup && mediaUser.isStudent) {
            // 未打开摄像头的用户根据当前登录用户的身份有点赞的操作，否则无菜单项
        }
        else {
            return;
        }
    }
    if (playingVideo) {
        // 在播放画面的用户可以全屏和放大
        [alert bjl_addActionWithTitle:fullscreen ? BJLLocalizedString(@"退出全屏") : BJLLocalizedString(@"全屏") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            bjl_strongify(self);
            if (fullscreen) {
                [self restoreCurrentFullscreenWindow];
            }
            else {
                [self replaceFullscreenWithWindowType:BJLScWindowType_userVideo mediaInfoView:mediaInfoView];
            }
        }];
        if (!fullscreen) {
            // 不在全屏区域可以放大
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"切换窗口") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                bjl_strongify(self);
                if (self.majorWindowType == BJLScWindowType_teacherVideo) {
                    // 大屏是老师视频时，先把老师视频放回小屏
                    [self replaceMinorContentViewWithTeacherMediaInfoView];
                }
                [self replaceMajorContentViewWithUserMediaInfoView:mediaInfoView];
                [self replaceSecondMinorContentViewWithPPTView];
            }];
        }
        if (!self.room.featureConfig.disableGrantDrawing
            && self.room.loginUser.isTeacherOrAssistant
            && self.room.loginUser.noGroup
            && !mediaUser.isTeacherOrAssistant) {
            BOOL wasGranted = [self.room.drawingVM.drawingGrantedUserNumbers containsObject:mediaUser.number ?: @""];
            [alert bjl_addActionWithTitle:wasGranted ? BJLLocalizedString(@"收回画笔") : BJLLocalizedString(@"授权画笔")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      BJLError *error =
                                          [self.room.drawingVM updateDrawingGranted:!wasGranted
                                                                         userNumber:mediaUser.number
                                                                              color:nil];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                  }];
        }
    }

    if ([self.room.loginUser isSameUser:mediaInfoView.user]) {
        if (self.room.recordingVM.recordingVideo) {
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"切换摄像头")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      if (!self.room.recordingVM.recordingVideo) {
                                          return;
                                      }
                                      BJLError *error = [self.room.recordingVM updateUsingRearCamera:!self.room.recordingVM.usingRearCamera];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                  }];

            // WebRTC 的课程无美颜
            if (!self.room.featureConfig.isWebRTC) {
                [alert bjl_addActionWithTitle:(self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_off
                                                      ? BJLLocalizedString(@"开启美颜")
                                                      : BJLLocalizedString(@"关闭美颜"))
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *_Nonnull action) {
                                          bjl_strongify(self);
                                          if (!self.room.recordingVM.recordingVideo) {
                                              return;
                                          }
                                          BJLError *error = [self.room.recordingVM updateVideoBeautifyLevel:(self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_off
                                                                                                                    ? BJLVideoBeautifyLevel_on
                                                                                                                    : BJLVideoBeautifyLevel_off)];
                                          if (error) {
                                              [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                          }
                                      }];
            }
        }

        [alert bjl_addActionWithTitle:self.room.recordingVM.recordingVideo ? BJLLocalizedString(@"关闭摄像头") : BJLLocalizedString(@"打开摄像头")
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction *_Nonnull action) {
                                  bjl_strongify(self);
                                  BJLError *error = [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                                                              recordingVideo:!self.room.recordingVM.recordingVideo];
                                  if (error) {
                                      [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                  }
                                  else {
                                      [self showProgressHUDWithText:(self.room.recordingVM.recordingVideo
                                                                            ? BJLLocalizedString(@"摄像头已打开")
                                                                            : BJLLocalizedString(@"摄像头已关闭"))];
                                      if (fullscreen && !self.room.recordingVM.recordingVideo) {
                                          // 关闭摄像头退出全屏
                                          [self restoreCurrentFullscreenWindow];
                                      }
                                  }
                              }];
    }
    else {
        if (mediaUser.videoOn) {
            // 用户开启了摄像头可以选择播放或者关闭画面
            [alert bjl_addActionWithTitle:playingVideo ? BJLLocalizedString(@"关闭视频") : BJLLocalizedString(@"开启视频")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      BJLError *error = [self.room.playingVM updatePlayingUserWithID:mediaUser.ID videoOn:!playingVideo mediaSource:mediaUser.mediaSource];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                      else {
                                          // 主动关闭视频后不再自动打开
                                          [mediaInfoView updateCloseVideoPlaceholderHidden:!playingVideo];
                                          [self updateAutoPlayVideoBlacklist:mediaUser add:playingVideo];
                                          if (fullscreen && playingVideo) {
                                              // 关闭画面退出全屏
                                              [self restoreCurrentFullscreenWindow];
                                          }
                                      }
                                  }];
        }
        if (self.room.loginUser.isTeacherOrAssistant
            && self.room.loginUser.noGroup
            && mediaUser.isStudent) {
            // 当前是老师或者助教可以给用户点赞
            [alert bjl_addActionWithTitle:BJLLocalizedString(@"奖励")
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *_Nonnull action) {
                                      bjl_strongify(self);
                                      BJLError *error = [self.room.roomVM sendLikeForUserNumber:mediaUser.number];
                                      if (error) {
                                          [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                      }
                                  }];
        }
    }

    [alert bjl_addActionWithTitle:BJLLocalizedString(@"取消")
                            style:UIAlertActionStyleCancel
                          handler:nil];
    sourceView = sourceView ?: self.secondMinorContentView;
    [self showAlertViewController:alert sourceView:sourceView];
}

- (void)showAlertViewController:(UIAlertController *)alertController sourceView:(UIView *)sourceView {
    if (alertController.preferredStyle == UIAlertControllerStyleActionSheet) {
        alertController.popoverPresentationController.sourceView = sourceView;
        alertController.popoverPresentationController.sourceRect = ({
            CGRect rect = sourceView.bounds;
            rect.origin.y = CGRectGetMaxY(rect) - 1.0;
            rect.size.height = 1.0;
            rect;
        });
        alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    }
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateAutoPlayVideoBlacklist:(BJLMediaUser *)user add:(BOOL)add {
    if (add) {
        [self.autoPlayVideoBlacklist addObject:[self videoKeyForUser:user]];
    }
    else {
        [self.autoPlayVideoBlacklist removeObject:[self videoKeyForUser:user]];
    }
}

- (BOOL)isVideoPlayingUser:(BJLMediaUser *)mediaUser {
    for (BJLMediaUser *user in [self.room.playingVM.videoPlayingUsers copy]) {
        if ([user isSameMediaUser:mediaUser]) {
            return YES;
        }
    }
    return NO;
}

- (void)mirrorVideoHorizontally {
    BOOL mirrorH = ([self.room.recordingVM videoEncoderMirrorModeForUser:self.room.loginUser error:nil] & BJLEncoderMirrorModeHorizontal) != 0;
    BOOL mirrorV = ([self.room.recordingVM videoEncoderMirrorModeForUser:self.room.loginUser error:nil] & BJLEncoderMirrorModeVertical) != 0;
    mirrorH = !mirrorH;

    BJLEncoderMirrorMode mode = 0;
    if (mirrorH) {
        mode |= BJLEncoderMirrorModeHorizontal;
    }
    if (mirrorV) {
        mode |= BJLEncoderMirrorModeVertical;
    }

    BJLError *error = [self.room.recordingVM updateVideoEncoderMirrorMode:mode forUser:self.room.loginUser];
    if (error) {
        [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
    }
}

- (void)mirrorVideoVertically {
    BOOL mirrorV = ([self.room.recordingVM videoEncoderMirrorModeForUser:self.room.loginUser error:nil] & BJLEncoderMirrorModeVertical) != 0;
    BOOL mirrorH = ([self.room.recordingVM videoEncoderMirrorModeForUser:self.room.loginUser error:nil] & BJLEncoderMirrorModeHorizontal) != 0;
    mirrorV = !mirrorV;

    BJLEncoderMirrorMode mode = 0;
    if (mirrorV) {
        mode |= BJLEncoderMirrorModeVertical;
    }
    if (mirrorH) {
        mode |= BJLEncoderMirrorModeHorizontal;
    }

    BJLError *error = [self.room.recordingVM updateVideoEncoderMirrorMode:mode forUser:self.room.loginUser];
    if (error) {
        [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
    }
}

#pragma mark - screenCapture
- (void)screenCaptureAlertHandler {
    if (!self.room.featureConfig.enablePreventScreenCapture) {
        return;
    }

    if (self.room.recordingVM.screenCaptured) {
        [self.screenCaptureAlertView showInParentView:self.view];
    }
    else {
        [self.screenCaptureAlertView hide];
    }
}

#pragma mark - 主屏公告打开

- (BOOL)openURL:(NSURL *)url {
    BOOL shouldOpen = NO;
    NSString *scheme = url.scheme.lowercaseString;
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
        if (self.presentedViewController) {
            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self bjl_presentFullScreenViewController:safari animated:YES completion:nil];
    }
    else if ([scheme hasPrefix:@"bjhl"]) {
        shouldOpen = YES;
    }
    else {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:BJLLocalizedString(@"不支持打开此链接")
                             message:nil
                      preferredStyle:UIAlertControllerStyleAlert];
        [alert bjl_addActionWithTitle:BJLLocalizedString(@"知道了")
                                style:UIAlertActionStyleCancel
                              handler:nil];
        if (self.presentedViewController) {
            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
    return shouldOpen;
}

@end
