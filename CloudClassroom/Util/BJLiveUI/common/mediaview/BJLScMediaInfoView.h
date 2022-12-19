//
//  BJLScMediaInfoView.h
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/19.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLScMediaInfoView: UIView

@property (nonatomic, readonly) BJLUser *user;
@property (nonatomic, readonly, nullable) BJLMediaUser *mediaUser;
@property (nonatomic) BJLScPositionType positionType;
@property (nonatomic) BOOL isFullScreen;

/**
 用于识别是否是竖屏模板
 */
@property (nonatomic) BOOL isPortraitMode;

/**
 用于识别是否是直播带货
 */
@property (nonatomic) BOOL isSellUI;

/**
 根据 user 初始化
 #discussion 初始化的 user 可以是 BJLUser，用于采集的视频窗口，如果用采集以外的用户初始化的 BJLMediaUser，认为是一个音视频未打开的主摄像头用户；
 #discussion 也可以是 BJLMediaUser，用于播放的视频窗口
 #discussion 一般情况下 音视频未打开的主摄像头用户是不会显示窗口状态的
 #param room BJLRoom
 #param user user
 #return self
 */
- (instancetype)initWithRoom:(BJLRoom *)room user:(__kindof BJLUser *)user;

- (void)updateCloseVideoPlaceholderHidden:(BOOL)hidden;
- (void)destroyView NS_SWIFT_NAME(destroyView());

/**
 设置父控制器

 #param parentViewController parentViewController
 */
- (void)updateParentViewController:(UIViewController *)parentViewController;
@end

NS_ASSUME_NONNULL_END