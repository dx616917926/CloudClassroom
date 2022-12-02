//
//  BJLStudyRoomVM.h
//  BJLiveCore
//
//  Created by Ney on 12/15/20.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLStudyRoomActiveUser.h"
#import "BJLStudyRoomReconnectParameters.h"
#import "BJLStudyRoomTutorPair.h"
#import "BJLStudyRoomQuestion.h"

typedef NS_ENUM(NSUInteger, BJLIcStudyRoomModeType) {
    // 初始状态
    BJLIcStudyRoomModeTypeInit = 0,
    // 自习模式，禁用麦克风
    BJLIcStudyRoomModeTypeStudy,
    // 讨论模式
    BJLIcStudyRoomModeTypeDiscuss,
    // 辅导模式
    BJLIcStudyRoomModeTypeTeach,
    // 保留模式
    BJLIcStudyRoomModeTypeUnknown,
};

NS_ASSUME_NONNULL_BEGIN

@interface BJLStudyRoomVM: BJLBaseVM

/** 自习室是否是自习室 */
@property (nonatomic, readonly) BOOL isStudyRoom;

/** 自习室是否开启讨论模式 */
@property (nonatomic, readonly) BOOL studyRoomEnableDiscuss;

/** 自习室是否开启授课模式 */
@property (nonatomic, readonly) BOOL studyRoomEnableTeach;

/** 自习室当前模式，若未初始化，则为 BJLIcStudyRoomModeTypeInit */
@property (nonatomic, readonly) BJLIcStudyRoomModeType studyRoomMode;

/** 自习室自习计时开始的时间戳，若未初始化则为 0 */
@property (nonatomic, readonly) NSTimeInterval startTime;

/** 自习室台上用户列表数据，仅仅在主动发起 requestStudyRoomActiveUserList 请求后才有值 */
@property (nonatomic, readonly) NSArray<BJLStudyRoomActiveUser *> *studyRoomActiveUserList;

/** 请求自习室自习时间排行榜数据 */
- (nullable BJLError *)requestStudyRoomTimeRankList;

/** 收到自习室自习时间排行榜数据 */
- (BJLObservable)onReceiveStudyRoomTimeRankList:(NSArray<BJLStudyRoomActiveUser *> *)res;

/** 请求自习室台上用户列表数据, 目前仅仅小班课自习室可用 */
- (nullable BJLError *)requestStudyRoomActiveUserList;

/** 收到自习室台上用户列表数据, 目前仅仅小班课自习室可用 */
- (BJLObservable)didReceiveStudyRoomActiveUserList:(NSArray<BJLStudyRoomActiveUser *> *)res;

/** 学生挂机/取消挂机 */
- (nullable BJLError *)studyRoomHangUp:(BOOL)hangUp;

/** 自习室模式切换 */
- (nullable BJLError *)studyRoomSwitchToMode:(BJLIcStudyRoomModeType)mode;

/**
 获取自习室公告
 #param completion title:公告标题  content:公告内容
 #return task
 */
- (nullable NSURLSessionDataTask *)getStudyRoomTipsWithCompletion:(nullable void (^)(NSString *_Nullable title, NSString *_Nullable content, BJLError *_Nullable error))completion;

/**
 获取自习室重进直播间的参数
 #param completion parameters:参数
 #return task
 */
- (nullable NSURLSessionDataTask *)getStudyRoomReconnectParametersWithCompletion:(nullable void (^)(BJLStudyRoomReconnectParameters *_Nullable parameters, BJLError *_Nullable error))completion;

#pragma mark - 场内辅导模式相关
/**
 是否支持场内辅导
*/
@property (nonatomic, readonly) BOOL enableTutor;

/**
 学生: 发送辅导申请
 #discussion 自习或者讨论模式状态才能申请辅导
 #discussion 辅导申请被允许/拒绝时会收到通知 `tutorRequestDidReplyToStudent:fromAssistant:accepted:`
 #return BJLError:
 BJLErrorCode_invalidCalling    错误调用，如在自习室的其他模式;
 BJLErrorCode_invalidUserRole   角色错误，如老师角色发起调用
*/
- (nullable BJLError *)sendTutorRequestToAssistant:(NSString *)assistantUserID;

/**
 学生发起辅导申请的老师的id。仅对学生起效，并且仅仅在辅导申请期间有效，取消、建立辅导会被置空
*/
@property (nonatomic, copy, readonly) NSString *assistantIDOfTutorRequest;

/**
 请求辅导自动取消倒计时总时长、更新间隔、剩余时间
 #discussion 调用 `sendTutorRequestToAssistant` 举手时设置为 `tutorRequestTimeoutInterval` 秒
 #discussion 每 `tutorRequestCountdownStep` 秒更新，变为 0.0 表示举手超时，变为 - 1.0 表示计时被取消 */
@property (nonatomic, readonly) NSTimeInterval tutorRequestTimeoutInterval, tutorRequestCountdownStep, tutorRequestTimeRemaining;

/**
 助教: 直播间内申请辅导的列表
*/
@property (nonatomic, copy, readonly) NSArray<BJLStudyRoomTutorPair *> *tutorRequestList;

/**
 助教: 收到辅导申请
 #param fromStudent 申请的学生
 */
- (BJLObservable)didReceiveTutorRequestFromStudent:(NSString *)studentUserID toAssistant:(NSString *)assistantID;

/**
 学生: 取消发送辅导申请
 */
- (nullable BJLError *)cancelSendTutorRequest;

/**
 老师: 学生取消辅导申请
 */
- (BJLObservable)tutorRequestDidCancelFromStudent:(NSString *)studentUserID;

/**
 老师: 允许/拒绝辅导申请
 #discussion 允许辅导后，
 #param studentUserID 想要辅导的学生用户id
 #param accept YES：接受，NO：拒绝
 #return BJLError:
 */
- (nullable BJLError *)replyTutorRequestToStudent:(NSString *)studentUserID accept:(BOOL)accept;

/**
 学生&老师: 收到允许/拒绝辅导申请的结果
 #discussion 允许/拒绝辅导申请的结果
 #param studentUserID 想要辅导的学生用户id
 #param studentUserID 接受辅导的老师用户id
 #param accepted YES：接受，NO：拒绝
 */
- (BJLObservable)tutorRequestDidReplyToStudent:(NSString *)studentUserID fromAssistant:(NSString *)assistantID accepted:(BOOL)accepted;

/**
 学生&老师: 当前用户的辅导数据，如果不在辅导状态则为nil
*/
@property (nonatomic, readonly) BJLStudyRoomTutorPair *currentUserTutorPair;

/**
 学生&老师: 当前辅导持续的时间
*/
@property (nonatomic, readonly) NSTimeInterval currentUserTutorDuration;

/**
 直播间内辅导的辅导列表，在收到辅导开始和结束的广播时，会更新该列表
 在发起 requestTutorPairList 之后会用服务端数据重置该列表
*/
@property (nonatomic, copy, readonly) NSArray<BJLStudyRoomTutorPair *> *tutorPairList;

/**
 学生&老师: 一个老师和学生进入辅导状态
 #discussion 一个老师和学生成功进行辅导结对，老师或学生都可以中断辅导
 #param tutorPair 辅导结对数据
 */
- (BJLObservable)tutorDidStartWithTutorPair:(BJLStudyRoomTutorPair *)tutorPair;

/**
 学生&老师: 老师或者学生关闭辅导状态
 #param tutorID 辅导id
 */
- (BJLObservable)tutorDidEndWithTutorPair:(BJLStudyRoomTutorPair *)tutorPair;

/**
 学生&老师: 结束辅导状态
 #discussion 老师或者学生结束辅导状态后，会收到`tutorDidEndWithTutorPair`回调
 #param tutorPair 辅导结对数据
 */
- (nullable BJLError *)endTutor;

/** 请求辅导配对数据 */
- (nullable BJLError *)requestTutorPairList;

/**
 学生&老师: 收到辅导配对数据。请求的数据会刷新 self.tutorPairList
 #param tutorPairList 辅导结对数据
 */
- (BJLObservable)onReceiveTutorPairList:(NSArray<BJLStudyRoomTutorPair *> *)tutorPairList;

#pragma mark - 场外辅导模式相关
/**
 是否支持场外辅导
*/
@property (nonatomic, readonly) BOOL enableTutorOutside;

/**
 自习室是否允许发送场外求助
*/
@property (nonatomic, readonly) BOOL enableSendTutorOutsideQuestion;

/**
 是否是场外辅导的直播间
*/
@property (nonatomic, readonly, getter=isTutorOutsideRoom) BOOL tutorOutsideRoom;

/**
 学生：提交场外辅导问题
 #param text 问题内容，必选
 #param images 问题附带的图片，可选。仅支持jpg和png，最多5张，每张最大5M
 #param completion 回调，如果调用方法的入参错误，会直接回调并附带错误参数对象
 #return task。如果调用方法的入参错误，会直接return nil
 */
- (nullable NSURLSessionDataTask *)submitQuestionWithText:(NSString *)text imagesData:(NSArray<NSData *> *)imagesData imagesURL:(NSArray<NSString *> *)imagesURL completion:(nullable void (^)(NSURLSessionDataTask *_Nullable task, NSDictionary *_Nullable response, BJLError *_Nullable error))completion;

/**
 学生：撤销当前提交的场外辅导问题
 #param completion 回调，如果调用方法的入参错误，会直接回调并附带错误参数对象
 #return task。如果调用方法的入参错误，会直接return nil
 */
- (nullable NSURLSessionDataTask *)recallCurrentQuestionWithCompletion:(nullable void (^)(NSURLSessionDataTask *_Nullable task, NSDictionary *_Nullable response, BJLError *_Nullable error))completion;

/**
 学生：请求当前提交的场外辅导问题
 #param completion 回调，如果调用方法的入参错误，会直接回调并附带错误参数对象
 #return task。如果调用方法的入参错误，会直接return nil
 */
- (nullable NSURLSessionDataTask *)requestCurrentQuestionWithCompletion:(nullable void (^)(NSURLSessionDataTask *_Nullable task, BJLStudyRoomQuestion *_Nullable question, BJLError *_Nullable error))completion;

/**
 学生：请求所有场外辅导问题记录
 #param completion 回调，如果调用方法的入参错误，会直接回调并附带错误参数对象
 #return task。如果调用方法的入参错误，会直接return nil
 */
- (nullable NSURLSessionDataTask *)requestQuestionHistoryWithCompletion:(nullable void (^)(NSURLSessionDataTask *_Nullable task, NSArray<BJLStudyRoomQuestionAndAnswer *> *_Nullable questionList, BJLError *_Nullable error))completion;

/**
 学生: 收到老师的辅导通知
 #param questionReplyNotification 辅导通知数据
 */
- (BJLObservable)onReceiveReplyForQuestion:(BJLStudyRoomQuestionReplyNotification *)questionReplyNotification;

typedef NS_ENUM(NSUInteger, BJLIcStudyRoomTutorOutsideCloseReason) {
    BJLIcStudyRoomTutorOutsideCloseReasonExit = 0,
    BJLIcStudyRoomTutorOutsideCloseReasonTimeout,
};
/**
 学生&老师: 1v1辅导结束
 #param closeReason 结束原因
 */
- (BJLObservable)onReceiveTutorOutsideDidClosed:(BJLIcStudyRoomTutorOutsideCloseReason)closeReason;
@end

NS_ASSUME_NONNULL_END
