//
//  UIView+panGesture.h
//  BJLiveUIBase
//
//  Created by ney on 2021/12/23.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (panGesture)
@property (nonatomic, assign) CGFloat bjl_titleBarHeight;

- (BOOL)bjl_titleBarPanGestureEnable;
- (void)bjl_addTitleBarPanGesture;
- (void)bjl_removeTitleBarPanGesture;
@end

NS_ASSUME_NONNULL_END
