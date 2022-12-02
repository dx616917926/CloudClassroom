//
//  BJLRoomViewController+protected.h
//  BJLiveUIBase-BJLiveUI
//
//  Created by xijia dai on 2022/2/15.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import "BJLiveUIBase.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BJLInnerRoomVCProtocol
@protocol BJLInnerRoomVCDelegate;

@protocol BJLInnerRoomVCProtocol <NSObject>

/** 直播直播间
 参考 `BJLiveCore` */
@property (nonatomic, readonly) BJLRoom *room;

/**
 通过参加码创建直播间
 #param roomSecret      直播间参加码
 #param userName        用户名
 #param userAvatar      用户头像 URL
 #return                直播间
 */
+ (UIViewController<BJLInnerRoomVCProtocol> *)instanceWithSecret:(NSString *)roomSecret
                                                        userName:(NSString *)userName
                                                      userAvatar:(nullable NSString *)userAvatar;

/**
 通过 ID 创建直播间
 #param roomID          直播间 ID
 #param user            用户，初始化时的属性未标记可为空的都需要有值，且字符值长度不能为0
 #param apiSign         API sign
 #return                直播间
 */
+ (UIViewController<BJLInnerRoomVCProtocol> *)instanceWithID:(NSString *)roomID
                                                     apiSign:(NSString *)apiSign
                                                        user:(BJLUser *)user;
/** 跑马灯内容 */
@property (nonatomic, copy, nullable) NSString *customLampContent;

- (void)exitWithCompletion:(nullable void (^)(void))completion;

#pragma mark observable methods
- (BJLObservable)roomViewControllerEnterRoomSuccess:(UIViewController<BJLInnerRoomVCProtocol> *)classViewController;

- (BJLObservable)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)classViewController enterRoomFailureWithError:(BJLError *)error;

- (BJLObservable)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)classViewController willExitWithError:(nullable BJLError *)error;

- (BJLObservable)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)classViewController didExitWithError:(nullable BJLError *)error;

/** 事件回调 `delegate` */
@property (nonatomic, weak) id<BJLInnerRoomVCDelegate> delegate;

@end

#pragma mark BJLInnerRoomVCDelegate
@protocol BJLInnerRoomVCDelegate <NSObject>

@optional

/** 进入直播间 - 成功/失败 */
- (void)roomViewControllerEnterRoomSuccess:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController;
- (void)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController enterRoomFailureWithError:(BJLError *)error;

/**
 退出直播间 - 正常/异常
 正常退出 `error` 为 `nil`，否则为异常退出
 参考 `BJLErrorCode` */
- (void)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController
         willExitWithError:(nullable BJLError *)error;
- (void)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController
          didExitWithError:(nullable BJLError *)error;

/**
 点击直播间右上方分享按钮回调。仅大班课有此功能
 */
- (nullable UIViewController *)roomViewControllerToShare:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController;

/**
 直播带货模板的回调
 点击购物车按钮, 展示商品列表
 @param sellViewController sellViewController
 @param superview 商品列表的父view
 @param closeCallback 关闭商品列表vc的回调
 */
- (void)roomViewController:(BJLRoomViewController *)sellViewController openListFromView:(UIView *)superview closeCallback:(nullable void (^)(void))closeCallback;

/**
 点击购物车中的商品，或者正在讲解的商品
 @param sellViewController sellViewController
 @param item 点击的商品的信息
 */
- (void)roomViewController:(BJLRoomViewController *)sellViewController openSellItem:(BJLSellItem *)item;
@end

NS_ASSUME_NONNULL_END
