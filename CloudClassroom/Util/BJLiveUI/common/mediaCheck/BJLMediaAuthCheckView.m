//
//  BJLMediaAuthCheckView.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/19.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase.h>
#import <AVFoundation/AVFoundation.h>

#import "BJLMediaAuthCheckView.h"
#import "BJLAppearance.h"

/// 权限图标和状态视图
@interface BJLMediaAuthStateView ()

@property (nonatomic) CGFloat iconSize, iconSpace, checkIconSize;
@property (nonatomic) BOOL networkChecked, cameraChecked, speakerChecked, microphoneChecked;
@property (nonatomic, readwrite) NSMutableArray<UIButton *> *authButtons;
@property (nonatomic, readwrite) NSMutableArray<UIImageView *> *checkResultViews;
@property (nonatomic) NSMutableArray<UIView *> *progessLines;
@property (nonatomic, readwrite) UIStackView *iconView;

@end

@implementation BJLMediaAuthStateView

- (instancetype)initWithIconSize:(CGFloat)size space:(CGFloat)space {
    if (self = [super initWithFrame:CGRectZero]) {
        self.iconSize = size;
        self.iconSpace = space;
        self.checkIconSize = 16.0;
        [self makeSubviews];
    }
    return self;
}

- (void)prepareForRetry {
    self.networkChecked = self.cameraChecked = self.speakerChecked = self.microphoneChecked = NO;
    [self.authButtons enumerateObjectsUsingBlock:^(UIButton *_Nonnull button, NSUInteger idx, BOOL *_Nonnull stop) {
        button.selected = NO;
    }];
    [self.checkResultViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.checkResultViews removeAllObjects];
    [self.progessLines makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.progessLines removeAllObjects];
    self.progessLines = nil;
}

- (void)makeSubviews {
    self.iconView = ({
        NSMutableArray<UIButton *> *buttons = [NSMutableArray new];
        [buttons bjl_addObject:[self makeButtonWithImage:[UIImage bjl_imageNamed:@"bjl_check_net_normal"] selectedImage:[UIImage bjl_imageNamed:@"bjl_check_net_selected"]]];
        [buttons bjl_addObject:[self makeButtonWithImage:[UIImage bjl_imageNamed:@"bjl_check_camera_normal"] selectedImage:[UIImage bjl_imageNamed:@"bjl_check_camera_selected"]]];
        [buttons bjl_addObject:[self makeButtonWithImage:[UIImage bjl_imageNamed:@"bjl_check_speaker_normal"] selectedImage:[UIImage bjl_imageNamed:@"bjl_check_speaker_selected"]]];
        [buttons bjl_addObject:[self makeButtonWithImage:[UIImage bjl_imageNamed:@"bjl_check_mic_normal"] selectedImage:[UIImage bjl_imageNamed:@"bjl_check_mic_selected"]]];
        self.authButtons = buttons;
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:buttons];
        stackView.spacing = self.iconSpace;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView;
    });
    [self addSubview:self.iconView];
    [self.iconView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-self.checkIconSize);
        make.height.equalTo(@(self.iconSize));
        make.width.equalTo(@(self.iconSize * self.authButtons.count + self.iconSpace * (self.authButtons.count - 1)));
        make.compressionResistance.hugging.required();
    }];
}

- (void)skipToStep:(BJLMediaCheckStep)step {
    for (NSInteger i = 0; i < self.authButtons.count; i++) {
        UIButton *button = [self.authButtons bjl_objectAtIndex:i];
        button.selected = i <= step;
        UIView *progessLine = [self.progessLines bjl_objectAtIndex:i];
        if (i >= step && progessLine) {
            [progessLine removeFromSuperview];
            [self.progessLines bjl_removeObject:progessLine];
        }
        UIImageView *checkResultView = [self.checkResultViews bjl_objectAtIndex:i];
        if (i >= step && checkResultView) {
            [checkResultView removeFromSuperview];
            [self.checkResultViews bjl_removeObject:checkResultView];
        }
        [self updateStep:(BJLMediaCheckStep)i checked:i < step];
    }
}

- (void)updateStep:(BJLMediaCheckStep)step checked:(BOOL)checked {
    switch (step) {
        case BJLMediaCheckStep_network:
            self.networkChecked = checked;
            break;

        case BJLMediaCheckStep_camera:
            self.cameraChecked = checked;
            break;

        case BJLMediaCheckStep_speaker:
            self.speakerChecked = checked;
            break;

        case BJLMediaCheckStep_microphone:
            self.microphoneChecked = checked;
            break;

        default:
            break;
    }
}

- (BOOL)hasCheckedStep:(BJLMediaCheckStep)step {
    switch (step) {
        case BJLMediaCheckStep_network:
            return self.networkChecked;

        case BJLMediaCheckStep_camera:
            return self.cameraChecked;

        case BJLMediaCheckStep_speaker:
            return self.speakerChecked;

        case BJLMediaCheckStep_microphone:
            return self.microphoneChecked;

        default:
            return NO;
    }
}

- (void)makeCheckProgressView {
    if (!self.checkResultViews) {
        self.checkResultViews = [NSMutableArray new];
    }
    if (!self.progessLines) {
        self.progessLines = [NSMutableArray new];
    }
    if (self.networkChecked) {
        if (self.checkResultViews.count <= 0) {
            [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.networkReachable]];
        }
        if (self.progessLines.count <= 0) {
            [self.progessLines bjl_addObject:[self makeProgessLineBetweenStep:BJLMediaCheckStep_network step:BJLMediaCheckStep_camera]];
        }
    }
    if (self.cameraChecked) {
        if (self.checkResultViews.count <= 1) {
            [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.cameraAuth]];
        }
        if (self.progessLines.count <= 1) {
            [self.progessLines bjl_addObject:[self makeProgessLineBetweenStep:BJLMediaCheckStep_camera step:BJLMediaCheckStep_speaker]];
        }
    }
    if (self.speakerChecked) {
        if (self.checkResultViews.count <= 2) {
            [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.speakerAuth]];
        }
        if (self.progessLines.count <= 2) {
            [self.progessLines bjl_addObject:[self makeProgessLineBetweenStep:BJLMediaCheckStep_speaker step:BJLMediaCheckStep_microphone]];
        }
    }
    if (self.microphoneChecked) {
        if (self.checkResultViews.count <= 3) {
            [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.microphoneAuth]];
        }
    }
    for (NSInteger i = 0; i < self.authButtons.count; i++) {
        UIView *authButton = [self.authButtons bjl_objectAtIndex:i];
        UIView *stateView = [self.checkResultViews bjl_objectAtIndex:i];
        if (stateView && !stateView.superview) {
            [self addSubview:stateView];
            [stateView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.top.equalTo(authButton.bjl_bottom);
                make.centerX.equalTo(authButton);
                make.size.equal.sizeOffset(CGSizeMake(self.checkIconSize, self.checkIconSize));
            }];
        }
    }
}

- (void)updateStep:(BJLMediaCheckStep)step selected:(BOOL)selected {
    UIButton *button = [self.authButtons bjl_objectAtIndex:step];
    button.selected = selected;
}

- (void)makeCheckCompleteView {
    self.checkResultViews = [NSMutableArray new];
    [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.networkReachable]];
    [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.cameraAuth]];
    [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.speakerAuth]];
    [self.checkResultViews bjl_addObject:[self imageViewWithCheckSuccess:self.microphoneAuth]];
    for (NSInteger i = 0; i < self.authButtons.count; i++) {
        UIView *authButton = [self.authButtons bjl_objectAtIndex:i];
        UIView *stateView = [self.checkResultViews bjl_objectAtIndex:i];
        if (stateView) {
            [self addSubview:stateView];
            [stateView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.top.equalTo(authButton.bjl_bottom);
                make.centerX.equalTo(authButton);
                make.size.equal.sizeOffset(CGSizeMake(self.checkIconSize, self.checkIconSize));
            }];
        }
    }
}

- (void)didSelectButton:(UIButton *)button {
    BJLMediaCheckStep step = [self.authButtons indexOfObject:button];
    if (self.selectCheckStepCallback) {
        self.selectCheckStepCallback(step);
    }
}

#pragma mark -

- (UIButton *)makeButtonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    UIButton *button = [BJLImageButton new];
    button.adjustsImageWhenHighlighted = NO;
    [button bjl_setImage:image forState:UIControlStateNormal];
    [button bjl_setImage:selectedImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)makeProgessLineBetweenStep:(BJLMediaCheckStep)step step:(BJLMediaCheckStep)otherStep {
    UIButton *button = [self.authButtons bjl_objectAtIndex:step];
    UIButton *otherButton = [self.authButtons bjl_objectAtIndex:otherStep];
    UIView *view = [UIView new];
    view.backgroundColor = BJLTheme.viewTextColor;
    [self addSubview:view];
    [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(button.bjl_right);
        make.right.equalTo(otherButton.bjl_left);
        make.centerY.equalTo(button);
        make.height.equalTo(@2.0);
    }];
    return view;
}

- (UIImageView *)imageViewWithCheckSuccess:(BOOL)success {
    UIImageView *imageView = [UIImageView new];
    imageView.image = success ? [UIImage bjl_imageNamed:@"bjl_check_pass"] : [UIImage bjl_imageNamed:@"bjl_check_fail"];
    return imageView;
}

@end

@implementation BJLMediaStateBar

- (instancetype)initWithCheckStep:(BJLMediaCheckStep)step pass:(BOOL)pass {
    if (self = [super initWithFrame:CGRectZero]) {
        self->_step = step;
        self->_pass = pass;
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    self.iconImageView = [[UIImageView alloc] initWithImage:[self imageWithStep]];
    [self addSubview:self.iconImageView];
    [self.iconImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.centerY.equalTo(self);
        make.size.equal.sizeOffset(CGSizeMake(24.0, 24.0));
    }];

    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    [self addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.iconImageView.bjl_right).offset(4.0);
        make.top.bottom.equalTo(self);
    }];

    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    [self addSubview:self.messageLabel];
    [self.messageLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.greaterThanOrEqualTo(self.titleLabel.bjl_right).offset(4.0);
        make.left.equalTo(self).offset(130.0);
        make.top.bottom.equalTo(self);
    }];

    self.checkImageView = [[UIImageView alloc] initWithImage:self.pass ? [UIImage bjl_imageNamed:@"bjl_check_pass"] : [UIImage bjl_imageNamed:@"bjl_check_fail"]];
    [self addSubview:self.checkImageView];
    [self.checkImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.centerY.equalTo(self);
        make.size.equal.sizeOffset(CGSizeMake(16.0, 16.0));
    }];
}

- (UIImage *)imageWithStep {
    switch (self.step) {
        case BJLMediaCheckStep_network:
            return [UIImage bjl_imageNamed:@"bjl_check_net_selected"];

        case BJLMediaCheckStep_camera:
            return [UIImage bjl_imageNamed:@"bjl_check_camera_selected"];

        case BJLMediaCheckStep_microphone:
            return [UIImage bjl_imageNamed:@"bjl_check_mic_selected"];

        case BJLMediaCheckStep_speaker:
            return [UIImage bjl_imageNamed:@"bjl_check_speaker_selected"];

        default:
            return [UIImage bjl_imageNamed:@"bjl_check_net_selected"];
    }
}

@end

/// 权限检测视图
@interface BJLMediaAuthCheckView ()

@property (nonatomic, nullable) void (^checkCompletionCallback)(BJLMediaCheckStep step, BOOL success);
@property (nonatomic) BJLMediaCheckStep currentStep;

@property (nonatomic) BJLMediaAuthStateView *authStateView;
@property (nonatomic) UIView *placeholderLine, *progressLine;
@property (nonatomic) UILabel *progressStateLabel;
@property (nonatomic) UIButton *startButton;

@end

@implementation BJLMediaAuthCheckView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    self.startButton = ({
        UIButton *button = [UIButton new];
        button.enabled = NO;
        button.layer.cornerRadius = 8.0;
        button.clipsToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button bjl_setBackgroundColor:BJLTheme.roomBackgroundColor forState:UIControlStateDisabled];
        [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
        [button bjl_setTitle:BJLLocalizedString(@"开始") forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.buttonDisableTextColor forState:UIControlStateDisabled];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        button;
    });
    [self addSubview:self.startButton];
    [self.startButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).multipliedBy(0.75);
        make.size.equal.sizeOffset(CGSizeMake(220.0, 40.0));
    }];

    self.authStateView = [[BJLMediaAuthStateView alloc] initWithIconSize:44.0 space:37.0];
    [self addSubview:self.authStateView];
    [self.authStateView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.bjl_centerY);
        make.centerX.equalTo(self);
    }];

    UILabel *tipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"为避免产生啸叫刺耳噪音及声音质量请您佩戴有线耳机，\n尽量不要使用蓝牙耳机。");
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.viewTextColor;
        label;
    });
    [self addSubview:tipLabel];
    [tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.bjl_centerY).offset(-30.0);
        make.centerX.equalTo(self);
        make.height.equalTo(@40.0);
    }];

    UILabel *noteLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"为了保证更好的授课效果，请务必完成设备检测哦~");
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.viewTextColor;
        label;
    });
    [self addSubview:noteLabel];
    [noteLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(tipLabel.bjl_top).offset(-10.0);
        make.centerX.equalTo(self);
        make.height.equalTo(@20.0);
    }];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = (infoDictionary[(NSString *)kCFBundleNameKey] ?: infoDictionary[@"CFBundleDisplayName"] ?
                                                                                                                : @"APP");
    UILabel *greetLabel = ({
        UILabel *label = [UILabel new];
        label.text = [NSString stringWithFormat:BJLLocalizedString(@"欢迎使用%@"), appName];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16.0];
        label;
    });
    [self addSubview:greetLabel];
    [greetLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(noteLabel.bjl_top).offset(-40.0);
        make.centerX.equalTo(self);
        make.height.equalTo(@20.0);
    }];

    UILabel *titleLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"准备检测");
        label.font = [UIFont systemFontOfSize:36.0];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self addSubview:titleLabel];
    [titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(greetLabel.bjl_top).offset(-24.0);
        make.centerX.equalTo(self);
        make.height.equalTo(@50.0);
    }];
}

- (void)startCheck {
    self.placeholderLine = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.separateLineColor;
        view;
    });
    [self addSubview:self.placeholderLine];
    [self.placeholderLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.authStateView.iconView.bjl_left).offset(-10.0);
        make.right.equalTo(self.authStateView.iconView.bjl_right).offset(10.0);
        make.height.equalTo(@2.0);
        make.centerX.equalTo(self);
        make.top.equalTo(self.authStateView.iconView.bjl_bottom).offset(10.0);
    }];

    self.progressLine = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.brandColor;
        view;
    });
    [self.placeholderLine addSubview:self.progressLine];
    [self.progressLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.bottom.left.equalTo(self.placeholderLine);
        make.right.equalTo(self.placeholderLine).multipliedBy(0.0);
    }];

    self.progressStateLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"正在尝试连接必要的设备与网络");
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label;
    });
    [self addSubview:self.progressStateLabel];
    [self.progressStateLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.authStateView.iconView.bjl_bottom).offset(20.0);
        make.height.equalTo(@20.0);
    }];
    self.currentStep = BJLMediaCheckStep_network;
    bjl_weakify(self);
    self.checkCompletionCallback = ^(BJLMediaCheckStep step, BOOL success) {
        bjl_strongify(self);
        self.progressStateLabel.textColor = BJLTheme.viewTextColor;
        if (step != BJLMediaCheckStep_network) {
            self.progressStateLabel.text = BJLLocalizedString(@"正在检查设备授权情况");
            [self.authStateView updateStep:(step - 1) selected:success];
        }
        [self.progressLine bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.bottom.left.equalTo(self.placeholderLine);
            make.right.equalTo(self.placeholderLine).multipliedBy((CGFloat)step / BJLMediaCheckStep_finish);
        }];
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
    self.checkCompletionCallback(self.currentStep, YES);
}

#pragma mark -

- (void)prepareForRetry {
    [self.authStateView prepareForRetry];
    [self.progressStateLabel removeFromSuperview];
    [self.startButton bjl_removeAllHandlers];
    [self.startButton bjl_setTitle:BJLLocalizedString(@"开始") forState:UIControlStateNormal];
    self.startButton.enabled = NO;
}

- (void)makeCheckCompleteView {
    [self.placeholderLine removeFromSuperview];
    [self.authStateView makeCheckCompleteView];

    self.startButton.enabled = YES;
    [self.startButton bjl_removeAllHandlers];
    bjl_weakify(self);
    if (!self.authStateView.networkReachable) {
        self.progressStateLabel.textColor = BJLTheme.warningColor;
        self.progressStateLabel.text = BJLLocalizedString(@"网络连接异常，无法进进行检测");
        self.startButton.enabled = YES;
        [self.startButton bjl_setTitle:BJLLocalizedString(@"重试") forState:UIControlStateNormal];
        [self.startButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self prepareForRetry];
            [self startCheck];
        }];
    }
    else if (!self.authStateView.cameraAuth || !self.authStateView.microphoneAuth || !self.authStateView.speakerAuth) {
        self.progressStateLabel.textColor = BJLTheme.warningColor;
        self.progressStateLabel.text = BJLLocalizedString(@"设备异常，可以尝试设置APP授权后再次检测");
        [self.startButton bjl_setTitle:BJLLocalizedString(@"去授权") forState:UIControlStateNormal];
        [self.startButton bjl_addHandler:^(UIButton *_Nonnull button) {
            //bjl_strongify(self);
            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [UIApplication.sharedApplication bjl_openURL:appSettings];
        }];
    }
    else {
        self.progressStateLabel.text = BJLLocalizedString(@"设备与网络情况正常可以进行检测啦");
        [self.startButton bjl_setTitle:BJLLocalizedString(@"开始") forState:UIControlStateNormal];
        [self.startButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.authCheckcompletion) {
                self.authCheckcompletion(YES);
            }
        }];
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
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.authStateView.cameraAuth = granted;
                self.currentStep = BJLMediaCheckStep_speaker;
                self.checkCompletionCallback(BJLMediaCheckStep_speaker, self.authStateView.cameraAuth);
            });
        }];
    }
    else {
        self.authStateView.cameraAuth = authStatus == AVAuthorizationStatusAuthorized;
        self.currentStep = BJLMediaCheckStep_speaker;
        self.checkCompletionCallback(BJLMediaCheckStep_speaker, self.authStateView.cameraAuth);
    }
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
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.authStateView.microphoneAuth = self.authStateView.speakerAuth = granted;
                self.currentStep = BJLMediaCheckStep_finish;
                self.checkCompletionCallback(BJLMediaCheckStep_finish, self.authStateView.microphoneAuth);
            });
        }];
    }
    else {
        self.authStateView.microphoneAuth = authStatus == AVAuthorizationStatusAuthorized;
        self.currentStep = BJLMediaCheckStep_finish;
        self.checkCompletionCallback(BJLMediaCheckStep_finish, self.authStateView.microphoneAuth);
    }
}

@end
