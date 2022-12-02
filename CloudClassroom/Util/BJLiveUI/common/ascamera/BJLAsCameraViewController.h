//
//  BJLAsCameraViewController.h
//  BJLiveUI
//
//  Created by xijia dai on 2020/11/12.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJLAsCameraViewControllerDelegate;

@interface BJLAsCameraViewController: UIViewController

/**
 直播直播间
 #discussion 参考 `BJLiveCore`
 */
@property (nonatomic, readonly, nullable) BJLRoom *room;

/** 事件回调 `delegate` */
@property (nonatomic, weak) id<BJLAsCameraViewControllerDelegate> delegate;

/**
 通过链接创建直播间，创建直播间可能失败，返回 nil
 #param string          一般为 APP 拉起链接
 #return                直播间或者 nil
 */
+ (nullable __kindof instancetype)instanceWithURLString:(NSString *)string;

/** 退出直播间 */
- (void)exit;

#pragma mark - observable methods

- (BJLObservable)roomViewControllerEnterRoomSuccess:(BJLAsCameraViewController *)roomViewController;
- (BJLObservable)roomViewController:(BJLAsCameraViewController *)roomViewController
          enterRoomFailureWithError:(BJLError *)error;

- (BJLObservable)roomViewController:(BJLAsCameraViewController *)roomViewController
                  willExitWithError:(nullable BJLError *)error;
- (BJLObservable)roomViewController:(BJLAsCameraViewController *)roomViewController
                   didExitWithError:(nullable BJLError *)error;

@end

@protocol BJLAsCameraViewControllerDelegate <NSObject>

@optional

/** 进入直播间 - 成功/失败 */
- (void)roomViewControllerEnterRoomSuccess:(BJLAsCameraViewController *)roomViewController;
- (void)roomViewController:(BJLAsCameraViewController *)roomViewController
    enterRoomFailureWithError:(BJLError *)error;

/**
 退出直播间 - 正常/异常
 正常退出 `error` 为 `nil`，否则为异常退出
 参考 `BJLErrorCode` */
- (void)roomViewController:(BJLAsCameraViewController *)roomViewController
         willExitWithError:(nullable BJLError *)error;
- (void)roomViewController:(BJLAsCameraViewController *)roomViewController
          didExitWithError:(nullable BJLError *)error;

@end

NS_ASSUME_NONNULL_END
