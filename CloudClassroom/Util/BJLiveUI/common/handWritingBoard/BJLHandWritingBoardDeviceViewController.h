//
//  BJLHandWritingBoardDeviceViewController.h
//  BJLiveUI
//
//  Created by xijia dai on 2021/5/27.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

/** 手写板信息 */
@interface BJLHandWritingBoardDeviceInfo: NSObject
// 设备标识符
@property (nonatomic, readonly) NSString *identifier;
// 设备名
@property (nonatomic, readonly, nullable) NSString *name;
// 最后一次链接的时间戳
@property (nonatomic, readonly) NSTimeInterval lastTimestamp;
@end

@interface BJLHandWritingBoardDeviceViewController: BJLTableViewController

@property (nonatomic) void (^connectFailedCallback)(void);
@property (nonatomic) void (^dormantCallback)(void);
+ (nullable BJLHandWritingBoardDeviceInfo *)prevConnectedWritingBoard;
- (instancetype)initWithRoom:(BJLRoom *)room;
- (void)autoConnectIfFindPrevConnectedDevice:(void (^__nullable)(BOOL success))completion;
- (void)disConnectCurrentConnectedDevice;

@end

NS_ASSUME_NONNULL_END
