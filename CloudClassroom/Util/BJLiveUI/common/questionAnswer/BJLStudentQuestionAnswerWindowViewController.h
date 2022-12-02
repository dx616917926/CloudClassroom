//
//  BJLStudentQuestionAnswerWindowViewController.h
//  BJLiveUI
//
//  Created by fanyi on 2019/6/3.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLRoom.h>
#import <BJLiveCore/BJLAnswerSheet.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLStudentQuestionAnswerWindowViewController: UIViewController

@property (nonatomic) BOOL hasReceiveEndMessage;
// 关闭窗口回调
@property (nonatomic, nullable) void (^closeCallback)(void);
@property (nonatomic, nullable) void (^errorCallback)(NSString *message);
@property (nonatomic, nullable) BOOL (^submitCallback)(BJLAnswerSheet *answerSheet);

- (instancetype)initWithRoom:(BJLRoom *)room
                 answerSheet:(BJLAnswerSheet *)answerSheet;

- (instancetype)init NS_UNAVAILABLE;
- (NSInteger)answerSheetOptionsCount;
- (void)close;
- (CGSize)presentationSize;
@end

NS_ASSUME_NONNULL_END
