//
//  BJLQuestionAnswerOptionCollectionViewCell.m
//  BJLiveUI
//
//  Created by fanyi on 2019/5/29.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLQuestionAnswerOptionCollectionViewCell.h"
#import "BJLAppearance.h"
#import "BJLAppearance.h"

NSString
    *const BJLQuestionAnswerOptionCollectionViewCellID_ChoosenCell = @"choosen",
           *const BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_right = @"right",
           *const BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong = @"wrong";

@interface BJLQuestionAnswerOptionCollectionViewCell ()

@property (nonatomic) UIButton *optionButton;
@property (nonatomic) UIImageView *selectedIconImageView;
@property (nonatomic) UILabel *wrongLabel;

@end

@implementation BJLQuestionAnswerOptionCollectionViewCell

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
    if ([self.reuseIdentifier isEqualToString:BJLQuestionAnswerOptionCollectionViewCellID_ChoosenCell]) {
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

            // action
            [button addTarget:self action:@selector(optionButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [self.contentView addSubview:self.optionButton];
        [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equalTo(self.contentView).offset(-1.5f);
            make.centerY.equalTo(self.contentView).offset(-1.5f);
            make.width.height.equalTo(@(BJLAppearance.questionAnswerOptionButtonWidth));
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong]) {
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

            // action
            [button addTarget:self action:@selector(optionButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];

            button;
        });
        [self.contentView addSubview:self.optionButton];
        [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equalTo(self.contentView).offset(-1.5f);
            make.top.equalTo(self.contentView);
            make.width.height.equalTo(@(BJLAppearance.questionAnswerOptionButtonWidth));
        }];

        self.wrongLabel = ({
            UILabel *label = [UILabel new];
            label.text = BJLLocalizedString(@"错");
            label.textColor = BJLTheme.viewTextColor;
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        [self.contentView addSubview:self.wrongLabel];
        [self.wrongLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerX.equalTo(self.optionButton);
            make.top.equalTo(self.optionButton.bjl_bottom).offset(5);
            make.bottom.equalTo(self.contentView);
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_right]) {
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

            // action
            [button addTarget:self action:@selector(optionButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];

            button;
        });
        [self.contentView addSubview:self.optionButton];
        [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equalTo(self.contentView).offset(-1.5f);
            make.top.equalTo(self.contentView);
            make.width.height.equalTo(@(BJLAppearance.questionAnswerOptionButtonWidth));
        }];
        self.wrongLabel = ({
            UILabel *label = [UILabel new];
            label.text = BJLLocalizedString(@"对");
            label.textColor = BJLTheme.viewTextColor;
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        [self.contentView addSubview:self.wrongLabel];
        [self.wrongLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerX.equalTo(self.optionButton);
            make.top.equalTo(self.optionButton.bjl_bottom).offset(5);
            make.bottom.equalTo(self.contentView);
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

- (void)optionButtonOnClick:(UIButton *)button {
    // 选中状态
    BOOL selected = self.selectedIconImageView.hidden;
    [self setOptionButtonSelected:selected];
    self.optionButton.selected = selected;

    // 回调
    if (self.optionSelectedCallback) {
        self.optionSelectedCallback(selected);
    }
}

- (void)setOptionButtonSelected:(BOOL)selected {
    self.selectedIconImageView.hidden = !selected;
}

- (void)updateContentWithOptionKey:(NSString *)optionKey isSelected:(BOOL)isSelected {
    [self.optionButton setTitle:optionKey forState:UIControlStateNormal];
    self.optionButton.selected = isSelected;
    [self setOptionButtonSelected:isSelected];
}

- (void)updateContentWithSelected:(BOOL)isSelected text:(NSString *)text {
    [self setOptionButtonSelected:isSelected];
    self.optionButton.selected = isSelected;
    self.wrongLabel.text = text;
}

- (void)updateContentWithOptionKey:(NSString *)optionKey isCorrect:(BOOL)isCorrect {
    [self.optionButton setTitle:optionKey forState:UIControlStateNormal];
    self.optionButton.layer.borderColor = isCorrect ? BJLTheme.brandColor.CGColor : BJLTheme.warningColor.CGColor;
    [self.optionButton bjl_setBackgroundColor:isCorrect ? BJLTheme.brandColor : BJLTheme.warningColor forState:UIControlStateNormal];
    [self.optionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)updateContentWithJudgOptionKey:(NSString *)optionKey isCorrect:(BOOL)isCorrect {
    self.wrongLabel.text = optionKey;

    [self.optionButton setImage:[UIImage bjl_imageNamed:isCorrect ? @"bjl_questionAnswer_right_select" : @"bjl_questionAnswer_right_warning"] forState:UIControlStateNormal];
    if ([self.reuseIdentifier isEqualToString:BJLQuestionAnswerOptionCollectionViewCellID_JudgeCell_wrong]) {
        [self.optionButton setImage:[UIImage bjl_imageNamed:isCorrect ? @"bjl_questionAnswer_wrong_select" : @"bjl_questionAnswer_wrong_warning"] forState:UIControlStateNormal];
    }
    self.optionButton.selected = NO;
}

@end
