//
//  BJLScPrivateChatUserCell.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-15.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLScPrivateChatUserCell.h"

#import "BJLViewImports.h"
#import "BJLScAppearance.h"
#import "BJLAvatarBackgroundColorGenerator.h"

NS_ASSUME_NONNULL_BEGIN

#define canManageFormat                           @"[manage-%d]"
#define isPresenterFormat                         @"[presenter-%d]"

#define userRoleFormat                            @"[userRole-%td]"
#define userStateFormat                           @"[userState-%td]"

#define hasVideoFormat                            @"[hasVideo-%d]"
#define videoPlayingFormat                        @"[videoPlaying-%d]"

#define scanIdentifier(IDENTIFIER, FORMAT, VALUE) ({                                             \
    [IDENTIFIER rangeOfString:[NSString stringWithFormat:FORMAT, VALUE]].location != NSNotFound; \
})

static const CGFloat avatarSize = 32.0;

@interface BJLScPrivateChatUserCell ()

@property (nonatomic) BOOL canManage;
@property (nonatomic) BOOL isTeacher, isAssistant;
@property (nonatomic) BOOL isPresenter;
@property (nonatomic) BOOL online, request, speaking;
@property (nonatomic) BOOL hasVideo, videoPlaying;

@property (nonatomic) UIImageView *avatarView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic, nullable) UIButton *roleButton, *presenterButton;
@property (nonatomic, nullable) UIButton *videoStateButton;

@property (nonatomic, nullable) UIButton *leftButton, *rightButton;
@property (nonatomic) UIView *line;
@end

@implementation BJLScPrivateChatUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canManage = scanIdentifier(reuseIdentifier, canManageFormat, YES);
        self.isTeacher = scanIdentifier(reuseIdentifier, userRoleFormat, BJLUserRole_teacher);
        self.isAssistant = scanIdentifier(reuseIdentifier, userRoleFormat, BJLUserRole_assistant);
        self.isPresenter = self.isAssistant && scanIdentifier(reuseIdentifier, isPresenterFormat, YES);
        self.request = scanIdentifier(reuseIdentifier, userStateFormat, BJLUserState_request);
        self.speaking = scanIdentifier(reuseIdentifier, userStateFormat, BJLUserState_speaking);
        self.online = scanIdentifier(reuseIdentifier, userStateFormat, BJLUserState_online);
        self.hasVideo = scanIdentifier(reuseIdentifier, hasVideoFormat, YES);
        self.videoPlaying = self.hasVideo && scanIdentifier(reuseIdentifier, videoPlayingFormat, YES);

        [self makeSubviews];
        [self makeConstraints];
        [self makeActions];

        [self prepareForReuse];
    }
    return self;
}

- (void)makeSubviews {
    self.avatarView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = BJLTheme.separateLineColor;
        imageView.layer.cornerRadius = avatarSize / 2;
        imageView.layer.masksToBounds = YES;
        imageView.accessibilityIdentifier = BJLKeypath(self, avatarView);
        [self.contentView addSubview:imageView];
        imageView;
    });

    self.line = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.separateLineColor;
        [self.contentView addSubview:view];
        view;
    });

    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:15.0];
        label.accessibilityIdentifier = BJLKeypath(self, nameLabel);
        [self.contentView addSubview:label];
        label;
    });

    if (self.isTeacher || self.isAssistant) {
        self.roleButton = ({
            UIButton *button = [UIButton new];
            button.userInteractionEnabled = NO;
            button.contentEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
            // [button setTitle:(self.isTeacher BJLLocalizedString(@"老师") : BJLLocalizedString(@"助教")) forState:UIControlStateNormal];
            [button setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:11.0];
            button.layer.borderWidth = BJLScOnePixel;
            button.layer.borderColor = BJLTheme.brandColor.CGColor;
            button.layer.cornerRadius = BJLScButtonCornerRadius;
            button.layer.masksToBounds = YES;
            button.accessibilityIdentifier = BJLKeypath(self, roleButton);
            [self.contentView addSubview:button];
            button;
        });
        if (self.isPresenter) {
            self.presenterButton = ({
                UIButton *button = [UIButton new];
                button.userInteractionEnabled = NO;
                button.contentEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
                [button setTitle:BJLLocalizedString(@"主讲") forState:UIControlStateNormal];
                [button setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:11.0];
                button.layer.borderWidth = BJLScOnePixel;
                button.layer.borderColor = BJLTheme.brandColor.CGColor;
                button.layer.cornerRadius = BJLScButtonCornerRadius;
                button.layer.masksToBounds = YES;
                button.accessibilityIdentifier = BJLKeypath(self, presenterButton);
                [self.contentView addSubview:button];
                button;
            });
        }
    }

    if (self.hasVideo) {
        self.videoStateButton = ({
            UIButton *button = [UIButton new];
            UIImage *icon = [UIImage bjlsc_imageNamed:(self.videoPlaying ? @"bjl_ic_video_opening" : @"bjl_ic_video_close")];
            [button setImage:icon forState:UIControlStateNormal];
            [button setTitleColor:BJLTheme.viewSubTextColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12.0];
            button.userInteractionEnabled = NO;
            button.accessibilityIdentifier = BJLKeypath(self, videoStateButton);
            [self.contentView addSubview:button];
            button;
        });
    }

    const CGFloat buttonWidth = 64.0, buttonHeight = BJLScButtonSizeS;
    if (self.request) {
        if (self.canManage) {
            self.leftButton = ({
                BJLButton *button = [BJLButton makeRoundedRectButtonHighlighted:YES];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:BJLLocalizedString(@"同意") forState:UIControlStateNormal];
                button.accessibilityIdentifier = BJLKeypath(self, leftButton);
                [self.contentView addSubview:button];
                button;
            });
            self.rightButton = ({
                BJLButton *button = [BJLButton makeRoundedRectButtonHighlighted:NO];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:BJLLocalizedString(@"拒绝") forState:UIControlStateNormal];
                button.accessibilityIdentifier = BJLKeypath(self, rightButton);
                [self.contentView addSubview:button];
                button;
            });
        }
    }
    else if (self.speaking) {
        if (self.hasVideo) {
            self.leftButton = ({
                BJLButton *button = [BJLButton makeTextButtonDestructive:NO];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:self.videoPlaying ? BJLLocalizedString(@"关闭视频") : BJLLocalizedString(@"打开视频") forState:UIControlStateNormal];
                button.accessibilityIdentifier = BJLKeypath(self, leftButton);
                [self.contentView addSubview:button];
                button;
            });
        }
        if (self.canManage && !self.isTeacher) {
            self.rightButton = ({
                BJLButton *button = [BJLButton makeTextButtonDestructive:YES];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:BJLLocalizedString(@"结束发言") forState:UIControlStateNormal];
                button.accessibilityIdentifier = BJLKeypath(self, rightButton);
                [self.contentView addSubview:button];
                button;
            });
        }
    }
}

- (void)makeConstraints {
    [self.avatarView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.width.height.equalTo(@(avatarSize));
        make.left.equalTo(self.contentView).with.offset(BJLScViewSpaceL);
        make.centerY.equalTo(self.contentView);
    }];

    [self.line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.avatarView);
        make.height.equalTo(@(BJLScOnePixel));
        make.right.bottom.equalTo(self.contentView);
    }];

    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.horizontal.compressionResistance.defaultLow();
        make.left.equalTo(self.avatarView.bjl_right).with.offset(BJLScViewSpaceM);
        make.centerY.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.roleButton.bjl_left
                                         ?: self.presenterButton.bjl_left
                                            ?
                                        : self.videoStateButton.bjl_left
                                            ?
                                        : self.leftButton.bjl_left
                                            ?
                                        : self.rightButton.bjl_left
                                            ?
                                            : self.contentView)
            .with.offset(-BJLScViewSpaceM);
    }];

    [self.roleButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.bjl_right).with.offset(BJLScViewSpaceM);
        make.centerY.equalTo(self.contentView);
        // make.size.equal.sizeOffset(CGSizeMake(32.0, 16.0));
        make.right.lessThanOrEqualTo(self.presenterButton.bjl_left
                                         ?: self.videoStateButton.bjl_left
                                            ?
                                        : self.leftButton.bjl_left
                                            ?
                                        : self.rightButton.bjl_left
                                            ?
                                            : self.contentView)
            .with.offset(-BJLScViewSpaceM);
    }];

    [self.presenterButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.roleButton.bjl_right
                              ?: self.nameLabel.bjl_right)
            .with.offset(BJLScViewSpaceM);
        make.centerY.equalTo(self.roleButton);
        make.size.equalTo(self.roleButton);
        make.right.lessThanOrEqualTo(self.videoStateButton.bjl_left
                                         ?: self.leftButton.bjl_left
                                            ?
                                        : self.rightButton.bjl_left
                                            ?
                                            : self.contentView)
            .with.offset(-BJLScViewSpaceM);
    }];

    [self.videoStateButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.presenterButton.bjl_right
                              ?: self.roleButton.bjl_right
                                 ?
                                 : self.nameLabel.bjl_right)
            .with.offset(BJLScViewSpaceM);
        make.centerY.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.leftButton.bjl_left
                                         ?: self.rightButton.bjl_left
                                            ?
                                            : self.contentView)
            .with.offset(-BJLScViewSpaceM);
    }];

    UIButton *right1st = self.rightButton ?: self.leftButton;
    [right1st bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-BJLScViewSpaceM);
        make.centerY.equalTo(self.contentView);
    }];

    UIButton *right2nd = self.rightButton ? self.leftButton : nil;
    [right2nd bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.rightButton.bjl_left).with.offset(-BJLScViewSpaceM);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)makeActions {
    bjl_weakify(self);

    [self.leftButton bjl_addHandler:^(__kindof UIControl *_Nullable sender) {
        bjl_strongify(self);
        if (self.request) {
            if (self.allowRequestCallback) self.allowRequestCallback(self);
        }
        else if (self.speaking) {
            const NSTimeInterval LIMIT = BJLScRobotDelayM;
            static NSTimeInterval LAST = 0;
            NSTimeInterval NOW = [NSDate timeIntervalSinceReferenceDate];
            if (NOW - LAST < LIMIT) {
                return;
            }
            if (self.toggleVideoPlayingRequestCallback) self.toggleVideoPlayingRequestCallback(self);
            LAST = NOW;
        }
    }];

    [self.rightButton bjl_addHandler:^(__kindof UIControl *_Nullable sender) {
        bjl_strongify(self);
        if (self.request) {
            if (self.disallowRequestCallback) self.disallowRequestCallback(self);
        }
        else if (self.speaking) {
            if (self.stopSpeakingRequestCallback) self.stopSpeakingRequestCallback(self);
        }
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarView.image = nil;
    self.nameLabel.text = nil;
}

- (void)updateWithUser:(nullable __kindof BJLUser *)user
              roleName:(nullable NSString *)roleName
             isSubCell:(BOOL)isSubCell {
    [self.avatarView bjl_setImageWithURL:[NSURL URLWithString:user.avatar]
                             placeholder:nil
                              completion:nil];
    if (user.isAssistant) {
        self.avatarView.backgroundColor = [BJLAvatarBackgroundColorGenerator backgroundColorWithUserNumber:user.number];
    }
    self.nameLabel.text = user.displayName;
    [self.roleButton setTitle:roleName ?: (self.isTeacher ? BJLLocalizedString(@"老师") : BJLLocalizedString(@"助教"))
                     forState:UIControlStateNormal];

    [self.avatarView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.contentView).with.offset(BJLScViewSpaceL + isSubCell * BJLScViewSpaceL);
    }];
}

+ (NSString *)cellIdentifierForUserState:(BJLUserState)userState
                    isTeacherOrAssistant:(BOOL)isTeacherOrAssistant
                             isPresenter:(BOOL)isPresenter
                                userRole:(BJLUserRole)userRole
                                hasVideo:(BOOL)hasVideo
                            videoPlaying:(BOOL)videoPlaying {
    return [NSString stringWithFormat:
                         canManageFormat isPresenterFormat userRoleFormat userStateFormat hasVideoFormat videoPlayingFormat,
                     isTeacherOrAssistant,
                     isPresenter,
                     userRole,
                     userState,
                     hasVideo,
                     hasVideo && videoPlaying];
}

+ (NSArray<NSString *> *)allCellIdentifiers {
    NSMutableArray *allCellIdentifiers = [NSMutableArray new];
    for (NSNumber *userRole in @[@(BJLUserRole_student), @(BJLUserRole_teacher), @(BJLUserRole_assistant), @(BJLUserRole_guest)]) {
        for (BJLUserState userState = (BJLUserState)0; userState < _BJLUserState_count; userState++) {
            for (NSNumber *hasVideo in @[@NO, @YES]) {
                for (NSNumber *videoPlaying in @[@NO, @YES]) {
                    for (NSNumber *isTeacherOrAssistant in @[@NO, @YES]) {
                        for (NSNumber *isPresenter in @[@NO, @YES]) {
                            NSString *cellIdentifier = [self
                                cellIdentifierForUserState:userState
                                      isTeacherOrAssistant:isTeacherOrAssistant.boolValue
                                               isPresenter:isPresenter.boolValue
                                                  userRole:(BJLUserRole)userRole.integerValue
                                                  hasVideo:hasVideo.boolValue
                                              videoPlaying:videoPlaying.boolValue];
                            [allCellIdentifiers bjl_addObject:cellIdentifier];
                        }
                    }
                }
            }
        }
    }
    return allCellIdentifiers;
}

@end

NS_ASSUME_NONNULL_END