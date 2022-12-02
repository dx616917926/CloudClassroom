//
//  BJLRequireFullScreenCheckFailedMaskView.h
//  BJLiveUI
//
//  Created by Ney on 4/23/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLRequireFullScreenCheckFailedMaskView: UIView
@property (nonatomic, class, readonly) BOOL requireFullScreenIsChecked;
@property (nonatomic, strong) void (^dismissEventHandler)(BJLRequireFullScreenCheckFailedMaskView *view);
- (void)showInParentView:(UIView *)view;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
