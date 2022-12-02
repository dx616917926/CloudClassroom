//
//  BJVRoom.h
//  Pods
//
//  Created by 辛亚鹏 on 2016/12/14.
//  Copyright (c) 2016 Baijia Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BJVPlayerManager.h"
#import "BJVOnlineUserVM.h"
#import "BJVRoomVM.h"
#import "BJVMessageVM.h"

#import "BJVPlaybackInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 直播间
 可同时存在多个实例
 */
@interface BJVRoom: NSObject

/** 是否是本地视频 */
@property (nonatomic, readonly) BOOL isLocalVideo;

/** 是否是小班课 */
@property (nonatomic, readonly) BOOL isInteractiveClass;

/** 是否是合并回放房间 */
@property (nonatomic, readonly) BOOL isMixPlaybackRoom;

/** 是否正在加载 */
@property (nonatomic, readonly) BOOL loading;

/** 回放房间信息 */
@property (nonatomic, readonly, nullable) BJVRoomVM *roomVM;

/** 聊天消息 */
@property (nonatomic, readonly, nullable) BJVMessageVM *messageVM;

/** 在线用户 */
@property (nonatomic, readonly, nullable) BJVOnlineUserVM *onlineUsersVM;

/** 播放控制器 */
@property (nonatomic, readonly, nullable) id<BJVPlayProtocol> playerManager;

/**
 课件功能控制 && 大班课回放的课件视图显示，
 大班课回放使用 `slideshowViewController` 或者 `blackboardPPTViewController` 展示皆可，
 小班课只可以使用 `blackboardPPTViewController`
 */
@property (nonatomic, readonly) UIViewController<BJLSlideshowUI> *slideshowViewController;

/**
 大小班课回放统一的课件视图显示，尺寸、位置随意设定，需要设置为整数的 pt 值，
 包装了黑板和课件的视图，仅用于显示，具体课件功能参考 `slideshowViewController` 相关方法
 */
@property (nonatomic, readonly) UIViewController *blackboardPPTViewController;

/**
 裁剪后的回放视频的version, 需要在调用enter之前设置
 #discussion  -1: 裁剪后的主版本,  0: 裁剪前的原始视频.
 #discussion 默认 clipedVersion 为 -1
 */
@property (nonatomic) NSInteger clipedVersion;

/**
 分组, 设置后, 返回对应分组的聊天信息, 需要在调用enter之前设置
 #discussion 默认 group 为 -1, 即返回所有分组的聊天信息
 #discussion group, 0: 大班老师和助教, 当 group > 0 时, 也会返回大班老师和助教的信息
 */
@property (nonatomic) NSInteger groupID;

/** 是否禁用动态课件，默认启用动态课件，为 NO，但是在无网络状态下进入离线回放时，将会自动切换成静态课件来保证能够正常观看 */
@property (nonatomic) BOOL disablePPTAnimation;

/** 是否存在 h5 课件（指除了 ppt, pptx 类型的动画课件
 如果存在，不能设置成禁用动画课件，并且建议联网观看，否则无网络的离线回放将无法加载 */
@property (nonatomic, readonly) BOOL existWebDocument;

/** 回放房间的相关信息 */
@property (nonatomic, readonly) BJVPlaybackInfo *playbackInfo;

/** 本地房间的相关信息 */
@property (nonatomic, readonly) BJVDownloadItem *downloadItem;

#pragma mark - initialize

/**
 Unavailable. Please use method: onlinePlaybackRoomWithClassID:sessionID:token: | localPlaybackRoomWithDownloadItem:playerType:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 创建在线回放房间，配置项采用默认值
 
 #discussion 具体参考 `onlinePlaybackRoomWithClassID:sessionID:token:encrypted:playerType:` 方法
 #discussion 视频不加密
 #discussion 使用 AVPlayer
 
 #param classID     课程 ID
 #param sessionID   课节 ID
 #param token       需要集成方后端调用百家云后端的API获取，传给移动端
 #return            回放房间实例
 */
+ (instancetype)onlinePlaybackRoomWithClassID:(NSString *)classID
                                    sessionID:(nullable NSString *)sessionID
                                        token:(NSString *)token;

/**
 创建在线合并回放房间，配置项采用默认值
 
 #discussion 具体参考 `onlinePlaybackRoomWithClassID:sessionID:token:encrypted:playerType:` 方法
 #discussion 视频不加密

 #param mixID       课程 ID
 #param mixToken    需要集成方后端调用百家云后端的API获取，传给移动端
 #param playerType  播放器类型：AVPlayer、IJKPlayer
 #return            回放房间实例
 */
+ (instancetype)onlineMixPlaybackRoomWithMixID:(NSString *)mixID mixToken:(NSString *)mixToken playerType:(BJVPlayerType)playerType;

/**
 创建在线回放房间
 
 #param classID     课程 ID
 #param sessionID   课节 ID
 #param token       需要集成方后端调用百家云后端的API获取，传给移动端
 #param encrypted   是否加密，「仅在使用 IJKPlayer 时有效」，playerType 参数传 BJVPlayerType_IJKPlayer
 #param accessKey   集成方鉴权, 回放如果需要请求第三方服务器查看是否有权限, 可设置该参数。鉴权验证请求需要与百家云后台沟通。
 #param playerType  播放器类型：AVPlayer、IJKPlayer
 #return            回放房间实例
 */
+ (instancetype)onlinePlaybackRoomWithClassID:(NSString *)classID
                                    sessionID:(nullable NSString *)sessionID
                                        token:(NSString *)token
                                    encrypted:(BOOL)encrypted
                                    accessKey:(nullable NSString *)accessKey
                                   playerType:(BJVPlayerType)playerType;

/**
 创建本地回放房间
 
 #param downloadItem    本地回放文件类型，通过下载模块获得
 #param playerType      播放器类型：AVPlayer、IJKPlayer
 #return                回放房间实例
 */
+ (instancetype)localPlaybackRoomWithDownloadItem:(BJVDownloadItem *)downloadItem
                                       playerType:(BJVPlayerType)playerType;

#pragma mark - enter

/**
 进入直播间
 */
- (void)enter;

/**
 进入直播间
 #param error 成功进入直播间, error为空, 错误码参考 BJVErrorCode
 case: 在线播放, 获取playbackVM的播放信息
 case: 本地视频, 信令文件解压完毕, 并载入内存，播放器加载视频完成
 */
- (BJLObservable)roomDidEnterWithError:(nullable NSError *)error;

#pragma mark - exit

/**
 退出直播间
 */
- (void)exit;

/**
 退出直播间事件，成功退出, error为空, 错误码参考 BJVErrorCode
 */
- (BJLObservable)roomDidExitWithError:(nullable NSError *)error;

#pragma mark - reload

/**
 重新加载房间内容
 
 #discussion 用于回放过程中出错后重试。
 */
- (void)reload;

#pragma mark - mixplayback

/**
 合并回放房间即将播放新片段
 
 #discussion 在获取到必要元数据后，会更新room内的playback info数据再调用该回调
 可监听此方法来更新和特定playback info相关的UI组件
 */
- (BJLObservable)mixPlaybackRoomWillLoadSlice:(BJVPlaybackInfo *)slice;

/**
 合并回放房间的新片段加载结束
 
 #discussion 如果加载失败，可以调用 `reload` 方法来重试
 可监听此方法来更新和特定playback info相关的UI组件
 
 #param error 为nil表示加载成功。否则 error 表示具体原因, 错误码参考 BJVErrorCode
 */
- (BJLObservable)mixPlaybackRoomSlice:(BJVPlaybackInfo *)slice didLoadWithError:(nullable NSError *)error;

#pragma mark - debug

@property (nonatomic, copy, nullable) void (^signalConsoleInfoCallback)(NSString *signalInfo);
@property (nonatomic, copy, nullable) void (^signalClearCallback)(void);
@property (nonatomic, copy, nullable, setter=setAPIConsoleInfoCallback:) void (^apiConsoleInfoCallback)(NSString *consoleInfo);

@end

NS_ASSUME_NONNULL_END
