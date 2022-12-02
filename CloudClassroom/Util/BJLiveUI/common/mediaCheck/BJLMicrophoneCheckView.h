//
//  BJLMicrophoneCheckView.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLMediaCheckBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLMicrophoneCheckView: BJLMediaCheckBaseView

@property (nonatomic, readonly) NSString *microphoneName;
@property (nonatomic, nullable) void (^microphoneCheckCompletion)(BOOL success, BOOL needConfirm);
- (void)updateInputPort;

@end

NS_ASSUME_NONNULL_END
