//
//  BJLOnlineUsersVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-11-15.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"

#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

/** ### 在线用户 */
@interface BJLOnlineUsersVM: BJLBaseVM

/** 在线人数 */
@property (nonatomic, readonly) NSInteger onlineUsersTotalCount;
/**
 在线用户，分页加载
 #discussion `loadMoreOnlineUsersWithCount:` 导致的更新会先重置为 nil，然后再赋值，可用来区分单个更新
 #discussion 参考 `loadMoreOnlineUsersWithCount:`
 */
@property (nonatomic, readonly, copy, nullable) NSArray<__kindof BJLUser *> *onlineUsers;

/**
 `onlineTeacher`、`currentPresenter` 是否加载完成
 #discussion 1、连接直播间后、掉线重新连接后，都会重置为 NO
 #discussion 2、然后重置 `onlineTeacher`、`currentPresenter`
 #discussion 3、然后自动加载 `onlineTeacher`、`currentPresenter`
 #discussion 4、加载完成后为 YES，`onlineTeacher`、`currentPresenter` 可能为 nil
 */
@property (nonatomic, readonly) BOOL activeUsersSynced;
/** 在线的老师 */
@property (nonatomic, readonly, nullable) __kindof BJLUser *onlineTeacher;
/** 当前主讲，可能和 `onlineTeacher` 相同、也可能不同 */
@property (nonatomic, readonly, nullable) __kindof BJLUser *currentPresenter;
/**
 切换主讲
 #discussion 1. 主讲人只能由老师设置，2. 之后老师本人或者助教才能被设置为主讲人
 #param userID  老师或助教的 userID
 #return BJLError:
 BJLErrorCode_invalidCalling    不支持切换主讲，参考 `room.featureConfig.canChangePresenter`
 BJLErrorCode_invalidArguments  错误参数
 BJLErrorCode_invalidUserRole   错误权限，要求老师权限
 */
- (nullable BJLError *)requestChangePresenterWithUserID:(NSString *)userID;

/** 获取当前登录用户所在group是否有更多在线用户未加载 */
@property (nonatomic, readonly) BOOL hasMoreOnlineUsers; // NON-KVO

/** 获取某一个分组是否有更多在线用户未加载 */
- (BOOL)hasMoreOnlineUsersofGroup:(NSInteger)groupID;

/**
 加载更多在线用户
 #discussion 连接直播间后、掉线重新连接后自动调用加载
 #discussion 加载成功更新 `onlineUsers`
 #discussion 参考 `hasMoreOnlineUsers`
 #param count 传 0 默认 20、最多 30
 #return BJLError:
 BJLErrorCode_invalidCalling    错误调用，如 `hasMoreOnlineUsers` 为 NO 时调用此方法
 */
- (nullable BJLError *)loadMoreOnlineUsersWithCount:(NSInteger)count;

/**
 加载更多在线用户
 #discussion 加载成功更新 `onlineUsers`
 #discussion 参考 `hasMoreOnlineUsersofGroup:`来获取某一个group是否可以加载更多
 #param count 传 0 默认 20、最多 30
 #return BJLError:
 BJLErrorCode_invalidCalling    错误调用，如 `hasMoreOnlineUsersofGroup:` 为 NO 时调用此方法
 */
- (nullable BJLError *)loadMoreOnlineUsersWithCount:(NSInteger)count
                                            groupID:(NSInteger)groupID;

/** TODO: 内部使用 */
- (BJLObservable)onlineUserWillAdd:(BJLUser *)user __APPLE_API_UNSTABLE;

/**
 有用户进入直播间
 #discussion 批量更新时不会调用
 #discussion 同时更新 `onlineUsers`
 #param user 用户
 */
- (BJLObservable)onlineUserDidEnter:(BJLUser *)user;

/**
 有用户退出直播间
 #discussion 批量更新时不会调用
 #discussion 同时更新 `onlineUsers`
 #param user 用户
 */
- (BJLObservable)onlineUserDidExit:(BJLUser *)user;

/**
 用户更新视频未开启时的占位图
#param imageURLString 为空表示清空之前的占位图设置
*/
- (BJLObservable)didRecieveUserCameraCover:(nullable NSString *)imageURLString userNumber:(NSString *)userNumber;

/**
 用户更新音视频状态
 */
- (BJLObservable)didRecieveUserStateUpdateWithUserNumber:(NSString *)userNumber
                                              audioState:(BJLUserMediaState)audioState
                                              videoState:(BJLUserMediaState)videoState;

#pragma mark - 分组

/** 直播间内分组信息
 #discussion 0表示未分组, groupList不包含groupID = 0的数据
 */
@property (nonatomic, readonly, copy, nullable) NSArray<BJLUserGroup *> *groupList;

/** 直播间内分组人数信息  <groupID, count> */
@property (nonatomic, readonly, copy, nullable) NSDictionary<NSString *, NSNumber *> *groupCountDic;

/**
 直播间内分组颜色
 #param groupID 对应分组的 ID
 #return 十六进制 RGB 色值字符串，如 `#FFFFFF`
 */
- (nullable NSString *)getGroupColorWithID:(NSInteger)groupID;

/**
 学生分组人数变化
 #param groupCountDic <groupID, count> 提供分组及其人数变化
 */
- (BJLObservable)onlineUserGroupCountDidChange:(NSDictionary *)groupCountDic;

/**
 批量更新用户分组信息变化
 #param groupInfo 学生所在分组的信息, nil表示分组被移除
 */
- (BJLObservable)onlineUserGroupInfoDidChangeWithUserNumbers:(NSArray<NSString *> *)userNumbers groupInfo:(nullable BJLUserGroup *)groupInfo;

#pragma mark - 踢出直播间

/**
 将学生加入黑名单列表
 #param userID 学生ID
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数；
 BJLErrorCode_invalidCalling    错误调用，如要踢出的用户是老师或助教；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)blockUserWithID:(NSString *)userID;

/**
 学生被加入黑名单列表
 #discussion 被踢出的用户非当前用户
 #param blockedUser 被踢出的学生
 */
- (BJLObservable)didBlockUser:(BJLUser *)blockedUser;

/**
 将学生移出直播间，如果addToBlockList为YES，则会加入黑名单
 #param userID 学生ID
 #param addToBlockList 是否把学生添加到黑名单
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数；
 BJLErrorCode_invalidCalling    错误调用，如要踢出的用户是老师或助教；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)blockUserWithID:(NSString *)userID addToBlockList:(BOOL)addToBlockList;

/** 加载黑名单列表 */
- (void)loadBlockedUserList;

/**
 返回黑名单列表
 #param userList 用户列表
 */
- (BJLObservable)didReceiveBlockedUserList:(NSArray<BJLUser *> *)userList;

/**
 解除用户黑名单
 #param userNumber userNumber
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数；
 BJLErrorCode_invalidCalling    错误调用，如要踢出的用户是老师或助教；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)freeBlockedUserWithNumber:(NSString *)userNumber;

/**
 用户黑名单被解除
 #param userNumber userNumber
 */
- (BJLObservable)didFreeBlockedUserWithNumber:(NSString *)userNumber;

/**
 解除全部用户黑名单
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数；
 BJLErrorCode_invalidCalling    错误调用，如要踢出的用户是老师或助教；
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)freeAllBlockedUsers;

/** 所有黑名单被解除 */
- (BJLObservable)didFreeAllBlockedUsers;

@end

NS_ASSUME_NONNULL_END
