//
//  BJLPopoverBaseViewController.h
//  BJLiveUI
//
//  Created by Ney on 3/2/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>

#import <BJLiveBase/BJLViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class BJLPopoverBaseViewController;
typedef void (^BJLPopoverViewPositionBlock)(BJLPopoverBaseViewController *vc, UIView *mainView, UIView *parentView);

@interface BJLPopoverBaseViewController: BJLViewController
@property (nonatomic, weak, readonly) BJLRoom *room;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, copy) NSString *headTitle;
@property (nonatomic, strong, nullable) UIImage *icon;
@property (nonatomic, assign) BOOL showHeadBar;

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, weak) UIViewController *parentVC;

/// 确定弹框主体位置的布局block，在viewDidLoad中调用。
/// 注意！！ 这里只能写view相对于父view的位置约束，不能写大小的
@property (nonatomic, copy) BJLPopoverViewPositionBlock positionBlock;

@property (nonatomic, copy) void (^backgroundViewTapEventCallback)(BJLPopoverBaseViewController *vc);
@property (nonatomic, copy) void (^closeEventBlock)(BJLPopoverBaseViewController *vc);

- (instancetype)initWithRoom:(BJLRoom *)room;
- (void)showOverParentView;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
