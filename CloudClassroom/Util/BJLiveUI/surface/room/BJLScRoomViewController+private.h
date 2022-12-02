//
//  BJLScRoomViewController+private.h
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.

#import <BJLiveBase/BJLScreenCaptureAlertMaskView.h>

#import "BJLScRoomViewController.h"
#import "BJLScRoomViewController+constraints.h"
#import "BJLScRoomViewController+observing.h"
#import "BJLScRoomViewController+actions.h"
#import "BJLScAppearance.h"
#import "BJLScTopBarViewController.h"
#import "BJLScVideosViewController.h"
#import "BJLScMediaInfoView.h"
#import "BJLScVideoPlaceholderView.h"
#import "BJLScOverlayViewController.h"
#import "BJLScPPTQuickSlideViewController.h"
#import "BJLScSegmentViewController.h"
#import "BJLScUserViewController.h"
#import "BJLScChatViewController.h"
#import "BJLScSettingsViewController.h"
#import "BJLNoticeViewController.h"
#import "BJLNoticeEditViewController.h"
#import "BJLScSpeakRequestUsersViewController.h"
#import "BJLScChatInputViewController.h"
#import "BJLScQuestionInputViewController.h"
#import "BJLAnnularProgressView.h"
#import "BJLLoadingViewController.h"
#import "BJLRainEffectViewController.h"
#import "BJLCreateRainViewController.h"
#import "BJLScQuizWebViewController.h"
#import "BJLCustomWebViewController.h"
#import "BJLScEvaluationViewController.h"
#import "BJLScToolViewController.h"
#import "BJLScLotteryViewController.h"
#import "BJLQRCodeViewController.h"
#import "BJLScControlsViewController.h"
#import "BJLRollCallViewController.h"
#import "BJLDocumentFileManagerViewController.h"
#import "BJLPopoverViewController.h"
#import "BJLHandWritingBoardDeviceViewController.h"
#import "BJLPopoverViewController.h"
#import "BJLScWarmingUpView.h"
#import "BJLBonusListViewController.h"
#import "BJLStudentBonusRankViewController.h"
#import "BJLOptionViewController.h"
#import "BJLLampConstructor.h"
#import "BJLQuestionNaire.h"
#import "BJLCDNListViewController.h"
#import "BJLAlertPresentationController.h"
#import "BJLCountDownManager.h"
#import "BJLQuestionAnswerManager.h"
#import "BJLQuestionResponderManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLScRoomViewController ()
@property (nonatomic, copy) void (^exitCallbackBlock)(void);
@property (nonatomic) CGRect keyboardFrame;
@property (nonatomic, nullable) BJLProgressHUD *prevHUD;
@property (nonatomic, nullable) BJLAFNetworkReachabilityManager *reachability;
@property (nonatomic) NSMutableSet *autoPlayVideoBlacklist;
@property (nonatomic) BJLScWindowType majorWindowType; // 大屏可以是除 BJLScWindowType_none 外的任意类型
@property (nonatomic) BJLScWindowType minorWindowType; // 小屏只能是 BJLScWindowType_ppt 或 BJLScWindowType_teacherVideo
@property (nonatomic) BJLScWindowType secondMinorWindowType; // 第二个小屏只能是 BJLScWindowType_ppt 或 BJLScWindowType_userVideo，目前仅为 1v1 设计
@property (nonatomic) BJLScWindowType fullscreenWindowType; // 全屏模式下的窗口类型，可以是任意类型
@property (nonatomic, readonly) BOOL is1V1Class;

@property (nonatomic) UIView *containerView;
@property (nonatomic) UIView *topBarView;
@property (nonatomic) UIView *majorContentView, *minorContentView, *secondMinorContentView;
@property (nonatomic) UIView *videosView;
@property (nonatomic) UIView *segmentView;
@property (nonatomic) BJLHitTestView *majorContentOperationView; // 和majorContent等大小的视图容器。现在用来装对majorContent进行操作的 BJLScControlsViewController
@property (nonatomic) BJLHitTestView *toolView; // 工具盒
@property (nonatomic) BJLHitTestView *lampView; // 跑马灯
@property (nonatomic, nullable) BJLLampConstructor *lampConstructor; // 跑马灯创建者
@property (nonatomic) UIView *majorNoticeView; // 主屏幕区置顶公告
@property (nonatomic) BJLHitTestView *imageViewLayer; // 聊天图片
@property (nonatomic) BJLHitTestView *fullscreenLayer; // 全屏显示的内容
@property (nonatomic) BJLHitTestView *timerLayer; // 计时器工具放在其他教具下层
@property (nonatomic) BJLHitTestView *teachAidLayer; // 答题器之类工具
@property (nonatomic) BJLHitTestView *overlayView; // 设置，公告之类的1/2页面
@property (nonatomic) BJLHitTestView *lotteryLayer; // 抽奖的layer, 仅次于popoversLayer
@property (nonatomic) BJLHitTestView *popoversLayer; // 在loadingLayer的下一层
@property (nonatomic) BJLHitTestView *loadingLayer; // 仅次于护眼层的次上层
@property (nonatomic) BJLHitTestView *eyeProtectedLayer; // 加入护眼模式,保持在最上层

@property (nonatomic) BJLScTopBarViewController *topBarViewController;
@property (nonatomic, nullable) BJLScVideosViewController *videosViewController;
@property (nonatomic, readonly) BOOL showTeacherExtraMediaInfoViewCoverPPT; // 主讲的辅助摄像头是否覆盖课件，特别的，teacherExtraMediaInfoView 的 positionType 之前和课件位置同步，因此暂未使用，使用视频列表是否存在该视图来判断在大屏区域还是视频列表区域的位置，fullscreen 属性用于判断全屏
@property (nonatomic, nullable) BJLScMediaInfoView *teacherMediaInfoView, *teacherExtraMediaInfoView, *secondMinorMediaInfoView;
@property (nonatomic, nullable, weak) BJLScMediaInfoView *fullscreenMediaInfoView;
@property (nonatomic) BJLScVideoPlaceholderView *teacherVideoPlaceholderView, *secondMinorVideoPlaceholderView;
@property (nonatomic) BJLScSegmentViewController *segmentViewController;
@property (nonatomic) BJLDocumentFileManagerViewController *pptManagerViewController;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *documentIndexDic;
@property (nonatomic) BJLScPPTQuickSlideViewController *pptQuickSlideViewController;
@property (nonatomic) BJLScOverlayViewController *overlayViewController, *fullscreenOverlayViewController;
@property (nonatomic) BJLScToolViewController *toolViewController;

// 点播暖场的view, 覆盖在老师视频窗口上
@property (nonatomic, nullable) BJLScWarmingUpView *warmingUpView;

@property (nonatomic) BJLScControlsViewController *controlsViewController;
@property (nonatomic) BOOL controlsHidden, toolHidden, questionRedDotHidden; // 状态和视图实际的状态保持一致
@property (nonatomic) UIButton *liveStartButton;

@property (nonatomic) BJLLoadingViewController *loadingViewController;
@property (nonatomic, nullable) BJLScSettingsViewController *settingsViewController;
@property (nonatomic) BJLNoticeViewController *noticeViewController;
@property (nonatomic) BJLNoticeEditViewController *noticeEditViewController;
@property (nonatomic) BJLScQuestionViewController *questionViewController;
@property (nonatomic) BJLScSpeakRequestUsersViewController *speakRequestUsersViewController;
@property (nonatomic) BJLScChatInputViewController *chatInputViewController;
@property (nonatomic) BJLScQuestionInputViewController *questionInputViewController;
@property (nonatomic) BJLCDNListViewController *switchRouteController;

@property (nonatomic, nullable) BJLRainEffectViewController *rainEffectViewController;
@property (nonatomic, nullable) BJLCreateRainViewController *createRainViewController;
@property (nonatomic, nullable) BJLScQuizWebViewController *quizWebViewController;
@property (nonatomic, nullable) BJLCustomWebViewController *customWebViewController;
@property (nonatomic, nullable) BJLQuestionNaire *questionNaire; //课前问卷

@property (nonatomic) BJLQuestionAnswerManager *questionAnswerManager;

@property (nonatomic) BJLQuestionResponderManager *questionResponderManager;

@property (nonatomic) BJLCountDownManager *countDownManager;

@property (nonatomic, nullable) BJLScEvaluationViewController *evaluationViewController;

@property (nonatomic, nullable) BJLScLotteryViewController *lotteryViewController;

// only for 1v1
@property (nonatomic) UIView *seperatorView;
@property (nonatomic) BJLScChatViewController *chatViewController;
@property (nonatomic) UIButton *chatButton;

@property (nonatomic, nullable) BJLScreenCaptureAlertMaskView *screenCaptureAlertView;
@property (nonatomic) BJLRequireFullScreenCheckFailedMaskView *requireFullScreenCheckFailedMaskView;

@property (nonatomic, nullable) BJLRollCallViewController *rollCallVC;
@property (nonatomic, nullable) BJLMajorNoticeModel *currentMajorNotice;
@property (nonatomic) NSUInteger currentMajorNoticeIndex;

@property (nonatomic, readonly, nullable) BJLBonusListViewController *bonusListVC;
@property (nonatomic, readonly, nullable) BJLStudentBonusRankViewController *studentBonusListVC;
@property (nonatomic, readonly) BJLOptionViewController *studentBonusIncreasingPopupVC;
@property (nonatomic, readonly) UILabel *studentBonusIncreasingLabel;
@property (nonatomic, copy, nullable) dispatch_block_t studentBonusIncreasingPopupDelayCloseBlock;

/// 大班课视频墙模板会有layout布局切换逻辑，仅仅在这个case下才会用到此属性
@property (nonatomic, assign) BJLRoomLayout roomLayout;

// 手写板设备列表
@property (nonatomic) BJLHandWritingBoardDeviceViewController *handWritingBoardViewController;

- (void)exit;
- (void)autoStartRecordingAudioAndVideoForce:(BOOL)force;
- (void)updateVideosConstraintsWithCurrentPlayingUsers;
- (void)showProgressHUDWithText:(NSString *)text;
- (void)roomDidExitWithError:(BJLError *)error;
- (NSString *)videoKeyForUser:(BJLMediaUser *)user;
- (void)askToExit;
- (void)addCreateEnvelopeRainView;
- (void)showRollCallViewController;
- (void)destoryBonusPointsVCIfNeeded;
@end

NS_ASSUME_NONNULL_END
