//
//  BJPAnswerResultViewController.h
//  BJPlaybackUI
//
//  Created by fanyi on 2019/9/4.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJVAnswerSheet.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPAnswerResultViewController: UIViewController

// 关闭回调
@property (nonatomic, copy, nullable) void (^closeCallback)(void);

- (instancetype)initWithAnswerSheet:(BJVAnswerSheet *)answerSheet;

@end

NS_ASSUME_NONNULL_END
