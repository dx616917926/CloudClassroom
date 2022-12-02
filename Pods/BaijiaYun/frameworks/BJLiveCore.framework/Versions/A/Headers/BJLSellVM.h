//
//  BJLSellVM.h
//  BJLiveCore
//
//  Created by 凡义 on 2020/11/24.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLSellItem.h"

NS_ASSUME_NONNULL_BEGIN

/** 商品上下架操作 */
typedef NS_ENUM(NSInteger, BJLSellGoodShelfState) {
    /** 下架 */
    BJLSellGoodShelfState_off,
    /** 上架 */
    BJLSellGoodShelfState_on,
};

@interface BJLSellVM: BJLBaseVM

@property (nonatomic, readonly) BOOL hasMoreGoods;

/** 所有商品总量(包括上架 & 未上架的商品) */
@property (nonatomic, readonly) NSInteger totalSellGoodCount;

/** 所有商品(包括上架 & 未上架的商品) */
@property (nonatomic, readonly, nullable) NSArray<BJLSellItem *> *sellGoodArray;

/** 所有上架商品ID */
@property (nonatomic, readonly, nullable) NSArray<NSString *> *allOnShelfGoodIDs;

/**
 请求商品列表数据
 #discussion 加载成功更新 `sellGoodArray`
 #param count 传 0 默认 20、最多 30
*/
- (nullable NSURLSessionDataTask *)requestSellGoodsListWithCount:(NSInteger)count
                                                        complete:(nullable void (^)(NSArray<BJLSellItem *> *_Nullable sellList, BJLError *_Nullable error))completion;

/**
 加载更多
 #discussion 加载成功更新 `sellGoodArray`
 #discussion 参考 `hasMoreGoods`来获取是否可以加载更多
 #param count 传 0 默认 20、最多 30
 */
- (nullable NSURLSessionDataTask *)loadMoreSellGoodsWithCount:(NSInteger)count
                                                     complete:(nullable void (^)(NSArray<BJLSellItem *> *_Nullable sellList, BJLError *_Nullable error))completion;

/**
 商品列表数据更新通知
 #discussion 需要重新请求商品列表,调用`requestSellGoodsListWithCount:complete:`
 */
- (BJLObservable)didReceiveSellGoodsUpdate;

/**
 商品上下架数据更新
 */
- (BJLObservable)didReceiveSellGoodsOnshelfStateUpdate;

/**
 商品上下架操作
 #param goodID 上架/下架操作对应的商品ID
 #param action 上架/下架操作
 #return BJLError:
 BJLErrorCode_invalidCalling    错误调用，如 `hasMoreOnlineUsersofGroup:` 为 NO 时调用此方法
 BJLErrorCode_invalidUserRole   错误调用，仅主播/助教角色允许操作商品上下架
 */
- (nullable BJLError *)updateGoodsShelfStateWithGood:(BJLSellItem *)sellGood action:(BJLSellGoodShelfState)action;

/** 是否显示购物车，默认 NO */
@property (nonatomic, readonly) BOOL showShopping;

/**
 学生端是否显示购物车的回调
 */
- (BJLObservable)didReceiveShowShopping:(BOOL)showShopping;

/**
 是否显示购物车的操作, 只有老师或者助教可以操作
 */
- (nullable BJLError *)requestUpdateShowShopping:(BOOL)showShopping;

/** 当前正在讲解的商品 */
@property (nonatomic, readonly, nullable) BJLSellItem *currentExplainingGood;

/**
 请求更新当前正在讲解的商品
 #goodsID 商品 ID
 */
- (nullable BJLError *)requestGoods:(NSString *)goodsID becomeCurrentExplainingGoods:(BOOL)isCurrentShowingGoods;
#pragma mark - 点赞

/** 观众：给主播点赞 */
- (nullable BJLError *)sendLikeToStreamerWithCount:(NSInteger)count;

/** 点赞数量更新通知 */
- (BJLObservable)didReceiveStreamerLikeCountUpdate:(NSInteger)likeCount;

#pragma mark - 送礼

/** 观众：给主播送礼 */
- (nullable BJLError *)sendGiftToStreamerWithGiftID:(NSInteger)giftID count:(NSInteger)count;

/** 观众：当前用户送礼是否成功的通知 */
- (BJLObservable)didReceiveResponseOfGiftID:(NSInteger)giftID success:(BOOL)success;

/**
 主播：主播端礼物数据更新通知
 #param gitInfoDic @[@{@"gid":xxx, @"count":xxx}]
 */
- (BJLObservable)didReceiveGiftUpdate:(NSArray<NSDictionary<NSString *, NSNumber *> *> *)gitInfoArray;

/** 观众：主播礼物新增通知 */
- (BJLObservable)didReceiveNewGift:(NSArray<NSDictionary *> *)newGiftArray;

#pragma mark -

/** 直播间有用户进入 */
- (BJLObservable)didReceiveUserInWithName:(NSString *)userName;

@end

NS_ASSUME_NONNULL_END
