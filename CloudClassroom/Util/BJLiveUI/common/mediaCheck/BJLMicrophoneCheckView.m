//
//  BJLMicrophoneCheckView.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <AVFAudio/AVFAudio.h>
#import <AVFoundation/AVFoundation.h>

#import "BJLMicrophoneCheckView.h"
#import "BJLAppearance.h"

NSString *BJLMicrophoneCheckCellReuseIdentifier = @"BJLMicrophoneCheckCellReuseIdentifier";

@interface BJLMicrophoneCheckView ()

@property (nonatomic) NSString *tempAudioFile;
@property (nonatomic) NSArray<AVAudioSessionPortDescription *> *microphonePorts;
@property (nonatomic) AVAudioSessionPortDescription *currentPort;
@property (nonatomic) UILabel *noteLabel;
@property (nonatomic) UIStackView *stackView;
@property (nonatomic) NSArray<UIView *> *volumeViews;
@property (nonatomic) AVAudioRecorder *audioRecorder;
@property (nonatomic) NSTimer *timer;

@end

@implementation BJLMicrophoneCheckView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeSubviews];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.timer invalidate];
    self.timer = nil;
    [self.audioRecorder stop];
    BOOL delete = [self.audioRecorder deleteRecording];
    if (!delete) {
        NSFileManager *fileManager = NSFileManager.defaultManager;
        if ([fileManager fileExistsAtPath:self.tempAudioFile]) {
            [fileManager removeItemAtPath:self.tempAudioFile error:nil];
        }
    }
}

- (void)makeSubviews {
    self.tipLabel.text = BJLLocalizedString(@"麦克风");
    [self.tableView registerClass:[BJLMediaDeviceCell class] forCellReuseIdentifier:BJLMicrophoneCheckCellReuseIdentifier];

    self.noteLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.viewTextColor;
        label.text = BJLLocalizedString(@"您可以对着麦克风从1数到10，并观察是否有跳动效果");
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    [self addSubview:self.noteLabel];
    [self.noteLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.arrowButton.bjl_bottom).offset(30.0);
        make.left.equalTo(self.tipLabel);
        make.height.equalTo(@20.0);
    }];

    CGFloat volumeViewCount = 27.0;
    CGFloat volumeViewWidth = 8.0;
    CGFloat volumeViewHeight = 20.0;
    CGFloat volumeViewSpace = 4.0;
    NSMutableArray<UIView *> *views = [NSMutableArray new];
    for (NSInteger i = 0; i < volumeViewCount; i++) {
        UIView *view = [UIView new];
        view.layer.cornerRadius = 1.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = BJLTheme.roomBackgroundColor;
        UIView *fillView = [UIView new];
        [view addSubview:fillView];
        [fillView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(view);
            make.size.equal.sizeOffset(CGSizeMake(volumeViewWidth, volumeViewHeight));
        }];
        [views addObject:view];
    }
    self.volumeViews = views;
    self.stackView = ({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:views];
        stackView.spacing = volumeViewSpace;
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentLeading;
        stackView.distribution = UIStackViewDistributionEqualSpacing;
        stackView;
    });
    [self addSubview:self.stackView];
    [self.stackView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.noteLabel.bjl_bottom).offset(10.0);
        make.centerX.equalTo(self);
        make.height.equalTo(@(volumeViewHeight));
        make.width.equalTo(@(volumeViewCount * volumeViewWidth + volumeViewSpace * (volumeViewCount - 1)));
    }];

    AVAuthorizationStatus microphoneAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (microphoneAuthStatus != AVAuthorizationStatusAuthorized) {
        [BJLAuthorization checkMicrophoneAccessAndRequest:YES callback:^(BOOL granted, UIAlertController *_Nullable alert) {
            if (granted) {
                [self setupAVSession];
            }
            else {
                [self makeCheckedViewWithError:BJLErrorMake(BJLErrorCode_invalidCalling, @"未授权")];
                if (alert) {
                    [self.parentViewController presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
    }
    else {
        [self setupAVSession];
    }
}

- (void)makeCheckedViewWithError:(nullable BJLError *)error {
    bjl_weakify(self);
    [self makeCheckedViewWithTitle:BJLLocalizedString(@"在对麦克风说话时音量条有跳动吗？")
        confirmMessage:BJLLocalizedString(@"有跳动")
        confirmHander:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.microphoneCheckCompletion) {
                self.microphoneCheckCompletion(YES, NO);
            }
        }
        opposeMessage:BJLLocalizedString(@"没跳动")
        opposeHander:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.microphoneCheckCompletion) {
                self.microphoneCheckCompletion(NO, !error);
            }
        }
        error:error];
}

#pragma mark -

- (void)setupAVSession {
    // 默认使用内置麦克风，使用通话音量
    BJLError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:(AVAudioSessionCategoryOptionMixWithOthers
                                                     | AVAudioSessionCategoryOptionAllowBluetooth
                                                     | AVAudioSessionCategoryOptionDefaultToSpeaker)
                                           error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        [self makeCheckedViewWithError:error];
        return;
    }
    if (error) {
        [self makeCheckedViewWithError:error];
        return;
    }
    [self updateInputPort];
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.baijiayun.microphoneCheck.caf"];
    NSDictionary *setting = @{
        AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatLinearPCM],
        AVSampleRateKey: [NSNumber numberWithFloat:8000.0],
        AVNumberOfChannelsKey: [NSNumber numberWithInt:1]
    };
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if ([fileManager fileExistsAtPath:tempFile]) {
        [fileManager removeItemAtPath:tempFile error:nil];
    }
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:tempFile] settings:setting error:&error];
    if (error) {
        [self makeCheckedViewWithError:error];
        return;
    }
    self.tempAudioFile = tempFile;
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder record];

    bjl_weakify(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify_ifNil(self) {
            [timer invalidate];
            return;
        }
        if (self.audioRecorder.isRecording) {
            // 声音区间 -160 0 之间，普通环境 -20 -30 之间，大声为 -10 0 之间
            [self.audioRecorder updateMeters];
            CGFloat peakPower = [self.audioRecorder peakPowerForChannel:0];
            [self updateVolumeViewsWithPower:peakPower];
        }
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.window && self.superview && !self.checkLabel) {
            [self makeCheckedViewWithError:nil];
        }
    });
}

- (void)updateInputPort {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    self.microphonePorts = audioSession.currentRoute.inputs;
    // 到 iOS 14 为止可用的 AVAudioSessionPort 类型 LineIn MicrophoneBuiltIn MicrophoneWired
    // 只能获取到当前的 AVAudioSessionRouteDescription，从中获取 input
    AVAudioSessionPortDescription *port = nil;
    for (AVAudioSessionPortDescription *data in self.microphonePorts) {
        if ([data.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            port = data;
        }
    }

    if (!port) {
        port = self.microphonePorts.firstObject;
    }
    self.currentPort = port;
}

- (void)setCurrentPort:(AVAudioSessionPortDescription *)currentPort {
    _currentPort = currentPort;
    [self.arrowButton bjl_setTitle:currentPort.portName forState:UIControlStateNormal];
    self->_microphoneName = currentPort.portName;
}

- (void)updateVolumeViewsWithPower:(CGFloat)power {
    NSInteger count = self.volumeViews.count;
    // 假定在 -10 的时候达到最大，在环境 30 左右时较小， 使用方程 Y = 100 / x^2
    NSInteger result = (100 / (power * power)) * count;
    for (NSInteger i = 0; i < count; i++) {
        UIView *view = [self.volumeViews bjl_objectAtIndex:i];
        view.backgroundColor = i <= result ? BJLTheme.brandColor : BJLTheme.roomBackgroundColor;
    }
}

#pragma mark -

- (NSArray *)dataSource {
    return self.microphonePorts;
}

@end
