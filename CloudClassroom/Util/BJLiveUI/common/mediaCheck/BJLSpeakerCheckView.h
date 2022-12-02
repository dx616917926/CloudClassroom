//
//  BJLSpeakerCheckView.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLMediaCheckBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLSpeakerCheckView: BJLMediaCheckBaseView

@property (nonatomic, readonly) NSString *speakerName;
@property (nonatomic, nullable) void (^speakerCheckCompletion)(BOOL success, BOOL needConfirm);
- (void)updateOutputPort;

@end

NS_ASSUME_NONNULL_END
