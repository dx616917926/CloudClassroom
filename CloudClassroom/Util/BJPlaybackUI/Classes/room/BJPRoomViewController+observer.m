//
//  BJPRoomViewController+observer.m
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/28.
//
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJPRoomViewController+protected.h"
#import "BJPRoomViewController+mixPlayback.h"
#import "BJPAppearance.h"

#import "BJPRoomViewController+studentVideo.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJPRoomViewController (observer)

#pragma mark - observers

- (void)addObserversForPlaybackRoom {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, loading) observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        if (self.room.loading) {
            [BJLProgressHUD bjpb_showLoading:BJLLocalizedString(@"正在加载") toView:self.fullScreenContainerView];
        }
        else {
            [BJLProgressHUD bjpb_closeLoadingView:self.fullScreenContainerView];
        }
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room, roomDidEnterWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 if (error) {
                     NSString *title = BJLLocalizedString(@"进入回放房间时发生错误");
                     NSString *detail = [NSString stringWithFormat:@"%td - %@", error.code, error.localizedDescription ?: error.localizedFailureReason];
                     [self.playbackControlView showReloadViewWithTitle:title detail:detail];
                     return YES;
                 }

                 if (!self.room.isMixPlaybackRoom) {
                     [self updateConstraintsWhenEnterRoomSuccess];
                 }

                 // 自动播放
                 if (self.playbackOptions.autoplay) {
                     [self.room.playerManager play];
                 }

                 // 添加回放房间 view models 相关监听
                 [self addObserversForPlaybackViewModels];

                 // 添加播放器相关监听
                 [self addObserversForVideoPlayer];

                 // 大班课添加对答题器和测验的监听
                 if (self.room.isMixPlaybackRoom
                     || (!self.disablePortrait && self.room.playbackInfo.enableQuizAndAnswer)) {
                     [self makeObservingForAnswerSheet];
                     [self makeObservingForQuiz];
                 }

                 // 跑马灯
                 [self makeObservingForLamp];

                 // 回放防录屏
                 [self screenCaptureAlertHandler]; //防止开着录屏进直播间
                 [self bjl_kvo:BJLMakeProperty(self.room.roomVM, screenCaptured)
                      observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                          bjl_strongify(self);
                          [self screenCaptureAlertHandler];
                          return YES;
                      }];

                 [self bjl_kvo:BJLMakeProperty(self.room.roomVM.cloudVideoPlayer, playerView)
                      observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                          bjl_strongify(self);
                          UIView *playerView = self.room.roomVM.cloudVideoPlayer.playerView;
                          if (playerView) {
                              if (playerView.superview != self.self.cloudVideoWrapperView) {
                                  for (UIView *subview in self.cloudVideoWrapperView.subviews.copy) {
                                      [subview removeFromSuperview];
                                  }
                                  [self resetCloudVideoWrapperViewPosition];
                                  [self.cloudVideoWrapperView addSubview:playerView];
                                  [playerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                                      make.edges.equalTo(self.cloudVideoWrapperView);
                                  }];
                              }
                          }
                          else {
                              for (UIView *subview in self.cloudVideoWrapperView.subviews.copy) {
                                  [subview removeFromSuperview];
                              }
                          }

                          return YES;
                      }];

                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, mixPlaybackRoomWillLoadSlice:)
             observer:^BOOL(BJVPlaybackInfo *playbackInfo) {
                 bjl_strongify(self);

                 [self updateMixPlaybackUIForNewSlice];

                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, mixPlaybackRoomSlice:didLoadWithError:)
             observer:^BOOL(BJVPlaybackInfo *playbackInfo, NSError *error) {
                 bjl_strongify(self);

                 if (error) {
                     NSString *title = BJLLocalizedString(@"加载回放时发生错误");
                     NSString *detail = [NSString stringWithFormat:@"%td - %@", error.code, error.localizedDescription ?: error.localizedFailureReason];
                     [self.playbackControlView showReloadViewWithTitle:title detail:detail];
                 }

                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, roomDidExitWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 // 退出直播间时让跑马灯停下来
                 if (self.lampConstructor) {
                     [NSObject cancelPreviousPerformRequestsWithTarget:self.lampConstructor];
                     self.lampConstructor = nil;
                 }
                 [self bjl_stopAllKeyValueObserving];
                 [self bjl_stopAllMethodParametersObserving];
                 return YES;
             }];

    // 网络监测
    [self setupReachabilityManager];

    // !!!: 播放错误，在进入回放房间成功之前添加，避免监听不到视频加载完成前的错误
    [self bjl_observe:BJLMakeMethod(self.room.playerManager, video:playFailedWithError:) observer:^BOOL(BJVPlayInfo *playInfo, NSError *error) {
        bjl_strongify(self);
        [self video:playInfo playFailedWithError:error];
        return YES;
    }];

    // 回放学生视频信息
    //    [self bjl_kvo:BJLMakeProperty(self.room, playbackInfo)
    //         observer:^BOOL(id  _Nullable now, id  _Nullable old, BJLPropertyChange * _Nullable change) {
    //        bjl_strongify(self);
    //        // 根据playbackInfo.userList的数量创建学生的view
    //        NSArray *userVideoList = self.room.playbackInfo.userVideoList;
    //        [self creatStudentViewWithUserVideoList:userVideoList];
    //        return YES;
    //    }];
}

- (void)addObserversForPlaybackViewModels {
    bjl_weakify(self);
    // 主讲
    [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, currentPresenter)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BJVMediaUser *presenter = self.room.onlineUsersVM.currentPresenter;

             NSString *nameString = (presenter ? [NSString stringWithFormat:@"%@ (%@)", presenter.name, presenter.isTeacher ? BJLLocalizedString(@"老师") : BJLLocalizedString(@"主讲")]
                                               : nil);
             [self.thumbnailContainerView setTitle:nameString];
             // 更新视频占位图 显示/隐藏 状态
             [self updateAudioOnlyImageViewHidden];
             return YES;
         }];

    // 所有用户音视频状态改变的通知
    [self bjl_observe:BJLMakeMethod(self.room.onlineUsersVM, mediaUsersDidUpdate:) observer:^BOOL(NSArray<BJVMediaUser *> *mediaUsers) {
        bjl_strongify(self);
        // 有用户音视频状态改变的时候, 更新主讲人的 视频占位图 显示/隐藏 状态
        for (BJVMediaUser *user in mediaUsers) {
            [self updateMediaState:user];
        }
        return YES;
    }];

    [self bjl_kvo:BJLMakeProperty(self.room, existWebDocument)
         observer:^BJLControlObserving(NSNumber *_Nullable value, NSNumber *_Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (value.bjl_boolValue
                 && self.room.isLocalVideo
                 && self.reachabilityManager.networkReachabilityStatus == BJLAFNetworkReachabilityStatusNotReachable) {
                 [BJLProgressHUD bjl_showHUDForText:BJLLocalizedString(@"当前直播间的课件必须要联网才能加载") superview:self.view animated:YES];
             }
             return YES;
         }];

    if (!self.room.isMixPlaybackRoom) {
        // 通过信令拿到所有课件之后, 如果没有课件翻页操作(白板也算为课件)则不展示大纲目录入口 , 小班课也不展示目录
        [self bjl_kvo:BJLMakeProperty(self.room.roomVM, documentCatalogueList)
             observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 if ([self.room.roomVM.documentCatalogueList count] && (!self.room.isInteractiveClass || self.room.playbackInfo.isInteractiveClass1v1SignalingRecord)) {
                     [self.playbackControlView setCatalogueHidden:NO];
                     return NO;
                 }
                 return YES;
             }];
    }
}

- (void)addObserversForVideoPlayer {
    bjl_weakify(self);
    // 播放时间
    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.playerManager, currentTime), BJLMakeProperty(self.room.playerManager, duration)] observer:^(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            //通知主线程刷新
            [self.playbackControlView updateContentWithCurrentTime:self.room.playerManager.currentTime
                                                     cacheDuration:self.room.playerManager.cachedDuration
                                                     totalDuration:self.room.playerManager.duration];
        });
    }];

    // 播放状态变化
    [self bjl_kvo:BJLMakeProperty(self.room.playerManager, playStatus)
        filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            return (old == nil) || (now.integerValue != old.integerValue);
        } observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            BJVPlayerStatus status = self.room.playerManager.playStatus;

            // hud
            if (status == BJVPlayerStatus_stalled || status == BJVPlayerStatus_loading) {
                [BJLProgressHUD bjpb_showLoading:BJLLocalizedString(@"正在加载") toView:self.fullScreenContainerView];
            }
            else {
                [BJLProgressHUD bjpb_closeLoadingView:self.fullScreenContainerView];
            }

            // controls
            if (status == BJVPlayerStatus_playing) {
                [self.playbackControlView updateWithPlayState:YES];
            }
            else if (status == BJVPlayerStatus_paused
                     || status == BJVPlayerStatus_stopped
                     || status == BJVPlayerStatus_reachEnd
                     || status == BJVPlayerStatus_failed
                     || status == BJVPlayerStatus_ready) {
                [self.playbackControlView updateWithPlayState:NO];
            }

            return YES;
        }];

    // 播放清晰度
    [self bjl_kvo:BJLMakeProperty(self.room.playerManager, currDefinitionInfo)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             // 显示清晰度
             [self.playbackControlView updateWithDefinition:self.room.playerManager.currDefinitionInfo.definitionName];
             [self updateDefinitionSettingViewAndShow:NO];

             // 视频宽高比
             BJVDefinitionInfo *currDefinitionInfo = self.room.playerManager.currDefinitionInfo;
             CGFloat width = currDefinitionInfo.width;
             CGFloat height = currDefinitionInfo.height;
             if (width > 0.0 && height > 0.0) {
                 // 更新播放视图宽高比
                 self.videoRatio = width / height;
                 [self updatePlayerViewConstraint];
             }

             // 更新视频占位图 显示/隐藏 状态
             [self updateAudioOnlyImageViewHidden];

             return YES;
         }];

    // 播放倍速
    [self bjl_kvo:BJLMakeProperty(self.room.playerManager, rate)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.playbackControlView updateWithRate:[NSString stringWithFormat:@"%.1fx", self.room.playerManager.rate]];
             [self updateRateSettingViewAndShow:NO];
             return YES;
         }];
}

- (void)screenCaptureAlertHandler {
    if (!self.room.playbackInfo.enablePreventScreenCapture) {
        return;
    }

    if (self.room.roomVM.screenCaptured) {
        [self.screenCaptureAlertView showInParentView:self.view];
    }
    else {
        [self.screenCaptureAlertView hide];
    }
}

#pragma mark - 答题器

- (void)makeObservingForAnswerSheet {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveQuestionAnswerSheet:) observer:^BOOL(BJVAnswerSheet *answerSheet) {
        bjl_strongify(self);
        [self clearAnswerSheet];

        self.answerSheetViewController = [[BJPAnswerSheetViewController alloc] initWithAnswerSheet:answerSheet];
        // 回放答题器提交之后直接显示答案
        [self.answerSheetViewController setSubmitCallback:^BOOL(BJVAnswerSheet *_Nullable result) {
            bjl_strongify(self);
            [self clearAnswerSheet];
            [self clearAnswerSheetResult];

            if (result) {
                self.answerSheetResultViewController = [[BJPAnswerResultViewController alloc] initWithAnswerSheet:result];

                // 答题器结果关闭回调
                [self.answerSheetResultViewController setCloseCallback:^{
                    bjl_strongify(self);
                    [self clearAnswerSheetResult];
                }];

                [self showAnswerSheetResult];
            }
            return YES;
        }];

        // 答题器关闭回调
        [self.answerSheetViewController setCloseCallback:^{
            bjl_strongify(self);
            [self clearAnswerSheet];
        }];

        [self showAnswerSheet];
        return YES;
    }];
}

- (void)makeObservingForQuiz {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveQuizMessage:) observer:^BOOL(NSDictionary<NSString *, id> *message) {
        NSString *messageType = [message bjl_stringForKey:@"message_type"];
        if (![messageType isEqualToString:@"quiz_start"]) {
            return YES;
        }

        bjl_strongify(self);
        BJPQuizWebViewController *quizWebViewController = [BJPQuizWebViewController
            instanceWithQuizMessage:message
                             roomVM:self.room.roomVM];
        if (quizWebViewController) {
            quizWebViewController.closeWebViewCallback = ^{
                bjl_strongify(self);
                [self.quizWebViewController bjl_removeFromParentViewControllerAndSuperiew];
                self.quizWebViewController = nil;
            };

            if (self.quizWebViewController) {
                [self.quizWebViewController bjl_removeFromParentViewControllerAndSuperiew];
            }
            self.quizWebViewController = quizWebViewController;
            [self bjl_addChildViewController:self.quizWebViewController superview:self.quizContainLayer];
            [self.quizWebViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.quizContainLayer);
            }];
        }
        else if (self.quizWebViewController) {
            [self.quizWebViewController didReceiveQuizMessage:message];
        }
        return YES;
    }];
}

- (void)showAnswerSheet {
    if (!self.answerSheetViewController) {
        return;
    }

    [self bjl_addChildViewController:self.answerSheetViewController superview:self.quizContainLayer];
    [self.answerSheetViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.quizContainLayer);
    }];
}

- (void)clearAnswerSheet {
    if (!self.answerSheetViewController) {
        return;
    }
    [self.answerSheetViewController bjl_removeFromParentViewControllerAndSuperiew];
    self.answerSheetViewController = nil;
}

- (void)showAnswerSheetResult {
    if (!self.answerSheetResultViewController) {
        return;
    }

    [self bjl_addChildViewController:self.answerSheetResultViewController superview:self.quizContainLayer];
    [self.answerSheetResultViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.quizContainLayer);
    }];
}

- (void)clearAnswerSheetResult {
    if (!self.answerSheetResultViewController) {
        return;
    }

    [self.answerSheetResultViewController bjl_removeFromParentViewControllerAndSuperiew];
    self.answerSheetResultViewController = nil;
}

#pragma mark - lamp

- (void)makeObservingForLamp {
    bjl_weakify(self);
    [self bjl_kvoMerge:@[BJLMakeProperty(self, customLamp),
        BJLMakeProperty(self.room.roomVM, lamp)]
               options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              observer:^(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updateLamp];
              }];

    [self updateLamp];
}

- (void)updateLamp {
    // 多个回放拼接时，会调用多次，所以需要先销毁
    NSArray *subviews = self.lampView.subviews;
    for (UIView *v in subviews) {
        [v removeFromSuperview];
    }

    BJVLamp *lamp = self.customLamp ?: self.room.roomVM.lamp;
    [lamp checkContentWithUserName:self.room.playerManager.userName];
    if (!lamp.content.length || lamp.alpha == 0) {
        return;
    }

    if (!self.lampConstructor) {
        self.lampConstructor = [[BJVLampConstructor alloc] init];
    }
    [self.lampConstructor updateLampWithLamp:lamp
                                    lampView:self.lampView
                                 lampContent:lamp.content];
}

#pragma mark - actions

- (void)setupReachabilityManager {
    bjl_weakify(self);
    BJLAFNetworkReachabilityManager *manager = [BJLAFNetworkReachabilityManager manager];

    __block BOOL WWANNetworkShowed = NO;
    [manager setReachabilityStatusChangeBlock:^(BJLAFNetworkReachabilityStatus status) {
        bjl_strongify(self);
        if (status == BJLAFNetworkReachabilityStatusNotReachable
            && self.room.existWebDocument
            && self.room.isLocalVideo) {
            [BJLProgressHUD bjl_showHUDForText:BJLLocalizedString(@"当前直播间的课件必须要联网才能加载") superview:self.view animated:YES];
        }

        if (self.room.isLocalVideo
            || status == BJLAFNetworkReachabilityStatusReachableViaWiFi) {
            return;
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (status == BJLAFNetworkReachabilityStatusReachableViaWiFi) {
                return;
            }

            // 断网提示
            if (status == BJLAFNetworkReachabilityStatusUnknown
                || status == BJLAFNetworkReachabilityStatusNotReachable) {
                UIAlertController *alert = [UIAlertController
                    alertControllerWithTitle:BJLLocalizedString(@"网络连接已断开")
                                     message:nil
                              preferredStyle:UIAlertControllerStyleAlert];
                [alert bjl_addActionWithTitle:BJLLocalizedString(@"知道了")
                                        style:UIAlertActionStyleCancel
                                      handler:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }

            // 3G/4G 提示
            if (status == BJLAFNetworkReachabilityStatusReachableViaWWAN) {
                if (WWANNetworkShowed) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BJLProgressHUD bjpb_showMessageThenHide:BJLLocalizedString(@"正在使用3G/4G网络") toView:self.fullScreenContainerView onHide:nil];
                    });
                }
                else {
                    WWANNetworkShowed = YES;
                    UIAlertController *alert = [UIAlertController
                        alertControllerWithTitle:BJLLocalizedString(@"正在使用3G/4G网络")
                                         message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];
                    [alert bjl_addActionWithTitle:BJLLocalizedString(@"知道了")
                                            style:UIAlertActionStyleCancel
                                          handler:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        });
    }];

    [manager startMonitoring];
    self.reachabilityManager = manager;
}

#pragma mark - action

- (void)video:(nullable BJVPlayInfo *)playInfo playFailedWithError:(nullable NSError *)error {
    NSString *errorTitle;
    switch (error.code) {
        case BJVErrorCode_unknown:
            errorTitle = BJLLocalizedString(@"未知错误");
            break;

        case BJVErrorCode_requestFailed:
            errorTitle = BJLLocalizedString(@"网络请求失败");
            break;

        case BJVErrorCode_invalidToken:
            errorTitle = BJLLocalizedString(@"token 参数错误");
            break;

        case BJVErrorCode_invalidPlayInfo:
            errorTitle = BJLLocalizedString(@"播放信息解析错误");
            break;

        case BJVErrorCode_invalidVideoURL:
            errorTitle = BJLLocalizedString(@"视频 URL 失效");
            break;

        case BJVErrorCode_fileLost:
            errorTitle = BJLLocalizedString(@"播放文件不存在");
            break;

        case BJVErrorCode_playFailed:
            errorTitle = BJLLocalizedString(@"视频播放失败");
            break;

        default:
            break;
    }

    if (errorTitle.length) {
        [BJLProgressHUD bjpb_closeLoadingView:self.fullScreenContainerView];
        NSString *detail = [NSString stringWithFormat:@"%td - %@", error.code, error.localizedDescription ?: error.localizedFailureReason];
        [self.playbackControlView showReloadViewWithTitle:errorTitle detail:detail];
    }
}

#pragma mark - private

- (NSString *)timeWithTime:(NSTimeInterval)interval {
    //    3753 == 1:02:33   33 + 120 + 3600
    int hours = interval / 3600;
    int minums = ((long long)interval % 3600) / 60;
    int seconds = (long long)interval % 60;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minums, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02d:%02d", minums, seconds];
    }
}

@end

NS_ASSUME_NONNULL_END
