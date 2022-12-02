//
//  BJLSettingCell.m
//  BJLiveUIBigClass
//
//  Created by 凡义 on 2021/9/18.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//
#import <BJLiveBase/NSObject+BJL_M9Dev.h>
#import "BJLAppearance.h"
#import "BJLSettingCell.h"

@interface BJLSettingCell ()

@property (nonatomic) UIButton *contentButton;

@end

@implementation BJLSettingCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
    self.contentButton = [UIButton new];
    self.contentButton.accessibilityIdentifier = BJLKeypath(self, contentButton);
    self.contentButton.layer.cornerRadius = 4;
    self.contentButton.layer.masksToBounds = YES;
    self.contentButton.userInteractionEnabled = NO;
    self.contentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.contentButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.contentButton bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
    [self.contentButton bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

    UIColor *highlightColor = BJLTheme.brandColor;
    UIColor *normalColor = [UIColor bjl_colorWithHex:0X9FA8B5 alpha:0.4];
    [self.contentButton bjl_setBackgroundColor:highlightColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
    [self.contentButton bjl_setBackgroundColor:normalColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [self.contentView addSubview:self.contentButton];
    [self.contentButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentButton.selected = selected;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentButton.selected = NO;
}

- (void)updateContentWithTitle:(NSString *)title selectd:(BOOL)isSelectd {
    self.contentButton.selected = isSelectd;
    [self.contentButton bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [self.contentButton bjl_setTitle:title forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
}

@end
