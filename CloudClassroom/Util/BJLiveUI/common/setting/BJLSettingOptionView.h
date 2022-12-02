//
//  BJLSettingOptionView.h
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/10/15.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLSettingOptionViewType) {
    BJLSettingOptionViewType_switch, //类似switch的选择样式
    BJLSettingOptionViewType_button // 多个button选择的样式
};

@interface BJLSettingOptionView: UIView

@property (nonatomic, readonly) BJLSettingOptionViewType viewType;

- (instancetype)initWithLeftTitle:(NSString *)title viewType:(BJLSettingOptionViewType)type;

// BJLSettingOptionView_button , from right to left ,tag = 0,1,2...
- (void)addButtonActionWithTile:(NSString *)title acitonCallback:(nullable void (^)(NSInteger tag))acitonCallback;

// BJLSettingOptionView_button , from right to left ,tag = 0,1,2...
- (void)addCustomButtonView:(UIButton *)button;

// BJLSettingOptionView_button
- (void)updateButtonEnable:(BOOL)enable atIndex:(NSInteger)index;

// BJLSettingOptionView_switch , from left to right ,tag = 0,1,2...
- (void)addSwitchMenuWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSInteger)selectedIndex callback:(nullable void (^)(NSInteger tag))callback;

// BJLSettingOptionView_switch or BJLSettingOptionView_button
- (void)setEnable:(BOOL)enable;

- (void)updateSelectedIndex:(NSInteger)selectedIndex;

- (void)updateLeftTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
