//
//  BJLScRoomViewController+observing.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScRoomViewController+observing.h"
#import "BJLScRoomViewController+private.h"
#import "BJLLikeEffectViewController.h"

@implementation BJLScRoomViewController (observing)

- (void)makeObservingBeforeEnterRoom {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, featureConfig)
         observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.featureConfig) {
                 if (self.room.featureConfig.shouldVideoInMajor) {
                     self.majorWindowType = BJLScWindowType_teacherVideo;
                     self.minorWindowType = BJLScWindowType_ppt;
                 }
                 if (self.room.featureConfig.enableAutoVideoFullscreen && self.room.roomInfo.isVideoWall) {
                     self.fullscreenWindowType = BJLScWindowType_teacherVideo;
                 }
             }
             return YES;
         }];
    [self bjl_kvo:BJLMakeProperty(self.room, roomInfo)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.roomInfo) {
                 if (self.room.roomInfo.isPureVideo || self.room.roomInfo.isVideoWall) {
                     self.majorWindowType = BJLScWindowType_teacherVideo;
                     self.minorWindowType = BJLScWindowType_ppt;
                 }
             }
             return YES;
         }];

    [self bjl_observe:BJLMakeMethod(self.room, enterRoomSuccess)
             observer:^BOOL {
                 bjl_strongify(self);

                 [self roomViewControllerEnterRoomSuccess:self];
                 self.reachability = ({
                     __block BOOL isFirstTime = YES;
                     BJLAFNetworkReachabilityManager *reachability = [BJLAFNetworkReachabilityManager manager];
                     [reachability setReachabilityStatusChangeBlock:^(BJLAFNetworkReachabilityStatus status) {
                         bjl_strongify(self);
                         if (status != BJLAFNetworkReachabilityStatusReachableViaWWAN) {
                             return;
                         }
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             if (status != BJLAFNetworkReachabilityStatusReachableViaWWAN) {
                                 return;
                             }
                             if (isFirstTime) {
                                 isFirstTime = NO;
                                 UIAlertController *alert = [UIAlertController
                                     alertControllerWithTitle:BJLLocalizedString(@"正在使用3G/4G网络，可手动关闭视频以减少流量消耗")
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
                             else {
                                 [self showProgressHUDWithText:BJLLocalizedString(@"正在使用3G/4G网络")];
                             }
                         });
                     }];
                     [reachability startMonitoring];
                     reachability;
                 });

                 // 进入直播间成功才设置 block
                 [self.room setReloadingBlock:^(BJLLoadingVM *_Nonnull reloadingVM, void (^_Nonnull callback)(BOOL)) {
                     bjl_strongify(self);
                     [self makeObservingForLoadingVM:reloadingVM];

                     callback(YES);
                 }];

                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, enterRoomFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self roomViewController:self enterRoomFailureWithError:error];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, roomWillExitWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 // 退出直播间时让跑马灯停下来
                 if (self.lampConstructor) {
                     [NSObject cancelPreviousPerformRequestsWithTarget:self.lampConstructor];
                     self.lampConstructor = nil;
                 }
                 if (self.room.loginUser.isTeacher
                     && error.code != BJLErrorCode_exitRoom_loginConflict) {
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, roomDidExitWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self roomDidExitWithError:error];
                 return YES;
             }];
}

- (void)makeObserving {
    bjl_weakify(self);

#pragma mark - common

    [self bjl_kvo:BJLMakeProperty(self.room, state)
        filter:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            return (BJLRoomState)[value integerValue] == BJLRoomState_connected;
        }
        observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self makeObservingWhenEnteredInRoom];
            return NO;
        }];

    [self bjl_observe:BJLMakeMethod(self.room.recordingVM, recordingDidDeny)
             observer:^BOOL {
                 bjl_strongify(self);
                 [self showProgressHUDWithText:BJLLocalizedString(@"服务器拒绝发布音视频，音视频并发已达上限")];
                 return YES;
             }];

#pragma mark - 上课状态

    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, liveStarted)
         observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.loginUser.isAudition) {
                 return YES;
             }
             // 上课按钮
             if (self.room.loginUser.isTeacher
                 || (self.room.loginUser.isAssistant && self.room.roomVM.getAssistantaAuthorityWithClassStartEnd)) {
                 // 线上双师小班老师或助教进入大班不显示开始上课按钮
                 self.liveStartButton.hidden = now.boolValue;

                 if (self.room.loginUser.isAssistant && (!self.room.loginUser.noGroup || self.room.roomInfo.isMockLive)) {
                     self.liveStartButton.hidden = YES;
                 }
             }
             if (now.boolValue != old.boolValue) {
                 // 显示提示
                 [self showProgressHUDWithText:now.boolValue ? BJLLocalizedString(@"上课啦") : BJLLocalizedString(@"下课啦")];
                 // 上下课重置全屏状态
                 if (self.fullscreenWindowType != BJLScWindowType_none && !self.room.featureConfig.enableAutoVideoFullscreen) {
                     [self restoreCurrentFullscreenWindow];
                 }
             }
             // 上课开启采集
             if (self.room.roomVM.liveStarted) {
                 [self autoStartRecordingAudioAndVideoForce:YES];
             }
             else {
                 [self.room.recordingVM setRecordingAudio:NO recordingVideo:NO];
             }

             // 点播暖场
             [self updateWarmingUpView];
             return YES;
         }];

#pragma mark - 视频列表

    if (!self.is1V1Class) {
        [self bjl_kvoMerge:@[BJLMakeProperty(self.room.recordingVM, recordingVideo),
            BJLMakeProperty(self.room.mainPlayingAdapterVM, playingUsers),
            BJLMakeProperty(self.room.extraPlayingAdapterVM, playingUsers)]
                  observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                      bjl_strongify(self);
                      [self updateVideosConstraintsWithCurrentPlayingUsers];
                  }];
    }

#pragma mark - 主讲视频

    [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, currentPresenter)
         observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.onlineUsersVM.currentPresenter) {
                 [self updateTeacherVideoView];
             }
             else if (self.teacherMediaInfoView) {
                 // 全屏区域，老师消失，复原全屏
                 if (self.teacherMediaInfoView.isFullScreen && !self.room.featureConfig.enableAutoVideoFullscreen) {
                     [self restoreCurrentFullscreenWindow];
                 }
                 [self.teacherMediaInfoView removeFromSuperview];
                 [self.teacherMediaInfoView destroyView];
                 self.teacherMediaInfoView = nil;
                 [self updateTeacherVideoPlaceholderView];
             }
             [self updateVideosConstraintsWithCurrentPlayingUsers];

             if (oldValue && value && oldValue != value && ![value isSameUser:oldValue] &&
                 [oldValue isSameUser:self.room.loginUser] && self.room.featureConfig.enableAutoCloseOldPresenterMedia) {
                 //自己以前是主讲,现在被切换到其他人
                 //大班课切主讲以后，旧的主讲人根据配置关闭音视频推送
                 if (self.room.recordingVM.hasAsCameraUser) {
                     [self.room.recordingVM stopAsCameraUserCompletion:^{
                         bjl_strongify(self);
                         if (self.room.recordingVM.recordingVideo || self.room.recordingVM.recordingAudio) {
                             [self.room.recordingVM setRecordingAudio:NO recordingVideo:NO];
                         }
                     }];
                 }
                 else {
                     if (self.room.recordingVM.recordingVideo || self.room.recordingVM.recordingAudio) {
                         [self.room.recordingVM setRecordingAudio:NO recordingVideo:NO];
                     }
                 }
             }

             return YES;
         }];

#pragma mark - 学生视频

    if (self.is1V1Class) {
        [self bjl_kvo:BJLMakeProperty(self.room.playingVM, playingUsers)
             observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 BJLMediaUser *targetUser = nil;
                 for (BJLMediaUser *user in [self.room.playingVM.playingUsers copy]) {
                     if (user.isStudent) {
                         targetUser = user;
                         break;
                     }
                 }
                 if (self.room.loginUser.isTeacherOrAssistant) {
                     if ([self.secondMinorMediaInfoView.mediaUser isSameUser:targetUser]) {
                         return YES;
                     }
                     [self updateSecondMinorContentViewWithUser:targetUser recording:NO];
                 }
                 else {
                     if (!self.secondMinorMediaInfoView) {
                         // 有其他学生在，理论上不应存在
                         if (targetUser) {
                             [self updateSecondMinorContentViewWithUser:targetUser recording:NO];
                         }
                         else {
                             // 显示当前学生状态
                             [self updateSecondMinorContentViewWithUser:nil recording:YES];
                         }
                     }
                 }
                 return YES;
             }];
    }

#pragma mark - majorWindowType, minorWindowType

    [self bjl_kvoMerge:@[BJLMakeProperty(self, majorWindowType),
        BJLMakeProperty(self, fullscreenWindowType)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updatePPTUserInteractionEnable];
              }];

    [self bjl_kvoMerge:@[BJLMakeProperty(self, fullscreenWindowType)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updateTeacherVideoPlaceholderView];
              }];

    [self bjl_kvoMerge:@[BJLMakeProperty(self, majorWindowType),
        BJLMakeProperty(self, minorWindowType)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updateTeacherVideoPlaceholderView];
              }];

#pragma mark - ppt 页码

    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.documentVM, allDocuments),
        BJLMakeProperty(self.room.slideshowViewController, viewType),
        BJLMakeProperty(self.room.documentVM, currentSlidePage),
        BJLMakeProperty(self.room.slideshowViewController, pageIndex)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  NSInteger pageIndex = self.room.slideshowViewController.pageIndex;
                  BJLDocument *whiteboardDocument = [self.room.documentVM documentWithID:BJLBlackboardID];
                  NSInteger whiteboardPageCount = MAX(whiteboardDocument.pageInfo.pageCount, 1);
                  if (pageIndex + 1 <= whiteboardPageCount) {
                      [self.room.slideshowViewController.pageControlButton setTitle:(whiteboardPageCount > 1 ? [NSString stringWithFormat:BJLLocalizedString(@"白板%td"), pageIndex + 1] : BJLLocalizedString(@"白板")) forState:UIControlStateNormal];
                  }
                  else {
                      [self.room.slideshowViewController.pageControlButton setTitle:[NSString stringWithFormat:@"%td/%td", pageIndex - whiteboardPageCount + 1, self.room.documentVM.totalPageCount - whiteboardPageCount] forState:UIControlStateNormal];
                  }
              }];

    // 记住每个ppt使用后的页码,下次切换到该PPT时,直接更新到上次的页面, 默认0(首页)
    [self bjl_kvo:BJLMakeProperty(self.room.documentVM, currentSlidePage)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             NSString *documentID = self.room.documentVM.currentSlidePage.documentID;
             NSInteger index = self.room.documentVM.currentSlidePage.slidePageIndex;
             [self.documentIndexDic bjl_setObject:@(index) forKey:documentID];
             return YES;
         }];

#pragma mark - 跑马灯

    [self bjl_kvoMerge:@[BJLMakeProperty(self, customLampContent),
        BJLMakeProperty(self.room.roomVM, lamp)]
               options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              observer:^(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  // 先让前跑马灯停下来
                  if (self.lampConstructor) {
                      [self.lampConstructor destoryLampLabel];
                      self.lampConstructor = nil;
                  }
                  [self updateLamp];
              }];
    // 第一次手动触发
    [self updateLamp];
    [self bjl_kvo:BJLMakeProperty(self, fullscreenWindowType)
          options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
         observer:^BJLControlObserving(NSNumber *_Nullable value, NSNumber *_Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if ((oldValue.bjl_integerValue != BJLScWindowType_none
                     && value.bjl_integerValue == BJLScWindowType_none)
                 || (oldValue.bjl_integerValue == BJLScWindowType_none
                     && value.bjl_integerValue != BJLScWindowType_none)) {
                 [self updateLampViewConstraints];
             }
             return YES;
         }];

#pragma mark - 公告
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, notice)
        filter:^BOOL(BJLNotice *_Nullable now, BJLNotice *_Nullable old, BJLPropertyChange *_Nullable change) {
            if (now.noticeText.length || now.linkURL) {
                return YES;
            }

            BOOL hasChange = NO;
            for (BJLNoticeModel *notice in now.groupNoticeList) {
                if (notice.noticeText.length || notice.linkURL) {
                    hasChange = YES;
                    break;
                }
            }
            return hasChange;
        }
        observer:^BOOL(BJLNotice *_Nullable notice, id _Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);

            [self.overlayViewController showWithContentViewController:self.noticeViewController contentView:nil];
            [self.noticeViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.center.equalTo(self.overlayViewController.view);
                make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                make.height.equalTo(self.overlayViewController.view).multipliedBy(iPhone ? 0.83 : 0.38);
            }];
            return YES;
        }];

#pragma mark - 主屏公告

    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, majorNotice)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self resetMajorNotice];
             return YES;
         }];
    [self resetMajorNotice];

#pragma mark - webrtc

    if (self.room.featureConfig.isWebRTC) {
        // webRTC 进入直播频道失败
        [self bjl_observe:BJLMakeMethod(self.room.mediaVM, enterLiveChannelFailed)
                 observer:^BOOL {
                     bjl_strongify(self);
                     [self showProgressHUDWithText:BJLLocalizedString(@"进入直播频道失败，请重试")];
                     return YES;
                 }];

        // webRTC 直播频道断开提示
        [self bjl_observe:BJLMakeMethod(self.room.mediaVM, didLiveChannelDisconnectWithError:)
                 observer:^BOOL(NSError *error) {
                     bjl_strongify(self);
                     [self showProgressHUDWithText:BJLLocalizedString(@"直播频道已断开，请重试")];
                     return YES;
                 }];

        // webRTC 推流重试提示
        [self bjl_observe:BJLMakeMethod(self.room.recordingVM, republishing)
                 observer:^BOOL {
                     bjl_strongify(self);
                     [self showProgressHUDWithText:BJLLocalizedString(@"音视频推送失败，自动重试中")];
                     return YES;
                 }];

        // webRTC 推流重试提示
        [self bjl_observe:BJLMakeMethod(self.room.recordingVM, publishFailed)
                 observer:^BOOL {
                     bjl_strongify(self);
                     [self showProgressHUDWithText:BJLLocalizedString(@"音视频推送失败，请重试")];
                     return YES;
                 }];
    }

#pragma mark - 工具显示

    [self bjl_kvoMerge:@[BJLMakeProperty(self, controlsHidden),
        BJLMakeProperty(self, teacherExtraMediaInfoView),
        BJLMakeProperty(self.toolViewController, expectedHidden),
        BJLMakeProperty(self, majorWindowType),
        BJLMakeProperty(self, fullscreenWindowType)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  // 当前是全屏状态
                  if (self.fullscreenWindowType != BJLScWindowType_none) {
                      // 存在全屏课件时，根据是否有权限来显示画笔，忽略掉其他控件是否显示的状态
                      if (self.fullscreenWindowType == BJLScWindowType_ppt
                          && (!self.teacherExtraMediaInfoView
                              || !self.showTeacherExtraMediaInfoViewCoverPPT)) {
                          self.toolHidden = self.toolViewController.expectedHidden;
                      }
                      // 否则始终隐藏
                      else {
                          self.toolHidden = YES;
                      }
                  }
                  // 当前不是全屏状态
                  else {
                      // 存在大屏课件时
                      if (self.majorWindowType == BJLScWindowType_ppt
                          && (!self.teacherExtraMediaInfoView
                              || !self.showTeacherExtraMediaInfoViewCoverPPT)) {
                          // 如果隐藏了其他控件
                          if (self.controlsHidden) {
                              // 如果当前正在使用画笔中，根据视图的自预期效果控制
                              if ((self.room.drawingVM.drawingGranted
                                      && self.room.drawingVM.drawingEnabled)
                                  || [self.toolViewController pptButtonIsSelect]) {
                                  self.toolHidden = self.toolViewController.expectedHidden;
                              }
                              // 不在使用画笔中就和其他控件效果保持一致
                              else {
                                  self.toolHidden = self.controlsHidden;
                              }
                          }
                          // 如果没隐藏其他控件，视图的自预期效果控制
                          else {
                              self.toolHidden = self.toolViewController.expectedHidden;
                          }

                          // 当前课程未开始 且 教师视频在大窗口 且 有暖场的点播视频, 大屏课件时, 不再强制隐藏 controlsViewController
                          if (!self.room.roomVM.liveStarted
                              && self.teacherMediaInfoView.positionType == BJLScPositionType_major
                              && self.warmingUpView != nil) {
                              self.controlsViewController.controlsHidden = self.controlsHidden;
                          }
                      }
                      // 否则始终隐藏
                      else {
                          self.toolHidden = YES;
                      }
                  }
              }];

    [self bjl_kvoMerge:@[BJLMakeProperty(self, fullscreenWindowType),
        BJLMakeProperty(self, majorWindowType)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  if (self.fullscreenWindowType != BJLScWindowType_none) {
                      if (!self.room.roomVM.liveStarted
                          && self.fullscreenWindowType == BJLScWindowType_teacherVideo
                          && self.warmingUpView != nil) {
                          // 当前课程未开始 且 老师视频全屏 且 有点播暖场视频, 则不处理
                      }
                      else {
                          [self.controlsViewController updateControlsForWindowType:self.fullscreenWindowType fullScreen:YES];
                      }
                  }
                  else if (self.majorWindowType != BJLScWindowType_none) {
                      [self.controlsViewController updateControlsForWindowType:self.majorWindowType fullScreen:NO];
                  }

                  if (self.fullscreenWindowType != BJLScWindowType_none) {
                      self.controlsViewController.moreOptionButton.hidden = YES;
                  }
                  else {
                      if (self.majorWindowType == BJLScWindowType_teacherVideo
                          || self.majorWindowType == BJLScWindowType_userVideo) {
                          self.controlsViewController.moreOptionButton.hidden = NO;
                      }
                      else {
                          self.controlsViewController.moreOptionButton.hidden = YES;
                      }
                  }

                  return;
              }];

    [self bjl_kvo:BJLMakeProperty(self, toolHidden)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.toolViewController updateToolViewHidden:self.toolHidden];
             return YES;
         }];

    BOOL iphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (iphone) {
        bjl_weakify(self);

        [self bjl_kvo:BJLMakeProperty(self.videosView, bounds)
             observer:^BOOL(id now, id old, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);

                 CGFloat offset = BJLScViewSpaceM;
                 if (self.videosView.bounds.size.height < 0.1f) {
                     //这里是顶部状态栏的高度，iphone下需要让controlsViewController中的
                     //控件避开状态栏
                     offset += 32.0;
                 }
                 self.controlsViewController.controlsTopOffset = offset;

                 return YES;
             }];
    }

    // 全屏时调整主屏公告的约束
    [self bjl_kvo:BJLMakeProperty(self, fullscreenWindowType)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self resetMajorNoticeWhenFullScreenStateChanged];
             return YES;
         }];

    // requiresFullScreen 配置如果不勾选，需要添加页面屏蔽逻辑
    BOOL disableRequiresFullScreenMask = self.room.featureConfig.disableRequiresFullScreenMask;
    BOOL requiresFullScreen = BJLRequireFullScreenCheckFailedMaskView.requireFullScreenIsChecked;
    if (!requiresFullScreen && !disableRequiresFullScreenMask) {
        [self bjl_kvo:BJLMakeProperty(self.view, frame) //这里用frame才会即时回调
             observer:^BOOL(id now, id old, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);

                 if (CGRectContainsRect(self.view.bounds, UIScreen.mainScreen.bounds) && self.view.bounds.size.width > self.view.bounds.size.height) {
                     [self.requireFullScreenCheckFailedMaskView hide];
                 }
                 else {
                     [self.requireFullScreenCheckFailedMaskView showInParentView:self.view];
                 }

                 return YES;
             }];
    }

#pragma mark - 设置

    [self bjl_kvo:BJLMakeProperty(self.room, state)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.state == BJLRoomState_connected) {
                 if (self.overlayViewController.viewController == self.settingsViewController) {
                     [self.overlayViewController hide];
                 }
                 [self.settingsViewController bjl_removeFromParentViewControllerAndSuperiew];
                 self.settingsViewController = nil;
             }
             return YES;
         }];

#pragma mark - 美颜

    [self bjl_kvo:BJLMakeProperty(self.room.mediaVM, inLiveChannel) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        BOOL enableCamera = self.room.recordingVM.recordingVideo && !self.room.recordingVM.hasAsCameraUser;
        BOOL inLiveChannel = self.room.mediaVM.inLiveChannel;
        if (inLiveChannel && enableCamera) {
            // 加入直播通道后再设置美颜, 推流端才会显示美颜效果
            float beautyLevel = self.room.featureConfig.enableBeauty ? 4.5 : self.room.recordingVM.beautyLevel;
            float whitenessLevel = self.room.featureConfig.enableBeauty ? 4.5 : self.room.recordingVM.whitenessLevel;
            [self.room.recordingVM updateBeautyLevel:beautyLevel];
            [self.room.recordingVM updateWhitenessLevel:whitenessLevel];
        }
        return YES;
    }];
}

- (void)makeObservingForLoadingVM:(BJLLoadingVM *)loadingVM {
    bjl_weakify(self);
    loadingVM.suspendBlock = ^(BJLLoadingStep step,
        BJLLoadingSuspendReason reason,
        BJLError *error,
        void (^continueCallback)(BOOL isContinue)) {
        bjl_strongify(self);
        // 成功
        BOOL enterWrongTemplate = NO;
        if (reason != BJLLoadingSuspendReason_errorOccurred) {
            if (self.room.roomInfo && self.room.roomInfo.roomType == BJLRoomType_interactiveClass) {
                enterWrongTemplate = YES;
            }
            else {
                continueCallback(YES);
                return;
            }
        }

        // 直接退出

        if (error.code == BJLErrorCode_enterRoom_auditionTimeout) {
            continueCallback(NO);
            return;
        }

        // 出错

        if (!error) {
            error = BJLErrorMake(BJLErrorCode_unknown, nil);
        }

        if (enterWrongTemplate) {
            error = BJLErrorMake(BJLErrorCode_enterRoom_unsupportedClient, BJLLocalizedString(@"班型错误"));
        }

        if (error.code == BJLErrorCode_enterRoom_timeExpire) {
            BJLPopoverViewController *popoverViewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLExitViewTimeOut message:[NSString stringWithFormat:BJLLocalizedString(@"直播间已过期")]];
            [self bjl_addChildViewController:popoverViewController superview:self.popoversLayer];
            [popoverViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.popoversLayer);
            }];
            [popoverViewController setConfirmCallback:^{
                bjl_strongify(self);
                continueCallback(NO);
                [self exit];
            }];
        }
        else {
            BJLPopoverViewController *popoverViewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLExitViewConnectFail message:[NSString stringWithFormat:BJLLocalizedString(@"网络连接失败（%td-%td），您可以退出或继续连接"), step, reason] detailMessage:self.room.roomInfo.customerSupportMessage];
            [self bjl_addChildViewController:popoverViewController superview:self.popoversLayer];
            [popoverViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.popoversLayer);
            }];
            [popoverViewController setCancelCallback:^{
                bjl_strongify(self);
                continueCallback(NO);
                [self exit];
            }];
            [popoverViewController setConfirmCallback:^{
                continueCallback(YES);
            }];
        }
    };

    [self bjl_observe:BJLMakeMethod(loadingVM, loadingFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self roomDidExitWithError:error];
                 return YES;
             }];
}

#pragma mark - makeObservingWhenEnteredInRoom

- (void)makeObservingWhenEnteredInRoom {
    if (self.room.loginUser.isAssistant) {
        [self makeObservingForSpeaking];
        [self makeObservingForAssistant];
        [self makeObservingForRollcall];
    }
    else {
        [self makeObservingForSpeaking];
        [self makeObservingForAttentionWarning];
        [self makeObservingForRollcall];
        [self makeObservingForEvaluation];
        [self makeObservingForQuiz];
        [self makeObservingForCustomWebView];
    }

    [self makeObservingForVideoPosition];
    //[self makeObservingForPPTAndDrawing];
    [self makeObservingForProgressHUD];
    [self makeObservingForEnvelope];
    [self makeObservingForLikeEffect];
    [self.countDownManager makeObserver];
    [self makeObservingForQuestion];
    [self.questionAnswerManager makeObeservingForQuestionAnswer];
    bjl_weakify(self);
    [self.questionAnswerManager setShowErrorMessageCallback:^(NSString *_Nonnull message) {
        bjl_strongify(self);
        [self showProgressHUDWithText:message];
    }];
    [self makeObservingForBonusPoints];
    [self makeObservingForShowLotteryResult];
    [self.questionResponderManager makeObservingForQuestionResponder];
    [self.questionResponderManager setShowErrorMessageCallback:^(NSString *_Nonnull message) {
        bjl_strongify(self);
        [self showProgressHUDWithText:message];
    }];
    [self.questionResponderManager setQuestionResponderSuccessCallback:^(BJLUser *_Nonnull user, UIButton *_Nullable button) {
        bjl_strongify(self);
        [self showQuestionResponderEffectViewControllerUser:user likeButton:button];
    }];
    [self makeObservingForScreenCapture];
    [self makeObservingForSwitchRoom];
    [self resetMajorNoticeWhenFullScreenStateChanged];
}

#pragma mark - assistant

- (void)makeObservingForAssistant {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveAssistantaAuthorityChanged) observer:^BOOL {
        bjl_strongify(self);
        [self showProgressHUDWithText:BJLLocalizedString(@"权限已变更")];

        // 如果助教被收回画笔权限，此时也要更新画笔权限，防止此时助教正在使用画笔而没有被收回权限
        if (![self.room.roomVM getAssistantaAuthorityWithPainter]) {
            [self.room.drawingVM updateDrawingEnabled:NO];
        }

        // 助教上下课权限更改
        if (self.room.loginUser.isTeacher || (self.room.loginUser.isAssistant && self.room.roomVM.getAssistantaAuthorityWithClassStartEnd)) {
            self.liveStartButton.hidden = self.room.roomVM.liveStarted;
        }
        else {
            self.liveStartButton.hidden = YES;
        }

        if (self.room.loginUser.isAssistant && !self.room.roomVM.getAssistantaAuthorityWithDocumentUpload) {
            [self.pptManagerViewController hideDocumentPickerViewControllerIfNeeded];
        }

        return YES;
    }];
}

#pragma mark - student

- (void)updateLamp {
    NSString *lampContent = self.customLampContent ?: self.room.roomVM.lamp.content;
    if (!lampContent.length || self.room.roomVM.lamp.alpha == 0) {
        return;
    }
    CGFloat containerViewWidth = (self.fullscreenWindowType != BJLScWindowType_none
                                      ? CGRectGetWidth(self.view.bounds)
                                      : CGRectGetWidth(self.view.bounds) - BJLScSegmentWidth);
    CGFloat containerViewHeight = (self.fullscreenWindowType != BJLScWindowType_none
                                       ? CGRectGetHeight(self.view.bounds)
                                       : CGRectGetHeight(self.view.bounds) - BJLScTopBarHeight - CGRectGetHeight(self.videosView.bounds));
    if (!self.lampConstructor) {
        self.lampConstructor = [[BJLLampConstructor alloc] init];
    }
    [self.lampConstructor updateLampWithLamp:self.room.roomVM.lamp
                                    lampView:self.lampView
                                 lampContent:lampContent
                          containerViewWidth:containerViewWidth + 36
                         containerViewHeight:containerViewHeight];
}

- (void)updateLampViewConstraints {
    if (self.fullscreenWindowType == BJLScWindowType_none) {
        [self.lampView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.majorContentView);
        }];
    }
    else {
        [self.lampView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.fullscreenLayer);
        }];
    }
}

- (void)makeObservingForVideoPosition {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didVideoExchangePositonWithPPT:)
             observer:(BJLMethodObserver) ^ BOOL(BOOL videoInMainPosition) {
                 bjl_strongify(self);
                 // 视频墙模板忽略这个信令
                 if (self.room.roomInfo.isPureVideo || (self.room.roomInfo.isVideoWall && self.roomLayout != BJLRoomLayout_blackboard)) {
                     return YES;
                 }

                 if ((videoInMainPosition && self.majorWindowType == BJLScWindowType_teacherVideo && self.minorWindowType == BJLScWindowType_ppt && self.secondMinorWindowType == BJLScWindowType_userVideo)
                     || (!videoInMainPosition && self.majorWindowType == BJLScWindowType_ppt && self.minorWindowType == BJLScWindowType_teacherVideo && self.secondMinorWindowType == BJLScWindowType_userVideo)) {
                     return YES;
                 }
                 if (self.room.featureConfig.enableAutoVideoFullscreen && self.fullscreenWindowType != BJLScWindowType_none) {
                     BJLScWindowType major = videoInMainPosition ? BJLScWindowType_teacherVideo : BJLScWindowType_ppt;
                     BJLScWindowType minor = videoInMainPosition ? BJLScWindowType_ppt : BJLScWindowType_teacherVideo;
                     if (major != self.majorWindowType) { self.majorWindowType = major; }
                     if (minor != self.minorWindowType) { self.minorWindowType = minor; }
                     return YES;
                 }

                 // 同步切换位置时，全屏复原
                 if (self.fullscreenWindowType != BJLScWindowType_none) {
                     [self restoreCurrentFullscreenWindow];
                 }
                 // 视频列表复原
                 if (self.videosViewController) {
                     [self.videosViewController resetVideo];
                 }
                 // 1v1 复原
                 if (self.secondMinorMediaInfoView) {
                     [self replaceSecondMinorContentViewWithSecondMinorMediaInfoView];
                 }
                 // 替换
                 if (videoInMainPosition) {
                     [self replaceMajorContentViewWithTeacherMediaInfoView];
                     [self replaceMinorContentViewWithPPTView];
                 }
                 else {
                     // !!!: 如果课程未开始, 且当前有暖场视频, 且当前大窗口已经是视频了, 则不切换, ps: pm要求暖场视频强制在大窗口
                     if (!self.room.roomVM.liveStarted
                         && self.warmingUpView
                         && self.majorWindowType == BJLScWindowType_teacherVideo) {
                     }
                     else {
                         [self replaceMinorContentViewWithTeacherMediaInfoView];
                         [self replaceMajorContentViewWithPPTView];
                     }
                 }
                 return YES;
             }];

    if (self.room.roomInfo.isVideoWall) {
        // 视频墙模板使用布局切换的信令决定是否以视频为主
        [self bjl_observe:BJLMakeMethod(self.room.roomVM, didUpdateRoomLayout:)
                 observer:(BJLMethodObserver) ^ BOOL(BJLRoomLayout roomLayout) {
                     bjl_strongify(self);
                     self.roomLayout = roomLayout;

                     [self.minorContentView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                         BOOL iphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
                         if (iphone) {
                             make.width.equalTo(self.containerView).multipliedBy(4.0 / 16.0);
                         }
                         else {
                             make.width.equalTo(@(BJLScSegmentWidth));
                         }
                         make.top.equalTo(self.topBarView.bjl_bottom);
                         make.right.equalTo(self.containerView);

                         if (roomLayout == BJLRoomLayout_blackboard) {
                             make.height.equalTo(self.minorContentView.bjl_width).multipliedBy(9.0 / 16.0);
                         }
                         else {
                             make.height.equalTo(@0.0);
                         }
                     }];

                     if (roomLayout == BJLRoomLayout_gallary
                         && self.majorWindowType != BJLScWindowType_teacherVideo) {
                         [self replaceMajorContentViewWithTeacherMediaInfoView];
                         [self replaceMinorContentViewWithPPTView];
                     }
                     else if (roomLayout == BJLRoomLayout_blackboard
                              && self.majorWindowType != BJLScWindowType_ppt) {
                         [self replaceMinorContentViewWithTeacherMediaInfoView];
                         [self replaceMajorContentViewWithPPTView];
                     }

                     return YES;
                 }];
    }
}

- (void)makeObservingForSpeaking {
    __block UIAlertController *alert = nil;
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.speakingRequestVM, didReceiveSpeakingInvite:)
             observer:(BJLMethodObserver) ^ BOOL(BOOL invite) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }
                 // 已经弹出 && 取消邀请
                 if (alert && !invite) {
                     [alert dismissViewControllerAnimated:NO completion:nil];
                     alert = nil;
                 }
                 // 已经弹出 && 已经邀请， 避免收到重复的邀请信令
                 if (alert && invite) {
                     return YES;
                 }
                 if (invite) {
                     alert = [UIAlertController
                         alertControllerWithTitle:BJLLocalizedString(@"老师邀请你上麦发言")
                                          message:nil
                                   preferredStyle:UIAlertControllerStyleAlert];
                     [alert bjl_addActionWithTitle:BJLLocalizedString(@"同意")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *_Nonnull action) {
                                               bjl_strongify(self);
                                               alert = nil;
                                               [self.room.speakingRequestVM responseSpeakingInvite:YES];
                                               BJLError *error = [self.room.recordingVM setRecordingAudio:YES recordingVideo:self.room.featureConfig.autoPublishVideoStudent];
                                               if (error) {
                                                   [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                               }
                                               else {
                                                   [self showProgressHUDWithText:(self.room.recordingVM.recordingAudio
                                                                                         ? BJLLocalizedString(@"麦克风已打开")
                                                                                         : BJLLocalizedString(@"麦克风已关闭"))];
                                               }
                                           }];
                     [alert bjl_addActionWithTitle:BJLLocalizedString(@"拒绝")
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *_Nonnull action) {
                                               bjl_strongify(self);
                                               alert = nil;
                                               [self.room.speakingRequestVM responseSpeakingInvite:NO];
                                               [self.room.recordingVM setRecordingAudio:NO recordingVideo:NO];
                                           }];
                     if (self.presentedViewController) {
                         [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
                     }
                     [self presentViewController:alert animated:YES completion:nil];
                 }
                 return YES;
             }];

    [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingEnabled)
        filter:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            return self.room.loginUser.isStudent;
        } observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            if (self.room.speakingRequestVM.speakingEnabled
                && self.fullscreenWindowType != BJLScWindowType_none) {
                // 上麦时全屏复原
                [self restoreCurrentFullscreenWindow];
            }
            // 1 V N
            if (self.room.roomInfo.roomType == BJLRoomType_1vNClass) {
                if (self.room.speakingRequestVM.speakingEnabled) {
                    if (!self.room.recordingVM.recordingAudio
                        && !self.room.recordingVM.recordingVideo) {
                        [self autoStartRecordingAudioAndVideoForce:NO];
                    }
                }
                else {
                    [self.room.recordingVM setRecordingAudio:NO recordingVideo:NO];
                    if (self.room.slideshowViewController.drawingEnabled) {
                        [self.room.drawingVM updateDrawingEnabled:NO];
                    }
                }
            }
            return YES;
        }];

    [self bjl_observe:BJLMakeMethod(self.room.speakingRequestVM, speakingRequestDidReplyEnabled:isUserCancelled:user:)
             observer:(BJLMethodObserver) ^ BOOL(BOOL speakingEnabled, BOOL isUserCancelled, BJLUser * user) {
                 bjl_strongify(self);
                 if ([user.ID isEqualToString:self.room.loginUser.ID]
                     && !isUserCancelled) {
                     [self showProgressHUDWithText:(speakingEnabled
                                                           ? BJLLocalizedString(@"老师同意发言，已进入发言状态")
                                                           : BJLLocalizedString(@"稍等一下，一会请你回答"))];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.recordingVM, recordingDidRemoteChangedRecordingAudio:recordingVideo:recordingAudioChanged:recordingVideoChanged:)
             observer:(BJLMethodObserver) ^ BOOL(BOOL recordingAudio, BOOL recordingVideo, BOOL recordingAudioChanged, BOOL recordingVideoChanged) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }
                 NSString *actionMessage = nil;
                 if (recordingAudioChanged && recordingVideoChanged) {
                     if (recordingAudio == recordingVideo) {
                         actionMessage = recordingAudio ? BJLLocalizedString(@"老师开启了你的麦克风和摄像头") : BJLLocalizedString(@"老师结束了你的发言") /* BJLLocalizedString(@"老师关闭了你的麦克风和摄像头") */;
                     }
                     else {
                         actionMessage = recordingAudio ? BJLLocalizedString(@"老师开启了你的麦克风") : BJLLocalizedString(@"老师开启了你的摄像头"); // 同时关闭了你的摄像头/麦克风
                     }
                 }
                 else if (recordingAudioChanged) {
                     actionMessage = recordingAudio ? BJLLocalizedString(@"老师开启了你的麦克风") : BJLLocalizedString(@"老师关闭了你的麦克风");
                 }
                 else if (recordingVideoChanged) {
                     actionMessage = recordingVideo ? BJLLocalizedString(@"老师开启了你的摄像头") : BJLLocalizedString(@"老师关闭了你的摄像头");
                 }
                 BOOL wasSpeakingEnabled = (recordingAudioChanged ? !recordingAudio : recordingAudio || recordingVideoChanged ? !recordingVideo
                                                                                                                              : recordingVideo);
                 BOOL isSpeakingEnabled = (recordingAudio || recordingVideo);
                 if (!wasSpeakingEnabled && isSpeakingEnabled) {
                     UIAlertController *alert = [UIAlertController
                         alertControllerWithTitle:[NSString stringWithFormat:BJLLocalizedString(@"%@，现在可以发言了"), actionMessage]
                                          message:nil
                                   preferredStyle:UIAlertControllerStyleAlert];
                     [alert bjl_addActionWithTitle:BJLLocalizedString(@"知道了")
                                             style:UIAlertActionStyleCancel
                                           handler:nil];
                     if (self.presentedViewController) {
                         [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
                     }
                     [self presentViewController:alert
                                        animated:YES
                                      completion:nil];
                 }
                 else if (actionMessage) {
                     [self showProgressHUDWithText:actionMessage];
                     if (wasSpeakingEnabled && !isSpeakingEnabled) {
                         [self.room.drawingVM updateDrawingEnabled:NO];
                     }
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveHitCommandLottery:) observer:^BOOL {
        bjl_strongify(self);
        // 发送口令信息成功后, 给一个提示
        [self showProgressHUDWithText:BJLLocalizedString(@"您已参与抽奖，等待开奖吧～")];
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveBeginCommandLottery:) observer:^BOOL {
        bjl_strongify(self);
        [self showProgressHUDWithText:BJLLocalizedString(@"老师发起了口令抽奖～")];
        return YES;
    }];
}

- (void)makeObservingForRollcall {
    [self.rollCallVC addObserverForTeacherIfNeeded];
    [self.rollCallVC addObserverForStudentIfNeededParentVC:self];
}

- (void)makeObservingForAttentionWarning {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveAttentionWarning:)
             observer:^BOOL(NSString *content) {
                 bjl_strongify(self);
                 [self showProgressHUDWithText:content];
                 return YES;
             }];
}

#pragma mark - common

- (void)makeObservingForProgressHUD {
    bjl_weakify(self);

    /* 麦克风和摄像头权限 */
    __block UIAlertController *alertController = nil;
    [self.room.recordingVM setCheckMicrophoneAndCameraAccessCallback:^(BOOL microphone, BOOL camera, BOOL granted, UIAlertController *_Nullable alert) {
        bjl_strongify(self);
        if (granted || !alert) {
            return;
        }
        // 弹出请求授权的提示
        if (self.presentedViewController) {
            if (self.presentedViewController == alertController && alert != alertController) {
                [self.room.recordingVM setCheckMicrophoneAndCameraAccessActionCompletion:^{
                    bjl_strongify(self);
                    self.room.recordingVM.checkMicrophoneAndCameraAccessActionCompletion = nil;
                    alertController = alert;
                    if (self.presentedViewController) {
                        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
                    }
                    [self presentViewController:alert animated:YES completion:nil];
                }];
            }
            else {
                alertController = alert;
                [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else {
            alertController = alert;
            [self presentViewController:alert animated:YES completion:nil];
        }
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
            NSString *name = self.room.loginUserIsPresenter ? BJLLocalizedString(@"你") : now.displayName;
            [self showProgressHUDWithText:[NSString stringWithFormat:BJLLocalizedString(@"%@成为了主讲"), name]];
            return YES;
        }];

    if (self.room.loginUser.isTeacherOrAssistant
        && self.room.loginUser.noGroup) {
        [self bjl_observe:BJLMakeMethod(self.room.speakingRequestVM, speakingRequestDidReplyToUserID:allowed:success:)
            filter:(BJLMethodObserver) ^ BOOL(NSString * userID, BOOL allowed, BOOL success) {
            // bjl_strongify(self);
            return allowed && !success; }
            observer:(BJLMethodObserver) ^ BOOL(NSString * userID, BOOL allowed, BOOL success) {
            bjl_strongify(self);
            [self showProgressHUDWithText:BJLLocalizedString(@"发言人数已满，请先关闭其他人音视频")];
            return YES; }];
    }

    if (!self.room.loginUser.isTeacher) {
        [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, activeUsersSynced)
            filter:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                // bjl_strongify(self);
                return now.boolValue;
            }
            observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                if (!self.room.onlineUsersVM.onlineTeacher) {
                    [self showProgressHUDWithText:BJLLocalizedString(@"老师未在直播间")];
                }
                return YES;
            }];

        [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, onlineTeacher)
            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
            filter:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                // activeUsersSynced 为 NO 时的变化无意义
                return self.room.onlineUsersVM.activeUsersSynced && !!old != !!now;
            }
            observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                [self showProgressHUDWithText:now ? BJLLocalizedString(@"老师进入直播间") : BJLLocalizedString(@"老师离开直播间")];
                return YES;
            }];

        [self bjl_observe:BJLMakeMethod(self.room.playingVM, playingUserDidUpdate:old:)
                 observer:(BJLMethodFilter) ^ BOOL(BJLMediaUser *_Nullable now, BJLMediaUser *_Nullable old) {
                     bjl_strongify(self);
                     if (now.isTeacher) {
                         BOOL audioChanged = (now.audioOn != old.audioOn
                                              && now.mediaSource == BJLMediaSource_mainCamera);
                         BOOL videoChanged = (now.videoOn != old.videoOn);

                         NSString *videoTitle = BJLVideoTitleWithMediaSource(now.mediaSource);
                         if (audioChanged && videoChanged) {
                             if (now.audioOn && now.videoOn) {
                                 [self showProgressHUDWithText:[NSString stringWithFormat:BJLLocalizedString(@"老师开启了麦克风和%@"), videoTitle]];
                             }
                             else if (now.audioOn) {
                                 [self showProgressHUDWithText:BJLLocalizedString(@"老师开启了麦克风")];
                             }
                             else if (now.videoOn) {
                                 [self showProgressHUDWithText:[NSString stringWithFormat:BJLLocalizedString(@"老师开启了%@"), videoTitle]];
                             }
                             else {
                                 [self showProgressHUDWithText:[NSString stringWithFormat:BJLLocalizedString(@"老师关闭了麦克风和%@"), videoTitle]];
                             }
                         }
                         else if (audioChanged) {
                             if (now.audioOn) {
                                 [self showProgressHUDWithText:BJLLocalizedString(@"老师开启了麦克风")];
                             }
                             else {
                                 [self showProgressHUDWithText:BJLLocalizedString(@"老师关闭了麦克风")];
                             }
                         }
                         else { // videoChanged
                             if (now.videoOn
                                 || (now.mediaSource == BJLMediaSource_mediaFile
                                     && old.mediaSource != BJLMediaSource_mediaFile)
                                 || (now.mediaSource == BJLMediaSource_extraMediaFile
                                     && old.mediaSource != BJLMediaSource_extraMediaFile)) {
                                 [self showProgressHUDWithText:[NSString stringWithFormat:BJLLocalizedString(@"老师开启了%@"), videoTitle]];
                             }
                             else {
                                 [self showProgressHUDWithText:[NSString stringWithFormat:BJLLocalizedString(@"老师关闭了%@"), videoTitle]];
                             }
                         }
                     }
                     return YES;
                 }];

        [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, forbidAllRecordingAudio)
            filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                // bjl_strongify(self);
                return now.boolValue != old.boolValue;
            }
            observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                [self showProgressHUDWithText:now.boolValue ? BJLLocalizedString(@"老师禁止打开麦克风") : BJLLocalizedString(@"老师允许打开麦克风")];
                return YES;
            }];
    }

    // 所有非学生角色, 仅对全体禁言开关做提示. 学生通过更新聊天输入按钮提示文案提醒禁言状态
    if (self.room.loginUser.isTeacherOrAssistant) {
        [self bjl_kvo:BJLMakeProperty(self.room.chatVM, forbidAll)
            filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                // bjl_strongify(self);
                return now.boolValue != old.boolValue;
            }
            observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                [self showProgressHUDWithText:(now.boolValue
                                                      ? BJLLocalizedString(@"老师已开启全体禁言")
                                                      : BJLLocalizedString(@"老师已关闭全体禁言"))];
                return YES;
            }];
    }

    // 老师强制上麦失败的提示
    if (self.room.loginUser.isTeacher) {
        [self bjl_observe:BJLMakeMethod(self.room.recordingVM, remoteChangeRecordingDidDenyForUser:)
                 observer:^BOOL(BJLUser *user) {
                     bjl_strongify(self);
                     [self showProgressHUDWithText:[NSString stringWithFormat:BJLLocalizedString(@"服务器拒绝强制 %@ 发言，音视频并发已达上限"), user.displayName]];
                     return YES;
                 }];
    }

    [self bjl_kvo:BJLMakeProperty(self.room.documentVM, authorizedH5PPT)
        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
        filter:^BJLControlObserving(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            return now.boolValue != old.boolValue || now.boolValue;
        }
        observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self showProgressHUDWithText:now.boolValue ? BJLLocalizedString(@"已全体授权课件") : BJLLocalizedString(@"已全体取消授权课件")];
            return YES;
        }];

    if (!self.room.loginUser.isTeacherOrAssistant
        && !self.room.featureConfig.disableGrantDrawing) {
        [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, drawingGranted)
            // options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
            filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                // bjl_strongify(self);
                return now.boolValue != old.boolValue;
            }
            observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                [self showProgressHUDWithText:(now.boolValue
                                                      ? BJLLocalizedString(@"老师开启了你的画笔权限")
                                                      : BJLLocalizedString(@"老师取消了你的画笔权限"))];
                return YES;
            }];
    }
}

#pragma mark - 红包雨

- (void)makeObservingForEnvelope {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didStartEnvelopRainWithID:duration:)
             observer:^BOOL(NSInteger envelopID, NSInteger duration) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }
                 if (self.rainEffectViewController) {
                     // 只存在一个
                     [self.rainEffectViewController bjl_removeFromParentViewControllerAndSuperiew];
                     self.rainEffectViewController = nil;
                 }

                 [self.view endEditing:YES];
                 CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
                 CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
                 CGFloat width = screenWidth > screenHeight ? screenWidth : screenHeight;
                 CGSize size = CGSizeMake(width, width);
                 NSInteger rainCount = 10;
                 BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
                 CGSize rainSize = iPad ? CGSizeMake(88.0, 176.0) : CGSizeMake(64.0, 128.0);
                 self.rainEffectViewController = [[BJLRainEffectViewController alloc] initWithRoom:self.room envelopeID:envelopID duration:duration];
                 [self.rainEffectViewController setupRainEffectSize:size rainImageName:nil rainCount:rainCount rainSize:rainSize];
                 [self.rainEffectViewController setOpenEnvelopeImageName:nil emptyImageName:nil size:rainSize emptySize:rainSize];

                 [self.teachAidLayer addSubview:self.rainEffectViewController.view];
                 [self.rainEffectViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                     make.edges.equalTo(self.teachAidLayer);
                 }];
                 [self.rainEffectViewController setOnceMoreCallback:^{
                     bjl_strongify(self);
                     [self addCreateEnvelopeRainView];
                 }];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didFinishEnvelopRainWithID:)
             observer:^BOOL(NSInteger envelopID) {
                 bjl_strongify(self);
                 if (self.rainEffectViewController.envelopeID == envelopID) {
                     [self.rainEffectViewController removeRainScene];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveRankingList:)
             observer:^BOOL(NSArray<BJLEnvelopeRank *> *rankList) {
                 bjl_strongify(self);
                 [self.rainEffectViewController didReceiveRankList:rankList];
                 return YES;
             }];
}

#pragma mark - 小测

- (void)makeObservingForQuiz {
    bjl_weakify(self);

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveQuizMessage:)
             observer:^BOOL(NSDictionary<NSString *, id> *message) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }

                 BJLScQuizWebViewController *quizWebViewController = [BJLScQuizWebViewController
                     instanceWithQuizMessage:message
                                      roomVM:self.room.roomVM];
                 if (quizWebViewController) {
                     quizWebViewController.closeWebViewCallback = ^{
                         bjl_strongify(self);
                         [self.overlayViewController hide];
                         self.quizWebViewController = nil;
                     };
                     quizWebViewController.sendQuizMessageCallback = ^BJLError *_Nullable(NSDictionary<NSString *, id> *_Nonnull message) {
                         bjl_strongify(self);
                         return [self.room.roomVM sendQuizMessage:message];
                     };

                     if (self.quizWebViewController) {
                         [self.overlayViewController hide];
                         self.quizWebViewController = nil;
                     }

                     self.quizWebViewController = quizWebViewController;
                     [self.overlayViewController showWithContentViewController:quizWebViewController contentView:nil];
                     [quizWebViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                         make.edges.equalTo(self.overlayViewController.view);
                     }];
                 }
                 else if (self.quizWebViewController) {
                     [self.quizWebViewController didReceiveQuizMessage:message];
                 }
                 return YES;
             }];

    [self bjl_kvo:BJLMakeProperty(self.room, state)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.loginUser.isAudition) {
                 return YES;
             }
             if (self.room.state == BJLRoomState_connected) {
                 if (self.quizWebViewController) {
                     [self.overlayViewController hide];
                 }
                 [self.room.roomVM sendQuizMessage:[BJLScQuizWebViewController quizReqMessageWithUserNumber:self.room.loginUser.number]];
             }
             return YES;
         }];
}

- (void)makeObservingForCustomWebView {
    bjl_weakify(self);

    NSString *const customWebpage = @"custom_webpage";

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveCustomizedBroadcast:value:isCache:)
        filter:(BJLMethodFilter) ^ BOOL(NSString * key, id _Nullable _value, BOOL isCache) {
        // bjl_strongify(self);
        return [key isEqualToString:customWebpage]; }
        observer:(BJLMethodObserver) ^ BOOL(NSString * key, id _Nullable _value, BOOL isCache) {
        bjl_strongify(self);
        if (self.room.loginUser.isAudition) {
            return YES;
        }
        
        NSDictionary *value = bjl_as(_value, NSDictionary);
        NSString *action = [value bjl_stringForKey:@"action"];
        
        if ([action isEqualToString:@"student_open_webpage"]) {
            NSString *urlString = [value bjl_stringForKey:@"url"];
            NSURLRequest *request = [BJLNetworking.bjl_manager.requestSerializer
                                     requestWithMethod:@"GET"
                                     URLString:urlString
                                     parameters:@{@"class_id":      self.room.roomInfo.ID ?: @"",
                                                  @"user_number":   self.room.loginUser.number ?: @"",
                                                  @"user_name":     self.room.loginUser.name ?: @""}
                                     error:nil];
            BJLCustomWebViewController *customWebViewController = [[BJLCustomWebViewController alloc] initWithRequest:request];
            if (customWebViewController) {
                customWebViewController.closeWebViewCallback = ^{
                    bjl_strongify(self);
                    self.overlayViewController.tapToHide = YES;
                    [self.overlayViewController hide];
                    self.customWebViewController = nil;
                };
                
                if (self.customWebViewController) {
                    [self.overlayViewController hide];
                    self.customWebViewController = nil;
                }
                
                self.customWebViewController = customWebViewController;
                [self.overlayViewController showWithContentViewController:customWebViewController contentView:nil];
                self.overlayViewController.tapToHide = NO;
                
                CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
                CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
                CGFloat width = self.room.featureConfig.customWebpageSize.width * screenWidth;
                CGFloat height = self.room.featureConfig.customWebpageSize.height * screenHeight;
                CGFloat leftSpace = self.room.featureConfig.customWebpagePosition.width * screenWidth;
                CGFloat topSpace = self.room.featureConfig.customWebpagePosition.height * screenHeight;
                
                [customWebViewController.view bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
                    // 固定宽高, 优先不超出 overlayViewController 边界, 其次遵守距离左侧和上侧的约束条件
                    make.width.equalTo(@(width));
                    make.height.equalTo(@(height));
                    make.bottom.right.lessThanOrEqualTo(self.overlayViewController.view);
                    make.top.left.greaterThanOrEqualTo(self.overlayViewController.view);
                    make.left.equalTo(self.overlayViewController.view).offset(leftSpace).priorityHigh();
                    make.top.equalTo(self.overlayViewController.view).offset(topSpace).priorityHigh();
                }];
            }
        }
        else if ([action isEqualToString:@"student_close_webpage"]) {
            [self.overlayViewController hide];
            self.customWebViewController = nil;
        }
        
        return YES; }];

    [self bjl_kvo:BJLMakeProperty(self.room, state)
        filter:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            return (BJLRoomState)[value integerValue] == BJLRoomState_connected;
        }
        observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self.room.roomVM requestCustomizedBroadcastCache:customWebpage];
            return YES;
        }];
}

#pragma mark - 问答

- (void)makeObservingForQuestion {
    bjl_weakify(self);
    [self bjl_observeMerge:@[BJLMakeMethod(self.room.roomVM, didPublishQuestion:),
        BJLMakeMethod(self.room.roomVM, didReplyQuestion:),
        BJLMakeMethod(self.room.roomVM, didSendQuestion:),
        BJLMakeMethod(self.room.roomVM, didUnpublishQuestion:)]
                  observer:^(BJLQuestion *question) {
                      bjl_strongify(self);
                      NSString *liveTabs = self.room.loginUser.isStudent ? self.room.featureConfig.liveTabsOfStudent : self.room.featureConfig.liveTabs;
                      BOOL enableQuestion = [liveTabs containsString:@"answer"] && self.room.featureConfig.enableQuestion;
                      if (enableQuestion) {
                          // 收到新发布的问答时，没有加载过问答界面，问答界面不在主窗口，问答界面被隐藏的时候，显示红点
                          BOOL hidden = (self.questionViewController.isViewLoaded && self.questionViewController.view.window && !self.questionViewController.view.hidden);

                          // 当前登录用户是学生, 问答被回复且未发布, state是已回复|未发布, 且该question不是当前学生提出来的, hidden = YES
                          if (!self.room.loginUser.isTeacherOrAssistant
                              && (question.state == 6)
                              && ![question.fromUser.number isEqualToString:self.room.loginUser.number]) {
                              hidden = YES;
                          }
                          [self.controlsViewController updateQuestionRedDotHidden:hidden];

                          // 当前是学生, 显示redDot, 且该question是已发布的状态
                          if (!hidden
                              && !self.room.loginUser.isTeacherOrAssistant
                              && ((question.state & BJLQuestionPublished) == BJLQuestionPublished)) {
                              [self.questionViewController showRedDotForStudentPublishSegment];
                          }
                      }
                  }];
}

#pragma mark - 课后评价

- (void)makeObservingForEvaluation {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, liveStarted)
        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
        filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return old.boolValue != now.boolValue;
        }
        observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            if (self.room.loginUser.isAudition || !self.room.loginUser.isStudent) {
                return YES;
            }
            if (!self.room.featureConfig.enableEvaluation) {
                return YES;
            }
            if (now.boolValue) {
                return YES;
            }
            BJLScEvaluationViewController *vc = [[BJLScEvaluationViewController alloc] initWithRoom:self.room];
            [vc setCloseEvaluationCallback:^{
                bjl_strongify(self);
                [self.overlayViewController hide];
            }];

            [self.overlayViewController showWithContentViewController:vc contentView:nil];
            [vc.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.center.equalTo(self.overlayViewController.view);
                make.width.equalTo(@540.0).priorityHigh();
                make.top.equalTo(self.overlayViewController.view).offset(BJLScViewSpaceM);
                make.bottom.equalTo(self.overlayViewController.view).offset(-BJLScViewSpaceM);
            }];
            return YES;
        }];
}

#pragma mark - 点赞

- (void)makeObservingForLikeEffect {
    bjl_weakify(self);
    // 收到点赞
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveLikeForUserNumber:records:)
             observer:^BOOL(NSString *userNumber, NSDictionary<NSString *, NSNumber *> *records) {
                 bjl_strongify(self);
                 for (BJLUser *user in self.room.onlineUsersVM.onlineUsers) {
                     if ([user.number isEqualToString:userNumber]) {
                         [self showLikeEffectViewControllerUser:user];
                         return YES;
                     }
                 }

                 return YES;
             }];
}

- (void)showLikeEffectViewControllerUser:(BJLUser *)user {
    NSString *picture = @"";
    if (self.room.roomVM.awardKey.length > 0) {
        for (BJLAward *award in [BJLAward allAwards]) {
            if ([award.key isEqualToString:self.room.roomVM.awardKey]) {
                picture = award.picture;
                break;
            }
        }
    }
    CGPoint center = CGPointMake(CGRectGetMidX(self.fullscreenLayer.frame), CGRectGetMidY(self.fullscreenLayer.frame));
    BJLLikeEffectViewController *likeEffectViewController = [[BJLLikeEffectViewController alloc] initForInteractiveClassWithName:user.displayName endPoint:center imageUrlString:picture interactiveType:BJLInteractiveTypePersonAward];
    [self bjl_addChildViewController:likeEffectViewController superview:self.lotteryLayer];
    [likeEffectViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.lotteryLayer);
    }];
}

- (void)showQuestionResponderEffectViewControllerUser:(BJLUser *)user likeButton:(UIButton *_Nullable)button {
    CGPoint endPoint = CGPointMake(self.fullscreenLayer.frame.size.width / 2.0f,
        self.fullscreenLayer.frame.size.height / 2.0f);
    if (button) {
        endPoint = [self.fullscreenLayer convertRect:button.frame fromView:button.superview].origin;
    }
    BJLLikeEffectViewController *likeEffectViewController =
        [[BJLLikeEffectViewController alloc] initForInteractiveClassWithName:[NSString stringWithFormat:@"\"%@", user.displayName]
                                                                    endPoint:endPoint
                                                              imageUrlString:nil //注意这里imageurl需要为nil，只有nil才会显示“大拇指点赞”的图片
                                                             interactiveType:BJLInteractiveTypePersonAward];
    likeEffectViewController.nameSuffix = BJLLocalizedString(@"\"抢答成功");
    //lotteryLayer 层级 高于 抢答题本身的弹框
    [self bjl_addChildViewController:likeEffectViewController superview:self.lotteryLayer];
    [likeEffectViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.lotteryLayer);
    }];
}

#pragma mark - 抽奖结果

- (void)makeObservingForShowLotteryResult {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveLotteryResult:) observer:^BOOL(BJLLottery *lottery) {
        bjl_strongify(self);
        // 学生身份才需要创建 lotteryViewController
        if (self.room.loginUser.isStudent) {
            self.lotteryViewController = [[BJLScLotteryViewController alloc] initWithRoom:self.room lottery:lottery];
            [self bjl_addChildViewController:self.lotteryViewController superview:self.lotteryLayer];
            [self.lotteryViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.lotteryLayer);
            }];

            [self.lotteryViewController setHideCallback:^(BJLScLotteryViewController *_Nonnull lotteryViewController) {
                [lotteryViewController bjl_removeFromParentViewControllerAndSuperiew];
            }];
        }
        return YES;
    }];
}

#pragma mark - 积分
- (void)makeObservingForBonusPoints {
    if (!self.room.featureConfig.enableUseBonusPoints) { return; }

    bjl_weakify(self);
    if (self.room.loginUser.isTeacherOrAssistant) {
        [self bjl_observe:BJLMakeMethod(self.room.roomVM, onReceiveBonusChange:success:)
                 observer:(BJLMethodObserver) ^ BOOL(CGFloat remainBonus, BOOL success) {
                     bjl_strongify(self);
                     if (!success) {
                         [self showProgressHUDWithText:BJLLocalizedString(@"积分不足，本操作暂不发放积分")];
                     }
                     return YES;
                 }];
    }
    else {
        [self bjl_observe:BJLMakeMethod(self.room.roomVM, onReceiveBonusIncreasing:)
                 observer:(BJLMethodObserver) ^ BOOL(CGFloat bonus) {
                     bjl_strongify(self);
                     [self showBonusPointsIncreasingForStudent:bonus];
                     return YES;
                 }];
    }
}

#pragma mark - drawing

- (void)makeObservingForPPTAndDrawing {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, drawingEnabled)
        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
        filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return now.integerValue != old.integerValue;
        }
        observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self setControlsHidden:now.boolValue animated:NO];
            return YES;
        }];

    self.toolViewController.pptButtonClickCallback = ^(BOOL isSelected) {
        bjl_strongify(self);
        [self setControlsHidden:isSelected animated:NO];
    };
}

#pragma mark - majorNotice

- (void)clearMajorNotice {
    self.currentMajorNotice = nil;
    self.currentMajorNoticeIndex = 0;
    [self.majorNoticeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.majorNoticeView.hidden = YES;
}

- (void)resetMajorNotice {
    // 清理之前还在运行的主屏公告数据
    [self clearMajorNotice];
    [self updatMajorNoticeWithNextIndex:@YES];
}

// 是从当前主屏公告继续,还是从下一个数据继续
- (void)updatMajorNoticeWithNextIndex:(NSNumber *)useNextNotice {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:[NSNumber numberWithBool:YES]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:[NSNumber numberWithBool:NO]];

    BJLMajorNotice *majorNotice = self.room.roomVM.majorNotice;
    // 清空主屏公告UI
    if (![majorNotice.noticeList count] || !majorNotice) {
        [self clearMajorNotice];
        return;
    }

    BJLMajorNoticeModel *nextMajorNotice = self.currentMajorNotice;
    NSUInteger nextMajorNoticeIndex = self.currentMajorNoticeIndex;
    if (!self.currentMajorNotice) {
        nextMajorNotice = majorNotice.noticeList.firstObject;
        nextMajorNoticeIndex = 0;
    }
    else if ([useNextNotice boolValue]) {
        NSUInteger noticeCount = [majorNotice.noticeList count];
        nextMajorNoticeIndex = ((self.currentMajorNoticeIndex + 1) % noticeCount);
        nextMajorNotice = [majorNotice.noticeList bjl_objectAtIndex:nextMajorNoticeIndex];

        if (!nextMajorNotice) {
            nextMajorNotice = majorNotice.noticeList.firstObject;
            nextMajorNoticeIndex = 0;
        }
    }

    self.currentMajorNotice = nextMajorNotice;
    self.currentMajorNoticeIndex = nextMajorNoticeIndex;

    self.majorNoticeView.hidden = NO;
    UIFont *font = [UIFont systemFontOfSize:majorNotice.fontSize];
    UIColor *viewBackgroundColor = [UIColor bjl_colorWithHexString:majorNotice.backgroundColor alpha:majorNotice.backgroundAlpha / 100.0] ?: [UIColor clearColor];
    UIColor *textColor = [UIColor bjl_colorWithHexString:majorNotice.fontColor alpha:majorNotice.fontAlpha / 100.0] ?: [UIColor whiteColor];
    UIColor *textBorderColor = [UIColor bjl_colorWithHexString:majorNotice.borderColor alpha:majorNotice.borderAlpha / 100.0] ?: [UIColor clearColor];

    self.majorNoticeView.backgroundColor = viewBackgroundColor;

    NSMutableDictionary *attributedDic = [@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: textColor,
        NSStrokeColorAttributeName: textBorderColor,
        NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-3],
    } mutableCopy];

    NSAttributedString *attribtStr = [[NSAttributedString alloc] initWithString:self.currentMajorNotice.noticeText attributes:attributedDic];

    UILabel *label = ({
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.textColor = textColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.attributedText = attribtStr;
        label.numberOfLines = 1;
        [label sizeToFit];
        label.userInteractionEnabled = NO;
        label;
    });

    // 文字边距
    CGSize labelSize = CGSizeMake(label.bounds.size.width, label.bounds.size.height);
    CGFloat containerViewWidth = self.majorNoticeView.bounds.size.width;

    [self.majorNoticeView addSubview:label];
    [label bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.majorNoticeView.bjl_left).offset(labelSize.width + containerViewWidth);
        make.centerY.equalTo(self.majorNoticeView);
        make.size.equal.sizeOffset(labelSize);
    }];
    [self.majorNoticeView layoutIfNeeded];

    // animation
    CGFloat speed = 64.0; // 公告跑马灯速度
    NSTimeInterval duration = (labelSize.width + containerViewWidth) / speed;
    bjl_weakify(self);
    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
        animations:^{
            bjl_strongify(self);
            // 设置动画结束后的最终位置
            [label bjl_updateConstraints:^(BJLConstraintMaker *make) {
                make.right.equalTo(self.majorNoticeView.bjl_left);
            }];
            [self.majorNoticeView layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];

    //     显示间隔
    [self performSelector:_cmd withObject:[NSNumber numberWithBool:YES] afterDelay:(duration + (majorNotice.rollTimeInterval > 0 ? majorNotice.rollTimeInterval : 15.0))];
}

#pragma mark - switch room
- (void)makeObservingForSwitchRoom {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, switchingRoom)
        filter:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return now.boolValue;
        }
        observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            if (self.room.switchingRoom) {
                if (!self.room.loginUser.isTeacher) {
                    [self showProgressHUDWithText:BJLLocalizedString(@"切换直播间中...")];
                    [self.overlayViewController hide];
                    [self destoryBonusPointsVCIfNeeded];
                }
            }
            return YES;
        }];
}

- (void)makeObservingForScreenCapture {
    bjl_weakify(self);
    [self screenCaptureAlertHandler]; //防止开着录屏进直播间
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, screenCaptured)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self screenCaptureAlertHandler];
             return YES;
         }];
}
@end
