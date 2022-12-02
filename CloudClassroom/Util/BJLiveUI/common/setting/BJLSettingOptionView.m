//
//  BJLSettingOptionView.m
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/10/15.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLSettingOptionView.h"
#import <BJLiveBase/NSObject+BJL_M9Dev.h>
#import "BJLAppearance.h"

@interface BJLSettingOptionView ()

@property (nonatomic, readwrite) BJLSettingOptionViewType viewType;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *buttonContainerView;
@property (nonatomic) NSArray<UIButton *> *buttonArray;

@end

@implementation BJLSettingOptionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (instancetype)initWithLeftTitle:(NSString *)title viewType:(BJLSettingOptionViewType)type {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.viewType = type;
        [self makeSubviewsAndConstraints];
        self.titleLabel.text = title;
    }
    return self;
}

- (void)makeSubviewsAndConstraints {
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.numberOfLines = 1;
        [self addSubview:label];
        bjl_return label;
    });

    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.bottom.equalTo(self);
    }];
}

#pragma mark - button

- (void)addButtonActionWithTile:(NSString *)title acitonCallback:(nullable void (^)(NSInteger tag))acitonCallback {
    if (self.viewType != BJLSettingOptionViewType_button) {
        return;
    }

    UIButton *button = [UIButton new];
    button.layer.cornerRadius = 4.0;
    button.layer.masksToBounds = YES;
    button.tag = [self.buttonArray count];
    [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:button];
    [button bjl_addHandler:^(UIButton *_Nonnull button) {
        [button bjl_disableForSeconds:1.0];
        if (acitonCallback) {
            acitonCallback(button.tag);
        }
    }];

    UIButton *lastButton = self.buttonArray.lastObject;
    [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.titleLabel.bjl_centerY);
        if (lastButton) {
            make.right.equalTo(lastButton.bjl_left).offset(-8);
            make.size.equalTo(lastButton);
        }
        else {
            make.right.equalTo(self);
            make.size.equal.sizeOffset(CGSizeMake(60, 28));
        }
    }];

    NSMutableArray *buttonArray = [self.buttonArray mutableCopy];
    if (!buttonArray) {
        buttonArray = [NSMutableArray new];
    }
    [buttonArray addObject:button];
    self.buttonArray = [buttonArray copy];
}

- (void)addCustomButtonView:(UIButton *)button {
    if (self.viewType != BJLSettingOptionViewType_button) {
        return;
    }

    if (!button) {
        return;
    }

    [self addSubview:button];
    UIButton *lastButton = self.buttonArray.lastObject;
    [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.titleLabel.bjl_centerY);
        if (lastButton) {
            make.right.equalTo(lastButton.bjl_left).offset(-8);
        }
        else {
            make.right.equalTo(self);
        }
    }];

    NSMutableArray *buttonArray = [self.buttonArray mutableCopy];
    if (!buttonArray) {
        buttonArray = [NSMutableArray new];
    }
    [buttonArray addObject:button];
    self.buttonArray = [buttonArray copy];
}

#pragma mark - switch

- (void)addSwitchMenuWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSInteger)selectedIndex callback:(nullable void (^)(NSInteger tag))callback {
    if (self.viewType != BJLSettingOptionViewType_switch) {
        return;
    }

    UIColor *normalColor = [UIColor bjl_colorWithHex:0X9fa8b5 alpha:0.2];
    UIColor *selectedColor = BJLTheme.brandColor;

    CGFloat buttonWidth = 64.0;
    UIView *buttonContainerView = [UIView new];
    buttonContainerView.backgroundColor = normalColor;
    buttonContainerView.layer.cornerRadius = 4;
    buttonContainerView.layer.masksToBounds = YES;
    [self addSubview:buttonContainerView];

    [buttonContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.compressionResistance.hugging.required();
        make.left.greaterThanOrEqualTo(self.titleLabel);
        make.centerY.equalTo(self.titleLabel.bjl_centerY);
        make.right.equalTo(self);
        make.height.equalTo(@(28));
        make.width.equalTo(@([titles count] * buttonWidth));
    }];
    self.buttonContainerView = buttonContainerView;

    NSMutableArray *buttonArray = [self.buttonArray mutableCopy];
    if (!buttonArray) {
        buttonArray = [NSMutableArray new];
    }

    UIButton *lastButton = nil;
    for (NSInteger i = 0; i < [titles count]; i++) {
        NSString *title = [titles bjl_objectAtIndex:i];
        UIButton *button = [UIButton new];
        button.layer.cornerRadius = 4.0;
        button.layer.masksToBounds = YES;
        button.tag = i;
        [button bjl_setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setBackgroundColor:selectedColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button bjl_setBackgroundColor:selectedColor forState:UIControlStateSelected possibleStates:UIControlStateDisabled];

        [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateDisabled];

        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateSelected possibleStates:UIControlStateDisabled];
        [button bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitle:title forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        ;
        [buttonContainerView addSubview:button];

        [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            if (lastButton) {
                make.left.equalTo(lastButton.bjl_right);
                make.size.centerY.equalTo(lastButton);
            }
            else {
                make.left.centerY.equalTo(buttonContainerView);
                make.size.equal.sizeOffset(CGSizeMake(buttonWidth, 28));
            }
        }];

        if (selectedIndex == i) {
            button.selected = YES;
        }
        bjl_weakify(self);
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (button.selected) {
                return;
            }

            [self.buttonArray enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                [obj bjl_disableForSeconds:0.2];
            }];

            if (callback) {
                callback(button.tag);
            }
        }];
        [buttonArray addObject:button];
        lastButton = button;
    }
    self.buttonArray = [buttonArray copy];
}

- (void)setEnable:(BOOL)enable {
    self.userInteractionEnabled = enable;
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.alpha = enable ? 1 : 0.5;
    }];
}

- (void)updateButtonEnable:(BOOL)enable atIndex:(NSInteger)index {
    if (self.viewType != BJLSettingOptionViewType_button) {
        return;
    }

    if (!self.userInteractionEnabled) {
        [self setEnable:YES];
    }

    UIButton *button = [self.buttonArray bjl_objectAtIndex:index];
    button.enabled = enable;
    button.alpha = enable ? 1 : 0.5;
}

- (void)updateSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex >= [self.buttonArray count]) {
        return;
    }

    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.selected = NO;
    }];

    UIButton *button = [self.buttonArray bjl_objectAtIndex:selectedIndex];
    button.selected = YES;
}

- (void)updateLeftTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
