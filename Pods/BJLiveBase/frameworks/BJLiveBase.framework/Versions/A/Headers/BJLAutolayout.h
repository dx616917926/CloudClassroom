//
//  BJLAutolayout.h
//  BJLiveBase
//
//  Created by MingLQ on 2018-10-12.
//  Copyright (c) 2018 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  item1.attr1 == [item2.attr2 [× multiplier]] + constant
 */

/*
@interface BJLAutolayout: NSObject
@end // */

@class BJLConstraintAttributesMaker, BJLConstraintConstantMaker;

#pragma mark - BJLConstraint

@interface BJLConstraint: NSObject
@property (nonatomic, readonly) BJLConstraintAttributesMaker *replace;
@property (nonatomic, readonly) BJLConstraintConstantMaker *update;
- (void)install;
- (void)uninstall;
@end

#pragma mark - BJLConstraintTarget

@interface BJLConstraintTarget: NSObject
@property (nonatomic, readonly, weak, nullable) id object; // nil
@property (nonatomic, readonly) NSLayoutAttribute attribute; // NSLayoutAttributeNotAnAttribute
@property (nonatomic, readonly, nullable) NSNumber *number; // nil
+ (instancetype)targetWithObject:(nullable id)object;
+ (instancetype)targetWithObject:(nullable id)object attribute:(NSLayoutAttribute)attribute;
@end

#pragma mark - BJLConstraintMaker

@interface BJLConstraintMakerRef: NSObject
@property (nonatomic, readonly) BJLConstraint *constraint;
@property (nonatomic, readonly) BJLConstraint * (^install)(void);
@property (nonatomic, readonly) BJLConstraint * (^uninstall)(void);
- (instancetype)and;
- (instancetype)with;
@end

@interface BJLConstraintMetaMaker: BJLConstraintMakerRef
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^shouldBeArchived)(BOOL shouldBeArchived); // NO
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^identifier)(NSString *identifier); // nil
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^priority)(UILayoutPriority priority); // UILayoutPriorityRequired
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^required)(void);
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^defaultHigh)(void);
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^defaultLow)(void);
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^fittingSizeLevel)(void);
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^active)(BOOL active); // YES
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^activate)(void);
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^deactivate)(void);
@end

@interface BJLConstraintConstantMaker: BJLConstraintMetaMaker
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^constant)(CGFloat constant); // 0.0
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^offset)(CGFloat offset);
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^insets)(UIEdgeInsets insets); // insets from target
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^inset)(CGFloat inset); // inset from target.attribute
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^centerOffset)(CGPoint centerOffset);
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^sizeOffset)(CGSize sizeOffset);
@end

@interface BJLConstraintMultiplierMaker: BJLConstraintConstantMaker
@property (nonatomic, readonly) BJLConstraintConstantMaker * (^multipliedBy)(CGFloat multiplier); // 1.0
@property (nonatomic, readonly) BJLConstraintConstantMaker * (^dividedBy)(CGFloat divider); // multiplier = 1.0 / divider
@end
@interface BJLConstraintTargetMaker: BJLConstraintConstantMaker
@property (nonatomic, readonly) BJLConstraintMultiplierMaker * (^to)(id _Nullable target); // nil, accepts NSNumber and NSArray
@property (nonatomic, readonly) BJLConstraintMultiplierMaker * (^toTargets)(id _Nullable target, ...); // NS_REQUIRES_NIL_TERMINATION, nil, accepts NSNumber
@end

@interface BJLConstraintRelationMaker: BJLConstraintMakerRef
@property (nonatomic, readonly) BJLConstraintTargetMaker * (^relation)(NSLayoutRelation relation); // NSLayoutRelationEqual
@property (nonatomic, readonly) BJLConstraintTargetMaker *equal, *lessThanOrEqual, *greaterThanOrEqual;
@end

@interface BJLConstraintAttributesMaker: BJLConstraintRelationMaker
@property (nonatomic, readonly) BJLConstraintRelationMaker * (^attributes)(NSLayoutAttribute first, ...); // edges
@property (nonatomic, readonly) BJLConstraintAttributesMaker
    *left,
    *right, *top, *bottom, *leading, *trailing,
    *width, *height, *centerX, *centerY,
    *firstBaseline, *lastBaseline,
    *leftMargin, *rightMargin, *topMargin, *bottomMargin, *leadingMargin, *trailingMargin,
    *centerXWithinMargins, *centerYWithinMargins;
@property (nonatomic, readonly) BJLConstraintAttributesMaker
    *edges,
    *center, *size;
@end

@interface BJLConstraintMaker: BJLConstraintAttributesMaker
@property (nonatomic, readonly) BJLConstraintAttributesMaker
    *replaceSimilar, // `replace` if has same view, attributes, relation
    *updateExisting; // for each attribute, `update`  if has same view, relation, target+attribute-s, multiplier
@end

#pragma mark - BJLLayoutAttribute

@protocol BJLLayoutGuide <NSObject>
@property (nonatomic, readonly) BJLConstraintTarget
    *bjl_left,
    *bjl_right, *bjl_top, *bjl_bottom, *bjl_leading, *bjl_trailing,
    *bjl_width, *bjl_height, *bjl_centerX, *bjl_centerY;
@end

@protocol BJLLayoutAttribute <BJLLayoutGuide>
@property (nonatomic, readonly) BJLConstraintTarget
    *bjl_firstBaseline,
    *bjl_lastBaseline,
    *bjl_leftMargin, *bjl_rightMargin, *bjl_topMargin, *bjl_bottomMargin, *bjl_leadingMargin, *bjl_trailingMargin,
    *bjl_centerXWithinMargins, *bjl_centerYWithinMargins;
@end

@interface UILayoutGuide (BJLLayoutAttribute) <BJLLayoutGuide>
@end

@interface UIView (BJLLayoutAttribute) <BJLLayoutGuide, BJLLayoutAttribute>
@property (nonatomic, readonly, nullable) UILayoutGuide *bjl_safeAreaLayoutGuide;
@end

@interface UIScrollView (BJLLayoutAttribute)
@property (nonatomic, readonly, nullable) UILayoutGuide *bjl_contentLayoutGuide, *bjl_frameLayoutGuide;
@end

@interface UIViewController (BJLLayoutAttribute)
@property (nonatomic, readonly) BJLConstraintTarget
    *bjl_topLayoutGuide,
    *bjl_topLayoutGuideTop, *bjl_topLayoutGuideBottom,
    *bjl_bottomLayoutGuide, *bjl_bottomLayoutGuideTop, *bjl_bottomLayoutGuideBottom;
@end

#pragma mark - BJLAutolayout

@interface UIView (BJLAutolayout)
@property (nonatomic, readonly) BJLConstraintMaker *bjl_make __APPLE_API_UNSTABLE;
// - (void)bjl_install __APPLE_API_UNSTABLE;
- (void)bjl_makeConstraints:(void(NS_NOESCAPE ^)(BJLConstraintMaker *make))block;
- (void)bjl_updateConstraints:(void(NS_NOESCAPE ^)(BJLConstraintMaker *make))block;
- (void)bjl_remakeConstraints:(void(NS_NOESCAPE ^)(BJLConstraintMaker *make))block; // uninstall & make
- (void)bjl_uninstallConstraints; // only BJLConstraint
- (void)bjl_removeAllConstraints; // include NSLayoutConstraint
@end

#pragma mark - MasonryCompatible

@interface BJLConstraintMetaMaker (MasonryCompatible)
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^priorityLow)(void)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^priorityMedium)(void)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) BJLConstraintMetaMaker * (^priorityHigh)(void)__APPLE_API_UNSTABLE;
@end

@interface BJLConstraintRelationMaker (MasonryCompatible)
@property (nonatomic, readonly) BJLConstraintMultiplierMaker * (^equalTo)(id _Nullable target)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) BJLConstraintMultiplierMaker * (^lessThanOrEqualTo)(id _Nullable target)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) BJLConstraintMultiplierMaker * (^greaterThanOrEqualTo)(id _Nullable target)__APPLE_API_UNSTABLE;
@end

#pragma mark - BJLContentMode

@interface BJLContentMakerRef: NSObject
@end

@interface BJLContentPriorityMaker: BJLContentMakerRef
@property (nonatomic, readonly) void (^priority)(UILayoutPriority priority); // UILayoutPriorityRequired
@property (nonatomic, readonly) void (^required)(void);
@property (nonatomic, readonly) void (^defaultHigh)(void);
@property (nonatomic, readonly) void (^defaultLow)(void);
@property (nonatomic, readonly) void (^fittingSizeLevel)(void);
@end

@interface BJLContentPriorityModeMaker: BJLContentPriorityMaker
@property (nonatomic, readonly) BJLContentPriorityModeMaker
    *hugging,
    *compressionResistance;
@end

@interface BJLContentModeMaker: BJLContentMakerRef
@property (nonatomic, readonly) BJLContentPriorityModeMaker
    *hugging,
    *compressionResistance;
@end

@interface BJLContentAxisMaker: BJLContentModeMaker
@property (nonatomic, readonly) BJLContentAxisMaker
    *horizontal,
    *vertical;
@end

@interface BJLConstraintAttributesMaker (BJLContentMode)
@property (nonatomic, readonly) BJLContentAxisMaker
    *horizontal,
    *vertical;
@property (nonatomic, readonly) BJLContentPriorityModeMaker
    *hugging,
    *compressionResistance;
@end

// #pragma mark -
//
// static inline void BJLMakeConstraint(UIView *aView, UIView *bView) {
//
//     /* REQUIRED: `install` for `bjl_make` */
//     aView.bjl_make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0).required().activate().install();
//
//     [aView bjl_makeConstraints:^(BJLConstraintMaker *make) {
//
//         /* OPTIONAL: `attributes` */
//         make/* <#.edges#> */.equal.to(bView).multipliedBy(1.0).constant(0.0);
//
//         /* REQUIRED: `relation` */
//         // make.left.right/* <#.equal#> */.to(bView).multipliedBy(1.0).constant(0.0);
//         // make.left.right/* <#.equal#> <#.to(bView)#> */.multipliedBy(1.0).constant(0.0);
//         // make.left.right/* <#.equal#> <#.to(bView)#> */.multipliedBy(1.0).constant(0.0);
//         // make.left.right/* <#.equal#> <#.to(bView)#> <#.multipliedBy(1.0)#> */.constant(0.0);
//
//         /* OPTIONAL: `to` */
//         make.left.right.equal/* <#.to(bView)#> <#.multipliedBy(1.0)#> */.constant(0.0);
//
//         /* REQUIRED: `multipliedBy` available only after `to` */
//         // make.left.right.equal/* <#.to(bView)#> */.multipliedBy(1.0).constant(0.0);
//
//         /* OPTIONAL: `attribute`, `multipliedBy`, `constant` after `to` */
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0);
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> */.constant(0.0);
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> <#.constant(0.0)#> */;
//         make.left.right.equal.to(bView).multipliedBy(1.0)/* <#.constant(0.0)#> */;
//
//         /* DEPRECATED: `make.left.right.equal;`, use `make.left.right.equal.constant(0.0);` */
//         // make.left.right.equal/* <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> */;
//
//         /* OPTIONAL: `priority`, `active` */
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0).required().activate();
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0)/* <#.required()#> */.activate();
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0).required()/* <#.activate()#> */;
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0)/* <#.required()#> <#.activate()#> */;
//         make.left.right.equal.to(bView).multipliedBy(1.0)/* <#.constant(0.0)#> <#.required()#> <#.activate()#> */;
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> <#.constant(0.0)#> <#.required()#> <#.activate()#> */;
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> <#.constant(0.0)#> <#.required()#> <#.activate()#> */;
//         make.left.right.equal/* <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> <#.required()#> <#.activate()#> */.install();
//         /* REQUIRED: `priority`, `active` available only after `to` */
//         // make.left.right/* <#.equal#> <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> */.required().activate();
//         // make/* <#.left#> <#.right#> <#.equal#> <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> */.required().activate();
//
//         /* OPTIONAL: `axes` */
//         make.horizontal.vertical.hugging.compressionResistance.required();
//         make.horizontal/* <#.vertical#> */.hugging.compressionResistance.required();
//         make/* <#.horizontal#> */.vertical.hugging.compressionResistance.required();
//         make/* <#.horizontal#> <#.vertical#> */.hugging.compressionResistance.required();
//         /* REQUIRED: `mode` */
//         make.hugging/* <#.compressionResistance#> */.required();
//         make/* <#.hugging#> */.compressionResistance.required();
//         // maker/* <#.hugging#> <#.compressionResistance#> */.required();
//         /* REQUIRED: `priority` */
//         // make.hugging.compressionResistance/* <#.required()#> */;
//
//     }];
// }

NS_ASSUME_NONNULL_END
