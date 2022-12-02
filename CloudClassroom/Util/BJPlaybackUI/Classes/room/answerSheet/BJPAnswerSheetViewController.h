//
//  BJPAnswerSheetViewController.h
//  BJPlaybackUI
//
//  Created by fanyi on 2019/8/16.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJVAnswerSheet.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPAnswerSheetViewController: UIViewController

// 提交回调, return YES 代表提交成功，将会关闭答题器视图
@property (nonatomic, copy, nullable) BOOL (^submitCallback)(BJVAnswerSheet *_Nullable result);
// 关闭回调
@property (nonatomic, copy, nullable) void (^closeCallback)(void);

- (instancetype)initWithAnswerSheet:(BJVAnswerSheet *)answerSheet;

@end

NS_ASSUME_NONNULL_END
