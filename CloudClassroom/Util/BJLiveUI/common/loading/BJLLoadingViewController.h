//
//  BJLLoadingViewController.h
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/9/18.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLLoadingViewController: UIViewController

/** loading 显示回调 */
@property (nonatomic, nullable) void (^showCallback)(BOOL reloading);

/** 进入直播间 */
@property (nonatomic, nullable) void (^enterCallback)(void);

/** 退出直播间 */
@property (nonatomic, nullable) void (^exitCallback)(void);

/** 加载完直播间信息回调 */
@property (nonatomic, nullable) void (^loadRoomInfoSucessCallback)(void);

/** 隐藏回调 */
@property (nonatomic, nullable) void (^hideCallback)(void);

/**
 初始化 loading 界面
 #param isInteractiveClass 是否为小班课, 用于初步判断当前班型是否不对
 */
- (instancetype)initWithRoom:(BJLRoom *)room isInteractiveClass:(BOOL)isInteractiveClass;

- (instancetype)init NS_UNAVAILABLE;

/** 忽略班型判断 */
@property (nonatomic) BOOL ignoreTemplate;

@end

NS_ASSUME_NONNULL_END
