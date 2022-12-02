//
//  BJLPlayingAdapterVM.h
//  BJLiveCore
//
//  Created by HuangJie on 2019/3/20.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLMediaUser.h"
#import "BJLWindowUpdateModel.h"

NS_ASSUME_NONNULL_BEGIN

/** ### 旧版 SDK 音视频模板适配层 */
@interface BJLPlayingAdapterVM: BJLBaseVM

/**
 音视频用户列表
 #discussion 包含 `videoPlayingUser`
 #discussion 所有用户的音频会自动播放，视频需要调用 `updatePlayingUserWithID:videoOn:` 打开或者通过 `autoPlayVideoBlock` 控制打开
 #discussion SDK 会处理音视频打断、恢复、前后台切换等情况
 */
@property (nonatomic, readonly, copy, nullable) NSArray<__kindof BJLMediaUser *> *playingUsers;

/**
 从 `playingUsers` 查找用户
 #param userID 用户 ID
 #param userNumber 用户编号
 */
- (nullable __kindof BJLMediaUser *)playingUserWithID:(nullable NSString *)userID
                                               number:(nullable NSString *)userNumber;

/**
 查找音视频流对应的用户实例
 #param mediaID 音视频流标识
 */
- (nullable __kindof BJLMediaUser *)playingUserWithMediaID:(nullable NSString *)mediaID;

/**
 用户开关音、视频
 #discussion - 某个用户主动开关自己的音视频、切换清晰度时发送此通知，但不包含意外掉线等情况
 #discussion - 正在播放的视频用户 关闭视频时 `videoPlayingUser` 将被设置为 nil、同时发送此通知
 #discussion - 进直播间后批量更新 `playingUsers` 时『不』发送此通知
 #discussion - 音视频开关状态通过 `BJLMediaUser` 的 `audioOn`、`videoOn` 获得
 #discussion - definitionIndex 可能会发生变化，调用 `definitionIndexForUserWithID:` 可获取最新的取值
 #param now 新用户信息
 #param old 旧用户信息
 TODO: 增加方法支持同时监听初始音视频状态
 */
- (BJLObservable)playingUserDidUpdate:(nullable BJLMediaUser *)now
                                  old:(nullable BJLMediaUser *)old;

/**
 用户开改变视频清晰度
 #param now 新用户信息
 #param old 旧用户信息
 */
- (BJLObservable)playingUserDidUpdateVideoDefinitions:(nullable BJLMediaUser *)now
                                                  old:(nullable BJLMediaUser *)old;

/**
 `playingUsers` 被覆盖更新
 #discussion 进直播间后批量更新才调用，增量更新不调用
 #param playingUsers 音视频用户列表
 */
- (BJLObservable)playingUsersDidOverwrite:(nullable NSArray<BJLMediaUser *> *)playingUsers;

/**
 将要播放视频
 #discussion 播放或者关闭视频的方法被成功调用
 #param playingUser 将要播放视频用户
 */
- (BJLObservable)playingUserDidStartLoadingVideo:(nullable BJLMediaUser *)playingUser;

/**
 播放成功
 #discussion 用户视频开启或者关闭成功
 #param playingUser 播放视频的用户
 */
- (BJLObservable)playingUserDidFinishLoadingVideo:(nullable BJLMediaUser *)playingUser;

/**
 播放出现卡顿
 #param user 出现卡顿的正在播放的视频用户实例
 */
- (BJLObservable)playLagWithPlayingUser:(BJLMediaUser *)user;

#pragma mark - auto play

/**
 自动播放视频并指定清晰度回调
 #discussion 传入参数 user 和 cachedDefinitionIndex 分别为 用户 和 上次播放该用户视频时使用的清晰度
 #discussion 返回结果 autoPlay 和 definitionIndex 分别为 是否自动播放视频 和 播放视频使用的视频清晰度，例如
 |  self.room.playingVM.autoPlayVideoBlock = ^BJLAutoPlayVideo(BJLMediaUser *user, NSInteger cachedDefinitionIndex) {
 |      BOOL autoPlay = user.number && ![self.autoPlayVideoBlacklist containsObject:user.number];
 |      NSInteger definitionIndex = cachedDefinitionIndex;
 |      if (autoPlay) {
 |          NSInteger maxDefinitionIndex = MAX(0, (NSInteger)user.definitions.count - 1);
 |          definitionIndex = (cachedDefinitionIndex <= maxDefinitionIndex
 |                             ? cachedDefinitionIndex : maxDefinitionIndex);
 |      }
 |      return BJLAutoPlayVideoMake(autoPlay, definitionIndex);
 |  };
 */
@property (nonatomic, copy, nullable) BJLAutoPlayVideo (^autoPlayVideoBlock)(BJLMediaUser *user, NSInteger cachedDefinitionIndex);

#pragma mark - video playing users

/**
 正在播放的视频用户
 #discussion `playingUsers` 的子集
 #discussion 断开重连、暂停恢复等操作不自动重置 `videoPlayingUsers`，除非对方用户掉线、离线等 */
@property (nonatomic, readonly, copy, nullable) NSArray<BJLMediaUser *> *videoPlayingUsers;

/**
 从 `videoPlayingUsers` 查找用户
 #param userID 用户 ID
 #param userNumber 用户编号
 */
- (nullable __kindof BJLMediaUser *)videoPlayingUserWithID:(nullable NSString *)userID
                                                    number:(nullable NSString *)userNumber;

/**
 打开／关闭 对象用户的视频
 #param userID 用户 ID
 #param videoOn YES：打开视频，NO：关闭视频
 #param definitionIndex `BJLMediaUser` 的 `definitions` 属性的 index，参考 `BJLLiveDefinitionKey`、`BJLLiveDefinitionNameForKey()`
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数，如 `playingUsers` 中不存在此用户；
 BJLErrorCode_invalidCalling    错误调用，如用户视频已经在播放、或用户没有开启摄像头。
 */
- (nullable BJLError *)updatePlayingUserWithID:(NSString *)userID
                                       videoOn:(BOOL)videoOn;
- (nullable BJLError *)updatePlayingUserWithID:(NSString *)userID
                                       videoOn:(BOOL)videoOn
                               definitionIndex:(NSInteger)definitionIndex;

/**
 获取播放用户的清晰度
 #param userID 用户 ID
 #return 播放时传入的 `definitionIndex`
 */
- (NSInteger)definitionIndexForUserWithID:(NSString *)userID;

/**
 获取播放用户的视频视图
 #param userID 用户 ID
 */
- (nullable UIView *)playingViewForUserWithID:(NSString *)userID;

/**
 获取播放用户的视频视图宽高比
 #param userID 用户 ID
 */
- (CGFloat)playingViewAspectRatioForUserWithID:(NSString *)userID;

/**
 用户视频宽高比发生变化的通知
 #param videoAspectRatio 视频宽高比
 #param user 用户实例
 */
- (BJLObservable)playingViewAspectRatioChanged:(CGFloat)videoAspectRatio
                                       forUser:(BJLMediaUser *)user;

@end

NS_ASSUME_NONNULL_END
