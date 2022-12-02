//
//  BLiveDef.h
//  BLive
//
//  Created by xijia dai on 2022/2/17.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

/// 错误码定义
typedef NS_ENUM(NSInteger, BLiveErrorCode) {
    /// 网络错误
    BLiveErrorCode_NetworkError,
    /// 请求失败
    BLiveErrorCode_RequestFailed,
    /// 主动调用取消
    BLiveErrorCode_Cancelled,
    /// 非法用户角色
    BLiveErrorCode_InvalidUserRole,
    /// 非法调用
    BLiveErrorCode_InvalidCalling,
    /// 参数错误
    BLiveErrorCode_InvalidArguments,
    /// 操作过于频繁
    BLiveErrorCode_AreYouRobot,
    /// 登录冲突
    BLiveErrorCode_LoginConflict,
    /// 未知错误
    BLiveErrorCode_Unknown
};

FOUNDATION_EXPORT NSString *_Nonnull BLiveErrorDescription(BLiveErrorCode code);

FOUNDATION_EXPORT NSError *_Nullable BLiveErrorMake(BLiveErrorCode errorCode, NSString *_Nullable reason);

#pragma mark -

/// 部署环境(内部使用)
typedef NS_ENUM(NSInteger, BLiveDeployType) {
    BLiveDeployType_Product,
    BLiveDeployType_Beta,
    BLiveDeployType_Test,
};

/// 直播场景状态
typedef NS_ENUM(NSInteger, BLiveState) {
    /// 默认状态
    BLiveState_Ready,
    /// 场景连接中
    BLiveState_Connecting,
    /// 已进入场景
    BLiveState_Connected,
};

/// 用户角色
typedef NS_ENUM(NSInteger, BLiveRoleType) {
    /// 观众
    BLiveRoleType_Audience = 0,
    /// 主播
    BLiveRoleType_Anchor = 1,
};

/// 合流布局模式
typedef NS_ENUM(NSInteger, BLiveMixStreamMode) {
    /// 自定义模式
    BLiveMixStreamMode_Custom = 1,
    /// 画廊布局
    BLiveMixStreamMode_Gallery = 2,
    /// 演讲布局
    BLiveMixStreamMode_Speech = 3,
    /// 悬浮布局
    BLiveMixStreamMode_Float = 4,
};

/// 媒体流编码格式
typedef NS_ENUM(NSInteger, BLiveStreamCodec) {
    /// h264
    BLiveStreamCodec_H264 = 0,
    /// vp8
    BLiveStreamCodec_VP8 = 1,
};

/// 媒体流类型
typedef NS_ENUM(NSInteger, BLiveStreamType) {
    /// vloud
    BLiveStreamType_Vloud = 0,
    /// trtc
    BLiveStreamType_TRTC = 1,
};

/// 内容填充模式
typedef NS_ENUM(NSInteger, BLiveContentMode) {
    /// 完整显示，可能有黑边
    BLiveContentMode_AspectFit = 0,
    /// 铺满显示，可能裁剪
    BLiveContentMode_AspectFill = 1,
    /// 拉伸铺满
    BLiveContentMode_Scalefill = 2,
};

#pragma mark -

typedef NSString *BLiveExtraInfoKey NS_EXTENSIBLE_STRING_ENUM;

FOUNDATION_EXPORT BLiveExtraInfoKey const BLiveExtraInfoUserNumber;
FOUNDATION_EXPORT BLiveExtraInfoKey const BLiveExtraInfoSDKVersion;
FOUNDATION_EXPORT BLiveExtraInfoKey const BLiveExtraInfoEndType;

/**
 ### 直播场景进入参数
 进入直播场景所需的参数类
 */
@interface BLiveParams: NSObject

/// APP ID
@property (nonatomic) NSString *appID;
/// 直播场景 ID
@property (nonatomic) NSString *roomID;
/// 校验 sign
@property (nonatomic) NSString *sign;
/// 用户唯一标识
@property (nonatomic) NSString *userID;
/// 用户角色
@property (nonatomic) BLiveRoleType role;
/// 直播场景可选的额外信息
@property (nonatomic, readonly) NSDictionary<BLiveExtraInfoKey, id> *extraInfo;

/// 设置进入直播场景的额外信息
- (void)setExtraInfo:(id)info forKey:(BLiveExtraInfoKey)key;

@end

#pragma mark -

typedef NSString *BLiveDefinition NS_EXTENSIBLE_STRING_ENUM;

FOUNDATION_EXPORT BLiveDefinition const BLiveDefinitionRaw;
FOUNDATION_EXPORT BLiveDefinition const BLiveDefinitionStd16x9;
FOUNDATION_EXPORT BLiveDefinition const BLiveDefinitionHigh16x9;
FOUNDATION_EXPORT BLiveDefinition const BLiveDefinitionStd4x3;
FOUNDATION_EXPORT BLiveDefinition const BLiveDefinitionHigh4x3;

/**
 ### 确定清晰度的 CDN 流的信息
 */
@interface BLiveMixStreamURLList: NSObject

/// 当前 URL 列表的清晰度
@property (nonatomic, nullable, readonly) NSString *definition;
/// RTMP 格式的 URL
@property (nonatomic, nullable, readonly) NSString *rtmpURLString;
/// FLV 格式的 URL
@property (nonatomic, nullable, readonly) NSString *flvURLString;
/// M3U8 格式的 URL，SDK 不支持播放
@property (nonatomic, nullable, readonly) NSString *m3u8URLString;
/// 当前清晰度列表是否支持某个 URL，M3U8 格式不支持
- (BOOL)supportStreamURLString:(NSString *)urlString;

@end

/**
 ### 合流清晰度信息
 */
@interface BLiveMixStreamDefinitionInfo: NSObject

/// 当前合流的清晰度节点，可能为空
@property (nonatomic, nullable, readonly) NSString *cdnName;
/// 当前节点的合流清晰度数组
@property (nonatomic, nullable, readonly) NSArray<BLiveMixStreamURLList *> *mixStreamList;
/// 获取指定清晰度的 CDN 地址列表
- (nullable BLiveMixStreamURLList *)streamURLListWithDefinition:(BLiveDefinition)definition;

@end

/**
 #### 播放 CDN 流参数
 */
@interface BLivePlayStreamInfo: NSObject

/// 合流 ID，为空时认为是外部 URL
@property (nonatomic, nullable) NSString *mixStreamID;
/// 需要播放的外部 URL
@property (nonatomic, nullable) NSString *urlString;
/// 清晰度，仅合流可用
@property (nonatomic, nullable) BLiveDefinition definition;
/// CDN 索引，仅播放合流可用，超过合流支持的 CDN 总数时取余
@property (nonatomic) NSInteger cdnIndex;
/// 是否播放音频、视频
@property (nonatomic) BOOL playAudio, playVideo;

@end

NS_ASSUME_NONNULL_END
