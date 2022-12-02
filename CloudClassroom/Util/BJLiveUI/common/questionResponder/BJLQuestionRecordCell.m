//
//  BJLQuestionRecordCell.m
//  BJLiveUI
//
//  Created by 凡义 on 2020/1/19.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLQuestionRecordCell.h"
#import "BJLAppearance.h"

@interface BJLQuestionRecordCell ()

@property (nonatomic) UIImageView *successImageView;
@property (nonatomic) UILabel *indexLabel;
@property (nonatomic) UILabel *nameLabel, *groupColorLabel, *groupNameLabel, *onlineUserCountLabel;
@end

@implementation BJLQuestionRecordCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.backgroundColor = [UIColor clearColor];
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    [self.contentView addSubview:self.indexLabel];
    [self.contentView addSubview:self.successImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.groupColorLabel];
    [self.contentView addSubview:self.groupNameLabel];
    [self.contentView addSubview:self.onlineUserCountLabel];

    [self.indexLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.contentView.bjl_left).offset(20);
        make.centerY.equalTo(self.contentView);
    }];

    [self.successImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.indexLabel.bjl_centerX).offset(20);
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@(18));
    }];

    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.successImageView);
        make.left.equalTo(self.successImageView.bjl_right).offset(8);
        make.right.lessThanOrEqualTo(self.groupColorLabel.bjl_left).offset(-20);
    }];

    [self.onlineUserCountLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.successImageView);
        make.right.equalTo(self.contentView).offset(-30);
    }];

    [self.groupNameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.contentView);
        make.left.equalTo(self.onlineUserCountLabel).offset(-130);
        make.right.lessThanOrEqualTo(self.onlineUserCountLabel.bjl_left).offset(-20);
    }];

    [self.groupColorLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.groupNameLabel);
        make.right.equalTo(self.groupNameLabel.bjl_left).offset(-2);
        make.width.height.equalTo(@(12.0));
    }];
}

- (void)updateWithIndex:(NSInteger)index user:(nullable BJLUser *)user groupInfo:(nullable BJLUserGroup *)groupInfo participateUserCount:(NSUInteger)count {
    self.indexLabel.text = @(index).stringValue;
    self.nameLabel.text = user.displayName;
    self.groupColorLabel.hidden = !groupInfo;
    self.groupNameLabel.hidden = !groupInfo;

    UIColor *groupColor = UIColor.clearColor;
    if (groupInfo.color.length > 0) {
        groupColor = [UIColor bjl_colorWithHexString:groupInfo.color];
    }
    else if (groupInfo.groupID != 0) {
        NSString *colorStr = [self.onlineUsersVM getGroupColorWithID:groupInfo.groupID];
        groupColor = [UIColor bjl_colorWithHexString:colorStr];
    }
    self.groupColorLabel.backgroundColor = groupColor;
    self.groupNameLabel.text = groupInfo.name;
    self.onlineUserCountLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"%td人"), count];
}

#pragma mark - get
- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont systemFontOfSize:12];
        _indexLabel.textColor = BJLTheme.viewTextColor;
        _indexLabel.backgroundColor = UIColor.clearColor;
        _indexLabel.accessibilityIdentifier = @"_indexLabel";
    }
    return _indexLabel;
}

- (UIImageView *)successImageView {
    if (!_successImageView) {
        _successImageView = [UIImageView new];
        [_successImageView setImage:[UIImage bjl_imageNamed:@"bjl_questionResponder_historyWinner"]];
    }
    return _successImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        [_nameLabel setText:@"--"];
        _nameLabel.textColor = BJLTheme.viewTextColor;
        [_nameLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];
        _nameLabel.accessibilityIdentifier = BJLKeypath(self, nameLabel);
    }
    return _nameLabel;
}

- (UILabel *)groupColorLabel {
    if (!_groupColorLabel) {
        _groupColorLabel = [UILabel new];
        _groupColorLabel.hidden = YES;
        _groupColorLabel.layer.cornerRadius = 6.0;
        _groupColorLabel.layer.masksToBounds = YES;
        _groupColorLabel.accessibilityIdentifier = BJLKeypath(self, groupColorLabel);
    }
    return _groupColorLabel;
}

- (UILabel *)groupNameLabel {
    if (!_groupNameLabel) {
        UILabel *label = [UILabel new];
        label.text = @"--";
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.accessibilityIdentifier = BJLKeypath(self, groupNameLabel);
        _groupNameLabel = label;
    }
    return _groupNameLabel;
}

- (UILabel *)onlineUserCountLabel {
    if (!_onlineUserCountLabel) {
        _onlineUserCountLabel = [UILabel new];
        [_onlineUserCountLabel setText:BJLLocalizedString(@"0人")];
        _onlineUserCountLabel.textColor = BJLTheme.viewTextColor;
        [_onlineUserCountLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_onlineUserCountLabel setTextAlignment:NSTextAlignmentRight];
        _onlineUserCountLabel.accessibilityIdentifier = BJLKeypath(self, onlineUserCountLabel);
    }
    return _onlineUserCountLabel;
}

@end
