//
//  BJLCountDownManager.h
//  BJLiveUIBigClass
//
//  Created by HuXin on 2022/2/24.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLRoom.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLCountDownManager: NSObject
- (instancetype)initWithRoom:(BJLRoom *)room roomViewController:(UIViewController *)roomViewController superView:(UIView *)superView;
- (void)showCountDownEditViewController;
- (void)makeObserver;
- (BOOL)hitTestViewIsCountDownView:(nullable UIView *)view;
@end

NS_ASSUME_NONNULL_END
