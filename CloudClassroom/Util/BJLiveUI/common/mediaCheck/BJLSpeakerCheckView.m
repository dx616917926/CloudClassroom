//
//  BJLSpeakerCheckView.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <AVFAudio/AVFAudio.h>
#import <BJYRTCEngine/BJYRTCEngine.h>

#import "BJLSpeakerCheckView.h"
#import "BJLAppearance.h"

NSString *BJLSpeakerCheckCellReuseIdentifier = @"BJLSpeakerCheckCellReuseIdentifier";

@interface BJLSpeakerCheckView ()

@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIImageView *stateImageView;
@property (nonatomic) UILabel *stateLabel;
@property (nonatomic) UIView *timeBar, *durationBar;

@property (nonatomic) NSArray<AVAudioSessionPortDescription *> *speakerPorts;
@property (nonatomic) AVAudioSessionPortDescription *currentPort;

@property (nonatomic) BJYRTMPMediaView *mediaView;
@property (nonatomic) NSTimer *timer;

@end

@implementation BJLSpeakerCheckView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeSubviews];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.mediaView stop];
    self.mediaView = nil;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)makeSubviews {
    self.tipLabel.text = BJLLocalizedString(@"扬声器");
    [self.tableView registerClass:[BJLMediaDeviceCell class] forCellReuseIdentifier:BJLSpeakerCheckCellReuseIdentifier];
    [self.arrowButton bjl_setImage:nil forState:UIControlStateNormal];

    self.playButton = ({
        UIButton *button = [BJLImageButton new];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_play"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_check_pause"] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
        [button addTarget:self action:@selector(updatePlayStatus) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self addSubview:self.playButton];
    [self.playButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.tipLabel);
        make.top.equalTo(self.arrowButton.bjl_bottom).offset(34.0);
        make.size.equal.sizeOffset(CGSizeMake(50.0, 50.0));
    }];

    self.stateImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_check_finger"]];
        imageView;
    });
    [self addSubview:self.stateImageView];
    [self.stateImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.playButton.bjl_right).offset(10.0);
        make.top.equalTo(self.playButton).offset(10.0);
        make.size.equal.sizeOffset(CGSizeMake(24.0, 24.0));
    }];

    self.stateLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"请点击播放测试音");
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    [self addSubview:self.stateLabel];
    [self.stateLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.stateImageView);
        make.left.equalTo(self.stateImageView.bjl_right).offset(10.0);
        make.height.equalTo(@20.0);
    }];

    self.durationBar = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.roomBackgroundColor;
        view;
    });
    [self addSubview:self.durationBar];
    [self.durationBar bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.stateImageView);
        make.top.equalTo(self.stateImageView.bjl_bottom).offset(10.0);
        make.height.equalTo(@2.0);
        make.right.equalTo(self.arrowButton);
    }];

    self.timeBar = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.brandColor;
        view;
    });
    [self addSubview:self.timeBar];
    [self.timeBar bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.bottom.equalTo(self.durationBar);
        make.width.equalTo(@0.0);
    }];

    [self setupAVSession];
}

- (void)makeCheckedViewWithError:(nullable BJLError *)error {
    if (self.checkLabel) {
        return;
    }
    bjl_weakify(self);
    [self makeCheckedViewWithTitle:BJLLocalizedString(@"通过扬声器能清晰的听到声音吗？")
        confirmMessage:BJLLocalizedString(@"能听到")
        confirmHander:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.speakerCheckCompletion) {
                self.speakerCheckCompletion(YES, NO);
            }
        }
        opposeMessage:BJLLocalizedString(@"听不到")
        opposeHander:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.speakerCheckCompletion) {
                self.speakerCheckCompletion(NO, !error);
            }
        }
        error:error];
}

#pragma mark -

- (void)updatePlayStatus {
    self.playButton.selected = !self.playButton.selected;
    if (self.playButton.selected) {
        if (!self.mediaView) {
//            NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
//            NSString *bundlePath = [classBundle pathForResource:@"BJLiveUI" ofType:@"bundle"];
//            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
//            NSString *audioPath = [bundle pathForResource:@"speakerCheck" ofType:@"mp3"];
            
            NSString *audioPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"speakerCheck.mp3"];
            BJYRTMPMediaView *mediaView = [[BJYRTMPMediaView alloc] initWithLiveURL:[NSURL fileURLWithPath:audioPath] isMixer:YES];
            [mediaView pause];
            self.mediaView = mediaView;
            [self.mediaView prepareToPlay];
        }
        [self.mediaView play];
        self.stateImageView.image = [UIImage bjl_imageNamed:@"bjl_check_audio"];
        self.stateLabel.text = BJLLocalizedString(@"正在播放测试音");
        if (self.window && self.superview && !self.checkLabel) {
            [self makeCheckedViewWithError:nil];
        }
    }
    else {
        [self.mediaView pause];
        self.stateImageView.image = [UIImage bjl_imageNamed:@"bjl_check_finger"];
        self.stateLabel.text = BJLLocalizedString(@"请点击播放测试音");
    }
}

- (void)setCurrentPort:(AVAudioSessionPortDescription *)currentPort {
    _currentPort = currentPort;
    [self.arrowButton bjl_setTitle:currentPort.portName forState:UIControlStateNormal];
    self->_speakerName = currentPort.portName;
}

- (void)setupAVSession {
    NSError *error = nil;
    // 默认使用扬声器，使用通话音量
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:(AVAudioSessionCategoryOptionMixWithOthers
                                                     | AVAudioSessionCategoryOptionAllowBluetooth
                                                     | AVAudioSessionCategoryOptionDefaultToSpeaker)
                                           error:&error];
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVoiceChat error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        [self makeCheckedViewWithError:error];
        return;
    }
    [self updateOutputPort];

    bjl_weakify(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify_ifNil(self) {
            [timer invalidate];
            return;
        }
        NSTimeInterval duration = self.mediaView.duration;
        if (duration <= 0) {
            return;
        }
        if (self.mediaView.isPlaying != self.playButton.selected) {
            self.playButton.selected = self.mediaView.isPlaying;
        }
        CGFloat width = (self.mediaView.currentTime / duration) * CGRectGetWidth(self.durationBar.frame);
        [self.timeBar bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.width.equalTo(@(width));
        }];
        return;
    }];
}

- (void)updateOutputPort {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    self.speakerPorts = audioSession.currentRoute.outputs;
    // 到 iOS 14 为止可用的 AVAudioSessionPort 类型 LineOut Headphones Receiver BluetoothA2DPOutput Speaker HDMIOutput AirPlay BluetoothLE BluetoothHFP USBAudio CarAudio Virtual PCI FireWire DisplayPort AVB Thunderbolt
    // 只能获取到当前的 AVAudioSessionRouteDescription，从中获取 output
    AVAudioSessionPortDescription *port = nil;
    for (AVAudioSessionPortDescription *data in self.speakerPorts) {
        if ([data.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            port = data;
        }
    }

    if (!port) {
        port = self.speakerPorts.firstObject;
    }
    self.currentPort = port;
}

#pragma mark -

- (NSArray *)dataSource {
    return self.speakerPorts;
}

@end
