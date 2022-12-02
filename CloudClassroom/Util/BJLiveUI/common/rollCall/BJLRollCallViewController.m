//
//  BJLRollCallViewController.m
//  BJLiveUI
//
//  Created by Ney on 1/11/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLRollCallViewController.h"
#import "BJLAppearance.h"
#import <BJLiveCore/BJLRollCallResult.h>
#import "BJLRollCallWidgetView.h"
#import "BJLViewControllerImports.h"
#import "UIView+panGesture.h"
#import "BJLUser+RollCall.h"

#define RemoveObserver(observer)  \
    if (observer) {               \
        [observer stopObserving]; \
        observer = nil;           \
    }

@interface BJLRollCallViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) BJLRoom *room;

@property (nonatomic, strong) UIView *windowContaienrView;
@property (nonatomic, strong) UIView *windowHeadView;
@property (nonatomic, strong) UILabel *windowTitleLabel;
@property (nonatomic, strong) UIButton *windowCloseButton;
@property (nonatomic, strong) UIView *windowHeadSeparatorLineView;

@property (nonatomic, strong) UIView *contentContaienrView;

@property (nonatomic, strong) BJLRollCallStartView *startView;
@property (nonatomic, strong) BJLRollCallCountdownTimerView *countdownView;
@property (nonatomic, strong) BJLRollCallResultView *resultView;
@property (nonatomic, strong) BJLRollCallResult *rollCallResult;

@property (nonatomic, strong) NSTimer *cooldownTimer;
@property (nonatomic, assign) NSInteger cooldownRemain;

@property (nonatomic, assign) BOOL didAddTeacherObserver;
@property (nonatomic, assign) BOOL didAddStudentObserver;
@property (nonatomic, weak) UIViewController *studentAlertParentVC;

@property (nonatomic, assign) BOOL showRollCallStartView;

@property (nonatomic, nullable) id<BJLObservation> rollcallTimeRemainingObserver, didReceiveRollcallWithTimeoutObserver, rollcallDidFinishObserver, onReceiveRollCallResultObserver;

@end

@implementation BJLRollCallViewController
- (instancetype)initWithRoom:(BJLRoom *)room {
    if (!room) { return nil; }

    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.room = room;

        [self buildUI];

        [self addObserverForTeacherIfNeeded];

        if ([self.room.loginUser canLaunchRollCallWithRoom:self.room]) {
            [self.room.roomVM requestLastRollcallResult];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.room.roomVM.rollcallTimeRemaining <= 0) {
        if (self.rollCallResult && self.rollCallResult.hasHistory && !self.showRollCallStartView) {
            [self changeContentView:self.resultView];
        }
        else {
            [self changeContentView:self.startView];
        }
    }
    else {
        [self changeContentView:self.countdownView];
    }
}

- (void)hideRollCall {
    [self closeButtonHandler:nil];
}

- (void)addObserverForStudentIfNeededParentVC:(UIViewController *)parentVC {
    self.studentAlertParentVC = parentVC;

    if (self.didAddStudentObserver) { return; }

    [self makeStudentObserver];
    self.didAddStudentObserver = YES;
}

- (void)addObserverForTeacherIfNeeded {
    if (self.didAddTeacherObserver) { return; }

    [self makeTeacherObserver];
    self.didAddTeacherObserver = YES;
}

- (void)changeContentView:(UIView *)view {
    if (view.superview == self.contentContaienrView) { return; }

    for (UIView *view in self.contentContaienrView.subviews.copy) {
        [view removeFromSuperview];
    }

    [self.contentContaienrView addSubview:view];
    [view bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.contentContaienrView);
    }];
}

#pragma mark - event handler
- (void)startRollCallHandler:(UIButton *)button {
    BJLError *error = [self.room.roomVM sendRollcallWithTimeout:self.startView.time];
    if (error) {
        [self showProgressHUDWithText:BJLLocalizedString(error.localizedFailureReason)];
    }
}

- (void)rollCallAgainHandler:(UIButton *)button {
    if (self.cooldownTimer) { return; }
    if (self.rollCallAgainBlock) {
        self.rollCallAgainBlock();
    }
    [self changeContentView:self.startView];
    self.showRollCallStartView = YES;
}

- (void)closeButtonHandler:(UIButton *)button {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self bjl_removeFromParentViewControllerAndSuperiew];
                             }];
}

#pragma mark - helper
- (CGSize)presentationSize {
    return CGSizeMake(280.0, 180.0);
}

- (void)buildUI {
    [self.view addSubview:self.windowContaienrView];
    [self.windowContaienrView addSubview:self.windowHeadView];
    [self.windowContaienrView addSubview:self.contentContaienrView];

    [self.windowContaienrView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.windowHeadView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.top.right.equalTo(self.windowContaienrView);
        make.height.equalTo(@30.0);
    }];
    [self.contentContaienrView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.windowHeadView.bjl_bottom);
        make.left.bottom.right.equalTo(self.windowContaienrView);
    }];
}

- (void)makeTeacherObserver {
    if (self.room.loginUser.isStudent) { return; }

    [self resetTeacherObserver];
    [self addObserverForSwitchRoom];
}

- (void)resetTeacherObserver {
    RemoveObserver(self.rollcallTimeRemainingObserver);
    RemoveObserver(self.didReceiveRollcallWithTimeoutObserver);
    RemoveObserver(self.rollcallDidFinishObserver);
    RemoveObserver(self.onReceiveRollCallResultObserver);

    if (![self.room.loginUser canLaunchRollCallWithRoom:self.room]) {
        self.view.hidden = YES;
        return;
    }

    self.view.hidden = NO;
    bjl_weakify(self);
    self.rollcallTimeRemainingObserver = [self bjl_kvo:BJLMakeProperty(self.room.roomVM, rollcallTimeRemaining)
                                              observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                                                  bjl_strongify(self);
                                                  [self.countdownView updateTime:self.room.roomVM.rollcallTimeRemaining];
                                                  return YES;
                                              }];

    self.didReceiveRollcallWithTimeoutObserver = [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveRollcallWithTimeout:)
                                                          observer:^BOOL(NSTimeInterval timeout) {
                                                              bjl_strongify(self);
                                                              [self changeContentView:self.countdownView];

                                                              if (self.rollCallActiveStateChangeBlock) {
                                                                  self.rollCallActiveStateChangeBlock(self, YES);
                                                              }
                                                              return YES;
                                                          }];

    self.rollcallDidFinishObserver = [self bjl_observe:BJLMakeMethod(self.room.roomVM, rollcallDidFinish)
                                              observer:^BOOL {
                                                  bjl_strongify(self);
                                                  if (self.rollCallActiveStateChangeBlock) {
                                                      self.rollCallActiveStateChangeBlock(self, NO);
                                                  }
                                                  return YES;
                                              }];

    self.onReceiveRollCallResultObserver = [self bjl_observe:BJLMakeMethod(self.room.roomVM, onReceiveRollCallResult:)
                                                    observer:^BOOL(BJLRollCallResult *result) {
                                                        bjl_strongify(self);
                                                        if (result.hasHistory) {
                                                            if (self.rollCallActiveStateChangeBlock) {
                                                                self.rollCallActiveStateChangeBlock(self, NO);
                                                            }
                                                            [self.resultView updateRollCallResult:result];
                                                            [self changeContentView:self.resultView];
                                                        }
                                                        if (self.rollCallResult) { //有过点名记录的才会有再次点名的cd
                                                            [self startCoolDownTimer];
                                                            self.showRollCallStartView = NO;
                                                        }
                                                        self.rollCallResult = result;
                                                        return YES;
                                                    }];
}

- (void)addObserverForSwitchRoom {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, switchingRoom)
        filter:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            return !now.boolValue;
        }
        observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            [self resetTeacherObserver];
            return YES;
        }];
}

- (void)makeStudentObserver {
    if (self.room.loginUser.isTeacherOrAssistant) { return; }

    bjl_weakify(self);
    NSString *const rollcallTitleFormat = BJLLocalizedString(@"老师要求你在%.0f秒内响应点名");
    __block UIAlertController *rollcallAlert = nil;
    __block id<BJLObservation> observation = nil;
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveRollcallWithTimeout:)
             observer:^BOOL(NSTimeInterval timeout) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition || self.room.loginUser.isTeacherOrAssistant) {
                     return YES;
                 }
                 if (rollcallAlert) {
                     [rollcallAlert dismissViewControllerAnimated:NO completion:nil];
                 }

                 rollcallAlert = [UIAlertController alertControllerWithTitle:BJLLocalizedString(@"点名")
                                                                     message:[NSString stringWithFormat:rollcallTitleFormat, timeout]
                                                              preferredStyle:UIAlertControllerStyleAlert];
                 [rollcallAlert bjl_addActionWithTitle:BJLLocalizedString(@"答到")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *_Nonnull action) {
                                                   bjl_strongify(self);
                                                   rollcallAlert = nil;
                                                   [observation stopObserving];
                                                   observation = nil;
                                                   [self.room.roomVM answerToRollcall];
                                               }];

                 UIViewController *presentedViewController = self.studentAlertParentVC;
                 while (presentedViewController.presentedViewController) {
                     presentedViewController = presentedViewController.presentedViewController;
                 }
                 [presentedViewController presentViewController:rollcallAlert animated:YES completion:nil];

                 observation = [self bjl_kvo:BJLMakeProperty(self.room.roomVM, rollcallTimeRemaining)
                                    observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                                        bjl_strongify(self);
                                        rollcallAlert.message = [NSString stringWithFormat:rollcallTitleFormat, self.room.roomVM.rollcallTimeRemaining];
                                        return YES;
                                    }];
                 return YES;
             }];
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, rollcallDidFinish)
             observer:^BOOL {
                 bjl_strongify(self);
                 if (self.room.loginUser.isAudition) {
                     return YES;
                 }
                 [observation stopObserving];
                 observation = nil;
                 [rollcallAlert dismissViewControllerAnimated:YES completion:nil];
                 rollcallAlert = nil;
                 return YES;
             }];
}

- (void)startCoolDownTimer {
    [self invalidateTimer];

    self.cooldownRemain = 60;

    bjl_weakify(self);
    self.cooldownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        if (!self) {
            [timer invalidate];
            return;
        }

        [self timerHandler:timer];
    }];

    //马上调用一次
    [self timerHandler:nil];

    [[NSRunLoop currentRunLoop] addTimer:self.cooldownTimer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer {
    [self.cooldownTimer invalidate];
    self.cooldownTimer = nil;
}

- (void)timerHandler:(NSTimer *)timer {
    self.cooldownRemain--;
    [self.resultView updateCooldownRemainTime:self.cooldownRemain];
    if (self.cooldownRemain <= 0) {
        [self invalidateTimer];
    }
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.windowContaienrView]) {
        return NO;
    }
    return YES;
}

#pragma mark - getter

- (UIView *)windowContaienrView {
    if (!_windowContaienrView) {
        _windowContaienrView = [[UIView alloc] init];
        _windowContaienrView.accessibilityIdentifier = @"windowContaienrView";
        _windowContaienrView.backgroundColor = BJLTheme.windowBackgroundColor;
        _windowContaienrView.clipsToBounds = YES;
        _windowContaienrView.layer.cornerRadius = 3;
    }
    return _windowContaienrView;
}

- (UIView *)windowHeadView {
    if (!_windowHeadView) {
        _windowHeadView = [[UIView alloc] init];
        _windowHeadView.accessibilityIdentifier = @"windowHeadView";
        _windowHeadView.backgroundColor = [UIColor clearColor];

        [_windowHeadView addSubview:self.windowTitleLabel];
        [_windowHeadView addSubview:self.windowCloseButton];
        [_windowHeadView addSubview:self.windowHeadSeparatorLineView];

        [self.windowTitleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(_windowHeadView);
            make.left.equalTo(_windowHeadView.bjl_left).offset(5.0);
        }];
        [self.windowCloseButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(_windowHeadView);
            make.right.equalTo(@(-5.0));
        }];
        [self.windowHeadSeparatorLineView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.left.bottom.right.equalTo(_windowHeadView);
            make.height.equalTo(@(BJL1Pixel()));
        }];
    }
    return _windowHeadView;
}

- (UILabel *)windowTitleLabel {
    if (!_windowTitleLabel) {
        _windowTitleLabel = [[UILabel alloc] init];
        _windowTitleLabel.accessibilityIdentifier = @"windowTitleLabel";
        _windowTitleLabel.text = BJLLocalizedString(@"点名");
        _windowTitleLabel.font = [UIFont systemFontOfSize:14];
        _windowTitleLabel.textColor = BJLTheme.viewTextColor;
        _windowTitleLabel.backgroundColor = UIColor.clearColor;
    }
    return _windowTitleLabel;
}

- (UIButton *)windowCloseButton {
    if (!_windowCloseButton) {
        _windowCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _windowCloseButton.accessibilityIdentifier = @"windowCloseButton";

        [_windowCloseButton setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];

        bjl_weakify(self);
        [_windowCloseButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self closeButtonHandler:button];
        }];
    }
    return _windowCloseButton;
}

- (UIView *)windowHeadSeparatorLineView {
    if (!_windowHeadSeparatorLineView) {
        _windowHeadSeparatorLineView = [[UIView alloc] init];
        _windowHeadSeparatorLineView.backgroundColor = BJLTheme.separateLineColor;
        _windowHeadSeparatorLineView.accessibilityIdentifier = @"windowHeadSeparatorLineView";
    }
    return _windowHeadSeparatorLineView;
}

- (UIView *)contentContaienrView {
    if (!_contentContaienrView) {
        _contentContaienrView = [[UIView alloc] init];
        _contentContaienrView.backgroundColor = [UIColor clearColor];
        _contentContaienrView.accessibilityIdentifier = @"contentContaienrView";
    }
    return _contentContaienrView;
}

- (BJLRollCallStartView *)startView {
    if (!_startView) {
        _startView = [[BJLRollCallStartView alloc] init];
        _startView.accessibilityIdentifier = @"startView";

        bjl_weakify(self);
        [_startView.startRollCallButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self startRollCallHandler:button];
        }];
    }
    return _startView;
}

- (BJLRollCallCountdownTimerView *)countdownView {
    if (!_countdownView) {
        _countdownView = [[BJLRollCallCountdownTimerView alloc] init];
        _countdownView.accessibilityIdentifier = @"countdownView";
    }
    return _countdownView;
}

- (BJLRollCallResultView *)resultView {
    if (!_resultView) {
        _resultView = [[BJLRollCallResultView alloc] init];
        _resultView.accessibilityIdentifier = @"resultView";
        bjl_weakify(self);
        [_resultView.rollCallAgainButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self rollCallAgainHandler:button];
        }];
    }
    return _resultView;
}
@end
