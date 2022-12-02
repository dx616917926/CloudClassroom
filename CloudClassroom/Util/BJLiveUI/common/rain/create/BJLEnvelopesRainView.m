//
//  BJLCreateRainView.m
//  BJLiveUI
//
//  Created by xyp on 2021/1/8.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLEnvelopesRainView.h"
#import "BJLAppearance.h"
#import "BJLTheme.h"
#import "UIView+panGesture.h"

@interface BJLEnvelopesRainView () <UITextFieldDelegate>

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) UIButton *titleButton, *closeButton, *startButton;
@property (nonatomic) UIView *lineView;
@property (nonatomic) UILabel *countLabel, *countTipLabel, *timeLabel, *scoreLabel, *scoreTipLabel;
@property (nonatomic, readwrite) UITextField *countTextField, *scoreTextField;
// 抢红包时长的button的superView
@property (nonatomic) UIStackView *duratioStackView;
@property (nonatomic) NSArray<NSString *> *duratioArray;
@property (nonatomic) NSMutableArray<UIButton *> *duratioButtonArrM;

@property (nonatomic) BOOL isPortrait;

// 抢红包时长
@property (nonatomic) NSInteger rainDuration;

@property (nonatomic) UIImageView *resultImageView;
@property (nonatomic) UILabel *resultTipLabel;
@property (nonatomic) UIButton *oneMoreButton, *resultButton;

@end

@implementation BJLEnvelopesRainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;
        self.backgroundColor = BJLTheme.windowBackgroundColor;
        [self makeCommonView];
    }
    return self;
}

+ (instancetype)createEnvelopesRainViewWithRoom:(BJLRoom *)room {
    BJLEnvelopesRainView *rainView = [[BJLEnvelopesRainView alloc] initWithFrame:CGRectZero];
    rainView.room = room;
    [rainView makeCreteRainView];
    [rainView observerMaxCount];
    return rainView;
}

+ (instancetype)resultEnvelopesRainViewIsTeacher:(BOOL)isTeacher {
    BJLEnvelopesRainView *rainView = [[BJLEnvelopesRainView alloc] initWithFrame:CGRectZero];
    [rainView makeRainResultViewIsTeacher:isTeacher];
    return rainView;
}

- (void)dealloc {
    [self bjl_stopAllKeyValueObserving];
}

#pragma mark - action

- (void)closeAction {
    if (self.closeCallback) {
        self.closeCallback();
    }
}

- (void)timeButtonAction:(UIButton *)button {
    NSUInteger index = [self.duratioButtonArrM indexOfObject:button];
    if (index == NSNotFound) {
        return;
    }
    for (UIButton *btn in self.duratioButtonArrM) {
        btn.selected = NO;
    }
    button.selected = YES;
    if (self.duratioArray.count > index) {
        self.rainDuration = [self.duratioArray objectAtIndex:index].integerValue;
    }

    for (UIButton *btn in self.duratioButtonArrM) {
        if (btn.selected) {
            btn.layer.borderColor = [UIColor clearColor].CGColor;
            btn.layer.borderWidth = 0.0;
            btn.backgroundColor = BJLTheme.brandColor;
        }
        else {
            btn.layer.borderColor = BJLTheme.separateLineColor.CGColor;
            btn.layer.borderWidth = 1.0;
            btn.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)startAction {
    if (self.createRainCallback) {
        self.createRainCallback(self.countTextField.text.integerValue, self.scoreTextField.text.integerValue, self.rainDuration);
    }
}

- (void)oneMoreAction {
    if (self.onceMoreCallback) {
        self.onceMoreCallback();
    }
}

- (void)resultAction {
    if (self.showResultCallback) {
        self.showResultCallback(self);
    }
}

#pragma mark - make view

- (void)makeCommonView {
    self.titleButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.userInteractionEnabled = NO;
        [button setTitle:BJLLocalizedString(@"红包雨") forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        button;
    });

    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        button;
    });

    self.lineView = [UIView new];
    self.lineView.backgroundColor = BJLTheme.separateLineColor;

    [self addSubview:self.titleButton];
    [self addSubview:self.closeButton];
    [self addSubview:self.lineView];

    [self.titleButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(4.0);
        make.height.equalTo(@24);
        make.width.equalTo(@80);
    }];
    [self.closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self).offset(-6);
        make.centerY.equalTo(self.titleButton);
        make.height.width.equalTo(@24);
    }];
    [self.lineView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.equalTo(@1);
        make.left.right.equalTo(self);
        make.top.equalTo(self.titleButton.bjl_bottom).offset(4.0);
    }];
}

- (void)makeCreteRainView {
    self.countLabel = [self labelWithText:BJLLocalizedString(@"红包个数") textAlignment:NSTextAlignmentLeft textColor:BJLTheme.viewTextColor];
    self.countTipLabel = [self labelWithText:[self recomendPackageCountString] textAlignment:NSTextAlignmentRight textColor:BJLTheme.brandColor];
    self.timeLabel = [self labelWithText:BJLLocalizedString(@"抢红包时长") textAlignment:NSTextAlignmentLeft textColor:BJLTheme.viewTextColor];
    self.scoreLabel = [self labelWithText:BJLLocalizedString(@"学分数") textAlignment:NSTextAlignmentLeft textColor:BJLTheme.viewTextColor];
    self.scoreTipLabel = [self labelWithText:[self recomendScoreString] textAlignment:NSTextAlignmentRight textColor:BJLTheme.brandColor];

    NSString *rangeString = [NSString stringWithFormat:@"1~%li", (long)self.room.featureConfig.maxRedPackageCount];
    self.countTextField = [self textFieldWithPlaceholder:rangeString];
    self.scoreTextField = [self textFieldWithPlaceholder:[NSString stringWithFormat:BJLLocalizedString(@"%@并且不小于红包个数"), rangeString]];

    self.duratioArray = @[@"5", @"10", @"15", @"30"];
    self.duratioButtonArrM = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        NSString *title = [NSString stringWithFormat:BJLLocalizedString(@"%@秒"), self.duratioArray[i]];
        UIButton *button = [self duratioButtonWithTitle:title];
        [self.duratioButtonArrM addObject:button];
    }
    // 默认选中15s
    [self.duratioButtonArrM[2] sendActionsForControlEvents:UIControlEventTouchUpInside];
    self.rainDuration = self.duratioArray[2].integerValue;
    self.duratioStackView = ({
        UIStackView *view = [[UIStackView alloc] initWithArrangedSubviews:self.duratioButtonArrM];
        view.distribution = UIStackViewDistributionFillEqually;
        view.alignment = UIStackViewAlignmentCenter;
        view.axis = UILayoutConstraintAxisHorizontal;
        view.spacing = 4.0;
        view;
    });

    self.startButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:BJLLocalizedString(@"开始抢红包") forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 4.0;
        [button bjl_setBackgroundImage:[UIImage bjl_imageWithColor:BJLTheme.subButtonBackgroundColor] forState:UIControlStateDisabled possibleStates:UIControlStateDisabled];
        [button bjl_setBackgroundImage:[UIImage bjl_imageWithColor:BJLTheme.brandColor] forState:UIControlStateNormal possibleStates:UIControlStateNormal];
        [button setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
        button;
    });

    [self addSubview:self.countLabel];
    [self addSubview:self.countTipLabel];
    [self addSubview:self.countTextField];
    [self addSubview:self.timeLabel];
    [self addSubview:self.duratioStackView];
    [self addSubview:self.scoreLabel];
    [self addSubview:self.scoreTipLabel];
    [self addSubview:self.scoreTextField];
    [self addSubview:self.startButton];

    CGFloat minSpace = 4.0;
    CGFloat midSpace = 8.0;
    CGFloat space = 10.0;
    CGFloat largeSpace = 16.0;
    CGFloat maxSpace = self.isPortrait ? 50.0 : 20.0;

    [self.countLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.lineView.bjl_bottom).offset(space);
        make.left.equalTo(self).offset(largeSpace);
        make.height.equalTo(@20);
    }];
    [self.countTipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self).offset(-largeSpace);
        make.centerY.height.equalTo(self.countLabel);
    }];
    [self.countTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.countLabel);
        make.right.equalTo(self.countTipLabel);
        make.top.equalTo(self.countLabel.bjl_bottom).offset(midSpace);
        make.height.equalTo(@32);
    }];
    [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.height.equalTo(self.countLabel);
        make.top.equalTo(self.countTextField.bjl_bottom).offset(midSpace);
    }];
    [self.duratioStackView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.timeLabel.bjl_bottom).offset(minSpace);
        make.left.equalTo(self.countLabel);
        make.right.equalTo(self.countTipLabel);
        make.height.equalTo(self.countTextField);
    }];
    [self.scoreLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.height.equalTo(self.countLabel);
        make.top.equalTo(self.duratioStackView.bjl_bottom).offset(midSpace);
    }];
    [self.scoreTipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.height.equalTo(self.scoreLabel);
        make.right.equalTo(self.countTipLabel);
    }];
    [self.scoreTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.height.equalTo(self.countTextField);
        make.top.equalTo(self.scoreLabel.bjl_bottom).offset(minSpace);
    }];
    [self.startButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.height.right.equalTo(self.countTextField);
        make.bottom.equalTo(self).offset(-maxSpace);
    }];
}

- (void)makeRainResultViewIsTeacher:(BOOL)isTeacher {
    self.resultImageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_envelope_result_img"]];
    self.resultTipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"时间已到，抢红包结束");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:16.0];
        label;
    });
    self.oneMoreButton = [self buttonWithTitle:BJLLocalizedString(@"再发一次") titleColor:BJLTheme.subButtonTextColor backgroundColor:BJLTheme.subButtonBackgroundColor];
    self.resultButton = [self buttonWithTitle:BJLLocalizedString(@"查看结果") titleColor:BJLTheme.buttonTextColor backgroundColor:BJLTheme.brandColor];
    [self.oneMoreButton addTarget:self action:@selector(oneMoreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.resultButton addTarget:self action:@selector(resultAction) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.resultImageView];
    [self addSubview:self.resultTipLabel];
    [self addSubview:self.oneMoreButton];
    [self addSubview:self.resultButton];

    CGFloat minSpace = 14.0;
    CGFloat midSpace = 20.0;
    CGFloat maxSpace = self.isPortrait ? 80.0 : 30.0;

    [self.resultImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.bjl_centerY);
        make.height.equalTo(@66);
        make.width.equalTo(@56);
        make.centerX.equalTo(self);
    }];
    [self.resultTipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.resultImageView.bjl_bottom).offset(midSpace);
    }];

    [self.resultButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.equalTo(@32);
        make.bottom.equalTo(self).offset(self.isPortrait ? -60.0 : -midSpace);
        if (isTeacher) {
            make.left.equalTo(self.bjl_centerX).offset(minSpace);
            make.right.equalTo(self).offset(-maxSpace);
        }
        else {
            make.left.equalTo(self).offset(midSpace);
            make.right.equalTo(self).offset(-midSpace);
        }
    }];

    if (isTeacher) {
        [self.oneMoreButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.bottom.top.height.equalTo(self.resultButton);
            make.right.equalTo(self.bjl_centerX).offset(-minSpace);
            make.left.equalTo(self).offset(maxSpace);
        }];
    }
}

#pragma mark -

- (NSString *)recomendPackageCountString {
    NSInteger userCount = self.room.onlineUsersVM.onlineUsersTotalCount;
    NSInteger maxRedPackageCount = self.room.featureConfig.maxRedPackageCount;
    NSInteger min = MIN(maxRedPackageCount, userCount * 5);
    NSInteger max = MIN(maxRedPackageCount, userCount * 20);
    if (0 == max) {
        return @"";
    }
    if (min == max) {
        return [NSString stringWithFormat:BJLLocalizedString(@"推荐红包数: %li"), (long)min];
    }
    else {
        return [NSString stringWithFormat:BJLLocalizedString(@"推荐红包数: %li~%li"), (long)min, (long)max];
    }
}

- (NSString *)recomendScoreString {
    NSInteger userCount = self.room.onlineUsersVM.onlineUsersTotalCount;
    NSInteger maxScore = self.room.featureConfig.maxRedPackageCount;
    NSInteger min = MIN(maxScore, userCount * 5);
    NSInteger max = MIN(maxScore, userCount * 20);
    if (0 == max) {
        return @"";
    }
    if (min == max) {
        return [NSString stringWithFormat:BJLLocalizedString(@"推荐学分数数: %ld"), (long)min];
    }
    else {
        return [NSString stringWithFormat:BJLLocalizedString(@"推荐学分数数: %li~%li"), (long)min, (long)max];
    }
}

#pragma mark - textField

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSInteger integer = [textField.text integerValue];
    // 过滤以0起始的string
    if (textField.text.length > 0
        && integer >= 0
        && [textField.text hasPrefix:@"0"]) {
        textField.text = [NSString stringWithFormat:@"%li", (long)integer];
    }

    [self checkStartButtonEnable];
}

- (void)textFieldTextChange:(UITextField *)textField {
    [self checkStartButtonEnable];
}

- (void)observerMaxCount {
    bjl_weakify(self);
    [self bjl_kvoMerge:@[
        BJLMakeProperty(self.countTextField, text),
        BJLMakeProperty(self.scoreTextField, text),
    ] observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        NSInteger count = [self.countTextField.text integerValue];
        NSInteger score = [self.scoreTextField.text integerValue];
        NSInteger maxRedPackageCount = self.room.featureConfig.maxRedPackageCount;
        if (count > maxRedPackageCount) {
            self.countTextField.text = [NSString stringWithFormat:@"%li", (long)maxRedPackageCount];
        }
        if (score > maxRedPackageCount) {
            self.scoreTextField.text = [NSString stringWithFormat:@"%li", (long)maxRedPackageCount];
        }
        [self checkStartButtonEnable];
    }];
}

- (void)checkStartButtonEnable {
    NSInteger count = [self.countTextField.text integerValue];
    NSInteger score = [self.scoreTextField.text integerValue];

    if (!self.countTextField.text.length
        || !self.scoreTextField.text.length
        || count < 1
        || score < 1
        || score < count
        || score > self.room.featureConfig.maxRedPackageCount
        || count > self.room.featureConfig.maxRedPackageCount) {
        self.startButton.enabled = NO;
    }
    else {
        self.startButton.enabled = YES;
    }
}

#pragma mark - util

- (UILabel *)labelWithText:(NSString *)text textAlignment:(NSTextAlignment)textAlignment textColor:(UIColor *)color {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = textAlignment;
    label.textColor = color;
    return label;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    textField.placeholder = placeholder;
    [textField setValue:BJLTheme.viewSubTextColor forKeyPath:@"placeholderLabel.textColor"];
    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.font = [UIFont systemFontOfSize:12.0];
    textField.textColor = BJLTheme.viewTextColor;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.borderWidth = 1.0;
    textField.layer.borderColor = BJLTheme.separateLineColor.CGColor;
    textField.layer.cornerRadius = 4.0;
    textField.layer.masksToBounds = YES;
    return textField;
}

- (UIButton *)duratioButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 4.0;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateSelected];
    [button setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateHighlighted];
    [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(timeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 4.0;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.backgroundColor = backgroundColor;
    return button;
}

@end
