//
//  BJLScreenCaptureAlertMaskView.h
//  BJLiveUI
//
//  Created by Ney on 11/13/20.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BJLScreenCaptureAlertMaskView: UIView
@property (nonatomic, strong) void (^dismissEventHandler)(BJLScreenCaptureAlertMaskView *view);
- (void)showInParentView:(UIView *)view;
- (void)hide;
@end
