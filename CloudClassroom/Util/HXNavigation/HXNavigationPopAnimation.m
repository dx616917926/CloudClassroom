//
//  HXNavigationPopAnimation.m
//  HXNavigationController
//
//  Created by iMac on 16/7/21.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import "HXNavigationPopAnimation.h"
#import "UIImage+Extension.h"

static const CGFloat kToBackgroundInitAlpha = 0.08;

@interface HXNavigationPopAnimation ()

@property (nonatomic, strong) UIView      *toBackgroundView;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UIImageView *maskImageView;

@property (nonatomic, strong) UIView      *naviContainView;

@end

@implementation HXNavigationPopAnimation

- (instancetype)init {
    if (self = [super init]) {
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        self.toBackgroundView = [[UIView alloc] init];
        
        self.shadowImageView = [[UIImageView alloc] initWithFrame:(CGRect){-10, 0, 10, screenHeight}];
        self.shadowImageView.image = [UIImage imageNamed:@"navi_shadow"];
        self.shadowImageView.contentMode = UIViewContentModeScaleToFill;
        
        self.maskImageView = [[UIImageView alloc] initWithFrame:(CGRect){0, kStatusBarHeight, kScreenWidth, 44}];
        self.maskImageView.image = [UIImage imageNamed:@"navi_mask"];
        
        self.naviContainView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, kNavigationBarHeight}];
        self.naviContainView.backgroundColor = [UIColor colorWithRed:0.774 green:0.368 blue:1.000 alpha:0.810];
        
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:fromViewController.view];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    [containerView insertSubview:self.toBackgroundView belowSubview:fromViewController.view];
    [containerView insertSubview:self.shadowImageView belowSubview:fromViewController.view];
    toViewController.view.frame = CGRectMake(-90, 0, kScreenWidth, CGRectGetHeight(toViewController.view.frame));
    self.toBackgroundView.frame = CGRectMake(-90, 0, kScreenWidth, CGRectGetHeight(toViewController.view.frame));
    self.shadowImageView.x = - 10;
    self.shadowImageView.alpha = 1.3;
    
    self.toBackgroundView.backgroundColor = [UIColor blackColor];
    self.maskImageView.image = [self.maskImageView.image imageWithTintColor:[UIColor clearColor]];
//    self.maskImageView.image = [UIImage imageNamed:@"navi_bgImage"];
    self.toBackgroundView.alpha = kToBackgroundInitAlpha;
    
    //先刷新一下
    [toViewController.sc_navigationBar setNeedsLayout];
    [toViewController.sc_navigationBar layoutIfNeeded];
    
    toViewController.sc_navigationBar.isTransition = YES;
    fromViewController.sc_navigationBar.isTransition = YES;
    // Configure Navi Transition
    
//    UIView *naviBarView;
    UIImageView *naviBarView;
    
    UIView *toNaviLeft;
    UIView *toNaviRight;
    UIView *toNaviTitle;
    UIView *toNaviTitleView;
    
    UIView *fromNaviLeft;
    UIView *fromNaviRight;
    UIView *fromNaviTitle;
    UIView *fromNaviTitleView;
    
    if (fromViewController.sc_NavigationBarAnimateInvalid || toViewController.sc_NavigationBarAnimateInvalid || fromViewController.sc_isNavigationBarHidden || toViewController.sc_isNavigationBarHidden) {
        ;
    } else {
        
        naviBarView = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, kNavigationBarHeight}];
        naviBarView.contentMode = UIViewContentModeScaleToFill;
        //        naviBarView.backgroundColor = kNavigationBarColor;
        naviBarView.image = [UIImage imageNamed:@"navi_bgImage"];
        [containerView addSubview:naviBarView];
        
//        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, kNavigationBarHeight, kScreenWidth, 0.5}];
//        lineView.backgroundColor = kNavigationBarLineColor;
//        [naviBarView addSubview:lineView];
        
        toNaviLeft = toViewController.sc_navigationBar.leftBarButtonItem.view;
        toNaviRight = toViewController.sc_navigationBar.rightBarButtonItem.view;
        toNaviTitle = toViewController.sc_navigationBar.titleLabel;
        toNaviTitleView = toViewController.sc_navigationBar.titleView;
        
        fromNaviLeft = fromViewController.sc_navigationBar.leftBarButtonItem.view;
        fromNaviRight = fromViewController.sc_navigationBar.rightBarButtonItem.view;
        fromNaviTitle = fromViewController.sc_navigationBar.titleLabel;
        fromNaviTitleView = fromViewController.sc_navigationBar.titleView;
        
        [containerView addSubview:toNaviTitle];
        [containerView addSubview:toNaviTitleView];
        [containerView addSubview:fromNaviTitle];
        [containerView addSubview:fromNaviTitleView];
        
        [containerView addSubview:self.maskImageView];
        
        [containerView addSubview:toNaviLeft];
        [containerView addSubview:toNaviRight];
        
        [containerView addSubview:fromNaviLeft];
        [containerView addSubview:fromNaviRight];
        
        fromNaviLeft.alpha = 1.0;
        fromNaviRight.alpha =  1.0;
        fromNaviTitle.alpha = 1.0;
        fromNaviTitleView.alpha = 1.0;
        fromNaviLeft.x = 0;
        fromNaviRight.x = kScreenWidth - fromNaviRight.width;
        fromNaviLeft.transform = CGAffineTransformIdentity;
        fromNaviRight.transform = CGAffineTransformIdentity;
        
        toNaviLeft.alpha = 0.0;
        toNaviRight.alpha = 0.0;
        toNaviTitle.alpha = 0.0;
        toNaviTitle.centerX = 44;
        toNaviTitleView.alpha = 0.0;
//        toNaviTitleView.centerX = 44;
        //        toNaviLeft.transform = CGAffineTransformMakeScale(0.1, 0.1);
        toNaviRight.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
    }
    
    // End configure
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        toViewController.view.x = 0;
        self.toBackgroundView.x = 0;
        fromViewController.view.x = kScreenWidth;
        
        self.shadowImageView.alpha = 0.2;
        self.shadowImageView.x = kScreenWidth - 7;
        
        
        self.toBackgroundView.alpha = 0.0;
        fromNaviLeft.alpha = 0;
        fromNaviRight.alpha =  0;
        fromNaviTitle.alpha = 0;
        fromNaviTitle.centerX = kScreenWidth + 10;
        fromNaviTitleView.alpha = 0;
        fromNaviTitleView.centerX = kScreenWidth + 10;
        fromNaviLeft.transform = CGAffineTransformMakeScale(0.1, 0.1);
        fromNaviRight.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        toNaviLeft.alpha = 1.0;
        toNaviRight.alpha = 1.0;
        toNaviTitle.alpha = 1.0;
        toNaviTitle.centerX = kScreenWidth / 2;
        toNaviTitleView.alpha = 1.0;
//        toNaviTitleView.centerX = kScreenWidth / 2;
        //        toNaviLeft.transform = CGAffineTransformIdentity;
        toNaviRight.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        toViewController.sc_navigationBar.isTransition = NO;
        fromViewController.sc_navigationBar.isTransition = NO;
        
        if (transitionContext.transitionWasCancelled) {
            toNaviLeft.alpha = 1.0;
            toNaviRight.alpha = 1.0;
            toNaviTitle.alpha = 1.0;
            toNaviTitle.centerX = kScreenWidth / 2;
            toNaviTitleView.alpha = 1.0;
            toNaviTitleView.centerX = kScreenWidth / 2;
            toNaviLeft.transform = CGAffineTransformIdentity;
            toNaviRight.transform = CGAffineTransformIdentity;
            self.toBackgroundView.alpha = kToBackgroundInitAlpha;
        }
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
        [naviBarView removeFromSuperview];
        [self.maskImageView removeFromSuperview];
        [self.toBackgroundView removeFromSuperview];
        [self.shadowImageView removeFromSuperview];
        
        [toNaviLeft removeFromSuperview];
        [toNaviTitle removeFromSuperview];
        [toNaviTitleView removeFromSuperview];
        [toNaviRight removeFromSuperview];
        
        [fromNaviLeft removeFromSuperview];
        [fromNaviTitle removeFromSuperview];
        [fromNaviTitleView removeFromSuperview];
        [fromNaviRight removeFromSuperview];
        
        [toViewController.sc_navigationBar addSubview:toNaviLeft];
        [toViewController.sc_navigationBar addSubview:toNaviTitle];
        [toViewController.sc_navigationBar addSubview:toNaviTitleView];
        [toViewController.sc_navigationBar addSubview:toNaviRight];
        
        [fromViewController.sc_navigationBar addSubview:fromNaviLeft];
        [fromViewController.sc_navigationBar addSubview:fromNaviTitle];
        [fromViewController.sc_navigationBar addSubview:fromNaviTitleView];
        [fromViewController.sc_navigationBar addSubview:fromNaviRight];
        
    }];
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

@end
