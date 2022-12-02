//
//  BJVRoomVM.h
//  Pods
//
//  Created by 辛亚鹏 on 2016/12/21.
//  Copyright © 2016年 Baijia Cloud. All rights reserved.
//

#import "BJVBaseVM.h"
#import "BJPDocumentCatalogueModel.h"
#import "BJPPageChangeModel.h"
#import "BJVQuestion.h"
#import "BJVNotice.h"
#import "BJVLamp.h"
#import "BJVSurvey.h"
#import "BJVQuiz.h"
#import "BJVAnswerSheet.h"
#import "BJVCloudVideoPlayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJVRoomVM: BJVBaseVM

/** 回放房间公告 */
@property (nonatomic, readonly) BJVNotice *notice;

/** 回放房间跑马灯 */
@property (nonatomic, readonly, nullable) BJVLamp *lamp;

/** 当前是否正在播放媒体文件 */
@property (nonatomic, readonly) BOOL isMediaPlaying;

/** 当前是否正在共享屏幕 */
@property (nonatomic, readonly) BOOL isDesktopSharing;

#pragma mark - 课件

/** 当前直播间内课件的大纲信息 */
@property (nonatomic, readonly, nullable) NSArray<BJPDocumentCatalogueModel *> *documentCatalogueList;

/** 当前直播间内实时的最新一条翻页数据 */
@property (nonatomic, readonly, nullable) BJPPageChangeModel *lastPageChangeSignal;

#pragma mark - 定制广播信令

/**
 收到定制广播信令
 #param key     信令类型
 #param value   信令内容，类型可能是字符串或者字典等 JSON 数据类型
 #param isCache 是否为缓存
 */
- (BJLObservable)didReceiveCustomizedBroadcast:(NSString *)key value:(nullable id)value isCache:(BOOL)isCache;

#pragma mark - 测验

/**
 学生: 收到新题目
 #param survey 题目
 */
- (BJLObservable)didReceiveSurvey:(BJVSurvey *)survey;

/** 学生: 收到答题结束 */
- (BJLObservable)didFinishSurvey;

#pragma mark - 测验v2 h5

- (BJLObservable)didReceiveQuizMessage:(NSDictionary<NSString *, id> *)message;

/** h5页面使用测验ID 生成请求 */
- (nullable NSURLRequest *)quizRequestWithID:(NSString *)quizID error:(NSError *__autoreleasing *)error;

#pragma mark - 测验v2 Native

/** 当前的新版测验状态列表，key -> 测验 ID，value -> 测验状态，测验的先后根据测验 ID 从小到大对应 */
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSNumber *> *quizStateList;

/** 正在进行的测验，至多只有一个测验正在进行，如果没有正在进行的测验，值为空 */
@property (nonatomic, readonly, nullable) NSString *currentQuizID;

- (BJLObservable)didStartQuizWithID:(NSString *)quizID force:(BOOL)force;

- (BJLObservable)didEndQuizWithID:(NSString *)quizID;

- (BJLObservable)didReceiveQuizWithID:(NSString *)quizID solution:(NSDictionary<NSString *, id> *)solutions;

- (BJLObservable)didLoadCurrentQuiz:(BJVQuiz *)quiz;

- (BJLObservable)didLoadParentRoomFinishedQuizList:(nullable NSArray<BJVQuiz *> *)quizList;

#pragma mark - 答题器

/** 收到答题器开始信息 */
- (BJLObservable)didReceiveQuestionAnswerSheet:(BJVAnswerSheet *)answerSheet;

/**
 收到答题结束信息
 #param endTime 答题结束时间戳
 */
- (BJLObservable)didReceiveEndQuestionAnswerWithEndTime:(NSTimeInterval)endTime;

/**
 收到答题器撤销信息
 #param endTime 答题结束时间戳
 */
- (BJLObservable)didReceiveRevokeQuestionAnswerWithEndTime:(NSTimeInterval)endTime;

#pragma mark - 问答

/** 清空问答 */
- (BJLObservable)didResetQuestion;

/**
 问答发布成功
 #discussion 只有在发布没有回答的问答时才会回调此方法
 #param question 问答全部内容
 */
- (BJLObservable)didPublishQuestion:(BJVQuestion *)question;

/**
 收到问答回复
 #discussion 问答如果已经有了回复，取消发布之后重新发布的情况，只回调此方法，不回调发布成功
 #param question 问答全部内容
 */
- (BJLObservable)didReplyQuestion:(BJVQuestion *)question;

/**
 取消发布问答成功
 #discussion 任何有回答或者没有回答的问题取消发布成功都回调此方法
 #param questionID 问答 ID
 */
- (BJLObservable)didUnpublishQuestionWithQuestionID:(NSString *)questionID;

#pragma mark -

/** 用户是否在录制屏幕，iOS11以上生效，iOS11以下一直是NO */
@property (nonatomic, readonly) BOOL screenCaptured;

/** 云插播的控制器 */
@property (nonatomic, readonly) id<BJVCloudVideoPlayerProtocol> cloudVideoPlayer;

@end

NS_ASSUME_NONNULL_END
