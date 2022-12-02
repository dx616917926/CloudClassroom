//
//  BJLScreenRecordingNotifier.h
//  BJLiveBase
//
//  Created by Ney on 7/13/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScreenRecordingNotifier: NSObject
/** 系统是否在录屏状态，iOS11以上生效，iOS11以下一直是NO。这个状态不受业务逻辑影响 */
@property (nonatomic, class, readonly) BOOL systemScreenRecording;

/** 用户是否在录制屏幕，iOS11以上生效，iOS11以下一直是NO */
@property (nonatomic, readonly) BOOL screenRecording;

@property (nonatomic, copy) BOOL (^screenRecordingStateWillChangeBlock)(BJLScreenRecordingNotifier *notifier, BOOL screenRecording);
@property (nonatomic, copy) void (^screenRecordingStateChangeBlock)(BJLScreenRecordingNotifier *notifier, BOOL screenRecording);

- (void)startObserve;
- (void)stopObserve;
@end

NS_ASSUME_NONNULL_END
