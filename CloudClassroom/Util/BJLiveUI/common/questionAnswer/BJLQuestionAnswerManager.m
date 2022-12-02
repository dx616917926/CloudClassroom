//
//  BJLQuestionAnswerManager.m
//  BJLiveUIBase
//
//  Created by HuXin on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLQuestionAnswerManager.h"
#import "BJLQuestionAnswerViewController.h"
#import "BJLStudentQuestionAnswerWindowViewController.h"
#import "BJLAlertPresentationController.h"
#import "BJLSheetPresentationController.h"
#import <BJLiveCore/BJLiveCore.h>
#import "BJLPopoverViewController.h"

@interface BJLQuestionAnswerManager ()

// 老师和助教答题器窗口
@property (nonatomic, nullable) BJLQuestionAnswerViewController *questionAnswerWindowViewController;
// 学生答题器窗口
@property (nonatomic, nullable, weak) BJLStudentQuestionAnswerWindowViewController *studentQuestionAnswerWindowViewController;
@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic, weak) UIViewController *roomViewController;
@property (nonatomic) BOOL didAddObserver;

@end

@implementation BJLQuestionAnswerManager

- (instancetype)initWithRoom:(BJLRoom *)room roomViewController:(UIViewController *)roomViewController {
    self.room = room;
    self.roomViewController = roomViewController;
    return self;
}

- (BOOL)haveQuestionAnswerAuthority {
    return self.room.loginUser.isTeacher || (self.room.loginUser.isAssistant && self.room.roomVM.getAssistantaAuthorityWithQuestionAnswer);
}

- (void)makeObeservingForQuestionAnswer {
    if (self.didAddObserver) {
        return;
    }
    self.didAddObserver = YES;

    bjl_weakify(self);
    // 答题器
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, liveStarted)
         observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (!self.room.roomVM.liveStarted) {
                 BOOL isTeacher = self.room.loginUser.isTeacher;
                 if (self.questionAnswerWindowViewController && isTeacher) {
                     [self.questionAnswerWindowViewController destroyQuestionAnswer];
                 }
             }
             return YES;
         }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveQuestionAnswerSheet:)
             observer:^BOOL(BJLAnswerSheet *answerSheet) {
                 bjl_strongify(self);
                 if ([self haveQuestionAnswerAuthority]) {
                     if (!self.questionAnswerWindowViewController) {
                         self.questionAnswerWindowViewController = [self displayQuestionAnswerWindowWithAnswerSheet:answerSheet layout:BJLQuestionAnswerWindowLayout_publish];
                         return YES;
                     }
                     if (self.roomViewController.presentedViewController != self.questionAnswerWindowViewController) {
                         [self openQuestionAnswer];
                     }
                 }
                 else if (self.room.loginUser.isStudent && !self.room.loginUser.isAudition) {
                     if (self.studentQuestionAnswerWindowViewController) {
                         [self.studentQuestionAnswerWindowViewController dismissViewControllerAnimated:YES
                                                                                            completion:^{
                                                                                                self.studentQuestionAnswerWindowViewController = nil;
                                                                                                self.studentQuestionAnswerWindowViewController = [self displayQuestionAnswerWindowWithAnswerSheet:answerSheet];
                                                                                            }];
                         return YES;
                     }

                     self.studentQuestionAnswerWindowViewController = [self displayQuestionAnswerWindowWithAnswerSheet:answerSheet];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveCloseQuestionAnswer)
             observer:^BOOL {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }

                 [self destoryQuestionAnswerController];

                 return YES;
             }];

    if (self.room.roomInfo.roomType == BJLRoomType_interactiveClass) {
        return;
    }

    [self bjl_kvo:BJLMakeProperty(self.room, switchingRoom)
        filter:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return now.boolValue;
        }
        observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            if (self.room.switchingRoom) {
                [self destoryQuestionAnswerController];
            }
            return YES;
        }];
}

- (void)destoryQuestionAnswerController {
    //移除正在显示的答题器
    if (self.questionAnswerWindowViewController) {
        [self.questionAnswerWindowViewController destroyQuestionAnswer];
        self.questionAnswerWindowViewController = nil;
    }

    if (self.studentQuestionAnswerWindowViewController) {
        [self.studentQuestionAnswerWindowViewController close];
        self.studentQuestionAnswerWindowViewController = nil;

        if (self.room.loginUser.isStudent) {
            self.showErrorMessageCallback(BJLLocalizedString(@"答题器已被收回"));
        }
    }
}

- (void)openQuestionAnswer {
    if (!self.room.roomVM.liveStarted) {
        self.showErrorMessageCallback(BJLLocalizedString(@"上课状态才能使用答题器"));
        return;
    }

    if (self.room.loginUser.isAssistant && !self.room.roomVM.getAssistantaAuthorityWithQuestionAnswer) {
        self.showErrorMessageCallback(BJLLocalizedString(@"答题器权限被禁用"));
        return;
    }

    if ([self haveQuestionAnswerAuthority] && !self.questionAnswerWindowViewController) {
        BJLAnswerSheet *answerSheet = [[BJLAnswerSheet alloc] initWithAnswerType:BJLAnswerSheetType_Choosen];
        self.questionAnswerWindowViewController = [self displayQuestionAnswerWindowWithAnswerSheet:answerSheet layout:BJLQuestionAnswerWindowLayout_normal];
    }
    else if (self.questionAnswerWindowViewController) {
        [self presentQuestionAnswerWindow:self.questionAnswerWindowViewController];
    }
}

- (void)closeQuestionAnswerController {
    if (self.questionAnswerWindowViewController) {
        [self.questionAnswerWindowViewController destroyQuestionAnswer];
    }
}

- (__kindof UIViewController *)displayQuestionAnswerWindowWithAnswerSheet:(BJLAnswerSheet *)answerSheet
                                                                   layout:(BJLQuestionAnswerWindowLayout)layout {
    BJLQuestionAnswerViewController *questionAnswerViewController = [[BJLQuestionAnswerViewController alloc] initWithRoom:self.room answerSheet:answerSheet layout:layout];

    bjl_weakify(self, questionAnswerViewController);
    [questionAnswerViewController setPublishQuestionAnswerCallback:^(BJLAnswerSheet *answerSheet) {
        bjl_strongify(self);
        [self.room.roomVM requestPublishQuestionAnswerSheet:answerSheet];
    }];

    [questionAnswerViewController setEndQuestionAnswerCallback:^(BOOL close) {
        bjl_strongify(self, questionAnswerViewController);
        [self.room.roomVM requestEndQuestionAnswerWithShouldSyncCloseWindow:close];

        if (close) {
            [questionAnswerViewController dismissViewControllerAnimated:YES
                                                             completion:^{
                                                                 [questionAnswerViewController bjl_removeFromParentViewControllerAndSuperiew];
                                                                 self.questionAnswerWindowViewController = nil;
                                                             }];
        }
    }];

    [questionAnswerViewController setRevokeQuestionAnswerCallback:^{
        bjl_strongify(self);
        [self.room.roomVM requestRevokeQuestionAnswer];
    }];

    [questionAnswerViewController setCloseQuestionAnswerCallback:^{
        bjl_strongify(self);
        [self askToCloseQuestionAnswerController];
    }];

    [questionAnswerViewController setRequestQuestionDetailCallback:^BOOL(NSString *_Nonnull ID) {
        bjl_strongify(self);
        BJLError *error = [self.room.roomVM requestQuestionAnswerDetailInfoWithAnswerSheetID:ID];
        if (error) {
            NSString *errDesc = error.localizedFailureReason ?: error.localizedDescription;
            self.showErrorMessageCallback(errDesc);
            return NO;
        }
        return YES;
    }];

    [questionAnswerViewController setCloseCallback:^{
        bjl_strongify(self, questionAnswerViewController);
        [questionAnswerViewController dismissViewControllerAnimated:YES
                                                         completion:^{
                                                             BJLError *error = [self.room.roomVM requestCloseQuestionAnswer];
                                                             if (error) {
                                                                 NSString *errDesc = error.localizedFailureReason ?: error.localizedDescription;
                                                                 self.showErrorMessageCallback(errDesc);
                                                             }
                                                             [questionAnswerViewController bjl_removeFromParentViewControllerAndSuperiew];
                                                         }];
    }];

    [questionAnswerViewController setErrorCallback:^(NSString *_Nonnull message) {
        bjl_strongify(self);
        self.showErrorMessageCallback(message);
    }];

    if (self.room.roomInfo.roomType == BJLRoomType_interactiveClass) {
        [questionAnswerViewController setKeyboardFrameChangeCallback:^(CGRect keyboardFrame) {
            bjl_strongify(self);
            if (self.keyboardFrameChangeCallback) {
                self.keyboardFrameChangeCallback(keyboardFrame);
            }
        }];
    }

    [self presentQuestionAnswerWindow:questionAnswerViewController];
    return questionAnswerViewController;
}

- (void)presentQuestionAnswerWindow:(BJLQuestionAnswerViewController *)questionAnswerViewController {
    bjl_weakify(self);
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    BOOL needSheetPresent = iPhone && (UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width);
    if (needSheetPresent) {
        BJLSheetPresentationController *sheetPresentationController = [[BJLSheetPresentationController alloc] initWithPresentedViewController:questionAnswerViewController presentingViewController:self.roomViewController];
        [sheetPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (viewController && [viewController isKindOfClass:[BJLQuestionAnswerViewController class]]) {
                if ([questionAnswerViewController keyboardDidShow]) {
                    return YES;
                }
                return NO;
            }
            return YES;
        }];
        questionAnswerViewController.preferredContentSize = CGSizeMake(self.roomViewController.view.bounds.size.width, self.roomViewController.view.bounds.size.height * 0.5);
        if (self.roomViewController.presentedViewController) {
            [self.roomViewController dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            bjl_strongify(self);
                                                            questionAnswerViewController.transitioningDelegate = sheetPresentationController;
                                                            [self.roomViewController presentViewController:questionAnswerViewController animated:YES completion:nil];
                                                        }];

            return;
        }
        questionAnswerViewController.transitioningDelegate = sheetPresentationController;
        [self.roomViewController presentViewController:questionAnswerViewController animated:YES completion:nil];
    }
    else {
        BJLAlertPresentationController *alertPresentationController = [[BJLAlertPresentationController alloc] initWithPresentedViewController:questionAnswerViewController presentingViewController:self.roomViewController];
        [alertPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (viewController && [viewController isKindOfClass:[BJLQuestionAnswerViewController class]]) {
                if ([questionAnswerViewController keyboardDidShow]) {
                    return YES;
                }
                return NO;
            }
            return YES;
        }];

        questionAnswerViewController.preferredContentSize = [questionAnswerViewController presentationSize];
        if (self.roomViewController.presentedViewController) {
            [self.roomViewController dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            bjl_strongify(self);
                                                            questionAnswerViewController.transitioningDelegate = alertPresentationController;
                                                            [self.roomViewController presentViewController:questionAnswerViewController animated:YES completion:nil];
                                                        }];

            return;
        }
        questionAnswerViewController.transitioningDelegate = alertPresentationController;
        [self.roomViewController presentViewController:questionAnswerViewController animated:YES completion:nil];
    }
}

- (__kindof UIViewController *)displayQuestionAnswerWindowWithAnswerSheet:(BJLAnswerSheet *)anwserSheet {
    BJLStudentQuestionAnswerWindowViewController *studentQuestionAnswerViewController = [[BJLStudentQuestionAnswerWindowViewController alloc] initWithRoom:self.room answerSheet:anwserSheet];

    bjl_weakify(self, studentQuestionAnswerViewController);
    [studentQuestionAnswerViewController setErrorCallback:^(NSString *_Nonnull message) {
        bjl_strongify(self);
        self.showErrorMessageCallback(message);
    }];

    [studentQuestionAnswerViewController setSubmitCallback:^BOOL(BJLAnswerSheet *_Nonnull answerSheet) {
        bjl_strongify(self);
        BJLError *error = [self.room.roomVM submitQuestionAnswer:answerSheet];
        if (error) {
            NSString *errDesc = error.localizedFailureReason ?: error.localizedDescription;
            self.showErrorMessageCallback(errDesc);
            return NO;
        }
        self.showErrorMessageCallback(BJLLocalizedString(@"提交成功"));
        return YES;
    }];

    [studentQuestionAnswerViewController setCloseCallback:^{
        bjl_strongify(studentQuestionAnswerViewController);
        [studentQuestionAnswerViewController dismissViewControllerAnimated:YES
                                                                completion:^{
                                                                    [studentQuestionAnswerViewController bjl_removeFromParentViewControllerAndSuperiew];
                                                                }];
    }];

    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    BOOL needSheetPresent = iPhone && (UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width);

    UIViewController *presentedViewController = self.roomViewController;
    while (presentedViewController.presentedViewController) {
        presentedViewController = presentedViewController.presentedViewController;
    }

    if (needSheetPresent) {
        BJLSheetPresentationController *sheetPresentationController = [[BJLSheetPresentationController alloc] initWithPresentedViewController:studentQuestionAnswerViewController presentingViewController:presentedViewController];
        [sheetPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (studentQuestionAnswerViewController.hasReceiveEndMessage) {
                return YES;
            }
            return NO;
        }];

        studentQuestionAnswerViewController.preferredContentSize = CGSizeMake(self.roomViewController.view.bounds.size.width, (self.roomViewController.view.bounds.size.height * 0.35) + (40.0 * (([studentQuestionAnswerViewController answerSheetOptionsCount] - 1) / 4)));
        studentQuestionAnswerViewController.transitioningDelegate = sheetPresentationController;
        [presentedViewController presentViewController:studentQuestionAnswerViewController animated:YES completion:nil];
    }
    else {
        BJLAlertPresentationController *alertPresentationController = [[BJLAlertPresentationController alloc] initWithPresentedViewController:studentQuestionAnswerViewController presentingViewController:self.roomViewController];
        [alertPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (studentQuestionAnswerViewController.hasReceiveEndMessage) {
                return YES;
            }
            return NO;
        }];

        studentQuestionAnswerViewController.preferredContentSize = [studentQuestionAnswerViewController presentationSize];
        studentQuestionAnswerViewController.transitioningDelegate = alertPresentationController;
        [presentedViewController presentViewController:studentQuestionAnswerViewController animated:YES completion:nil];
    }

    return studentQuestionAnswerViewController;
}

- (void)askToCloseQuestionAnswerController {
    BJLPopoverViewController *popoverViewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLCloseWebPage];
    [self.questionAnswerWindowViewController bjl_addChildViewController:popoverViewController superview:self.questionAnswerWindowViewController.view];
    [popoverViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.questionAnswerWindowViewController.view);
    }];
    bjl_weakify(self);
    [popoverViewController setCancelCallback:^{
        bjl_strongify(self);
        [self closeQuestionAnswerController];
    }];
}

@end
