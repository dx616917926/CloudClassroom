//
//  BJLAlertPresentationController.h
//  BJLiveUIBase
//
//  Created by HuXin on 2022/2/17.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLAlertPresentationController: UIPresentationController <UIViewControllerTransitioningDelegate>
@property (nonatomic, nullable) BOOL (^tapCallback)(UIViewController *_Nullable viewController);
@end

NS_ASSUME_NONNULL_END
