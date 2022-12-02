//
//  BJLNetworkCheckView.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/22.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLNetworkCheckView.h"
#import "BJLMediaAuthCheckView.h"
#import "BJLAppearance.h"

@implementation BJLNetworkInfoBar

- (instancetype)initWithName:(NSString *)name {
    if (self = [super initWithFrame:CGRectZero]) {
        self.name = name;
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.viewTextColor;
        label.text = self.name;
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    [self addSubview:self.nameLabel];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.centerY.equalTo(self);
    }];

    self.loadingImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage bjl_imageNamed:@"bjl_check_loading"];
        imageView;
    });
    [self addSubview:self.loadingImageView];
    [self.loadingImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.centerY.equalTo(self);
        make.width.height.equalTo(@16.0);
    }];

    self.messageLabel = ({
        UILabel *label = [UILabel new];
        label.hidden = YES;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = BJLTheme.viewTextColor;
        label;
    });
    [self addSubview:self.messageLabel];
    [self startLoadingAnimationWithAngle:0];
}

- (void)updateMessage:(NSString *)message {
    [self updateMessage:message centerStyle:NO];
}

- (void)updateMessage:(NSString *)message centerStyle:(BOOL)centerStyle {
    if (centerStyle) {
        [self.messageLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.bjl_centerX);
            make.right.lessThanOrEqualTo(self);
        }];
    }
    else {
        [self.messageLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.centerY.equalTo(self);
        }];
    }
    self.messageLabel.text = message;
    self.messageLabel.hidden = NO;
    self.loadingImageView.hidden = YES;
    [self.loadingImageView.layer removeAllAnimations];
    self.loadingImageView.transform = CGAffineTransformIdentity;
}

#pragma mark -

- (void)startLoadingAnimationWithAngle:(NSInteger)angle {
    NSInteger nextAngle = angle + 20;
    if (nextAngle >= 360) {
        nextAngle -= 360;
    }
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.loadingImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        if (!self.loadingImageView.hidden || !self.window) {
            [self startLoadingAnimationWithAngle:nextAngle];
        }
    }];
}

@end

@interface BJLNetworkCheckView ()

@property (nonatomic) UIStackView *checkContentView;
@property (nonatomic) BJLNetworkInfoBar *osBar, *versionBar, *ipBar, *netTypeBar, *upSpeedBar, *downSpeedBar;
@property (nonatomic) UIButton *nextStepButton;
@property (nonatomic) UILabel *checkLabel;

@end

@implementation BJLNetworkCheckView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    CGFloat barSize = 20.0;
    CGFloat barSpace = 16.0;

    self.osBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"操作系统")];
    self.versionBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"客户端")];
    self.ipBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"网络IP")];
    self.netTypeBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"网络类型")];
    self.upSpeedBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"上行")];
    self.downSpeedBar = [[BJLNetworkInfoBar alloc] initWithName:BJLLocalizedString(@"下行")];
    self.checkContentView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.osBar, self.versionBar, self.ipBar, self.netTypeBar, self.upSpeedBar, self.downSpeedBar]];
        stackView.spacing = barSize;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView;
    });
    NSInteger count = self.checkContentView.arrangedSubviews.count;
    [self addSubview:self.checkContentView];
    [self.checkContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.height.equalTo(@(count * barSize + (count - 1) * barSpace));
        make.width.equalTo(@320.0);
    }];
    [self startCheck];
}

- (void)startCheck {
    self.osString = [[UIDevice currentDevice].systemName stringByAppendingString:[NSString stringWithFormat:@" %@", [UIDevice currentDevice].systemVersion]];
    [self.osBar updateMessage:self.osString];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"] ?: [infoDictionary objectForKey:(__bridge NSString *)kCFBundleVersionKey];
    self.versionString = [NSString stringWithFormat:@"V %@", version];
    [self.versionBar updateMessage:self.versionString];
    BJLNetworkType type = [BJLAFNeverStopReachabilityManager sharedManager].networkType;
    self.networkTypeString = [self networkTypeStringWithType:type];
    [self.netTypeBar updateMessage:self.networkTypeString];
    [BJLRoomVM checkUploadSpeedAndDownloadSpeedWithCompletion:^(NSString *_Nullable ipAddress, CGFloat uploadSpeed, CGFloat downloadSpeed, BJLError *_Nullable error) {
        [self makeCheckedViewWithError:error];
        if (error) {
            return;
        }
        self.uploadSpeed = uploadSpeed;
        self.downloadSpeed = downloadSpeed;
        self.ipString = ipAddress;
        self.uploadSpeedString = uploadSpeed < 0.1 ? [NSString stringWithFormat:@"%.1f kbps", uploadSpeed * 1024] : [NSString stringWithFormat:@"%.1f Mbps", uploadSpeed];
        self.downloadSpeedString = downloadSpeed < 0.1 ? [NSString stringWithFormat:@"%.1f kbps", downloadSpeed * 1024] : [NSString stringWithFormat:@"%.1f Mbps", downloadSpeed];
        [self.ipBar updateMessage:ipAddress];
        [self.downSpeedBar updateMessage:self.downloadSpeedString];
        [self.upSpeedBar updateMessage:self.uploadSpeedString];
    }];
}

- (void)makeCheckedViewWithError:(BJLError *)error {
    if (self.nextStepButton) {
        [self.nextStepButton removeFromSuperview];
        [self.checkLabel removeFromSuperview];
    }
    bjl_weakify(self);
    self.nextStepButton = ({
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = 8.0;
        button.enabled = !error;
        button.clipsToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button bjl_setBackgroundColor:BJLTheme.roomBackgroundColor forState:UIControlStateDisabled];
        [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
        [button bjl_setTitle:BJLLocalizedString(@"下一步") forState:UIControlStateNormal];
        [button bjl_setTitleColor:BJLTheme.buttonDisableTextColor forState:UIControlStateDisabled];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.networkCheckCompletion) {
                self.networkCheckCompletion(YES);
            }
        }];
        button;
    });
    [self addSubview:self.nextStepButton];
    [self.nextStepButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).multipliedBy(0.75);
        make.size.equal.sizeOffset(CGSizeMake(220.0, 40.0));
    }];
    BOOL networkUnreachable = [BJLAFNetworkReachabilityManager sharedManager].reachable;
    UILabel *label = ({
        UILabel *label = [UILabel new];
        label.text = error ? (networkUnreachable ? BJLLocalizedString(@"正在重连，检测中请务必保持网络正常连接") : error.localizedFailureReason ?
                                                                                                                                                : error.localizedDescription)
                           : BJLLocalizedString(@"网络检测完成");
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self addSubview:label];
    [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.nextStepButton.bjl_top).offset(-16.0);
        make.height.equalTo(@20.0);
    }];
    if (!networkUnreachable) {
        [self bjl_kvo:BJLMakeProperty([BJLAFNetworkReachabilityManager sharedManager], reachable)
             observer:^BJLControlObserving(NSNumber *_Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 if (value.bjl_boolValue) {
                     [self startCheck];
                     return NO;
                 }
                 return YES;
             }];
    }
}

#pragma mark -

- (NSString *)networkTypeStringWithType:(BJLNetworkType)type {
    switch (type) {
        case BJLNetworkTypeWiFi:
            return @"WiFi";

        case BJLNetworkType2G:
            return @"2G";

        case BJLNetworkType3G:
            return @"3G";

        case BJLNetworkType4G:
            return @"4G";

        case BJLNetworkType5G:
            return @"5G";

        default:
            return BJLLocalizedString(@"未知网络");
            ;
    }
}

@end
