//
//  BJLBonusListViewController.m
//  BJLiveUI-SmallClass
//
//  Created by Ney on 7/23/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLBonusListViewController.h"
#import <BJLiveCore/BJLBonusModel.h>
#import <BJLiveCore/BJLRoom.h>
#import "BJLTopRoundedButton.h"
#import "BJLTheme.h"
#import "BJLAppearance.h"
#import "BJLOptionViewController.h"

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

@interface BJLBonusRankListContentView: UIView
@property (nonatomic, assign) NSInteger topRange; //top xx 排名
- (instancetype)initWithRoom:(BJLRoom *)room rankType:(BJLBonusListType)rankType;
- (void)requestDataIfNeeded;
- (void)setNeedRefreshData;
- (void)requestData;
@end

@interface BJLBonusListViewController ()
//top
@property (nonatomic, strong) BJLTopRoundedButton *allTabButton;
@property (nonatomic, strong) BJLTopRoundedButton *groupTabButton;

//only one group
@property (nonatomic, strong) UILabel *rankTitleLabel;
@property (nonatomic, strong) UILabel *rankValueLabel;
@property (nonatomic, strong) UIButton *introductionButton;
@property (nonatomic, strong) BJLOptionViewController *introductionPopoverVC;
@property (nonatomic, strong) UIView *tabSeparatorLineView;

//mid
@property (nonatomic, strong) BJLBonusRankListContentView *allRank;
@property (nonatomic, strong) BJLBonusRankListContentView *groupRank;
@property (nonatomic, strong) UIView *bottomSeparatorLineView;

//bottom
@property (nonatomic, strong) UILabel *remainBonusLabel;
@property (nonatomic, strong) BJLImageRightButton *topRangeButton;
@property (nonatomic, strong) BJLOptionViewController *topRangeOptionVC;
@property (nonatomic, assign) NSInteger topRange;
@end

@implementation BJLBonusListViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent) {
        [self.allRank requestDataIfNeeded];
        [self.groupRank requestDataIfNeeded];
    }
    else {
        [self.allRank setNeedRefreshData];
        [self.groupRank setNeedRefreshData];
    }
}

- (void)setupUI {
    self.headTitle = BJLLocalizedString(@"积分排行");
    self.icon = nil;

    [self setupConstraints];

    [self updateGroupTabVisibleSetting];

    [self.allTabButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, remainBonus)
         observer:^BOOL(id now, id old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.remainBonusLabel.text = [NSString stringWithFormat:@"%@%.0f", BJLLocalizedString(@"剩余可发放积分："), self.room.roomVM.remainBonus];
             return YES;
         }];
}

- (void)updateGroupTabVisibleSetting {
    BOOL showGroupTab = NO;
    if (self.room.roomInfo.roomType == BJLRoomType_interactiveClass) {
        showGroupTab = !self.room.studyRoomVM.isStudyRoom;
    }
    else if (self.room.roomInfo.roomType == BJLRoomType_1vNClass) {
        if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_group
            || self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_onlinedoubleTeachers) {
            //组外老师、助教 显示
            //组内老师、助教 隐藏
            //组内学生：在配置项开启：显示，不开启：隐藏
            showGroupTab = (self.room.loginUser.groupID == 0);
        }
    }

    if (showGroupTab) {
        self.rankTitleLabel.hidden = YES;
        self.rankValueLabel.hidden = YES;
    }
    else {
        self.allTabButton.hidden = YES;
        self.groupTabButton.hidden = YES;
        self.groupRank.hidden = YES;
    }
}

- (void)setupConstraints {
    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        BOOL iphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        make.width.equalTo(@(UIScreen.mainScreen.bounds.size.width * (iphone ? 0.7 : 0.5)));
        make.height.equalTo(@(UIScreen.mainScreen.bounds.size.height * (iphone ? 0.7 : 0.5)));
    }];
    [self.contentView addSubview:self.allTabButton];
    [self.contentView addSubview:self.groupTabButton];
    [self.contentView addSubview:self.rankTitleLabel];
    [self.contentView addSubview:self.rankValueLabel];
    [self.contentView addSubview:self.introductionButton];
    [self.contentView addSubview:self.tabSeparatorLineView];
    [self.contentView addSubview:self.allRank];
    [self.contentView addSubview:self.groupRank];
    [self.contentView addSubview:self.bottomSeparatorLineView];
    [self.contentView addSubview:self.remainBonusLabel];
    [self.contentView addSubview:self.topRangeButton];

    //top group
    [self.tabSeparatorLineView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(@36.0);
        make.height.equalTo(@(BJL1Pixel()));
        make.left.right.equalTo(self.contentView);
    }];
    [self.allTabButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(@12);
        make.bottom.equalTo(self.tabSeparatorLineView.bjl_top);
        make.width.equalTo(@96);
        make.height.equalTo(@28);
    }];
    [self.groupTabButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.allTabButton.bjl_right).offset(8);
        make.top.equalTo(self.allTabButton);
        make.width.height.equalTo(self.allTabButton);
    }];
    [self.rankTitleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(@12);
        make.centerY.equalTo(self.tabSeparatorLineView.bjl_top).offset(-18);
    }];
    [self.introductionButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(@-12);
        make.centerY.equalTo(self.tabSeparatorLineView.bjl_top).offset(-18);
    }];
    [self.rankValueLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.introductionButton.bjl_left).offset(0);
        make.centerY.equalTo(self.introductionButton);
    }];

    //bottom group
    [self.bottomSeparatorLineView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@(BJL1Pixel()));
        make.bottom.equalTo(self.contentView).offset(-40.0);
    }];
    [self.remainBonusLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(@12);
        make.centerY.equalTo(self.contentView.bjl_bottom).offset(-20.0);
    }];
    [self.topRangeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.width.equalTo(@80);
        make.height.equalTo(@24);
        make.centerY.equalTo(self.contentView.bjl_bottom).offset(-20.0);
        make.right.equalTo(self.contentView).offset(-12.0);
    }];

    //middle group
    [self.allRank bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.tabSeparatorLineView.bjl_bottom);
        make.bottom.equalTo(self.bottomSeparatorLineView.bjl_top);
    }];
    [self.groupRank bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.allRank);
    }];
}

- (void)showContentForTabIndex:(NSInteger)tabIndex {
    NSArray<BJLBonusRankListContentView *> *arr = @[self.allRank, self.groupRank];
    if (tabIndex >= 0 && tabIndex < arr.count) {
        for (BJLBonusRankListContentView *view in arr) {
            if (view == arr[tabIndex]) {
                [view requestDataIfNeeded];
                view.hidden = NO;
            }
            else {
                view.hidden = YES;
            }
        }
    }
}

- (void)hilightTabForTabIndex:(NSInteger)tabIndex {
    NSArray<UIButton *> *arr = @[self.allTabButton, self.groupTabButton];
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

#pragma mark - getter
- (BJLTopRoundedButton *)allTabButton {
    if (!_allTabButton) {
        _allTabButton = [[BJLTopRoundedButton alloc] init];
        _allTabButton.tag = 0;
        _allTabButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_allTabButton setTitle:BJLLocalizedString(@"全部成员") forState:UIControlStateNormal];
        bjl_weakify(self);
        [_allTabButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self hilightTabForTabIndex:button.tag];
            [self showContentForTabIndex:button.tag];
            self.topRangeButton.hidden = NO;
        }];
    }
    return _allTabButton;
}

- (BJLTopRoundedButton *)groupTabButton {
    if (!_groupTabButton) {
        _groupTabButton = [[BJLTopRoundedButton alloc] init];
        _groupTabButton.tag = 1;
        _groupTabButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_groupTabButton setTitle:BJLLocalizedString(@"小组排行") forState:UIControlStateNormal];
        bjl_weakify(self);
        [_groupTabButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self hilightTabForTabIndex:button.tag];
            [self showContentForTabIndex:button.tag];
            self.topRangeButton.hidden = YES;
        }];
    }
    return _groupTabButton;
}

- (UILabel *)rankTitleLabel {
    if (!_rankTitleLabel) {
        _rankTitleLabel = [[UILabel alloc] init];
        _rankTitleLabel.text = BJLLocalizedString(@"排名");
        _rankTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        _rankTitleLabel.textColor = BJLTheme.viewTextColor;
        _rankTitleLabel.backgroundColor = UIColor.clearColor;
        _rankTitleLabel.accessibilityIdentifier = @"_rankTitleLabel";
    }
    return _rankTitleLabel;
}

- (UILabel *)rankValueLabel {
    if (!_rankValueLabel) {
        _rankValueLabel = [[UILabel alloc] init];
        _rankValueLabel.text = BJLLocalizedString(@"积分");
        _rankValueLabel.font = [UIFont systemFontOfSize:12];
        _rankValueLabel.textColor = BJLTheme.viewTextColor;
        _rankValueLabel.backgroundColor = UIColor.clearColor;
        _rankValueLabel.accessibilityIdentifier = @"_rankValueLabel";
    }
    return _rankValueLabel;
}

- (UIButton *)introductionButton {
    if (!_introductionButton) {
        _introductionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_introductionButton setImage:[UIImage bjl_imageNamed:@"bjl_bonus_introduction_normal"] forState:UIControlStateNormal];
        [_introductionButton setImage:[UIImage bjl_imageNamed:@"bjl_bonus_introduction_selected"] forState:UIControlStateSelected];
        _introductionButton.accessibilityIdentifier = @"_introductionButton";
        bjl_weakify(self);
        [_introductionButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.introductionPopoverVC.presentingViewController) {
                return;
            }

            button.selected = YES;
            self.introductionPopoverVC.sourceView = button;
            [self.introductionPopoverVC updatePopoverProperty];
            [self presentViewController:self.introductionPopoverVC animated:YES completion:nil];
        }];
    }
    return _introductionButton;
}

- (BJLOptionViewController *)introductionPopoverVC {
    if (!_introductionPopoverVC) {
        BJLOptionConfig *cfg = [BJLOptionConfig defaultConfig];
        cfg.preselectedIndex = -1;
        cfg.optionHeight = 140;
        cfg.optionWidth = 310;
        _introductionPopoverVC = [[BJLOptionViewController alloc] initWithConfig:cfg options:@[@""]];
        bjl_weakify(self);
        _introductionPopoverVC.optionCellBuilderBlock = ^UIControl *_Nonnull(BJLOptionViewController *_Nonnull vc, NSInteger index, NSString *_Nonnull option) {
            //            bjl_strongify(self);
            UIControl *view = [[UIControl alloc] init];
            view.backgroundColor = cfg.backgroudColor;

            UITextView *textView = [[UITextView alloc] init];
            textView.editable = NO;
            textView.scrollEnabled = NO;
            textView.backgroundColor = cfg.backgroudColor;
            NSString *text = BJLLocalizedString(@"1.积分排行打开窗口时更新 \n2.当剩余可发放积分不足时，部分操作将无法获得积分 \n3.积分每节课从0累计 \n4.小组积分为组内成员的积分总和 \n5.每天0点自动清空积分信息");
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 7; // 字体的行间距
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: BJLTheme.viewSubTextColor, NSParagraphStyleAttributeName: paragraphStyle};
            textView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];

            [view addSubview:textView];
            [textView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.equalTo(view).offset(6);
                make.top.equalTo(view).offset(16);
                make.bottom.right.equalTo(view);
            }];

            return view;
        };

        _introductionPopoverVC.eventBlock = ^(BJLOptionViewController *_Nonnull vc, NSInteger selectedIndex, NSInteger previousSelectedIndex, BOOL isCancel) {
            bjl_strongify(self);
            self.introductionButton.selected = NO;
        };
    }
    return _introductionPopoverVC;
}

- (UIView *)tabSeparatorLineView {
    if (!_tabSeparatorLineView) {
        _tabSeparatorLineView = [[UIView alloc] init];
        _tabSeparatorLineView.backgroundColor = BJLTheme.separateLineColor;
        _tabSeparatorLineView.accessibilityIdentifier = @"_tabSeparatorLineView";
    }
    return _tabSeparatorLineView;
}

- (BJLBonusRankListContentView *)allRank {
    if (!_allRank) {
        _allRank = [[BJLBonusRankListContentView alloc] initWithRoom:self.room rankType:BJLBonusListTypeAll];
        _allRank.topRange = 10;
    }
    return _allRank;
}

- (BJLBonusRankListContentView *)groupRank {
    if (!_groupRank) {
        _groupRank = [[BJLBonusRankListContentView alloc] initWithRoom:self.room rankType:BJLBonusListTypeGroup];
        _groupRank.topRange = 100;
    }
    return _groupRank;
}

- (UIView *)bottomSeparatorLineView {
    if (!_bottomSeparatorLineView) {
        _bottomSeparatorLineView = [[UIView alloc] init];
        _bottomSeparatorLineView.backgroundColor = BJLTheme.separateLineColor;
        _bottomSeparatorLineView.accessibilityIdentifier = @"_bottomSeparatorLineView";
    }
    return _bottomSeparatorLineView;
}

- (UILabel *)remainBonusLabel {
    if (!_remainBonusLabel) {
        _remainBonusLabel = [[UILabel alloc] init];
        _remainBonusLabel.text = @"";
        _remainBonusLabel.font = [UIFont systemFontOfSize:12];
        _remainBonusLabel.textColor = BJLTheme.viewSubTextColor;
        _remainBonusLabel.backgroundColor = UIColor.clearColor;
        _remainBonusLabel.accessibilityIdentifier = @"_remainBonusLabel";
    }
    return _remainBonusLabel;
}

- (BJLImageRightButton *)topRangeButton {
    if (!_topRangeButton) {
        _topRangeButton = [[BJLImageRightButton alloc] init];
        [_topRangeButton setTitle:@"TOP10" forState:UIControlStateNormal];
        [_topRangeButton setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        _topRangeButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        _topRangeButton.accessibilityIdentifier = @"_topRangeButton";
        _topRangeButton.midSpace = 13;
        _topRangeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
        [_topRangeButton setImage:[UIImage bjl_imageNamed:@"bjl_arrow_popover_down"] forState:UIControlStateNormal];
        _topRangeButton.backgroundColor = [[UIColor bjl_colorWithHexString:@"#9FA8B5"] colorWithAlphaComponent:0.1];
        _topRangeButton.clipsToBounds = YES;
        _topRangeButton.layer.cornerRadius = 3;
        bjl_weakify(self);
        [_topRangeButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self.topRangeButton setImage:[UIImage bjl_imageNamed:@"bjl_arrow_popover_up"] forState:UIControlStateNormal];
            self.topRangeOptionVC.sourceView = button;
            [self.topRangeOptionVC updatePopoverProperty];
            [self presentViewController:self.topRangeOptionVC animated:YES completion:nil];
        }];
    }
    return _topRangeButton;
}

- (BJLOptionViewController *)topRangeOptionVC {
    if (!_topRangeOptionVC) {
        bjl_weakify(self);
        NSArray *rangeOption = @[BJLLocalizedString(@"TOP5"),
            BJLLocalizedString(@"TOP10"),
            BJLLocalizedString(@"TOP20"),
            BJLLocalizedString(@"全部")];
        NSArray *rangeArgs = @[@5, @10, @20, @100];
        _topRangeOptionVC = [BJLOptionViewController viewControllerWithOptions:rangeOption preselectedIndex:1 eventBlock:^(BJLOptionViewController *_Nonnull vc, NSInteger selectedIndex, NSInteger previousSelectedIndex, BOOL isCancel) {
            bjl_strongify(self);
            [self.topRangeButton setImage:[UIImage bjl_imageNamed:@"bjl_arrow_popover_down"] forState:UIControlStateNormal];
            if (selectedIndex != previousSelectedIndex) {
                NSString *option = vc.options[selectedIndex];
                [self.topRangeButton setTitle:option forState:UIControlStateNormal];
                self.allRank.topRange = [rangeArgs[selectedIndex] integerValue];
                [self.allRank requestData];
            }
        }];
    }
    return _topRangeOptionVC;
}
@end

@interface BJLBonusRankListItemCell: UITableViewCell
- (void)setData:(BJLBonusListItem *)data;
@end

@interface BJLBonusRankListItemCell ()
@property (nonatomic, strong) UIImageView *top3BadgeIcon;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIView *groupColorView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *bonusNumberLabel;
@property (nonatomic, strong) UIView *separateLineView;
@end

@implementation BJLBonusRankListItemCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.backgroundColor = BJLTheme.windowBackgroundColor;
    self.backgroundColor = BJLTheme.windowBackgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:self.indexLabel];
    [self.contentView addSubview:self.top3BadgeIcon];
    [self.contentView addSubview:self.groupColorView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.bonusNumberLabel];
    [self.contentView addSubview:self.separateLineView];

    [self.top3BadgeIcon bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.width.height.equalTo(@20.0);
        make.centerX.equalTo(self.bjl_left).offset(22);
        make.centerY.equalTo(self.contentView);
    }];
    [self.indexLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self.top3BadgeIcon);
    }];
    [self.groupColorView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.width.height.equalTo(@12);
        make.centerY.equalTo(self.contentView);
        make.centerX.equalTo(self.indexLabel).offset(24);
    }];
    [self.userNameLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.indexLabel.bjl_centerX).offset(37);
        make.right.lessThanOrEqualTo(self.bonusNumberLabel.bjl_left);
    }];
    [self.bonusNumberLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView.bjl_right).offset(-50);
    }];
    [self.separateLineView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.height.equalTo(@(BJL1Pixel()));
        make.left.bottom.right.equalTo(self.contentView);
    }];
}

- (void)setData:(BJLBonusListItem *)data {
    if (!data) { return; }

    self.indexLabel.text = @(data.ranking).stringValue;
    if (data.ranking >= 1 && data.ranking <= 3) {
        NSArray *nameTable = @[
            @"bjl_rank_1st",
            @"bjl_rank_2nd",
            @"bjl_rank_3rd"
        ];
        NSString *name = [nameTable bjl_objectAtIndex:data.ranking - 1];
        self.top3BadgeIcon.image = [UIImage bjl_imageNamed:name];
        self.top3BadgeIcon.hidden = NO;
    }
    else {
        self.top3BadgeIcon.hidden = YES;
    }

    self.userNameLabel.text = data.name ?: @"";
    CGFloat nameLabelOffset = 0;
    UIColor *color = [UIColor bjl_colorWithHexString:data.color];
    if (color) {
        self.groupColorView.backgroundColor = color;
        self.groupColorView.hidden = NO;
        nameLabelOffset = 37;
    }
    else {
        nameLabelOffset = 18;
        self.groupColorView.hidden = YES;
    }
    [self.userNameLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.indexLabel.bjl_centerX).offset(nameLabelOffset);
        make.right.lessThanOrEqualTo(self.bonusNumberLabel.bjl_left);
    }];

    if (data.points > 0) {
        self.bonusNumberLabel.text = [NSString stringWithFormat:@"%.0f", data.points];
    }
    else {
        self.bonusNumberLabel.text = @"-";
    }
}

#pragma mark getter
- (UIImageView *)top3BadgeIcon {
    if (!_top3BadgeIcon) {
        _top3BadgeIcon = [[UIImageView alloc] init];
        _top3BadgeIcon.backgroundColor = [UIColor clearColor];
    }
    return _top3BadgeIcon;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.text = @"";
        _indexLabel.font = [UIFont systemFontOfSize:12];
        _indexLabel.textColor = BJLTheme.viewTextColor;
        _indexLabel.backgroundColor = UIColor.clearColor;
    }
    return _indexLabel;
}

- (UIView *)groupColorView {
    if (!_groupColorView) {
        _groupColorView = [[UIView alloc] init];
        _groupColorView.backgroundColor = [UIColor clearColor];
        _groupColorView.accessibilityIdentifier = @"_groupColorView";
        _groupColorView.layer.cornerRadius = 6;
        _groupColorView.layer.masksToBounds = YES;
    }
    return _groupColorView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.text = @"";
        _userNameLabel.font = [UIFont systemFontOfSize:12];
        _userNameLabel.textColor = BJLTheme.viewTextColor;
        _userNameLabel.backgroundColor = UIColor.clearColor;
        [_userNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh - 1 forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _userNameLabel;
}

- (UILabel *)bonusNumberLabel {
    if (!_bonusNumberLabel) {
        _bonusNumberLabel = [[UILabel alloc] init];
        _bonusNumberLabel.text = @"";
        _bonusNumberLabel.font = [UIFont systemFontOfSize:12];
        _bonusNumberLabel.textColor = BJLTheme.viewTextColor;
        _bonusNumberLabel.backgroundColor = UIColor.clearColor;
        _bonusNumberLabel.accessibilityIdentifier = @"_bonusNumberLabel";
    }
    return _bonusNumberLabel;
}

- (UIView *)separateLineView {
    if (!_separateLineView) {
        _separateLineView = [[UIView alloc] init];
        _separateLineView.backgroundColor = BJLTheme.separateLineColor;
        _separateLineView.accessibilityIdentifier = @"_separateLineView";
    }
    return _separateLineView;
}
@end

@interface BJLBonusRankListContentView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic, assign) BJLBonusListType rankType;

@property (nonatomic, strong) BJLBonusList *list;
@property (nonatomic, assign) BOOL needRefresh;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *placeholderImageView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation BJLBonusRankListContentView
- (instancetype)initWithRoom:(BJLRoom *)room rankType:(BJLBonusListType)rankType {
    self = [super init];
    if (self) {
        self.room = room;
        self.needRefresh = YES;
        self.rankType = rankType;
        [self makeSubview];

        bjl_weakify(self);
        [self bjl_observe:BJLMakeMethod(self.room.roomVM, onReceiveBonusRankList:) observer:^BOOL(BJLBonusList *list) {
            bjl_strongify(self);

            if (list && rankType == list.type) {
                self.list = list;
                self.needRefresh = NO;
                if (list.rankList.count > 0) {
                    self.placeholderLabel.hidden = YES;
                    self.placeholderImageView.hidden = YES;
                }
                else {
                    self.placeholderLabel.hidden = NO;
                    self.placeholderImageView.hidden = NO;
                }
                [self.tableView reloadData];
            }

            return YES;
        }];
    }
    return self;
}

- (void)requestDataIfNeeded {
    if (!self.list || self.needRefresh) {
        [self fetchData];
    }
}

- (void)setNeedRefreshData {
    self.needRefresh = YES;
}

- (void)requestData {
    [self fetchData];
}

- (void)makeSubview {
    [self addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self addSubview:self.placeholderImageView];
    [self addSubview:self.placeholderLabel];

    [self.placeholderImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    [self.placeholderLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self.placeholderImageView).offset(4);
        make.top.equalTo(self.placeholderImageView.bjl_bottom).offset(10);
    }];
}

- (void)fetchData {
    [self.room.roomVM requestBonusRankListWithType:self.rankType
                                               top:self.topRange
                                        userNumber:self.room.loginUser.number
                                           groupID:self.room.loginUser.groupID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.rankList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLBonusRankListItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BJLBonusRankListItemCell" forIndexPath:indexPath];
    BJLBonusListItem *data = self.list.rankList[indexPath.row];
    [cell setData:data];
    return cell;
}

#pragma mark getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 36;
        [_tableView registerClass:BJLBonusRankListItemCell.class forCellReuseIdentifier:@"BJLBonusRankListItemCell"];

        _tableView.accessibilityIdentifier = @"_tableView";
    }
    return _tableView;
}

- (UIImageView *)placeholderImageView {
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] init];
        _placeholderImageView.image = [UIImage bjl_imageNamed:@"bjl_list_empty"];
        _placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _placeholderImageView.backgroundColor = [UIColor clearColor];
        [_placeholderImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.width.height.equalTo(@(80.0));
        }];
    }
    return _placeholderImageView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.text = BJLLocalizedString(@"暂无数据~");
        _placeholderLabel.font = [UIFont systemFontOfSize:12];
        _placeholderLabel.textColor = BJLTheme.buttonBorderColor;
        _placeholderLabel.backgroundColor = UIColor.clearColor;
    }
    return _placeholderLabel;
}
@end
