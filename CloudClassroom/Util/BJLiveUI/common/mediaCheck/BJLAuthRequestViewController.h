//
//  BJLAuthRequestViewController.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/19.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** ### 授权引导页面 */
@interface BJLAuthRequestViewController: UIViewController

@property (nonatomic, nullable) void (^enterCallback)(void);

@end

NS_ASSUME_NONNULL_END
