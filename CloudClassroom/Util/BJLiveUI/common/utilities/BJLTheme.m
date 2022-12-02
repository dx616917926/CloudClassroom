//
//  BJLTheme.m
//  BJLiveUI
//
//  Created by xijia dai on 2020/6/12.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLTheme.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLTheme () <BJLYYModel>

#pragma mark - 支持的配置项，根据需要增删

@property (nonatomic) NSString *brandColor;

@property (nonatomic) NSString *viewTextColor;
@property (nonatomic) NSString *viewSubTextColor;
@property (nonatomic) NSString *buttonBorderColor;
@property (nonatomic) NSString *buttonNormalBackgroundColor;

@property (nonatomic) NSString *buttonTextColor;
@property (nonatomic) NSString *subButtonTextColor;
@property (nonatomic) NSString *subButtonBackgroundColor;
@property (nonatomic) NSString *buttonDisableTextColor;

/** room */
@property (nonatomic) NSString *roomBackgroundColor;

/** blackboard */
@property (nonatomic) NSString *blackboardColor;

/** separate Line color */
@property (nonatomic) NSString *separateLineColor;

/** user list */
@property (nonatomic) NSString *userCellRoleAssistantColor;
@property (nonatomic) NSString *userCellRolePresenterColor;

/** userMediaInfoView */
@property (nonatomic) NSString *userViewBackgroundColor;

/** overlay */
@property (nonatomic) NSString *overlayBackgroundColor;

/** 教具窗口: 小黑板, 答题器, 抢答器, 网页, 计时器 */
@property (nonatomic) NSString *windowBackgroundColor;

/** status bar */
@property (nonatomic) NSString *statusBackgroungColor;
@property (nonatomic) NSString *toolButtonTitleColor;
@property (nonatomic) NSString *statusNormalColor;

/** toolbox */
@property (nonatomic) NSString *toolboxBackgroundColor;
@property (nonatomic) NSString *toolboxFontBackgroundColor;

/** warning color */
@property (nonatomic) NSString *warningColor;

@end

@implementation BJLTheme

static BJLTheme *_Nullable sharedInstance = nil;

+ (void)setupColorWithConfig:(nullable NSDictionary *)config {
    if (!sharedInstance) {
        sharedInstance = [BJLTheme new];
    }
    if (config) {
        [sharedInstance bjlyy_modelSetWithJSON:config];
    }
}

+ (BOOL)hasInitial {
    return sharedInstance != nil;
}

+ (void)destroy {
    sharedInstance = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupDefaultColorConfig];
    }
    return self;
}

// 初始化默认的颜色
- (void)setupDefaultColorConfig {
    self.brandColor = @"#1795FF"; // b-1
    BOOL white = YES;

    if (white) {
        // 白色主题
        // window
        self.windowBackgroundColor = @"#FFFFFF"; // b-2 #313847

        // toolbox
        self.toolboxBackgroundColor = @"#FFFFFF"; // b-2  313847 + 0.9透明度

        // room
        self.roomBackgroundColor = @"#F1F3FA"; //b-3 161D2B

        // blackboard
        self.blackboardColor = @"#FBFBFE"; //b-4 242A36

        // text
        self.viewTextColor = @"#333333"; //b-6 FFFFFF
    }
    else {
        // 深色主题
        // window
        self.windowBackgroundColor = @"#313847"; // b-2 #

        // toolbox
        self.toolboxBackgroundColor = @"#313847"; // b-2 + 0.9透明度

        // room
        self.roomBackgroundColor = @"#161D2B"; //b-3

        // blackboard
        self.blackboardColor = @"#242A36"; //b-4

        // text
        self.viewTextColor = @"#FFFFFF"; //b-6
    }

    // 以下变量在深浅模式都暂时不会有颜色变化
    self.buttonTextColor = @"#FFFFFF"; // b-10

    self.viewSubTextColor = @"#999999"; // 副内容文字b-7
    self.buttonBorderColor = @"#9FA8B5"; // +0.5透明度
    self.buttonNormalBackgroundColor = @"#9FA8B5";
    self.subButtonTextColor = @"#666666"; // b-9
    self.subButtonBackgroundColor = @"#EEEEEE"; // b-8
    self.buttonDisableTextColor = @"#BDC6CF"; // 灰色按钮的浅黑色文字

    // separateLineColor
    self.separateLineColor = @"#9FA8B5"; // +0.2透明度

    // user list
    self.userCellRoleAssistantColor = @"#FA6400";
    self.userCellRolePresenterColor = @"#1795FF";

    // userVideo
    self.userViewBackgroundColor = @"#313847";

    // overlay
    self.overlayBackgroundColor = @"#313847";

    // status
    self.statusBackgroungColor = @"#9FA8B5"; // +0.15透明度
    self.toolButtonTitleColor = @"#9FA8B5"; // b5
    self.statusNormalColor = @"#A8B0BC";

    self.toolboxFontBackgroundColor = @"#3E4651";

    // warning color
    self.warningColor = @"#FF1F49";
}

// 支持服务端配置的值需要在此处解析
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        // 主题色
        BJLInstanceKeypath(BJLTheme, brandColor): @"b1",
        BJLInstanceKeypath(BJLTheme, buttonTextColor): @"b10",
        // 黑板
        BJLInstanceKeypath(BJLTheme, blackboardColor): @"b4",
        // 窗口色
        BJLInstanceKeypath(BJLTheme, roomBackgroundColor): @"b3",
        BJLInstanceKeypath(BJLTheme, windowBackgroundColor): @"b2",
        BJLInstanceKeypath(BJLTheme, toolboxBackgroundColor): @"b2",
        BJLInstanceKeypath(BJLTheme, toolButtonTitleColor): @"b5",
        // 字体颜色
        BJLInstanceKeypath(BJLTheme, viewSubTextColor): @"b7",
        BJLInstanceKeypath(BJLTheme, viewTextColor): @"b6",
        BJLInstanceKeypath(BJLTheme, subButtonTextColor): @"b9",
        BJLInstanceKeypath(BJLTheme, subButtonBackgroundColor): @"b8",
    };
}

#pragma mark - public

+ (BJLThemeStyle)themeStyle {
    // 暂时使用窗口背景是否是白色区分深色和浅色模式
    return ![sharedInstance.windowBackgroundColor.uppercaseString isEqualToString:@"#FFFFFF"] ? BJLThemeStyle_dark : BJLThemeStyle_light;
}

+ (UIColor *)brandColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.brandColor] ?: [UIColor clearColor];
}

#pragma mark - text

+ (UIColor *)viewTextColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.viewTextColor] ?: [UIColor clearColor];
}

+ (UIColor *)viewSubTextColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.viewSubTextColor] ?: [UIColor clearColor];
}

+ (UIColor *)buttonBorderColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.buttonBorderColor alpha:0.5] ?: [UIColor clearColor];
}

+ (UIColor *)buttonNormalBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.buttonNormalBackgroundColor] ?: [UIColor clearColor];
}

+ (UIColor *)buttonLightBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.buttonNormalBackgroundColor alpha:0.1] ?: [UIColor clearColor];
    ;
}

+ (UIColor *)buttonTextColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.buttonTextColor] ?: [UIColor clearColor];
}

+ (UIColor *)subButtonTextColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.subButtonTextColor] ?: [UIColor clearColor];
}

+ (UIColor *)subButtonBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.subButtonBackgroundColor] ?: [UIColor clearColor];
}

+ (UIColor *)buttonDisableTextColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.buttonDisableTextColor] ?: [UIColor clearColor];
}

#pragma mark - room

+ (UIColor *)roomBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.roomBackgroundColor] ?: [UIColor clearColor];
}

#pragma mark - blackboard

+ (UIColor *)blackboardColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.blackboardColor] ?: [UIColor clearColor];
}

#pragma mark - separate Line color

+ (UIColor *)separateLineColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.separateLineColor alpha:0.2] ?: [UIColor clearColor];
}

#pragma mark - user list

+ (UIColor *)userCellRoleAssistantColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.userCellRoleAssistantColor] ?: [UIColor clearColor];
}

+ (UIColor *)userCellRolePresenterColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.userCellRolePresenterColor] ?: [UIColor clearColor];
}

#pragma mark - userMediaInfoView

+ (UIColor *)userViewBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.userViewBackgroundColor] ?: [UIColor clearColor];
}

#pragma mark - overlay

+ (UIColor *)overlayBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.overlayBackgroundColor alpha:0.5] ?: [UIColor clearColor];
}

#pragma mark -

+ (UIColor *)windowBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.windowBackgroundColor] ?: [UIColor clearColor];
}

+ (UIColor *)windowShadowColor {
    return [UIColor colorWithWhite:0 alpha:0.2] ?: [UIColor clearColor];
}

#pragma mark - status bar

+ (UIColor *)statusBackgroungColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.statusBackgroungColor alpha:0.15] ?: [UIColor clearColor];
}

+ (UIColor *)toolButtonTitleColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.toolButtonTitleColor] ?: [UIColor clearColor];
}

+ (UIColor *)statusNormalColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.statusNormalColor] ?: [UIColor clearColor];
}
#pragma mark - toolbox

+ (UIColor *)toolboxBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.toolboxBackgroundColor alpha:0.9] ?: [UIColor clearColor];
}

+ (UIColor *)toolboxFontBackgroundColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.toolboxFontBackgroundColor] ?: [UIColor clearColor];
}

#pragma mark - warning

+ (UIColor *)warningColor {
    return [UIColor bjl_colorWithHexString:sharedInstance.warningColor] ?: [UIColor clearColor];
}

@end

NS_ASSUME_NONNULL_END
