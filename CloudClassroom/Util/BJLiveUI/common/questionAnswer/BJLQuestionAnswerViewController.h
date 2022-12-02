//
//  BJLQuestionAnswerViewController.h
//  BJLiveUI
//
//  Created by fanyi on 2019/5/25.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLRoom.h>
#import <BJLiveCore/BJLAnswerSheet.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, BJLQuestionAnswerWindowLayout) {
    BJLQuestionAnswerWindowLayout_normal, // 老师未发布状态
    BJLQuestionAnswerWindowLayout_publish, // 老师已发布
    BJLQuestionAnswerWindowLayout_end, // 老师已结束答题
};

/** 答题器 */
@interface BJLQuestionAnswerViewController: UIViewController

// 发布答题器
@property (nonatomic, nullable) void (^publishQuestionAnswerCallback)(BJLAnswerSheet *answerSheet);

// 结束答题器
@property (nonatomic, nullable) void (^endQuestionAnswerCallback)(BOOL close);

// 撤回答题器
@property (nonatomic, nullable) void (^revokeQuestionAnswerCallback)(void);

// 关闭答题器
@property (nonatomic, nullable) void (^closeQuestionAnswerCallback)(void);

// 关闭窗口回调
@property (nonatomic, nullable) void (^closeCallback)(void);

// 请求详情
@property (nonatomic, nullable) BOOL (^requestQuestionDetailCallback)(NSString *ID);

// 错误提示
@property (nonatomic, nullable) void (^errorCallback)(NSString *message);

@property (nonatomic, nullable) void (^keyboardFrameChangeCallback)(CGRect keyboardFrame);

- (instancetype)initWithRoom:(BJLRoom *)room
                 answerSheet:(BJLAnswerSheet *)answerSheet
                      layout:(BJLQuestionAnswerWindowLayout)layout;

- (instancetype)init NS_UNAVAILABLE;

- (CGSize)presentationSize;
// 关闭抢答器窗口
- (void)closeUI;

- (void)destroyQuestionAnswer;

- (BOOL)keyboardDidShow;

- (void)hideKeyboardView;

@end

NS_ASSUME_NONNULL_END
