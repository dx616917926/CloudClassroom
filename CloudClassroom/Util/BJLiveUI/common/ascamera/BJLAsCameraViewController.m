//
//  BJLAsCameraViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2020/11/12.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLAsCameraViewController.h"
#import "BJLLoadingViewController.h"
#import "BJLPopoverViewController.h"
#import "BJLPromptViewController.h"
#import "BJLTheme.h"
#import "BJLAppearance.h"

@interface BJLAsCameraViewController ()

@property (nonatomic, readwrite, nullable) BJLRoom *room;
@property (nonatomic) CGRect keyboardFrame;
@property (nonatomic, nullable) BJLAFNetworkReachabilityManager *reachability;
@property (nonatomic, nullable) BJLProgressHUD *prevHUD;

@property (nonatomic) UIView *loadingContainerView;
@property (nonatomic) BJLLoadingViewController *loadingViewController;
@property (nonatomic) BJLPromptViewController *promptViewController;

@property (nonatomic) UIView *contentContainerView;
@property (nonatomic) UIView *videoAreaContainerView;
@property (nonatomic) UIView *videoContainerView;
@property (nonatomic) UIView *videoEmptyStateContainerView;
@property (nonatomic) UIImageView *videoEmptyImageView;
@property (nonatomic) UILabel *videoEmptyDesciptionLabel;

@property (nonatomic) UIStackView *menuStackView;
@property (nonatomic) NSArray *menuButtonItems;
@property (nonatomic) UIButton *cameraTypeSwitchButton;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UIButton *videoDefinitionSwitchButton;

@end

@implementation BJLAsCameraViewController {
    BOOL _entered;
}

+ (nullable __kindof instancetype)instanceWithURLString:(NSString *)string {
    BJLRoom *room = [BJLRoom roomWithURLString:string];
    if (!room) {
        return nil;
    }
    return [[self alloc] initWithRoom:room];
}

- (instancetype)initWithRoom:(BJLRoom *)room {
    NSParameterAssert(room);
    self = [super init];
    if (self) {
        self.room = room;
        [BJLTheme setupColorWithConfig:nil];
    }
    return self;
}

#pragma mark - enter

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    /* 第一次 `viewDidAppear:` 时进入直播间、而不是 `viewDidLoad`，因为要避免
     在创建 `BJLScRoomViewController` 实例后、如果触发 `viewDidLoad` 但没有立即展示；
     然后 `viewDidLoad` 中调用 `enter`，进直播间过程中可能需要弹出提示；
     但在 `viewDidAppear:` 之前弹出的提示无法显示，并在终端打印警告。
     Warning: Attempt to present <UIAlertController> on <BJLScRoomViewController> whose view
     is not in the window hierarchy!
     */
    if (!_entered) {
        _entered = YES;
        [self.room enterByValidatingConflict:YES];
    }

    NSNotificationCenter *defaultCenter = NSNotificationCenter.defaultCenter;
    [defaultCenter addObserver:self
                      selector:@selector(keyboardDidHideWithNotification:)
                          name:UIKeyboardDidHideNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(keyboardWillChangeFrameWithNotification:)
                          name:UIKeyboardWillChangeFrameNotification
                        object:nil];
    // WKWebView 弹出全屏播放器，返回后 UI 方向、样式出问题
    // 1. 强转：Left 直播间，弹出播放器、转到 Portrait、Right、Portrait，退出全屏播放器，直播间竖屏显示一部分
    bjl_weakify(self);
    [defaultCenter addObserverForName:UIWindowDidBecomeKeyNotification
                               object:nil
                                queue:nil
                           usingBlock:^(NSNotification *_Nonnull note) {
                               bjl_strongify(self);
                               if (self.view.window.isKeyWindow) {
                                   UIInterfaceOrientationMask supportedOrt = self.supportedInterfaceOrientations;
                                   UIInterfaceOrientation targetOrt = (UIInterfaceOrientation)UIDevice.currentDevice.orientation;
                                   if (!(supportedOrt & (1 << targetOrt))) {
                                       if (@available(iOS 13.0, *))
                                           targetOrt = self.view.window.windowScene.interfaceOrientation;
                                       else
                                           targetOrt = UIApplication.sharedApplication.statusBarOrientation;
                                   }
                                   if (!(supportedOrt & (1 << targetOrt))) {
                                       targetOrt = self.bjl_preferredInterfaceOrientation;
                                   }
                                   UIInterfaceOrientation tempOrt = (targetOrt != UIInterfaceOrientationPortrait ? UIInterfaceOrientationPortrait : UIInterfaceOrientationPortraitUpsideDown);
                                   // 2. 延时强转：Left 直播间，弹出播放器，退出全屏播放器，直播间竖屏显示一部分
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       [UIDevice.currentDevice setValue:@(tempOrt) forKey:@"orientation"];
                                       [UIDevice.currentDevice setValue:@(targetOrt) forKey:@"orientation"];
                                   });
                               }
                           }];
}

#pragma mark - exit

- (void)roomDidExitWithError:(BJLError *)error {
    // !error: 主动退出
    // BJLErrorCode_exitRoom_disconnected: self.loadingViewController 已处理
    if (!error
        || error.code == BJLErrorCode_exitRoom_disconnected
        || error.code == BJLErrorCode_exitRoom_noReplacedUser) { // 因为被替换的用户的原因退出直播间不显示提示
        [self dismissWithError:error];
        return;
    }

    if (error.code == BJLErrorCode_enterRoom_auditionTimeout
        || error.code == BJLErrorCode_exitRoom_auditionTimeout) {
        SEL setTitle_ = @selector(setTitle:);
        BOOL enableCountdown = [UIAlertAction instancesRespondToSelector:setTitle_];
        NSString *const defaultTitle = BJLLocalizedString(@"确定");
        NSString *const format = @" (%td)";

        __block UIAlertController *alert = nil;
        __block UIAlertAction *action = nil;
        __block NSInteger countdown = 5;

        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *_Nonnull timer) {
            countdown--;
            if (enableCountdown) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [action performSelector:setTitle_ withObject:[defaultTitle stringByAppendingFormat:format, countdown]];
#pragma clang diagnostic pop
            }
            if (countdown <= 0) {
                [timer invalidate];
                if (self.presentedViewController == alert) {
                    [alert dismissViewControllerAnimated:NO completion:^{
                        [self dismissWithError:error];
                    }];
                }
            }
        }];

        alert = [UIAlertController
            alertControllerWithTitle:self.room.featureConfig.auditionEndTip ?: BJLLocalizedString(@"哎呀，您的试听时间已到！")
                             message:nil
                      preferredStyle:UIAlertControllerStyleAlert];
        action = [alert bjl_addActionWithTitle:(enableCountdown ? [defaultTitle stringByAppendingFormat:format, countdown] : defaultTitle) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            [timer invalidate];
            [self dismissWithError:error];
        }];
        [UIWindow.bjl_keyWindow.bjl_visibleViewController presentViewController:alert animated:YES completion:nil];

        return;
    }

    NSString *message = [NSString stringWithFormat:@"%@: %@(%td)",
                                  error.localizedDescription,
                                  error.localizedFailureReason ?: @"",
                                  error.code];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:message
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];
    bjl_weakify(self);
    [alert addAction:[UIAlertAction
                         actionWithTitle:BJLLocalizedString(@"确定")
                                   style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction *_Nonnull action) {
                                     bjl_strongify(self);
                                     [self dismissWithError:error];
                                 }]];
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [UIWindow bjl_presentAlertController:alert animated:YES completion:nil];
}

- (void)exit {
    [BJLTheme destroy];
    if (self.room) {
        [self.room exit];
    }
    else {
        [self dismissWithError:nil];
    }
}

- (void)dismissWithError:(nullable BJLError *)error {
    [self roomViewController:self willExitWithError:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    bjl_weakify(self);
    void (^completion)(void) = ^{
        bjl_strongify(self);
        [self roomViewController:self didExitWithError:error];
    };

    UINavigationController *navigation = [self.parentViewController bjl_as:[UINavigationController class]];
    BOOL isRoot = (navigation
                   && self == navigation.topViewController
                   && self == navigation.bjl_rootViewController);
    UIViewController *outermost = isRoot ? navigation : self;

    // pop
    if (navigation && !isRoot) {
        [navigation bjl_popViewControllerAnimated:YES completion:completion];
    }
    // dismiss
    else if (!outermost.parentViewController && outermost.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
    // close in `roomViewController:didExitWithError:`
    else {
        completion();
    }
}

#pragma mark - NSNotification

- (void)keyboardDidHideWithNotification:(NSNotification *)notification {
    self.keyboardFrame = CGRectZero;
}

- (void)keyboardWillChangeFrameWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) {
        return;
    }

    self.keyboardFrame = bjl_as(userInfo[UIKeyboardFrameEndUserInfoKey], NSValue).CGRectValue;
}

#pragma mark - subviews

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeSubviewsAndConstraints];
    [self makeObserving];
}

- (void)makeSubviewsAndConstraints {
    [self.view addSubview:self.contentContainerView];
    [self.view addSubview:self.loadingContainerView];

    [self.contentContainerView addSubview:self.videoAreaContainerView];
    [self.contentContainerView addSubview:self.menuStackView];

    [self.videoAreaContainerView addSubview:self.videoEmptyStateContainerView];
    [self.videoAreaContainerView addSubview:self.videoContainerView];

    [self.videoEmptyStateContainerView addSubview:self.videoEmptyImageView];
    [self.videoEmptyStateContainerView addSubview:self.videoEmptyDesciptionLabel];

    [self.contentContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.loadingContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.videoAreaContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            make.left.right.equalTo(self.contentContainerView);
            make.centerY.equalTo(self.contentContainerView);
            make.height.equalTo(self.videoAreaContainerView.bjl_width).multipliedBy(9.0 / 16.0);
        }
        else {
            make.top.bottom.equalTo(self.contentContainerView);
            make.centerX.equalTo(self.contentContainerView);
            make.width.equalTo(self.videoAreaContainerView.bjl_height).multipliedBy(16.0 / 9.0);
        }
    }];

    [self.videoEmptyStateContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.videoAreaContainerView);
    }];
    [self.videoEmptyImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self.videoEmptyStateContainerView);
        make.height.equalTo(@160.0);
        make.width.equalTo(@160.0);
    }];
    [self.videoEmptyDesciptionLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self.videoEmptyImageView);
        make.top.equalTo(self.videoEmptyImageView.bjl_bottom).offset(5.0);
    }];

    [self.videoContainerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.videoAreaContainerView);
    }];

    [self.menuStackView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            make.centerX.equalTo(self.contentContainerView);
            make.bottom.equalTo(self.contentContainerView).offset(-20.0);
        }
        else {
            make.centerY.equalTo(self.contentContainerView);
            make.right.equalTo(self.contentContainerView).offset(-20.0);
        }
    }];

    for (UIButton *btn in self.menuButtonItems) {
        [btn bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.width.height.equalTo(@60.0f);
        }];
    }

    // prompt
    self.promptViewController = [[BJLPromptViewController alloc] init];
    [self bjl_addChildViewController:self.promptViewController superview:self.loadingContainerView];
    [self.promptViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.loadingContainerView);
        make.height.equalTo(@(BJLPromptViewController.defaultAppearance.promptViewHeight));
    }];

    // loading
    self.loadingViewController = [[BJLLoadingViewController alloc] initWithRoom:self.room isInteractiveClass:NO];
    self.loadingViewController.ignoreTemplate = YES;
    bjl_weakify(self);
    [self.loadingViewController setExitCallback:^{
        bjl_strongify(self);
        [self exit];
    }];
    [self bjl_addChildViewController:self.loadingViewController superview:self.loadingContainerView];
    [self.loadingViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.loadingContainerView);
    }];
}

#pragma mark - observer

- (void)makeObserving {
    bjl_weakify(self);
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
                                 [self.promptViewController enqueueWithPrompt:BJLLocalizedString(@"正在使用3G/4G网络")];
                             }
                         });
                     }];
                     [reachability startMonitoring];
                     reachability;
                 });
                 // 进入直播间成功才设置断网重连 block
                 [self.room setReloadingBlock:^(BJLLoadingVM *_Nonnull reloadingVM, void (^_Nonnull callback)(BOOL)) {
                     bjl_strongify(self);
                     [self.promptViewController enqueueWithPrompt:BJLLocalizedString(@"网络中断！正在尝试重新连接...") duration:0 important:YES];
                     [self makeObservingForLoadingVM:reloadingVM];
                     callback(YES);
                 }];

                 [self makeObservingAfterEnterRoom];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, enterRoomFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self roomViewController:self enterRoomFailureWithError:error];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room, roomDidExitWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self roomDidExitWithError:error];
                 return YES;
             }];

    __block UIAlertController *alertController = nil;
    [self.room.recordingVM setCheckMicrophoneAndCameraAccessCallback:^(BOOL microphone, BOOL camera, BOOL granted, UIAlertController *_Nullable alert) {
        bjl_strongify(self);
        if (granted) {
            return;
        }
        if (alert) {
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
        }
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
        if (reason != BJLLoadingSuspendReason_errorOccurred) {
            continueCallback(YES);
            return;
        }

        NSInteger progress = 1;
        switch (step) {
            case BJLLoadingStep_checkNetwork:
                progress = 1;
                break;

            case BJLLoadingStep_loadRoomInfo:
                progress = 2;
                break;

            case BJLLoadingStep_connectRoomServer:
                progress = 3;
                break;

            case BJLLoadingStep_connectMasterServer:
                progress = 4;
                break;

            default:
                break;
        }

        if (error.code == BJLErrorCode_enterRoom_timeExpire) {
            BJLPopoverViewController *popoverViewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLExitViewTimeOut message:[NSString stringWithFormat:BJLLocalizedString(@"直播间已过期")]];
            [self bjl_addChildViewController:popoverViewController superview:self.loadingContainerView];
            [popoverViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.loadingContainerView);
            }];
            [popoverViewController setConfirmCallback:^{
                bjl_strongify(self);
                continueCallback(NO);
                [self exit];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else {
            BJLPopoverViewController *popoverViewController = [[BJLPopoverViewController alloc] initWithPopoverViewType:BJLExitViewConnectFail
                                                                                                                message:[NSString stringWithFormat:BJLLocalizedString(@"网络连接失败（进度%ld/4），您可以退出或继续连接"), (long)progress]];
            [self bjl_addChildViewController:popoverViewController superview:self.loadingContainerView];
            [popoverViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.loadingContainerView);
            }];
            [popoverViewController setCancelCallback:^{
                bjl_strongify(self);
                continueCallback(NO);
                [self exit];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [popoverViewController setConfirmCallback:^{
                continueCallback(YES);
            }];
        }
    };

    [self bjl_observe:BJLMakeMethod(loadingVM, loadingSuccess)
             observer:^BOOL() {
                 bjl_strongify(self);
                 [self.promptViewController enqueueWithPrompt:BJLLocalizedString(@"重新连接成功")];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(loadingVM, loadingFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self.promptViewController enqueueWithPrompt:BJLLocalizedString(@"连接失败")];
                 return YES;
             }];
}

- (void)makeObservingAfterEnterRoom {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, activeUsersSynced)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if ([value bjl_boolValue]) {
                 [self autoStartRecordingVideo];
             }
             return YES;
         }];
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingVideo)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if ([value bjl_boolValue]) {
                 [self switchVideoAreaAsNormalState];
             }
             else {
                 [self switchVideoAreaAsCameraDisableState];
             }
             return YES;
         }];
    // 暂时不区分屏幕共享导致的关闭视频
    //    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.playingVM, playingUsers),
    //                         BJLMakeProperty(self.room.playingVM, extraPlayingUsers),
    //                         BJLMakeProperty(self.room.playingVM, mixedPlayingUsers),
    //                         BJLMakeProperty(self.room.playingVM, extraMixedPlayingUsers)]
    //              observer:^(NSArray *  _Nullable playingUsers, id  _Nullable oldValue, BJLPropertyChange * _Nullable change) {
    //        bjl_strongify(self);
    //        BOOL existReplaceUserUseOtherMainMediaSource = NO;
    //        for (BJLMediaUser *mediaUser in playingUsers) {
    //            if ([mediaUser isSameUserWithID:nil number:self.room.loginUser.replaceNumber]) {
    //                if (mediaUser.videoOn
    //                    && mediaUser.mediaSource != BJLMediaSource_mainCamera
    //                    && mediaUser.cameraType != BJLCameraType_extra) {
    //                    existReplaceUserUseOtherMainMediaSource = YES;
    //                    break;
    //                }
    //            }
    //        }
    //        if (existReplaceUserUseOtherMainMediaSource && !self.room.recordingVM.recordingVideo) {
    //            [self switchVideoAreaAsScreenShareState];
    //        }
    //    }];

    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, liveStarted)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (!self.room.roomVM.liveStarted) {
                 [self exit];
             }
             return YES;
         }];
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, videoDefinition)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.videoDefinitionSwitchButton setTitle:[self definitionKeyWithType:[value bjl_integerValue]] forState:UIControlStateNormal];
             return YES;
         }];
}

#pragma mark - action

- (void)autoStartRecordingVideo {
    BJLError *error = [self.room.recordingVM setRecordingAudio:NO recordingVideo:YES];
    if (error) {
        [self.promptViewController enqueueWithPrompt:error.localizedFailureReason ?: error.localizedDescription];
    }
    else {
        [self switchVideoAreaAsNormalState];
    }
}

- (void)switchVideoAreaAsNormalState {
    if (self.room.recordingVM.recordingVideo && self.room.recordingView.superview != self.videoContainerView) {
        [self.videoContainerView addSubview:self.room.recordingView];
        [self.room.recordingView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.videoContainerView);
        }];
    }

    self.videoContainerView.hidden = NO;
    self.videoEmptyStateContainerView.hidden = YES;
}

- (void)switchVideoAreaAsScreenShareState {
    self.videoContainerView.hidden = YES;
    self.videoEmptyImageView.image = [UIImage bjl_imageNamed:@"bjl_external_camera_screen_share"];
    self.videoEmptyDesciptionLabel.hidden = NO;
    self.videoEmptyStateContainerView.hidden = NO;
}
- (void)switchVideoAreaAsCameraDisableState {
    self.videoContainerView.hidden = YES;
    self.videoEmptyImageView.image = [UIImage bjl_imageNamed:@"bjl_external_camera_disable"];
    self.videoEmptyDesciptionLabel.hidden = YES;
    self.videoEmptyStateContainerView.hidden = NO;
}

- (void)showMenuButtons {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMenuButtons) object:nil];
    self.menuStackView.hidden = NO;
    [self performSelector:@selector(hideMenuButtons) withObject:nil afterDelay:30.0];
}

- (void)hideMenuButtons {
    self.menuStackView.hidden = YES;
}

#pragma mark - definition

- (void)showVideoDefinitionActionSheet {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMenuButtons) object:nil];
    BJLVideoDefinition lowDefinition = BJLVideoDefinition_std;
    BJLVideoDefinition highDefinition = BJLVideoDefinition_std;
    if (self.room.roomInfo.roomType == BJLRoomType_interactiveClass) {
        highDefinition = self.room.featureConfig.maxVideoDefinition;
    }
    else {
        highDefinition = self.room.featureConfig.support720p
                             ? BJLVideoDefinition_720p
                             : BJLVideoDefinition_high;
    }
    UIAlertController *actionSheet = [UIAlertController
        alertControllerWithTitle:BJLLocalizedString(@"设置清晰度")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];
    bjl_weakify(self);
    for (BJLVideoDefinition definition = lowDefinition; definition <= highDefinition; definition++) {
        // 大班课不用切换 360p
        if (definition == BJLVideoDefinition_360p && self.room.roomInfo.roomType != BJLRoomType_interactiveClass) {
            continue;
        }
        UIAlertAction *action = [UIAlertAction actionWithTitle:[self definitionKeyWithType:definition] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            bjl_strongify(self);
            [self.room.recordingVM updateVideoDefinition:definition];
            [self showMenuButtons];
        }];
        action.enabled = (self.room.recordingVM.videoDefinition != definition);
        [actionSheet addAction:action];
    }
    [actionSheet bjl_addActionWithTitle:BJLLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        bjl_strongify(self);
        [self showMenuButtons];
    }];
    [self showAlertViewController:actionSheet sourceView:self.view];
}

- (NSString *)definitionKeyWithType:(BJLVideoDefinition)definition {
    switch (definition) {
        case BJLVideoDefinition_std:
            return BJLLocalizedString(@"标清");

        case BJLVideoDefinition_360p:
            return @"360p";

        case BJLVideoDefinition_high:
            return BJLLocalizedString(@"高清");

        case BJLVideoDefinition_720p:
            return @"720p";

        case BJLVideoDefinition_1080p:
            return @"1080p";

        default:
            return BJLLocalizedString(@"标清");
    }
}

#pragma mark - hud

- (void)showProgressHUDWithText:(NSString *)text {
    if (!text.length
        || [text isEqualToString:self.prevHUD.detailsLabel.text]) {
        return;
    }

    BJLProgressHUD *hud = [BJLProgressHUD bjl_hudForTextWithSuperview:self.view];
    [hud bjl_makeDetailsLabelWithLabelStyle];
    hud.detailsLabel.text = text;
    hud.minShowTime = 0.0; // !!!: MUST be 0.0
    bjl_weakify(self, hud);
    hud.completionBlock = ^{
        bjl_strongify(self, hud);
        if (hud == self.prevHUD) {
            self.prevHUD = nil;
        }
    };

    if (self.prevHUD) {
        [self.prevHUD hideAnimated:NO];
    }
    CGFloat minY = CGRectGetMinY(self.keyboardFrame);
    if (minY > CGFLOAT_MIN) {
        hud.offset = CGPointMake(0, -(CGRectGetHeight(self.view.frame) - minY) / 2);
    }
    [hud showAnimated:NO]; // YES?
    [hud hideAnimated:YES afterDelay:BJLProgressHUDTimeInterval];
    self.prevHUD = hud;
}

#pragma mark - alert

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

#pragma mark - UIViewControllerRotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.bjl_preferredInterfaceOrientation;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

- (BOOL)prefersStatusBarHidden {
    BOOL hidden = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    return hidden;
}

// NOTE: call `[self setNeedsUpdateOfHomeIndicatorAutoHidden]` if return value changed
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark - observable methods

- (BJLObservable)roomViewControllerEnterRoomSuccess:(BJLAsCameraViewController *)roomViewController {
    BJLMethodNotify((BJLAsCameraViewController *),
        roomViewController);
    if ([self.delegate respondsToSelector:@selector(roomViewControllerEnterRoomSuccess:)]) {
        [self.delegate roomViewControllerEnterRoomSuccess:self];
    }
}

- (BJLObservable)roomViewController:(BJLAsCameraViewController *)roomViewController
          enterRoomFailureWithError:(BJLError *)error {
    BJLMethodNotify((BJLAsCameraViewController *, BJLError *),
        roomViewController,
        error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:enterRoomFailureWithError:)]) {
        [self.delegate roomViewController:self enterRoomFailureWithError:error];
    }
}

- (BJLObservable)roomViewController:(BJLAsCameraViewController *)roomViewController
                  willExitWithError:(nullable BJLError *)error {
    BJLMethodNotify((BJLAsCameraViewController *, BJLError *),
        roomViewController,
        error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:willExitWithError:)]) {
        [self.delegate roomViewController:self willExitWithError:error];
    }
}

- (BJLObservable)roomViewController:(BJLAsCameraViewController *)roomViewController
                   didExitWithError:(nullable BJLError *)error {
    BJLMethodNotify((BJLAsCameraViewController *, BJLError *),
        roomViewController,
        error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:didExitWithError:)]) {
        [self.delegate roomViewController:self didExitWithError:error];
    }
}

#pragma mark - getter

- (NSArray *)menuButtonItems {
    if (!_menuButtonItems) {
        _menuButtonItems = @[self.cameraTypeSwitchButton,
            self.closeButton,
            self.videoDefinitionSwitchButton];
    }
    return _menuButtonItems;
}

- (UIView *)loadingContainerView {
    if (!_loadingContainerView) {
        _loadingContainerView = [[BJLHitTestView alloc] init];
        _loadingContainerView.backgroundColor = [UIColor clearColor];
    }
    return _loadingContainerView;
}

- (UIView *)contentContainerView {
    if (!_contentContainerView) {
        _contentContainerView = [[BJLHitTestView alloc] init];
        _contentContainerView.backgroundColor = [UIColor colorWithRed:36 / 255.0 green:42 / 255.0 blue:54 / 255.0 alpha:1.0];
        bjl_weakify(self);
        [_contentContainerView addGestureRecognizer:[UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
            bjl_strongify(self);
            [self showMenuButtons];
        }]];
    }
    return _contentContainerView;
}

- (UIView *)videoAreaContainerView {
    if (!_videoAreaContainerView) {
        _videoAreaContainerView = [[BJLHitTestView alloc] init];
        _videoAreaContainerView.backgroundColor = [UIColor clearColor];
        _videoAreaContainerView.backgroundColor = [UIColor colorWithRed:49 / 255.0 green:56 / 255.0 blue:71 / 255.0 alpha:1.0];
    }
    return _videoAreaContainerView;
}

- (UIView *)videoEmptyStateContainerView {
    if (!_videoEmptyStateContainerView) {
        _videoEmptyStateContainerView = [[BJLHitTestView alloc] init];
        _videoEmptyStateContainerView.backgroundColor = [UIColor clearColor];
    }
    return _videoEmptyStateContainerView;
}

- (UIImageView *)videoEmptyImageView {
    if (!_videoEmptyImageView) {
        _videoEmptyImageView = [[UIImageView alloc] init];
        _videoEmptyImageView.backgroundColor = [UIColor clearColor];
    }
    return _videoEmptyImageView;
}

- (UILabel *)videoEmptyDesciptionLabel {
    if (!_videoEmptyDesciptionLabel) {
        _videoEmptyDesciptionLabel = [[UILabel alloc] init];
        _videoEmptyDesciptionLabel.text = BJLLocalizedString(@"屏幕共享或视频播放中~");
        _videoEmptyDesciptionLabel.font = [UIFont systemFontOfSize:12];
        _videoEmptyDesciptionLabel.textColor = [UIColor colorWithRed:159 / 255.0 green:168 / 255.0 blue:181 / 255.0 alpha:1.0];
        _videoEmptyDesciptionLabel.backgroundColor = [UIColor clearColor];
    }
    return _videoEmptyDesciptionLabel;
}

- (UIView *)videoContainerView {
    if (!_videoContainerView) {
        _videoContainerView = [[BJLHitTestView alloc] init];
        _videoContainerView.backgroundColor = [UIColor clearColor];
    }
    return _videoContainerView;
}

- (UIStackView *)menuStackView {
    if (!_menuStackView) {
        UILayoutConstraintAxis axis = UILayoutConstraintAxisHorizontal;
        CGFloat spacing = 0;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            axis = UILayoutConstraintAxisHorizontal;
            spacing = 80;
        }
        else {
            axis = UILayoutConstraintAxisVertical;
            CGFloat shortSide = MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            spacing = (shortSide - 70 * 2 - 44 * 3) / 2;
        }
        _menuStackView = [[UIStackView alloc] initWithArrangedSubviews:self.menuButtonItems];
        _menuStackView.distribution = UIStackViewDistributionEqualSpacing;
        _menuStackView.alignment = UIStackViewAlignmentCenter;
        _menuStackView.spacing = spacing;
        _menuStackView.axis = axis;
    }
    return _menuStackView;
}

- (UIButton *)cameraTypeSwitchButton {
    if (!_cameraTypeSwitchButton) {
        _cameraTypeSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraTypeSwitchButton.accessibilityIdentifier = BJLKeypath(self, cameraTypeSwitchButton);
        [_cameraTypeSwitchButton setImage:[UIImage bjl_imageNamed:@"bjl_external_camera_switch"] forState:UIControlStateNormal];

        bjl_weakify(self);
        [_cameraTypeSwitchButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self.room.recordingVM updateUsingRearCamera:!self.room.recordingVM.usingRearCamera];
        }];
    }
    return _cameraTypeSwitchButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.accessibilityIdentifier = BJLKeypath(self, videoDefinitionSwitchButton);
        [_closeButton setImage:[UIImage bjl_imageNamed:@"bjl_external_camera_close"] forState:UIControlStateNormal];

        bjl_weakify(self);
        [_closeButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self exit];
        }];
    }
    return _closeButton;
}

- (UIButton *)videoDefinitionSwitchButton {
    if (!_videoDefinitionSwitchButton) {
        _videoDefinitionSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoDefinitionSwitchButton.accessibilityIdentifier = BJLKeypath(self, videoDefinitionSwitchButton);
        _videoDefinitionSwitchButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _videoDefinitionSwitchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _videoDefinitionSwitchButton.titleLabel.minimumScaleFactor = 0.8;
        [_videoDefinitionSwitchButton setTitle:[self definitionKeyWithType:self.room.recordingVM.videoDefinition] forState:UIControlStateNormal];
        [_videoDefinitionSwitchButton setBackgroundImage:[UIImage bjl_imageNamed:@"bjl_external_camera_definition_switch"] forState:UIControlStateNormal];
        [_videoDefinitionSwitchButton setTitleColor:[UIColor bjl_colorWithHexString:@"#313847"] forState:UIControlStateNormal];
        bjl_weakify(self);
        [_videoDefinitionSwitchButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self showVideoDefinitionActionSheet];
        }];
    }
    return _videoDefinitionSwitchButton;
}

@end
