//
//  BJLHomeworkVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLHomeworkVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLHomeworkVM (swift)
- (id<BJLObservation>)sw_allHomeworksDidOverwrite:(BJLControlObserving (^)(NSArray<BJLHomework *> *_Nullable homeworks))block NS_SWIFT_NAME(sw_allHomeworksDidOverwrite(_:));
- (id<BJLObservation>)sw_didReceiveAllowStudentUploadHomework:(BJLControlObserving (^)(BOOL allow))block NS_SWIFT_NAME(sw_didReceiveAllowStudentUploadHomework(_:));
- (id<BJLObservation>)sw_didReceiveHomeworkSearchResultWithKeywordListHasmore:(BJLControlObserving (^)(NSString *keywork, NSArray<BJLHomework *> *_Nullable homeworks, BOOL hasmore))block NS_SWIFT_NAME(sw_didReceiveHomeworkSearchResultWithKeywordListHasmore(_:));
- (id<BJLObservation>)sw_didAddHomeworks:(BJLControlObserving (^)(NSArray<BJLHomework *> *homeworks))block NS_SWIFT_NAME(sw_didAddHomeworks(_:));
- (id<BJLObservation>)sw_didDeleteHomework:(BJLControlObserving (^)(BJLHomework *document))block NS_SWIFT_NAME(sw_didDeleteHomework(_:));
@end

NS_ASSUME_NONNULL_END
