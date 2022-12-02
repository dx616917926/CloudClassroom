//
//  BJLPopoverViewController.h
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/20.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLPopoverView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 任意按钮被点击都将 remove self, 点击事件不穿透
 */
@interface BJLPopoverViewController: UIViewController

/**
 init
 #param type BJLPopoverViewType
 #return self
 */
- (instancetype)initWithPopoverViewType:(BJLPopoverViewType)type;

/**
 init
 #param type BJLPopoverViewType
 #param message 提示消息
 #return self
 */
- (instancetype)initWithPopoverViewType:(BJLPopoverViewType)type message:(nullable NSString *)message;

/**
 init
 #param type BJLPopoverViewType
 #param message 提示消息
 #param detailMessage 详细描述信息
 #return self
 */
- (instancetype)initWithPopoverViewType:(BJLPopoverViewType)type message:(nullable NSString *)message detailMessage:(NSString *)detailMessage;

/** 取消提示框回调 */
@property (nonatomic, nullable) void (^cancelCallback)(void);

/** 确认提示框回调, 单个按钮只需设置这个回调 */
@property (nonatomic, nullable) void (^confirmCallback)(void);

/** 带有复选框的选择回调，仅当确认时复选框有效 */
@property (nonatomic, nullable) void (^checkConfirmCallback)(BOOL checked);

/** 附加提示框回调 */
@property (nonatomic, nullable) void (^appendCallback)(void);

/** 弹窗类型 */
@property (nonatomic, readonly) BJLPopoverViewType type;

/** 弹窗view */
@property (nonatomic, readonly) BJLPopoverView *popoverView;

/** 是否显示毛玻璃效果 */
- (void)updateEffectHidden:(BOOL)hidden;

- (void)runTimerWithInterval:(NSTimeInterval)timeInterval;
@property (nonatomic, assign, readonly) NSTimeInterval timeInterval;
@property (nonatomic, nullable) void (^timerCallback)(BJLPopoverViewController *vc, NSTimeInterval remain);
@end

NS_ASSUME_NONNULL_END
