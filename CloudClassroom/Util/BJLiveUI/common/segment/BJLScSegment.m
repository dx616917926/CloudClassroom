//
//  BJLScSegment.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/23.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLScSegment.h"
#import "BJLScAppearance.h"

@interface BJLScSegment ()

@property (nonatomic) NSArray<NSString *> *items;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) NSMutableArray<UIButton *> *buttons;
@property (nonatomic) NSMutableArray<UILabel *> *redDots;
@property (nonatomic) BJLSegmentStyle style;

@end

@implementation BJLScSegment

- (instancetype)initWithItems:(NSArray<NSString *> *)items width:(CGFloat)width fontSize:(CGFloat)fontSize textColor:(nonnull UIColor *)textColor style:(BJLSegmentStyle)style {
    if (self = [super initWithFrame:CGRectZero]) {
        self.items = items;
        self.width = width;
        self.fontSize = fontSize > 0 ? fontSize : 14.0;
        self.textColor = textColor;
        self.backgroundColor = BJLTheme.windowBackgroundColor;
        self.buttons = [NSMutableArray new];
        self.redDots = [NSMutableArray new];
        self.style = style;
        [self makeSubviewsAndConstraints];
    }
    return self;
}

- (void)makeSubviewsAndConstraints {
    for (NSString *title in self.items) {
        UILabel *redDot = [self makeRedDot];
        UIButton *button;

        switch (self.style) {
            case BJLSegmentStyleUnderline: {
                button = [self makeSegmentButtonWithTitleUnderLine:title redDot:redDot];
            } break;

            case BJLSegmentStyleRoundCorner: {
                button = [self makeSegmentButtonWithTitleRoundCorner:title redDot:redDot];
            } break;

            default: {
                button = [self makeSegmentButtonWithTitleUnderLine:title redDot:redDot];
            } break;
        }

        [self.redDots bjl_addObject:redDot];
        [self.buttons bjl_addObject:button];
    }

    UIButton *last = nil;
    for (UIButton *button in [self.buttons copy]) {
        [self addSubview:button];
        [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            if (self.width > 0) {
                make.width.equalTo(@(self.width));
            }
            else {
                make.width.equalTo(self.bjl_width).multipliedBy(1.0 / self.buttons.count);
            }
            make.top.bottom.equalTo(self);
            make.left.equalTo(last ? last.bjl_right : self.bjl_left);
        }];
        last = button;
    }
    self.selectedIndex = 0;
}

- (void)changeSelectedIndex:(UIButton *)button {
    NSInteger index = [self.buttons indexOfObject:button];
    if (index != NSNotFound) {
        if (self.selectedIndex != index) {
            self.selectedIndex = index;
        }
    }
}

#pragma mark - setter

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    UILabel *redDot = [self.redDots bjl_objectAtIndex:selectedIndex];
    if (!redDot.hidden) {
        redDot.hidden = YES;
    }
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = [self.buttons bjl_objectAtIndex:i];
        button.selected = (selectedIndex == i);
    }
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSInteger)index {
    UIButton *button = [self.buttons bjl_objectAtIndex:index];
    if (button) {
        [button bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    }
}

- (void)setImage:(nullable UIImage *)image forSegmentAtIndex:(NSInteger)index {
    UIButton *button = [self.buttons bjl_objectAtIndex:index];
    UILabel *redDot = [self.redDots bjl_objectAtIndex:index];
    if (button) {
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 16.0);
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 16.0, 0.0, 8.0);
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button bjl_setImage:image forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

        CGFloat redDotWidth = 8.0;
        redDot.layer.cornerRadius = redDotWidth / 2.0;
        [redDot bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(button).offset(8.0);
            make.left.equalTo(button.imageView.bjl_right).offset(-4.0);
            make.height.width.equalTo(@(redDotWidth));
        }];
    }
}

- (void)updateRedDotAtIndex:(NSInteger)index count:(NSInteger)count ignoreCount:(BOOL)ignoreCount {
    if (index == self.selectedIndex) {
        return;
    }

    UILabel *redDot = [self.redDots bjl_objectAtIndex:index];
    if (redDot) {
        redDot.hidden = (count <= 0);
        redDot.text = ignoreCount ? nil : (count > 99 ? @"···" : [NSString stringWithFormat:@"%td", count]);
        CGFloat redDotWidth = ignoreCount ? 8.0 : 14.0;
        redDot.layer.cornerRadius = redDotWidth / 2.0;
        [redDot bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.height.width.equalTo(@(redDotWidth));
        }];

        UIButton *button = [self.buttons bjl_objectAtIndex:index];
        if (button) {
            [self bringSubviewToFront:button];
        }
    }
}

#pragma mark - wheel
- (UIButton *)makeSegmentButtonWithTitleRoundCorner:(NSString *)title redDot:(UIView *)redDot {
    UIButton *button = [UIButton new];
    button.accessibilityIdentifier = title;
    //    button.clipsToBounds = YES;
    button.backgroundColor = [UIColor clearColor];
    button.layer.cornerRadius = 3;
    button.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
    button.titleLabel.textAlignment = self.items.count > 1 ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    [button bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button bjl_setTitleColor:self.textColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

    if (self.items.count > 1) {
        [button bjl_setTitleColor:UIColor.whiteColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button addTarget:self action:@selector(changeSelectedIndex:) forControlEvents:UIControlEventTouchUpInside];

        //seperator
        [self bjl_kvo:BJLMakeProperty(button, selected)
             observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 button.backgroundColor = button.isSelected ? BJLTheme.brandColor : [UIColor clearColor];
                 return YES;
             }];

        // redDot
        [button addSubview:redDot];
        [redDot bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(button).offset(BJLScOnePixel);
            make.left.equalTo(button.titleLabel.bjl_right);
            make.height.width.equalTo(@(14.0));
        }];
    }
    else {
        button.userInteractionEnabled = NO;
        [button addSubview:redDot];
    }

    return button;
}

- (UIButton *)makeSegmentButtonWithTitleUnderLine:(NSString *)title redDot:(UIView *)redDot {
    UIButton *button = [UIButton new];
    button.accessibilityIdentifier = title;
    //    button.clipsToBounds = YES;
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
    button.titleLabel.textAlignment = self.items.count > 1 ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    [button bjl_setTitle:title forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button bjl_setTitleColor:self.textColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

    if (self.items.count > 1) {
        [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button addTarget:self action:@selector(changeSelectedIndex:) forControlEvents:UIControlEventTouchUpInside];

        //seperator
        UIView *view = [UIView new];
        [button addSubview:view];
        [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerX.equalTo(button);
            make.bottom.equalTo(button);
            make.width.equalTo(@24.0);
            make.height.equalTo(@2);
        }];
        bjl_weakify(button, view);
        [self bjl_kvo:BJLMakeProperty(button, selected)
             observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(button, view);
                 view.backgroundColor = button.isSelected ? BJLTheme.brandColor : [UIColor clearColor];
                 return YES;
             }];

        // redDot
        [button addSubview:redDot];
        [redDot bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(button).offset(BJLScOnePixel);
            make.left.equalTo(button.titleLabel.bjl_right);
            make.height.width.equalTo(@(14.0));
        }];
    }
    else {
        button.userInteractionEnabled = NO;
        [button addSubview:redDot];
    }

    return button;
}

- (UILabel *)makeRedDot {
    UILabel *redDot = [UILabel new];
    redDot.hidden = YES;
    redDot.layer.masksToBounds = YES;
    redDot.layer.cornerRadius = 7.0;
    redDot.backgroundColor = BJLTheme.warningColor;
    redDot.textColor = [UIColor whiteColor];
    redDot.textAlignment = NSTextAlignmentCenter;
    redDot.adjustsFontSizeToFitWidth = YES;
    redDot.font = [UIFont systemFontOfSize:10.0];
    return redDot;
}

@end