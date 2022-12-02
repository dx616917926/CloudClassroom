//
//  BJLStudentBonusRankViewController.m
//  BJLiveUI-SmallClass
//
//  Created by Ney on 7/23/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLStudentBonusRankViewController.h"
#import <BJLiveCore/BJLBonusModel.h>
#import <BJLiveCore/BJLRoom.h>
#import "BJLTopRoundedButton.h"
#import "BJLTheme.h"
#import "BJLAppearance.h"

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

@interface BJLStudentBonusRankViewController ()
//top
@property (nonatomic, strong) BJLTopRoundedButton *meTabButton;
@property (nonatomic, strong) BJLTopRoundedButton *groupTabButton;
@property (nonatomic, strong) UIView *tabSeparatorLineView;

//mid
@property (nonatomic, strong) UIView *bottomSeparatorLineView;
@property (nonatomic, strong) UIImageView *iconImageView; //👑
@property (nonatomic, strong) UILabel *rankTitleLabel; //我的排名
@property (nonatomic, strong) UILabel *bonusTitleLabel; //积分

//bottom
@property (nonatomic, strong) UILabel *rankLabel; //第10名
@property (nonatomic, strong) UILabel *bonusValueLabel; // xx分
@property (nonatomic, strong) UILabel *groupRankLabel;
@property (nonatomic, strong) UILabel *groupBonusValueLabel;

@property (nonatomic, strong) BJLBonusList *meBonusList;
@property (nonatomic, strong) BJLBonusList *groupBonusList;
@property (nonatomic, assign) BOOL meBonusListNeedUpdate;
@property (nonatomic, assign) BOOL groupBonusListNeedUpdate;
@end

@implementation BJLStudentBonusRankViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.meBonusListNeedUpdate = YES;
        self.groupBonusListNeedUpdate = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self makeObserve];
    [self.meTabButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent) {
        [self requestMeDataIfNeeded];
        [self requestGroupDataIfNeeded];
    }
    else {
        self.meBonusListNeedUpdate = YES;
        self.groupBonusListNeedUpdate = YES;
    }
}

- (void)setupUI {
    self.headTitle = BJLLocalizedString(@"我的积分");
    self.icon = nil;

    [self setupConstraints];

    [self updateGroupTabVisibleSetting];
}

- (void)updateGroupTabVisibleSetting {
    BOOL showGroupTab = NO;
    if (self.room.roomInfo.roomType == BJLRoomType_interactiveClass) {
        showGroupTab = !self.room.studyRoomVM.isStudyRoom;
    }
    else if (self.room.roomInfo.roomType == BJLRoomType_1vNClass) {
        if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_onlinedoubleTeachers) {
            showGroupTab = self.room.featureConfig.enableShowAllGroupMember;
        }
    }

    if (showGroupTab) {
        [self.bottomSeparatorLineView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(@72.0);
            make.height.equalTo(@(BJL1Pixel()));
        }];
        self.meTabButton.hidden = NO;
        self.groupTabButton.hidden = NO;
    }
    else {
        [self.bottomSeparatorLineView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(@36.0);
            make.height.equalTo(@(BJL1Pixel()));
        }];
        self.meTabButton.hidden = YES;
        self.groupTabButton.hidden = YES;
    }
}

- (void)makeObserve {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, onReceiveBonusRankList:) observer:^BOOL(BJLBonusList *list) {
        bjl_strongify(self);

        if (list.type == BJLBonusListTypeMe && list.rankList.count > 0) {
            self.meBonusList = list;
            self.meBonusListNeedUpdate = NO;
            BJLBonusListItem *item = list.rankList.firstObject;
            if (item.ranking == 0) {
                self.rankLabel.text = BJLLocalizedString(@"暂无排名");
            }
            else {
                self.rankLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"第%ld名"), (long)item.ranking];
            }
            self.bonusValueLabel.text = [NSString stringWithFormat:@"%.0f", item.points];
        }
        else if (list.type == BJLBonusListTypeMeInGroup && list.rankList.count > 0) {
            self.groupBonusList = list;
            self.groupBonusListNeedUpdate = NO;
            BJLBonusListItem *item = list.rankList.firstObject;
            if (item.ranking == 0) {
                self.groupRankLabel.text = BJLLocalizedString(@"暂无排名");
            }
            else {
                self.groupRankLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"第%ld名"), (long)item.ranking];
            }
            self.groupBonusValueLabel.text = [NSString stringWithFormat:@"%.0f", item.points];
        }

        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, onReceiveBonusIncreasing:) observer:(BJLMethodObserver) ^ BOOL(CGFloat bonus) {
        bjl_strongify(self);
        [self requestMeData];
        return YES;
    }];
}

- (void)setupConstraints {
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.width.equalTo(@(UIScreen.mainScreen.bounds.size.width * 0.4));
    }];

    [self.contentView addSubview:self.meTabButton];
    [self.contentView addSubview:self.groupTabButton];
    [self.contentView addSubview:self.tabSeparatorLineView];

    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.rankTitleLabel];
    [self.contentView addSubview:self.bonusTitleLabel];
    [self.contentView addSubview:self.bottomSeparatorLineView];

    [self.contentView addSubview:self.rankLabel];
    [self.contentView addSubview:self.bonusValueLabel];
    [self.contentView addSubview:self.groupRankLabel];
    [self.contentView addSubview:self.groupBonusValueLabel];

    //top group
    [self.tabSeparatorLineView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(@36.0);
        make.height.equalTo(@(BJL1Pixel()));
        make.left.right.equalTo(self.contentView);
    }];
    [self.meTabButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(@12);
        make.bottom.equalTo(self.tabSeparatorLineView.bjl_top);
        make.width.equalTo(@96);
        make.height.equalTo(@28);
    }];
    [self.groupTabButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.meTabButton.bjl_right).offset(8);
        make.top.equalTo(self.meTabButton);
        make.width.height.equalTo(self.meTabButton);
    }];

    [self.iconImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(@12);
        make.centerY.equalTo(self.bottomSeparatorLineView).offset(-18);
    }];
    [self.rankTitleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.iconImageView.bjl_right).offset(2);
        make.centerY.equalTo(self.iconImageView);
    }];
    [self.bonusTitleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.bonusValueLabel);
        make.centerY.equalTo(self.iconImageView);
    }];

    [self.bottomSeparatorLineView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(@72.0);
        make.height.equalTo(@(BJL1Pixel()));
    }];
    [self.rankLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(@20);
        make.centerY.equalTo(self.bottomSeparatorLineView.bjl_bottom).offset(20);
        make.centerY.equalTo(self.contentView.bjl_bottom).offset(-20);
    }];
    [self.groupRankLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.rankLabel);
        make.centerY.equalTo(self.rankLabel);
    }];
    [self.bonusValueLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.rankLabel);
        make.centerX.equalTo(self.contentView.bjl_right).offset(-60);
    }];
    [self.groupBonusValueLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.bonusValueLabel);
    }];
}

- (void)showContentForTabIndex:(NSInteger)tabIndex {
    NSArray<NSArray<UIView *> *> *arr = @[
        @[self.rankLabel, self.bonusValueLabel],
        @[self.groupRankLabel, self.groupBonusValueLabel],
    ];
    if (tabIndex >= 0 && tabIndex < arr.count) {
        for (NSInteger i = 0; i < arr.count; i++) {
            for (UIView *views in arr[i]) {
                if (i == tabIndex) {
                    views.hidden = NO;
                }
                else {
                    views.hidden = YES;
                }
            }
        }
    }

    NSArray *titles = @[
        @[BJLLocalizedString(@"我的排名"), BJLLocalizedString(@"积分")],
        @[BJLLocalizedString(@"我的小组排名"), BJLLocalizedString(@"小组总积分")],
    ];
    if (tabIndex >= 0 && tabIndex < titles.count) {
        self.rankTitleLabel.text = titles[tabIndex][0];
        self.bonusTitleLabel.text = titles[tabIndex][1];
    }
}

- (void)hilightTabForTabIndex:(NSInteger)tabIndex {
    NSArray<UIButton *> *arr = @[self.meTabButton, self.groupTabButton];
    if (tabIndex >= 0 && tabIndex < arr.count) {
        for (UIButton *btn in arr) {
            if (btn == arr[tabIndex]) {
                btn.backgroundColor = BJLTheme.brandColor;
                [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            }
            else {
                btn.backgroundColor = BJLTheme.windowBackgroundColor;
                [btn setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
            }
        }
    }
}

- (void)requestMeDataIfNeeded {
    if (!self.meBonusList || self.meBonusListNeedUpdate) {
        [self requestMeData];
    }
}

- (void)requestMeData {
    [self.room.roomVM requestBonusRankListWithType:BJLBonusListTypeMe
                                               top:100
                                        userNumber:self.room.loginUser.number
                                           groupID:self.room.loginUser.groupID];
}

- (void)requestGroupDataIfNeeded {
    if (!self.groupBonusList || self.groupBonusListNeedUpdate) {
        [self.room.roomVM requestBonusRankListWithType:BJLBonusListTypeMeInGroup
                                                   top:100
                                            userNumber:self.room.loginUser.number
                                               groupID:self.room.loginUser.groupID];
    }
}

#pragma mark - getter
- (BJLTopRoundedButton *)meTabButton {
    if (!_meTabButton) {
        _meTabButton = [[BJLTopRoundedButton alloc] init];
        _meTabButton.tag = 0;
        _meTabButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_meTabButton setTitle:BJLLocalizedString(@"我的") forState:UIControlStateNormal];
        bjl_weakify(self);
        [_meTabButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self hilightTabForTabIndex:button.tag];
            [self showContentForTabIndex:button.tag];
            [self requestMeDataIfNeeded];
        }];
    }
    return _meTabButton;
}

- (BJLTopRoundedButton *)groupTabButton {
    if (!_groupTabButton) {
        _groupTabButton = [[BJLTopRoundedButton alloc] init];
        _groupTabButton.tag = 1;
        _groupTabButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_groupTabButton setTitle:BJLLocalizedString(@"我的小组") forState:UIControlStateNormal];

        bjl_weakify(self);
        [_groupTabButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self hilightTabForTabIndex:button.tag];
            [self showContentForTabIndex:button.tag];
            [self requestGroupDataIfNeeded];
        }];
    }
    return _groupTabButton;
}

- (UIView *)tabSeparatorLineView {
    if (!_tabSeparatorLineView) {
        _tabSeparatorLineView = [[UIView alloc] init];
        _tabSeparatorLineView.backgroundColor = BJLTheme.separateLineColor;
        _tabSeparatorLineView.accessibilityIdentifier = @"_tabSeparatorLineView";
    }
    return _tabSeparatorLineView;
}

- (UIView *)bottomSeparatorLineView {
    if (!_bottomSeparatorLineView) {
        _bottomSeparatorLineView = [[UIView alloc] init];
        _bottomSeparatorLineView.backgroundColor = BJLTheme.separateLineColor;
        _bottomSeparatorLineView.accessibilityIdentifier = @"_bottomSeparatorLineView";
    }
    return _bottomSeparatorLineView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage bjl_imageNamed:@"bjl_toolbar_bonus_crown"];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.accessibilityIdentifier = @"_iconImageView";
    }
    return _iconImageView;
}

- (UILabel *)rankTitleLabel {
    if (!_rankTitleLabel) {
        _rankTitleLabel = [[UILabel alloc] init];
        _rankTitleLabel.font = [UIFont systemFontOfSize:14];
        _rankTitleLabel.textColor = BJLTheme.viewSubTextColor;
        _rankTitleLabel.backgroundColor = UIColor.clearColor;
        _rankTitleLabel.accessibilityIdentifier = @"_rankTitleLabel";
    }
    return _rankTitleLabel;
}

- (UILabel *)bonusTitleLabel {
    if (!_bonusTitleLabel) {
        _bonusTitleLabel = [[UILabel alloc] init];
        _bonusTitleLabel.font = [UIFont systemFontOfSize:14];
        _bonusTitleLabel.textColor = BJLTheme.viewTextColor;
        _bonusTitleLabel.backgroundColor = UIColor.clearColor;
        _bonusTitleLabel.accessibilityIdentifier = @"_bonusTitleLabel";
    }
    return _bonusTitleLabel;
}

- (UILabel *)rankLabel {
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc] init];
        _rankLabel.text = BJLLocalizedString(@"暂无排名");
        _rankLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        _rankLabel.textColor = BJLTheme.viewTextColor;
        _rankLabel.backgroundColor = UIColor.clearColor;
        _rankLabel.accessibilityIdentifier = @"_rankLabel";
    }
    return _rankLabel;
}

- (UILabel *)bonusValueLabel {
    if (!_bonusValueLabel) {
        _bonusValueLabel = [[UILabel alloc] init];
        _bonusValueLabel.text = BJLLocalizedString(@"0");
        _bonusValueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _bonusValueLabel.textColor = BJLTheme.viewTextColor;
        _bonusValueLabel.backgroundColor = UIColor.clearColor;
        _bonusValueLabel.accessibilityIdentifier = @"_bonusValueLabel";
    }
    return _bonusValueLabel;
}

- (UILabel *)groupRankLabel {
    if (!_groupRankLabel) {
        _groupRankLabel = [[UILabel alloc] init];
        _groupRankLabel.text = BJLLocalizedString(@"暂无排名");
        _groupRankLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        _groupRankLabel.textColor = BJLTheme.viewTextColor;
        _groupRankLabel.backgroundColor = UIColor.clearColor;
        _groupRankLabel.accessibilityIdentifier = @"_groupRankLabel";
    }
    return _groupRankLabel;
}

- (UILabel *)groupBonusValueLabel {
    if (!_groupBonusValueLabel) {
        _groupBonusValueLabel = [[UILabel alloc] init];
        _groupBonusValueLabel.text = BJLLocalizedString(@"0");
        _groupBonusValueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _groupBonusValueLabel.textColor = BJLTheme.viewTextColor;
        _groupBonusValueLabel.backgroundColor = UIColor.clearColor;
        _groupBonusValueLabel.accessibilityIdentifier = @"_groupBonusValueLabel";
    }
    return _groupBonusValueLabel;
}
@end
