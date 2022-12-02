//
//  BJLQRCodeScanner.h
//  BJLiveUI
//
//  Created by xijia dai on 2020/10/29.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLQRCodeScanner: UIViewController

/** 设置方向 */
@property (nonatomic) UIInterfaceOrientationMask scannerSupportOrientation;

/** 回调二维码数据 */
@property (nonatomic, nullable) void (^outputMessageCallback)(NSString *_Nullable message);

@end

NS_ASSUME_NONNULL_END
