//
//  BJLThemeMaker.h
//  BJLiveBase
//
//  Created by MingLQ on 2020-07-06.
//  Copyright (c) 2020 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@interface UIResponder (BJLTheme)
/// getter: if self.bjl_theme is nil, returns self.nextResponder.bjl_theme
/// setter: calls view.blocks and view.subviews.blocks
@property (nonatomic, copy, setter=bjl_setTheme:, nullable) NSString *bjl_theme;
- (void)bjl_themeDidUpdate:(nullable NSString *)prevTheme NS_REQUIRES_SUPER;
@end

@protocol BJLApplicationThemeDelegate <UIApplicationDelegate>
- (void)bjl_application:(UIApplication *)application didUpdateTheme:(nullable NSString *)prevTheme;
@end

@protocol BJLWindowSceneThemeDelegate <UIWindowSceneDelegate>
- (void)bjl_windowScene:(UIWindowScene *)windowScene didUpdateTheme:(nullable NSString *)prevTheme API_AVAILABLE(ios(13.0));
@end

#pragma mark -

typedef void (^BJLThemeMaker)(__kindof UIView *view);

@interface UIView (BJLThemeMaker)

/// will swizzle `- [UIView didMoveToSuperview]`
+ (void)bjl_autoUpdateThemeWhenMovedToSuperview;

/// makers will be called when:
/// 1. [view bjl_makeTheme:]
/// 2. [view[...nextResponder] didMoveToSuperview]
/// 3. [view[...nextResponder] bjl_setTheme:]
- (id)bjl_makeTheme:(BJLThemeMaker)maker;
- (id)bjl_makeTheme:(BJLThemeMaker)maker replace:(id)receipt;
- (id)bjl_remakeTheme:(BJLThemeMaker)maker;
- (void)bjl_removeTheme:(id)receipt;
- (void)bjl_removeThemes;

@end

NS_ASSUME_NONNULL_END
