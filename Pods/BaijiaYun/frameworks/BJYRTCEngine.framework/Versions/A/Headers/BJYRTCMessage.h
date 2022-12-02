//
//  BJYRTCMessage.h
//  BJYRTCEngine
//
//  Created by lw0717 on 2019/11/1.
//  Copyright © 2019 BaiJiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJYRTCEngineDefines.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *BJYRTCMessageCode_Domain_BJYSDKAdapter;
FOUNDATION_EXPORT NSString *BJYRTCMessageCode_Domain_BJYAgoraSDKAdapter;
FOUNDATION_EXPORT NSString *BJYRTCMessageCode_Domain_BJYTRTCSDKAdapter;
FOUNDATION_EXPORT NSString *BJYRTCMessageCode_Domain_BJYBRTCSDKAdapter;

typedef NS_ENUM(NSUInteger, BJYRTCMessageType) {
    BJYRTCMessageType_Notification,
    BJYRTCMessageType_Error,
};

typedef NS_ENUM(NSUInteger, BJYRTCMessageCode) {
    ///
    BJYRTCMessageCode_Normal = 0,
    ///******************************************* Room *******************************************
    /// init resolution not support
    BJYRTCMessageCode_Room_NotSupportInitResolution = 500,
    /// no token
    BJYRTCMessageCode_Room_NoToken = 10000,
    /// no session ID
    BJYRTCMessageCode_Room_NoSessionID,
    /// no user ID
    BJYRTCMessageCode_Room_NoUserID,
    /// 第三方sdk设置双流模式相关报错
    BJYRTCMessageCode_Room_SetDualStreamModeError,
    /// 第三方sdk进入房间方法报错
    BJYRTCMessageCode_Room_JoinChannelFailure,
    /// 第三方sdk与服务器断开链接
    BJYRTCMessageCode_Room_LinkServerFailure,
    /// join room 超时
    BJYRTCMessageCode_Room_JoinRoomTimeOut,
    /// 获取流媒体节点失败
    BJYRTCMessageCode_Room_GetServerError,
    /// WebSocket 连接失败
    BJYRTCMessageCode_Room_WebSocketConnectFailure,
    /// WebSocket 断开
    BJYRTCMessageCode_Room_WebSocketFailure,
    /// WebSocket 关闭
    BJYRTCMessageCode_Room_WebSocketDidClosed,
    /// WebSocket 网络不可用
    BJYRTCMessageCode_Room_WebSocketNotReachable,
    /// 区域及媒体服务器地址没有同时存在
    BJYRTCMessageCode_Room_AreaOrNodeNotExist,
    /// 或者区域与媒体服务器地址对应不上
    BJYRTCMessageCode_Room_AreaAndNodeUnableMatch,
    /// 进入主摄像头 session 失败
    BJYRTCMessageCode_Room_JoinMainCameraSessionFailure,
    /// 进入主屏幕分享 session 失败
    BJYRTCMessageCode_Room_JoinMainScreenSharingSessionFailure,
    /// 进入主文件 session 失败
    BJYRTCMessageCode_Room_JoinMainFileSessionFailure,
    /// 进入辅助屏幕共享 session 失败
    BJYRTCMessageCode_Room_JoinExtraScreenSharingSessionFailure,
    /// 进入辅助摄像头 session 失败
    BJYRTCMessageCode_Room_JoinExtraCameraSessionFailure,
    /// 进入辅助文件 session 失败
    BJYRTCMessageCode_Room_JoinExtraFileSessionFailure,
    /// quit session 失败
    BJYRTCMessageCode_Room_QuitSessionFailure,
    /// 拉大小流参数设置失败
    BJYRTCMessageCode_Room_SetDuaStreamFailure,
    ///******************************************* Publisher *******************************************
    /// 推流超时
    BJYRTCMessageCode_Publisher_PublishTimeOut = 20000,
    /// 推流时发生错误
    BJYRTCMessageCode_Publisher_PublishFailure,
    /// 取消推流失败
    BJYRTCMessageCode_Publisher_UnPublishFailure,
    /// 发布器发生未知错误
    BJYRTCMessageCode_Publisher_UnknowError,
    /// tools码率设置异常
    BJYRTCMessageCode_Publisher_BitrateWrong,
    /// 分辨率不在指定范围
    BJYRTCMessageCode_Publisher_SwitchResolutionOutOfRange,
    /// 切分辨率失败
    BJYRTCMessageCode_Publisher_SwitchResolutionFailure,
    /// get local sdp failure
    BJYRTCMessageCode_Publisher_GetLocalSDPFailure,
    /// set local sdp failure
    BJYRTCMessageCode_Publisher_SetLocalSDPFailure,
    /// get remote sdp failure
    BJYRTCMessageCode_Publisher_GetRemoteSDPFailure,
    /// set remote sdp
    BJYRTCMessageCode_Publisher_SetRemoteSDPFailure,
    /// publisher ice连接状态failed pc断了 ---- 与媒体服务器断开
    BJYRTCMessageCode_Publisher_IceConnectionStateFailed,
    /// publisher timeout
    BJYRTCMessageCode_Publisher_Timeout,
    /// 第三方sdk推流方法报错
    BJYRTCMessageCode_Publisher_FunctionReturnFailure,
    /// 双流模式下，切换分辨率时大流分辨率小于等于设置的小流分辨率, 关闭双流
    BJYRTCMessageCode_Publisher_SwitchResolution_CloseDualStream,
    /// 双流模式下，切换分辨率时大流分辨率大于设置的小流分辨率，打开双流
    BJYRTCMessageCode_Publisher_SwitchResolution_OpenDualStream,
    ///******************************************* Subscriber *******************************************
    /// 用户不存在
    BJYRTCMessageCode_Subscriber_UserIDNotExist = 30000,
    /// 切换媒体服务器节点失败
    BJYRTCMessageCode_Subscriber_SwitchMediaServerFailure,
    /// 订阅时发生错误 --- 拉流失败
    BJYRTCMessageCode_Subscriber_SubscribeFailure,
    /// 取消订阅时发生错误
    BJYRTCMessageCode_Subscriber_UnsubscribeFailure,
    /// 订阅器发生未知错误 --- 拉流失败
    BJYRTCMessageCode_Subscriber_UnknowError,
    /// mute 失败
    BJYRTCMessageCode_Subscriber_MuteError,
    /// get local sdp failure
    BJYRTCMessageCode_Subscriber_GetLocalSDPFailure,
    /// set local sdp failure
    BJYRTCMessageCode_Subscriber_SetLocalSDPFailure,
    /// get remote sdp failure
    BJYRTCMessageCode_Subscriber_GetRemoteSDPFailure,
    /// set remote sdp
    BJYRTCMessageCode_Subscriber_SetRemoteSDPFailure,
    /// 卡顿 底层会自动切节点
    BJYRTCMessageCode_Subscriber_Block,
    /// 黑屏 底层会自动切节点 底层需要提供给上层当前节点信息 node:(NSString *)node
    BJYRTCMessageCode_Subscriber_BlackScreen,
    /// subscriber ice连接状态failed pc断了 ---- 与媒体服务器断开
    BJYRTCMessageCode_Subscriber_IceConnectionStateFailed,
    /// subscriber unpublish异常 ---- 与媒体服务器断开
    BJYRTCMessageCode_Subscriber_UnPublishError,
    /// 单个subscriber自动切节点次数达到阈值
    BJYRTCMessageCode_Subscriber_AudoSiwtchNodeTimesRunOut,
    ///******************************************* Server *******************************************
    /// 服务器抛出未知错误码
    BJYRTCMessageCode_Server_UnknowError = 40000,
    ///
    BJYRTCMessageCode_Server_RequestTimeout,// = 3,
    ///
    BJYRTCMessageCode_Server_NotAvailableCode,// = 101,
    ///
    BJYRTCMessageCode_Server_NotExistCode,// = 102,
    ///
    BJYRTCMessageCode_Server_AlreadyExistCode,// = 103,
    ///
    BJYRTCMessageCode_Server_NotReadyCode,// = 104,
    ///
    BJYRTCMessageCode_Server_InvalidRequestCode,// = 105,
    ///
    BJYRTCMessageCode_Server_NotAllowedCode,// = 106,
    ///
    BJYRTCMessageCode_Server_TokenInvalidCode,// = 107,
    ///
    BJYRTCMessageCode_Server_InternalErrorCode,// = 3000,
    ///
    BJYRTCMessageCode_Server_RootDownCode,// = 3001,
    ///
    BJYRTCMessageCode_Server_RouterDownCode,// = 3002,
    ///******************************************* 未知错误 *******************************************
    BJYRTCMessageCode_Unknow = 89757,
};

@interface BJYRTCMessage : NSObject

///
@property (nonatomic, assign) BJYRTCMessageType type;
///
@property (nonatomic, assign) BJYRTCMessageCode code;
///
@property (nonatomic, copy) NSString *data;
///
@property (nonatomic, copy) NSString *domain;
/// 详情
@property (nonatomic, strong) NSDictionary *detail;

/// 链接媒体服务器失败时的分辨率
@property (nonatomic, assign) BJYVideoResolution videoResolution;

- (instancetype)initWithType:(BJYRTCMessageType)type code:(NSInteger)code data:(NSString *)data domain:(NSString *)domain detail:(NSDictionary *)detail;

@end

NS_ASSUME_NONNULL_END
