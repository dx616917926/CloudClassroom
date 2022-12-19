//
//  BJLScQuestionViewController.h
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/25.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScQuestionViewController: BJLTableViewController

@property (nonatomic, nullable) void (^closeCallback)(void);
@property (nonatomic, nullable) void (^replyCallback)(BJLQuestion *question, BJLQuestionReply *_Nullable reply);
@property (nonatomic, nullable) void (^newMessageCallback)(void);
@property (nonatomic, nullable) void (^showQuestionInputViewCallback)(void);
@property (nonatomic, nullable) void (^showErrorMessageCallback)(NSString *message);

- (instancetype)initWithRoom:(BJLRoom *)room;
- (void)sendQuestion:(NSString *)content;
- (void)clearReplyQuestion;
- (void)updateQuestion:(BJLQuestion *)question reply:(NSString *)reply;

- (void)showRedDotForStudentPublishSegment;

@end

NS_ASSUME_NONNULL_END