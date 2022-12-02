//
//  BJLWindowViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2018-09-18.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

// 枚举保持优先级递增的顺序，优先级高的往往显示在优先级低的窗口上面
typedef NS_ENUM(NSInteger, BJLWindowState) {
    BJLWindowState_closed,
    // BJLWindowState_minimized,
    BJLWindowState_windowed,
    BJLWindowState_maximized,
    BJLWindowState_fullscreen
};

@interface BJLWindowViewController: UIViewController

@property (nonatomic, readonly) BJLWindowState state;
@property (nonatomic, readonly) BJLWindowState windowedState;

@property (nonatomic, nullable, copy) void (^windowUpdateCallback)(NSString *action, CGRect relativeRect);
@property (nonatomic, nullable, copy) void (^singleTapGestureCallback)(CGPoint point);
// 窗口的最大化、还原、全屏按钮被点击的回调，回调会早于窗口的行为执行，特别的，主动调用的最大化、还原、全屏操作将不会触发该回调
@property (nonatomic, copy, nullable) void (^didWindowStateUserChanged)(BJLWindowState state);

- (void)setWindowedParentViewController:(UIViewController *)parentViewController
                              superview:(nullable UIView *)superview; // parentViewController.view

- (void)setFullscreenParentViewController:(UIViewController *)parentViewController
                                superview:(nullable UIView *)superview; // parentViewController.view

- (void)open; // windowed
// - (void)minimize;   // minimized
- (void)maximize; // maximized
- (void)fullscreen; // fullscreen
- (void)restore; // windowed || maximized
- (void)restoreToWindow; // windowed
- (void)restoreToMaximize; // maximized
- (void)close; // closed
- (void)updateWithRelativeRect:(CGRect)relativeRect;
- (void)bringToFront;

- (void)openWithoutRequest;
- (void)maximizeWithoutRequest;
- (void)fullScreenWithoutRequest;
- (void)restoreWithoutRequest;
- (void)restoreToWindowWithoutRequest;
- (void)restoreToMaximizeWithoutRequest;
- (void)closeWithoutRequest;
- (void)bringToFrontWithoutRequest;
- (void)sendToBackWithoutRequest;

@end

NS_ASSUME_NONNULL_END
