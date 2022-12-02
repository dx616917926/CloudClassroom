//
//  BJVOnlineUserVM.h
//  Pods
//
//  Created by 辛亚鹏 on 2017/1/12.
//  Copyright © 2017年 Baijia Cloud. All rights reserved.
//

#import "BJVBaseVM.h"
#import "BJVUser.h"
#import "BJVMediaUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJVOnlineUserVM: BJVBaseVM

/** 在线人数 */
@property (nonatomic, readonly) NSInteger onlineUsersTotalCount;

/** 在线用户 */
@property (nonatomic, readonly, nullable, copy) NSArray<BJVUser *> *onlineUsers;

/** 当前主讲 */
@property (nonatomic, readonly, nullable, copy) BJVMediaUser *currentPresenter;

/** 在线用户列表覆盖更新
 同时更新 `onlineUsers` */
- (BJLObservable)onlineUsersDidOverwrite:(NSArray<BJVUser *> *)users;

/** 有用户进入房间
 同时更新 `onlineUsers` */
- (BJLObservable)onlineUsersDidEnter:(NSArray<BJVUser *> *)users;

/** 有用户退出房间
 同时更新 `onlineUsers` */
- (BJLObservable)onlineUsersDidExit:(NSArray<BJVUser *> *)users;

/**
 音视频用户列表变更
 #param mediaUsers 音视频用户列表
 */
- (BJLObservable)mediaUsersDidUpdate:(NSArray<BJVMediaUser *> *)mediaUsers;

/**
 单个音视频用户状态变更
 note:  建议使用 mediaUsersDidUpdate:
 #param mediaUser 发生改变的音视频用户
 */
- (BJLObservable)userMediaDidUpdate:(BJVMediaUser *)mediaUser __APPLE_API_UNSTABLE;

@end

NS_ASSUME_NONNULL_END
