//
//  BJLCheckGuideViewController.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/19.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BJLCheckGuideViewController.h"
#import "BJLAppearance.h"
#import "BJLMediaAuthCheckView.h"
#import "BJLNetworkCheckView.h"
#import "BJLCameraCheckView.h"
#import "BJLSpeakerCheckView.h"
#import "BJLMicrophoneCheckView.h"

/** ### 音视频自检页面，该页面在进直播间之前，目前仅使用白色模式的主题效果 */
@interface BJLCheckGuideViewController ()

@property (nonatomic) UIView *contentView;
@property (nonatomic) UIButton *skipCheckButton;
@property (nonatomic) BJLMediaCheckStep currentStep;

@property (nonatomic) BOOL hasCheckOnce;
@property (nonatomic) BJLMediaAuthCheckView *authCheckView;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) BJLMediaAuthStateView *authStateView;
@property (nonatomic) BJLNetworkCheckView *networkCheckView;
@property (nonatomic) BJLCameraCheckView *cameraCheckView;
@property (nonatomic) BJLSpeakerCheckView *speakerCheckView;
@property (nonatomic) BJLMicrophoneCheckView *microphoneCheckView;
@property (nonatomic) UIView *checkResultView;

@property (nonatomic) AVAudioSessionCategory audioSessionCategory;
@property (nonatomic) AVAudioSessionCategoryOptions audioSessionOptions;
@property (nonatomic) AVAudioSessionMode audioSessionMode;
@property (nonatomic) CGFloat audioVolume;
@property (nonatomic) UISlider *volumeSlider;

@end

@implementation BJLCheckGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!BJLTheme.hasInitial) {
        [BJLTheme setupColorWithConfig:nil];
    }
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    self.audioVolume = -1;
    [self cacheCurrentAudioSessionMode];
    [self addNotify];
    [self makeCommonView];
    [self makeAuthCheckView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.authCheckView startCheck];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)makeCommonView {
    bjl_weakify(self);
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    self.contentView = ({
        UIView *view = [UIView new];
        view;
    });
    [self.view addSubview:self.contentView];
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];
    self.skipCheckButton = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button bjl_setTitle:BJLLocalizedString(@"放弃检测") forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.buttonDisableTextColor forState:UIControlStateNormal];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self showAlertWithTitle:BJLLocalizedString(@"放弃检测？")
                             message:BJLLocalizedString(@"检测尚未完成，放弃检测可能会影响上课效果\n确定要放弃检测？")
                       opposeMessage:BJLLocalizedString(@"放弃检测")
                      confirmMessage:BJLLocalizedString(@"继续检测")
                            callback:^(BOOL confirm, BOOL cancel) {
                                bjl_strongify(self);
                                if (cancel) {
                                    return;
                                }
                                if (!confirm) {
                                    [self finishCheck];
                                }
                            }];
        }];
        button;
    });
    [self.view addSubview:self.skipCheckButton];
    [self.skipCheckButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide).offset(iPhone ? -24.0 : -44.0);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20.0);
        make.hugging.compressionResistance.required();
    }];
}

- (void)makeAuthCheckView {
    self.currentStep = BJLMediaCheckStep_auth;
    self.authCheckView = [BJLMediaAuthCheckView new];
    bjl_weakify(self);
    [self.authCheckView setAuthCheckcompletion:^(BOOL success) {
        bjl_strongify(self);
        [self.authCheckView removeFromSuperview];
        [self makeChecProgessView];
        [self makeCheckNetworkView];
    }];
    [self.contentView addSubview:self.authCheckView];
    [self.authCheckView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)makeChecProgessView {
    self.authStateView = [[BJLMediaAuthStateView alloc] initWithIconSize:24.0 space:75.0];
    bjl_weakify(self);
    [self.authStateView setSelectCheckStepCallback:^(BJLMediaCheckStep step) {
        bjl_strongify(self);
        if (self.hasCheckOnce) {
            [self skipToStep:step];
        }
        else {
            if ([self.authStateView hasCheckedStep:step]) {
                [self skipToStep:step];
            }
        }
    }];
    [self.contentView addSubview:self.authStateView];
    [self.authStateView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.contentView.bjl_centerY).offset(-180.0);
        make.centerX.equalTo(self.view);
    }];

    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:18.0];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.authStateView.bjl_top).offset(-24.0);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20.0);
    }];
}

#pragma mark - network

- (void)makeCheckNetworkView {
    self.currentStep = BJLMediaCheckStep_network;
    self.titleLabel.text = BJLLocalizedString(@"检测网络");
    [self.authStateView skipToStep:BJLMediaCheckStep_network];
    self.networkCheckView = [BJLNetworkCheckView new];
    bjl_weakify(self);
    [self.networkCheckView setNetworkCheckCompletion:^(BOOL success) {
        bjl_strongify(self);
        [self.networkCheckView removeFromSuperview];
        self.authStateView.networkReachable = success;
        [self makeCheckCameraView];
    }];
    [self.contentView addSubview:self.networkCheckView];
    [self.networkCheckView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.authStateView.bjl_bottom).offset(24.0);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - camera

- (void)makeCheckCameraView {
    self.currentStep = BJLMediaCheckStep_camera;
    [self.authStateView skipToStep:BJLMediaCheckStep_camera];
    [self.authStateView makeCheckProgressView];
    self.titleLabel.text = BJLLocalizedString(@"检测摄像头");
    self.cameraCheckView = [BJLCameraCheckView new];
    self.cameraCheckView.parentViewController = self;
    bjl_weakify(self);
    [self.cameraCheckView setCameraCheckCompletion:^(BOOL success, BOOL needConfirm) {
        bjl_strongify(self);
        if (needConfirm) {
            [self showAlertWithTitle:BJLLocalizedString(@"看不到？")
                             message:BJLLocalizedString(@"检测到摄像头已正常连接\n确定无法通过摄像头看到自己吗？")
                       opposeMessage:BJLLocalizedString(@"看不到")
                      confirmMessage:BJLLocalizedString(@"能看到")
                            callback:^(BOOL confirm, BOOL cancel) {
                                bjl_strongify(self);
                                if (cancel) {
                                    return;
                                }
                                [self.cameraCheckView removeFromSuperview];
                                self.authStateView.cameraAuth = confirm;
                                [self makeCheckSpeakerView];
                            }];
        }
        else {
            [self.cameraCheckView removeFromSuperview];
            self.authStateView.cameraAuth = success;
            [self makeCheckSpeakerView];
        }
    }];
    [self updateCameraOrientation];
    [self.contentView addSubview:self.cameraCheckView];
    [self.cameraCheckView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.authStateView.bjl_bottom).offset(24.0);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

- (void)updateCameraOrientation {
    if (self.currentStep == BJLMediaCheckStep_camera) {
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
        [self.cameraCheckView updateOrientation:targetOrt];
    }
}

#pragma mark - speaker

- (void)makeCheckSpeakerView {
    self.currentStep = BJLMediaCheckStep_speaker;
    [self.authStateView skipToStep:BJLMediaCheckStep_speaker];
    [self.authStateView makeCheckProgressView];
    self.titleLabel.text = BJLLocalizedString(@"检测扬声器");
    self.speakerCheckView = [BJLSpeakerCheckView new];
    self.speakerCheckView.parentViewController = self;
    bjl_weakify(self);
    [self.speakerCheckView setSpeakerCheckCompletion:^(BOOL success, BOOL needConfirm) {
        bjl_strongify(self);
        if (needConfirm) {
            [self showAlertWithTitle:BJLLocalizedString(@"听不到？")
                             message:BJLLocalizedString(@"检测到扬声器已正常连接\n确定无法通过扬声器听到声音吗？")
                       opposeMessage:BJLLocalizedString(@"听不到")
                      confirmMessage:BJLLocalizedString(@"能听到")
                            callback:^(BOOL confirm, BOOL cancel) {
                                bjl_strongify(self);
                                if (cancel) {
                                    return;
                                }
                                [self.speakerCheckView removeFromSuperview];
                                self.authStateView.speakerAuth = confirm;
                                [self makeCheckMicrophoneView];
                            }];
        }
        else {
            [self.speakerCheckView removeFromSuperview];
            self.authStateView.speakerAuth = success;
            [self makeCheckMicrophoneView];
        }
    }];
    [self.contentView addSubview:self.speakerCheckView];
    [self.speakerCheckView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.authStateView.bjl_bottom).offset(24.0);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - microphone

- (void)makeCheckMicrophoneView {
    self.currentStep = BJLMediaCheckStep_microphone;
    [self.authStateView skipToStep:BJLMediaCheckStep_microphone];
    [self.authStateView makeCheckProgressView];
    self.titleLabel.text = BJLLocalizedString(@"检测麦克风");
    self.microphoneCheckView = [BJLMicrophoneCheckView new];
    self.microphoneCheckView.parentViewController = self;
    bjl_weakify(self);
    [self.microphoneCheckView setMicrophoneCheckCompletion:^(BOOL success, BOOL needConfirm) {
        bjl_strongify(self);
        if (needConfirm) {
            [self showAlertWithTitle:BJLLocalizedString(@"没跳动？")
                             message:BJLLocalizedString(@"检测到麦克风已正常连接\n确定在对麦克风说话时音量条没有跳动吗？")
                       opposeMessage:BJLLocalizedString(@"没跳动")
                      confirmMessage:BJLLocalizedString(@"有跳动")
                            callback:^(BOOL confirm, BOOL cancel) {
                                bjl_strongify(self);
                                if (cancel) {
                                    return;
                                }
                                [self.microphoneCheckView removeFromSuperview];
                                self.authStateView.microphoneAuth = confirm;
                                [self makeCheckResultView];
                            }];
        }
        else {
            [self.microphoneCheckView removeFromSuperview];
            self.authStateView.microphoneAuth = success;
            [self makeCheckResultView];
        }
    }];
    [self.contentView addSubview:self.microphoneCheckView];
    [self.microphoneCheckView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.authStateView.bjl_bottom).offset(24.0);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - check result

- (void)makeCheckResultView {
    self.authStateView.hidden = YES;
    self.skipCheckButton.hidden = YES;
    self.hasCheckOnce = YES;
    [self saveCheckResult];

    self.currentStep = BJLMediaCheckStep_finish;
    self.titleLabel.text = BJLLocalizedString(@"检测报告");
    self.checkResultView = [UIView new];
    self.checkResultView.accessibilityIdentifier = BJLKeypath(self, checkResultView);
    [self.contentView addSubview:self.checkResultView];
    [self.checkResultView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.titleLabel.bjl_bottom).offset(40.0);
        make.left.right.bottom.equalTo(self.contentView);
    }];
    [self makeCheckResultSubviews];
}

- (UIButton *)makeButtonWithMessage:(NSString *)message focus:(BOOL)focus {
    UIButton *button = [UIButton new];
    button.layer.cornerRadius = 8.0;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button bjl_setTitle:message forState:UIControlStateNormal];
    if (focus) {
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
    }
    else {
        button.layer.borderColor = BJLTheme.brandColor.CGColor;
        button.layer.borderWidth = 1.0;
        [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
    }
    return button;
}

#pragma mark - check finish && retry

- (void)removeAllCheckStepView {
    [self.checkResultView removeFromSuperview];
    [self.networkCheckView removeFromSuperview];
    [self.cameraCheckView removeFromSuperview];
    [self.speakerCheckView removeFromSuperview];
    [self.microphoneCheckView removeFromSuperview];
}

- (void)skipToStep:(BJLMediaCheckStep)step {
    if (self.currentStep == step) {
        return;
    }
    [self removeAllCheckStepView];
    [self.authStateView skipToStep:step];
    switch (step) {
        case BJLMediaCheckStep_network:
            [self makeCheckNetworkView];
            break;

        case BJLMediaCheckStep_camera:
            [self makeCheckCameraView];
            break;

        case BJLMediaCheckStep_speaker:
            [self makeCheckSpeakerView];
            break;

        case BJLMediaCheckStep_microphone:
            [self makeCheckMicrophoneView];
            break;

        default:
            break;
    }
}

- (void)makeRetryView {
    [self.checkResultView removeFromSuperview];
    self.authStateView.hidden = NO;
    self.skipCheckButton.hidden = NO;
    [self.authStateView prepareForRetry];
    [self.authStateView skipToStep:BJLMediaCheckStep_network];
    [self makeCheckNetworkView];
}

- (void)checkFinish:(BOOL)allCheckSuccess {
    if (!allCheckSuccess) {
        bjl_weakify(self);
        [self showAlertWithTitle:BJLLocalizedString(@"结束检测？")
                         message:BJLLocalizedString(@"部分检测项目未达标\n继续使用可能会影响上课体验")
                   opposeMessage:BJLLocalizedString(@"结束")
                  confirmMessage:BJLLocalizedString(@"重新检测")
                        callback:^(BOOL confirm, BOOL cancel) {
                            bjl_strongify(self);
                            if (cancel) {
                                return;
                            }
                            if (confirm) {
                                [self finishCheck];
                            }
                            else {
                                [self makeRetryView];
                            }
                        }];
    }
    else {
        [self finishCheck];
    }
}

- (void)saveCheckResult {
    [BJLRoomVM saveCheckResultWithDictionary:@{@"camera_status": @(self.authStateView.cameraAuth),
        @"mic_status": @(self.authStateView.microphoneAuth),
        @"speaker_status": @(self.authStateView.speakerAuth),
        @"os": self.networkCheckView.osString ?: @"",
        @"client": self.networkCheckView.versionString ?: @"",
        @"ip": self.networkCheckView.ipString ?: @""}];
}

- (void)finishCheck {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self resetCurrentAudioSessionMode];
    if (self.checkFinishCompletion) {
        self.checkFinishCompletion();
    }
}

#pragma mark - audio mode

- (void)cacheCurrentAudioSessionMode {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    self.audioSessionCategory = session.category;
    self.audioSessionOptions = session.categoryOptions;
    self.audioSessionMode = session.mode;
}

- (void)resetCurrentAudioSessionMode {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:self.audioSessionCategory withOptions:self.audioSessionOptions error:nil];
    [session setMode:self.audioSessionMode error:nil];
    if (self.audioVolume > -1) {
        self.volumeSlider.value = self.audioVolume;
    }
}

#pragma mark - notify

- (void)addNotify {
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    // 声音音量变更
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didVolumeChanged:)
                                               name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(audioSessionRouteChangeNotification:)
                                               name:AVAudioSessionRouteChangeNotification
                                             object:nil];
    MPVolumeView *volumeView = [MPVolumeView new];
    volumeView.hidden = YES;
    for (UIView *view in volumeView.subviews) {
        if ([view isKindOfClass:[UISlider class]]) {
            view.hidden = YES;
            self.volumeSlider = bjl_as(view, UISlider);
            break;
        }
    }
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty([AVAudioSession sharedInstance], outputVolume)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             // 媒体音量和通话音量的变化都会触发监听，同步通话音量的变化
             if ([AVAudioSession sharedInstance].category == AVAudioSessionCategoryPlayAndRecord) {
                 self.audioVolume = [AVAudioSession sharedInstance].outputVolume;
             }
             return YES;
         }];
}

- (void)didVolumeChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo bjl_stringForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqualToString:@"ExplicitVolumeChange"]) {
        CGFloat audioVolume = [userInfo bjl_floatForKey:@"AVSystemController_AudioVolumeNotificationParameter"];
        // 媒体音量和通话音量的变化都会触发通知，同步通话音量的变化
        if ([AVAudioSession sharedInstance].category == AVAudioSessionCategoryPlayAndRecord) {
            self.audioVolume = audioVolume;
        }
    }
}

- (void)audioSessionRouteChangeNotification:(NSNotification *)notification {
    if (self.currentStep == BJLMediaCheckStep_speaker) {
        bjl_dispatch_sync_main_queue(^{
            [self.speakerCheckView updateOutputPort];
        });
    }
    else if (self.currentStep == BJLMediaCheckStep_microphone) {
        bjl_dispatch_sync_main_queue(^{
            [self.microphoneCheckView updateInputPort];
        });
    }
}

#pragma mark -

- (void)makeCheckResultSubviews {
    CGFloat infoBarHeight = 24.0;
    CGFloat infoBarSpace = 4.0;
    BJLNetworkInfoBar *osBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"系统")];
    [osBar updateMessage:self.networkCheckView.osString centerStyle:YES];
    BJLNetworkInfoBar *versionBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"客户端")];
    [versionBar updateMessage:self.networkCheckView.versionString centerStyle:YES];
    BJLNetworkInfoBar *ipBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"网络IP")];
    [ipBar updateMessage:self.networkCheckView.ipString centerStyle:YES];
    UIStackView *topInfoStackView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[osBar, versionBar, ipBar]];
        stackView.backgroundColor = [BJLTheme.roomBackgroundColor colorWithAlphaComponent:0.5];
        stackView.spacing = infoBarSpace;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView;
    });
    [self.checkResultView addSubview:topInfoStackView];
    NSInteger infoBarCount = topInfoStackView.arrangedSubviews.count;
    [topInfoStackView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.centerX.equalTo(self.checkResultView);
        make.size.equal.sizeOffset(CGSizeMake(320.0, infoBarHeight * infoBarCount + infoBarSpace * (infoBarCount - 1)));
    }];

    CGFloat mediaBarHeight = 40.0;
    CGFloat mediaBarSpace = 16.0;
    BJLMediaStateBar *networkBar = [[BJLMediaStateBar alloc] initWithCheckStep:BJLMediaCheckStep_network pass:self.authStateView.networkReachable];
    networkBar.titleLabel.text = self.networkCheckView.networkTypeString;
    networkBar.messageLabel.numberOfLines = 2;
    networkBar.messageLabel.attributedText = [self networkStateString];
    BJLMediaStateBar *cameraBar = [[BJLMediaStateBar alloc] initWithCheckStep:BJLMediaCheckStep_camera pass:self.authStateView.cameraAuth];
    cameraBar.titleLabel.text = self.cameraCheckView.cameraName;
    cameraBar.messageLabel.text = self.authStateView.cameraAuth ? BJLLocalizedString(@"正常") : BJLLocalizedString(@"看不见");
    cameraBar.messageLabel.textColor = self.authStateView.cameraAuth ? BJLTheme.viewTextColor : BJLTheme.warningColor;
    BJLMediaStateBar *speakerBar = [[BJLMediaStateBar alloc] initWithCheckStep:BJLMediaCheckStep_speaker pass:self.authStateView.speakerAuth];
    speakerBar.titleLabel.text = self.speakerCheckView.speakerName;
    speakerBar.messageLabel.text = self.authStateView.speakerAuth ? BJLLocalizedString(@"正常") : BJLLocalizedString(@"听不见");
    speakerBar.messageLabel.textColor = self.authStateView.speakerAuth ? BJLTheme.viewTextColor : BJLTheme.warningColor;
    BJLMediaStateBar *microphoneBar = [[BJLMediaStateBar alloc] initWithCheckStep:BJLMediaCheckStep_microphone pass:self.authStateView.microphoneAuth];
    microphoneBar.titleLabel.text = self.microphoneCheckView.microphoneName;
    microphoneBar.messageLabel.text = self.authStateView.microphoneAuth ? BJLLocalizedString(@"正常") : BJLLocalizedString(@"没跳动");
    microphoneBar.messageLabel.textColor = self.authStateView.microphoneAuth ? BJLTheme.viewTextColor : BJLTheme.warningColor;
    UIStackView *mediaInfoStackView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[networkBar, cameraBar, speakerBar, microphoneBar]];
        stackView.spacing = infoBarSpace;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView;
    });
    NSInteger mediaBarCount = mediaInfoStackView.arrangedSubviews.count;
    [self.checkResultView addSubview:mediaInfoStackView];
    [mediaInfoStackView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.checkResultView);
        make.top.equalTo(topInfoStackView.bjl_bottom).offset(10.0);
        make.size.equal.sizeOffset(CGSizeMake(300.0, mediaBarHeight * mediaBarCount + mediaBarSpace * (mediaBarCount - 1)));
    }];

    BOOL allCheckSuccess = self.authStateView.networkReachable && self.authStateView.cameraAuth && self.authStateView.speakerAuth && self.authStateView.microphoneAuth;
    UILabel *resultMessageLabel = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 2;
        label.text = allCheckSuccess ? BJLLocalizedString(@"恭喜您！\n全部检测项目已达标！") : BJLLocalizedString(@"部分检测项目未达标\n可能会直接影响课堂体验！");
        label.textColor = allCheckSuccess ? BJLTheme.viewTextColor : BJLTheme.warningColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self.checkResultView addSubview:resultMessageLabel];
    [resultMessageLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.checkResultView);
        make.top.equalTo(mediaInfoStackView.bjl_bottom).offset(20.0);
        make.height.equalTo(@40.0);
    }];
    UIImageView *resultImageView = [[UIImageView alloc] initWithImage:allCheckSuccess ? [UIImage bjl_imageNamed:@"bjl_check_result_success"] : [UIImage bjl_imageNamed:@"bjl_check_result_failed"]];
    [self.checkResultView addSubview:resultImageView];
    [resultImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(topInfoStackView);
        make.size.equal.sizeOffset(CGSizeMake(65.0, 65.0));
        make.top.equalTo(resultMessageLabel);
    }];

    bjl_weakify(self);
    UIButton *opposeButton = [self makeButtonWithMessage:BJLLocalizedString(@"重新检测") focus:!allCheckSuccess];
    [opposeButton bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        [self makeRetryView];
    }];
    [self.checkResultView addSubview:opposeButton];
    [opposeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.checkResultView).multipliedBy(0.75);
        make.right.equalTo(self.checkResultView.bjl_centerX).offset(-16.0);
        make.size.equal.sizeOffset(CGSizeMake(144.0, 40.0));
    }];

    UIButton *confirmButton = [self makeButtonWithMessage:BJLLocalizedString(@"结束") focus:allCheckSuccess];
    [confirmButton bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        [self checkFinish:allCheckSuccess];
    }];
    [self.checkResultView addSubview:confirmButton];
    [confirmButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.bottom.width.equalTo(opposeButton);
        make.left.equalTo(self.checkResultView.bjl_centerX).offset(16.0);
    }];

    UILabel *checkTimeLabel = ({
        UILabel *label = [UILabel new];
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        dateFormat.dateFormat = BJLConstantString(@"yyyy年MM月dd日 HH:mm");
        dateFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:+28800];
        NSString *timeString = [dateFormat stringFromDate:[NSDate date]];
        label.text = timeString;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self.checkResultView addSubview:checkTimeLabel];
    [checkTimeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(opposeButton.bjl_bottom).offset(16.0);
        make.centerX.equalTo(self.checkResultView);
        make.height.equalTo(@20.0);
    }];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
             opposeMessage:(NSString *)opposeMessage
            confirmMessage:(NSString *)confirmMessage
                  callback:(nullable void (^)(BOOL confirm, BOOL cancel))callback {
    UIView *stopCheckConfirmView = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.overlayBackgroundColor;
        bjl_weakify(view);
        [view addGestureRecognizer:[UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
            bjl_strongify(view);
            [view removeFromSuperview];
            if (callback) {
                callback(YES, YES);
            }
        }]];
        view;
    });
    [self.view addSubview:stopCheckConfirmView];
    [stopCheckConfirmView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    UIView *containerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        view.layer.cornerRadius = 8.0;
        view.clipsToBounds = YES;
        view;
    });
    [stopCheckConfirmView addSubview:containerView];
    [containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(stopCheckConfirmView);
        make.size.equal.sizeOffset(CGSizeMake(320.0, 226.0));
    }];

    UILabel *titleLabel = ({
        UILabel *label = [UILabel new];
        label.text = title;
        label.font = [UIFont systemFontOfSize:24.0];
        label.textColor = BJLTheme.viewTextColor;
        label;
    });
    [containerView addSubview:titleLabel];
    [titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(containerView).offset(30.0);
        make.centerX.equalTo(containerView);
        make.height.equalTo(@33.0);
    }];

    UILabel *tipLabel = ({
        UILabel *label = [UILabel new];
        label.text = message;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.warningColor;
        label.numberOfLines = 2;
        label;
    });
    [containerView addSubview:tipLabel];
    [tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(titleLabel.bjl_bottom).offset(15.0);
        make.centerX.equalTo(containerView);
        make.height.equalTo(@58.0);
    }];

    UIButton *skipCheckButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = 8.0;
        button.clipsToBounds = YES;
        button.layer.borderColor = BJLTheme.brandColor.CGColor;
        button.layer.borderWidth = 1.0;
        [button bjl_setTitle:opposeMessage forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            [stopCheckConfirmView removeFromSuperview];
            callback(NO, NO);
        }];
        button;
    });
    [containerView addSubview:skipCheckButton];
    [skipCheckButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(containerView.bjl_centerX).offset(-15.0);
        make.size.equal.sizeOffset(CGSizeMake(120.0, 40.0));
        make.bottom.equalTo(containerView).offset(-24.0);
    }];

    UIButton *continueCheckButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = 8.0;
        button.clipsToBounds = YES;
        [button bjl_setTitle:confirmMessage forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            [stopCheckConfirmView removeFromSuperview];
            callback(YES, NO);
        }];
        button;
    });
    [containerView addSubview:continueCheckButton];
    [continueCheckButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(containerView.bjl_centerX).offset(15.0);
        make.top.bottom.width.equalTo(skipCheckButton);
    }];
}

- (NSAttributedString *)networkStateString {
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    NSTextAttachment *upAttach = [NSTextAttachment new];
    upAttach.bounds = CGRectMake(0.0, -4.0, 16.0, 16.0);
    upAttach.image = [UIImage bjl_imageNamed:@"bjl_check_upSpeed"];
    NSAttributedString *upImageString = [NSAttributedString attributedStringWithAttachment:upAttach];
    NSTextAttachment *downAttach = [NSTextAttachment new];
    downAttach.bounds = CGRectMake(0.0, -4.0, 16.0, 16.0);
    downAttach.image = [UIImage bjl_imageNamed:@"bjl_check_downSpeed"];
    NSAttributedString *downImageString = [NSAttributedString attributedStringWithAttachment:downAttach];
    NSMutableAttributedString *upSpeedString = [[NSMutableAttributedString alloc] initWithString:self.networkCheckView.uploadSpeedString ?: @""
                                                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10.0],
                                                                                          NSForegroundColorAttributeName: BJLTheme.viewTextColor}];
    [upSpeedString appendAttributedString:[self colorWithSpeed:self.networkCheckView.uploadSpeed]];
    NSMutableAttributedString *downSpeedString = [[NSMutableAttributedString alloc] initWithString:self.networkCheckView.downloadSpeedString ?: @""
                                                                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10.0],
                                                                                            NSForegroundColorAttributeName: BJLTheme.viewTextColor}];
    [downSpeedString appendAttributedString:[self colorWithSpeed:self.networkCheckView.downloadSpeed]];

    [result appendAttributedString:upImageString];
    [result appendAttributedString:upSpeedString];
    [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [result appendAttributedString:downImageString];
    [result appendAttributedString:downSpeedString];
    return result;
}

/**
 0-50kb/s极差
 50kb/s-200kb/s差
 200kb/s-1M/s一般
 1-10M/s 良好
 10M/s以上优秀
 */
- (NSAttributedString *)colorWithSpeed:(CGFloat)speed {
    NSString *message = @"--";
    UIColor *color = BJLTheme.viewTextColor;
    UIFont *font = [UIFont systemFontOfSize:10.0];

    if (speed * 1024 < 50.0) {
        message = BJLLocalizedString(@"极差");
    }
    else if (speed * 1024 < 200.0) {
        message = BJLLocalizedString(@"差");
    }
    else if (speed < 1.0) {
        message = BJLLocalizedString(@"一般");
    }
    else if (speed < 10.0) {
        message = BJLLocalizedString(@"良好");
    }
    else {
        message = BJLLocalizedString(@"优秀");
    }

    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", message] attributes:@{NSFontAttributeName: font,
        NSForegroundColorAttributeName: color}];
}

#pragma mark -

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self setNeedsStatusBarAppearanceUpdate];
        [self.view setNeedsUpdateConstraints];
        [self updateCameraOrientation];
    } completion:nil];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self setNeedsStatusBarAppearanceUpdate];
        if (@available(iOS 11.0, *)) {
            [self setNeedsUpdateOfHomeIndicatorAutoHidden];
        }
        [self.view setNeedsUpdateConstraints];
    } completion:nil];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone
                ? UIInterfaceOrientationMaskPortrait
                : UIInterfaceOrientationMaskAll);
}
@end
