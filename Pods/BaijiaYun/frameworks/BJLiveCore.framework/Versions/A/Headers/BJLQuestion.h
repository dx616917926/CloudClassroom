//
//  BJLQuestion.h
//  BJLiveCore
//
//  Created by xijia dai on 2019/1/23.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

/** 问答状态 */
typedef NS_OPTIONS(NSInteger, BJLQuestionState) {
    /** 已发布 */
    BJLQuestionPublished = 1 << 0,
    /** 未发布 */
    BJLQuestionUnpublished = 1 << 1,
    /** 已回复 */
    BJLQuestionReplied = 1 << 2,
    /** 未回复 */
    BJLQuestionUnreplied = 1 << 3,
    /** 所有状态 */
    BJLQuestionAllState = (1 << 4) - 1
};

@interface BJLQuestionCount: NSObject

@property (nonatomic, readonly) NSInteger totalCount;
@property (nonatomic, readonly) NSInteger publishCount;
@property (nonatomic, readonly) NSInteger replyCount;
@property (nonatomic, readonly) NSInteger replynopub;

@end

@interface BJLQuestionReply: NSObject

@property (nonatomic, readonly) NSTimeInterval createTime;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) BOOL publish;
@property (nonatomic, readonly) BJLUser *fromUser; // only user `ID、number、avatar、name、client type、role` available

@end

@interface BJLQuestion: NSObject

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic) BJLQuestionState state;
@property (nonatomic, readonly) NSTimeInterval lastTime; // 最后更新时间
@property (nonatomic, readonly) NSTimeInterval createTime; // not publish time
@property (nonatomic, readonly) NSString *content; // content
@property (nonatomic, readonly) NSInteger pageIndex; // current page index >= 0
@property (nonatomic, readonly) BJLQuestionCount *questionCount; // totalCount, publishCount, replyCount
@property (nonatomic, readonly) BJLUser *fromUser; // only user `ID、number、avatar、name、client type、role` available
@property (nonatomic, readonly, nullable) NSArray<BJLQuestionReply *> *replies; // reply
@property (nonatomic) BOOL forbid; // whether question owner is forbidden

- (void)updateQuestionWithUnpubishReply:(NSString *)reply fromUser:(BJLUser *)fromUser;

@end

NS_ASSUME_NONNULL_END
