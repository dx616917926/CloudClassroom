//
//  BJLRoomVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLRoomVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLRoomVM (swift)
- (id<BJLObservation>)sw_didVideoExchangePositonWithPPT:(BJLControlObserving (^)(BOOL videoInMainPosition))block NS_SWIFT_NAME(sw_didVideoExchangePositonWithPPT(_:));
- (id<BJLObservation>)sw_didReceiveAssistantaAuthorityChanged:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveAssistantaAuthorityChanged(_:));
- (id<BJLObservation>)sw_didStartLiveBroadcast:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didStartLiveBroadcast(_:));
- (id<BJLObservation>)sw_didStopLiveBroadcast:(BJLControlObserving (^)(BJLError *_Nullable error))block NS_SWIFT_NAME(sw_didStopLiveBroadcast(_:));
- (id<BJLObservation>)sw_onReceiveRollCallResult:(BJLControlObserving (^)(BJLRollCallResult *result))block NS_SWIFT_NAME(sw_onReceiveRollCallResult(_:));
- (id<BJLObservation>)sw_didReceiveRollcallWithTimeout:(BJLControlObserving (^)(NSTimeInterval timeout))block NS_SWIFT_NAME(sw_didReceiveRollcallWithTimeout(_:));
- (id<BJLObservation>)sw_rollcallDidFinish:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_rollcallDidFinish(_:));
- (id<BJLObservation>)sw_didReceiveAttentionWarning:(BJLControlObserving (^)(NSString *warning))block NS_SWIFT_NAME(sw_didReceiveAttentionWarning(_:));
- (id<BJLObservation>)sw_likeRecordsDidOverwrite:(BJLControlObserving (^)(NSDictionary<NSString *, NSNumber *> *records))block NS_SWIFT_NAME(sw_likeRecordsDidOverwrite(_:));
- (id<BJLObservation>)sw_didReceiveLikeForUserNumberRecords:(BJLControlObserving (^)(NSString *userNumber, NSDictionary<NSString *, NSNumber *> *records))block NS_SWIFT_NAME(sw_didReceiveLikeForUserNumberRecords(_:));
- (id<BJLObservation>)sw_didReceiveLikeForGroupIDGroupName:(BJLControlObserving (^)(NSInteger groupID, NSString *_Nullable groupName))block NS_SWIFT_NAME(sw_didReceiveLikeForGroupIDGroupName(_:));
- (id<BJLObservation>)sw_likeRecordsDidOverwriteWithGoupLikeInfos:(BJLControlObserving (^)(NSDictionary<NSNumber *, NSNumber *> *groupInfo))block NS_SWIFT_NAME(sw_likeRecordsDidOverwriteWithGoupLikeInfos(_:));
- (id<BJLObservation>)sw_didStartEnvelopRainWithIDDuration:(BJLControlObserving (^)(NSInteger envelopeID, NSInteger duration))block NS_SWIFT_NAME(sw_didStartEnvelopRainWithIDDuration(_:));
- (id<BJLObservation>)sw_didFinishEnvelopRainWithID:(BJLControlObserving (^)(NSInteger envelopeID))block NS_SWIFT_NAME(sw_didFinishEnvelopRainWithID(_:));
- (id<BJLObservation>)sw_didReceiveRankingList:(BJLControlObserving (^)(NSArray<BJLEnvelopeRank *> *rankList))block NS_SWIFT_NAME(sw_didReceiveRankingList(_:));
- (id<BJLObservation>)sw_didReceiveSurveyHistoryRightCountWrongCount:(BJLControlObserving (^)(NSArray<BJLSurvey *> *surveyHistory, NSInteger rightCount, NSInteger wrongCount))block NS_SWIFT_NAME(sw_didReceiveSurveyHistoryRightCountWrongCount(_:));
- (id<BJLObservation>)sw_didReceiveSurvey:(BJLControlObserving (^)(BJLSurvey *survey))block NS_SWIFT_NAME(sw_didReceiveSurvey(_:));
- (id<BJLObservation>)sw_didReceiveSurveyResultsOrder:(BJLControlObserving (^)(NSDictionary<NSString *, NSNumber *> *results, NSInteger order))block NS_SWIFT_NAME(sw_didReceiveSurveyResultsOrder(_:));
- (id<BJLObservation>)sw_didFinishSurvey:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didFinishSurvey(_:));
- (id<BJLObservation>)sw_didReceiveQuizMessage:(BJLControlObserving (^)(NSDictionary<NSString *, id> *message))block NS_SWIFT_NAME(sw_didReceiveQuizMessage(_:));
- (id<BJLObservation>)sw_didStartQuizWithIDForce:(BJLControlObserving (^)(NSString *quizID, BOOL force))block NS_SWIFT_NAME(sw_didStartQuizWithIDForce(_:));
- (id<BJLObservation>)sw_didEndQuizWithID:(BJLControlObserving (^)(NSString *quizID))block NS_SWIFT_NAME(sw_didEndQuizWithID(_:));
- (id<BJLObservation>)sw_didReceiveQuizWithIDSolution:(BJLControlObserving (^)(NSString *quizID, NSDictionary<NSString *, id> *solutions))block NS_SWIFT_NAME(sw_didReceiveQuizWithIDSolution(_:));
- (id<BJLObservation>)sw_didLoadCurrentQuiz:(BJLControlObserving (^)(BJLQuiz *quiz))block NS_SWIFT_NAME(sw_didLoadCurrentQuiz(_:));
- (id<BJLObservation>)sw_didSubmitQuizWithIDSolution:(BJLControlObserving (^)(NSString *quizID, NSDictionary<NSString *, id> *solutions))block NS_SWIFT_NAME(sw_didSubmitQuizWithIDSolution(_:));
- (id<BJLObservation>)sw_didLoadParentRoomFinishedQuizList:(BJLControlObserving (^)(NSArray<BJLQuiz *> *_Nullable quizList))block NS_SWIFT_NAME(sw_didLoadParentRoomFinishedQuizList(_:));
- (id<BJLObservation>)sw_didLoadQuestionHistoryCurrentPageTotalPage:(BJLControlObserving (^)(NSArray<BJLQuestion *> *history, NSInteger currentPage, NSInteger totalPage))block NS_SWIFT_NAME(sw_didLoadQuestionHistoryCurrentPageTotalPage(_:));
- (id<BJLObservation>)sw_didLoadQuestionHistoryCurrentPageQuestionCountState:(BJLControlObserving (^)(NSArray<BJLQuestion *> *history, NSInteger currentPage, BJLQuestionCount *questionCount, BJLQuestionState state))block NS_SWIFT_NAME(sw_didLoadQuestionHistoryCurrentPageQuestionCountState(_:));
- (id<BJLObservation>)sw_didSendQuestion:(BJLControlObserving (^)(BJLQuestion *question))block NS_SWIFT_NAME(sw_didSendQuestion(_:));
- (id<BJLObservation>)sw_didPublishQuestion:(BJLControlObserving (^)(BJLQuestion *question))block NS_SWIFT_NAME(sw_didPublishQuestion(_:));
- (id<BJLObservation>)sw_didUnpublishQuestion:(BJLControlObserving (^)(BJLQuestion *question))block NS_SWIFT_NAME(sw_didUnpublishQuestion(_:));
- (id<BJLObservation>)sw_didReplyQuestion:(BJLControlObserving (^)(BJLQuestion *question))block NS_SWIFT_NAME(sw_didReplyQuestion(_:));
- (id<BJLObservation>)sw_didSwitchQuestionForbidForUserForbid:(BJLControlObserving (^)(BJLUser *user, BOOL forbid))block NS_SWIFT_NAME(sw_didSwitchQuestionForbidForUserForbid(_:));
- (id<BJLObservation>)sw_didReceiveCustomizedBroadcastValueIsCache:(BJLControlObserving (^)(NSString *key, id _Nullable value, BOOL isCache))block NS_SWIFT_NAME(sw_didReceiveCustomizedBroadcastValueIsCache(_:));
- (id<BJLObservation>)sw_didUpdateRoomLayout:(BJLControlObserving (^)(BJLRoomLayout roomLayout))block NS_SWIFT_NAME(sw_didUpdateRoomLayout(_:));
- (id<BJLObservation>)sw_didUpdateWebPageWithURLStringOpenIsCache:(BJLControlObserving (^)(NSString *_Nullable urlString, BOOL open, BOOL isCache))block NS_SWIFT_NAME(sw_didUpdateWebPageWithURLStringOpenIsCache(_:));
- (id<BJLObservation>)sw_didUpdateWebPageWindowWithModel:(BJLControlObserving (^)(BJLWindowUpdateModel *model))block NS_SWIFT_NAME(sw_didUpdateWebPageWindowWithModel(_:));
- (id<BJLObservation>)sw_didUpdateCountDownTimerWithTimeOpen:(BJLControlObserving (^)(NSTimeInterval time, BOOL open))block NS_SWIFT_NAME(sw_didUpdateCountDownTimerWithTimeOpen(_:));
- (id<BJLObservation>)sw_didReceiveRevokeCountDownTimer:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveRevokeCountDownTimer(_:));
- (id<BJLObservation>)sw_didReceiveTimerWithTotalTimeCountDownTimeIsDecrease:(BJLControlObserving (^)(NSInteger totalTime, NSInteger countDownTime, BOOL isDecrease))block NS_SWIFT_NAME(sw_didReceiveTimerWithTotalTimeCountDownTimeIsDecrease(_:));
- (id<BJLObservation>)sw_didReceivePauseTimerWithTotalTimeLeftCountDownTimeIsDecrease:(BJLControlObserving (^)(NSInteger totalTime, NSInteger countDownTime, BOOL isDecrease))block NS_SWIFT_NAME(sw_didReceivePauseTimerWithTotalTimeLeftCountDownTimeIsDecrease(_:));
- (id<BJLObservation>)sw_didReceiveStopTimer:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveStopTimer(_:));
- (id<BJLObservation>)sw_didReceiveQuestionResponderWithTime:(BJLControlObserving (^)(NSInteger time))block NS_SWIFT_NAME(sw_didReceiveQuestionResponderWithTime(_:));
- (id<BJLObservation>)sw_didReceiveEndQuestionResponderWithWinner:(BJLControlObserving (^)(BJLUser *_Nullable winner))block NS_SWIFT_NAME(sw_didReceiveEndQuestionResponderWithWinner(_:));
- (id<BJLObservation>)sw_didReceiveRevokeQuestionResponder:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveRevokeQuestionResponder(_:));
- (id<BJLObservation>)sw_didReceiveCloseQuestionResponder:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveCloseQuestionResponder(_:));
- (id<BJLObservation>)sw_didReceiveQuestionAnswerSheet:(BJLControlObserving (^)(BJLAnswerSheet *answerSheet))block NS_SWIFT_NAME(sw_didReceiveQuestionAnswerSheet(_:));
- (id<BJLObservation>)sw_didReceiveEndQuestionAnswerWithEndTime:(BJLControlObserving (^)(NSTimeInterval endTime))block NS_SWIFT_NAME(sw_didReceiveEndQuestionAnswerWithEndTime(_:));
- (id<BJLObservation>)sw_didReceiveRevokeQuestionAnswerWithEndTime:(BJLControlObserving (^)(NSTimeInterval endTime))block NS_SWIFT_NAME(sw_didReceiveRevokeQuestionAnswerWithEndTime(_:));
- (id<BJLObservation>)sw_didReceiveQuestionAnswerSubmited:(BJLControlObserving (^)(BJLAnswerSheet *res))block NS_SWIFT_NAME(sw_didReceiveQuestionAnswerSubmited(_:));
- (id<BJLObservation>)sw_didReceiveCloseQuestionAnswer:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveCloseQuestionAnswer(_:));
- (id<BJLObservation>)sw_didReceiveQuestionAnswerDetailInfo:(BJLControlObserving (^)(NSArray<BJLAnswerSheet *> *answerSheetArray))block NS_SWIFT_NAME(sw_didReceiveQuestionAnswerDetailInfo(_:));
- (id<BJLObservation>)sw_didReceiveRandomSelectCandidateListChoosenUser:(BJLControlObserving (^)(NSArray<NSString *> *_Nullable candidateList, BJLUser *user))block NS_SWIFT_NAME(sw_didReceiveRandomSelectCandidateListChoosenUser(_:));
- (id<BJLObservation>)sw_didReceiveLotteryResult:(BJLControlObserving (^)(BJLLottery *lottery))block NS_SWIFT_NAME(sw_didReceiveLotteryResult(_:));
- (id<BJLObservation>)sw_didReceiveBeginCommandLottery:(BJLControlObserving (^)(BJLCommandLotteryBegin *commandLotteryBegin))block NS_SWIFT_NAME(sw_didReceiveBeginCommandLottery(_:));
- (id<BJLObservation>)sw_didReceiveHitCommandLottery:(BJLControlObserving (^)(NSDictionary *res))block NS_SWIFT_NAME(sw_didReceiveHitCommandLottery(_:));
- (id<BJLObservation>)sw_onReceiveBonusRankList:(BJLControlObserving (^)(BJLBonusList *bonusRankList))block NS_SWIFT_NAME(sw_onReceiveBonusRankList(_:));
- (id<BJLObservation>)sw_onReceiveBonusChangeSuccess:(BJLControlObserving (^)(CGFloat remainBonus, BOOL success))block NS_SWIFT_NAME(sw_onReceiveBonusChangeSuccess(_:));
- (id<BJLObservation>)sw_onReceiveBonusIncreasing:(BJLControlObserving (^)(CGFloat bonus))block NS_SWIFT_NAME(sw_onReceiveBonusIncreasing(_:));
- (id<BJLObservation>)sw_didReceiveRoundaboutStartWithTargetValue:(BJLControlObserving (^)(NSInteger targetNumer))block NS_SWIFT_NAME(sw_didReceiveRoundaboutStartWithTargetValue(_:));
- (id<BJLObservation>)sw_didReceiveRoundaboutclosed:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveRoundaboutclosed(_:));
- (id<BJLObservation>)sw_didReceiveRoundaboutOpened:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_didReceiveRoundaboutOpened(_:));
- (id<BJLObservation>)sw_didReceivePKStatusWithModel:(BJLControlObserving (^)(BJLPKStatusModel *model))block NS_SWIFT_NAME(sw_didReceivePKStatusWithModel(_:));
- (id<BJLObservation>)sw_didReceivePKVoteStatus:(BJLControlObserving (^)(BJLPKStatusModel *model))block NS_SWIFT_NAME(sw_didReceivePKVoteStatus(_:));
@end

NS_ASSUME_NONNULL_END
