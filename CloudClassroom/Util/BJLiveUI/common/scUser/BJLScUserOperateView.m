//
//  BJLScUserOperateView.m
//  BJLiveUI
//
//  Created by 凡义 on 2020/3/9.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLScUserOperateView.h"
#import "BJLScAppearance.h"
#import "BJLAvatarBackgroundColorGenerator.h"

@interface BJLScUserOperateView ()

@property (nonatomic) BJLUser *user;

@property (nonatomic) UIView *backgroundView;
@property (nonatomic, readwrite) UIImageView *avatarImageView;
@property (nonatomic) UILabel *nameLabel;

@property (nonatomic) UIButton *inviteSpeakButton;
@property (nonatomic) UIButton *forbidChatButton; // 禁止聊天
@property (nonatomic) UIButton *presentButton; // 设为主讲
@property (nonatomic) UIButton *whisperButton; // 私聊
@property (nonatomic) UIButton *kickoutButton; //踢人

@property (nonatomic, readwrite) NSArray<UIButton *> *buttons;

@end

@implementation BJLScUserOperateView
- (instancetype)initWithUser:(BJLUser *)user {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.user = user;
    }
    return self;
}

- (void)updateButtonConstraints {
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowRadius = 10.0;

    // 毛玻璃效果
    self.backgroundView = ({
        UIView *view = [UIView new];
        view;
    });
    [self addSubview:self.backgroundView];
    [self.backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    UIView *userContainerView = ({
        UIView *view = [UIView new];
        view;
    });
    [self.backgroundView addSubview:userContainerView];
    [userContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.equalTo(@(BJLScUserOperateViewButtonHeight)).priorityHigh();
        make.top.left.right.equalTo(self.backgroundView);
    }];

    self.avatarImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.accessibilityIdentifier = BJLKeypath(self, avatarImageView);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 16.0;
        imageView.layer.masksToBounds = YES;
        if (self.user.isAssistant) {
            imageView.backgroundColor = [BJLAvatarBackgroundColorGenerator backgroundColorWithUserNumber:self.user.number];
        }
        imageView;
    });
    NSString *urlString = BJLAliIMG_aspectFit(CGSizeMake(32.0, 32.0),
        0.0,
        self.user.avatar,
        nil);
    [self.avatarImageView bjl_setImageWithURL:[NSURL URLWithString:urlString]];

    [userContainerView addSubview:self.avatarImageView];
    [self.avatarImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(userContainerView).offset(20.0);
        make.centerY.equalTo(userContainerView);
        make.height.width.equalTo(@32.0);
    }];

    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, nameLabel);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14.0];
        label.numberOfLines = 1;
        label.text = self.user.displayName ?: @"";
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label;
    });
    [userContainerView addSubview:self.nameLabel];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.avatarImageView.bjl_right).offset(10.0);
        make.right.lessThanOrEqualTo(userContainerView).offset(-BJLScViewSpaceM);
        make.centerY.equalTo(self.nameLabel);
        make.height.equalTo(userContainerView);
    }];
    self.inviteSpeakButton = [self creatButtonWithTiltle:self.forceSpeak ? (self.speakingEnable ? BJLLocalizedString(@"终止发言") : BJLLocalizedString(@"强制发言")) : (self.speakingEnable ? BJLLocalizedString(@"终止发言") : (self.isInviting ? BJLLocalizedString(@"取消邀请") : BJLLocalizedString(@"邀请发言"))) titleColor:BJLTheme.brandColor];
    [self.inviteSpeakButton addTarget:self action:@selector(inviteSpeak:) forControlEvents:UIControlEventTouchUpInside];

    self.forbidChatButton = [self creatButtonWithTiltle:self.forbidChat ? BJLLocalizedString(@"允许聊天") : BJLLocalizedString(@"禁止聊天") titleColor:BJLTheme.brandColor];
    [self.forbidChatButton addTarget:self action:@selector(forbidChatAction:) forControlEvents:UIControlEventTouchUpInside];

    self.presentButton = [self creatButtonWithTiltle:self.isSetPresent ? BJLLocalizedString(@"设为主讲") : BJLLocalizedString(@"收回主讲") titleColor:BJLTheme.brandColor];
    [self.presentButton addTarget:self action:@selector(setPresent:) forControlEvents:UIControlEventTouchUpInside];

    self.whisperButton = [self creatButtonWithTiltle:BJLLocalizedString(@"私聊") titleColor:BJLTheme.brandColor];
    [self.whisperButton addTarget:self action:@selector(whisper:) forControlEvents:UIControlEventTouchUpInside];

    self.kickoutButton = [self creatButtonWithTiltle:BJLLocalizedString(@"踢出直播间") titleColor:BJLTheme.warningColor];
    [self.kickoutButton addTarget:self action:@selector(kcikout:) forControlEvents:UIControlEventTouchUpInside];

    NSMutableArray *buttons = [NSMutableArray new];
    if (!self.disableinviteSpeakButton) {
        [buttons bjl_addObject:self.inviteSpeakButton];
    }
    if (!self.disableForbidChatButton) {
        [buttons bjl_addObject:self.forbidChatButton];
    }
    if (!self.disableSetPresentButton) {
        [buttons bjl_addObject:self.presentButton];
    }
    if (self.enableWhisper) {
        [buttons bjl_addObject:self.whisperButton];
    }
    /* TODO:由于大班课目前没有黑名单, 暂时不加踢人功能
    if (!self.disableKickoutButton) {
        [buttons bjl_addObject:self.kickoutButton];
    }*/
    self.buttons = [buttons copy];
    [self makeConstraintsWithButtons:self.buttons];
}

#pragma mark - action

- (void)makeConstraintsWithButtons:(nullable NSArray *)buttonArray {
    if (buttonArray.count <= 0) {
        return;
    }
    UIButton *lastButton = nil;
    for (UIButton *button in buttonArray) {
        [self addSubview:button];
        [button bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.left.right.equalTo(self);
            if (lastButton) {
                make.height.equalTo(lastButton.bjl_height);
                make.top.equalTo(lastButton.bjl_bottom);
            }
            else {
                make.height.equalTo(@(BJLScUserOperateViewButtonHeight)).priorityHigh();
                make.top.equalTo(self.nameLabel.bjl_bottom);
            }
        }];
        lastButton = button;
    }
    [lastButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.bottom.equalTo(self.backgroundView.bjl_bottom);
    }];
}

- (void)inviteSpeak:(id)sender {
    if (self.invateSpeakCallback) {
        if (self.invateSpeakCallback(self.forceSpeak)) {
            [sender bjl_disableForSeconds:BJLScRobotDelayS];
        }
    }
}

- (void)forbidChatAction:(id)sender {
    if (self.forbidChatCallback) {
        if (self.forbidChatCallback(!self.forbidChat)) {
            [sender bjl_disableForSeconds:BJLScRobotDelayS];
        }
    }
}

- (void)whisper:(id)sender {
    if (self.whisperCallback) {
        if (self.whisperCallback()) {
            [sender bjl_disableForSeconds:BJLScRobotDelayS];
        }
    }
}

- (void)kcikout:(id)sender {
    if (self.kickoutCallback) {
        if (self.kickoutCallback()) {
            [sender bjl_disableForSeconds:BJLScRobotDelayS];
        }
    }
}

- (void)setPresent:(id)sender {
    if (self.presentCallback) {
        self.presentCallback(self.isSetPresent);
        [sender bjl_disableForSeconds:BJLScRobotDelayS];
    }
}

#pragma mark -

- (UIButton *)creatButtonWithTiltle:(NSString *)title titleColor:(UIColor *)color {
    UIButton *button = [[UIButton alloc] init];
    button.clipsToBounds = NO;
    button.accessibilityIdentifier = title;
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.borderColor = BJLTheme.separateLineColor.CGColor;
    button.layer.borderWidth = BJLScOnePixel;
    return button;
}

@end
