//
//  BJLUserInterfaceStyle.h
//  BJLiveBase
//
//  Created by MingLQ on 2020-07-01.
//  Copyright (c) 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLUserInterfaceStyle) {
    BJLUserInterfaceStyleUnspecified,
    BJLUserInterfaceStyleLight,
    BJLUserInterfaceStyleDark
};

@interface UIColor (BJLUserInterfaceStyle)
+ (UIColor *)bjl_colorWithDynamicProvider:(UIColor * (^)(UITraitCollection *traitCollection))dynamicProvider NS_SWIFT_NAME(dynamic(provider:));
- (UIColor *)bjl_resolvedColorWithTraitCollection:(UITraitCollection *)traitCollection;
- (UIColor *)bjl_resolvedColorWithUserInterfaceStyle:(BJLUserInterfaceStyle)userInterfaceStyle;
@end

@interface UITraitCollection (BJLUserInterfaceStyle)
@property (nonatomic, readonly) BJLUserInterfaceStyle bjl_userInterfaceStyle;
+ (UITraitCollection *)bjl_traitCollectionWithUserInterfaceStyle:(BJLUserInterfaceStyle)userInterfaceStyle;
@end

@protocol BJLUserInterfaceStyleContainer <NSObject>
@property (nonatomic, setter=bjl_setOverrideUserInterfaceStyle:) BJLUserInterfaceStyle bjl_overrideUserInterfaceStyle;
@end

@interface UIView (BJLUserInterfaceStyle) <BJLUserInterfaceStyleContainer>
@end

@interface UIViewController (BJLUserInterfaceStyle) <BJLUserInterfaceStyleContainer>
@end

NS_ASSUME_NONNULL_END
