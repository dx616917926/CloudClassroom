//
//  BJLRollCallWidgetView.m
//  BJLiveUI
//
//  Created by Ney on 1/12/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJLRollCallWidgetView.h"

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>
#import "BJLAppearance.h"

@implementation BJLRollCallStartView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (NSInteger)time {
    for (UIButton *btn in self.timeOptionsStackView.arrangedSubviews.copy) {
        if (![btn isKindOfClass:UIButton.class]) { continue; }
        if (btn.isSelected) {
            return btn.tag;
        }
    }
    return 0;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(280.0, 150.0);
}

- (void)buildUI {
    BOOL isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;

    [self addSubview:self.timeLabel];
    [self addSubview:self.timeOptionsStackView];
    [self addSubview:self.startRollCallButton];

    NSArray *timeOptions = @[@10, @20, @30, @60];
    for (NSInteger i = 0; i < timeOptions.count; i++) {
        NSNumber *time = timeOptions[i];
        UIButton *btn = [self getOptionButtonWithTime:time.integerValue];
        [self.timeOptionsStackView addArrangedSubview:btn];
    }

    //select first
    [self buttonEventHandler:self.timeOptionsStackView.arrangedSubviews.firstObject];

    [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(@16.0);
        make.centerX.equalTo(self);
    }];
    [self.timeOptionsStackView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.bjl_bottom).offset(22.0);
        make.height.equalTo(@32.0);
        make.left.right.equalTo(self.startRollCallButton);
    }];
    [self.startRollCallButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.timeOptionsStackView.bjl_bottom).offset(isPortrait ? 40.0 : 14.0);
        make.height.equalTo(@32.0);
        make.left.equalTo(@16.0);
        make.right.equalTo(@-16.0);
    }];
}

- (UIButton *)getOptionButtonWithTime:(NSInteger)time {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    NSString *title = [NSString stringWithFormat:BJLLocalizedString(@"%ld秒"), (long)time];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 3;
    [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.2].CGColor;
    [self setButtonAsNormalTheme:button];
    [button addTarget:self action:@selector(buttonEventHandler:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = time;

    return button;
}

- (void)buttonEventHandler:(UIButton *)button {
    if (button.tag <= 0) { return; }

    for (UIButton *btn in self.timeOptionsStackView.arrangedSubviews.copy) {
        if (![btn isKindOfClass:UIButton.class] || btn == button) { continue; }
        [self setButtonAsNormalTheme:btn];
    }

    [self setButtonAsSelectedTheme:button];

    self.timeLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"请设置学生需要在 %ld 秒内响应"), (long)button.tag];
}

- (void)setButtonAsNormalTheme:(UIButton *)button {
    button.backgroundColor = BJLTheme.windowBackgroundColor;
    button.selected = NO;
}

- (void)setButtonAsSelectedTheme:(UIButton *)button {
    button.backgroundColor = BJLTheme.brandColor;
    button.selected = YES;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.accessibilityIdentifier = @"timeLabel";
        _timeLabel.text = @"";
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = BJLTheme.viewTextColor;
        _timeLabel.backgroundColor = UIColor.clearColor;
    }
    return _timeLabel;
}

- (UIStackView *)timeOptionsStackView {
    if (!_timeOptionsStackView) {
        _timeOptionsStackView = [[UIStackView alloc] init];
        _timeOptionsStackView.accessibilityIdentifier = @"timeOptionsStackView";
        _timeOptionsStackView.axis = UILayoutConstraintAxisHorizontal;
        _timeOptionsStackView.distribution = UIStackViewDistributionFillEqually;
        _timeOptionsStackView.alignment = UIStackViewAlignmentCenter;
        _timeOptionsStackView.spacing = 8;
    }
    return _timeOptionsStackView;
}

- (UIButton *)startRollCallButton {
    if (!_startRollCallButton) {
        _startRollCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startRollCallButton.accessibilityIdentifier = @"startRollCallButton";

        [_startRollCallButton setTitle:BJLLocalizedString(@"发起点名") forState:UIControlStateNormal];
        _startRollCallButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _startRollCallButton.backgroundColor = BJLTheme.brandColor;
        _startRollCallButton.layer.cornerRadius = 3.0;
        [_startRollCallButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [_startRollCallButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    }
    return _startRollCallButton;
}
@end

@implementation BJLRollCallCountdownTimerView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];

    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(@27.0);
    }];
    [self.subtitleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.titleLabel.bjl_bottom).offset(12.0);
    }];
}

- (void)updateTime:(NSInteger)time {
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:@(MAX(0, time)).stringValue];
    UIColor *red = [UIColor colorWithRed:0.99 green:0.20 blue:0.35 alpha:1.0];
    [atts addAttribute:NSForegroundColorAttributeName value:red range:NSMakeRange(0, atts.length)];

    NSMutableAttributedString *atts2 = [[NSMutableAttributedString alloc] initWithString:BJLLocalizedString(@" 秒后可以查看结果，请稍候~")];
    [atts2 addAttribute:NSForegroundColorAttributeName value:BJLTheme.viewTextColor range:NSMakeRange(0, atts2.length)];

    [atts appendAttributedString:atts2];

    self.subtitleLabel.attributedText = atts;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(280.0, 150.0);
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.accessibilityIdentifier = @"titleLabel";
        _titleLabel.text = BJLLocalizedString(@"学生正在陆续答到中");
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = BJLTheme.viewTextColor;
        _titleLabel.backgroundColor = UIColor.clearColor;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.accessibilityIdentifier = @"subtitleLabel";
        _subtitleLabel.text = BJLLocalizedString(@"稍后可以查看结果，请稍候~");
        _subtitleLabel.font = [UIFont systemFontOfSize:14];
        _subtitleLabel.textColor = BJLTheme.viewTextColor;
        _subtitleLabel.backgroundColor = UIColor.clearColor;
    }
    return _subtitleLabel;
}
@end

@implementation BJLRollCallResultItemCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.nameLabel];
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;

        [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.contentView).offset(2.0);
            make.right.lessThanOrEqualTo(self.contentView).offset(-2.0).priorityMedium();
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)updateData:(BJLRollCallResultItem *)data {
    self.nameLabel.text = data.name;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.accessibilityIdentifier = @"nameLabel";
        _nameLabel.text = @"";
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = BJLTheme.viewTextColor;
        _nameLabel.backgroundColor = UIColor.clearColor;
    }
    return _nameLabel;
}
@end

@implementation BJLRollCallResultView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUI];
        [self selectDefaultTab];
    }
    return self;
}

- (void)buildUI {
    BOOL isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;

    [self addSubview:self.nackListTabButton];
    [self addSubview:self.nackListTableView];
    [self addSubview:self.ackListTabButton];
    [self addSubview:self.ackListTableView];
    [self addSubview:self.rollCallAgainButton];

    [self addSubview:self.emptyDataLabel];
    [self addSubview:self.emptyDataImageView];

    [self.nackListTabButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(@8.0);
        make.left.equalTo(@10.0);
        make.height.equalTo(@30.0);
    }];
    [self.ackListTabButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.nackListTabButton);
        make.right.equalTo(@-10.0);
        make.left.equalTo(self.nackListTabButton.bjl_right).offset(10);
        make.height.width.equalTo(self.nackListTabButton);
    }];
    [self.nackListTableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.nackListTabButton.bjl_bottom).offset(1);
        make.bottom.equalTo(self.rollCallAgainButton.bjl_top).offset(-8);
    }];
    [self.ackListTableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.nackListTableView);
    }];
    [self.emptyDataImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.nackListTableView);
    }];
    [self.emptyDataLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self.emptyDataImageView);
        make.top.equalTo(self.emptyDataImageView.bjl_bottom).offset(2);
    }];
    [self.rollCallAgainButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(@16.0);
        make.right.equalTo(@-16.0);
        make.bottom.equalTo(@(isPortrait ? -40.0 : -12.0));
        make.height.equalTo(@32.0);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.ackListTabButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(4, 4)];
        shapeLayer.frame = self.ackListTabButton.bounds;
        shapeLayer.path = path.CGPath;
        self.ackListTabButton.layer.mask = shapeLayer;

        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.path = path.CGPath;
        borderLayer.fillColor = UIColor.clearColor.CGColor;
        borderLayer.strokeColor = [UIColor colorWithRed:159 / 255.0 green:168 / 255.0 blue:181 / 255.0 alpha:0.20].CGColor;
        borderLayer.lineWidth = 1;
        borderLayer.lineJoin = kCALineJoinRound;
        borderLayer.lineCap = kCALineCapRound;
        borderLayer.frame = self.ackListTabButton.bounds;
        [self.ackListTabButton.layer addSublayer:borderLayer];

        self.ackListTabMaskLayer = shapeLayer;

        if (self.ackListTabBorderLayer) {
            [self.ackListTabBorderLayer removeFromSuperlayer];
        }
        self.ackListTabBorderLayer = borderLayer;
    }

    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.nackListTabButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(4, 4)];
        shapeLayer.frame = self.nackListTabButton.bounds;
        shapeLayer.path = path.CGPath;
        self.nackListTabButton.layer.mask = shapeLayer;

        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.path = path.CGPath;
        borderLayer.fillColor = UIColor.clearColor.CGColor;
        borderLayer.strokeColor = [UIColor colorWithRed:159 / 255.0 green:168 / 255.0 blue:181 / 255.0 alpha:0.20].CGColor;
        borderLayer.lineWidth = 1;
        borderLayer.lineJoin = kCALineJoinRound;
        borderLayer.lineCap = kCALineCapRound;
        borderLayer.frame = self.nackListTabButton.bounds;
        [self.nackListTabButton.layer addSublayer:borderLayer];

        self.nackListTabMaskLayer = shapeLayer;
        if (self.nackListTabBorderLayer) {
            [self.nackListTabBorderLayer removeFromSuperlayer];
        }
        self.nackListTabBorderLayer = borderLayer;
    }
}

- (void)updateRollCallResult:(BJLRollCallResult *)result {
    self.result = result;

    NSString *nackListTabTitle = [NSString stringWithFormat:BJLLocalizedString(@"未答到(%lu)"), (unsigned long)result.nackList.count];
    [self.nackListTabButton setTitle:nackListTabTitle forState:UIControlStateNormal];
    NSString *ackListTabTitle = [NSString stringWithFormat:BJLLocalizedString(@"答到(%lu)"), (unsigned long)result.ackList.count];
    [self.ackListTabButton setTitle:ackListTabTitle forState:UIControlStateNormal];

    [self.ackListTableView reloadData];
    [self.nackListTableView reloadData];

    [self updateEmptyUIForCurrentList];
}

- (void)updateCooldownRemainTime:(NSInteger)cooldownRemainTime {
    if (cooldownRemainTime <= 0) {
        [_rollCallAgainButton setTitle:BJLLocalizedString(@"再次点名") forState:UIControlStateNormal];
    }
    else {
        NSString *rerollcall = BJLLocalizedString(@"秒后再次发起点名");
        NSString *title = [NSString stringWithFormat:@"%ld%@", (long)cooldownRemainTime, rerollcall];
        [_rollCallAgainButton setTitle:title forState:UIControlStateNormal];
    }
}

- (CGSize)intrinsicContentSize {
    BOOL iphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (iphone) {
        CGSize screen = UIScreen.mainScreen.bounds.size;
        CGFloat height = (MIN(screen.width, screen.height) - 140.0);
        return CGSizeMake(280.0, height);
    }
    else {
        return CGSizeMake(280.0, 420.0);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.ackListTableView) {
        return self.result.ackList.count;
    }
    if (tableView == self.nackListTableView) {
        return self.result.nackList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLRollCallResultItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(BJLRollCallResultItemCell.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BJLRollCallResultItem *data = nil;
    if (tableView == self.ackListTableView) {
        data = [self.result.ackList bjl_objectAtIndex:indexPath.item];
    }
    if (tableView == self.nackListTableView) {
        data = [self.result.nackList bjl_objectAtIndex:indexPath.item];
    }
    [cell updateData:data];
    return cell;
}

#pragma mark - helper
- (void)showEmptyUI:(BOOL)empty {
    self.emptyDataImageView.hidden = !empty;
    self.emptyDataLabel.hidden = !empty;
}

- (void)updateEmptyUIForCurrentList {
    BOOL isEmpty = YES;
    if (!self.nackListTableView.hidden) {
        isEmpty = self.result.nackList.count == 0;
    }
    else if (!self.ackListTableView.hidden) {
        isEmpty = self.result.ackList.count == 0;
    }
    [self showEmptyUI:isEmpty];
}

- (void)selectDefaultTab {
    [self.nackListTabButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - getter
- (UIButton *)ackListTabButton {
    if (!_ackListTabButton) {
        _ackListTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _ackListTabButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_ackListTabButton setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        [_ackListTabButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];

        bjl_weakify(self);
        [_ackListTabButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            button.selected = YES;
            button.backgroundColor = BJLTheme.brandColor;
            self.ackListTableView.hidden = NO;
            self.nackListTabButton.selected = NO;
            self.nackListTabButton.backgroundColor = BJLTheme.windowBackgroundColor;
            self.nackListTableView.hidden = YES;

            [self updateEmptyUIForCurrentList];
        }];

        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.ackListTabButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(4, 4)];
        shapeLayer.frame = self.ackListTabButton.bounds;
        shapeLayer.fillColor = UIColor.clearColor.CGColor;
        shapeLayer.strokeColor = UIColor.blackColor.CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.path = path.CGPath;
    }
    return _ackListTabButton;
}

- (UIButton *)nackListTabButton {
    if (!_nackListTabButton) {
        _nackListTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nackListTabButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_nackListTabButton setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        [_nackListTabButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];

        bjl_weakify(self);
        [_nackListTabButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            button.selected = YES;
            button.backgroundColor = BJLTheme.brandColor;
            self.nackListTableView.hidden = NO;
            self.ackListTableView.hidden = YES;
            self.ackListTabButton.selected = NO;
            self.ackListTabButton.backgroundColor = BJLTheme.windowBackgroundColor;

            [self updateEmptyUIForCurrentList];
        }];
    }
    return _nackListTabButton;
}

- (UITableView *)ackListTableView {
    if (!_ackListTableView) {
        _ackListTableView = [[UITableView alloc] init];
        _ackListTableView.accessibilityIdentifier = @"ackListTableView";
        _ackListTableView.dataSource = self;
        _ackListTableView.rowHeight = 35.0;
        _ackListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _ackListTableView.backgroundColor = UIColor.clearColor;
        [_ackListTableView registerClass:BJLRollCallResultItemCell.class forCellReuseIdentifier:NSStringFromClass(BJLRollCallResultItemCell.class)];
    }
    return _ackListTableView;
}

- (UITableView *)nackListTableView {
    if (!_nackListTableView) {
        _nackListTableView = [[UITableView alloc] init];
        _nackListTableView.accessibilityIdentifier = @"nackListTableView";
        _nackListTableView.dataSource = self;
        _nackListTableView.rowHeight = 35.0;
        _nackListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _nackListTableView.backgroundColor = UIColor.clearColor;
        [_nackListTableView registerClass:BJLRollCallResultItemCell.class forCellReuseIdentifier:NSStringFromClass(BJLRollCallResultItemCell.class)];
    }
    return _nackListTableView;
}

- (UIImageView *)emptyDataImageView {
    if (!_emptyDataImageView) {
        BOOL isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;
        _emptyDataImageView = [[UIImageView alloc] init];
        _emptyDataImageView.image = [UIImage bjl_imageNamed:isPortrait ? @"bjl_rollcall_userlist_empty_portrait" : @"bjl_rollcall_userlist_empty"];
        _emptyDataImageView.backgroundColor = [UIColor clearColor];
        _emptyDataImageView.hidden = YES;
    }
    return _emptyDataImageView;
}

- (UILabel *)emptyDataLabel {
    if (!_emptyDataLabel) {
        BOOL isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;
        _emptyDataLabel = [[UILabel alloc] init];
        _emptyDataLabel.text = BJLLocalizedString(isPortrait ? @"暂无数据" : @"暂无记录");
        _emptyDataLabel.font = [UIFont systemFontOfSize:12];
        _emptyDataLabel.textColor = BJLTheme.viewSubTextColor;
        _emptyDataLabel.backgroundColor = UIColor.clearColor;
        _emptyDataLabel.hidden = YES;
    }
    return _emptyDataLabel;
}

- (UIButton *)rollCallAgainButton {
    if (!_rollCallAgainButton) {
        _rollCallAgainButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rollCallAgainButton.accessibilityIdentifier = @"rollCallAgainButton";
        [_rollCallAgainButton setTitle:BJLLocalizedString(@"再次点名") forState:UIControlStateNormal];
        _rollCallAgainButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rollCallAgainButton.backgroundColor = BJLTheme.brandColor;
        [_rollCallAgainButton setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        _rollCallAgainButton.layer.cornerRadius = 3;
        _rollCallAgainButton.layer.masksToBounds = YES;
    }
    return _rollCallAgainButton;
}
@end
