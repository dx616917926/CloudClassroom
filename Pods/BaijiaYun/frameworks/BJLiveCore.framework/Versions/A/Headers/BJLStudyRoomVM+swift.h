//
//  BJLStudyRoomVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLStudyRoomVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLStudyRoomVM (swift)
- (id<BJLObservation>)sw_onReceiveStudyRoomTimeRankList:(BJLControlObserving (^)(NSArray<BJLStudyRoomActiveUser *> *res))block NS_SWIFT_NAME(sw_onReceiveStudyRoomTimeRankList(_:));
- (id<BJLObservation>)sw_didReceiveStudyRoomActiveUserList:(BJLControlObserving (^)(NSArray<BJLStudyRoomActiveUser *> *res))block NS_SWIFT_NAME(sw_didReceiveStudyRoomActiveUserList(_:));
- (id<BJLObservation>)sw_didReceiveTutorRequestFromStudentToAssistant:(BJLControlObserving (^)(NSString *studentUserID, NSString *assistantID))block NS_SWIFT_NAME(sw_didReceiveTutorRequestFromStudentToAssistant(_:));
- (id<BJLObservation>)sw_tutorRequestDidCancelFromStudent:(BJLControlObserving (^)(NSString *studentUserID))block NS_SWIFT_NAME(sw_tutorRequestDidCancelFromStudent(_:));
- (id<BJLObservation>)sw_tutorRequestDidReplyToStudentFromAssistantAccepted:(BJLControlObserving (^)(NSString *studentUserID, NSString *assistantID, BOOL accepted))block NS_SWIFT_NAME(sw_tutorRequestDidReplyToStudentFromAssistantAccepted(_:));
- (id<BJLObservation>)sw_tutorDidStartWithTutorPair:(BJLControlObserving (^)(BJLStudyRoomTutorPair *tutorPair))block NS_SWIFT_NAME(sw_tutorDidStartWithTutorPair(_:));
- (id<BJLObservation>)sw_tutorDidEndWithTutorPair:(BJLControlObserving (^)(BJLStudyRoomTutorPair *tutorPair))block NS_SWIFT_NAME(sw_tutorDidEndWithTutorPair(_:));
- (id<BJLObservation>)sw_onReceiveTutorPairList:(BJLControlObserving (^)(NSArray<BJLStudyRoomTutorPair *> *tutorPairList))block NS_SWIFT_NAME(sw_onReceiveTutorPairList(_:));
- (id<BJLObservation>)sw_onReceiveReplyForQuestion:(BJLControlObserving (^)(BJLStudyRoomQuestionReplyNotification *questionReplyNotification))block NS_SWIFT_NAME(sw_onReceiveReplyForQuestion(_:));
- (id<BJLObservation>)sw_onReceiveTutorOutsideDidClosed:(BJLControlObserving (^)(BJLIcStudyRoomTutorOutsideCloseReason closeReason))block NS_SWIFT_NAME(sw_onReceiveTutorOutsideDidClosed(_:));
@end

NS_ASSUME_NONNULL_END
