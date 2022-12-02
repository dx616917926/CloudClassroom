//
//  UIKit+M9Handler.h
//  M9Dev
//
//  Created by MingLQ on 2015-08-11.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (BJLHandler)

+ (instancetype)bjl_barButtonItemWithImage:(nullable UIImage *)image
                                     style:(UIBarButtonItemStyle)style;
+ (instancetype)bjl_barButtonItemWithImage:(nullable UIImage *)image
                       landscapeImagePhone:(nullable UIImage *)landscapeImagePhone
                                     style:(UIBarButtonItemStyle)style;
+ (instancetype)bjl_barButtonItemWithTitle:(nullable NSString *)title
                                     style:(UIBarButtonItemStyle)style;
+ (instancetype)bjl_barButtonItemWithCustomView:(UIView *)customView;
+ (instancetype)bjl_barButtonSystemItem:(UIBarButtonSystemItem)systemItem;

/**
 - will RESET the target and action properties
 - supports adding multiple targets
 #return    an actual target(NOT the target property) which can be used for removing this handler
 */
- (id)bjl_addHandler:(void (^)(__kindof UIBarButtonItem *_Nullable sender))handler;

- (void)bjl_removeHandlerWithTarget:(id)target;
- (void)bjl_removeAllHandlers;

@end

#pragma mark -

@interface UIControl (BJLHandler)

/**
 #return    actual target[s] which can be used for removing this handler
 */
- (id)bjl_addHandler:(void (^)(__kindof UIControl *sender, UIControlEvents event))handler forControlEvents:(UIControlEvents)events NS_SWIFT_UNAVAILABLE("Objective-C ONLY");
- (id)bjl_addHandlerForControlEvents:(UIControlEvents)events handler:(void (^)(__kindof UIControl *_Nullable sender, UIControlEvents event))handler NS_SWIFT_NAME(bjl_addHandler(for:handler:));

- (void)bjl_removeHandlerWithTarget:(id)target forControlEvents:(UIControlEvents)events;
- (void)bjl_removeHandlersForControlEvents:(UIControlEvents)events;
- (void)bjl_removeAllHandlers;

- (id)bjl_kvoHighlighted:(BOOL (^)(__kindof UIControl *control, BOOL highlighted))observer;
- (id)bjl_kvoSelected:(BOOL (^)(__kindof UIControl *control, BOOL selected))observer;
- (id)bjl_kvoEnabled:(BOOL (^)(__kindof UIControl *control, BOOL enabled))observer;
- (id)bjl_kvoFocused:(BOOL (^)(__kindof UIControl *control, BOOL focused))observer;
- (id)bjl_kvoState:(BOOL (^)(__kindof UIControl *control, UIControlState state, UIControlState prevState))observer;

@end

#pragma mark -

@interface UIButton (BJLHandler)

// forControlEvents:UIControlEventTouchUpInside
- (id)bjl_addHandler:(void (^)(UIButton *button))handler NS_SWIFT_NAME(bjl_addHandler(_:));
- (void)bjl_removeHandlerWithTarget:(id)target;

/// #param possible state1|state2|...
- (void)bjl_setTitle:(nullable NSString *)title forState:(UIControlState)state possibleStates:(UIControlState)possible;
- (void)bjl_setTitleColor:(nullable UIColor *)color forState:(UIControlState)state possibleStates:(UIControlState)possible;
- (void)bjl_setTitleShadowColor:(nullable UIColor *)color forState:(UIControlState)state possibleStates:(UIControlState)possible;
- (void)bjl_setAttributedTitle:(nullable NSAttributedString *)title forState:(UIControlState)state possibleStates:(UIControlState)possible;
- (void)bjl_setImage:(nullable UIImage *)image forState:(UIControlState)state possibleStates:(UIControlState)possible;
- (void)bjl_setBackgroundColor:(nullable UIColor *)color forState:(UIControlState)state possibleStates:(UIControlState)possible;
- (void)bjl_setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state possibleStates:(UIControlState)possible;
- (void)bjl_setPreferredSymbolConfiguration:(nullable UIImageSymbolConfiguration *)configuration forImageInState:(UIControlState)state possibleStates:(UIControlState)possible API_AVAILABLE(ios(13.0), tvos(13.0), watchos(6.0));

/// possibleStates is optional for Swift
- (void)bjl_setTitle:(nullable NSString *)title forState:(UIControlState)state;
- (void)bjl_setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;
- (void)bjl_setTitleShadowColor:(nullable UIColor *)color forState:(UIControlState)state;
- (void)bjl_setAttributedTitle:(nullable NSAttributedString *)title forState:(UIControlState)state;
- (void)bjl_setImage:(nullable UIImage *)image forState:(UIControlState)state;
- (void)bjl_setBackgroundColor:(nullable UIColor *)color forState:(UIControlState)state;
- (void)bjl_setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state;
- (void)bjl_setPreferredSymbolConfiguration:(nullable UIImageSymbolConfiguration *)configuration forImageInState:(UIControlState)state API_AVAILABLE(ios(13.0), tvos(13.0), watchos(6.0));

@end

#pragma mark -

@interface UIGestureRecognizer (BJLHandler)

+ (instancetype)bjl_gestureWithHandler:(void (^)(__kindof UIGestureRecognizer *_Nullable gesture))handler;

/**
 #return    an actual target which can be used for removing this handler
 */
- (id)bjl_addHandler:(void (^)(__kindof UIGestureRecognizer *_Nullable gesture))handler;

- (void)bjl_removeHandlerWithTarget:(id)target;
- (void)bjl_removeAllHandlers;

@end

NS_ASSUME_NONNULL_END
