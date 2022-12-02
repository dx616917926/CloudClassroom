//
//  BJLScRoomViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/16.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScRoomViewController.h"
#import "BJLScRoomViewController+private.h"

#if DEBUG && __has_include(<BJLiveBase/BJLiveBase+UIKit.h>)
#import <BJLiveBase/BJLiveBase+UIKit.h>
#endif

#import "BJLiveUIBigClass.h"
#import "BJLUser+RollCall.h"

@implementation BJLScRoomViewController {
    BOOL _entered;
}

#pragma mark - init
+ (void)load {
    [[BJLUserAgent defaultInstance] registerSDK:BJLiveUIBigClassName() version:BJLiveUIBigClassVersion()];
}

+ (__kindof instancetype)instanceWithID:(NSString *)roomID
                                apiSign:(NSString *)apiSign
                                   user:(BJLUser *)user {
    BJLRoom *room = [BJLRoom roomWithID:roomID apiSign:apiSign user:user];
    return [[self alloc] initWithRoom:room];
}

+ (__kindof instancetype)instanceWithSecret:(NSString *)roomSecret
                                   userName:(NSString *)userName
                                 userAvatar:(nullable NSString *)userAvatar {
    BJLRoom *room = [BJLRoom roomWithSecret:roomSecret userName:userName userAvatar:userAvatar];
    return [[self alloc] initWithRoom:room];
}

- (instancetype)initWithRoom:(BJLRoom *)room {
    NSParameterAssert(room);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
        [self prepareForEnterRoom];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bjl_colorWithHex:0X666666];

    self.documentIndexDic = [NSMutableDictionary new];

    self.loadingLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.accessibilityIdentifier = BJLKeypath(self, loadingLayer);
        bjl_return view;
    });
    [self.view addSubview:self.loadingLayer];
    [self.loadingLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    self.eyeProtectedLayer = ({
        BJLHitTestView *view = [BJLHitTestView new];
        view.backgroundColor = [UIColor bjl_colorWithHex:0XFFB139 alpha:0.07];
        view.hidden = YES;
        view.accessibilityIdentifier = BJLKeypath(self, eyeProtectedLayer);
        bjl_return view;
    });
    [self.view insertSubview:self.eyeProtectedLayer aboveSubview:self.loadingLayer];
    [self.eyeProtectedLayer bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    [self makeObservingBeforeEnterRoom];

    bjl_weakify(self);
    self.loadingViewController = [[BJLLoadingViewController alloc] initWithRoom:self.room isInteractiveClass:NO];
    [self.loadingViewController setShowCallback:^(BOOL reloading) {
        bjl_strongify(self);
        [self bjl_dismissPresentedViewControllerAnimated:NO completion:nil];
        [self.overlayViewController hide];
    }];
    [self.loadingViewController setHideCallback:^{
        //        bjl_strongify(self);
    }];
    [self.loadingViewController setEnterCallback:^{
        bjl_strongify(self);
        if (!self->_entered) {
            self->_entered = YES;
            [self.room enterByValidatingConflict:YES];
        }
    }];
    [self.loadingViewController setExitCallback:^{
        bjl_strongify(self);
        [self askToExit];
    }];
    [self.loadingViewController setLoadRoomInfoSucessCallback:^{
        bjl_strongify(self);
        [BJLTheme setupColorWithConfig:self.room.featureConfig.customColors];
        self.view.backgroundColor = BJLTheme.roomBackgroundColor;

        [self makeConstraints];
        [self makeViewControllers];
        [self makeActionsOnViewDidLoad];
        [self makeObserving];
    }];
    [self bjl_addChildViewController:self.loadingViewController superview:self.loadingLayer];
    [self.loadingViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.loadingLayer);
    }];
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

    [self updatMajorNoticeWithNextIndex:@NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSNotificationCenter *defaultCenter = NSNotificationCenter.defaultCenter;
    [defaultCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [defaultCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [defaultCenter removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatMajorNoticeWithNextIndex:) object:nil];
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
    if (!hidden) {
        hidden = self.fullscreenOverlayViewController.contentView || self.fullscreenOverlayViewController.viewController;
    }
    return hidden;
}

// NOTE: call `[self setNeedsUpdateOfHomeIndicatorAutoHidden]` if return value changed
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark - exit

- (void)roomDidExitWithError:(BJLError *)error {
    // !error: 主动退出
    // BJLErrorCode_exitRoom_disconnected: self.loadingViewController 已处理
    if (!error
        || error.code == BJLErrorCode_exitRoom_disconnected) {
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
    [self presentViewController:alert animated:YES completion:nil];
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

- (void)exitWithCompletion:(void (^)(void))completion {
    self.exitCallbackBlock = completion;

    [self exit];
}

- (void)dismissWithError:(nullable BJLError *)error {
    [self roomViewController:self willExitWithError:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    bjl_weakify(self);
    void (^completion)(void) = ^{
        bjl_strongify(self);
        [self roomViewController:self didExitWithError:error];
        if (self.exitCallbackBlock) {
            self.exitCallbackBlock();
        }
    };

    UINavigationController *navigation = [self.parentViewController bjl_as:[UINavigationController class]];
    BOOL isRoot = (navigation
                   && self == navigation.topViewController
                   && self == navigation.bjl_rootViewController);
    UIViewController *outermost = isRoot ? navigation : self;

    BOOL inRoomVC = outermost.parentViewController && [NSStringFromClass(outermost.parentViewController.class) isEqual:@"BJLRoomViewController"];
    // pop
    if (navigation && !isRoot) {
        [navigation bjl_popViewControllerAnimated:YES completion:completion];
    }
    // dismiss
    else if (inRoomVC || (!outermost.parentViewController && outermost.presentingViewController)) {
        if (self.parentViewController) {
            [self.parentViewController dismissViewControllerAnimated:YES completion:completion];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:completion];
        }
    }
    // close in `roomViewController:didExitWithError:`
    else {
        completion();
    }
}

- (void)clean {
    [self.reachability stopMonitoring];
    self->_room = nil;
}

- (void)askToExit {
    bjl_weakify(self);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:BJLLocalizedString(@"提示") message:BJLLocalizedString(@"确定要退出直播间吗？") preferredStyle:UIAlertControllerStyleAlert];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"取消") style:UIAlertActionStyleDefault handler:nil];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"退出") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        bjl_strongify(self);
        [self exit];
    }];
    // 上课、非推流直播、非伪直播、老师或者有上下课权限的助教才能下课
    if (self.room.roomVM.liveStarted
        && !self.room.roomInfo.isPushLive
        && !self.room.roomInfo.isMockLive
        && (self.room.loginUser.isTeacher
            || (self.room.loginUser.isAssistant
                && self.room.roomVM.getAssistantaAuthorityWithClassStartEnd
                && self.room.loginUser.noGroup))) {
        [alertController bjl_addActionWithTitle:BJLLocalizedString(@"下课并退出") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
            bjl_strongify(self);
            [self.room.roomVM sendLiveStarted:NO];

            if (BJLServerRecordingType_cloud != self.room.featureConfig.cloudRecordType) {
                [self endClassAndExit];
                return;
            }

            [self.room.serverRecordingVM requestServerRecordState:^(BOOL success) {
                bjl_strongify(self);
                if (!success) {
                    [self endClassAndExit];
                    return;
                }

                // 开启过云端录制并且未转码或者正在云端录制中, 需要处理生成回放的逻辑
                if (self.room.serverRecordingVM.state == BJLServerRecordingState_recording) {
                    if (self.room.featureConfig.secretCloudRecord) {
                        [self.room.serverRecordingVM requestServerRecording:NO]; // 结束录制
                        if (self.room.serverRecordingVM.shouldGeneratePlaybackAfterClass) {
                            [self.room.serverRecordingVM requestServerRecordingTranscode]; // 生成回放
                        }
                        [self endClassAndExit]; // 退直播间
                    }
                    else {
                        if (self.room.serverRecordingVM.shouldGeneratePlaybackAfterClass) {
                            [self.room.serverRecordingVM requestServerRecording:NO]; // 结束录制
                            [self.room.serverRecordingVM requestServerRecordingTranscode]; // 生成回放

                            [self endClassAndExit]; // 退直播间
                        }
                        else {
                            [self showGeneratePlaybackAlert];
                        }
                    }
                }
                else {
                    [self endClassAndExit];
                }
            }];
        }];
    }

    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showGeneratePlaybackAlert {
    bjl_weakify(self);

    NSString *title = BJLLocalizedString(@"您是否希望现在开始生成回放?");
    NSString *message = self.room.roomInfo.isLongTerm ? nil : BJLLocalizedString(@"(开始生成回放后，本节课后续将无法使用云端录制)");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"暂不生成") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        bjl_strongify(self);
        [self.room.serverRecordingVM requestServerRecording:NO]; // 结束录制
        [self endClassAndExit];
    }];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"开始生成") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
        bjl_strongify(self);
        [self.room.serverRecordingVM requestServerRecording:NO]; // 结束录制
        [self.room.serverRecordingVM requestServerRecordingTranscode]; // 生成回放

        [self endClassAndExit];
    }];
    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)endClassAndExit {
    // 下课时发出关闭计时器信令
    if (self.room.loginUser.isTeacher) {
        [self.room.roomVM requestStopTimer];
    }
    [self exit];
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

#pragma mark - hud

- (void)showProgressHUDWithText:(NSString *)text {
    UIWindow *keyWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }
    [self showProgressHUDWithText:text superView:keyWindow];
}

- (void)showProgressHUDWithText:(NSString *)text superView:(UIView *)superview {
    if (!text.length
        || [text isEqualToString:self.prevHUD.detailsLabel.text]) {
        return;
    }

    BJLProgressHUD *hud = [BJLProgressHUD bjl_hudForTextWithSuperview:superview];
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

#pragma mark - action

- (void)prepareForEnterRoom {
    // UI
    self.autoPlayVideoBlacklist = [NSMutableSet new];
    self.questionRedDotHidden = YES;
    self.toolHidden = YES;
    self.majorWindowType = BJLScWindowType_ppt;
    self.minorWindowType = BJLScWindowType_teacherVideo;
    self.secondMinorWindowType = BJLScWindowType_userVideo;
    self.fullscreenWindowType = BJLScWindowType_none;
    [BJLAppearance updateBlackboardAspectRatio:BJLScBlackboardAspectRatio];

    // core
    bjl_weakify(self);
    self.room.playingVM.autoPlayVideoBlock = ^BJLAutoPlayVideo(BJLMediaUser *user, NSInteger cachedDefinitionIndex) {
        bjl_strongify(self);
        NSString *videoKey = [self videoKeyForUser:user];
        BOOL autoPlay = videoKey && ![self.autoPlayVideoBlacklist containsObject:videoKey];
        NSInteger definitionIndex = cachedDefinitionIndex;
        if (autoPlay) {
            NSInteger maxDefinitionIndex = MAX(0, (NSInteger)user.definitions.count - 1);
            definitionIndex = (cachedDefinitionIndex <= maxDefinitionIndex
                                   ? cachedDefinitionIndex
                                   : maxDefinitionIndex);
        }
        return BJLAutoPlayVideoMake(autoPlay, definitionIndex);
    };
    self.room.drawingVM.drawsLaserPointer = NO;
}

/**
 * force :是否要加入`大班课的学生不自动打开音视频`这个判断条件
*/
- (void)autoStartRecordingAudioAndVideoForce:(BOOL)force {
    if (self.room.loginUser.isAssistant) {
        return;
    }

    if (self.room.roomInfo.roomType == BJLRoomType_1vNClass
        && self.room.loginUser.isStudent
        && force) {
        return;
    }

    BOOL openVideo = !(self.room.loginUser.isStudent && !self.room.featureConfig.autoPublishVideoStudent);

    BOOL audioChange = !self.room.recordingVM.recordingAudio;
    BOOL videoChange = self.room.recordingVM.recordingVideo != openVideo;
    BJLError *error = [self.room.recordingVM setRecordingAudio:YES recordingVideo:openVideo];
    if (error) {
        [self showProgressHUDWithText:(error.localizedFailureReason ?: error.localizedDescription ?
                                                                                                  : BJLLocalizedString(@"麦克风、摄像头打开失败"))];
        return;
    }

    NSString *message = nil;
    if (audioChange) {
        message = self.room.recordingVM.recordingAudio ? BJLLocalizedString(@"麦克风已打开") : BJLLocalizedString(@"麦克风已关闭");
    }
    if (videoChange) {
        message = self.room.recordingVM.recordingVideo ? BJLLocalizedString(@"摄像头已打开") : BJLLocalizedString(@"摄像头已关闭");
    }
    if (message) {
        [self showProgressHUDWithText:message];
    }
}

- (void)updateVideosConstraintsWithCurrentPlayingUsers {
    NSInteger count = self.room.mainPlayingAdapterVM.playingUsers.count + self.room.extraPlayingAdapterVM.playingUsers.count;

    // 老师窗口和其他用户分离，（老师在线，除了老师的音视频流，有一个以上 playinguser 的情况），（或是老师不在线或者当前登录用户是老师，有 1 个以上 playinguser 的情况），显示视频列表
    BOOL videosViewHidden = YES;
    if (self.room.loginUserIsPresenter) {
        // 目前移动端当老师不支持多个摄像头，因此只要有正在播放的流，就显示出列表
        if (count >= 1) {
            videosViewHidden = NO;
        }
    }
    else {
        BJLMediaUser *extraTeacher = nil;
        NSInteger mediaUserCount = 0; // 只有老师的的预期视频流数量
        for (BJLMediaUser *user in [self.room.mainPlayingAdapterVM.playingUsers copy]) {
            if ([user isSameUser:self.room.onlineUsersVM.currentPresenter]) {
                mediaUserCount++;
                break;
            }
        }
        for (BJLMediaUser *user in [self.room.extraPlayingAdapterVM.playingUsers copy]) {
            if ([user isSameUser:self.room.onlineUsersVM.currentPresenter]) {
                extraTeacher = user;
                if (self.showTeacherExtraMediaInfoViewCoverPPT) {
                    mediaUserCount++;
                }
                break;
            }
        }
        [self updateTeacherExtraVideoViewWithMediaUser:extraTeacher];
        // 如果实际的音视频流比 只有老师的的预期视频流数量 多，则显示视频列表
        if (count >= mediaUserCount + 1 || self.room.recordingVM.recordingVideo) {
            videosViewHidden = NO;
        }
    }
    [self updateVideosViewHidden:videosViewHidden];
}

- (NSString *)videoKeyForUser:(BJLMediaUser *)user {
    return [NSString stringWithFormat:@"%@-%td", user.number, user.mediaSource];
}

- (void)destoryBonusPointsVCIfNeeded {
    if (!self.room.featureConfig.enableUseBonusPoints) { return; }

    if (self.room.loginUser.isTeacherOrAssistant) {
        if (_bonusListVC) {
            if (_bonusListVC.isViewLoaded) {
                [_bonusListVC bjl_removeFromParentViewControllerAndSuperiew];
            }
            _bonusListVC = nil;
        }
    }
    else {
        if (_studentBonusListVC) {
            if (_studentBonusListVC.isViewLoaded) {
                [_studentBonusListVC bjl_removeFromParentViewControllerAndSuperiew];
            }
            _studentBonusListVC = nil;
        }
    }
}

#pragma mark -

- (void)showRollCallViewController {
    if (![self.room.loginUser canLaunchRollCallWithRoom:self.room]) {
        return;
    }

    bjl_weakify(self);
    BJLAlertPresentationController *alertPresentationController = [[BJLAlertPresentationController alloc] initWithPresentedViewController:self.rollCallVC presentingViewController:self];
    self.rollCallVC.preferredContentSize = [self.rollCallVC presentationSize];
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     bjl_strongify(self);
                                     self.rollCallVC.transitioningDelegate = alertPresentationController;
                                     [self presentViewController:self.rollCallVC animated:YES completion:nil];
                                 }];
        return;
    }
    self.rollCallVC.transitioningDelegate = alertPresentationController;
    [self presentViewController:self.rollCallVC animated:YES completion:nil];
}

- (void)addCreateEnvelopeRainView {
    if (!self.room.roomVM.liveStarted) {
        [self showProgressHUDWithText:BJLLocalizedString(@"上课状态才能使用红包雨")];
        return;
    }
    if (self.createRainViewController) {
        [self.createRainViewController bjl_removeFromParentViewControllerAndSuperiew];
        self.createRainViewController = nil;
    }
    BJLCreateRainViewController *createRainViewControl = [[BJLCreateRainViewController alloc] initWithRoom:self.room];
    BJLAlertPresentationController *alertPresentationController = [[BJLAlertPresentationController alloc] initWithPresentedViewController:createRainViewControl presentingViewController:self];
    [alertPresentationController setTapCallback:^BOOL(UIViewController *_Nullable viewController) {
        if (viewController && [viewController isKindOfClass:[BJLCreateRainViewController class]]) {
            if ([createRainViewControl keyboardDidShow]) {
                return YES;
            }
            return NO;
        }
        return YES;
    }];
    createRainViewControl.transitioningDelegate = alertPresentationController;
    createRainViewControl.preferredContentSize = CGSizeMake(280.0, 318.0);
    [self presentViewController:createRainViewControl animated:YES completion:nil];
}

#pragma mark - observable methods

- (BJLObservable)roomViewControllerEnterRoomSuccess:(BJLScRoomViewController *)roomViewController {
    BJLMethodNotify((BJLScRoomViewController *),
        roomViewController);
    if ([self.delegate respondsToSelector:@selector(roomViewControllerEnterRoomSuccess:)]) {
        [self.delegate roomViewControllerEnterRoomSuccess:self];
    }
}

- (BJLObservable)roomViewController:(BJLScRoomViewController *)roomViewController
          enterRoomFailureWithError:(BJLError *)error {
    BJLMethodNotify((BJLScRoomViewController *, BJLError *),
        roomViewController,
        error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:enterRoomFailureWithError:)]) {
        [self.delegate roomViewController:self enterRoomFailureWithError:error];
    }
}

- (BJLObservable)roomViewController:(BJLScRoomViewController *)roomViewController
                  willExitWithError:(nullable BJLError *)error {
    BJLMethodNotify((BJLScRoomViewController *, BJLError *),
        roomViewController,
        error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:willExitWithError:)]) {
        [self.delegate roomViewController:self willExitWithError:error];
    }
}

- (BJLObservable)roomViewController:(BJLScRoomViewController *)roomViewController
                   didExitWithError:(nullable BJLError *)error {
    BJLMethodNotify((BJLScRoomViewController *, BJLError *),
        roomViewController,
        error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:didExitWithError:)]) {
        [self.delegate roomViewController:self didExitWithError:error];
    }
}

#pragma mark - getter

- (BOOL)enableShare {
    return NO;  //self.room.featureConfig.enableShare;
}

- (BOOL)is1V1Class {
    return self.room.roomInfo.roomType == BJLRoomType_1v1Class;
}

- (BOOL)showTeacherExtraMediaInfoViewCoverPPT {
    return self.teacherExtraMediaInfoView && !self.room.featureConfig.enablePPTShowWithAssistCamera && self.room.roomInfo.isDoubleCamera;
}

- (BJLScSettingsViewController *)settingsViewController {
    if (!_settingsViewController) {
        _settingsViewController = [[BJLScSettingsViewController alloc] initWithRoom:self.room];
    }
    return _settingsViewController;
}

- (BJLNoticeViewController *)noticeViewController {
    if (!_noticeViewController) {
        _noticeViewController = [[BJLNoticeViewController alloc] initWithRoom:self.room];
    }
    return _noticeViewController;
}

- (BJLNoticeEditViewController *)noticeEditViewController {
    if (!_noticeEditViewController) {
        _noticeEditViewController = [[BJLNoticeEditViewController alloc] initWithRoom:self.room];
    }
    return _noticeEditViewController;
}
- (BJLScQuestionViewController *)questionViewController {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (!_questionViewController) {
        _questionViewController = [[BJLScQuestionViewController alloc] initWithRoom:self.room];
        bjl_weakify(self);
        [_questionViewController setReplyCallback:^(BJLQuestion *_Nonnull question, BJLQuestionReply *_Nullable reply) {
            bjl_strongify(self);
            [self.questionInputViewController updateWithQuestion:question];
            [self.overlayViewController addContentViewController:self.questionInputViewController];
            if (!iPhone) {
                [self.questionViewController.view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                    make.top.equalTo(self.overlayViewController.view);
                    make.centerX.equalTo(self.overlayViewController.view);
                    make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                    make.height.equalTo(self.overlayViewController.view).multipliedBy(0.75);
                }];

                [UIView animateWithDuration:0.3 animations:^{
                    [self.overlayViewController.view setNeedsLayout];
                    [self.overlayViewController.view layoutIfNeeded];
                }];
            }
            [self.questionInputViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.right.bottom.equalTo(self.overlayViewController.view);
            }];
        }];
        [_questionViewController setShowQuestionInputViewCallback:^{
            bjl_strongify(self);
            [self.questionInputViewController updateWithQuestion:nil];
            [self.overlayViewController addContentViewController:self.questionInputViewController];
            if (!iPhone) {
                [self.questionViewController.view bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                    make.top.equalTo(self.overlayViewController.view).offset(60);
                    make.centerX.equalTo(self.overlayViewController.view);
                    make.width.equalTo(self.overlayViewController.view).multipliedBy(0.39);
                    make.height.equalTo(self.overlayViewController.view).multipliedBy(0.75);
                }];

                [UIView animateWithDuration:0.3 animations:^{
                    [self.overlayViewController.view setNeedsLayout];
                    [self.overlayViewController.view layoutIfNeeded];
                }];
            }
            [self.questionInputViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.right.bottom.equalTo(self.overlayViewController.view);
            }];
        }];
    }
    return _questionViewController;
}

- (BJLCDNListViewController *)switchRouteController {
    if (!_switchRouteController) {
        _switchRouteController = [[BJLCDNListViewController alloc] initWithRoom:self.room shouldFullScreent:NO];
        bjl_weakify(self);
        [_switchRouteController setSwitchRouteCallback:^(NSInteger index) {
            bjl_strongify(self);
            BJLError *error = [self.room.mediaVM updateTCPDownLinkCDNWithIndex:index];
            if (error == nil) {
                [self showProgressHUDWithText:BJLLocalizedString(@"已切换")];
            }
            else {
                [self showProgressHUDWithText:BJLLocalizedString(@"切换失败，请重试！")];
            }
        }];
    }
    return _switchRouteController;
}

- (BJLDocumentFileManagerViewController *)pptManagerViewController {
    if (!_pptManagerViewController) {
        _pptManagerViewController = [[BJLDocumentFileManagerViewController alloc] initWithRoom:self.room];
        bjl_weakify(self);
        [_pptManagerViewController setShowErrorMessageCallback:^(NSString *_Nonnull message) {
            bjl_strongify(self);
            [self showProgressHUDWithText:BJLLocalizedString(message)];
        }];
        // 打开PPT
        [_pptManagerViewController setSelectDocumentFileCallback:^(BJLDocumentFile *_Nonnull documentFile, UIImage *_Nullable image) {
            bjl_strongify(self);
            BJLDocument *document = documentFile.remoteDocument;
            NSInteger index = [self.documentIndexDic bjl_integerForKey:document.documentID defaultValue:0];
            BJLSlidePage *slidePage = [self.room.documentVM slidePageWithDocumentID:document.documentID pageIndex:index];
            if (slidePage && self.room.slideshowViewController.pageIndex != slidePage.documentPageIndex) {
                [self.room.slideshowViewController updatePageIndex:slidePage.documentPageIndex];
            }
            [self showProgressHUDWithText:BJLLocalizedString(@"文件已打开, 请在黑板区查看")];
        }];
    }
    return _pptManagerViewController;
}

- (BJLScSpeakRequestUsersViewController *)speakRequestUsersViewController {
    if (!_speakRequestUsersViewController) {
        _speakRequestUsersViewController = [[BJLScSpeakRequestUsersViewController alloc] initWithRoom:self.room];
        bjl_weakify(self);
        [_speakRequestUsersViewController setAgreeSpeakingRequestCallback:^{
            bjl_strongify(self);
            if (self.fullscreenWindowType != BJLScWindowType_none) {
                [self restoreCurrentFullscreenWindow];
            }
        }];
    }
    return _speakRequestUsersViewController;
}

- (BJLScChatInputViewController *)chatInputViewController {
    if (!_chatInputViewController) {
        _chatInputViewController = [[BJLScChatInputViewController alloc] initWithRoom:self.room];

        bjl_weakify(self);
        [_chatInputViewController setChangeChatStatusCallback:^(BJLChatStatus chatStatus, BJLUser *_Nullable targetUser) {
            bjl_strongify(self);
            if (self.segmentViewController) {
                [self.segmentViewController.chatViewController updateChatStatus:chatStatus withTargetUser:targetUser];
            }
            else {
                [self.chatViewController updateChatStatus:chatStatus withTargetUser:targetUser];
            }
        }];

        [_chatInputViewController setSelectImageFileCallback:^(ICLImageFile *_Nonnull file, UIImage *_Nullable image) {
            bjl_strongify(self);
            [self.overlayViewController hide];
            if (self.segmentViewController) {
                [self.segmentViewController.chatViewController refreshMessages];
                [self.segmentViewController.chatViewController sendImageFile:file image:image];
            }
            else {
                [self.chatViewController refreshMessages];
                [self.chatViewController sendImageFile:file image:image];
            }
        }];

        [_chatInputViewController setFinishCallback:^(NSString *_Nullable errorMessage) {
            bjl_strongify(self);
            [self.overlayViewController hide];
            if (errorMessage.length) {
                [self showProgressHUDWithText:errorMessage];
            }
            else {
                if (self.segmentViewController) {
                    [self.segmentViewController.chatViewController refreshMessages];
                }
                else {
                    [self.chatViewController refreshMessages];
                }
            }
        }];

        [_chatInputViewController setSecretForbidMessageCallback:^(NSString *_Nullable secretForbidMessage, BJLUser *_Nullable targetUser) {
            bjl_strongify(self);
            if (secretForbidMessage.length <= 0) { return; }
            [self.overlayViewController hide];
            [self.segmentViewController.chatViewController addSecretForbidMessage:secretForbidMessage targetUser:targetUser];
        }];
    }
    return _chatInputViewController;
}

- (BJLScQuestionInputViewController *)questionInputViewController {
    if (!_questionInputViewController) {
        _questionInputViewController = ({
            BJLScQuestionInputViewController *vc = [[BJLScQuestionInputViewController alloc] initWithRoom:self.room];
            bjl_weakify(self);
            [vc setSendQuestionCallback:^(NSString *_Nonnull content) {
                bjl_strongify(self);
                [self.questionViewController sendQuestion:content];
                [self.questionViewController clearReplyQuestion];
                [self.overlayViewController hide];
                [self showQuestionViewController];
            }];
            [vc setSaveReplyCallback:^(BJLQuestion *_Nonnull question, NSString *_Nonnull reply) {
                bjl_strongify(self);
                [self.questionViewController updateQuestion:question reply:reply];
                [self.questionViewController clearReplyQuestion];
                [self.overlayViewController hide];
                [self showQuestionViewController];
            }];
            [vc setCancelCallback:^{
                bjl_strongify(self);
                [self.overlayViewController hide];
                [self.questionViewController clearReplyQuestion];
            }];
            vc;
        });
    }
    return _questionInputViewController;
}

- (BJLScreenCaptureAlertMaskView *)screenCaptureAlertView {
    if (!_screenCaptureAlertView) {
        _screenCaptureAlertView = [[BJLScreenCaptureAlertMaskView alloc] init];
        bjl_weakify(self);
        _screenCaptureAlertView.dismissEventHandler = ^(BJLScreenCaptureAlertMaskView *_Nonnull view) {
            bjl_strongify(self);

            if (self.room.roomVM.liveStarted && self.room.loginUser.isTeacher) {
                [self.room.roomVM sendLiveStarted:NO];
            }
            [self exit];
        };
    }
    return _screenCaptureAlertView;
}

- (BJLRollCallViewController *)rollCallVC {
    if (!_rollCallVC) {
        _rollCallVC = [[BJLRollCallViewController alloc] initWithRoom:self.room];

        bjl_weakify(self);
        _rollCallVC.rollCallActiveStateChangeBlock = ^(BJLRollCallViewController *_Nonnull vc, BOOL rollCallActive) {
            bjl_strongify(self);
            [self.toolViewController showRollCallBadgePoint:rollCallActive];

            //这里老师/助教发送点名后，教师内其他助教/老师也会弹出点名窗口
            if (rollCallActive && !self.room.roomVM.isRollcalling && self.presentedViewController != self->_rollCallVC) {
                [self showRollCallViewController];
            }
        };
    }
    return _rollCallVC;
}

- (BJLHitTestView *)majorContentOperationView {
    if (!_majorContentOperationView) {
        _majorContentOperationView = [[BJLHitTestView alloc] init];
        _majorContentOperationView.accessibilityIdentifier = @"_majorContentOperationView";
    }
    return _majorContentOperationView;
}

- (BJLCountDownManager *)countDownManager {
    if (!_countDownManager) {
        _countDownManager = [[BJLCountDownManager alloc] initWithRoom:self.room roomViewController:self superView:self.timerLayer];
    }
    return _countDownManager;
}

- (BJLQuestionAnswerManager *)questionAnswerManager {
    if (!_questionAnswerManager) {
        _questionAnswerManager = [[BJLQuestionAnswerManager alloc] initWithRoom:self.room roomViewController:self];
    }
    return _questionAnswerManager;
}

- (BJLQuestionResponderManager *)questionResponderManager {
    if (!_questionResponderManager) {
        _questionResponderManager = [[BJLQuestionResponderManager alloc] initWithRoom:self.room roomViewController:self superView:self.teachAidLayer];
    }
    return _questionResponderManager;
}

- (BJLRequireFullScreenCheckFailedMaskView *)requireFullScreenCheckFailedMaskView {
    if (!_requireFullScreenCheckFailedMaskView) {
        _requireFullScreenCheckFailedMaskView = [[BJLRequireFullScreenCheckFailedMaskView alloc] init];

        bjl_weakify(self);
        _requireFullScreenCheckFailedMaskView.dismissEventHandler = ^(BJLRequireFullScreenCheckFailedMaskView *_Nonnull view) {
            bjl_strongify(self);

            if (self.room.roomVM.liveStarted && self.room.loginUser.isTeacher) {
                [self.room.roomVM sendLiveStarted:NO];
            }
            [self exit];
        };
    }
    return _requireFullScreenCheckFailedMaskView;
}

@synthesize bonusListVC = _bonusListVC;
- (BJLBonusListViewController *)bonusListVC {
    if (!_bonusListVC) {
        _bonusListVC = [[BJLBonusListViewController alloc] initWithRoom:self.room];
    }
    return _bonusListVC;
}

@synthesize studentBonusListVC = _studentBonusListVC;
- (BJLStudentBonusRankViewController *)studentBonusListVC {
    if (!_studentBonusListVC) {
        _studentBonusListVC = [[BJLStudentBonusRankViewController alloc] initWithRoom:self.room];
    }
    return _studentBonusListVC;
}

@synthesize studentBonusIncreasingPopupVC = _studentBonusIncreasingPopupVC;
- (BJLOptionViewController *)studentBonusIncreasingPopupVC {
    if (!_studentBonusIncreasingPopupVC) {
        BJLOptionConfig *cfg = [BJLOptionConfig defaultConfig];
        cfg.preselectedIndex = -1;
        cfg.optionHeight = 35;
        cfg.optionWidth = 145;
        _studentBonusIncreasingPopupVC = [[BJLOptionViewController alloc] initWithConfig:cfg options:@[@""]];
        bjl_weakify(self);
        _studentBonusIncreasingPopupVC.optionCellBuilderBlock = ^UIControl *_Nonnull(BJLOptionViewController *_Nonnull vc, NSInteger index, NSString *_Nonnull option) {
            bjl_strongify(self);
            UIControl *view = [[UIControl alloc] init];
            view.backgroundColor = cfg.backgroudColor;

            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.textAlignment = NSTextAlignmentRight;
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.textColor = BJLTheme.viewSubTextColor;
            titleLabel.text = BJLLocalizedString(@"积分");

            UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_toolbar_bonus_coin"]];

            [view addSubview:titleLabel];
            [view addSubview:icon];
            [view addSubview:self.studentBonusIncreasingLabel];

            [titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.right.equalTo(icon.bjl_left).offset(-10.0);
                make.centerY.equalTo(view);
                make.left.greaterThanOrEqualTo(view);
            }];
            [icon bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.center.equalTo(view);
            }];
            [self.studentBonusIncreasingLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.equalTo(icon.bjl_right).offset(8.0);
                make.centerY.equalTo(view);
                make.right.lessThanOrEqualTo(view);
            }];

            return view;
        };
    }
    return _studentBonusIncreasingPopupVC;
}

@synthesize studentBonusIncreasingLabel = _studentBonusIncreasingLabel;
- (UILabel *)studentBonusIncreasingLabel {
    if (!_studentBonusIncreasingLabel) {
        _studentBonusIncreasingLabel = [[UILabel alloc] init];
        _studentBonusIncreasingLabel.font = [UIFont systemFontOfSize:16];
        _studentBonusIncreasingLabel.textColor = [[UIColor bjl_colorWithHexString:@"#FFD96B"] colorWithAlphaComponent:1];
        _studentBonusIncreasingLabel.backgroundColor = UIColor.clearColor;
        _studentBonusIncreasingLabel.accessibilityIdentifier = @"_studentBonusIncreasingLabel";
    }
    return _studentBonusIncreasingLabel;
}
@end
