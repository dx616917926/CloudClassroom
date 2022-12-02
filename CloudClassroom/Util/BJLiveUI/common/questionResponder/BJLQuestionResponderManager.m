//
//  BJLQuestionResponderManager.m
//  BJLiveUIBase
//
//  Created by HuXin on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLQuestionResponderManager.h"
#import "BJLQuestionResponderWindowViewController.h"
#import "BJLStudentQuestionResponderViewController.h"
#import "BJLAlertPresentationController.h"
#import "BJLSheetPresentationController.h"
#import "BJLPopoverViewController.h"
#import <BJLiveCore/BJLiveCore.h>
#import "BJLLikeEffectViewController.h"

@interface BJLQuestionResponderManager ()

// 本次课节所有抢答记录
@property (nonatomic, nullable) NSArray<NSDictionary *> *questionResponderList;
// 老师和助教的抢答器窗口
@property (nonatomic, nullable) BJLQuestionResponderWindowViewController *questionResponderViewController;
// 学生的抢答器窗口
@property (nonatomic, nullable, weak) BJLStudentQuestionResponderViewController *studentResponderViewController;

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic, weak) UIViewController *roomViewController;
@property (nonatomic) UIView *windowView;
@property (nonatomic) BOOL didAddObserver;

@end

@implementation BJLQuestionResponderManager

- (instancetype)initWithRoom:(BJLRoom *)room roomViewController:(UIViewController *)roomViewController superView:(UIView *)superView {
    self.room = room;
    self.roomViewController = roomViewController;
    self.windowView = superView;
    return self;
}

- (void)makeObservingForQuestionResponder {
    bjl_weakify(self);
    // 抢答器
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, liveStarted)
         observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             // 老师下课时, 正在抢答时, 发送抢答结束信令
             BOOL isTeacher = self.room.loginUser.isTeacher;

             if (self.questionResponderViewController && isTeacher) {
                 [self.questionResponderViewController destroyQuestionResponder];
             }
             else if (self.studentResponderViewController && self.room.loginUser.isStudent) {
                 [self.studentResponderViewController hide];
             }
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room, switchingRoom)
        filter:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return now.boolValue;
        }
        observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            if (self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.noGroup) {
                [self closeQuestionResponderController];
                self.questionResponderList = nil;
                self.questionResponderViewController = nil;
            }
            return YES;
        }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveQuestionResponderWithTime:)
             observer:^BOOL(NSInteger time) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isTeacherOrAssistant) {
                     // 小班助教或者老师进入大班后，没有抢答器界面
                     if (!self.room.loginUser.noGroup) {
                         if (self.questionResponderViewController) {
                             [self.questionResponderViewController closeUI];
                             self.questionResponderViewController = nil;
                         }
                         return YES;
                     }

                     if (!self.questionResponderViewController) {
                         self.questionResponderViewController = [self displayQuestionResponderWindowWithLayout:BJLQuestionResponderWindowLayout_publish];
                         return YES;
                     }
                     if (self.roomViewController.presentedViewController != self.questionResponderViewController) {
                         [self openQuestionResponder];
                     }
                 }
                 else if (self.room.loginUser.isStudent) {
                     if (self.studentResponderViewController) {
                         [self.studentResponderViewController hide];
                         self.studentResponderViewController = nil;
                     }

                     self.studentResponderViewController = [self displayQuestionResponderWindowWithCountDownTime:time];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveCloseQuestionResponder)
             observer:^BOOL {
                 bjl_strongify(self);
                 if (self.questionResponderViewController) {
                     [self.questionResponderViewController closeUI];
                     self.questionResponderViewController = nil;
                 }

                 if (self.studentResponderViewController) {
                     [self.studentResponderViewController hide];
                     self.studentResponderViewController = nil;

                     if (self.room.loginUser.isStudent) {
                         self.showErrorMessageCallback(BJLLocalizedString(@"抢答器已被收回"));
                     }
                 }
                 return YES;
             }];

    //    抢答器结果记录
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveEndQuestionResponderWithWinner:)
             observer:^BOOL(BJLUser *user) {
                 bjl_strongify(self);
                 if (!user) {
                     return YES;
                 }

                 if (self.room.loginUser.isTeacherOrAssistant
                     && !self.room.loginUser.noGroup
                     && (user.groupID == self.room.loginUser.groupID || self.room.featureConfig.enableShowAllGroupMember)) {
                     if (self.questionResponderSuccessCallback) {
                         self.questionResponderSuccessCallback(user, nil);
                     }
                 }

                 NSMutableArray<NSDictionary *> *list = [self.questionResponderList mutableCopy];
                 if (!list) {
                     list = [NSMutableArray new];
                 }

                 NSUInteger onlineUserCount = 0;
                 for (BJLUser *user in self.room.onlineUsersVM.onlineUsers) {
                     if (user.role == BJLUserRole_student) {
                         onlineUserCount++;
                     }
                 }

                 NSDictionary *dictionary = @{
                     kQuestionRecordUserKey: [[user bjlyy_modelToJSONObject] bjl_asDictionary] ?: @{},
                     kQuestionRecordCountKey: @(onlineUserCount)
                 };
                 [list bjl_addObject:dictionary];
                 self.questionResponderList = [list copy];
                 return YES;
             }];
}

- (void)openQuestionResponder {
    if (!self.room.loginUser.isTeacherOrAssistant) {
        self.showErrorMessageCallback(BJLLocalizedString(@"老师或助教才能使用抢答器"));
        return;
    }

    if (!self.room.roomVM.liveStarted) {
        self.showErrorMessageCallback(BJLLocalizedString(@"上课状态才能使用抢答器"));
        return;
    }

    if (self.room.loginUser.isTeacherOrAssistant && !self.questionResponderViewController) {
        self.questionResponderViewController = [self displayQuestionResponderWindowWithLayout:BJLQuestionResponderWindowLayout_normal];
    }
    else if (self.questionResponderViewController) {
        [self presentQuestionResponderWindow:self.questionResponderViewController];
    }
}

- (void)closeQuestionResponderController {
    if (self.questionResponderViewController) {
        [self.questionResponderViewController destroyQuestionResponder];
    }
}

- (nullable __kindof UIViewController *)displayQuestionResponderWindowWithLayout:(BJLQuestionResponderWindowLayout)layout {
    if (self.room.loginUser.isStudent) {
        return nil;
    }

    BJLQuestionResponderWindowViewController *questionResponderViewController = [[BJLQuestionResponderWindowViewController alloc] initWithRoom:self.room layout:layout historeQuestionList:self.questionResponderList];

    bjl_weakify(self, questionResponderViewController);
    [questionResponderViewController setPublishQuestionResponderCallback:^BOOL(NSTimeInterval time) {
        bjl_strongify(self);
        BJLError *error = [self.room.roomVM requestPublishQuestionResponderWithTime:time];
        if (error) {
            self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
            return NO;
        }
        return YES;
    }];

    [questionResponderViewController setEndQuestionResponderCallback:^BOOL(BOOL close) {
        bjl_strongify(self, questionResponderViewController);
        BJLError *error = [self.room.roomVM endQuestionResponderWithShouldCloseWindow:close];
        if (error) {
            self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
            return NO;
        }

        if (close) {
            [questionResponderViewController dismissViewControllerAnimated:YES
                                                                completion:^{
                                                                    [questionResponderViewController bjl_removeFromParentViewControllerAndSuperiew];
                                                                    self.questionResponderViewController = nil;
                                                                }];
        }
        return YES;
    }];

    [questionResponderViewController setRevokeQuestionResponderCallback:^BOOL {
        bjl_strongify(self);
        BJLError *error = [self.room.roomVM requestRevokeQuestionResponder];
        if (error) {
            self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
            return NO;
        }
        return YES;
    }];

    [questionResponderViewController setCloseQuestionResponderCallback:^{
        bjl_strongify(self);
        [self closeQuestionResponderController];
    }];

    [questionResponderViewController setCloseCallback:^{
        bjl_strongify(self, questionResponderViewController);
        [questionResponderViewController dismissViewControllerAnimated:YES
                                                            completion:^{
                                                                BJLError *error = [self.room.roomVM requestCloseQuestionResponder];
                                                                if (error) {
                                                                    self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
                                                                }
                                                                [questionResponderViewController bjl_removeFromParentViewControllerAndSuperiew];
                                                            }];
    }];

    [questionResponderViewController setErrorCallback:^(NSString *message) {
        bjl_strongify(self);
        self.showErrorMessageCallback(message);
    }];

    [questionResponderViewController setInviteSpeakCallback:^(BJLUser *_Nonnull user) {
        bjl_strongify(self);

        bjl_returnIfRobot(1.0);
        if (self.questionResponderInviteSpeakCallback) {
            self.questionResponderInviteSpeakCallback(user);
            return;
        }

        BJLUser *targetUser = nil;
        for (BJLUser *onlineUser in [self.room.onlineUsersVM.onlineUsers copy]) {
            if ([onlineUser isSameUser:user]) {
                targetUser = onlineUser;
                break;
            }
        }
        if (!targetUser) {
            self.showErrorMessageCallback(BJLLocalizedString(@"该学生不在直播间"));
            return;
        }

        BJLMediaUser *targetMediaUser = nil;
        for (BJLMediaUser *i in [self.room.playingVM.playingUsers copy]) {
            if ([i isSameUser:targetUser]) {
                targetMediaUser = i;
                break;
            }
        }

        if (targetMediaUser.videoState == BJLUserMediaState_backstage
            || targetMediaUser.audioState == BJLUserMediaState_backstage) {
            self.showErrorMessageCallback(BJLLocalizedString(@"该学生已暂时离开"));
            return;
        }

        if (targetMediaUser) {
            if (targetMediaUser.videoOn && targetMediaUser.audioOn) {
                self.showErrorMessageCallback(BJLLocalizedString(@"该学生已在台上"));
            }
            else {
                NSError *error = [self.room.recordingVM remoteChangeRecordingWithUser:targetUser audioOn:YES videoOn:YES];
                if (error) {
                    self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
                }
            }
        }
        else {
            NSInteger count = self.room.featureConfig.maxActiveUserCountForSC;
            if (count > 0) {
                NSMutableArray<BJLUser *> *playingUsers = [(self.room.playingVM.playMixedVideo ? self.room.playingVM.mixedPlayingUsers : self.room.playingVM.playingUsers) mutableCopy];
                if (self.room.recordingVM.recordingVideo || self.room.recordingVM.recordingAudio) {
                    [playingUsers addObject:self.room.loginUser];
                }

                // maxActiveUserCountForSC返回的数量包含主讲人
                // 所以如果主讲人不上台，要减 1
                if (!self.room.onlineUsersVM.currentPresenter) {
                    count--;
                }

                if (playingUsers.count >= count) {
                    self.showErrorMessageCallback(BJLLocalizedString(@"台上人数已满"));
                    return;
                }
            }

            NSError *error = [self.room.recordingVM remoteChangeRecordingWithUser:targetUser audioOn:YES videoOn:YES];
            if (error) {
                self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
            }
        }
    }];

    [questionResponderViewController setResponderSuccessCallback:^(BJLUser *_Nonnull user, UIButton *_Nonnull button) {
        bjl_strongify(self);
        if (self.questionResponderSuccessCallback) {
            self.questionResponderSuccessCallback(user, button);
        }
    }];

    [self presentQuestionResponderWindow:questionResponderViewController];
    return questionResponderViewController;
}

- (void)presentQuestionResponderWindow:(BJLQuestionResponderWindowViewController *)questionResponderViewController {
    bjl_weakify(self);
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    BOOL needSheetPresent = iPhone && (UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width);
    if (needSheetPresent) {
        BJLSheetPresentationController *sheetPresentationController = [[BJLSheetPresentationController alloc] initWithPresentedViewController:questionResponderViewController presentingViewController:self.roomViewController];
        [sheetPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (viewController && [viewController isKindOfClass:[BJLQuestionResponderWindowViewController class]]) {
                if ([questionResponderViewController keyboardDidShow]) {
                    return YES;
                }
                return NO;
            }
            return YES;
        }];
        questionResponderViewController.preferredContentSize = CGSizeMake(self.roomViewController.view.bounds.size.width, self.roomViewController.view.bounds.size.height * 0.4);
        if (self.roomViewController.presentedViewController) {
            [self.roomViewController dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            bjl_strongify(self);
                                                            questionResponderViewController.transitioningDelegate = sheetPresentationController;
                                                            [self.roomViewController presentViewController:questionResponderViewController animated:YES completion:nil];
                                                        }];

            return;
        }
        questionResponderViewController.transitioningDelegate = sheetPresentationController;
        [self.roomViewController presentViewController:questionResponderViewController animated:YES completion:nil];
    }
    else {
        BJLAlertPresentationController *alertPresentationController = [[BJLAlertPresentationController alloc] initWithPresentedViewController:questionResponderViewController presentingViewController:self.roomViewController];
        [alertPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (viewController && [viewController isKindOfClass:[BJLQuestionResponderWindowViewController class]]) {
                if ([questionResponderViewController keyboardDidShow]) {
                    return YES;
                }
                return NO;
            }
            return YES;
        }];

        questionResponderViewController.preferredContentSize = [questionResponderViewController getSize];
        if (self.roomViewController.presentedViewController) {
            [self.roomViewController dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            bjl_strongify(self);
                                                            questionResponderViewController.transitioningDelegate = alertPresentationController;
                                                            [self.roomViewController presentViewController:questionResponderViewController animated:YES completion:nil];
                                                        }];

            return;
        }
        questionResponderViewController.transitioningDelegate = alertPresentationController;
        [self.roomViewController presentViewController:questionResponderViewController animated:YES completion:nil];
    }
}

- (nullable __kindof UIViewController *)displayQuestionResponderWindowWithCountDownTime:(NSInteger)time {
    if (!self.room.loginUser.isStudent) {
        return nil;
    }
    BJLStudentQuestionResponderViewController *responderVC = [[BJLStudentQuestionResponderViewController alloc] initWithRoom:self.room countDownTime:time];

    bjl_weakify(self);
    [responderVC setErrorCallback:^(NSString *_Nonnull message) {
        bjl_strongify(self);
        self.showErrorMessageCallback(message);
    }];
    [responderVC setResponderCallback:^{
        bjl_strongify(self);
        BJLError *error = [self.room.roomVM submitQuestionResponder];
        if (error) {
            self.showErrorMessageCallback(error.localizedFailureReason ?: error.localizedDescription);
            return NO;
        }
        return YES;
    }];
    [responderVC setResponderSuccessCallback:^(BJLUser *_Nonnull user, UIButton *_Nonnull button) {
        bjl_strongify(self);
        if (self.questionResponderSuccessCallback) {
            self.questionResponderSuccessCallback(user, button);
        }
    }];

    [responderVC setHiddenCallback:^void {
        bjl_strongify(self);
        self.studentResponderViewController = nil;
    }];

    [self.roomViewController bjl_addChildViewController:responderVC superview:self.windowView];
    [responderVC.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.windowView);
    }];
    return responderVC;
}

- (void)destoryStudentQuestionResponderViewController {
    if (self.studentResponderViewController) {
        [self.studentResponderViewController hide];
    }
}

- (void)showQuestionResponderEffectViewControllerUser:(BJLUser *)user likeButton:(UIButton *_Nullable)button fullscreenLayer:(UIView *)fullscreenLayer {
    CGPoint endPoint = CGPointMake(fullscreenLayer.frame.size.width / 2.0f,
        fullscreenLayer.frame.size.height / 2.0f);
    if (button) {
        endPoint = [fullscreenLayer convertRect:button.frame fromView:button.superview].origin;
    }
    BJLLikeEffectViewController *likeEffectViewController =
        [[BJLLikeEffectViewController alloc] initForInteractiveClassWithName:[NSString stringWithFormat:@"\"%@", user.displayName]
                                                                    endPoint:endPoint
                                                              imageUrlString:nil //注意这里imageurl需要为nil，只有nil才会显示“大拇指点赞”的图片
                                                             interactiveType:BJLInteractiveTypePersonAward];
    likeEffectViewController.nameSuffix = BJLLocalizedString(@"\"抢答成功");
    [self.roomViewController bjl_addChildViewController:likeEffectViewController superview:fullscreenLayer];
    [likeEffectViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(fullscreenLayer);
    }];
}

@end
