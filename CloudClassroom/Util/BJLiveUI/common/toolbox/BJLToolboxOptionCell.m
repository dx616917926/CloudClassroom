//
//  BJLToolboxOptionCell.m
//  BJLiveUI
//
//  Created by HuangJie on 2018/10/29.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLToolboxOptionCell.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLToolboxOptionCell ()

@property (nonatomic) BJLCornerImageButton *optionButton;

@end

@implementation BJLToolboxOptionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - subviews

- (void)setupSubviews {
    self.optionButton = ({
        BJLCornerImageButton *button = [BJLCornerImageButton new];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = BJLAppearance.toolboxCornerRadius;
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.toolButtonTitleColor forState:UIControlStateSelected];

        button.selectedColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        button.normalColor = [UIColor clearColor];
        button.backgroundSize = CGSizeMake(28, 28);
        button.backgroundCornerRadius = BJLAppearance.toolboxCornerRadius;

        bjl_weakify(self);
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.selectCallback) {
                self.selectCallback(!button.selected);
            }
        }];
        button;
    });
    [self.contentView addSubview:self.optionButton];
    [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - public

- (void)updateBackgroundIcon:(UIImage *)icon
                selectedIcon:(UIImage *)selectedIcon
                 description:(NSString *_Nullable)description
                  isSelected:(BOOL)selected {
    [self updateBackgroundIcon:icon selectedIcon:selectedIcon backgroundColor:nil description:description isSelected:selected];
}

// 目前仅用于字体按钮
- (void)updateBackgroundIcon:(UIImage *)icon
                selectedIcon:(UIImage *)selectedIcon
             backgroundColor:(nullable UIColor *)backgroundColor
                 description:(NSString *_Nullable)description
                  isSelected:(BOOL)selected {
    if (backgroundColor) {
        self.optionButton.backgroundColor = backgroundColor;
    }
    self.optionButton.selectedColor = [UIColor clearColor];
    [self.optionButton setBackgroundImage:icon forState:UIControlStateNormal];
    [self.optionButton setBackgroundImage:selectedIcon forState:UIControlStateSelected];
    [self.optionButton setTitle:description forState:UIControlStateNormal];
    self.optionButton.titleEdgeInsets = UIEdgeInsetsMake(0, -BJLAppearance.toolboxDrawFontIconSize / 2.0, 0, BJLAppearance.toolboxDrawFontIconSize / 2.0);
    self.optionButton.titleLabel.font = [UIFont systemFontOfSize:BJLAppearance.toolboxDrawFontSize];
    self.optionButton.selected = selected;
}

- (void)updateContentWithOptionIcon:(UIImage *)icon
                       selectedIcon:(UIImage *_Nullable)selectedIcon
                        description:(NSString *_Nullable)description
                         isSelected:(BOOL)selected {
    // 如果要显示边框就不要显示背景色
    if (self.showSelectBorder) {
        self.optionButton.selectedColor = [UIColor clearColor];
    }

    [self.optionButton setImage:icon forState:UIControlStateNormal];
    [self.optionButton setImage:selectedIcon forState:UIControlStateSelected];
    [self.optionButton setTitle:description forState:UIControlStateNormal];
    self.optionButton.selected = selected;

    if (self.showSelectBorder) {
        UIColor *borderColor = selected ? [UIColor whiteColor] : [UIColor clearColor];
        CGFloat borderWidth = selected ? 2.0 : 0.0;
        self.optionButton.layer.borderColor = borderColor.CGColor;
        self.optionButton.layer.borderWidth = borderWidth;
    }
}

@end

NS_ASSUME_NONNULL_END
