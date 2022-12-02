//
//  BJVMessageVM.h
//  BJPlayerManagerCore
//
//  Created by HuangJie on 2018/5/11.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJVBaseVM.h"
#import "BJVMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJVMessageVM: BJVBaseVM

// 消息覆盖更新
- (BJLObservable)receivedMessagesDidOverwrite:(nullable NSArray<BJVMessage *> *)messages;

// 消息增量更新
- (BJLObservable)didReceiveMessages:(nullable NSArray<BJVMessage *> *)messages;

@end

NS_ASSUME_NONNULL_END
