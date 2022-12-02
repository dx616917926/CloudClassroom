//
//  BJLRoom.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-11-15.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BJLConstants.h"

/** model **/

#import "BJLRoomInfo.h"
#import "BJLUser.h"
#import "BJLFeatureConfig.h"

/** view & vm **/

#import "BJLLoadingVM.h"

#import "BJLRoomVM.h"
#import "BJLOnlineUsersVM.h"
#import "BJLSpeakingRequestVM.h"

#import "BJLMediaVM.h"
#import "BJLRecordingVM.h"
#import "BJLPlayingVM.h"
#import "BJLPlayingAdapterVM.h"

#import "BJLDocumentVM.h"
#import "BJLDrawingVM.h"

#import "BJLServerRecordingVM.h"
#import "BJLGiftVM.h"

#import "BJLChatVM.h"
#import "BJLHomeworkVM.h"
#import "BJLCloudDiskVM.h"
#import "BJLSellVM.h"
#import "BJLStudyRoomVM.h"
#import "BJLHelpVM.h"

/** ui */

NS_ASSUME_NONNULL_BEGIN

/**
 nullable:
 SDK 中使用 `nullable` 来标记属性、参数是否可以为 nil，一般不再特别说明
 - 未标记 `nullable` 的属性、参数，调用时传入 nil 结果不可预期
 - 未标记 `nonnull` 的属性，读取时不保证非 nil —— 即使在 NS_ASSUME_NONNULL 内，因为可能没有初始化
 
 block:
 这里需要较多的使用 block 进行 KVO、方法监听等（RAC 本是个很好的选择、但为避免依赖过多的开源库而被放弃）
 - vm 所有属性支持 KVO，除非额外注释说明，参考 NSObject+BJLObserving.h
 - vm 返回值类型为 BJLObservable 的方法支持方法监听，参考 NSObject+BJLObserving.h
 - tuple pack&unpack，参考 NSObject+BJL_M9Dev.h
 更多应用实例参考 BJLiveUI - https://github.com/baijia/BJLiveUI-iOS
 
 vm: view-model
 vm 用于管理各功能模块的状态、数据等，参考 `BJLRoom` 的各 vm 属性
 
 lifecycle:
 0. 创建直播间
 通过 `roomWithID:apiSign:user:` 或 `roomWithSecret:userName:userAvatar:` 方法获得 `BJLRoom`
 可以开始监听 room 和 vm 的属性变化、方法调用，以及显示 view、view-controller
 但 vm 的状态、数据没有与服务端同步，调用 vm 方法时发起的网络请求会被丢弃、甚至产生不可预期的错误，断开重连时类似
 1. 进入直播间
 调用 `enter` 进入直播间，开始 loading
 2. loading
 `loadingVM` 从 loading 开始可用，直到结束变为 nil，参考 `BJLLoadingVM`
 loading 每一步的正常完成、询问、出错都有回调，回调中可实现出错重试等逻辑，`loadingVM.suspendBlock`
 2.1. 检查网络是否可用
 2.2. 获取直播间、用户及直播间配置等信息，成功后 `roomInfo` 和 `loginUser` 变为可用
 2.3. 建立服务器连接
 2.4. 进入直播间成功、loading 状态结束，`loadingVM` 变为 nil、调用 `enterRoomSuccess`
 此时 vm 的数据已经和服务端同步、可调用 vm 方法
 3. 进直播间成功、失败
 进直播间成功、失败分别调用 `enterRoomSuccess`、`enterRoomFailureWithError:`，失败原因参考 `BJLError`
 4. 断开、重连
 参考 `setReloadingBlock:`
 5. 主动/异常退出
 主动退出调用 `exit`、异常退出包括断开重连、在其它设备登录、主动退出等
 除进直播间失败以外的退出都会调用 `roomWillExitWithError:` 和 `roomDidExitWithError:`，主动退出时 error 为 nil
 退出直播间后各 vm、view 均被重置
 */

/** 直播间状态 */
typedef NS_ENUM(NSInteger, BJLRoomState) {
    /** 初始状态、连接失败、连接断开等
     参考 `error` */
    BJLRoomState_disconnected,
    /** 连接中 */
    BJLRoomState_connecting,
    /** 已连接 */
    BJLRoomState_connected
};

/**
 ### 直播直播间
 #discussion 可同时存在多个实例，但最多只有一个直播间处于进入状态，后执行 `enter` 的直播间会把之前的直播间踢掉
 #discussion 直播间类型为专业版小班课的直播间，默认只支持 64-ibit 设备进入直播间，32-bit 设备进直播间时通过 `enterRoomFailureWithError:` 返回错误码 `BJLErrorCode_enterRoom_unsupportedDevice`
 #discussion iPad: 1、2、3、4、mini 1 是 32-bit，其它是 64-bit
 #discussion iPhone: 5、5C 之前的设备是 32-bit，5S 开始是 64-bit
 #discussion iPod Touch: 1、2、3、4、5 是 32-bit，其它是 64-bit
 #see https://en.wikipedia.org/wiki/IPhone
 #see https://en.wikipedia.org/wiki/IPad
 #see https://jamesdempsey.net/iosdevicesummary-sep2016/
 */
@interface BJLRoom: NSObject

/**
 设置客户专属域名前缀
 #param prefix  客户专属域名前缀，例如专属域名为 `demo123.at.baijiayun.com`，则前缀为 `demo123`
 #discussion 需要在进直播间之前设置，专属域名从百家云账号中心查看
 */
+ (void)setPrivateDomainPrefix:(nullable NSString *)prefix;

#pragma mark lifecycle

/**
 通过 ID 创建直播间
 #param roomID          直播间 ID
 #param apiSign         API sign
 #param user            用户，参考 `BJLUser` 的 `userWithNumber:name:groupID:avatar:role:`
 #return                直播间
 #discussion 此方法传入的参数、以及创建 BJLUser 时所传参数都会参与 apiSign 的计算
 */
+ (__kindof instancetype)roomWithID:(NSString *)roomID
                            apiSign:(NSString *)apiSign
                               user:(BJLUser *)user;

/**
 通过参加码创建直播间
 #param roomSecret      直播间参加码
 #param userName        用户名
 #param userAvatar      用户头像 URL
 #return                直播间
 */
+ (__kindof instancetype)roomWithSecret:(NSString *)roomSecret
                               userName:(NSString *)userName
                             userAvatar:(nullable NSString *)userAvatar;

/**
 通过链接创建直播间，创建直播间可能失败，返回 nil
 #param string          一般为 APP 拉起链接
 #return                直播间或者 nil
 */
+ (nullable __kindof instancetype)roomWithURLString:(NSString *)string;

/**
 设置用户自定义参数，参数会作为进直播间接口的入参
 这个参数必须在进直播间之前设置，建议当实例化room对象后马上设置。
 #param userCustomParameters  用户自定义参数
 */
- (void)setUserCustomParameters:(NSString *)userCustomParameters;

/**
 直播间状态
 #discussion 正常流程: initialized > loadingInfo > loadedInfo > connectingServer > connectedServer > exited
 #discussion 加载直播间信息出错: loadingInfo > initialized + loadInfoError
 #discussion 服务器连接出错/断开: connectingServer > loadedInfo + connectServerError
 #discussion 随时退出: any > exited
 #discussion `state` 属性支持 KVO、各种 `error` 不支持 KVO，`state` 发生变化时各 `error` 可用
 */
@property (nonatomic, readonly) BJLRoomState state;
@property (nonatomic, readonly, nullable) BJLError *error; // NON-KVO

/**
 是否在切换直播间
 #discussion 大小班切换中
 */
@property (nonatomic, readonly, getter=isSwitchingRoom) BOOL switchingRoom;
/** 是否在刷新直播间 */
@property (nonatomic, readonly) BOOL reloading;

/** 线上双师具体班型, 仅对线上双师班型有效 */
@property (nonatomic, readonly) BJLOnlineDoubleRoomType onlineDoubleRoomType;

/** 进入直播间 */
- (void)enter;
/** 进入直播间
 #param validateConflict 传 YES 检查是否有相同用户在直播间、如果有则回调错误 `BJLErrorCode_enterRoom_loginConflict`，传 NO 直接进入直播间、相同用户将被踢出
 #discussion 目前此参数只对老师起作用、其他角色相当于 `validateConflict` 传 NO
 #discussion 直接调用 `enter` 也相当于 `validateConflict` 传 NO
 */
- (void)enterByValidatingConflict:(BOOL)validateConflict;

/**
 进入直播间成功
 #discussion 成功时所有初始化工作已经结束，vm 的状态、数据已经和服务端同步，并可调用 vm 方法
 */
- (BJLObservable)enterRoomSuccess;

/**
 进入直播间失败
 #param error 错误信息
 #discussion 参考 `BJLErrorCode`
 */
- (BJLObservable)enterRoomFailureWithError:(BJLError *)error;

/**
 断开、重连
 #discussion 网络连接断开时回调，回调 callback 确认是否重连，YES 重连、NO 退出直播间，也可延时或者手动调用 callback
 #discussion 可通过 `reloadingVM` 监听重连的进度和结果
 #discussion 默认（不设置此回调）在断开时自动重连、重连过程中遇到错误将 `异常退出`
 #discussion !!!: 断开重连过程中 vm 的状态、数据没有与服务端同步，调用其它 vm 方法时发起的网络请求会被丢弃、甚至产生不可预期的错误
 #param reloadingBlock 重连回调。reloadingVM：重连 vm；callback(reload)：调用 callback 时 reload 参数传 YES 重连，NO 将导致 `异常退出`
 */
- (void)setReloadingBlock:(void (^_Nullable)(BJLLoadingVM *reloadingVM,
                              void (^callback)(BOOL reload)))reloadingBlock;

/** 退出直播间 */
- (void)exit;

/**
 即将退出直播间的通知 - 主动/异常
 #discussion 主动退出 `error` 为 nil，否则为异常退出
 #discussion 参考 `BJLErrorCode`
 #param error 错误信息
 */
- (BJLObservable)roomWillExitWithError:(nullable BJLError *)error;

/**
 退出直播间的通知 - 主动/异常
 #discussion 主动退出 `error` 为 nil，否则为异常退出
 #discussion 参考 `BJLErrorCode`
 #param error 错误信息
 */
- (BJLObservable)roomDidExitWithError:(nullable BJLError *)error;

#pragma mark metainfo

/**
 直播间信息
 #discussion BJLiveCore 内部【不】读取此处 `roomInfo`
 */
@property (nonatomic, readonly, copy) NSObject<BJLRoomInfo> *roomInfo;

/**
 当前登录用户信息
 #discussion BJLiveCore 内部【不】读取此处 `loginUser`
 */
@property (nonatomic, readonly, copy) BJLUser *loginUser;

/**
 当前登录用户是否是主讲人
 #discussion 不支持 KVO
 */
@property (nonatomic, readonly) BOOL loginUserIsPresenter; // NON-KVO

/**
 功能设置
 #discussion BJLiveCore 内部【不】读取此处 featureConfig
 #discussion TODO: MingLQ - if nil
 */
@property (nonatomic, readonly, copy, nullable) BJLFeatureConfig *featureConfig __APPLE_API_UNSTABLE;

#pragma mark view & view-model

/** 进直播间的 loading 状态，参考 `BJLLoadingVM` */
@property (nonatomic, readonly, nullable) BJLLoadingVM *loadingVM;

/** 直播间信息、状态，用户信息，公告等，参考 `BJLRoomVM` */
@property (nonatomic, readonly, nullable) BJLRoomVM *roomVM;

/** 在线用户，参考 `BJLOnlineUsersVM` */
@property (nonatomic, readonly, nullable) BJLOnlineUsersVM *onlineUsersVM;

/** 发言申请/处理，参考 `BJLSpeakingRequestVM` */
@property (nonatomic, readonly, nullable) BJLSpeakingRequestVM *speakingRequestVM;

/** 音视频 设置，参考 `BJLMediaVM` */
@property (nonatomic, readonly, nullable) BJLMediaVM *mediaVM;

/** 音视频 采集 - 个人，参考 `BJLRecordingVM` */
@property (nonatomic, readonly, nullable) BJLRecordingVM *recordingVM;
/**
 视频采集视图 - 个人，
 #discussion 参考 `BJLRecordingVM` 的 `recordingVideo`、`inputVideoAspectRatio`
 */
@property (nonatomic, readonly, nullable) UIView *recordingView;

/** 音视频 播放 - 他人，参考 `BJLPlayingVM` */
@property (nonatomic, readonly, nullable) BJLPlayingVM *playingVM;

/** 针对旧版 SDK 的 playingVM 创建的适配层，管理发言用户大班课主摄像头位置的音视频信息 */
@property (nonatomic, readonly, nullable) BJLPlayingAdapterVM *mainPlayingAdapterVM;

/** 针对旧版 SDK 的 playingVM 创建的适配层，管理发言用户大班课扩展摄像头位置的音视频信息 */
@property (nonatomic, readonly, nullable) BJLPlayingAdapterVM *extraPlayingAdapterVM;

/** 课件管理、显示、控制，参考 `BJLDocumentVM` */
@property (nonatomic, readonly, nullable) BJLDocumentVM *documentVM;

/** 画笔管理 */
@property (nonatomic, readonly, nullable) BJLDrawingVM *drawingVM;

/**
 禁用动画课件
 #discussion 是否禁用动画课件由两个参数控制，任意一个值为 YES 就禁止
 #discussion 1、由服务端通过 `BJLFeatureConfig` 的 `disablePPTAnimation` 控制
 #discussion 2、由上层设置这个 `disablePPTAnimation`
 */
@property (nonatomic) BOOL disablePPTAnimation;
/**
 课件、画笔视图
 #discussion 尺寸、位置随意设定，需要设置为整数的 pt 值
 */
@property (nonatomic, readonly, nullable) UIViewController<BJLSlideshowUI> *slideshowViewController;

/** 云端录课，参考 `BJLServerRecordingVM` */
@property (nonatomic, readonly, nullable) BJLServerRecordingVM *serverRecordingVM;

/** 打赏，参考 BJLGiftVM */
@property (nonatomic, readonly, nullable) BJLGiftVM *giftVM;

/** 聊天/弹幕，参考 BJLChatVM */
@property (nonatomic, readonly, nullable) BJLChatVM *chatVM;

/** 直播间内作业管理、显示、控制，参考 `BJLHomeworkVM` */
@property (nonatomic, readonly, nullable) BJLHomeworkVM *homeworkVM;

/** 直播间内云盘文件管理、显示、控制，参考 `BJLCloudDiskVM` */
@property (nonatomic, readonly, nullable) BJLCloudDiskVM *cloudDiskVM;

/** 直播带货商品显示、控制，参考 `BJLSellVM` */
@property (nonatomic, readonly, nullable) BJLSellVM *sellVM;

/** 自习室逻辑 */
@property (nonatomic, readonly, nullable) BJLStudyRoomVM *studyRoomVM;

/** 内部使用 */
@property (nonatomic, readonly, nullable) BJLHelpVM *helpVM;
/** 直播配置项，内部使用 */
@property (nonatomic, readonly) NSMutableDictionary *roomOptions;

#pragma mark - deployment

/**
 环境部署，需要在进直播间之前设置
 设置 `deployType` 将导致 `privateDomainPrefix` 被重置
 !!!: 仅供内部使用，集成 SDK 的用户请勿使用
 */
@property (class, nonatomic) BJLDeployType deployType;

/**
 环境部署，需要在进直播间之前设置
 !!!: 仅供内部使用，集成 SDK 的用户请勿使用
 */
@property (class, nonatomic) BJLDeployType brtcDeployType;

/**
 上传 rtc 课程的日志
 #param urlString 文件将要存储的 urlString
 #param completion 完成的 completion
 */
+ (void)uploadRTCLogWithURLString:(NSString *)urlString completion:(nullable void (^)(BOOL success, BJLError *_Nullable error))completion;

/** 上报用户行为 */
- (void)reportLogWithMessage:(NSString *)message;

#ifdef DEBUG
- (BOOL)usingKCP;
#endif
@end

NS_ASSUME_NONNULL_END
