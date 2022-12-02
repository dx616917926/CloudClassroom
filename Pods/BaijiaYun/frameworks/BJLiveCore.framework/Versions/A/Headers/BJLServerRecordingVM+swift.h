//
//  BJLServerRecordingVM+swift.h
//  BJLiveCore
//
//  Created by ney on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLServerRecordingVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLServerRecordingVM (swift)
- (id<BJLObservation>)sw_didReceiveServerRecordingFromUser:(BJLControlObserving (^)(BOOL serverRecording, BJLUser *fromUser))block NS_SWIFT_NAME(sw_didReceiveServerRecordingFromUser(_:));
- (id<BJLObservation>)sw_requestServerRecordingTranscodeAccept:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_requestServerRecordingTranscodeAccept(_:));
- (id<BJLObservation>)sw_requestServerRecordingChangeResolutionAccept:(BJLControlObserving (^)(void))block NS_SWIFT_NAME(sw_requestServerRecordingChangeResolutionAccept(_:));
- (id<BJLObservation>)sw_requestServerRecordingDidFailed:(BJLControlObserving (^)(NSString *message))block NS_SWIFT_NAME(sw_requestServerRecordingDidFailed(_:));
@end

NS_ASSUME_NONNULL_END
