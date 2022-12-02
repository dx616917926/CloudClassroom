//
//  BJLScControlsViewController.h
//  BJLiveUI
//
//  Created by xijia dai on 2020/12/21.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

#import "BJLScAppearance.h"
#import "BJLChatPanelViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLScControlsViewController: UIViewController

@property (nonatomic) BOOL controlsHidden;

@property (nonatomic, nullable) void (^handUpCallback)(void);
@property (nonatomic, nullable) void (^updateRecordingVideoCallback)(void);
@property (nonatomic, nullable) void (^updateRecordingAudioCallback)(void);
@property (nonatomic, nullable) void (^updateHandWritingBoardCallback)(BOOL connect);
@property (nonatomic, nullable) void (^scaleCallback)(void);
@property (nonatomic, nullable) void (^showNoticeCallback)(void);
@property (nonatomic, nullable) void (^showQuestionCallback)(void);
@property (nonatomic, nullable) void (^switchEyeProtectedCallback)(void);
@property (nonatomic, nullable) void (^showHomeworkViewCallback)(void);
@property (nonatomic, nullable) void (^switchWebPPTAuthCallback)(void);
@property (nonatomic, nullable) void (^updateAsCameraCallback)(void);
@property (nonatomic, nullable) void (^bonusEventCallback)(void);
@property (nonatomic, nullable) void (^switchDoubleClassCallback)(void);
@property (nonatomic, nullable) void (^showSwitchRouteCallback)(void);
@property (nonatomic, nullable) void (^moreOptionEventCallback)(void);
@property (nonatomic, nullable) void (^chatIputButtonClickCallback)(void);

// 右上侧按钮
@property (nonatomic, readonly) UIButton *moreOptionButton;
@property (nonatomic, readonly) UIButton *bonusButton;
@property (nonatomic) BJLChatPanelViewController *chatPanelViewController;

/// 如果按钮是放在顶部的，这里就是顶部需要偏移的量（用于漏出status bar）
@property (nonatomic) CGFloat controlsTopOffset;

- (instancetype)initWithRoom:(BJLRoom *)room
                  windowType:(BJLScWindowType)windowType
                  fullScreen:(BOOL)fullScreen;

- (void)setupToolView:(UIView *)view fullScreenView:(UIView *)fullScreenView;
- (void)updateControlsForWindowType:(BJLScWindowType)windowType fullScreen:(BOOL)fullScreen;
- (void)updateQuestionRedDotHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
