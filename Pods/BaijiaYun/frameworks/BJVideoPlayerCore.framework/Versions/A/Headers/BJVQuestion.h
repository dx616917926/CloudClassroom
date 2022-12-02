//
//  BJVQuestion.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJVUser.h"

NS_ASSUME_NONNULL_BEGIN

/** 问答状态 */
typedef NS_ENUM(NSInteger, BJVQuestionState) {
    /** 已发布 */
    BJVQuestionPublished = 1 << 0,
    /** 未发布 */
    BJVQuestionUnpublished = 1 << 1,
    /** 已回复 */
    BJVQuestionReplied = 1 << 2,
    /** 未回复 */
    BJVQuestionUnreplied = 1 << 3,
    /** 所有状态 */
    BJVQuestionAllState = (1 << 4) - 1
};

@interface BJVQuestionCount: NSObject

@property (nonatomic, readonly) NSInteger totalCount;
@property (nonatomic, readonly) NSInteger publishCount;
@property (nonatomic, readonly) NSInteger replyCount;
@property (nonatomic, readonly) NSInteger replynopub;

@end

@interface BJVQuestionReply: NSObject

@property (nonatomic, readonly) NSTimeInterval createTime;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) BOOL publish;
@property (nonatomic, readonly) BJVUser *fromUser; // only user `ID、number、avatar、name、client type、role` available

@end

@interface BJVQuestion: NSObject

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic) BJVQuestionState state;
@property (nonatomic, readonly) NSTimeInterval lastTime; // 最后更新时间
@property (nonatomic, readonly) NSTimeInterval createTime; // not publish time
@property (nonatomic, readonly) NSString *content; // content
@property (nonatomic, readonly) NSInteger pageIndex; // current page index >= 0
@property (nonatomic, readonly) BJVQuestionCount *questionCount; // totalCount, publishCount, replyCount
@property (nonatomic, readonly) BJVUser *fromUser; // only user `ID、number、avatar、name、client type、role` available
@property (nonatomic, readonly, nullable) NSArray<BJVQuestionReply *> *replies; // reply
@property (nonatomic) BOOL forbid; // whether question owner is forbidden

- (void)updateQuestionWithUnpubishReply:(NSString *)reply fromUser:(BJVUser *)fromUser;

@end

NS_ASSUME_NONNULL_END
