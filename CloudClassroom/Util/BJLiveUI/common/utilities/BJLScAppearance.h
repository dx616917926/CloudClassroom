//
//  BJLScAppearance.h
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLViewControllerImports.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

#define BJLScViewSpaceS                  5.0
#define BJLScViewSpaceM                  10.0
#define BJLScViewSpaceL                  15.0

#define BJLScControlSize                 44.0

#define BJLScButtonSizeS                 30.0
#define BJLScButtonSizeM                 36.0
#define BJLScButtonSizeL                 46.0
#define BJLScButtonCornerRadius          3.0
#define BJLScRedDotWidth                 18.0
#define BJLScMessageOperatorButtonSize   32.0

#define BJLScBadgeSize                   20.0
#define BJLScScrollIndicatorSize         8.5 // 8.5 = 2.5 + 3.0 * 2

#define BJLScAnimateDurationS            0.2
#define BJLScAnimateDurationM            0.4
#define BJLScRobotDelayS                 1.0
#define BJLScRobotDelayM                 2.0

#define BJLScTopBarHeight                32.0
#define BJLScSegmentWidth                240.0

#define BJLScOverlayImageMinSize         32.0
#define BJLScOverlayImageMaxSize         480.0

#define BJLScUserWindowDefaultBarHeight  24.0
#define BJLScBlackboardAspectRatio       4.0 / 3.0

#define BJLScAnswerOptionButtonHeight    36.0
#define BJLScUserOperateViewButtonHeight 50.0

// toolView
#define BJLScToolViewWidth               ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 24.0 : 44.0)
#define BJLScToolViewButtonWidth         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22.0 : 32.0)
#define BJLScToolViewButtonSpace         4.0
#define BJLScToolViewCornerRadius        2.0
#define BJLScToolViewColorLength         (BJLScToolViewButtonWidth * 0.75)
#define BJLScToolViewColorSize           ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 2.0 : 4.0)
#define BJLScToolViewDrawOffset          4.0
#define BJLScToolViewDrawSpace           6.0
#define BJLScToolViewDrawButtonSize      32.0
#define BJLScToolViewFontIconSize        20.0
#define BJLScToolViewDrawFontSize        24.0

#pragma mark -

/** 窗口类型 */
typedef NS_ENUM(NSInteger, BJLScWindowType) {
    BJLScWindowType_none, // 空类型
    BJLScWindowType_ppt, // ppt窗口 或 老师辅助摄像头窗口，需要根据是否存在辅助摄像头视图来决定
    BJLScWindowType_userVideo, // 除老师外的窗口
    BJLScWindowType_teacherVideo, // 老师窗口
};

#pragma mark -

@interface UIColor (BJLSurfaceClass)

// common
@property (class, nonatomic, readonly) UIColor
    *bjlsc_darkGrayBackgroundColor,
    *bjlsc_lightGrayBackgroundColor,

    *bjlsc_darkGrayTextColor,
    *bjlsc_grayTextColor,
    *bjlsc_lightGrayTextColor,

    *bjlsc_grayBorderColor,
    *bjlsc_grayLineColor,
    *bjlsc_grayImagePlaceholderColor, // == bjlsc_grayLineColor

    *bjlsc_blueBrandColor,
    *bjlsc_orangeBrandColor,
    *bjlsc_redColor;

// dim
@property (class, nonatomic, readonly) UIColor
    *bjlsc_lightDimColor, // black-0.2
    *bjlsc_dimColor, // black-0.5
    *bjlsc_darkDimColor; // black-0.6

@end

#pragma mark -

@interface UIImage (BJLSurfaceClass)

+ (UIImage *)bjlsc_imageNamed:(NSString *)name;

@end

#pragma mark -

@interface UIButton (BJLButtons)

+ (instancetype)makeTextButtonDestructive:(BOOL)destructive;
+ (instancetype)makeRoundedRectButtonHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
