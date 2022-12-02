//
//  BJLCameraCheckView.h
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLMediaCheckBaseView.h"

NS_ASSUME_NONNULL_BEGIN

/** ### 摄像头自检视图 */
@interface BJLCameraCheckView: BJLMediaCheckBaseView

@property (nonatomic, nullable) void (^cameraCheckCompletion)(BOOL success, BOOL needConfirm);
@property (nonatomic, readonly) NSString *cameraName;
- (void)updateOrientation:(UIInterfaceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
