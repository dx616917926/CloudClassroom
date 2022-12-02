//
//  BJLCheckGuideViewController.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/19.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** ### 课前自检控制页面 */
@interface BJLCheckGuideViewController: UIViewController

/// 检测完成回调
@property (nonatomic, nullable) void (^checkFinishCompletion)(void);

@end

NS_ASSUME_NONNULL_END
