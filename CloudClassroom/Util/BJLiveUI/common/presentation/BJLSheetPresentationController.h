//
//  BJLSheetPresentationController.h
//  BJLiveUIBase
//
//  Created by ney on 2022/2/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLSheetPresentationController: UIPresentationController <UIViewControllerTransitioningDelegate>
@property (nonatomic, nullable) BOOL (^tapCallback)(UIViewController *_Nullable viewController);
@end

NS_ASSUME_NONNULL_END
