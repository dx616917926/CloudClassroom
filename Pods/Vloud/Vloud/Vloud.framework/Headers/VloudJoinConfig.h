/***********************
auth: cszdlt@qq.com
date: 2020-03-26 20:35:40
name: VloudJoinConfig.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudJoinConfig : NSObject

/// 房间ID
@property(nonatomic, copy) NSString *roomId;

/// 用户ID，相同房间内不可以有两个相同的 userId
@property(nonatomic, copy) NSString *userId;

/// 设备平台 (可选)
@property (nonatomic, copy) NSString *platform;

/// 房间密码 (可选)
@property(nonatomic, copy) NSString *roomPassword;

/// 当 roomId 的房间未创建时，是否创建房间。 默认值为 YES
@property(nonatomic, assign) BOOL create;

/// 用户昵称 (可选)
@property(nonatomic, copy) NSString *nickName;

/// 当前设备 (可选)
@property(nonatomic, copy) NSString *device;

/// 当前版本 (可选)
@property(nonatomic, copy) NSString *version;

/// 自定义鉴权 token (可选)
@property(nonatomic, copy) NSString *customToken;

/// 自定义扩展信息 (可选)
@property(nonatomic, copy) NSString *extendInfo;

/// 自定义信息 (可选)
@property(nonatomic, copy) NSString *customInfo;

/// 卡顿判断阈值-视频丢包率 (可选)
@property(nonatomic, assign) int videoLoss;

/// 卡顿判断阈值-音频丢包率 (可选)
@property(nonatomic, assign) int audioLoss;

/// 卡顿判断阈值-视频帧率 (可选)
@property(nonatomic, assign) int videoFrameRate;

/// 卡顿判断阈值-视频帧间隔 (可选)
@property(nonatomic, assign) int videoInterval;

/// 卡顿判断阈值-音频帧间隔 (可选)
@property(nonatomic, assign) int audioInterval;

/// 代理服务器信息
@property(nonatomic, copy) NSString *proxiesInfo;

/// proxy 走竟速连接还是顺序连接
@property(nonatomic, assign) BOOL isSpeedConnect;

/// 服务器跟本地的时间戳差值
@property(nonatomic, strong) NSNumber *timestampDiff;

/// 真实IP
@property(nonatomic, copy) NSString *clientIP;

/// 标识是否开启日志上报功能
@property(nonatomic, assign) BOOL isReport;

- (instancetype)init;

- (instancetype)initWithRoomId:(NSString *)roomId userId:(NSString *)userId;

- (instancetype)initWithRoomId:(NSString *)roomId
                        userId:(NSString *)userId
                  roomPassword:(NSString *)roomPassword
                        create:(BOOL)create
                      nickName:(NSString *)nickName
                        device:(NSString *)device
                       version:(NSString *)version
                   customToken:(NSString *)customToken
                    extendInfo:(NSString *)extendInfo
                    customInfo:(NSString *)customInfo;
@end

NS_ASSUME_NONNULL_END
