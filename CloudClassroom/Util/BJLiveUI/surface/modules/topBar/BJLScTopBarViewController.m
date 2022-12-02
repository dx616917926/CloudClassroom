//
//  BJLScTopBarViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/18.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScTopBarViewController.h"
#import "BJLScAppearance.h"

#define SHOW_NETWORK_INFO 0   //是否显示网络状态

@interface BJLScTopBarViewController ()

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) NSTimer *classTimer;

@property (nonatomic) UILabel *titleLabel, *timeLabel;
@property (nonatomic) UIButton *closeButton, *serverRecordingButton, *shareButton, *settingButton, *broadcastButton;
@property (nonatomic) NSArray<UIButton *> *layoutButtons;

#pragma mark - weak network

#if SHOW_NETWORK_INFO
@property (nonatomic) UIButton *upPackageLossRateButton, *downPackageLossRateButton;
@property (nonatomic) NSString *upPackageLossRateString, *downPackageLossRateString;
@property (nonatomic) BJLNetworkStatus upPackageLossRateStatus, downPackageLossRateStatus;
@property (nonatomic) dispatch_queue_t headerHandleQueue;

#endif
// < userNumber, < time, loss rate > >
@property (nonatomic) NSMutableDictionary<NSString *, NSArray<NSDictionary<NSNumber *, NSNumber *> *> *> *lossRateDictionary;
@property (nonatomic, nullable) NSTimer *lossRateObservingTimer;
@property (nonatomic) CGFloat lossRateObservingTimeInterval;

@end

@implementation BJLScTopBarViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super init]) {
        self.room = room;
#if SHOW_NETWORK_INFO
        self.upPackageLossRateString = @"0.00%";
        self.downPackageLossRateString = @"0.00%";
        self.upPackageLossRateStatus = BJLNetworkStatus_normal;
        self.downPackageLossRateStatus = BJLNetworkStatus_normal;
#endif
        self.lossRateDictionary = [NSMutableDictionary new];
        self.lossRateObservingTimeInterval = (self.room.featureConfig.lossRateRetainTime > 0) ? self.room.featureConfig.lossRateRetainTime : 10;
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
#if SHOW_NETWORK_INFO
    [self stopLossRateObservingTimer];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.accessibilityIdentifier = NSStringFromClass(self.class);

    [self makeSubviews];
    [self makeObserving];

#if SHOW_NETWORK_INFO
    // fire
    [self updateUploadPackageLossRateString:self.upPackageLossRateString networkStatus:self.upPackageLossRateStatus];
    [self updateDownloadPackageLossRateString:self.downPackageLossRateString networkStatus:self.downPackageLossRateStatus];

    [self restartLossRateObservingTimer];
#endif
}

- (void)makeSubviews {
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowOpacity = 0.3;
    self.view.layer.shadowColor = BJLTheme.windowShadowColor.CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.view.layer.shadowRadius = 2.0;

    UIView *networkInfoView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = @"networkInfoView";
        [self.view addSubview:view];
        view;
    });
    [networkInfoView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).priorityHigh();
    }];
    
#if SHOW_NETWORK_INFO

    self.upPackageLossRateButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = BJLKeypath(self, upPackageLossRateButton);
        [button setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_uplossrate"] forState:UIControlStateNormal];
        [button setAttributedTitle:[self packageLossRateAttributedStringWithString:self.upPackageLossRateString networkStatus:self.upPackageLossRateStatus] forState:UIControlStateNormal];
        [networkInfoView addSubview:button];
        button.userInteractionEnabled = NO;
        bjl_return button;
    });
    [self.upPackageLossRateButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.bottom.equalTo(networkInfoView).priorityHigh();
        make.left.equalTo(networkInfoView).offset(BJLScViewSpaceS);
    }];

    self.downPackageLossRateButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = BJLKeypath(self, downPackageLossRateButton);
        [button setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_downlossrate"] forState:UIControlStateNormal];
        [button setAttributedTitle:[self packageLossRateAttributedStringWithString:self.downPackageLossRateString networkStatus:self.downPackageLossRateStatus] forState:UIControlStateNormal];
        [networkInfoView addSubview:button];
        button.userInteractionEnabled = NO;
        bjl_return button;
    });

    [self.downPackageLossRateButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.upPackageLossRateButton.bjl_right).offset(12.0);
        make.top.bottom.equalTo(self.upPackageLossRateButton);
        make.right.equalTo(networkInfoView);
    }];
#endif
    
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, titleLabel);
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.viewTextColor;
        label.text = BJLLocalizedString(@"课程标题");
        label;
    });
    [self.view addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view).offset(-70).priorityHigh();
        make.horizontal.hugging.required();
        make.left.greaterThanOrEqualTo(networkInfoView.bjl_right).offset(BJLScViewSpaceM);
        make.right.lessThanOrEqualTo(self.timeLabel.bjl_left).offset(-BJLScViewSpaceM);
    }];

    CGFloat closeButtonWidth = 24.0;
    self.closeButton = ({
        UIButton *button = [UIButton new];
        button.accessibilityIdentifier = BJLKeypath(self, closeButton);
        button.layer.cornerRadius = closeButtonWidth / 2.0;
        button.layer.masksToBounds = YES;
        button.backgroundColor = BJLTheme.warningColor;
        [button bjl_setImage:[UIImage bjlsc_imageNamed:@"bjl_sc_close"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:self.closeButton];
    [self.closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.view).offset(-8.0);
        make.centerY.equalTo(self.view);
        make.width.equalTo(@(closeButtonWidth));
        make.height.equalTo(@(closeButtonWidth));
    }];

    self.settingButton = [self makeButtonWithImageName:@"bjl_sc_setting" selectedImage:nil action:@selector(showSetting)];
    self.shareButton = [self makeButtonWithImageName:@"bjl_sc_share" selectedImage:nil action:@selector(share)];
    self.serverRecordingButton = [self makeButtonWithImageName:@"bjl_sc_recording" selectedImage:@"bjl_sc_recording_on" action:@selector(updateServerRecording:)];
    self.serverRecordingButton.selected = self.room.serverRecordingVM.serverRecording;
    self.broadcastButton = [self makeButtonWithImageName:@"bjl_sc_broadcast" selectedImage:@"bjl_sc_broadcast_on" action:@selector(updateBroadcast:)];

    self.timeLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, timeLabel);
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = BJLTheme.toolButtonTitleColor;
        label.text = BJLLocalizedString(@"直播未开始");
        label.textAlignment = NSTextAlignmentRight;
        label;
    });
    [self.view addSubview:self.timeLabel];
}

- (void)makeConstraints {
    [self.layoutButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray<UIView *> *views = [@[self.settingButton] mutableCopy];
    if ([self enableShare]) {
        [views bjl_addObject:self.shareButton];
    }
    if ([self canLoginUserShowServerRecordingState]) {
        [views bjl_addObject:self.serverRecordingButton];
    }
    if (self.room.roomVM.enableLiveBroadcast) {
        [views bjl_addObject:self.broadcastButton];
    }
    [self makeConstraintsWithViews:views];
    self.layoutButtons = [views copy];

    [self.timeLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.compressionResistance.required();
        make.left.greaterThanOrEqualTo(self.titleLabel.bjl_right).offset(BJLScViewSpaceM);
        make.right.equalTo(views.lastObject.bjl_left).offset(-8.0);
        make.height.centerY.equalTo(self.view);
    }];
}

- (BOOL)enableShare {
    BOOL shouldSupportShare = NO; //self.room.featureConfig.enableShare;
    return (shouldSupportShare && self.shareCallback);
}

#pragma mark - observing

- (void)makeObserving {
    bjl_weakify(self);

    [self bjl_kvoMerge:@[BJLMakeProperty(self.room, featureConfig),
        BJLMakeProperty(self.room.roomVM, enableLiveBroadcast)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  if (self.room.featureConfig) {
                      [self makeConstraints];
                  }
              }];

    // 目前在获取到了 roominfo 之后布局，可以直接 kvo roomInfo
    [self bjl_kvo:BJLMakeProperty(self.room.roomInfo, title)
         observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.titleLabel.text = self.room.roomInfo.title;
             return YES;
         }];

    __block BOOL isInitial = YES;
    [self bjl_kvo:BJLMakeProperty(self.room.serverRecordingVM, serverRecording)
        filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return now.boolValue != old.boolValue;
        }
        observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            self.serverRecordingButton.selected = self.room.serverRecordingVM.serverRecording;

            if (self.room.featureConfig.secretCloudRecord) {
                return YES;
            }

            if (now.boolValue) {
                [self showProgressHUDWithText:BJLLocalizedString(@"已开启录课")];
            }
            else {
                if (!isInitial) {
                    [self showProgressHUDWithText:BJLLocalizedString(@"已关闭录课")];
                }
            }
            isInitial = NO;
            return YES;
        }];

    [self bjl_observe:BJLMakeMethod(self.room.serverRecordingVM, requestServerRecordingDidFailed:)
             observer:^BOOL(NSString *message) {
                 bjl_strongify(self);
                 if (!self.room.featureConfig.secretCloudRecord) {
                     [self showProgressHUDWithText:message];
                 }
                 return YES;
             }];

    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, isReceiveLiveBroadcast)
        filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            // bjl_strongify(self);
            return now.boolValue != old.boolValue;
        }
        observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            self.broadcastButton.selected = now.bjl_boolValue;
            [self showProgressHUDWithText:now.bjl_boolValue ? BJLLocalizedString(@"已开启转播") : BJLLocalizedString(@"已关闭转播")];
            return YES;
        }];

    [self bjl_observe:BJLMakeMethod(self.room.roomVM, didStopLiveBroadcast:)
             observer:^BJLControlObserving(BJLError *error) {
                 if (error) {
                     [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                 }
                 return YES;
             }];

#if SHOW_NETWORK_INFO
    [self bjl_observe:BJLMakeMethod(self.room.mediaVM, mediaLossRateDidUpdateWithUser:videoLossRate:audioLossRate:)
             observer:(BJLMethodObserver) ^ BOOL(BJLMediaUser * user, CGFloat videoLossRate, CGFloat audioLossRate) {
                 bjl_strongify(self);
                 // 目前只统计所有用户主摄流的丢包
                 if (user.mediaSource != BJLMediaSource_mainCamera) {
                     return YES;
                 }

                 // 记录每个用户不同时间的丢包率数据
                 NSString *userNumber = user.number;
                 CGFloat packageLossRate = MIN(MAX(0.0, videoLossRate), 100.0);
                 NSString *userKey = [self userLossRateKeyWithUserNumber:userNumber mediaSource:user.mediaSource];
                 dispatch_async(self.headerHandleQueue, ^{
                     NSMutableArray<NSDictionary *> *lossRateArray = [[self.lossRateDictionary bjl_arrayForKey:userKey] mutableCopy];
                     if (!lossRateArray) {
                         lossRateArray = [NSMutableArray new];
                     }
                     NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
                     NSDictionary<NSNumber *, NSNumber *> *lossRateDic = [NSDictionary dictionaryWithObject:@(packageLossRate) forKey:@(timeInterval)];
                     [lossRateArray bjl_addObject:lossRateDic];
                     [self.lossRateDictionary bjl_setObject:lossRateArray forKey:userKey];
                 });
                 return YES;
             }];
#endif
    
    [self startTimer];
}

- (void)startTimer {
    [self stopTimer];

    bjl_weakify(self);
    self.classTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        if (!self || !self.classTimer) {
            [timer invalidate];
            return;
        }

        if (self.room.roomVM.classStartTimeMillisecond <= 0 || !self.room.roomVM.liveStarted) {
            return;
        }

        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:(self.room.roomVM.classStartTimeMillisecond / 1000)]];
        NSString *elapsedTimeString = [self elapsedTimeStringWithTimeInterval:time];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timeLabel.text = elapsedTimeString;
        });
    }];
}

- (void)stopTimer {
    if (self.classTimer || [self.classTimer isValid]) {
        [self.classTimer invalidate];
        self.classTimer = nil;
    }
}

- (NSString *)elapsedTimeStringWithTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval <= 0) {
        return BJLLocalizedString(@"直播未开始");
    }

    NSInteger elapsedTime = round(timeInterval);
    NSInteger second = elapsedTime % 60;
    NSInteger minute = (elapsedTime / 60) % 60;
    NSInteger hour = elapsedTime / 3600;
    NSString *secondString = second >= 10 ? [NSString stringWithFormat:@"%ld", (long)second] : [NSString stringWithFormat:@"0%ld", (long)second];
    NSString *minuteString = minute >= 10 ? [NSString stringWithFormat:@"%ld", (long)minute] : [NSString stringWithFormat:@"0%ld", (long)minute];
    NSString *hourString = hour >= 10 ? [NSString stringWithFormat:@"%ld", (long)hour] : [NSString stringWithFormat:@"0%ld", (long)hour];
    return [NSString stringWithFormat:@"直播中:  %@:%@:%@", hourString, minuteString, secondString];
}

#if SHOW_NETWORK_INFO

#pragma mark - lossrate
- (void)stopLossRateObservingTimer {
    if (self.lossRateObservingTimer || [self.lossRateObservingTimer isValid]) {
        [self.lossRateObservingTimer invalidate];
        self.lossRateObservingTimer = nil;
    }
}

- (void)restartLossRateObservingTimer {
    [self stopLossRateObservingTimer];
    bjl_weakify(self);
    self.lossRateObservingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify_ifNil(self) {
            [timer invalidate];
            return;
        }
        dispatch_async(self.headerHandleQueue, ^{
            CGFloat downloadLossRate = 0.0f;
            CGFloat uploadLossRate = 0.0f;
            BOOL hasCurrentLoginUser = NO;
            NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
            for (NSString *userKey in [self.lossRateDictionary.allKeys copy]) {
                // 读取每个用户的丢包率数据
                NSMutableArray<NSDictionary *> *lossRateArray = [[self.lossRateDictionary bjl_arrayForKey:userKey] mutableCopy];
                NSString *userNumber = [self userNumberForUserLossRateKey:userKey];
                NSInteger count = lossRateArray.count;

                if (count > 0) {
                    CGFloat totalLossRate = 0.0f;
                    for (NSDictionary<NSNumber *, NSNumber *> *lossRateDic in [lossRateArray copy]) {
                        // 读取用户丢包率数据中的时间，去掉 lossRateObservingTimeInterval 之外的时间
                        for (NSNumber *timeInterval in [lossRateDic.allKeys copy]) {
                            if (nowTimeInterval - [timeInterval bjl_doubleValue] > self.lossRateObservingTimeInterval) {
                                // 大于 lossRateObservingTimeInterval 的数据移除
                                [lossRateArray removeObject:lossRateDic];
                            }
                            else {
                                // 否则加入计算
                                totalLossRate += [lossRateDic bjl_floatForKey:timeInterval];
                            }
                        }
                    }
                    // 更新丢包率的字典
                    [self.lossRateDictionary bjl_setObject:lossRateArray forKey:userKey];

                    if ([userNumber isEqualToString:self.room.loginUser.number]) {
                        uploadLossRate = (lossRateArray.count > 0) ? totalLossRate / lossRateArray.count : 0.0f;
                        hasCurrentLoginUser = YES;
                    }
                    else {
                        downloadLossRate += (lossRateArray.count > 0) ? totalLossRate / lossRateArray.count : 0.0f;
                    }
                }
            }

            if ([self.lossRateDictionary.allKeys count]) {
                if (hasCurrentLoginUser && [self.lossRateDictionary.allKeys count] > 1) {
                    downloadLossRate = downloadLossRate / ([self.lossRateDictionary.allKeys count] - 1);
                }
                else if (!hasCurrentLoginUser) {
                    downloadLossRate = downloadLossRate / ([self.lossRateDictionary.allKeys count]);
                }
                else {
                    downloadLossRate = 0.0f;
                }
            }
            else {
                downloadLossRate = 0.0f;
            }

            // 记录处理时间
            BJLNetworkStatus uploadNetWork = [self netWorkStatusWithLossRate:uploadLossRate];
            BJLNetworkStatus downloadNetWork = [self netWorkStatusWithLossRate:downloadLossRate];
            NSString *upPackageLossRateString = [NSString stringWithFormat:@"%.2f%%", uploadLossRate];
            NSString *downPackageLossRateString = [NSString stringWithFormat:@"%.2f%%", downloadLossRate];
            [self updateUploadPackageLossRateString:upPackageLossRateString networkStatus:uploadNetWork];
            [self updateDownloadPackageLossRateString:downPackageLossRateString networkStatus:downloadNetWork];
        });
    }];
}

- (NSString *)userLossRateKeyWithUserNumber:(NSString *)userNumber mediaSource:(BJLMediaSource)mediaSource {
    return [NSString stringWithFormat:@"%@-%td", userNumber, mediaSource];
}

- (BJLMediaSource)mediaSourceForUserLossRateKey:(NSString *)key {
    NSString *separator = @"-";
    BJLMediaSource mediaSource = BJLMediaSource_mainCamera;
    NSRange separatorRange = [key rangeOfString:separator];
    if (separatorRange.location != NSNotFound) {
        mediaSource = [key substringFromIndex:separatorRange.location + separatorRange.length].integerValue;
    }
    return mediaSource;
}
- (nullable NSString *)userNumberForUserLossRateKey:(NSString *)key {
    NSString *separator = @"-";
    NSString *userNumber = nil;
    NSRange separatorRange = [key rangeOfString:separator];
    if (separatorRange.location != NSNotFound) {
        userNumber = [key substringToIndex:separatorRange.location];
    }
    return userNumber;
}

// 更新上行丢包率和网络状况
- (void)updateUploadPackageLossRateString:(NSString *)packageLossRateString
                            networkStatus:(BJLNetworkStatus)networkStatus {
    // 只有标签存在, 并且网络状态或丢包率的状态变化了, 才会更新
    dispatch_async(self.headerHandleQueue, ^{
        if (![self.upPackageLossRateString isEqualToString:packageLossRateString]) {
            self.upPackageLossRateString = packageLossRateString;
            if (self.upPackageLossRateButton) {
                NSAttributedString *packageLossRateAttributedString = [self packageLossRateAttributedStringWithString:packageLossRateString networkStatus:networkStatus];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.upPackageLossRateButton setAttributedTitle:packageLossRateAttributedString forState:UIControlStateNormal];
                });
            }
        }
    });
}

// 更新下行丢包率和网络状态
- (void)updateDownloadPackageLossRateString:(NSString *)packageLossRateString
                              networkStatus:(BJLNetworkStatus)networkStatus {
    // 只有标签存在, 并且网络状态或丢包率的状态变化了, 才会更新
    dispatch_async(self.headerHandleQueue, ^{
        if (![self.downPackageLossRateString isEqualToString:packageLossRateString]) {
            self.downPackageLossRateString = packageLossRateString;
            if (self.downPackageLossRateButton) {
                NSAttributedString *packageLossRateAttributedString = [self packageLossRateAttributedStringWithString:packageLossRateString networkStatus:networkStatus];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.downPackageLossRateButton setAttributedTitle:packageLossRateAttributedString forState:UIControlStateNormal];
                });
            }
        }
    });
}

- (nullable NSAttributedString *)packageLossRateAttributedStringWithString:(NSString
                                                                                   *)packageLossRateString
                                                             networkStatus:(BJLNetworkStatus)networkStatus {
    if (!packageLossRateString.length) {
        return nil;
    }
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    NSAttributedString *packageLossRateAttributedString = [[NSAttributedString alloc] initWithString:packageLossRateString
                                                                                          attributes:@{
                                                                                              NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                                                                              NSForegroundColorAttributeName: [self colorWithNetworkStatus:networkStatus],
                                                                                          }];
    [mutableAttributedString appendAttributedString:packageLossRateAttributedString];
    return mutableAttributedString;
}

- (BJLNetworkStatus)netWorkStatusWithLossRate:(CGFloat)lossRate {
    NSArray *lossRateArray = [self.room.featureConfig.lossRateLevelArray copy];

    BJLNetworkStatus preLossRateLevel = BJLNetworkStatus_normal;
    BJLNetworkStatus currentLossRateLevel = BJLNetworkStatus_normal;
    for (NSInteger index = 0; index < [lossRateArray count]; index++) {
        NSNumber *nmber = [lossRateArray objectAtIndex:index];
        CGFloat lossRateLevel = nmber.floatValue;
        if (preLossRateLevel == BJLNetworkStatus_normal && lossRateLevel > 0 && lossRateLevel <= 100) {
            preLossRateLevel = (BJLNetworkStatus)index;
        }

        if (lossRateLevel <= 0 || lossRateLevel > 100) {
            continue;
        }

        if (lossRateLevel <= lossRate) {
            preLossRateLevel = (BJLNetworkStatus)index;
            continue;
        }

        if (lossRateLevel > lossRate) {
            currentLossRateLevel = (BJLNetworkStatus)index;
            break;
        }
    }

    if (currentLossRateLevel == BJLNetworkStatus_normal && preLossRateLevel == BJLNetworkStatus_normal) {
        return BJLNetworkStatus_normal;
    }

    if (currentLossRateLevel == BJLNetworkStatus_normal) {
        currentLossRateLevel = (preLossRateLevel + 1 <= BJLNetworkStatus_Bad_level5) ? (preLossRateLevel + 1) : BJLNetworkStatus_Bad_level5;
    }
    else {
        currentLossRateLevel = (currentLossRateLevel <= BJLNetworkStatus_Bad_level5) ? currentLossRateLevel : BJLNetworkStatus_Bad_level5;
    }
    return currentLossRateLevel;
}

- (UIColor *)colorWithNetworkStatus:(BJLNetworkStatus)networkStatus {
    switch (networkStatus) {
        case BJLNetworkStatus_normal:
            return [UIColor bjl_colorWithHexString:@"#88FF00" alpha:1.0];

        case BJLNetworkStatus_Bad_level1:
            return [UIColor bjl_colorWithHexString:@"#1199FF" alpha:1.0];

        case BJLNetworkStatus_Bad_level2:
            return [UIColor bjl_colorWithHexString:@"#FFBB33" alpha:1.0];

        case BJLNetworkStatus_Bad_level3:
        case BJLNetworkStatus_Bad_level4:
        case BJLNetworkStatus_Bad_level5:
            return [UIColor bjl_colorWithHexString:@"#FF0000" alpha:1.0];

        default:
            return [UIColor whiteColor];
    }
}

- (dispatch_queue_t)headerHandleQueue {
    if (!_headerHandleQueue) {
        _headerHandleQueue = dispatch_queue_create("header_handle_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _headerHandleQueue;
}

#endif

#pragma mark - action

- (void)close:(UIButton *)button {
    if (self.exitCallback) {
        self.exitCallback();
    }
}

- (void)showSetting {
    if (self.showSettingCallback) {
        self.showSettingCallback();
    }
}

- (void)share {
    if (!self.room.featureConfig.enableShare) {
        return;
    }

    if (self.shareCallback) {
        self.shareCallback();
    }
}

- (void)updateServerRecording:(UIButton *)button {
    if (![self checkEnableServerRecordingAndShowHintIfDisable]) {
        return;
    }

    if (!button.selected) {
        BJLError *error = [self.room.serverRecordingVM requestServerRecording:!button.selected];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        return;
    }

    bjl_weakify(self);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:BJLLocalizedString(@"正在录课中") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"取消") style:UIAlertActionStyleDefault handler:nil];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"结束录课") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
        bjl_strongify(self);
        BJLError *error = [self.room.serverRecordingVM requestServerRecording:!button.selected];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
    }];

    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateBroadcast:(UIButton *)button {
    if (!button.selected) {
        BJLError *error = [self.room.roomVM startReceiveLiveBroadcast];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        return;
    }
    bjl_weakify(self);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:BJLLocalizedString(@"正在转播中") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"取消") style:UIAlertActionStyleDefault handler:nil];
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"结束转播") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
        bjl_strongify(self);
        BJLError *error = [self.room.roomVM stopReceiveLiveBroadcast];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
    }];

    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - wheel

/* 是否展示云端录制
 配置为展示录制状态 && 直播间配置为云端录制 && 直播间未配置无感知录制
 */

- (BOOL)canLoginUserShowServerRecordingState {
    if (self.room.featureConfig.secretCloudRecord) {
        return NO;
    }

    if (self.room.loginUser.isTeacherOrAssistant) {
        return (self.room.loginUser.isTeacherOrAssistant
                && self.room.loginUser.groupID == 0
                && !self.room.featureConfig.hideRecordStatusOfTeacherAndAssistant
                && self.room.featureConfig.cloudRecordType == BJLServerRecordingType_cloud);
    }
    else if (self.room.loginUser.isStudent) {
        return (!self.room.featureConfig.hideRecordStatusOfStudent
                && self.room.featureConfig.cloudRecordType == BJLServerRecordingType_cloud);
    }
    return NO;
}

/* 开启/关闭云端录制权限
 大班课老师, 配置了展示录制就允许操作
 大班课助教,允许操作云端录制 && 配置为展示录制  && 直播间配置为云端录制
 */
- (BOOL)checkEnableServerRecordingAndShowHintIfDisable {
    if (self.room.loginUser.isAssistant && !self.room.roomVM.getAssistantaAuthorityWithCloudRecord) {
        [self showProgressHUDWithText:BJLLocalizedString(@"云端录制权限已被禁用")];
        return NO;
    }

    return ((self.room.loginUser.isTeacher
                || (self.room.loginUser.isAssistant && self.room.roomVM.getAssistantaAuthorityWithCloudRecord))
            && self.room.loginUser.groupID == 0
            && !self.room.featureConfig.hideRecordStatusOfTeacherAndAssistant
            && self.room.featureConfig.cloudRecordType == BJLServerRecordingType_cloud);
}

- (void)makeConstraintsWithViews:(NSArray<UIView *> *)views {
    UIView *last = nil;
    for (UIView *view in views) {
        [view removeFromSuperview];
        [self.view addSubview:view];
        [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.horizontal.compressionResistance.required();
            make.centerY.equalTo(self.view);
            if (last) {
                make.right.equalTo(last.bjl_left);
                make.width.height.equalTo(last);
            }
            else {
                make.right.equalTo(self.closeButton.bjl_left).offset(-8.0);
                make.width.height.equalTo(@32.0).priorityHigh();
            }
        }];
        last = view;
    }
}

- (UIButton *)makeButtonWithImageName:(NSString *)imageName
                        selectedImage:(NSString *)selectedImageName
                               action:(SEL)selector {
    UIButton *button = [UIButton new];
    if (imageName) {
        [button bjl_setImage:[UIImage bjlsc_imageNamed:imageName] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    }
    if (selectedImageName) {
        [button bjl_setImage:[UIImage bjlsc_imageNamed:selectedImageName] forState:UIControlStateSelected possibleStates:UIControlStateHighlighted];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
