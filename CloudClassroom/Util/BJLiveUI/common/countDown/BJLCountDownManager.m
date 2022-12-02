//
//  BJLCountDownManager.m
//  BJLiveUIBigClass
//
//  Created by HuXin on 2022/2/24.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLCountDownManager.h"
#import "BJLScCountDownEditViewController.h"
#import "BJLScCountDownViewController.h"
#import "BJLAlertPresentationController.h"
#import "BJLSheetPresentationController.h"
#import "BJLWindowViewController+protected.h"

@interface BJLCountDownManager ()

@property (nonatomic, nullable) BJLScCountDownViewController *countDownViewController;
@property (nonatomic, nullable) BJLScCountDownEditViewController *countDownEditViewController;
@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic, weak) UIViewController *roomViewController;
@property (nonatomic) UIView *windowView;
@property (nonatomic) BOOL didAddObserver;

@end

@implementation BJLCountDownManager

- (instancetype)initWithRoom:(BJLRoom *)room roomViewController:(UIViewController *)roomViewController superView:(UIView *)superView {
    self.room = room;
    self.roomViewController = roomViewController;
    self.windowView = superView;
    return self;
}

- (void)makeCountDownViewController {
    if (self.room.loginUser.isAudition) {
        return;
    }

    bjl_weakify(self);
    if (self.room.loginUser.isTeacher) {
        if (!self.countDownEditViewController) {
            self.countDownEditViewController = [[BJLScCountDownEditViewController alloc] initWithRoom:self.room];
            [self.countDownEditViewController setCloseCallback:^{
                bjl_strongify(self);
                [self.countDownEditViewController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }

    if (self.countDownViewController) {
        return;
    }

    self.countDownViewController = [[BJLScCountDownViewController alloc] initWithRoom:self.room];
    [self.countDownViewController setShowCountDownEditViewCallback:^{
        bjl_strongify(self);
        [self showCountDownEditViewController];
    }];
}

- (void)showCountDownEditViewController {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (!self.room.loginUser.isTeacher) {
        return;
    }

    if (!self.countDownEditViewController) {
        [self makeCountDownViewController];
    }
    NSUInteger totalTime = self.countDownViewController.originCountDownTime;
    BOOL isDecrease = self.countDownViewController.isDecrease;
    BOOL shouldPause = self.countDownViewController.shouldPause;
    NSUInteger leftCountDownTime = isDecrease ? self.countDownViewController.currentCountDownTime : (totalTime - self.countDownViewController.currentCountDownTime);
    [self.countDownEditViewController updateTimerWithTotalTime:totalTime
                                          currentCountDownTime:leftCountDownTime
                                                    isDecrease:isDecrease
                                                   shouldPause:shouldPause];
    BOOL needSheetPresent = iPhone && (UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width);
    if (needSheetPresent) {
        BJLSheetPresentationController *sheetPresentationController = [[BJLSheetPresentationController alloc] initWithPresentedViewController:self.countDownEditViewController presentingViewController:self.roomViewController];
        [sheetPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (viewController && [viewController isKindOfClass:[BJLScCountDownEditViewController class]]) {
                if ([self.countDownEditViewController keyboardDidShow]) {
                    return YES;
                }
                return NO;
            }
            return YES;
        }];
        CGFloat height = self.roomViewController.view.bounds.size.height * 0.38 > 220.0 ? self.roomViewController.view.bounds.size.height * 0.38 : 220.0;
        self.countDownEditViewController.preferredContentSize = CGSizeMake(self.roomViewController.view.bounds.size.width, height);
        self.countDownEditViewController.transitioningDelegate = sheetPresentationController;
        [self.roomViewController presentViewController:self.countDownEditViewController animated:YES completion:nil];
    }
    else {
        BJLAlertPresentationController *alertPresentationController = [[BJLAlertPresentationController alloc] initWithPresentedViewController:self.countDownEditViewController presentingViewController:self.roomViewController];
        [alertPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
            if (viewController && [viewController isKindOfClass:[BJLScCountDownEditViewController class]]) {
                if ([self.countDownEditViewController keyboardDidShow]) {
                    return YES;
                }
                return NO;
            }
            return YES;
        }];
        self.countDownEditViewController.transitioningDelegate = alertPresentationController;
        CGFloat height = UIScreen.mainScreen.bounds.size.height * (iPhone ? 0.51 : 0.38) >= 210.0 ? UIScreen.mainScreen.bounds.size.height * (iPhone ? 0.51 : 0.38) : 210.0;
        self.countDownEditViewController.preferredContentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width * (iPhone ? 0.42 : 0.36), height);
        [self.roomViewController presentViewController:self.countDownEditViewController animated:YES completion:nil];
    }
}

- (void)makeObserver {
    if (self.didAddObserver) {
        return;
    }
    self.didAddObserver = YES;

    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveStopTimer)
             observer:^BOOL {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }
                 if (!self.countDownViewController) {
                     return YES;
                 }

                 [self.countDownViewController bjl_removeFromParentViewControllerAndSuperiew];
                 [self.countDownViewController closeWithoutRequest];
                 self.countDownViewController = nil;

                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveTimerWithTotalTime:countDownTime:isDecrease:)
             observer:(BJLMethodObserver) ^ BOOL(NSInteger totalTime, NSInteger countDownTime, BOOL isDecrease) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }

                 BOOL noEditViewController = self.room.loginUser.isTeacher && !self.countDownEditViewController;
                 BOOL noCountDownViewController = !self.countDownViewController;
                 if (noCountDownViewController || noEditViewController) {
                     [self makeCountDownViewController];
                 }

                 if (noEditViewController) {
                     [self.countDownEditViewController updateTimerWithTotalTime:totalTime currentCountDownTime:countDownTime isDecrease:isDecrease shouldPause:NO];
                 }

                 if (noCountDownViewController || self.countDownViewController.state == BJLWindowState_closed) {
                     [self.countDownViewController setWindowedParentViewController:self.roomViewController
                                                                         superview:self.windowView];
                     [self.countDownViewController updateTimerWithTotalTime:totalTime
                                                       currentCountDownTime:countDownTime
                                                                 isDecrease:isDecrease
                                                                shouldPause:NO];
                     [self.countDownViewController openWithoutRequest];
                 }
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceivePauseTimerWithTotalTime:leftCountDownTime:isDecrease:)
             observer:(BJLMethodObserver) ^ BOOL(NSInteger totalTime, NSInteger countDownTime, BOOL isDecrease) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }

                 BOOL noEditViewController = self.room.loginUser.isTeacher && !self.countDownEditViewController;
                 BOOL noCountDownViewController = !self.countDownViewController;
                 if (noCountDownViewController || noEditViewController) {
                     [self makeCountDownViewController];
                 }

                 if (noEditViewController) {
                     [self.countDownEditViewController updateTimerWithTotalTime:totalTime currentCountDownTime:countDownTime isDecrease:isDecrease shouldPause:YES];
                 }

                 if (self.countDownViewController.state == BJLWindowState_closed) {
                     [self.countDownViewController setWindowedParentViewController:self.roomViewController
                                                                         superview:self.windowView];
                     [self.countDownViewController updateTimerWithTotalTime:totalTime currentCountDownTime:countDownTime isDecrease:isDecrease shouldPause:YES];
                     [self.countDownViewController openWithoutRequest];
                 }
                 return YES;
             }];
}

- (BOOL)hitTestViewIsCountDownView:(UIView *)view {
    return view == self.countDownViewController.forgroundView;
}

@end
