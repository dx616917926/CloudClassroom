//
//  BJLScSettingsViewController.m
//  BJLiveUI
//
//  Created by fanyi on 2019/9/18.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScSettingsViewController.h"
#import "BJLHandWritingBoardDeviceViewController.h"
#import "BJLScAppearance.h"
#import "BJLSettingOptionView.h"
#import "BJLSettingBeautyView.h"
#import "UIView+panGesture.h"

@interface BJLScSettingsViewController ()

@property (nonatomic) BJLSettingOptionView *camera, *definitionOptionView, *cameraSwitchView, *beautifySwitch;
@property (nonatomic) BJLSettingOptionView *mic, *backgroundAudio;
@property (nonatomic) BJLSettingOptionView *forbidHandsUp, *allForbidSpeak, *allProhibitions, *allHorizontalFlip, *allVerticalFlip, *upLink, *downLink;
@property (nonatomic) BJLSettingOptionView *pptRemark, *pptContentMode, *pptAnimation, *studentPageChange;
@property (nonatomic) BJLSettingOptionView *musicMode, *blutooth;
@property (nonatomic) BJLSettingOptionView *debug;
@property (nonatomic) BJLSettingOptionView *beauty;
@property (nonatomic) BJLSettingBeautyView *whitenessView, *beautyView;
@property (nonatomic) UIButton *bluetoothDeviceButton;

@property (nonatomic) NSArray<BJLSettingOptionView *> *supportChangeAfterLiveStartSwitches;

@end

@implementation BJLScSettingsViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithRoom:room];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 构造所有菜单按钮
    [self makeOptionContentView];
    // 增加按钮行为
    [self makeObservingAndActions];
    // 更新视图
    [self upadteCurrentOptionViews];

    // 这里禁用掉，避免拖动窗口时，scroll view的内容在safe area边缘就不能再往外拖动了
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.view.bjl_titleBarHeight = 30.0;
    [self.view bjl_addTitleBarPanGesture];
}

#pragma mark - option

- (void)makeOptionContentView {
    bjl_weakify(self);

#pragma mark - right

    NSMutableArray *supportChangeAfterLiveStartSwitches = [NSMutableArray new];
    NSMutableDictionary<NSString *, NSArray *> *dataSource = [NSMutableDictionary new];

#pragma mark - 摄像头
    NSMutableArray *cameraOptions = [NSMutableArray new];

    if (!self.room.roomInfo.isPushLive && !self.room.roomInfo.isMockLive) {
        BJLSettingOptionView *camera = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"摄像头：") viewType:BJLSettingOptionViewType_switch];
        void (^cameraActionCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BJLError *error = [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                                        recordingVideo:(tag == 0)];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                bjl_dispatch_async_main_queue(^{
                    [self.camera updateSelectedIndex:self.room.recordingVM.recordingVideo ? 0 : 1];
                });
            }
            else {
                [self showProgressHUDWithText:(self.room.recordingVM.recordingVideo
                                                      ? BJLLocalizedString(@"摄像头已打开")
                                                      : BJLLocalizedString(@"摄像头已关闭"))];
            }
        };
        [camera addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:cameraActionCallback];
        [cameraOptions addObject:camera];
        self.camera = camera;
    }

    NSMutableArray<NSString *> *definitionArray = [NSMutableArray arrayWithArray:@[BJLLocalizedString(@"标清"), BJLLocalizedString(@"高清")]];
    if (self.room.featureConfig.support720p) {
        [definitionArray addObject:@"720p"];
    }

    if (self.room.featureConfig.support1080p && !self.room.loginUser.isStudent && self.room.featureConfig.playerType != BJLPlayerType_BJYRTC) {
        [definitionArray addObject:@"1080p"];
    }
    BJLSettingOptionView *definitionOptionView = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"画质设置：") viewType:BJLSettingOptionViewType_switch];
    void (^definitionActionCallback)(NSInteger tag) = ^(NSInteger tag) {
        bjl_strongify(self);
        BJLVideoDefinition definition = BJLVideoDefinition_std;
        if (tag == 1) {
            definition = BJLVideoDefinition_high;
        }
        else if (tag == 2) {
            definition = BJLVideoDefinition_720p;
            if (!self.room.featureConfig.support720p) {
                definition = BJLVideoDefinition_1080p;
            }
        }
        else if (tag == 3) {
            definition = BJLVideoDefinition_1080p;
        }
        BJLError *error = [self.room.recordingVM updateVideoDefinition:definition];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
    };
    [definitionOptionView addSwitchMenuWithTitles:definitionArray selectedIndex:0 callback:definitionActionCallback];
    [cameraOptions addObject:definitionOptionView];
    self.definitionOptionView = definitionOptionView;

    BJLSettingOptionView *cameraSwitchView = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"摄像头切换：") viewType:BJLSettingOptionViewType_switch];
    void (^cameraSwitchActionCallback)(NSInteger tag) = ^(NSInteger tag) {
        bjl_strongify(self);
        BOOL UsingRearCamera = (tag == 1);
        BJLError *error = [self.room.recordingVM updateUsingRearCamera:UsingRearCamera];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
    };
    [cameraSwitchView addSwitchMenuWithTitles:@[BJLLocalizedString(@"前"), BJLLocalizedString(@"后")] selectedIndex:0 callback:cameraSwitchActionCallback];
    [cameraOptions addObject:cameraSwitchView];
    self.cameraSwitchView = cameraSwitchView;

    if (!self.room.featureConfig.isWebRTC && !self.room.roomInfo.isPushLive && !self.room.roomInfo.isMockLive) {
        BJLSettingOptionView *beautifySwitch = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"美颜：") viewType:BJLSettingOptionViewType_switch];
        void (^beautifySwitchActionCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BOOL beautifySwitchOn = (tag == 0);
            BJLError *error = [self.room.recordingVM updateVideoBeautifyLevel:(beautifySwitchOn
                                                                                      ? BJLVideoBeautifyLevel_on
                                                                                      : BJLVideoBeautifyLevel_off)];
            if (error) {
                [self.beautifySwitch updateSelectedIndex:(self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_on) ? 0 : 1];
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        };
        [beautifySwitch addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:beautifySwitchActionCallback];
        [cameraOptions addObject:beautifySwitch];
        self.beautifySwitch = beautifySwitch;
        [supportChangeAfterLiveStartSwitches addObject:beautifySwitch];
    }

    [dataSource setObject:cameraOptions forKey:BJLSettingMenuOptionKey_camera];

#pragma mark - 麦克风

    NSMutableArray *micOptions = [NSMutableArray new];
    if (!self.room.roomInfo.isPushLive && !self.room.roomInfo.isMockLive) {
        BJLSettingOptionView *mic = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"麦克风：") viewType:BJLSettingOptionViewType_switch];
        void (^micSwitchActionCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BOOL on = (tag == 0);
            BJLError *error = [self.room.recordingVM setRecordingAudio:on
                                                        recordingVideo:self.room.recordingVM.recordingVideo];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                // 避免触发 UIControlEventValueChanged
                bjl_dispatch_async_main_queue(^{
                    [self.mic updateSelectedIndex:self.room.recordingVM.recordingAudio ? 0 : 1];
                });
            }
            else {
                [self showProgressHUDWithText:(self.room.recordingVM.recordingAudio
                                                      ? BJLLocalizedString(@"麦克风已打开")
                                                      : BJLLocalizedString(@"麦克风已关闭"))];
            }
        };
        [mic addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:micSwitchActionCallback];
        [micOptions addObject:mic];
        self.mic = mic;
    }

    BJLSettingOptionView *backgroundAudio = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"后台音频：") viewType:BJLSettingOptionViewType_switch];
    void (^backgroundAudioSwitchActionCallback)(NSInteger tag) = ^(NSInteger tag) {
        bjl_strongify(self);
        BJLError *error = [self.room.mediaVM updateSupportBackgroundAudio:(tag == 0)];
        if (error) {
            [self.backgroundAudio updateSelectedIndex:self.room.mediaVM.supportBackgroundAudio ? 0 : 1];
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
    };
    [backgroundAudio addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:backgroundAudioSwitchActionCallback];
    [micOptions addObject:backgroundAudio];
    self.backgroundAudio = backgroundAudio;
    [supportChangeAfterLiveStartSwitches addObject:backgroundAudio];

    [dataSource setObject:micOptions forKey:BJLSettingMenuOptionKey_mic];

#pragma mark - 房间控制
    NSMutableArray *roomOptions = [NSMutableArray new];

    if (self.room.loginUser.isTeacherOrAssistant && BJLRoomType_1vNClass == self.room.roomInfo.roomType) {
        BJLSettingOptionView *forbidHandsUp = [[BJLSettingOptionView alloc] initWithLeftTitle:@"禁止举手：" viewType:BJLSettingOptionViewType_switch];
        void (^forbidHandsUpCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            [self.room.speakingRequestVM requestForbidSpeakingRequest:(tag == 0)];
        };
        [forbidHandsUp addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:forbidHandsUpCallback];
        [roomOptions addObject:forbidHandsUp];
        self.forbidHandsUp = forbidHandsUp;
        [supportChangeAfterLiveStartSwitches addObject:forbidHandsUp];
    }

    /*
    BJLSettingOptionView *allForbidSpeak = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"全体静音：") viewType:BJLSettingOptionViewType_switch];
    void (^allForbidSpeakCallback)(NSInteger tag) = ^(NSInteger tag) {
        bjl_strongify(self);
        [self.room.recordingVM sendForbidAllRecordingAudio:(tag == 0)];
    };
    [allForbidSpeak addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:allForbidSpeakCallback];
    [roomOptions addObject:allForbidSpeak];
     self.allForbidSpeak = allForbidSpeak;
    [supportChangeAfterLiveStartSwitches addObject:allForbidSpeak];
    */

    if (self.room.loginUser.isTeacherOrAssistant) {
        BJLSettingOptionView *allProhibitions = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"全体禁言：") viewType:BJLSettingOptionViewType_switch];
        void (^allProhibitionsCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BOOL allProhibitions = (tag == 0);
            NSError *error = [self.room.chatVM sendForbidAll:allProhibitions];
            if (error) {
                //                sender.on = !sender.on;
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        };
        [allProhibitions addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:allProhibitionsCallback];
        [roomOptions addObject:allProhibitions];
        self.allProhibitions = allProhibitions;
        [supportChangeAfterLiveStartSwitches addObject:allProhibitions];
    }

    if ([self enableVideoHorizontalMirror]) {
        BJLSettingOptionView *allHorizontalFlip = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"全体水平翻转：") viewType:BJLSettingOptionViewType_button];
        void (^allHorizontalFlipCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BJLEncoderMirrorMode mode = (tag == 0) ? 0 : BJLEncoderMirrorModeHorizontal;
            if (self.room.recordingVM.currentUserVideoEncoderMirrorMode & BJLEncoderMirrorModeVertical) {
                mode |= BJLEncoderMirrorModeVertical;
            }
            [self.room.recordingVM updateVideoEncoderMirrorModeForAllPlayingUser:mode];
        };
        [allHorizontalFlip addButtonActionWithTile:BJLLocalizedString(@"还原") acitonCallback:allHorizontalFlipCallback];
        [allHorizontalFlip addButtonActionWithTile:BJLLocalizedString(@"翻转") acitonCallback:allHorizontalFlipCallback];
        [roomOptions addObject:allHorizontalFlip];
        self.allHorizontalFlip = allHorizontalFlip;
    }

    if ([self enableVideoVerticalMirror]) {
        BJLSettingOptionView *allVerticalFlip = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"全体垂直翻转：") viewType:BJLSettingOptionViewType_button];
        void (^allVerticalFlipCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BJLEncoderMirrorMode mode = (tag == 0) ? 0 : BJLEncoderMirrorModeVertical;
            if (self.room.recordingVM.currentUserVideoEncoderMirrorMode & BJLEncoderMirrorModeHorizontal) {
                mode |= BJLEncoderMirrorModeHorizontal;
            }
            [self.room.recordingVM updateVideoEncoderMirrorModeForAllPlayingUser:mode];
        };
        [allVerticalFlip addButtonActionWithTile:BJLLocalizedString(@"还原") acitonCallback:allVerticalFlipCallback];
        [allVerticalFlip addButtonActionWithTile:BJLLocalizedString(@"翻转") acitonCallback:allVerticalFlipCallback];
        [roomOptions addObject:allVerticalFlip];
        self.allVerticalFlip = allVerticalFlip;
    }

    BJLSettingOptionView *upLink = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"上行线路：") viewType:BJLSettingOptionViewType_switch];
    void (^upLinkCallback)(NSInteger tag) = ^(NSInteger tag) {
        bjl_strongify(self);
        BOOL switchToTCP = (tag == 0);
        if (switchToTCP) {
            // 切换 TCP 上行链路的 CDN
            [self showTCPLinkTypeSwitchAlertWithIsUplink:YES
                                              completion:^(NSInteger selectIndex, BOOL canceled) {
                                                  bjl_strongify(self);
                                                  if (canceled) {
                                                      return;
                                                  }

                                                  BJLError *error = [self.room.mediaVM updateTCPUpLinkCDNWithIndex:selectIndex];
                                                  if (error) {
                                                      [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                                      bjl_dispatch_async_main_queue(^{
                                                          [self.upLink updateSelectedIndex:(self.room.mediaVM.upLinkType == BJLLinkType_TCP) ? 0 : 1];
                                                      });
                                                  }
                                              }];
        }
        else {
            BJLError *error = [self.room.mediaVM updateUpLinkType:BJLLinkType_UDP];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                bjl_dispatch_async_main_queue(^{
                    [self.upLink updateSelectedIndex:(self.room.mediaVM.upLinkType == BJLLinkType_TCP) ? 0 : 1];
                });
            }
        }
    };
    [upLink addSwitchMenuWithTitles:@[@"TCP", @"UDP"] selectedIndex:0 callback:upLinkCallback];
    [roomOptions addObject:upLink];
    self.upLink = upLink;

    BJLSettingOptionView *downLink = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"下行线路：") viewType:BJLSettingOptionViewType_switch];
    void (^downLinkCallback)(NSInteger tag) = ^(NSInteger tag) {
        bjl_strongify(self);
        BOOL switchToTCP = (tag == 0);
        if (switchToTCP) {
            [self showTCPLinkTypeSwitchAlertWithIsUplink:NO
                                              completion:^(NSInteger selectIndex, BOOL canceled) {
                                                  bjl_strongify(self);
                                                  if (canceled) {
                                                      return;
                                                  }

                                                  BJLError *error = [self.room.mediaVM updateTCPDownLinkCDNWithIndex:selectIndex];
                                                  if (error) {
                                                      [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                                                      bjl_dispatch_async_main_queue(^{
                                                          [self.downLink updateSelectedIndex:(self.room.mediaVM.downLinkType == BJLLinkType_TCP) ? 0 : 1];
                                                      });
                                                  }
                                              }];
        }
        else {
            BJLError *error = [self.room.mediaVM updateDownLinkType:BJLLinkType_UDP];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                [self.downLink updateSelectedIndex:(self.room.mediaVM.downLinkType == BJLLinkType_TCP) ? 0 : 1];
            }
        }
    };
    [downLink addSwitchMenuWithTitles:@[@"TCP", @"UDP"] selectedIndex:0 callback:downLinkCallback];
    [roomOptions addObject:downLink];
    self.downLink = downLink;

    [dataSource setObject:roomOptions forKey:BJLSettingMenuOptionKey_roomcontrol];

#pragma mark - 课件相关
    NSMutableArray *pptOptions = [NSMutableArray new];

    if (self.room.loginUser.isTeacherOrAssistant) {
        BJLSettingOptionView *pptRemark = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"课件备注：") viewType:BJLSettingOptionViewType_switch];
        void (^pptRemarkCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            [self.room.slideshowViewController updateShowPPTRemarkInfo:tag == 0];
        };
        [pptRemark addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:0 callback:pptRemarkCallback];
        [pptOptions addObject:pptRemark];
        self.pptRemark = pptRemark;
    }

    BJLSettingOptionView *pptContentMode = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"课件展示：") viewType:BJLSettingOptionViewType_switch];
    void (^pptContentModeCallback)(NSInteger tag) = ^(NSInteger tag) {
        bjl_strongify(self);
        BJLContentMode model = (tag == 0) ? BJLContentMode_scaleAspectFit : BJLContentMode_scaleAspectFill;
        [self.room.slideshowViewController updateContentMode:model];
    };
    [pptContentMode addSwitchMenuWithTitles:@[BJLLocalizedString(@"全屏"), BJLLocalizedString(@"铺满")] selectedIndex:0 callback:pptContentModeCallback];
    [pptOptions addObject:pptContentMode];
    self.pptContentMode = pptContentMode;

    if (self.room.loginUser.isTeacherOrAssistant) {
        BJLSettingOptionView *pptAnimation = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"课件类型：") viewType:BJLSettingOptionViewType_switch];
        void (^pptAnimationCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            self.room.disablePPTAnimation = (tag != 0);
        };
        [pptAnimation addSwitchMenuWithTitles:@[BJLLocalizedString(@"动态"), BJLLocalizedString(@"静态")] selectedIndex:0 callback:pptAnimationCallback];
        [pptOptions addObject:pptAnimation];
        self.pptAnimation = pptAnimation;
    }

    if (self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.noGroup && !self.room.roomInfo.isPureVideo) {
        BJLSettingOptionView *studentPageChange = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"学生预览&翻页：") viewType:BJLSettingOptionViewType_switch];
        void (^studentPageChangeCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BOOL forbidStudentChangePPT = (tag != 0);
            if (forbidStudentChangePPT) {
                [self.room.documentVM updateAllStudentH5PPTAuthorized:NO];
            }
            [self.room.documentVM updateForbidStudentChangePPT:forbidStudentChangePPT];
        };
        [studentPageChange addSwitchMenuWithTitles:@[BJLLocalizedString(@"允许"), BJLLocalizedString(@"不允许")] selectedIndex:0 callback:studentPageChangeCallback];
        [pptOptions addObject:studentPageChange];
        self.studentPageChange = studentPageChange;
    }
    [dataSource setObject:pptOptions forKey:BJLSettingMenuOptionKey_ppt];

#pragma mark - 美颜滤镜
    NSMutableArray *beautyOptions = [NSMutableArray new];
    if (self.room.featureConfig.playerType == BJLPlayerType_BRTC_TRTC
        || self.room.featureConfig.playerType == BJLPlayerType_BRTC
        || self.room.featureConfig.playerType == BJLPlayerType_TRTC) {
        self.beauty = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"美颜滤镜") viewType:BJLSettingOptionViewType_switch];
        self.beautyView = [[BJLSettingBeautyView alloc] initWithTitle:BJLLocalizedString(@"磨皮") normalImage:@"bjl_setting_vague_normal" disableImage:@"bjl_setting_vague_disable" value:self.room.recordingVM.beautyLevel];
        self.whitenessView = [[BJLSettingBeautyView alloc] initWithTitle:BJLLocalizedString(@"美白") normalImage:@"bjl_setting_skin_normal" disableImage:@"bjl_setting_skin_disable" value:self.room.recordingVM.whitenessLevel];

        void (^beautyCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BOOL beautyOn = (tag == 0);
            [self.beauty updateSelectedIndex:tag];
            [self.whitenessView beautyOn:beautyOn];
            [self.beautyView beautyOn:beautyOn];
        };
        [self.beauty addSwitchMenuWithTitles:@[BJLLocalizedString(@"开"), BJLLocalizedString(@"关")] selectedIndex:1 callback:beautyCallback];

        BOOL isBeautyOn = self.room.recordingVM.beautyLevel > 0 && self.room.recordingVM.whitenessLevel > 0;
        [self.beauty updateSelectedIndex:isBeautyOn ? 0 : 1];
        [self.whitenessView beautyOn:isBeautyOn];
        [self.beautyView beautyOn:isBeautyOn];

        [self.beautyView setValueChangeCallback:^(CGFloat value) {
            bjl_strongify(self);
            [self.room.recordingVM updateBeautyLevel:value];
        }];

        [self.whitenessView setValueChangeCallback:^(CGFloat value) {
            bjl_strongify(self);
            [self.room.recordingVM updateWhitenessLevel:value];
        }];

        [beautyOptions addObject:self.beauty];
        [beautyOptions addObject:self.beautyView];
        [beautyOptions addObject:self.whitenessView];
        [dataSource setObject:beautyOptions forKey:BJLSettingMenuOptionKey_beauty];
    }

#pragma mark - 其他

    NSMutableArray *otherOptions = [NSMutableArray new];

    BJLPlayerType playType = self.room.featureConfig.playerType;
    BOOL enableUseMusicMode = playType == BJLPlayerType_BRTC || playType == BJLPlayerType_BRTC_TRTC || playType == BJLPlayerType_TRTC;
    if (enableUseMusicMode) {
        BJLSettingOptionView *musicMode = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"音乐模式：") viewType:BJLSettingOptionViewType_switch];
        void (^musicModeCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            BJLAudioQuality quality = (tag == 0) ? BJLAudioQualityMusic : BJLAudioQualityDefault;
            BJLError *error = [self.room.recordingVM updateAudioQuality:quality];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        };
        [musicMode addSwitchMenuWithTitles:@[BJLLocalizedString(@"启用"), BJLLocalizedString(@"不启用")] selectedIndex:1 callback:musicModeCallback];
        [otherOptions addObject:musicMode];
        self.musicMode = musicMode;
    }

    if (self.room.featureConfig.enableUseHandWritingBoard) {
        BJLSettingOptionView *blutooth = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"蓝牙设备：") viewType:BJLSettingOptionViewType_button];
        void (^blutoothCallback)(NSInteger tag) = ^(NSInteger tag) {
            bjl_strongify(self);
            if (self.showHandWritingBoardViewCallback) {
                self.showHandWritingBoardViewCallback();
            }
        };
        [blutooth addButtonActionWithTile:BJLLocalizedString(@"连接") acitonCallback:blutoothCallback];

        self.bluetoothDeviceButton = [self makeHandWritingBoardButtonWithText:@""];
        [blutooth addCustomButtonView:self.bluetoothDeviceButton];
        [otherOptions addObject:blutooth];
        self.blutooth = blutooth;
    }

    [dataSource setObject:otherOptions forKey:BJLSettingMenuOptionKey_other];

#ifdef DEBUG
    BJLSettingOptionView *debug = [[BJLSettingOptionView alloc] initWithLeftTitle:BJLLocalizedString(@"信令服务器类型：") viewType:BJLSettingOptionViewType_switch];
    [debug addSwitchMenuWithTitles:@[@"ws", @"kcp"] selectedIndex:[self.room usingKCP] ? 1 : 0 callback:^(NSInteger tag){}];
    self.debug = debug;

    [dataSource setObject:@[debug] forKey:BJLSettingMenuOptionKey_debug];
#endif

    self.rightDataSource = dataSource.copy;
    self.supportChangeAfterLiveStartSwitches = [supportChangeAfterLiveStartSwitches copy];

#pragma mark - left

    NSMutableArray *leftContainerViewDataSource = [@[
        @{BJLSettingMenuOptionKeyString: BJLSettingMenuOptionKey_camera, BJLSettingMenuOptionNameString: BJLLocalizedString(@"摄像头")},
        @{BJLSettingMenuOptionKeyString: BJLSettingMenuOptionKey_mic, BJLSettingMenuOptionNameString: BJLLocalizedString(@"麦克风")},
        @{BJLSettingMenuOptionKeyString: BJLSettingMenuOptionKey_roomcontrol, BJLSettingMenuOptionNameString: BJLLocalizedString(@"房间控制")},
        @{BJLSettingMenuOptionKeyString: BJLSettingMenuOptionKey_ppt, BJLSettingMenuOptionNameString: BJLLocalizedString(@"课件相关")},
    ] mutableCopy];

    if (self.room.featureConfig.playerType == BJLPlayerType_BRTC
        || self.room.featureConfig.playerType == BJLPlayerType_BRTC_TRTC
        || self.room.featureConfig.playerType == BJLPlayerType_TRTC) {
        [leftContainerViewDataSource addObject:@{BJLSettingMenuOptionKeyString: BJLSettingMenuOptionKey_beauty, BJLSettingMenuOptionNameString: BJLLocalizedString(@"美颜滤镜")}];
    }
    if ([self.rightDataSource bjl_objectForKey:BJLSettingMenuOptionKey_other].count) {
        [leftContainerViewDataSource addObject:@{BJLSettingMenuOptionKeyString: BJLSettingMenuOptionKey_other, BJLSettingMenuOptionNameString: BJLLocalizedString(@"其他")}];
    }
#ifdef DEBUG
    if ([self.rightDataSource bjl_objectForKey:BJLSettingMenuOptionKey_debug].count) {
        [leftContainerViewDataSource addObject:@{BJLSettingMenuOptionKeyString: BJLSettingMenuOptionKey_debug, BJLSettingMenuOptionNameString: BJLLocalizedString(@"Debug")}];
    }
#endif
    self.leftContainerViewDataSource = [leftContainerViewDataSource copy];
}

- (UIButton *)makeHandWritingBoardButtonWithText:(nullable NSString *)text {
    BJLButton *button = [BJLImageRightButton new];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    button.layer.cornerRadius = 3.0;
    button.layer.masksToBounds = YES;

    [button bjl_setTitle:text forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    [button bjl_setBackgroundImage:[UIImage bjl_imageWithColor:[UIColor bjl_colorWithHex:0X9fa8b5 alpha:0.2]] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];

    bjl_weakify(button);
    [button bjl_kvo:BJLMakeProperty(button.titleLabel, text)
           observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
               bjl_strongify(button);
               button.hidden = !button.titleLabel.text.length;
               return YES;
           }];
    button.intrinsicContentSize = CGSizeMake(140.0, BJLScButtonSizeS);
    return button;
}

- (void)makeObservingAndActions {
    bjl_weakify(self);

    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, liveStarted) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        // 音视频开关
        BOOL mediaEnabled = NO;
        if (self.room.loginUser.isTeacherOrAssistant) {
            mediaEnabled = self.room.roomVM.liveStarted;
        }
        else {
            mediaEnabled = (!self.room.loginUser.isAudition
                            && (self.room.speakingRequestVM.speakingEnabled
                                || self.room.roomInfo.roomType != BJLRoomType_1vNClass)
                            && self.room.roomVM.liveStarted);
        }
        [self.mic setEnable:mediaEnabled];
        [self.camera setEnable:mediaEnabled];

        // 其他功能switch开关
        [self.supportChangeAfterLiveStartSwitches enumerateObjectsUsingBlock:^(BJLSettingOptionView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            bjl_strongify(self);
            [obj setEnable:self.room.roomVM.liveStarted];
        }];

        // 本地采集分辨率
        [self updateVideoDefinitionEnable];

        // 上下行链路
        BOOL enableDownLinkTypeChange = !self.room.featureConfig.isWebRTC && self.room.roomVM.liveStarted;
        BOOL enableUpLinkTypeChange = enableDownLinkTypeChange && !self.room.roomInfo.isPushLive && !self.room.roomInfo.isMockLive;

        [self.upLink setEnable:enableUpLinkTypeChange];
        [self.downLink setEnable:enableDownLinkTypeChange];
        [self updateMirrorButtonStatus];
        return YES;
    }];

    [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingEnabled)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BOOL mediaEnabled = NO;
             if (self.room.loginUser.isTeacherOrAssistant) {
                 mediaEnabled = self.room.roomVM.liveStarted;
             }
             else {
                 mediaEnabled = (!self.room.loginUser.isAudition
                                 && (self.room.speakingRequestVM.speakingEnabled
                                     || self.room.roomInfo.roomType != BJLRoomType_1vNClass)
                                 && self.room.roomVM.liveStarted);
             }
             [self.mic setEnable:mediaEnabled];
             [self.camera setEnable:mediaEnabled];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingAudio)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.mic updateSelectedIndex:now.boolValue ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingVideo)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.camera updateSelectedIndex:now.boolValue ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, videoBeautifyLevel)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.beautifySwitch updateSelectedIndex:(self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_on) ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.mediaVM, supportBackgroundAudio)
         observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.backgroundAudio updateSelectedIndex:now.boolValue ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, showPPTRemarkInfo)
         observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.pptRemark updateSelectedIndex:self.room.slideshowViewController.showPPTRemarkInfo ? 0 : 1];
             return YES;
         }];

    // 大班老师/助教只需要监听全体禁言状态变化, 线上双师的班型, 助教的groupID会变化
    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.chatVM, forbidAll),
        BJLMakeProperty(self.room.chatVM, forbidMyGroup)]
              observer:^(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  BOOL forbid = NO;
                  if (self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.noGroup) {
                      forbid = self.room.chatVM.forbidAll;
                  }
                  else {
                      forbid = self.room.chatVM.forbidAll || self.room.chatVM.forbidMyGroup;
                  }
                  [self.allProhibitions updateSelectedIndex:forbid ? 0 : 1];
              }];

    [self bjl_kvo:BJLMakeProperty(self.room, loginUser)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             NSString *title = (@"全体禁言");
             if (self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.noGroup) {
                 title = BJLLocalizedString(@"全体禁言");
             }
             else {
                 title = BJLLocalizedString(@"本组禁言");
             }
             [self.allProhibitions updateLeftTitle:title];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, forbidSpeakingRequest)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.forbidHandsUp updateSelectedIndex:now.boolValue ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, forbidAllRecordingAudio)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.allForbidSpeak updateSelectedIndex:now.boolValue ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, viewType)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.pptContentMode setEnable:self.room.slideshowViewController.viewType == BJLPPTViewType_Native];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, contentMode)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BJLContentMode contentMode = now.integerValue;
             [self.pptContentMode updateSelectedIndex:(contentMode == BJLContentMode_scaleAspectFit) ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.documentVM, forbidStudentChangePPT)
         observer:^BJLControlObserving(NSNumber *_Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.studentPageChange updateSelectedIndex:value.bjl_boolValue ? 1 : 0];
             return YES;
         }];

    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.documentVM, allDocuments),
        BJLMakeProperty(self.room, disablePPTAnimation)]
              observer:^(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  BOOL hasAnimatedPPT = NO;
                  BOOL hasWebDoc = NO;
                  for (BJLDocument *document in self.room.documentVM.allDocuments) {
                      if (document.isAnimate) {
                          hasAnimatedPPT = YES;
                      }
                      if (document.pageInfo.isWebDoc) {
                          hasAnimatedPPT = YES;
                          hasWebDoc = YES;
                          break;
                      }
                  }
                  BOOL isWebDoc = (hasWebDoc || hasAnimatedPPT) && !self.room.featureConfig.disablePPTAnimation && !self.room.disablePPTAnimation;
                  [self.pptAnimation setEnable:(hasWebDoc || hasAnimatedPPT) && !self.room.featureConfig.disablePPTAnimation];
                  [self.pptAnimation updateSelectedIndex:isWebDoc ? 0 : 1];
              }];

    // 清晰度
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, videoDefinition)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BJLVideoDefinition videoDefinition = now.integerValue;
             NSInteger index = videoDefinition == BJLVideoDefinition_std ? 0 : (videoDefinition == BJLVideoDefinition_high ? 1 : 2);
             if (self.room.featureConfig.support720p && videoDefinition == BJLVideoDefinition_1080p && self.room.featureConfig.playerType != BJLPlayerType_BJYRTC) {
                 index = 3;
             }
             [self.definitionOptionView updateSelectedIndex:index];
             return YES;
         }];
    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.recordingVM, hasAsCameraUser),
        BJLMakeProperty(self, definitionOptionView)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updateVideoDefinitionEnable];
              }];

    // 前后摄像头
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingVideo)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BOOL enableCamera = self.room.recordingVM.recordingVideo && !self.room.recordingVM.hasAsCameraUser;
             [self.cameraSwitchView setEnable:enableCamera];
             [self.beauty setEnable:enableCamera];
             if (!enableCamera) {
                 // 关闭摄像头时, 关闭开关
                 [self.beauty updateSelectedIndex:1];
                 [self.beautyView beautyOn:NO];
                 [self.whitenessView beautyOn:NO];
             }
             else {
                 BOOL beautyShouldOn = NO;
                 if (self.room.recordingVM.beautyLevel > 0 || self.room.featureConfig.enableBeauty) {
                     [self.beautyView beautyOn:YES];
                     [self.room.recordingVM updateBeautyLevel:self.room.recordingVM.beautyLevel];
                     beautyShouldOn = YES;
                 }
                 if (self.room.recordingVM.whitenessLevel > 0 || self.room.featureConfig.enableBeauty) {
                     [self.whitenessView beautyOn:YES];
                     [self.room.recordingVM updateWhitenessLevel:self.room.recordingVM.whitenessLevel];
                     beautyShouldOn = YES;
                 }
                 [self.beauty updateSelectedIndex:beautyShouldOn ? 0 : 1];
             }
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, usingRearCamera)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BOOL usingRearCamera = now.boolValue;
             [self.cameraSwitchView updateSelectedIndex:usingRearCamera ? 1 : 0];
             return YES;
         }];

    // 链路切换
    [self bjl_kvo:BJLMakeProperty(self.room.mediaVM, upLinkType)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BJLLinkType upLinkType = now.integerValue;
             [self.upLink updateSelectedIndex:(upLinkType == BJLLinkType_TCP) ? 0 : 1];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.mediaVM, downLinkType)
         observer:^BOOL(NSNumber *_Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             BJLLinkType downLinkType = now.integerValue;
             [self.downLink updateSelectedIndex:(downLinkType == BJLLinkType_TCP) ? 0 : 1];
             return YES;
         }];

    // 镜像
    [self bjl_kvoMerge:@[BJLMakeProperty(self.room.recordingVM, hasHorizontalMirrorUser),
        BJLMakeProperty(self.room.recordingVM, hasHorizontalUnmirrorUser),
        BJLMakeProperty(self.room.recordingVM, hasVerticalMirrorUser),
        BJLMakeProperty(self.room.recordingVM, hasVerticalUnmirrorUser)]
              observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                  bjl_strongify(self);
                  [self updateMirrorButtonStatus];
              }];

    // 蓝牙
    [self bjl_kvo:BJLMakeProperty(self.room.drawingVM, connectedHandWritingBoard)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             NSString *prevConnectedWritingBoardName = [BJLHandWritingBoardDeviceViewController prevConnectedWritingBoard].name;
             [self.bluetoothDeviceButton setTitleColor:self.room.drawingVM.connectedHandWritingBoard ? BJLTheme.viewTextColor : BJLTheme.buttonBorderColor forState:UIControlStateNormal];
             [self.bluetoothDeviceButton setTitle:self.room.drawingVM.connectedHandWritingBoard.name ?: prevConnectedWritingBoardName ?
                                                                                                                                      : @""
                                         forState:UIControlStateNormal];
             [self.bluetoothDeviceButton setImage:self.room.drawingVM.connectedHandWritingBoard ? [UIImage bjl_imageNamed:@"bjl_bluetooth_connected"] : nil forState:UIControlStateNormal];
             self.bluetoothDeviceButton.hidden = !self.room.drawingVM.connectedHandWritingBoard && !prevConnectedWritingBoardName;
             return YES;
         }];

    // 音频质量
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, audioQuality)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self.musicMode updateSelectedIndex:self.room.recordingVM.audioQuality == BJLAudioQualityMusic ? 0 : 1];
             return YES;
         }];
}

#pragma mark - 镜像

- (BOOL)enableVideoHorizontalMirror {
    if (self.room.featureConfig.isWebRTC
        && self.room.loginUser.isTeacherOrAssistant
        && !self.room.roomInfo.isPushLive
        && !self.room.roomInfo.isMockLive
        && self.room.featureConfig.videoMirrorMode != BJLVideoMirrorModeDisable) {
        return YES;
    }
    return NO;
}

- (BOOL)enableVideoVerticalMirror {
    if (self.room.featureConfig.isWebRTC
        && self.room.loginUser.isTeacherOrAssistant
        && !self.room.roomInfo.isPushLive
        && !self.room.roomInfo.isMockLive
        && (self.room.featureConfig.videoMirrorMode == BJLVideoMirrorModeVertical
            || self.room.featureConfig.videoMirrorMode == BJLVideoMirrorModeHorizontalAndVertical)) {
        return YES;
    }
    return NO;
}

- (void)updateMirrorButtonStatus {
    if (self.room.roomVM.liveStarted) {
        // 水平还原
        [self.allHorizontalFlip updateButtonEnable:self.room.recordingVM.hasHorizontalMirrorUser atIndex:0];
        [self.allHorizontalFlip updateButtonEnable:self.room.recordingVM.hasHorizontalUnmirrorUser atIndex:1];

        [self.allVerticalFlip updateButtonEnable:self.room.recordingVM.hasVerticalMirrorUser atIndex:0];
        [self.allVerticalFlip updateButtonEnable:self.room.recordingVM.hasVerticalUnmirrorUser atIndex:1];
    }
    else {
        [self.allHorizontalFlip setEnable:NO];
        [self.allVerticalFlip setEnable:NO];
    }
}

#pragma mark - 视频清晰度按钮是否可用

- (void)updateVideoDefinitionEnable {
    BOOL enableChangeVideoDefinition = self.room.roomVM.liveStarted && !self.room.roomInfo.isPushLive && !self.room.roomInfo.isMockLive && !self.room.recordingVM.hasAsCameraUser;
    [self.definitionOptionView setEnable:enableChangeVideoDefinition];
}

#pragma mark - 线路切换

- (void)showTCPLinkTypeSwitchAlertWithIsUplink:(BOOL)isUplink completion:(void (^)(NSInteger selectIndex, BOOL canceled))completion {
    if (self.room.mediaVM.upLinkTypeReadOnly) {
        [self showProgressHUDWithText:BJLLocalizedString(@"暂时不能切换线路")];
        return;
    }
    if (self.room.featureConfig.isWebRTC) {
        [self showProgressHUDWithText:BJLLocalizedString(@"该房间不能切换链路类型")];
        return;
    }

    NSString *title = isUplink ? BJLLocalizedString(@"选择上行 TCP 线路") : BJLLocalizedString(@"选择下行 TCP 线路");
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:title
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];

    NSUInteger availableCDNCount = isUplink ? self.room.mediaVM.upLinkCDNCount : self.room.mediaVM.downLinkCDNCount;
    NSInteger currentIndex = isUplink ? self.room.mediaVM.upLinkCDNIndex : self.room.mediaVM.downLinkCDNIndex;
    BOOL isTCPNow = isUplink ? (self.room.mediaVM.upLinkType == BJLLinkType_TCP) : (self.room.mediaVM.downLinkType == BJLLinkType_TCP);

    // autoSwitch
    NSString *checkedString = BJLLocalizedString(@" ✓");
    BOOL autoSwitch = (currentIndex < 0 || currentIndex > availableCDNCount) && isTCPNow;
    UIAlertAction *autoSwitchAction = [alertController bjl_addActionWithTitle:[NSString stringWithFormat:BJLLocalizedString(@"自动%@"), autoSwitch ? checkedString : @""]
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                                          // bjl_strongify(self);
                                                                          if (completion) {
                                                                              completion(NSNotFound, NO);
                                                                          }
                                                                      }];
    autoSwitchAction.enabled = !autoSwitch;

    for (NSInteger index = 0; index < availableCDNCount; index++) {
        // switchAction
        BOOL selected = (currentIndex == index && isTCPNow);
        UIAlertAction *switchAction = [alertController bjl_addActionWithTitle:[NSString stringWithFormat:BJLLocalizedString(@"线路 %td%@"), index + 1, selected ? checkedString : @""]
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                                          // bjl_strongify(self);
                                                                          if (completion) {
                                                                              completion(index, NO);
                                                                          }
                                                                      }];
        switchAction.enabled = !selected;
    }

    // cancel
    [alertController bjl_addActionWithTitle:BJLLocalizedString(@"取消")
                                      style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction *_Nonnull action) {
                                        // bjl_strongify(self);
                                        if (completion) {
                                            completion(NSNotFound, YES);
                                        }
                                    }];

    alertController.popoverPresentationController.sourceView = isUplink ? self.upLink : self.downLink;
    alertController.popoverPresentationController.sourceRect = [UIApplication sharedApplication].statusBarFrame;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;

    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end
