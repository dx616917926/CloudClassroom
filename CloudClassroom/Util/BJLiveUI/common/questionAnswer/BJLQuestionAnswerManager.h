//
//  BJLQuestionAnswerManager.h
//  BJLiveUIBase
//
//  Created by HuXin on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLRoom.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLQuestionAnswerManager: NSObject
@property (nonatomic, nullable) void (^showErrorMessageCallback)(NSString *message);
@property (nonatomic, nullable) void (^keyboardFrameChangeCallback)(CGRect keyboardFrame);

- (instancetype)initWithRoom:(BJLRoom *)room roomViewController:(UIViewController *)roomViewController;
- (void)openQuestionAnswer;
- (void)makeObeservingForQuestionAnswer;
@end

NS_ASSUME_NONNULL_END
