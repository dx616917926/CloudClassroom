//
//  BJLScQuestionInputViewController.h
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/25.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>
#import <BJLiveBase/BJLViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScQuestionInputViewController: BJLViewController

@property (nonatomic, nullable) void (^sendQuestionCallback)(NSString *content);
@property (nonatomic, nullable) void (^saveReplyCallback)(BJLQuestion *question, NSString *reply);
@property (nonatomic, nullable) void (^cancelCallback)(void);

- (instancetype)initWithRoom:(BJLRoom *)room;

- (void)updateWithQuestion:(nullable BJLQuestion *)question;

@end

NS_ASSUME_NONNULL_END
