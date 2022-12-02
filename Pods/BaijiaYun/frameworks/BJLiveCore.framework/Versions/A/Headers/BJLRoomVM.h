//
//  BJLRoomVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-05.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"

#import "BJLRoomInfo.h"
#import "BJLUser.h"
#import "BJLNotice.h"
#import "BJLSurvey.h"
#import "BJLQuestion.h"
#import "BJLAnswerSheet.h"
#import "BJLStudyReportDataSource.h"
#import "BJLQuiz.h"
#import "BJLEnvelopeResult.h"
#import "BJLLamp.h"
#import "BJLLottery.h"
#import "BJLRollCallResult.h"
#import "BJLMajorNotice.h"
#import "BJLBonusModel.h"
#import "BJLWindowUpdateModel.h"
#import "BJLPKStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

/** 专业版小班课直播间布局 */
typedef NS_ENUM(NSInteger, BJLRoomLayout) {
    /** 画廊布局 */
    BJLRoomLayout_gallary = 1,
    /** 板书布局 */
    BJLRoomLayout_blackboard = 2
};

/** ### 直播间信息、状态，用户信息，公告等 */
@interface BJLRoomVM: BJLBaseVM

/** 进入直播间时间 */
@property (nonatomic, readonly) NSTimeInterval enteringTimeInterval; // seconds since 1970

/**
 大班课 - 视频与 PPT 切换位置
 #param videoInMainPosition 视频是否切换到主位
 */
- (BJLObservable)didVideoExchangePositonWithPPT:(BOOL)videoInMainPosition;

- (nullable BJLError *)exchangeVideoPositonWithPPT:(BOOL)videoInMainPosition;

#pragma mark - 上课状态

/** 上课状态 */
@property (nonatomic, readonly) BOOL liveStarted;

/**
 老师: 设置上课状态
 #discussion 设置成功后修改 `liveStarted`
 #param liveStarted YES：上课，NO：下课
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求老师权限
 */
- (nullable BJLError *)sendLiveStarted:(BOOL)liveStarted;

/** 实际上课开始时间(单位: 毫秒) */
@property (nonatomic, readonly) NSTimeInterval classStartTimeMillisecond;

/** 理论排课开始时间(单位: 秒) */
@property (nonatomic, readonly) NSTimeInterval classStartTimesecond;

#pragma mark - 助教权限

/** 助教上麦权限 */
- (BOOL)getAssistantaAuthorityWithSpeak;

/** 助教画笔权限 */
- (BOOL)getAssistantaAuthorityWithPainter;

/** 助教文档操作权限 */
- (BOOL)getAssistantaAuthorityWithDocumentControl;

/** 助教上传文档权限 */
- (BOOL)getAssistantaAuthorityWithDocumentUpload;

/** 助教发布公告权限 */
- (BOOL)getAssistantaAuthorityWithNotice;

/** 助教禁言与踢出房间权限 */
- (BOOL)getAssistantaAuthorityWithForbidandKick;

/** 助教上下课权限 */
- (BOOL)getAssistantaAuthorityWithClassStartEnd;

/** 助教答题器权限 */
- (BOOL)getAssistantaAuthorityWithQuestionAnswer;

/** 助教云端录制权限 */
- (BOOL)getAssistantaAuthorityWithCloudRecord;

/** 收到助教权限变化 */
- (BJLObservable)didReceiveAssistantaAuthorityChanged;

#pragma mark - 大小班切换

/**
 线上双师课程切换大小班
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
*/
- (nullable BJLError *)requestSwitchClass;

#pragma mark - 转播

/** 是否支持转播 */
@property (nonatomic, readonly) BOOL enableLiveBroadcast;

/** 是否正在接收转播内容 */
@property (nonatomic, readonly) BOOL isReceiveLiveBroadcast;

/**
 开始转播
 #discussion 需要后台配置开启转播，关联了转播的直播间，才能使用
 #discussion 转播仅转播目标直播间的音视频、课件、画笔内容，同时将禁止这些功能，其他的功能如聊天等正常使用
 #discussion 大班课合流场景下使用
 #discussion 调用开始转播后，在未收到转播开始或者结束的回调之前的调用无效，但不会返回错误
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限
 BJLErrorCode_invalidCalling    错误调用，当前直播间不支持转播
 */
- (nullable BJLError *)startReceiveLiveBroadcast;

/** 停止转播，恢复直播间转播前的状态 */
- (nullable BJLError *)stopReceiveLiveBroadcast;

/** 收到转播开始，`isReceiveLiveBroadcast` 被置为 YES */
- (BJLObservable)didStartLiveBroadcast;

/**
 收到转播结束，`isReceiveLiveBroadcast` 被置为 NO
 #discussion 调用 `startReceiveLiveBroadcast` 开始后，如果没有关联任何转播直播间也会回调
 #param error 意外的转播结束可能有错误信息，没有一般是正常结束
 */
- (BJLObservable)didStopLiveBroadcast:(nullable BJLError *)error;

#pragma mark - 公告

/** 直播间公告 */
@property (nonatomic, readonly, copy, nullable) BJLNotice *notice;

/**
 获取直播间公告
 #discussion 连接直播间后、掉线重新连接后自动调用加载
 #discussion 获取成功后修改 `notice`
 */
- (void)loadNotice;
/**
 老师: 设置直播间公告
 #discussion 最多 BJLTextMaxLength_notice 个字符
 #discussion `noticeText` = `noticeText.length` ? `noticeText` : `linkURL.absoluteString`
 #discussion 设置成功后修改 `notice`
 #param noticeText 公告文字内容
 #param linkURL 公告跳转链接
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数，如字数超过 `BJLTextMaxLength_notice`；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)sendNoticeWithText:(nullable NSString *)noticeText
                                  linkURL:(nullable NSURL *)linkURL;

/** 直播间内主屏置顶公告 */
@property (nonatomic, readonly, copy, nullable) BJLMajorNotice *majorNotice;

#pragma mark - 跑马灯

/** 跑马灯内容 <包括文本内容，文本颜色，字体大小, 透明度> */
@property (nonatomic, readonly, copy, nullable) BJLLamp *lamp;

#pragma mark - 课前问卷

/**
 获取课前问卷
 #param completion 回调, isNeedFill: 是否需要填写问卷; questionURL: 问卷链接;
 */
- (void)getQuestionNaireWithCompletion:(nullable void (^)(BOOL isNeedFill, NSString *questionURL))completion;

#pragma mark - 课后评价

- (nullable NSURLRequest *)evaluationRequest;

#pragma mark - 点名
/** 老师: 发起点名
 学生需要在规定时间内 `timeout` 答到
 参考 `rollcallTimeRemaining`
 */
- (nullable BJLError *)sendRollcallWithTimeout:(NSTimeInterval)timeout;

/** 老师: 请求最近一次点名结果
 */
- (nullable BJLError *)requestLastRollcallResult;

/** 收到最近一次点名数据 */
- (BJLObservable)onReceiveRollCallResult:(BJLRollCallResult *)result;

/**
 点名倒计时
 #discussion 每秒更新
 */
@property (nonatomic, readonly) NSTimeInterval rollcallTimeRemaining;

/**
 助教点名不在主讲处显示时，才使用这个值
 */
@property (nonatomic, readonly) BOOL isRollcalling;

/**
 学生/老师: 收到点名
 #discussion 学生需要在规定时间内 `timeout` 答到 - 调用 `answerToRollcall`
 #discussion 参考 `rollcallTimeRemaining`
 #discussion 老师自己发起点名时，也会收到该回调
 #param timeout 超时时间
 */
- (BJLObservable)didReceiveRollcallWithTimeout:(NSTimeInterval)timeout;

/**
 学生/老师: 收到点名取消
 #discussion 可能是老师取消、或者倒计时结束
 #discussion 参考 `rollcallTimeRemaining`
 */
- (BJLObservable)rollcallDidFinish;

/**
 学生: 答到
 #return BJLError:
 BJLErrorCode_invalidCalling    错误调用，如老师没有点名或者点名已过期；
 BJLErrorCode_invalidUserRole   错误权限，要求非试听学生权限。
 */
- (nullable BJLError *)answerToRollcall;

#pragma mark - 专注度检测

- (BJLObservable)didReceiveAttentionWarning:(NSString *)warning;

#pragma mark - 点赞

/**
 个人点赞数据
 #discussion key --> userNumber
 #discussion value --> 点赞数
 */
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSNumber *> *likeList;

/**
 个人点赞数据-多种奖励方式
 #discussion key --> userNumber
 #discussion value --> dic, { "key" : "key对应类型的奖励数目" }
*/
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSDictionary *> *mutableAwardsInfo;

/**
  个人点赞数据-多种奖励方式, 具体的奖励方式的key值.  奖励方式由后台配置, 参考 BJLAward
 */
@property (nonatomic, readonly) NSString *awardKey;

/**
 分组点赞数据
 #discussion key --> groupID
 #discussion value --> 点赞数
 */
@property (nonatomic, readonly, nullable) NSDictionary<NSNumber *, NSNumber *> *grouplikeList;

/**
 点赞
 #param userNumber userNumber
 #return error:
 BJLErrorCode_invalidCalling    错误调用，如用户不在线；
 BJLErrorCode_invalidUserRole   错误权限，如点赞用户不能是学生，被点赞用户不能是老师，助教。
 */
- (nullable BJLError *)sendLikeForUserNumber:(NSString *)userNumber;

/**
 多种点赞方式
 #param userNumber userNumber
 #param key 多种奖励方式对应的key
 #return error:
 BJLErrorCode_invalidCalling    错误调用，如用户不在线；
 BJLErrorCode_invalidUserRole   错误权限，如点赞用户不能是学生，被点赞用户不能是老师，助教。
*/
- (nullable BJLError *)sendLikeForUserNumber:(NSString *)userNumber key:(nullable NSString *)key;

/**
 个人点赞覆盖更新
 #discussion 覆盖更新时调用，增量更新时不调用
 #discussion 首次连接 server，断开重连，下课，会导致覆盖更新
 #discussion 下课不会清空所有点赞
 #param records 点赞记录 key --> user number, value --> 点赞数
 */
- (BJLObservable)likeRecordsDidOverwrite:(NSDictionary<NSString *, NSNumber *> *)records;

/**
 收到个人点赞
 #discussion 收到的所有点赞都在点赞记录中，包括本次收到的点赞
 #param userNumber userNumber
 #param records 点赞记录 key --> userNumber，value --> 点赞数
 */
- (BJLObservable)didReceiveLikeForUserNumber:(NSString *)userNumber records:(NSDictionary<NSString *, NSNumber *> *)records;

/**
 收到一次分组点赞/台上用户点赞
 #discussion groupID 为 0 表示台上成员的点赞，非0表示分组点赞，非 0 时 groupName 为分组名
 #param groupID = 0 时，表示给台上成员的点赞，计入台上个人点赞数量，同时触发`likeRecordsDidOverwrite:`
 */
- (BJLObservable)didReceiveLikeForGroupID:(NSInteger)groupID groupName:(nullable NSString *)groupName;

/**
 批量点赞数据更新
 #discussion 批量点赞的数据不包含个人点赞数据
 #param groupInfo 分组点赞的记录 key -> groupID, value -> 该组点赞数
 */
- (BJLObservable)likeRecordsDidOverwriteWithGoupLikeInfos:(NSDictionary<NSNumber *, NSNumber *> *)groupInfo;

#pragma mark - 红包雨

/**
 创建红包雨
 #param amount 红包总数
 #param score 学分总数
 #param duration 红包雨时长
 #param completion 红包雨活动ID
 #return task
 */
- (nullable NSURLSessionDataTask *)createEnvelopeRainWithAmount:(NSInteger)amount
                                                          score:(NSInteger)score
                                                       duration:(NSInteger)duration
                                                     completion:(nullable void (^)(NSInteger envelopeID, BJLError *_Nullable error))completion;

/**
 抢红包
 #discussion 活动结束时，completion 也返回 0，并且没有 task
 #param envelopeID 红包雨活动ID
 #param completion 抢到的学分
 #return task
 */
- (nullable NSURLSessionDataTask *)grapEnvelopeWithID:(NSInteger)envelopeID completion:(nullable void (^)(NSInteger score, BJLError *_Nullable error))completion;

/**
 获取学生抢到的学分总数
 #param userNumber user number
 #param completion 学分总数
 #return task
 */
- (nullable NSURLSessionDataTask *)requestTotalScoreWithUserNumber:(NSString *)userNumber completion:(nullable void (^)(NSInteger totalScore, BJLError *_Nullable error))completion;

/**
 获取指定红包雨活动的最终结果
 #param envelopeID 红包雨活动ID
 #param completion completion 红包雨活动结果
 #return task
 */
- (nullable NSURLSessionDataTask *)requestResultWithEnvelopeID:(NSInteger)envelopeID completion:(nullable void (^)(BJLEnvelopeResult *_Nullable result, BJLError *_Nullable error))completion;

/**
 获取指定红包雨活动的排行榜
 #param envelopeID envelopeID
 #param completion completion 排行榜数据
 #return task
 */
- (nullable NSURLSessionDataTask *)requestRankListWithEnvelopeID:(NSInteger)envelopeID completion:(nullable void (^)(NSArray<BJLEnvelopeRank *> *_Nullable, BJLError *_Nullable))completion;

/**
 开始红包雨
 #param envelopeID 红包雨活动ID
 #param duration 红包雨时长
 #return error
 */
- (nullable BJLError *)startEnvelopRainWithID:(NSInteger)envelopeID duration:(NSInteger)duration;

/**
 收到红包雨
 #param envelopeID 红包雨活动ID
 #param duration 红包雨时长
 */
- (BJLObservable)didStartEnvelopRainWithID:(NSInteger)envelopeID duration:(NSInteger)duration;

/** 红包雨结束 */
- (BJLObservable)didFinishEnvelopRainWithID:(NSInteger)envelopeID;

/** 收到红包排行榜数据 */
- (BJLObservable)didReceiveRankingList:(NSArray<BJLEnvelopeRank *> *)rankList;

#pragma mark - 测验

/**
 请求历史题目
 BJLErrorCode_invalidUserRole   错误权限，要求非试听学生权限。
 */
- (nullable BJLError *)loadSurveyHistory;

/**
 收到历史题目以及当前用户的答题情况
 #param surveyHistory 历史题目
 #param rightCount 回答正确个数
 #param wrongCount 回答错误个数
 */
- (BJLObservable)didReceiveSurveyHistory:(NSArray<BJLSurvey *> *)surveyHistory
                              rightCount:(NSInteger)rightCount
                              wrongCount:(NSInteger)wrongCount;

/**
 老师: 发送题目 - 暂未实现
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 - (nullable BJLError *)sendSurvey:(BJLSurvey *)survey; */

/**
 学生: 收到新题目
 #param survey 题目
 */
- (BJLObservable)didReceiveSurvey:(BJLSurvey *)survey;

/**
 学生: 答题
 #param answers `BJLSurveyOption` 的 `key`
 #param result   与每个 `BJLSurveyOption` 的 `isAnswer` 比对得出，如果一个题目下所有 `BJLSurveyOption` 的 `isAnswer` 都是 NO 表示此题目没有标准答案
 #param order   `BJLSurvey` 的 `order`
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)sendSurveyAnswers:(NSArray<NSString *> *)answers
                                  result:(BJLSurveyResult)result
                                   order:(NSInteger)order;

/**
 收到答题统计
 #param results `NSDictionary` 的 key-value 分别是 `BJLSurveyOption` 的 `key` 和选择该选项的人数
 #param order   `BJLSurvey` 的 `order`
 */
- (BJLObservable)didReceiveSurveyResults:(NSDictionary<NSString *, NSNumber *> *)results
                                   order:(NSInteger)order;

/** 学生: 收到答题结束 */
- (BJLObservable)didFinishSurvey;

#pragma mark - 测验 V2 h5 方式

/**
 测验 V2 h5 方式
 #return BJLError:
 BJLErrorCode_invalidUserRole   试听学生不能使用测验
 BJLErrorCode_invalidCalling    错误调用
 */
- (nullable BJLError *)sendQuizMessage:(NSDictionary<NSString *, id> *)message;
- (BJLObservable)didReceiveQuizMessage:(NSDictionary<NSString *, id> *)message;
- (nullable NSURLRequest *)quizRequestWithID:(NSString *)quizID error:(NSError *__autoreleasing *)error;
// customView: h5定制版测验
- (nullable NSURLRequest *)quizRequestWithID:(NSString *)quizID customView:(nullable NSString *)customView error:(NSError *__autoreleasing *)error;

#pragma mark - 测验 V2 native 方式

/**
 当前的新版测验状态列表
 #discussion key -> 测验 ID，value -> 测验状态（参考 `BJLQuizState`），测验的先后根据测验 ID 从小到大对应
 */
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSNumber *> *quizStateList;

/**
 正在进行的测验
 #discussion 至多只有一个测验正在进行，如果没有正在进行的测验，值为空
 */
@property (nonatomic, readonly, nullable) NSString *currentQuizID;

/**
 加载测验列表
 #param completion quizList 仅 quiz ID，title，state 可用
 #return task
 */
- (nullable NSURLSessionDataTask *)loadQuizListWithCompletion:(nullable void (^)(NSArray<BJLQuiz *> *_Nullable quizList, BJLError *_Nullable error))completion;

/**
 新建，更新测验，老师或助教身份
 #discussion 创建新测验，测验 ID 使用 0，否则更新测验
 #param quiz 测验内容，参考 `BJLQuiz`
 #param completion 测验 ID
 #return task
 */
- (nullable NSURLSessionDataTask *)updateQuiz:(BJLQuiz *)quiz completion:(nullable void (^)(NSString *_Nullable quizID, BJLError *_Nullable error))completion;

/**
 删除测验，老师或助教身份
 #param quizID 测验 ID
 #param completion 测验 ID
 #return task
 */
- (nullable NSURLSessionDataTask *)deleteQuizWithID:(NSString *)quizID completion:(nullable void (^)(NSString *_Nullable quizID, BJLError *_Nullable error))completion;

/**
 加载测验详细内容
 #discussion 所有角色，对于老师或助教，如果测验结束了，有答题情况了，会返回测验的答题情况，对于学生，不会返回答题情况
 #param quizID 测验 ID
 #param completion BJLQuiz，测验详细信息
 #return task
 */
- (nullable NSURLSessionDataTask *)loadQuizDetailWithID:(NSString *)quizID completion:(nullable void (^)(BJLQuiz *_Nullable quiz, BJLError *_Nullable error))completion;

/**
 开始测验，老师或助教身份
 #param quizID quizID
 #param force 是否强制参加
 #return BJLError
 */
- (nullable BJLError *)startQuizWithID:(NSString *)quizID force:(BOOL)force;
- (BJLObservable)didStartQuizWithID:(NSString *)quizID force:(BOOL)force;

/**
 结束测验，老师或助教身份
 #param quizID quizID
 #return BJLError
 */
- (nullable BJLError *)endQuizWithID:(NSString *)quizID;
- (BJLObservable)didEndQuizWithID:(NSString *)quizID;

/**
 发布测验答案，老师或助教身份
 #param quiz 需要发布答案的测验 ID
 #return BJLError
 */
- (nullable BJLError *)publishQuizSolutionWithID:(NSString *)quizID;
- (BJLObservable)didReceiveQuizWithID:(NSString *)quizID solution:(NSDictionary<NSString *, id> *)solutions;

/**
 加载当前测验
 #discussion 学生身份如果回答过，将返回回答的结果
 #return BJLError
 */
- (nullable BJLError *)loadCurrentQuiz;
- (BJLObservable)didLoadCurrentQuiz:(BJLQuiz *)quiz;

/**
 提交测验，学生身份，此方法无提交完成的回调
 #param quizID 测验 ID
 #param solutions 测验回答 key -> 问题 ID，value -> 问题回答，对于 value，Radio 类型的问题的值为选项 ID，Checkbox 类型的问题的值为选项 ID 数组，ShortAnswer 类型的问题值为简答的关键内容
 #return BJLError
 */
- (nullable BJLError *)submitQuizWithID:(NSString *)quizID solution:(NSDictionary<NSString *, id> *)solutions;

/**
 收到学生提交测验，老师或助教身份
 #param quizID 测验ID
 #param solutions 学生答题情况
 */
- (BJLObservable)didSubmitQuizWithID:(NSString *)quizID solution:(NSDictionary<NSString *, id> *)solutions;

/**
 位于小班，加载大班的已经结束的测验列表
 #return BJLError
 */
- (nullable BJLError *)loadParentRoomFinishedQuizList;

/**
 收到大班结束的测验信息
 #param quizList 测验列表
 */
- (BJLObservable)didLoadParentRoomFinishedQuizList:(nullable NSArray<BJLQuiz *> *)quizList;

#pragma mark - 问答

/**
 禁止提出问答的 userNumber 列表
 #discussion 列表包含禁止提出问答的 userNumber
 */
@property (nonatomic, readonly, nullable) NSSet<NSString *> *forbidQuestionList;

/**
 请求指定页码的问答
 请求的state: 老师为BJLQuestionAllState, 学生为BJLQuestionPublished
 #param page 页码，从0开始计数
 #param count 每一页的数据量
 #return error
 */
- (nullable BJLError *)loadQuestionHistoryWithPage:(NSInteger)page countPerPage:(NSInteger)count;

/**
 收到指定页码的问答数据
 #param history 问答数据，可能为空列表
 #param currentPage 当前页码，从0开始计数
 #param totalPage 最大页码，从0开始计数
 */
- (BJLObservable)didLoadQuestionHistory:(NSArray<BJLQuestion *> *)history currentPage:(NSInteger)currentPage totalPage:(NSInteger)totalPage;

/**
 请求指定页码的问答
 #param page 页码，从0开始计数
 #param count 每一页的数据量
 #param state 请求对应state的question
 #param isSelf  yes: 返回当前登录用户的question, no: 返回所有人
 #return error
*/
- (nullable BJLError *)loadQuestionHistoryWithPage:(NSInteger)page countPerPage:(NSInteger)count state:(BJLQuestionState)state isSelf:(BOOL)isSelf;

/**
 收到指定页码的问答数据
 #param history 问答数据，可能为空列表
 #param currentPage 当前页码，从0开始计数
 #param questionCount 各状态问答的数目
 #param state 列表里面question的state
 */
- (BJLObservable)didLoadQuestionHistory:(NSArray<BJLQuestion *> *)history currentPage:(NSInteger)currentPage questionCount:(BJLQuestionCount *)questionCount state:(BJLQuestionState)state;

/**
 创建问答
 #param question 问题内容
 */
- (nullable BJLError *)sendQuestion:(NSString *)question;

/**
 创建问答成功
 #param question 问答，包括问答 ID
 */
- (BJLObservable)didSendQuestion:(BJLQuestion *)question;

/**
 发布问答，需要先成功创建问答
 #param questionID 问答 ID
 */
- (nullable BJLError *)publishQuestionWithQuestionID:(NSString *)questionID;

/**
 问答发布成功
 #discussion 只有在发布没有回答的问答时才会回调此方法
 #param question 问答全部内容
 */
- (BJLObservable)didPublishQuestion:(BJLQuestion *)question;

/**
 取消发布问答
 #param questionID 问答 ID
 */
- (nullable BJLError *)unpublishQuestionWithQuestionID:(NSString *)questionID;

/**
 取消发布问答成功
 #param question 问答全部内容
 */
- (BJLObservable)didUnpublishQuestion:(BJLQuestion *)question;

/**
 回复问答
 #param questionID 问答 ID
 #param state 该ID的问答的state
 #param reply 回复内容
 */
- (nullable BJLError *)replyQuestionWithID:(NSString *)questionID state:(BJLQuestionState)state reply:(NSString *)reply;

/**
 收到问答回复
 #discussion 问答如果已经有了回复，取消发布之后重新发布的情况，只回调此方法，不回调发布成功
 #param question 问答全部内容
 */
- (BJLObservable)didReplyQuestion:(BJLQuestion *)question;

/**
 改变问答状态
 #param user user
 #param forbid 是否禁止问答
 */
- (nullable BJLError *)switchQuestionForbidForUser:(BJLUser *)user forbid:(BOOL)forbid;

/**
 问答状态被改变
 #param user user
 #param forbid 禁止问答状态
 */
- (BJLObservable)didSwitchQuestionForbidForUser:(BJLUser *)user forbid:(BOOL)forbid;

#pragma mark - 定制信令

/**
 发送定制广播信令
 #discussion 发送定制广播信令
 #param key     信令类型
 #param value   信令内容，合法的 JSON 数据类型 - #see `[NSJSONSerialization isValidJSONObject:]`，序列化成字符串后不能过长，一般不超过 1024 个字符
 #param cache   是否缓存，缓存的信令可以通过 `requestCustomizedBroadcastCache:` 方法重新请求
 #return BJLError:
 BJLErrorCode_invalidArguments  不支持的 key，内容为空或者内容过长
 BJLErrorCode_areYouRobot       发送频率过快，要求每秒不超过 5 条、并且每分钟不超过 60 条
 */
- (nullable BJLError *)sendCustomizedBroadcast:(NSString *)key value:(id)value cache:(BOOL)cache;

/**
 收到定制广播信令
 #param key     信令类型
 #param value   信令内容，类型可能是字符串或者字典等 JSON 数据类型
 #param isCache 是否为缓存
 */
- (BJLObservable)didReceiveCustomizedBroadcast:(NSString *)key value:(nullable id)value isCache:(BOOL)isCache;

/**
 获取定制广播信令缓存
 #discussion 进直播间后调用此方法可以获取定制广播信令的缓存，结果回调 `didReceiveCustomizedBroadcast:value:isCache:`
 #param key     信令类型
 #return BJLError:
 BJLErrorCode_invalidArguments  不支持的 key
 BJLErrorCode_areYouRobot       发送频率过快，要求每秒不超过 5 条、并且每分钟不超过 60 条
 */
- (nullable BJLError *)requestCustomizedBroadcastCache:(NSString *)key;

#pragma mark - interactive class 专业版小班课 API

/**
 专业版小班课 - 更新直播间布局请求
 #param roomLayout 窗口布局类型
 #return BJLError: 错误码参考 BJLErrorCode
 */
- (nullable BJLError *)updateRoomLayout:(BJLRoomLayout)roomLayout;

/**
 专业版小班课 - 直播间布局更新通知
 #param roomLayout 窗口布局类型
 */
- (BJLObservable)didUpdateRoomLayout:(BJLRoomLayout)roomLayout;

#pragma mark - 网页

/**
 更新网页信息
 #param urlString 网址
 #param open YES：打开，NO：关闭
 #return BJLError
 */
- (nullable BJLError *)updateWebPageWithURLString:(nullable NSString *)urlString open:(BOOL)open;

/**
 收到网页信息更新
 #param urlString 网址
 #param open YES：打开，NO：关闭
 #param isCache 是否是缓存
 */
- (BJLObservable)didUpdateWebPageWithURLString:(nullable NSString *)urlString open:(BOOL)open isCache:(BOOL)isCache;

/**
 老师或助教：更新网页位置信息
 #param action 更新动作，参考 BJLWindowsUpdateAction
 #param info 位置信息，传空认为关闭网页，等同于在调用当前方法后再调用 `updateWebPageWithURLString:open:` 第二个参数传 NO
 #return BJLError
 #discussion 目前仅支持一个网页，因此仅位置信息有效，其余信息不需设置
 #discussion 必须后台配置开启同步网页位置功能，参考 `FeatureConfig` 的 `enableWebpageSynchronize`
 */
- (BJLError *)updateWebPageWithAction:(NSString *)action displayInfo:(nullable BJLWindowDisplayInfo *)info;

/**
 收到网页窗口位置更新
 #discussion 目前仅支持一个网页，因此仅位置信息有效，其余信息不需设置
 */
- (BJLObservable)didUpdateWebPageWindowWithModel:(BJLWindowUpdateModel *)model;

#pragma mark - 学情报告
/**
 课后学情报告
 #return BJLStudyReportDataSource对象，每次调用返回不同对象
 */
- (BJLStudyReportDataSource *)getStudyReportDataSource;

/**
 课后学情报告，获取到返回的`NSURLRequest`结果后用 webview 打开
 #param userNumber 用户 number
 #return NSURLRequest
 */
- (nullable NSURLRequest *)expressReportRequestWithUserNumber:(NSString *)userNumber;

#pragma mark - 计时器

/**
 发布计时器信息
 #param time 倒计时时间
 #param open YES：发布，NO：关闭
 #return BJLError
*/
- (nullable BJLError *)requestUpdateCountDownTimerWithTime:(NSTimeInterval)time
                                                      open:(BOOL)open;

/**
 收到计时器信息更新
 #param time 倒计时时间
 #param open YES：发布，NO：关闭
 */
- (BJLObservable)didUpdateCountDownTimerWithTime:(NSTimeInterval)time
                                            open:(BOOL)open;

/**
 撤回计时器
 #return BJLError
 */
- (nullable BJLError *)requestRevokeCountDownTimer;

/** 收到计时器撤回信息 */
- (BJLObservable)didReceiveRevokeCountDownTimer;

#pragma mark - 计时器 V2 支持正计时/倒计时

/**
 发布计时器
 #param totalTime 计时总时长，单位 秒
 #param countDownTime 当前计时剩余计时时长，单位 秒
 #param isDecrease 是否为倒计时，NO表示正计时
 #return BJLError
 */
- (nullable BJLError *)requestPublishTimerWithTotalTime:(NSInteger)totalTime
                                          countDownTime:(NSInteger)countDownTime
                                             isDecrease:(BOOL)isDecrease;

- (BJLObservable)didReceiveTimerWithTotalTime:(NSInteger)totalTime
                                countDownTime:(NSInteger)countDownTime
                                   isDecrease:(BOOL)isDecrease;

/**
 暂停计时器
 #param totalTime 计时总时长，单位 秒
 #param countDownTime 当前计时剩余计时时长，单位 秒
 #param isDecrease 是否为倒计时，NO表示正计时
 #return BJLError
 */
- (nullable BJLError *)requestPauseTimerWithTotalTime:(NSInteger)totalTime
                                    leftCountDownTime:(NSInteger)countDownTime
                                           isDecrease:(BOOL)isDecrease;

- (BJLObservable)didReceivePauseTimerWithTotalTime:(NSInteger)totalTime
                                 leftCountDownTime:(NSInteger)countDownTime
                                        isDecrease:(BOOL)isDecrease;

/**
 结束计时器
 #return BJLError
 */
- (nullable BJLError *)requestStopTimer;

- (BJLObservable)didReceiveStopTimer;

#pragma mark - 抢答器

/**
 请求发布抢答器
 #param time 抢答器倒计时
 #return BJLError
 */
- (nullable BJLError *)requestPublishQuestionResponderWithTime:(NSInteger)time;

/**
 收到抢答器开始信息
 #param time 抢答器倒计时
 */
- (BJLObservable)didReceiveQuestionResponderWithTime:(NSInteger)time;

/**
 请求结束抢答器
 #discussion 由老师发送抢答结束信令
 #return BJLError
 */
- (nullable BJLError *)endQuestionResponderWithShouldCloseWindow:(BOOL)shouldCloseWindow;

/**
 收到抢答器结束信息
 #param winner 抢答成功的用户, 为空则表示无人抢答
 */
- (BJLObservable)didReceiveEndQuestionResponderWithWinner:(nullable BJLUser *)winner;

/**
 请求撤销抢答器信息
 #return BJLError
 */
- (nullable BJLError *)requestRevokeQuestionResponder;

/** 收到抢答器撤销信息 */
- (BJLObservable)didReceiveRevokeQuestionResponder;

/**
 关闭抢答器窗口
 #discussion 用来同步助教和老师之前的关闭状态
 */
- (nullable BJLError *)requestCloseQuestionResponder;

/**
 收到关闭抢答器信息
 #discussion 用来同步助教和老师之前的关闭状态
 */
- (BJLObservable)didReceiveCloseQuestionResponder;

/**
 学生提交抢答
 #discussion 学生在抢答界面, 抢答后可发送提交抢答信令
 #return BJLError
 */
- (nullable BJLError *)submitQuestionResponder;

#pragma mark - 答题器

/**
 请求发布答题
 #param answerSheet 请求发布的答题内容，参数请参考`answerSheet`的属性内容
 #return BJLError
 */
- (nullable BJLError *)requestPublishQuestionAnswerSheet:(BJLAnswerSheet *)answerSheet;

/** 收到答题器开始信息 */
- (BJLObservable)didReceiveQuestionAnswerSheet:(BJLAnswerSheet *)answerSheet;

/**
 请求结束答题
 #discussion 由老师发送答题结束信令
 #param shouldSyncCloseWindow 结束答题器的同时是否需要同步关闭其他端的答题器窗口，若为YES则会收到`didReceiveCloseQuestionResponder`
 #return BJLError
 */
- (nullable BJLError *)requestEndQuestionAnswerWithShouldSyncCloseWindow:(BOOL)shouldSyncCloseWindow;

/**
 收到答题结束信息
 #param endTime 答题结束时间戳
 */
- (BJLObservable)didReceiveEndQuestionAnswerWithEndTime:(NSTimeInterval)endTime;

/**
 请求撤销答题
 #return BJLError
 */
- (nullable BJLError *)requestRevokeQuestionAnswer;

/**
 收到答题器撤销信息
 #param endTime 答题结束时间戳
 */
- (BJLObservable)didReceiveRevokeQuestionAnswerWithEndTime:(NSTimeInterval)endTime;

/**
 学生提交答题
 #return BJLError
 */
- (nullable BJLError *)submitQuestionAnswer:(BJLAnswerSheet *)answer;

/** 收到学生答题信息 */
- (BJLObservable)didReceiveQuestionAnswerSubmited:(BJLAnswerSheet *)res;

/**
 关闭答题器窗口
 #discussion 用来同步助教和老师之前的关闭状态
 */
- (nullable BJLError *)requestCloseQuestionAnswer;

/**
 收到答题器关闭信息
 #discussion 用来同步助教和老师之间的窗口关闭状态
 */
- (BJLObservable)didReceiveCloseQuestionAnswer;

/**
 请求答题数据
 #param ID 某一次答题ID，参数为空则表示请求当前直播间所有的历史答题数据
 */
- (nullable BJLError *)requestQuestionAnswerDetailInfoWithAnswerSheetID:(nullable NSString *)ID;

/** 收到答题数据 */
- (BJLObservable)didReceiveQuestionAnswerDetailInfo:(NSArray<BJLAnswerSheet *> *)answerSheetArray;

#pragma mark - 随机选人

- (BJLObservable)didReceiveRandomSelectCandidateList:(nullable NSArray<NSString *> *)candidateList choosenUser:(BJLUser *)user;

#pragma mark - 标准抽奖 和 口令抽奖

/** 抽奖结果
 #param lottery lottery
 */
- (BJLObservable)didReceiveLotteryResult:(BJLLottery *)lottery;

/**
 提交中奖信息
 #param userName 用户名
 #param mobile 用户联系电话
 #param beginTime 抽奖开始时间
 #param completion 提交完成的回调
 */
- (void)submitLotteryUserName:(NSString *)userName
                       mobile:(NSString *)mobile
                    beginTime:(NSTimeInterval)beginTime
                   completion:(nullable void (^)(BOOL success))completion;

/**
 口令抽奖 - 开始
 #param commandLotteryBegin commandLotteryBegin
 */
- (BJLObservable)didReceiveBeginCommandLottery:(BJLCommandLotteryBegin *)commandLotteryBegin;

/**
 口令抽奖 - 当学生发送的聊天信息匹配口令时，需要发送此请求
 身份为老师 / 助教 / 游客 调用此接口无效
 */
- (nullable BJLError *)requestHitCommandLottery;

/** 口令抽奖 - 发送口令请求的res */
- (BJLObservable)didReceiveHitCommandLottery:(NSDictionary *)res;

#pragma mark - 点播预热暖场
/**
 获取当前房间暖场点播视频的列表
 
 #param completion 回调, scuuess: 是否成功; isLoop: 是否循环播放; videoList: 点播视频列表
 */
- (void)getWarmingUpVideoListWithCompletion:(nullable void (^)(BOOL success, BOOL isLoop, NSArray<NSString *> *videoList))completion;

#pragma mark - 积分
/**
 直播间内剩余可用积分，只有请求过积分列表才会有数据
 */
@property (nonatomic, readonly) CGFloat remainBonus;
/// 请求积分列表
/// @param type 排行榜类型
/// @param top top xx
/// @param userNumber 自己的userNumber
/// @param groupID 自己的分组id、id为0表示未分组或者是大班身份
- (nullable BJLError *)requestBonusRankListWithType:(BJLBonusListType)type top:(NSInteger)top userNumber:(NSString *)userNumber groupID:(NSInteger)groupID;

/// 收到积分列表
- (BJLObservable)onReceiveBonusRankList:(BJLBonusList *)bonusRankList;

/// 收到积分变动，只有老师收到该信令
/// @param remainBonus 直播间剩余积分
/// @param success 积分变更是否成功，为false表示积分不够
- (BJLObservable)onReceiveBonusChange:(CGFloat)remainBonus success:(BOOL)success;

/// 收到积分增加信令，只有学生能收到该信令
/// @param bonus 本次新增积分
- (BJLObservable)onReceiveBonusIncreasing:(CGFloat)bonus;

#pragma mark - 课前检测

/// 检测上传和下载速度
/// @param completion ipAddress ip 地址，uploadSpeed 上传速度，downloadSpeed 下载速度
+ (void)checkUploadSpeedAndDownloadSpeedWithCompletion:(nullable void (^)(NSString *_Nullable ipAddress, CGFloat uploadSpeed, CGFloat downloadSpeed, BJLError *_Nullable error))completion;

/// 存储检测报告，需要在进直播间成功之后上报
/// @param dictionary 检测内容字典
+ (void)saveCheckResultWithDictionary:(NSDictionary *)dictionary;

#pragma mark - 转盘

- (nullable BJLError *)publishRoundaboutWithTargetNumer:(NSInteger)targetNumer;

- (BJLObservable)didReceiveRoundaboutStartWithTargetValue:(NSInteger)targetNumer;

- (nullable BJLError *)closeRoundabout;

- (BJLObservable)didReceiveRoundaboutclosed;

- (nullable BJLError *)openRoundabout;

- (BJLObservable)didReceiveRoundaboutOpened;

#pragma mark - PK

/** PK 状态 */
@property (nonatomic, nullable) BJLPKStatusModel *pkStatusModel;

/** 请求教室的 PK 状态，会回调 `didReceivePKStatusWithModel` 方法 */
- (void)requestPKStatus;

/** 收到 PK 状态变化的消息 */
- (BJLObservable)didReceivePKStatusWithModel:(BJLPKStatusModel *)model;

/**
 收到教室 PK 投票响应
 #discussion 在投票过程中会持续回调
 */
- (BJLObservable)didReceivePKVoteStatus:(BJLPKStatusModel *)model;

/**
 学生：PK 投票给某人
 #discussion 仅限非 PK 参与者在 PK 投票环节投票
 */
- (nullable BJLError *)requestPKVoteToUserNumber:(NSString *)userNumber;

@end

NS_ASSUME_NONNULL_END
