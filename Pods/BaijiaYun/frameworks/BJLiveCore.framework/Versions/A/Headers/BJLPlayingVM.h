//
//  BJLPlayingVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-16.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLMediaUser.h"
#import "BJLWindowUpdateModel.h"
#import "BJLMediaFile.h"

NS_ASSUME_NONNULL_BEGIN

/** ### 音视频播放 */
@interface BJLPlayingVM: BJLBaseVM

/**
 音视频用户列表
 #discussion 包含直播间内推送主音视频流的用户，数组内 BJLMediaUser 实例的音视频信息为主音视频流的信息，每个用户在 playingUsers 中只有一个 BJLMediaUser 实例
 #discussion 在 webRTC 直播间中，数组内的 BJLMediaUser 实例的 mediaSource 为 BJLMediaSource_mainCamera
 #discussion 在非 webRTC 直播间中，数组内的 BJLMediaUser 实例的 mediaSource 为 BJLMediaSource_mainCamera、BJLMediaSource_screenShare、BJLMediaSource_mediaFile、BJLMediaSource_extraMediaFile
 #discussion 所有用户的音频会自动播放，视频需要调用 `updatePlayingUserWithID:videoOn:mediaSource:` 打开或者通过 `autoPlayVideoBlock` 控制打开
 #discussion SDK 会处理音视频打断、恢复、前后台切换等情况
 */
@property (nonatomic, readonly, copy, nullable) NSArray<BJLMediaUser *> *playingUsers;

/**
 扩展音视频流用户列表
 #discussion 包含直播间内推送扩展音视频流的用户，音视频信息为扩展音视频流的信息，每个用户在 extraPlayingUsers 中可以有多个 BJLMediaUser 实例
 #discussion 在 webRTC 直播间中，数组内的 BJLMediaUser 实例的 mediaSource 为除 BJLMediaSource_mainCamera 之外的音视频流类型
 #discussion 在非 webRTC 直播间中，数组内 BJLMediaUser 实例的 mediaSource 为 BJLMediaSource_extraCamera、BJLMediaSource_extraScreenShare、BJLMediaSource_extraMediaFile
 #discussion 所有用户的音频会自动播放，视频需要调用 `updatePlayingUserWithID:videoOn:mediaSource:` 打开或者通过 `autoPlayVideoBlock` 控制打开
 #discussion 打开了扩展音视频流的用户将同时包含在 playingUsers 和 extraPlayingUsers 中，但两个列表中的 BJLMediaUser 实例的音视频信息不同
 */
@property (nonatomic, readonly, copy, nullable) NSArray<BJLMediaUser *> *extraPlayingUsers;

/**
 查找音视频用户
 #param userID 用户 ID
 #param userNumber 用户编号
 #param mediaSource 视频源类型
 #discussion 不同的 mediaSource 取到的 BJLMediaUser 实例可能用户信息相同，但音视频信息是不同的
 */
- (nullable __kindof BJLMediaUser *)playingUserWithID:(nullable NSString *)userID
                                               number:(nullable NSString *)userNumber
                                          mediaSource:(BJLMediaSource)mediaSource;

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
 #discussion - 用户退出直播间时，new 为 nil，old 的 `mediaSource` 属性为 `BJLMediaSource_all`
 #param now 新用户信息
 #param old 旧用户信息
 TODO: 增加方法支持同时监听初始音视频状态
 */
- (BJLObservable)playingUserDidUpdate:(nullable BJLMediaUser *)now
                                  old:(nullable BJLMediaUser *)old;

/**
 用户改变视频清晰度
 #param now 新用户信息
 #param old 旧用户信息
 #discussion 清晰度的变化可对比 `now` 与 `old` 的 `definitions` 属性得知
 */
- (BJLObservable)playingUserDidUpdateVideoDefinitions:(nullable BJLMediaUser *)now
                                                  old:(nullable BJLMediaUser *)old;

/**
 `playingUsers`、`extraPlayingUsers` 被覆盖更新
 #discussion 进直播间后批量更新才调用，增量更新不调用
 #param playingUsers 音视频用户列表, 使用主摄像头采集音视频推流的用户列表
 #param extraPlayingUsers 扩展音视频流用户列表，不使用主摄像头采集音视频推流的用户列表
 TODO: 改进此方法，使之与监听 playingUsers 区别更小
 */
- (BJLObservable)playingUsersDidOverwrite:(nullable NSArray<BJLMediaUser *> *)playingUsers
                        extraPlayingUsers:(nullable NSArray<BJLMediaUser *> *)extraPlayingUsers;

/**
 将要播放视频
 #discussion 播放视频的方法被成功调用时回调
 #param playingUser 将要播放的视频用户
 */
- (BJLObservable)playingUserDidStartLoadingVideo:(nullable BJLMediaUser *)playingUser;

/**
 视频播放成功
 #discussion 用户视频播放成功
 #param playingUser 播放的视频对应的用户
 */
- (BJLObservable)playingUserDidFinishLoadingVideo:(nullable BJLMediaUser *)playingUser;

/**
 播放出现卡顿
 #param user 出现卡顿的正在播放的视频用户实例
 */
- (BJLObservable)playLagWithPlayingUser:(BJLMediaUser *)user;

#pragma mark -

/**
 正在播放的视频用户
 #discussion 数组内元素包含在 `playingUsers`、`extraPlayingUsers` 之中，在当前打开了音视频的用户列表中，本地在播放的用户列表。
 #discussion 断开重连、暂停恢复等操作不自动重置 `videoPlayingUsers`，除非对方用户掉线、离线等
 */
@property (nonatomic, readonly, copy, nullable) NSArray<BJLMediaUser *> *videoPlayingUsers;

/**
 从 `videoPlayingUsers` 查找用户
 #param userID 用户 ID
 #param userNumber 用户编号
 #param mediaSource 视频源类型
 */
- (nullable __kindof BJLMediaUser *)videoPlayingUserWithID:(nullable NSString *)userID
                                                    number:(nullable NSString *)userNumber
                                               mediaSource:(BJLMediaSource)mediaSource;

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

/** 播放画面显示模式，默认 BJLVideoContentMode_aspectFit */
@property (nonatomic) BJLVideoContentMode videoContentMode;

/**
 更新播放画面的水印显示
 #param user 播放画面的用户
 #param size 显示播放画面的容器的尺寸或者视频的实际尺寸
 #param videoContentMode 播放画面的显示模式
 #discussion 目前只有主讲人的视图才会显示水印，主讲人只能是老师或者助教身份。
 #discussion 播放画面显示模式为 BJLVideoContentMode_aspectFill 时，size 为显示播放画面的容器的尺寸。
 #discussion 播放画面显示模式为 BJLVideoContentMode_aspectFit 时，size 为视频的尺寸比例。
 #discussion 例如尺寸比例为 ratio，size 的值为 CGSizeMake(ratio, 1.0)，尺寸比例参考 `playingViewAspectRatioForUserWithID:mediaSource:`。
 */
- (void)updateWatermarkWithUser:(BJLMediaUser *)user size:(CGSize)size videoContentMode:(BJLVideoContentMode)videoContentMode;

/** 禁止自动播放除老师，助教以外的视频，目前仅专业小班课使用 */
@property (nonatomic, readonly) BOOL disableAutoPlayVideoExceptTeacherAndAssistant;

/**
 设置播放用户的视频
 #param userID 用户 ID
 #param videoOn YES：打开视频，NO：关闭视频
 #param definitionIndex `BJLMediaUser` 的 `definitions` 属性的 index，参考 `BJLLiveDefinitionKey`、`BJLLiveDefinitionNameForKey()`
 #param mediaSource 视频源类型
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数，如 `playingUsers` 中不存在此用户；
 BJLErrorCode_invalidCalling    错误调用，如用户视频已经在播放、或用户没有开启摄像头。
 */
- (nullable BJLError *)updatePlayingUserWithID:(NSString *)userID
                                       videoOn:(BOOL)videoOn
                                   mediaSource:(BJLMediaSource)mediaSource;
- (nullable BJLError *)updatePlayingUserWithID:(NSString *)userID
                                       videoOn:(BOOL)videoOn
                                   mediaSource:(BJLMediaSource)mediaSource
                               definitionIndex:(NSInteger)definitionIndex;
/**
 设置播放用户的音频
 #param userID 用户 ID
 #param audioOn YES：打开音频，NO：关闭音频。打开关闭操作仅仅只是本地操作，不会影响推流端。并且如果远端未开启音频，也不能打开音频
 #param mediaSource 视频源类型
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数，如 `playingUsers` 中不存在此用户；
 BJLErrorCode_invalidCalling    错误调用，如推流端用户没有开启音频。
 */
- (nullable BJLError *)updatePlayingUserWithID:(NSString *)userID
                                       audioOn:(BOOL)audioOn
                                   mediaSource:(BJLMediaSource)mediaSource;

/**
 查询播放用户的本地音频开关状态
 #param audioOnState 用户传递结果的BOOL 指针
 #param userID 用户 ID
 #param mediaSource 视频源类型
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数，如 `playingUsers` 中不存在此用户；
 */
- (nullable BJLError *)audioOnState:(BOOL *)audioOnState forUserID:(NSString *)userID mediaSource:(BJLMediaSource)mediaSource;

/**
 获取播放用户的清晰度
 #param userID 用户 ID
 #param mediaSource 视频源类型
 #return 播放时传入的 `definitionIndex`
 */
- (NSInteger)definitionIndexForUserWithID:(NSString *)userID
                              mediaSource:(BJLMediaSource)mediaSource;

/**
 获取播放用户的视频视图
 #param userID 用户 ID
 #param mediaSource 视频源类型
 */
- (nullable UIView *)playingViewForUserWithID:(NSString *)userID
                                  mediaSource:(BJLMediaSource)mediaSource;

/**
 获取播放用户的视频视图宽高比
 #param userID 用户 ID
 #param mediaSource 视频源类型
 */
- (CGFloat)playingViewAspectRatioForUserWithID:(NSString *)userID
                                   mediaSource:(BJLMediaSource)mediaSource;

/**
 用户视频宽高比发生变化的通知
 #param videoAspectRatio 视频宽高比
 #param user             用户音视频流信息
 */
- (BJLObservable)playingViewAspectRatioChanged:(CGFloat)videoAspectRatio
                                       forUser:(BJLMediaUser *)user;

/**
 老师在 PC 上更改共享桌面设置、媒体文件播放状态
 #discussion 这两个属性需要与老师的在线状态、音视频状态配合使用
 */
@property (nonatomic, readonly) BOOL teacherSharingDesktop, teacherPlayingMedia;

#pragma mark - WebRTC 大小流切换

/**
 拉流时大小流切换，仅在支持大小流的 WebRTC 直播间有效
 #param user user
 #param useLowDefinition 是否切换为小流, yes: 切为小流，no: 切为大流
 */
- (void)switchVideoDefinitionWithUser:(BJLMediaUser *)user useLowDefinition:(BOOL)useLowDefinition;

#pragma mark - CDN 拉流清晰度切换

/** 是否是原始清晰度，默认是原始清晰度 */
@property (nonatomic, readonly) BOOL originCDNVideoDefinition;

/**
 使用合流原始清晰度，默认原始清晰度
 #discussion 大班课合流模式下，参考 `playMixedVideo` 生效
 #discussion 伪直播、推流直播的场景下，参考 `BJLRoom.roomInfo.isMockLive` 和 `BJLRoom.roomInfo.isMockLive.isPushLive` 生效
 #param origin YES：原始清晰度 NO：使用低清晰度
 #return BJLError 不支持切换清晰度，参考 `BJLFeatureConfig.enableSwitchMixedVideoDefinition`
 */
- (nullable BJLError *)useOriginCDNVideoDefinition:(BOOL)origin;

#pragma mark - interactive class 专业版小班课 API

/**
 专业版小班课 - 更新视频窗口
 #param mediaID 视频流标识
 #param action 更新类型，参考 BJLWindowsUpdateModel 的 BJLWindowsUpdateAction
 #param displayInfos 直播间内所有视频窗口显示信息
 #return 调用错误, 参考 BJLErrorCode
 */
- (nullable BJLError *)updateVideoWindowWithMediaID:(NSString *)mediaID
                                             action:(NSString *)action
                                       displayInfos:(NSArray<BJLWindowDisplayInfo *> *)displayInfos;

/**
 专业版小班课 - 视频窗口更新通知
 #param updateModel 更新信息
 #param shouldReset 是否重置
 */
- (BJLObservable)didUpdateVideoWindowWithModel:(BJLWindowUpdateModel *)updateModel
                                   shouldReset:(BOOL)shouldReset;

/**
 专业版小班课 - 用户上台请求
 #param user 对象用户
 #return 错误调用
 */
- (nullable BJLError *)requestAddActiveUser:(BJLUser *)user;

/**
 专业版小班课 - 用户下台请求
 #param user 对象用户
 #return 错误调用
 */
- (nullable BJLError *)requestRemoveActiveUser:(BJLUser *)user;

/**
 专业版小班课 - 用户上台成功回调
 #param user 用户信息
 */
- (BJLObservable)didAddActiveUser:(BJLUser *)user;

/**
 专业版小班课 - 用户上台请求被服务端拒绝
 #param user 上台对象信息
 #param responseCode: 拒绝原因对应的状态码：1.上台人数达到上限; 2.用户已离开直播间
 */
- (BJLObservable)didAddActiveUserDeny:(BJLUser *)user responseCode:(NSInteger)responseCode;

/**
 专业版小班课 - 用户下台成功回调
 #param user 用户信息
 */
- (BJLObservable)didRemoveActiveUser:(BJLUser *)user;

#pragma mark - mix video

/** 当前是否在播放合流 */
@property (nonatomic, readonly) BOOL playMixedVideo;

/** 视频合流时的被混合的音视频用户列表 */
@property (nonatomic, readonly, nullable) NSArray<BJLMediaUser *> *mixedPlayingUsers __APPLE_API_UNSTABLE;
@property (nonatomic, readonly, nullable) NSArray<BJLMediaUser *> *extraMixedPlayingUsers __APPLE_API_UNSTABLE;

/** 直播带货，是否只显示主用户 */
@property (nonatomic, readonly) BOOL onlyShowMainUserInMixVideo;

/**
 直播带货 - 是否只显示主用户
 */
- (nullable BJLError *)showMainUserOnlyInMixVideo:(BOOL)show;

#pragma mark - 播放媒体文件

/** 当前有其他用户正在播放媒体文件 */
@property (nonatomic, readonly) BOOL otherCloudVideoPlaying;

/** 当前播放的媒体文件的时间，如果没有播放，数值无效 */
@property (nonatomic, readonly) NSTimeInterval cloudVideoCurrentTime;

/**
 通过媒体文件获取播放媒体文件视图
 #discussion 获取视图后将会默认自动播放，从 0 开始播放，速率为 1.0
 #param mediaFile BJLMediaFile
 */
- (nullable UIView *)cloudVideoViewWithMediaFile:(BJLMediaFile *)mediaFile;

/**
 改变当前播放媒体文件的播放状态
 #discussion 当前没有正在播放的媒体文件时忽略
 #param play 是否播放
 */
- (void)updateCloudVideoPlayStatus:(BOOL)play;

/**
 跳转播放媒体文件的时间
 #discussion 跳转的时间超过当前媒体文件的总时长时无效
 #param time 跳转到的目标时间，单位 秒
 */
- (void)seekCloudVideoToTime:(NSTimeInterval)time;

/**
 改变当前播放媒体文件的播放速率
 #discussion 当前没有正在播放的媒体文件时忽略
 #param rate 播放速率，默认 1.0
 */
- (void)changeCloudVideRate:(CGFloat)rate;

/** 停止播放媒体文件 */
- (void)stopPlayCloudVideo;

/** 当前播放媒体文件被停止，一般是其他角色播放了新的媒体文件导致 */
- (BJLObservable)didStopCloudVideo;

#pragma mark - 点播暖场

/** 点播暖场视频的当前时间，如果没有播放，数值无效 */
@property (nonatomic, readonly) NSTimeInterval vodPlayerCurrentTime;
@property (nonatomic, readonly) NSTimeInterval vodPlayerDuration;

@property (nonatomic, copy) void (^vodVideoPlayDidFinishCallback)(NSString *urlString);

/**
 通过 URL 获取视图
 #discussion 如果不是webrtc底层, 将会返回空值
 #discussion 获取视图后将会默认自动播放，从 0 开始播放，速率为 1.0
 #param videoURLString videoURLString
 */
- (nullable UIView *)vodPlayerViewWithURLString:(NSString *)videoURLString;

/** 播放点播预热视频 */
- (void)vodVideoPlay;

/** 暂停点播预热视频 */
- (void)vodVideoPause;

/**
 跳转播放视频的的时间
 #discussion 跳转的时间超过当前媒体文件的总时长时无效
 #param time 跳转到的目标时间，单位 秒
 */
- (void)seekVodPlayerToTime:(NSTimeInterval)time;

/** 停止播放点播暖场视频 */
- (void)stopVodPlayer;

@end

NS_ASSUME_NONNULL_END
