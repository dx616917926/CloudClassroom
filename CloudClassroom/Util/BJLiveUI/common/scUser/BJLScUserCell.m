//
//  BJLScUserCell.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/23.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScUserCell.h"
#import "BJLScAppearance.h"
#import "BJLAvatarBackgroundColorGenerator.h"

@interface BJLScUserCell ()

@property (nonatomic) BJLUser *user;
@property (nonatomic, readwrite) UIImageView *avatarImageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UIButton *roleLabel;

@property (nonatomic, readwrite) UIButton *likeButton;
@end

@implementation BJLScUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeSubviewsAndConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarImageView.image = nil;
    self.nameLabel.text = nil;
    self.roleLabel.hidden = YES;
}

- (void)makeSubviewsAndConstraints {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    self.avatarImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.accessibilityIdentifier = BJLKeypath(self, avatarImageView);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 17.0;
        imageView.layer.masksToBounds = YES;
        imageView;
    });
    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.contentView).offset(8.0);
        make.centerY.equalTo(self.contentView);
        make.height.width.equalTo(@34.0);
    }];

    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, nameLabel);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14.0];
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [label setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh - 100 forAxis:UILayoutConstraintAxisHorizontal];
        label;
    });
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.avatarImageView.bjl_right).offset(10.0);
        make.right.lessThanOrEqualTo(self.contentView).offset(-BJLScViewSpaceM);
        make.top.equalTo(self.avatarImageView);
    }];

    self.roleLabel = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = BJLKeypath(self, roleLabel);
        button.backgroundColor = [UIColor clearColor];
        [button setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        button.layer.cornerRadius = BJLScButtonCornerRadius;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = BJLScOnePixel;
        button.titleLabel.font = [UIFont systemFontOfSize:11.0];
        button.userInteractionEnabled = NO;
        button;
    });
    [self.contentView addSubview:self.roleLabel];
    [self.roleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.lessThanOrEqualTo(self.contentView).offset(-BJLScViewSpaceM);
        make.bottom.equalTo(self.avatarImageView.bjl_bottom);
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.bjl_bottom);
        make.height.equalTo(@16.0);
    }];

    self.likeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.hidden = YES;
        button.accessibilityIdentifier = BJLKeypath(self, likeButton);
        button.titleLabel.font = [UIFont systemFontOfSize:10.0];
        button.layer.cornerRadius = 11.0;
        button.layer.masksToBounds = YES;
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setTitle:nil forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage bjl_imageWithColor:[[UIColor bjl_colorWithHexString:@"#9FA8B5"] colorWithAlphaComponent:0.2]] forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        if ([BJLAward allAwards].count > 1) {
            [button setImage:[[UIImage bjl_imageNamed:@"bjl_sc_award_mediainfo"] bjl_imageFillSize:CGSizeMake(20.0, 20.0) enlarge:YES] forState:UIControlStateNormal];
        }
        else {
            [button setImage:[[UIImage bjl_imageNamed:@"bjl_sc_like_icon"] bjl_imageFillSize:CGSizeMake(20.0, 20.0) enlarge:YES] forState:UIControlStateNormal];
        }
        bjl_weakify(self);
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.likeEventHandlerBlock) {
                self.likeEventHandlerBlock(self, button);
            }
        }];

        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        button;
    });
    [self.contentView addSubview:self.likeButton];
    [self.likeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.contentView).offset(-BJLScViewSpaceM);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@22.0);
    }];
}

- (void)updateWithUser:(BJLUser *)user
              roleName:(nullable NSString *)roleName
             isSubCell:(BOOL)isSubCell
             likeCount:(NSInteger)likeCount
        hideLikeButton:(BOOL)hideLikeButton {
    [self.avatarImageView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.contentView).offset(isSubCell ? 15 : 8.0);
    }];

    self.user = user;
    self.nameLabel.text = user.displayName;
    NSString *urlString = BJLAliIMG_aspectFit(CGSizeMake(32.0, 32.0),
        0.0,
        user.avatar,
        nil);
    [self.avatarImageView bjl_setImageWithURL:[NSURL URLWithString:urlString]];
    if (user.isTeacher) {
        [self.roleLabel setTitle:roleName ?: BJLLocalizedString(@"老师") forState:UIControlStateNormal];
        [self.roleLabel setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
        self.roleLabel.layer.borderColor = BJLTheme.brandColor.CGColor;
    }
    else if (user.isAssistant) {
        [self.roleLabel setTitle:roleName ?: BJLLocalizedString(@"助教") forState:UIControlStateNormal];
        [self.roleLabel setTitleColor:[UIColor bjlsc_orangeBrandColor] forState:UIControlStateNormal];
        self.roleLabel.layer.borderColor = [UIColor bjlsc_orangeBrandColor].CGColor;
        self.avatarImageView.backgroundColor = [BJLAvatarBackgroundColorGenerator backgroundColorWithUserNumber:self.user.number];
    }
    self.roleLabel.hidden = !user.isTeacherOrAssistant;
    [self.nameLabel bjl_uninstallConstraints];
    [self.roleLabel bjl_uninstallConstraints];
    if (user.isTeacherOrAssistant) {
        [self.nameLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.avatarImageView.bjl_right).offset(10.0);
            make.right.lessThanOrEqualTo(self.contentView).offset(-BJLScViewSpaceM);
            make.top.equalTo(self.avatarImageView);
        }];
        [self.roleLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.lessThanOrEqualTo(self.contentView).offset(-BJLScViewSpaceM);
            make.bottom.equalTo(self.avatarImageView.bjl_bottom);
            make.left.equalTo(self.nameLabel);
            make.top.equalTo(self.nameLabel.bjl_bottom);
            make.height.equalTo(@16.0);
        }];
    }
    else {
        [self.nameLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.avatarImageView.bjl_right).offset(10.0);
            if (hideLikeButton) {
                make.right.lessThanOrEqualTo(self.contentView).offset(-BJLScViewSpaceM);
            }
            else {
                make.right.lessThanOrEqualTo(self.likeButton.bjl_left).offset(-2.0);
            }
            make.top.bottom.equalTo(self.avatarImageView);
        }];
        [self.roleLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.lessThanOrEqualTo(self.contentView).offset(-BJLScViewSpaceM);
            make.bottom.equalTo(self.avatarImageView.bjl_bottom);
            make.left.equalTo(self.nameLabel);
            make.height.equalTo(@16.0);
        }];
    }

    [self.likeButton setTitle:likeCount ? [NSString stringWithFormat:@"%ld", (long)likeCount] : nil forState:UIControlStateNormal];
    self.likeButton.hidden = hideLikeButton;
}

@end
