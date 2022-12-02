//
//  BJPRoomViewController+protected.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/23.
//
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJPRoomViewController+observer.h"
#import "BJPRoomViewController+control.h"
#import "BJPRoomViewController+ui.h"
#import "BJPAppearance.h"
#import "BJPSliderView.h"
#import "BJPFullScreenContainerView.h"
#import "BJPThumbnailContainerView.h"
#import "BJPPlaybackControlView.h"
#import "BJPMediaSettingView.h"
#import "BJPControlView.h"
#import "BJPChatMessageViewController.h"
#import "BJPUsersViewController.h"
#import "BJPImageBrowserViewController.h"
#import "BJPOverlayViewController.h"
#import "MBProgressHUD+bjpb.h"
#import "BJPAnswerSheetViewController.h"
#import "BJPAnswerResultViewController.h"
#import "BJPQuizWebViewController.h"
#import "BJPQuestionViewController.h"
#import "BJPNoticeViewController.h"
#import "BJPCatalogueViewController.h"
#import <BJVideoPlayerCore/BJVLampConstructor.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPRoomViewController () {
    BOOL _chatMessageHidden;
}

@property (nonatomic, readonly) BJPFullScreenContainerView *fullScreenContainerView;
@property (nonatomic, readonly) BJPThumbnailContainerView *thumbnailContainerView;
@property (nonatomic, readonly) BJPPlaybackControlView *playbackControlView;
@property (nonatomic, readonly) BJPMediaSettingView *mediaSettingView;
@property (nonatomic, nullable) BJPControlView *controlView;
@property (nonatomic, nullable) BJPChatMessageViewController *messageViewContrller;
@property (nonatomic, nullable) BJPUsersViewController *usersViewController;
@property (nonatomic, readonly) BJPImageBrowserViewController *imageBrowserViewController;
@property (nonatomic, readonly) BJPOverlayViewController *overlayViewController;

@property (nonatomic, readonly) UIView *controlLayer, *quizContainLayer, *pptcatalogueLayer;
@property (nonatomic, nullable) UIView *cloudVideoLayer;
@property (nonatomic, nullable) UIView *cloudVideoWrapperView;
@property (nonatomic, nullable) BJPAnswerSheetViewController *answerSheetViewController;
@property (nonatomic, nullable) BJPAnswerResultViewController *answerSheetResultViewController;
@property (nonatomic, nullable) BJPQuizWebViewController *quizWebViewController;
@property (nonatomic, nullable) BJPQuestionViewController *questionViewController;
@property (nonatomic, nullable) BJPNoticeViewController *noticeViewController;
@property (nonatomic, nullable) BJPCatalogueViewController *catalogueViewController;
@property (nonatomic, nullable) BJLScreenCaptureAlertMaskView *screenCaptureAlertView;

@property (nonatomic, readonly) UIView *lampView;
@property (nonatomic, nullable) BJVLampConstructor *lampConstructor;

@property (nonatomic, nullable) UIImageView *audioOnlyImageView;

@property (nonatomic, nullable) BJPPlaybackOptions *playbackOptions;
@property (nonatomic, nullable) BJLAFNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, assign) BOOL pauseByInterrupt;
@property (nonatomic, readonly) NSArray<NSNumber *> *rateList;
@property (nonatomic) CGFloat videoRatio;
@property (nonatomic) BOOL disablePortrait; // 直播间是否支持竖屏作为一个固定的属性存储，确定后不再改变，避免因为 room 的销毁影响 UI

// !!!: just for test
@property (nonatomic) NSMutableDictionary *userVideoDictM;

- (void)askToExit;

@end

NS_ASSUME_NONNULL_END
