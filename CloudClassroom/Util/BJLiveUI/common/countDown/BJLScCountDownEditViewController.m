//
//  BJLScCountDownEditViewController.m
//  BJLiveUI
//
//  Created by 凡义 on 2020/3/26.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BJLScCountDownEditViewController.h"
#import "BJLScAppearance.h"
#import "UIView+panGesture.h"

@interface BJLScCountDownEditViewController () <UITextFieldDelegate>

@property (nonatomic, readonly, weak) BJLRoom *room;
@property (nonatomic) BOOL isDecrease;
@property (nonatomic) BOOL shouldPause;
@property (nonatomic) NSInteger totalTime;
@property (nonatomic) NSInteger currentShowCountDownTime; // 当前显示的计数值
@property (nonatomic) NSTimer *countDownTimer;

@property (nonatomic) UIView *topContainerView;
@property (nonatomic) UIButton *decreaseButton, *increaseButton;
@property (nonatomic) UIButton *publishButton, *stopButton;
@property (nonatomic) UITextField *minuteTextField, *minuteTextFieldTwo, *secondTextField, *secondTextFieldTwo;

@property (nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation BJLScCountDownEditViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
    }
    return self;
}

- (void)updateTimerWithTotalTime:(NSInteger)time
            currentCountDownTime:(NSInteger)currentCountDownTime
                      isDecrease:(BOOL)isDecrease
                     shouldPause:(BOOL)shouldPause {
    self.isDecrease = isDecrease;
    self.totalTime = time;
    self.currentShowCountDownTime = isDecrease ? currentCountDownTime : MAX(0, (time - currentCountDownTime));
    self.shouldPause = shouldPause;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;

    [self makeSubviews];
    [self updateTimerCountDownTypeWithDecrease:self.isDecrease];
    if (self.currentShowCountDownTime > 0) {
        [self updateTimerDuration:self.totalTime];
        if (!self.shouldPause) {
            [self startCountDownTimer];
        }
        else {
            [self pauseCountDownTimer];
        }
    }
    else {
        [self initialTimerDuration];
    }

    bjl_weakify(self);
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        [self hideKeyBoard];
    }];
    [self.view addGestureRecognizer:tap];
    [self makeObserving];
}

- (void)dealloc {
    [self stopTimer];
    self.minuteTextField.delegate = nil;
    self.minuteTextFieldTwo.delegate = nil;
    self.secondTextField.delegate = nil;
    self.secondTextFieldTwo.delegate = nil;

    [self stopAudio];
}

- (void)makeObserving {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveTimerWithTotalTime:countDownTime:isDecrease:)
             observer:(BJLMethodObserver) ^ BOOL(NSInteger totalTime, NSInteger countDownTime, BOOL isDecrease) {
                 bjl_strongify(self);
                 self.currentShowCountDownTime = isDecrease ? countDownTime : MAX(0, (totalTime - countDownTime));
                 self.totalTime = totalTime;
                 self.isDecrease = isDecrease;

                 [self startCountDownTimer];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceivePauseTimerWithTotalTime:leftCountDownTime:isDecrease:) observer:(BJLMethodObserver) ^ BOOL(NSInteger totalTime, NSInteger countDownTime, BOOL isDecrease) {
        bjl_strongify(self);
        [self pauseCountDownTimer];
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveStopTimer) observer:^BOOL {
        bjl_strongify(self);
        [self stopCountDownTimer];
        return YES;
    }];

    [self bjl_kvo:BJLMakeProperty(self.publishButton.titleLabel, text) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self) if (iPhone) {
            [self updatePhoneConstraints];
        }
        else {
            [self updatePadConstraints];
        }
        return YES;
    }];
}

#pragma mark - UI

- (void)makeSubviews {
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    [self makeTopView];

    self.decreaseButton = [self buttonWithTitle:BJLLocalizedString(@"倒计时")];
    [self.decreaseButton addTarget:self action:@selector(decreaseTimer) forControlEvents:UIControlEventTouchUpInside];
    self.increaseButton = [self buttonWithTitle:BJLLocalizedString(@"正计时")];
    [self.increaseButton addTarget:self action:@selector(increaseTimer) forControlEvents:UIControlEventTouchUpInside];
    self.minuteTextField = [self makeTextField];
    self.minuteTextFieldTwo = [self makeTextField];
    self.secondTextField = [self makeTextField];
    self.secondTextFieldTwo = [self makeTextField];

    [self.view addSubview:self.decreaseButton];
    [self.view addSubview:self.increaseButton];

    [self.view addSubview:self.minuteTextField];
    [self.view addSubview:self.minuteTextFieldTwo];
    [self.view addSubview:self.secondTextField];
    [self.view addSubview:self.secondTextFieldTwo];
    [self.view addSubview:self.stopButton];
    [self.view addSubview:self.publishButton];

    if (iPhone) {
        [self makePhoneSubviewsConstraints];
    }
    else {
        [self makePadSubviewsConstraints];
    }
}

- (void)makeTopView {
    self.topContainerView = [UIView new];

    UILabel *label = [UILabel new];
    label.text = BJLLocalizedString(@"计时器");
    label.textColor = BJLTheme.viewTextColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:14];
    [self.topContainerView addSubview:label];
    [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.topContainerView).offset(10);
        make.centerY.equalTo(self.topContainerView);
        make.right.lessThanOrEqualTo(self.topContainerView);
    }];

    UIButton *closeButton = [UIButton new];
    [closeButton setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
    [self.topContainerView addSubview:closeButton];
    [closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.topContainerView).offset(-5);
        make.centerY.equalTo(self.topContainerView);
    }];

    UIView *line = [UIView new];
    line.backgroundColor = BJLTheme.separateLineColor;
    [self.topContainerView addSubview:line];
    [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.topContainerView);
        make.height.equalTo(@(BJLScOnePixel));
    }];

    [self.view addSubview:self.topContainerView];
    [self.topContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.height.equalTo(@(30));
    }];
}

- (void)makePhoneSubviewsConstraints {
    UILabel *gapLabel = [self labelWithTitle:@":"];
    gapLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:gapLabel];

    [self.increaseButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.topContainerView.bjl_bottom).offset(14);
        make.left.equalTo(self.secondTextField);
        make.right.equalTo(self.secondTextFieldTwo);
        make.height.equalTo(@(32));
    }];
    [self.decreaseButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.increaseButton);
        make.left.equalTo(self.minuteTextField);
        make.size.equalTo(self.increaseButton);
    }];

    [self.minuteTextFieldTwo bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(gapLabel.bjl_left).offset(-6);
        make.top.equalTo(self.decreaseButton.bjl_bottom).offset(12);
        make.height.equalTo(@72);
        make.width.equalTo(@48);
    }];

    [self.minuteTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.minuteTextFieldTwo.bjl_left).offset(-16);
        make.top.equalTo(self.minuteTextFieldTwo);
        make.height.width.equalTo(self.minuteTextFieldTwo);
    }];

    [gapLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.minuteTextField);
        make.width.equalTo(@24);
        make.height.equalTo(@48);
    }];

    [self.secondTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(gapLabel.bjl_right).offset(6);
        make.top.equalTo(self.minuteTextField);
        make.height.width.equalTo(self.minuteTextField);
    }];

    [self.secondTextFieldTwo bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.secondTextField.bjl_right).offset(16);
        make.top.equalTo(self.secondTextField);
        make.width.height.equalTo(self.secondTextField);
    }];
}

- (void)makePadSubviewsConstraints {
    UILabel *gapLabel = [self labelWithTitle:@":"];
    gapLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:gapLabel];

    [self.increaseButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.topContainerView.bjl_bottom).offset(22);
        make.right.equalTo(self.secondTextFieldTwo);
        make.height.equalTo(@(32));
        make.width.equalTo(@(120));
    }];
    [self.decreaseButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.increaseButton);
        make.left.equalTo(self.minuteTextField);
        make.size.equalTo(self.increaseButton);
    }];

    [self.minuteTextFieldTwo bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(gapLabel.bjl_left).offset(-6);
        make.top.equalTo(self.decreaseButton.bjl_bottom).offset(31);
        make.height.equalTo(@100);
        make.width.equalTo(@51);
    }];

    [self.minuteTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.minuteTextFieldTwo.bjl_left).offset(-16);
        make.top.equalTo(self.minuteTextFieldTwo);
        make.height.width.equalTo(self.minuteTextFieldTwo);
    }];

    [gapLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.minuteTextField);
        make.width.equalTo(@40);
        make.height.equalTo(@100);
    }];

    [self.secondTextField bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(gapLabel.bjl_right).offset(6);
        make.top.equalTo(self.minuteTextField);
        make.height.width.equalTo(self.minuteTextField);
    }];

    [self.secondTextFieldTwo bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.secondTextField.bjl_right).offset(16);
        make.top.equalTo(self.secondTextField);
        make.width.height.equalTo(self.secondTextField);
    }];
}

- (void)updatePhoneConstraints {
    BOOL isPortrait = UIScreen.mainScreen.bounds.size.height > UIScreen.mainScreen.bounds.size.width;

    if ([self.publishButton.titleLabel.text isEqualToString:@"开始计时"]) {
        self.stopButton.hidden = YES;
        [self.publishButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerX.equalTo(self.view);
            if (isPortrait) {
                make.top.equalTo(self.minuteTextField.bjl_bottom).offset(30.0);
                make.left.equalTo(self.minuteTextField);
                make.right.equalTo(self.secondTextFieldTwo);
            }
            else {
                make.bottom.lessThanOrEqualTo(self.view).offset(-5);
                make.size.equalTo(self.increaseButton);
            }
        }];
    }
    else {
        self.stopButton.hidden = NO;
        [self.publishButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            if (isPortrait) {
                make.top.equalTo(self.minuteTextField.bjl_bottom).offset(30.0);
            }
            else {
                make.bottom.lessThanOrEqualTo(self.view).offset(-5);
            }
            make.left.equalTo(self.increaseButton);
            make.size.equalTo(self.increaseButton);
        }];

        [self.stopButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.publishButton);
            make.right.equalTo(self.decreaseButton);
            make.size.equalTo(self.publishButton);
        }];
    }
}

- (void)updatePadConstraints {
    if ([self.publishButton.titleLabel.text isEqualToString:@"开始计时"]) {
        self.stopButton.hidden = YES;
        [self.publishButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.bottom.lessThanOrEqualTo(self.view).offset(-15);
            make.centerX.equalTo(self.view);
            make.size.equalTo(self.increaseButton);
        }];
    }
    else {
        self.stopButton.hidden = NO;
        [self.publishButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.bottom.lessThanOrEqualTo(self.view).offset(-15);
            make.left.equalTo(self.increaseButton);
            make.size.equalTo(self.increaseButton);
        }];

        [self.stopButton bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.publishButton);
            make.right.equalTo(self.decreaseButton);
            make.size.equalTo(self.publishButton);
        }];
    }
}

#pragma mark - timer

- (void)stopTimer {
    if (self.countDownTimer || [self.countDownTimer isValid]) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}

- (void)startTimer {
    [self stopTimer];

    bjl_weakify(self);
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        if (!self) {
            [timer invalidate];
            return;
        }

        // 计时结束
        if ((self.currentShowCountDownTime <= 0 && self.isDecrease)
            || (self.currentShowCountDownTime >= self.totalTime && !self.isDecrease)) {
            [timer invalidate];
            [self stopCountDownTimer];

            // 倒计时结束, 播放铃声
            [self playAudio];
            return;
        }

        if (self.isDecrease) {
            self.currentShowCountDownTime--;
        }
        else {
            self.currentShowCountDownTime++;
        }
        [self updateTimerDuration:self.currentShowCountDownTime];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

#pragma mark - action
- (BOOL)keyboardDidShow {
    if (self.minuteTextField.isFirstResponder || self.minuteTextFieldTwo.isFirstResponder
        || self.secondTextField.isFirstResponder || self.secondTextFieldTwo.isFirstResponder) {
        [self hideKeyBoard];
        return NO;
    }
    return YES;
}

- (void)closeWindow {
    if (self.closeCallback) {
        self.closeCallback();
    }
}

- (void)updateUserInteractive:(BOOL)enable {
    self.decreaseButton.userInteractionEnabled = enable;
    self.increaseButton.userInteractionEnabled = enable;
    self.minuteTextField.userInteractionEnabled = enable;
    self.secondTextField.userInteractionEnabled = enable;
    self.minuteTextFieldTwo.userInteractionEnabled = enable;
    self.secondTextFieldTwo.userInteractionEnabled = enable;
}

- (void)startCountDownTimer {
    self.publishButton.selected = YES;
    [self updateUserInteractive:NO];
    [self startTimer];
}

- (void)pauseCountDownTimer {
    self.publishButton.selected = NO;
    [self.publishButton bjl_setTitle:BJLLocalizedString(@"继续") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

    [self stopTimer];
    [self updateUserInteractive:NO];
}

- (void)stopCountDownTimer {
    self.publishButton.selected = NO;
    [self.publishButton bjl_setTitle:BJLLocalizedString(@"开始计时") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

    [self stopTimer];
    [self updateUserInteractive:YES];
    [self initialTimerDuration];
}

- (void)decreaseTimer {
    self.decreaseButton.layer.borderColor = BJLTheme.brandColor.CGColor;
    self.increaseButton.layer.borderColor = BJLTheme.buttonNormalBackgroundColor.CGColor;
    [self updateTimerCountDownTypeWithDecrease:YES];
    [self initialTimerDuration];
}

- (void)increaseTimer {
    self.decreaseButton.layer.borderColor = BJLTheme.buttonNormalBackgroundColor.CGColor;
    self.increaseButton.layer.borderColor = BJLTheme.brandColor.CGColor;
    [self updateTimerCountDownTypeWithDecrease:NO];
    [self initialTimerDuration];
}

- (void)updateTimerCountDownTypeWithDecrease:(BOOL)isDecrease {
    self.isDecrease = isDecrease;
    self.decreaseButton.selected = isDecrease;
    self.increaseButton.selected = !isDecrease;
    [self hideKeyBoard];
}

- (void)initialTimerDuration {
    self.currentShowCountDownTime = self.isDecrease ? self.totalTime : 0;
    [self updateTimerDuration:self.totalTime];
}

- (void)updateTimerDuration:(NSInteger)time {
    NSInteger minus = (time / 60) / 10;
    NSInteger minusTwo = (time / 60) - (minus * 10);
    NSInteger second = (time % 60) / 10;
    NSInteger secondTwo = (time % 60) - (second * 10);
    self.minuteTextField.text = [NSString stringWithFormat:@"%ld", (long)minus];
    self.minuteTextFieldTwo.text = [NSString stringWithFormat:@"%ld", (long)minusTwo];
    self.secondTextField.text = [NSString stringWithFormat:@"%ld", (long)second];
    self.secondTextFieldTwo.text = [NSString stringWithFormat:@"%ld", (long)secondTwo];
}

- (void)hideKeyBoard {
    if ([self.minuteTextField isFirstResponder]) {
        [self.minuteTextField resignFirstResponder];
    }
    if ([self.secondTextField isFirstResponder]) {
        [self.secondTextField resignFirstResponder];
    }
    if ([self.minuteTextFieldTwo isFirstResponder]) {
        [self.minuteTextFieldTwo resignFirstResponder];
    }
    if ([self.secondTextFieldTwo isFirstResponder]) {
        [self.secondTextFieldTwo resignFirstResponder];
    }
}

- (void)requestStopTimer {
    bjl_returnIfRobot(1);
    [self hideKeyBoard];
    BJLError *error = [self.room.roomVM requestStopTimer];
    if (error) {
        [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
    }
}

- (void)requestStartOrPauseTimer {
    bjl_returnIfRobot(1);
    [self hideKeyBoard];
    [self updateTotalTime];
    NSInteger leftCountDownTime = self.isDecrease ? self.currentShowCountDownTime : (self.totalTime - self.currentShowCountDownTime);

    if (self.publishButton.selected) {
        BJLError *error = [self.room.roomVM requestPauseTimerWithTotalTime:self.totalTime
                                                         leftCountDownTime:leftCountDownTime
                                                                isDecrease:self.isDecrease];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        else {
            if (self.closeCallback) {
                self.closeCallback();
            }
        }
    }
    else {
        if ([self.publishButton.titleLabel.text isEqualToString:@"开始计时"]) {
            leftCountDownTime = self.totalTime;
        }
        if (self.totalTime <= 0) {
            if (self.isDecrease) {
                [self showProgressHUDWithText:BJLLocalizedString(@"请先设置倒计时时间")];
            }
            else {
                [self showProgressHUDWithText:BJLLocalizedString(@"请先设置正计时时间")];
            }
            return;
        }
        BJLError *error = [self.room.roomVM requestPublishTimerWithTotalTime:self.totalTime
                                                               countDownTime:leftCountDownTime
                                                                  isDecrease:self.isDecrease];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        else {
            if (self.closeCallback) {
                self.closeCallback();
            }
        }
    }
}

#pragma mark - wheel

- (UILabel *)labelWithTitle:(NSString *)string {
    UILabel *label = [UILabel new];
    label.textColor = BJLTheme.viewTextColor;
    label.font = [UIFont systemFontOfSize:48];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = string;
    return label;
}

- (UIButton *)buttonWithTitle:(NSString *)string {
    UIButton *button = [UIButton new];
    [button setTitle:string forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = BJLScOnePixel;
    button.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;

    [button bjl_setBackgroundImage:[UIImage bjl_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button bjl_setTitleColor:BJLTheme.buttonNormalBackgroundColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button setImage:[UIImage bjl_imageNamed:@"bjl_button_unselected"] forState:UIControlStateNormal];

    [button bjl_setBackgroundImage:[UIImage bjl_imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
    [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
    [button setImage:[UIImage bjl_imageNamed:@"bjl_button_selected"] forState:UIControlStateSelected];

    button.titleEdgeInsets = UIEdgeInsetsMake(9, 30, 9, 25);
    return button;
}

- (UIButton *)publishButton {
    if (!_publishButton) {
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = BJLTheme.brandColor;
        button.layer.cornerRadius = 4.0;
        // if self.doneButton.selected then save
        // otherwise show valid error
        [button bjl_setTitle:BJLLocalizedString(@"开始计时") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitle:BJLLocalizedString(@"暂停") forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];

        _publishButton = button;
        [_publishButton addTarget:self action:@selector(requestStartOrPauseTimer) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishButton;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = BJLTheme.subButtonBackgroundColor;
        button.layer.cornerRadius = 4.0;
        button.layer.borderWidth = BJLScOnePixel;
        button.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
        // if self.doneButton.selected then save
        // otherwise show valid error
        [button bjl_setTitle:BJLLocalizedString(@"结束计时") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setTitleColor:BJLTheme.subButtonTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        _stopButton = button;
        [_stopButton addTarget:self action:@selector(requestStopTimer) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}

- (UITextField *)makeTextField {
    UITextField *textField = [UITextField new];
    textField.font = [UIFont systemFontOfSize:48];
    textField.textColor = BJLTheme.viewTextColor;
    textField.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.1];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.layer.cornerRadius = 8;
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = BJLScOnePixel;
    textField.layer.borderColor = BJLTheme.buttonBorderColor.CGColor;
    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.returnKeyType = UIReturnKeyDone;
    return textField;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateTotalTime];
    [self initialTimerDuration];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (![self isValidDuration:newString] || newString.length > 1) {
        return NO;
    }
    NSInteger totalTime = [self totalTimeWillUpdateWithTextField:textField updatedTextFieldTime:newString];
    //总时间的最大值要求为60分钟,即3600秒
    if (totalTime >= 0 && totalTime <= 3600) {
        return YES;
    }
    return NO;
}

- (NSInteger)totalTimeWillUpdateWithTextField:(UITextField *)textField updatedTextFieldTime:(NSString *)timeString {
    NSString *minuteString = [self.minuteTextField.text stringByAppendingString:self.minuteTextFieldTwo.text];
    NSString *secondString = [self.secondTextField.text stringByAppendingString:self.secondTextFieldTwo.text];
    if (textField == self.minuteTextField) {
        minuteString = [timeString stringByAppendingString:self.minuteTextFieldTwo.text];
    }
    else if (textField == self.minuteTextFieldTwo) {
        minuteString = [self.minuteTextField.text stringByAppendingString:timeString];
    }
    else if (textField == self.secondTextField) {
        secondString = [timeString stringByAppendingString:self.secondTextFieldTwo.text];
    }
    else {
        secondString = [self.secondTextField.text stringByAppendingString:timeString];
    }

    NSInteger minute = minuteString.bjl_integerValue;
    NSInteger second = secondString.bjl_integerValue;
    NSInteger totalTime = minute * 60 + second;
    return totalTime;
}

- (void)updateTotalTime {
    if (!self.minuteTextField.userInteractionEnabled) {
        return;
    }
    NSString *minuteString = [self.minuteTextField.text stringByAppendingString:self.minuteTextFieldTwo.text];
    NSString *secondString = [self.secondTextField.text stringByAppendingString:self.secondTextFieldTwo.text];
    NSInteger minute = minuteString.bjl_integerValue;
    NSInteger second = secondString.bjl_integerValue;
    self.totalTime = minute * 60 + second;
}

// 判断是否为数字
- (BOOL)isValidDuration:(NSString *)durationString {
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:durationString]) {
        return YES;
    }
    return NO;
}

#pragma mark - mp3

- (void)playAudio {
    
    // 默认使用内置麦克风，使用通话音量
    BJLError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:(AVAudioSessionCategoryOptionMixWithOthers
                                                     | AVAudioSessionCategoryOptionAllowBluetooth
                                                     | AVAudioSessionCategoryOptionDefaultToSpeaker)
                                           error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    if (!self.audioPlayer) {
//        NSBundle *classBundle = [NSBundle bundleForClass:[BJLTheme class]];
//        NSString *bundlePath = [classBundle pathForResource:@"BJLiveUI" ofType:@"bundle"];
//        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
//        NSString *audioPath = [bundle pathForResource:@"countDownTimer" ofType:@"mp3"];
        
        NSString *audioPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"countDownTimer.mp3"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
        [self.audioPlayer prepareToPlay];
    }
    self.audioPlayer.volume = 1;
    [self.audioPlayer play];
}

- (void)stopAudio {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}

@end
