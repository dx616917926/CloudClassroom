//
//  BJLLoadingViewController.m
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/18.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif
#import <AVFoundation/AVFoundation.h>

#import "BJLLoadingViewController.h"
#import "BJLAppearance.h"
#import "BJLRoomViewController.h"
#import "BJLMediaAuthCheckView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLLoadingViewController ()

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) BOOL isInteractiveClass;
@property (nonatomic) BJLError *error;

@property (nonatomic) BJLMediaCheckStep currentStep;
@property (nonatomic, nullable) void (^checkCompletionCallback)(BJLMediaCheckStep step, BOOL success);
@property (nonatomic, nullable) void (^recheckCallback)(void);
@property (nonatomic, nullable) void (^reloadingCallback)(void);

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) BJLMediaAuthStateView *authStateView;
@property (nonatomic) UIButton *exitButton, *enterButton, *retryButton;
@property (nonatomic) UILabel *progressStateLabel, *tipLabel;
@property (nonatomic) UILabel *enterRoomProgressLabel;

@end

@implementation BJLLoadingViewController

- (instancetype)initWithRoom:(BJLRoom *)room isInteractiveClass:(BOOL)isInteractiveClass {
    self = [super init];
    if (self) {
        self.room = room;
        self.isInteractiveClass = isInteractiveClass;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!BJLTheme.hasInitial) {
        [BJLTheme setupColorWithConfig:nil];
    }
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    [self makeSubviewsAndConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self makeObservingForEnterRoom];
    [self startAuthCheck];
}

#pragma mark - subviews

- (void)makeSubviewsAndConstraints {
    BOOL iphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    // logo
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"准备进入");
        label.font = [UIFont systemFontOfSize:36.0];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self.view addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).multipliedBy(iphone ? 0.3 : 1 - 0.618);
        make.height.equalTo(@50.0);
    }];

    self.authStateView = [[BJLMediaAuthStateView alloc] initWithIconSize:44.0 space:37.0];
    [self.view addSubview:self.authStateView];
    [self.authStateView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.titleLabel.bjl_bottom).offset(43.0);
        make.centerX.equalTo(self.view);
    }];

    self.enterRoomProgressLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:16.0];
        label.text = [NSString stringWithFormat:BJLLocalizedString(@"正在进入直播间 %.0f%%"), 0.0];
        label.textColor = BJLTheme.brandColor;
        label;
    });
    [self.view addSubview:self.enterRoomProgressLabel];
    [self.enterRoomProgressLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.authStateView.bjl_top).offset(-10.0);
        make.height.equalTo(@22.0);
        make.centerX.equalTo(self.view);
    }];

    self.progressStateLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"正在尝试连接必要的设备与网络请稍候");
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label;
    });
    [self.view addSubview:self.progressStateLabel];
    [self.progressStateLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.authStateView.iconView.bjl_bottom).offset(20.0);
        make.height.equalTo(@20.0);
    }];

    self.tipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"使用耳机可避免产生啸叫噪音");
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.viewSubTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label;
    });
    [self.view addSubview:self.tipLabel];
    [self.tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.authStateView.bjl_bottom).offset(113.0);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20.0);
    }];
}

// 进直播间前自检状态
- (void)startAuthCheck {
    self.currentStep = BJLMediaCheckStep_network;
    bjl_weakify(self);
    self.checkCompletionCallback = ^(BJLMediaCheckStep step, BOOL success) {
        bjl_strongify(self);
        self.progressStateLabel.textColor = BJLTheme.viewTextColor;
        if (step != BJLMediaCheckStep_network) {
            [self.authStateView.authButtons bjl_objectAtIndex:(step - 1)].selected = success;
        }
        switch (step) {
            case BJLMediaCheckStep_network:
                [self checkNetwork];
                break;

            case BJLMediaCheckStep_camera:
                [self checkCamera];
                break;

            case BJLMediaCheckStep_speaker:
                [self checkSpeaker];
                break;

            case BJLMediaCheckStep_microphone:
                [self checkMicrophone];
                break;

            case BJLMediaCheckStep_finish:
                [self makeCheckCompleteView];
                break;

            default:
                break;
        }
    };
    self.recheckCallback = ^{
        bjl_strongify(self);
        self.recheckCallback = nil;
        [self.retryButton removeFromSuperview];
        [self.exitButton removeFromSuperview];
        self.progressStateLabel.text = BJLLocalizedString(@"正在尝试连接必要的设备与网络请稍候");
        self.progressStateLabel.textColor = BJLTheme.viewTextColor;
        [self.authStateView prepareForRetry];
        [self startAuthCheck];
    };
    self.checkCompletionCallback(self.currentStep, YES);
}

// 自检完成
- (void)makeCheckCompleteView {
    [self.authStateView makeCheckCompleteView];
    // 仅网络错误才需要重试才能进入直播间，其他情况可以继续进入直播间
    if (!self.authStateView.networkReachable) {
        if (self.authStateView.cameraAuth && self.authStateView.microphoneAuth && self.authStateView.speakerAuth) {
            self.progressStateLabel.textColor = BJLTheme.warningColor;
            self.progressStateLabel.text = BJLLocalizedString(@"网络连接异常，无法进入直播间！");
        }
        else {
            self.progressStateLabel.text = BJLLocalizedString(@"硬件设备及网络连接异常，无法进入直播间！");
        }
        [self makeCheckFailedViewForceRetry:YES];
    }
    else if (!self.authStateView.cameraAuth || !self.authStateView.microphoneAuth || !self.authStateView.speakerAuth) {
        self.progressStateLabel.textColor = BJLTheme.warningColor;
        self.progressStateLabel.text = BJLLocalizedString(@"设备音视频未授权，可能会直接影响您的课堂体验！");
        [self makeCheckFailedViewForceRetry:NO];
    }
    else {
        self.progressStateLabel.text = BJLLocalizedString(@"网络及设备连接正常");
        if (self.enterCallback) {
            self.enterCallback();
        }
    }
}

// 进直播间前自检未全部通过
- (void)makeCheckFailedViewForceRetry:(BOOL)retry {
    bjl_weakify(self);
    if (retry) {
        self.retryButton = ({
            UIButton *button = [UIButton new];
            button.clipsToBounds = YES;
            button.layer.cornerRadius = 8.0;
            [button bjl_setTitle:BJLLocalizedString(@"重试") forState:UIControlStateNormal];
            [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
            [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [button bjl_addHandler:^(UIButton *_Nonnull button) {
                bjl_strongify(self);
                if (self.recheckCallback) {
                    self.recheckCallback();
                }
            }];
            button;
        });
        [self.view addSubview:self.retryButton];
        [self.retryButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.view.bjl_centerX).offset(-16.0);
            make.size.equal.sizeOffset(CGSizeMake(160.0, 40.0));
            make.top.equalTo(self.authStateView.bjl_bottom).offset(62.0);
        }];
        self.exitButton = ({
            UIButton *button = [UIButton new];
            button.clipsToBounds = YES;
            button.layer.cornerRadius = 8.0;
            button.layer.borderColor = BJLTheme.brandColor.CGColor;
            button.layer.borderWidth = 1.0;
            [button bjl_setTitle:BJLLocalizedString(@"退出") forState:UIControlStateNormal];
            [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [button bjl_addHandler:^(UIButton *_Nonnull button) {
                bjl_strongify(self);
                if (self.exitCallback) {
                    self.exitCallback();
                }
            }];
            button;
        });
        [self.view addSubview:self.exitButton];
        [self.exitButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.view.bjl_centerX).offset(16.0);
            make.top.bottom.width.equalTo(self.retryButton);
        }];
    }
    else {
        self.exitButton = ({
            UIButton *button = [UIButton new];
            button.clipsToBounds = YES;
            button.layer.cornerRadius = 8.0;
            [button bjl_setTitle:BJLLocalizedString(@"退出直播间") forState:UIControlStateNormal];
            [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
            [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [button bjl_addHandler:^(UIButton *_Nonnull button) {
                bjl_strongify(self);
                if (self.exitCallback) {
                    self.exitCallback();
                }
            }];
            button;
        });
        [self.view addSubview:self.exitButton];
        [self.exitButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.view.bjl_centerX).offset(-16.0);
            make.size.equal.sizeOffset(CGSizeMake(160.0, 40.0));
            make.top.equalTo(self.authStateView.bjl_bottom).offset(62.0);
        }];
        self.enterButton = ({
            UIButton *button = [UIButton new];
            button.clipsToBounds = YES;
            button.layer.cornerRadius = 8.0;
            button.layer.borderColor = BJLTheme.brandColor.CGColor;
            button.layer.borderWidth = 1.0;
            [button bjl_setTitle:BJLLocalizedString(@"继续进入") forState:UIControlStateNormal];
            [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [button bjl_addHandler:^(UIButton *_Nonnull button) {
                bjl_strongify(self);
                self.progressStateLabel.text = nil;
                [self.exitButton removeFromSuperview];
                [self.enterButton removeFromSuperview];
                if (self.enterCallback) {
                    self.enterCallback();
                }
            }];
            button;
        });
        [self.view addSubview:self.enterButton];
        [self.enterButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.view.bjl_centerX).offset(16.0);
            make.top.bottom.width.equalTo(self.exitButton);
        }];
    }
}

// 进直播间过程中失败
- (void)makeLoadFailedView {
    bjl_weakify(self);
    BOOL needRetry = !(self.error.code == BJLErrorCode_enterRoom_unsupportedClient
                       || self.error.code == BJLErrorCode_enterRoom_unsupportedDevice);
    BOOL conflict = (self.error.code == BJLErrorCode_enterRoom_loginConflict);
    self.exitButton = ({
        UIButton *button = [UIButton new];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 8.0;
        button.layer.borderColor = BJLTheme.brandColor.CGColor;
        button.layer.borderWidth = 1.0;
        [button setTitle:BJLLocalizedString(@"我知道了") forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.exitCallback) {
                self.exitCallback();
            }
        }];
        button;
    });
    [self.view addSubview:self.exitButton];
    [self.exitButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        if (needRetry) {
            make.left.equalTo(self.view.bjl_centerX).offset(16.0);
        }
        else {
            make.centerX.equalTo(self.view);
        }
        make.size.equal.sizeOffset(CGSizeMake(160.0, 40.0));
        make.top.equalTo(self.authStateView.bjl_bottom).offset(62.0);
    }];

    if (needRetry) {
        self.retryButton = ({
            UIButton *button = [UIButton new];
            button.clipsToBounds = YES;
            button.layer.cornerRadius = 8.0;
            [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
            [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
            [button setTitle:(conflict ? BJLLocalizedString(@"进入直播间") : BJLLocalizedString(@"刷新重试")) forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [button bjl_addHandler:^(UIButton *_Nonnull button) {
                bjl_strongify(self);
                if (self.reloadingCallback) {
                    self.reloadingCallback();
                }
            }];
            button;
        });
        [self.view addSubview:self.retryButton];
        [self.retryButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.view.bjl_centerX).offset(-16.0);
            make.size.equal.sizeOffset(CGSizeMake(160.0, 40.0));
            make.top.equalTo(self.authStateView.bjl_bottom).offset(62.0);
        }];
    }

    NSString *message = BJLLocalizedString(@"哎呀出错了");
    NSString *detailMessage = [NSString stringWithFormat:@"\n%@，%@", self.error.localizedDescription, self.error.localizedFailureReason];
    switch (self.error.code) {
        case BJLErrorCode_enterRoom_roomIsFull:
            message = BJLLocalizedString(@"直播间已满");
            detailMessage = BJLLocalizedString(@"\n该直播间成员已满，无法进入直播间");
            break;

        case BJLErrorCode_enterRoom_unsupportedClient:
            message = BJLLocalizedString(@"iOS端不支持");
            detailMessage = BJLLocalizedString(@"\niOS端不支持该班型，请使用PC客户端进入");
            break;

        case BJLErrorCode_enterRoom_unsupportedDevice:
            message = BJLLocalizedString(@"设备不支持");
            detailMessage = BJLLocalizedString(@"\n你的设备不支持该直播间，请更换设备进入");
            break;

        case BJLErrorCode_enterRoom_forbidden:
            message = BJLLocalizedString(@"无法进入");
            detailMessage = BJLLocalizedString(@"\n你已被移出，无法再次进入直播间");
            break;

        case BJLErrorCode_enterRoom_loginConflict:
            message = BJLLocalizedString(@"已有老师");
            detailMessage = BJLLocalizedString(@"\n继续进入将导致该老师强制下线");
            break;

        case BJLErrorCode_enterRoom_timeExpire:
            message = BJLLocalizedString(@"无法进入");
            detailMessage = BJLLocalizedString(@"\n直播间已过期");
            break;

        default:
            break;
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4.0;
    paragraphStyle.paragraphSpacing = 4.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:[message stringByAppendingString:detailMessage]
                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                             NSForegroundColorAttributeName: BJLTheme.warningColor,
                                                                             NSParagraphStyleAttributeName: paragraphStyle}];

    [self.progressStateLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.authStateView.iconView.bjl_bottom).offset(20.0);
        make.bottom.lessThanOrEqualTo(self.exitButton.bjl_top);
    }];
    self.progressStateLabel.text = nil;
    self.progressStateLabel.numberOfLines = 2;
    self.progressStateLabel.attributedText = attributedText;
    self.enterRoomProgressLabel.textColor = BJLTheme.warningColor;
}

#pragma mark - observing

- (void)makeObservingForEnterRoom {
    bjl_weakify(self);
    if (!self.room) {
        return;
    }

    [self bjl_kvo:BJLMakeProperty(self.room, loadingVM)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.loadingVM) {
                 [self makeObservingForLoadingVM:self.room.loadingVM isReload:NO];
             }
             return YES;
         }];

    [self.room setReloadingBlock:^(BJLLoadingVM *reloadingVM, void (^callback)(BOOL reload)) {
        bjl_strongify(self);
        [self makeObservingForLoadingVM:reloadingVM isReload:YES];
        callback(YES);
    }];

    [self bjl_observe:BJLMakeMethod(self.room, enterRoomFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 self.error = error;
                 [self makeLoadFailedView];
                 return YES;
             }];
}

- (void)makeObservingForLoadingVM:(nullable BJLLoadingVM *)loadingVM isReload:(BOOL)reload {
    if (self.showCallback) self.showCallback(reload);

    bjl_weakify(self);
    loadingVM.suspendBlock = ^(BJLLoadingStep step,
        BJLLoadingSuspendReason reason,
        BJLError *error,
        void (^continueCallback)(BOOL isContinue)) {
        // 成功
        BOOL enterWrongTemplate = NO;
        if (reason != BJLLoadingSuspendReason_errorOccurred) {
            BOOL rigthTemplate = self.isInteractiveClass ? (self.room.roomInfo.roomType == BJLRoomType_interactiveClass) : (self.room.roomInfo.roomType != BJLRoomType_interactiveClass);
            if (!self.ignoreTemplate && self.room.roomInfo && !rigthTemplate) {
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
        /* 
        // 失败，直接报错，没有重试步骤
        CGFloat progress = 0.2;
        switch (step) {
            case BJLLoadingStep_checkNetwork:
                progress = 0.2;
                break;
                
            case BJLLoadingStep_loadRoomInfo:
                progress = 0.25;
                break;
                
            case BJLLoadingStep_connectMasterServer:
                progress = 0.5;
                break;
                
            case BJLLoadingStep_connectRoomServer:
                progress = 0.75;
                break;
                
            default:
                break;
        }
         */
        if (enterWrongTemplate) {
            error = BJLErrorMake(BJLErrorCode_enterRoom_unsupportedClient, BJLLocalizedString(@"班型错误"));
        }
        self.error = error;
        [self makeLoadFailedView];
        self.reloadingCallback = ^{
            bjl_strongify(self);
            self.reloadingCallback = nil;
            continueCallback(YES);
        };
    };

    [self bjl_observe:BJLMakeMethod(loadingVM, loadingUpdateProgress:)
             observer:(BJLMethodObserver) ^ BOOL(CGFloat progress) {
                 bjl_strongify(self);
                 self.enterRoomProgressLabel.textColor = BJLTheme.brandColor;
                 self.enterRoomProgressLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"正在进入直播间 %.0f%%"), (progress / 1.0) * 100];
                 return YES;
             }];

    /** 首次加载成功进入直播间之后，创建 UI，隐藏 loading
     TODO:之所以换到加载完成后构建，由于遗留一个问题，在加载过程中构建，如果触发退出直播间，会出现界面卡住的情况，暂未找到解决方法
     因此在成功进入直播间后有二次确认弹窗，不会过快退出直播间，因此转移到进入直播间后才构建 UI
     */
    [self bjl_observe:BJLMakeMethod(loadingVM, loadingSuccess)
             observer:^BOOL {
                 bjl_strongify(self);
                 if (!reload && self.loadRoomInfoSucessCallback) {
                     self.loadRoomInfoSucessCallback();
                 }
                 [self hide];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(loadingVM, loadingFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 self.error = error;
                 [self makeLoadFailedView];
                 return YES;
             }];
}

#pragma mark -

// 隐藏 loading
- (void)hide {
    if (self && self.viewLoaded && self.view.window && !self.view.hidden) {
        [self bjl_removeFromParentViewControllerAndSuperiew];
        if (self.hideCallback) {
            self.hideCallback();
        }
    }
}

#pragma mark -

- (void)checkNetwork {
    if (self.currentStep != BJLMediaCheckStep_network) {
        return;
    }
    BOOL reachable = [BJLAFNeverStopReachabilityManager sharedManager].reachable;
    self.authStateView.networkReachable = reachable;
    self.currentStep = BJLMediaCheckStep_camera;
    self.checkCompletionCallback(BJLMediaCheckStep_camera, reachable);
}

- (void)checkCamera {
    if (self.currentStep != BJLMediaCheckStep_camera) {
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    self.authStateView.cameraAuth = authStatus == AVAuthorizationStatusAuthorized;
    self.currentStep = BJLMediaCheckStep_speaker;
    self.checkCompletionCallback(BJLMediaCheckStep_speaker, self.authStateView.cameraAuth);
}

- (void)checkSpeaker {
    if (self.currentStep != BJLMediaCheckStep_speaker) {
        return;
    }
    self.authStateView.speakerAuth = YES;
    self.currentStep = BJLMediaCheckStep_microphone;
    self.checkCompletionCallback(BJLMediaCheckStep_microphone, self.authStateView.speakerAuth);
}

- (void)checkMicrophone {
    if (self.currentStep != BJLMediaCheckStep_microphone) {
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    self.authStateView.microphoneAuth = authStatus == AVAuthorizationStatusAuthorized;
    self.currentStep = BJLMediaCheckStep_finish;
    self.checkCompletionCallback(BJLMediaCheckStep_finish, self.authStateView.microphoneAuth);
}

@end

NS_ASSUME_NONNULL_END
