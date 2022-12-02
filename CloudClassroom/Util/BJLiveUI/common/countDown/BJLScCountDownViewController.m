//
//  BJLScCountDownViewController.m
//  BJLiveUI
//
//  Created by 凡义 on 2019/10/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BJLWindowViewController+protected.h"

#import "BJLScCountDownViewController.h"
#import "BJLScAppearance.h"

#define hightCountDownTime   60
#define defaultCountDownTime 300

@interface BJLScCountDownViewController () <UITextFieldDelegate>

@property (nonatomic, readonly, weak) BJLRoom *room;
@property (nonatomic, readwrite) BOOL isDecrease;
@property (nonatomic, readwrite) BOOL shouldPause;

@property (nonatomic) NSTimer *countDownTimer;

@property (nonatomic, readwrite) NSUInteger originCountDownTime; // 初始计时值
@property (nonatomic, readwrite) NSUInteger currentCountDownTime; // 正、到计时的数值

// 初始倒计时时间为1分钟及以上时, 倒计时从1分钟开始要变色, 否则不变色.
@property (nonatomic) BOOL shouldStartTimeHighlight;

@property (nonatomic) UIView *middleView, *containerView;
@property (nonatomic) UIImageView *timerIcon;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UIButton *closeButton;

@property (nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation BJLScCountDownViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super init];
    if (self) {
        self->_room = room;
        [self prepareToOpen];
    }
    return self;
}

- (instancetype)initWithRoom:(BJLRoom *)room
                   totalTime:(NSInteger)time
        currentCountDownTime:(NSInteger)currentCountDownTime
                  isDecrease:(BOOL)isDecrease {
    self = [super init];
    if (self) {
        self->_room = room;
        self.isDecrease = isDecrease;
        self.originCountDownTime = time;
        self.currentCountDownTime = isDecrease ? currentCountDownTime : MAX(0, (time - currentCountDownTime));
        self.shouldStartTimeHighlight = (time >= hightCountDownTime);
        [self prepareToOpen];
    }
    return self;
}

- (void)prepareToOpen {
    self.minWindowHeight = 45.0f;
    self.minWindowWidth = 160.0f;
    self.fixedAspectRatio = self.minWindowWidth / self.minWindowHeight;
}

- (void)updateTimerWithTotalTime:(NSUInteger)time
            currentCountDownTime:(NSUInteger)currentCountDownTime
                      isDecrease:(BOOL)isDecrease
                     shouldPause:(BOOL)shouldPause {
    self.isDecrease = isDecrease;
    self.shouldPause = shouldPause;
    self.originCountDownTime = time;
    self.currentCountDownTime = isDecrease ? currentCountDownTime : MAX(0, (time - currentCountDownTime));
    self.shouldStartTimeHighlight = (time >= hightCountDownTime);

    CGSize windowAreaSize = self.windowedSuperview.bounds.size;
    if (CGSizeEqualToSize(windowAreaSize, CGSizeZero)) {
        return;
    }

    CGFloat relativeWidth = self.minWindowWidth / (windowAreaSize.width);
    CGFloat relativeHeight = self.minWindowHeight / (windowAreaSize.height);
    self.relativeRect = [self rectInBounds:CGRectMake(0.04, 0.08, relativeWidth, relativeHeight)];
}

- (void)dealloc {
    [self stopCountDownTimer];
    [self stopAudio];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 4.0;
    self.view.layer.masksToBounds = YES;

    self.maximizeButtonHidden = YES;
    self.fullscreenButtonHidden = YES;
    self.doubleTapToMaximize = NO;
    self.closeButtonHidden = YES;
    self.bottomBar.hidden = YES;
    self.topBar.hidden = YES;
    self.panToResize = NO;
    self.tapToBringToFront = NO;
    self.resizeHandleImageViewHidden = YES;
    self.topBarBackgroundViewHidden = YES;

    [self makeSubviews];
    [self makeObeserving];

    bjl_weakify(self);
    [self setSingleTapGestureCallback:^(CGPoint point) {
        bjl_strongify(self);
        if (self.room.loginUser.isTeacher) {
            if ([self.middleView.layer containsPoint:point]) {
                if (self.showCountDownEditViewCallback) {
                    self.showCountDownEditViewCallback();
                }
            }
            else {
                BJLError *error = [self.room.roomVM requestStopTimer];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                }
            }
        }
    }];
}

- (void)makeSubviews {
    self.containerView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, containerView);
        view.backgroundColor = BJLTheme.brandColor;
        bjl_return view;
    });

    self.middleView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, middleView);
        view.backgroundColor = UIColor.clearColor;
        bjl_return view;
    });

    self.timerIcon = ({
        UIImageView *view = [UIImageView new];
        view.accessibilityIdentifier = BJLKeypath(self, timerIcon);
        [view setImage:[UIImage bjl_imageNamed:@"bjl_timer_icon"]];
        bjl_return view;
    });

    self.timeLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, timeLabel);
        label.textColor = BJLTheme.buttonTextColor;
        label.font = [UIFont systemFontOfSize:26];
        label.textAlignment = NSTextAlignmentCenter;
        bjl_return label;
    });

    self.closeButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = BJLKeypath(self, closeButton);
        [button setImage:[UIImage bjl_imageNamed:@"bjl_timer_close"] forState:UIControlStateNormal];
        [button bjl_setBackgroundColor:UIColor.clearColor forState:UIControlStateNormal];
        bjl_return button;
    });

    [self.containerView addSubview:self.middleView];
    [self.middleView addSubview:self.timerIcon];
    [self.middleView addSubview:self.timeLabel];
    if (self.room.loginUser.isTeacher) {
        [self.containerView addSubview:self.closeButton];
        [self.closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.bottom.equalTo(self.containerView);
            make.right.equalTo(self.containerView).offset(-5.0);
            make.width.equalTo(@24.0);
        }];
    }

    [self.middleView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.bottom.equalTo(self.containerView);
        if (self.room.loginUser.isTeacher) {
            make.right.equalTo(self.closeButton.bjl_left).offset(-5.0);
        }
        else {
            make.right.equalTo(self.containerView);
        }
    }];

    [self.timerIcon bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.middleView);
        make.left.equalTo(self.middleView).offset(13);
        make.width.height.equalTo(@(32.0));
    }];
    [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.middleView);
        make.left.equalTo(self.timerIcon.bjl_right).offset(8);
        make.right.lessThanOrEqualTo(self.middleView);
    }];

    [self setContentViewController:nil contentView:self.containerView];
    [self initialCountDownTime];
    if (!self.shouldPause) {
        [self startCountDownTimer];
    }
}

- (void)makeObeserving {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceiveTimerWithTotalTime:countDownTime:isDecrease:)
             observer:(BJLMethodObserver) ^ BOOL(NSInteger totalTime, NSInteger countDownTime, BOOL isDecrease) {
                 bjl_strongify(self);
                 self.currentCountDownTime = isDecrease ? countDownTime : MAX(0, (totalTime - countDownTime));
                 self.originCountDownTime = totalTime;
                 self.isDecrease = isDecrease;
                 self.shouldStartTimeHighlight = (totalTime >= hightCountDownTime);

                 [self startCountDownTimer];
                 [self stopAudio];
                 return YES;
             }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didReceivePauseTimerWithTotalTime:leftCountDownTime:isDecrease:) observer:^BOOL {
        bjl_strongify(self);
        [self pauseCountDownTimer];
        return YES;
    }];
}

- (void)initialCountDownTime {
    [self updateShowTimeColor];
    [self updateShowTime];
}

#pragma mark - override

- (void)closeWithoutRequest {
    [self stopCountDownTimer];
    [super closeWithoutRequest];
}

#pragma mark - timer

- (void)stopCountDownTimer {
    if (self.countDownTimer || [self.countDownTimer isValid]) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}

- (void)pauseCountDownTimer {
    [self stopCountDownTimer];
}

- (void)startCountDownTimer {
    [self stopCountDownTimer];
    [self initialCountDownTime];

    bjl_weakify(self);
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        if (!self) {
            [timer invalidate];
            return;
        }

        // 倒计时结束
        if ((self.currentCountDownTime <= 0 && self.isDecrease) || (self.currentCountDownTime >= self.originCountDownTime && !self.isDecrease)) {
            [timer invalidate];
            self.shouldStartTimeHighlight = NO;
            [self initialCountDownTime];
            // 计时结束时,更新到高亮状态
            self.containerView.backgroundColor = [UIColor bjl_colorWithHex:0xFF1F49 alpha:0.8];

            // 计时结束, 播放铃声
            [self playAudio];
            return;
        }

        if (self.isDecrease) {
            self.currentCountDownTime--;
        }
        else {
            self.currentCountDownTime++;
        }
        [self updateShowTimeColor];
        [self updateShowTime];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

- (void)updateShowTimeColor {
    BOOL shouldHight = (((self.currentCountDownTime <= hightCountDownTime && self.isDecrease)
                            || (self.originCountDownTime - self.currentCountDownTime <= hightCountDownTime && !self.isDecrease))
                        && self.shouldStartTimeHighlight);

    UIColor *backgroundColor = shouldHight ? [UIColor bjl_colorWithHex:0xFF1F49 alpha:0.8] : BJLTheme.brandColor;
    self.containerView.backgroundColor = backgroundColor;
}

- (void)updateShowTime {
    NSInteger minute = self.currentCountDownTime / 60;
    NSInteger second = self.currentCountDownTime % 60;
    NSString *minuteString = (minute < 10) ? [NSString stringWithFormat:@"%02td", minute] : [NSString stringWithFormat:@"%td", minute];
    NSString *secondString = (second < 10) ? [NSString stringWithFormat:@"%02td", second] : [NSString stringWithFormat:@"%td", second];

    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", minuteString, secondString];
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
