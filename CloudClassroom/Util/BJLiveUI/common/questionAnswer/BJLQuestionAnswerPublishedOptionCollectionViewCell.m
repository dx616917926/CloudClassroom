//
//  BJLQuestionAnswerPublishedOptionCollectionViewCell.m
//  BJLiveUI
//
//  Created by fanyi on 2019/6/3.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLQuestionAnswerPublishedOptionCollectionViewCell.h"
#import "BJLAppearance.h"
#import "BJLAppearance.h"

NSString
    *const BJLQuestionAnswerPublishedOptionCollectionViewCell_ChoosenCell = @"choose",
           *const BJLQuestionAnswerPublishedOptionCollectionViewCell_JudgeCell_right = @"right",
           *const BJLQuestionAnswerPublishedOptionCollectionViewCell_JudgeCell_wrong = @"wrong";

@interface BJLQuestionAnswerPublishedOptionCollectionViewCell ()

@property (nonatomic) UILabel *selectedTimesLabel;
@property (nonatomic) UIButton *optionButton;
@property (nonatomic, strong) UILabel *bottomLabel; //底部标题，现在仅仅判断题显示判断选项title
@property (nonatomic) UIImageView *selectedIconImageView;

@end

@implementation BJLQuestionAnswerPublishedOptionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        bjl_weakify(self);
        [self bjl_kvo:BJLMakeProperty(self, reuseIdentifier)
            filter:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                return !!now;
            }
            observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                bjl_strongify(self);
                [self setUpContentView];
                [self prepareForReuse];
                return NO;
            }];
    }
    return self;
}

- (void)setUpContentView {
    self.selectedTimesLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"0次");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.accessibilityIdentifier = BJLKeypath(self, selectedTimesLabel);
        [self.contentView addSubview:label];
        bjl_return label;
    });
    [self.selectedTimesLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.top.equalTo(self.contentView);
    }];

    if ([self.reuseIdentifier isEqualToString:BJLQuestionAnswerPublishedOptionCollectionViewCell_ChoosenCell]) {
        // option button
        self.optionButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button bjl_setBackgroundColor:BJLTheme.windowBackgroundColor forState:UIControlStateNormal];
            [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateSelected];

            // layer
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = BJLAppearance.questionAnswerOptionButtonWidth / 2;
            button.layer.borderWidth = 2.0;
            button.layer.borderColor = BJLTheme.brandColor.CGColor;

            // title
            button.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
            button.titleLabel.numberOfLines = 0;
            [button setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
            [button setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateSelected];

            button;
        });
        [self.contentView addSubview:self.optionButton];
        [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.top.equalTo(self.selectedTimesLabel.bjl_bottom).offset(10);
            make.centerX.equalTo(self.contentView).offset(-1.5f);
            make.width.height.equalTo(@(BJLAppearance.questionAnswerOptionButtonWidth));
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLQuestionAnswerPublishedOptionCollectionViewCell_JudgeCell_wrong]) {
        // option button
        self.optionButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.backgroundColor = BJLTheme.windowBackgroundColor;
            // layer
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = BJLAppearance.questionAnswerOptionButtonWidth / 2;

            [button setImage:[UIImage bjl_imageNamed:@"bjl_questionAnswer_wrong_unSelect"] forState:UIControlStateNormal];
            [button setImage:[UIImage bjl_imageNamed:@"bjl_questionAnswer_wrong_select"] forState:UIControlStateSelected];
            [button setImage:[UIImage bjl_imageNamed:@"bjl_questionAnswer_wrong_select"] forState:UIControlStateHighlighted];

            button;
        });
        [self.contentView addSubview:self.optionButton];
        [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.top.equalTo(self.selectedTimesLabel.bjl_bottom).offset(10);
            make.centerX.equalTo(self.contentView).offset(-1.5f);
            make.width.height.equalTo(@(BJLAppearance.questionAnswerOptionButtonWidth));
        }];

        [self.contentView addSubview:self.bottomLabel];
        [self.bottomLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.top.equalTo(self.optionButton.bjl_bottom).offset(3);
            make.centerX.equalTo(self.optionButton);
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLQuestionAnswerPublishedOptionCollectionViewCell_JudgeCell_right]) {
        // option button
        self.optionButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.backgroundColor = BJLTheme.windowBackgroundColor;
            // layer
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = BJLAppearance.questionAnswerOptionButtonWidth / 2;

            [button setImage:[UIImage bjl_imageNamed:@"bjl_questionAnswer_right_unSelect"] forState:UIControlStateNormal];
            [button setImage:[UIImage bjl_imageNamed:@"bjl_questionAnswer_right_select"] forState:UIControlStateSelected];
            [button setImage:[UIImage bjl_imageNamed:@"bjl_questionAnswer_right_select"] forState:UIControlStateHighlighted];

            button;
        });
        [self.contentView addSubview:self.optionButton];
        [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.top.equalTo(self.selectedTimesLabel.bjl_bottom).offset(10);
            make.centerX.equalTo(self.contentView).offset(-1.5f);
            make.width.height.equalTo(@(BJLAppearance.questionAnswerOptionButtonWidth));
        }];

        [self.contentView addSubview:self.bottomLabel];
        [self.bottomLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.top.equalTo(self.optionButton.bjl_bottom).offset(3);
            make.centerX.equalTo(self.optionButton);
        }];
    }

    self.selectedIconImageView = ({
        UIImageView *imageView = [UIImageView new];
        [imageView setImage:[UIImage bjl_imageNamed:@"bjl_questionAnswer_selected"]];
        imageView.layer.cornerRadius = 9.0f;
        imageView.clipsToBounds = YES;
        imageView.hidden = YES;
        imageView;
    });
    [self.contentView addSubview:self.selectedIconImageView];
    [self.selectedIconImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.width.equalTo(@(18));
        make.bottom.right.equalTo(self.optionButton).offset(3);
    }];
}

- (void)setOptionButtonSelected:(BOOL)selected {
    self.optionButton.selected = selected;
    self.selectedIconImageView.hidden = !selected;
}

- (void)updateContentWithOptionKey:(NSString *)optionKey isSelected:(BOOL)isSelected selectedTimes:(NSInteger)times {
    self.selectedTimesLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"%td次"), times];
    [self.optionButton setTitle:optionKey forState:UIControlStateNormal];
    [self setOptionButtonSelected:isSelected];
}

- (void)updateContentWithSelected:(BOOL)isSelected selectedTimes:(NSInteger)times {
    self.selectedTimesLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"%td次"), times];
    [self setOptionButtonSelected:isSelected];
}

- (void)updateJudgeOptionTitle:(NSString *)title {
    self.bottomLabel.text = title;
}

#pragma mark - getter
- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.textColor = BJLTheme.viewTextColor;
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomLabel;
}
@end
