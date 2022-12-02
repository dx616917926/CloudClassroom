//
//  BJVConstants.h
//  BJVideoPlayerCore
//
//  Created by xyp on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <BJLiveBase/UIKit+BJL_M9Dev.h>

NS_ASSUME_NONNULL_BEGIN

/** WebSocket 请求超时时间 */
FOUNDATION_EXPORT const NSTimeInterval BJVWebSocketTimeoutInterval;

/** 服务端信令协议的版本 */
FOUNDATION_EXPORT const NSInteger BJVRoomServerVersion;

/** 部署环境(内部使用) */
//typedef NS_ENUM(NSInteger, BJVDeployType) {
//    BJVDeployType_www, // 正式环境
//    BJVDeployType_beta,
//    BJVDeployType_test,
//    _BJVDeployType_count
//};

/** 用户角色 */
typedef NS_ENUM(NSInteger, BJVUserRole) {
    /** 学生 */
    BJVUserRole_student = 0,
    /** 老师 */
    BJVUserRole_teacher = 1,
    /** 助教 */
    BJVUserRole_assistant = 2,
    /** 游客 */
    BJVUserRole_guest = 3 // 内部使用
};

/** 用户音视频可用状态 */
typedef NS_ENUM(NSInteger, BJVUserMediaState) {
    /** 可用的 */
    BJVUserMediaState_available = 0,
    /** 某种原因不可用 */
    BJVUserMediaState_unavailable = 1,
    /** 未授权的 */
    BJVUserMediaState_unauthorized = 2,
    /** 被占用的 */
    BJVUserMediaState_occupied = 3,
    /** 在后台的 */
    BJVUserMediaState_backstage = 4
};

/** 直播间类型 */
typedef NS_ENUM(NSInteger, BJVRoomType) {
    /** 大班课 */
    BJVRoomType_1vNClass = 2,
    /** 小班课 & 1v1 (专业版) */
    BJVRoomType_interactiveClass = 4,
    /** 1v1 (基础版) */
    BJVRoomType_1v1Class = 6,
    /** 双师 */
    BJVRoomType_doubleTeachersClass = 5,
    /// REMOVED:
    // BJVRoomType_1to1 = 1 - 旧版一对一
    // BJVRoomType_smallClass = 3 - 旧版小班课
};

/** 直播间分组类型 */
typedef NS_ENUM(NSInteger, BJVRoomGroupType) {
    /** 普通未分组大班课 */
    BJVRoomGroupType_noGroup = 0,
    /** 分组直播 */
    BJVRoomGroupType_group = 1,
    /** 大小班课程 */
    BJVRoomGroupType_onlinedoubleTeachers = 2,
};

/** 新版直播间分组类型 */
typedef NS_ENUM(NSInteger, BJVRoomNewGroupType) {
    /** 普通大班课 */
    BJVRoomNewGroupType_normal = 0,
    /** 新版分组课堂 */
    BJVRoomNewGroupType_group = 1,
    /** 新版线上双师 */
    BJVRoomNewGroupType_onlinedoubleTeachers = 2,
};

/** 专业版小班课直播间模板类型 */
typedef NS_ENUM(NSInteger, BJVIcTemplateType) {
    /** 用户视频位于上侧 */
    BJVIcTemplateType_userVideoUpside = 1,
    /** 1v1 (专业版) */
    BJVIcTemplateType_1v1 = 3
};

/** 客户端类型 */
typedef NS_ENUM(NSUInteger, BJVClientType) {
    /** PC 网页 */
    BJVClientType_PCWeb = 0,
    /** PC 客户端 */
    BJVClientType_PCApp = 1,
    /** M 站 */
    BJVClientType_MobileWeb = 2,
    /** iOS 客户端 */
    BJVClientType_iOSApp = 3,
    /** Android 客户端 */
    BJVClientType_AndroidApp = 4,
    /** Mac 客户端 */
    BJVClientType_MacApp = 5,
    /** 微信小程序 */
    BJVClientType_MiniProgram = 6
};

/** 在线状态 */
typedef NS_ENUM(NSInteger, BJVOnlineState) {
    /** 在线 */
    BJVOnlineState_visible = 0,
    /** 隐身 */
    BJVOnlineState_invisible = 1,
    /** 离线 */
    BJVOnlineState_offline = 2
};

/** 媒体类型限制 */
typedef NS_ENUM(NSInteger, BJVMediaLimit) {
    /** 无限制 */
    BJVMediaLimit_none = 0,
    /** 只支持音频 */
    BJVMediaLimit_audioOnly = 1
};

/** 链路类型 */
typedef NS_ENUM(NSInteger, BJVLinkType) {
    /** TCP */
    BJVLinkType_TCP = 0,
    /** UDP */
    BJVLinkType_UDP = 1
};
static inline BOOL BJVLinkTypeValidate(BJVLinkType linkType) {
    return linkType == BJVLinkType_TCP || linkType == BJVLinkType_UDP;
}
static inline BJVLinkType BJVLinkTypeValidify(BJVLinkType linkType) {
    return linkType == BJVLinkType_TCP ? BJVLinkType_TCP : BJVLinkType_UDP;
}

/** 视频画面采集方向 */
typedef NS_ENUM(NSInteger, BJVVideoRecordingOrientation) {
    /** 横屏采集 */
    BJVVideoRecordingOrientation_alwaysLandscape,
    /** 竖屏采集 */
    BJVVideoRecordingOrientation_alwaysPortrait,
    /** 根据设备方向自适应采集 */
    BJVVideoRecordingOrientation_auto
};

/** 视频画面显示模式 */
typedef NS_ENUM(NSInteger, BJVVideoContentMode) {
    /** 保持比例，自适应显示 */
    BJVVideoContentMode_aspectFit,
    /** 保持比例，填充显示 */
    BJVVideoContentMode_aspectFill
};

/** 视频画面显示方向 */
typedef NS_ENUM(NSInteger, BJVVideoOrientation) {
    /** 自动 - 使用设备方向 */
    BJVVideoOrientation_auto,
    /** 纵向 */
    BJVVideoOrientation_portrait,
    /** 横向 */
    BJVVideoOrientation_landscape
};

/** 视频清晰度 - 采集 */
typedef NS_ENUM(NSInteger, BJVVideoDefinition) {
    /** 流畅 */
    BJVVideoDefinition_std,
    /** 360p */
    BJVVideoDefinition_360p,
    /** 高清 */
    BJVVideoDefinition_high,
    /** 720p */
    BJVVideoDefinition_720p,
    /** 1080p */
    BJVVideoDefinition_1080p,
    /** 清晰度数量 */
    _BJVVideoDefinition_count,
    /** 默认 */
    BJVVideoDefinition_default = BJVVideoDefinition_std
};
/** 视频清晰度 - 播放
typedef NS_ENUM(NSInteger, BJVLiveDefinition) {
    // 流畅
    BJVLiveDefinition_low,
    // 标清
    BJVLiveDefinition_std,
    // 高清
    BJVLiveDefinition_high,
    // 超清
    BJVLiveDefinition_super,
    // 720p
    BJVLiveDefinition_720p,
    // 1080p
    BJVLiveDefinition_1080p
}; */

/** 视频清晰度 - 播放 */
typedef NSString *BJVLiveDefinitionKey NS_STRING_ENUM;
FOUNDATION_EXPORT BJVLiveDefinitionKey const BJVLiveDefinitionKey_low; // 流畅
FOUNDATION_EXPORT BJVLiveDefinitionKey const BJVLiveDefinitionKey_std; // 标清
FOUNDATION_EXPORT BJVLiveDefinitionKey const BJVLiveDefinitionKey_high; // 高清
FOUNDATION_EXPORT BJVLiveDefinitionKey const BJVLiveDefinitionKey_super; // 超清
FOUNDATION_EXPORT BJVLiveDefinitionKey const BJVLiveDefinitionKey_720p; // 720p
FOUNDATION_EXPORT BJVLiveDefinitionKey const BJVLiveDefinitionKey_1080; // 1080p
FOUNDATION_EXPORT NSString *_Nonnull BJVLiveDefinitionNameForKey(BJVLiveDefinitionKey key);

/** 美颜 */
typedef NS_ENUM(NSInteger, BJVVideoBeautifyLevel) {
    BJVVideoBeautifyLevel_0,
    BJVVideoBeautifyLevel_1,
    BJVVideoBeautifyLevel_2,
    BJVVideoBeautifyLevel_3,
    BJVVideoBeautifyLevel_4,
    BJVVideoBeautifyLevel_5,
    BJVVideoBeautifyLevel_off = BJVVideoBeautifyLevel_0,
    BJVVideoBeautifyLevel_on = BJVVideoBeautifyLevel_5,
    BJVVideoBeautifyLevel_default = BJVVideoBeautifyLevel_off
};

/** 礼物类型 */
typedef NS_ENUM(NSInteger, BJVGiftType) {
    /** 可乐 */
    BJVGiftType_cola = 1,
    /** 咖啡 */
    BJVGiftType_coffee = 2,
    /** 橙汁 */
    BJVGiftType_orangeJuice = 3,
    /** 冰红茶 */
    BJVGiftType_tea = 4,
    /** 大麦茶 */
    BJVGiftType_barleyTea = 5
};

typedef NS_ENUM(NSInteger, BJVTextMaxLength) {
    /** 聊天消息最大字符数 */
    BJVTextMaxLength_chat = 400,
    /** 公告最大字符数 */
    BJVTextMaxLength_notice = 140,
    /** 问答最大字符数 */
    BJVTextMaxLength_question = 280
};

/** 聊天状态 */
typedef NS_ENUM(NSInteger, BJVChatStatus) {
    /** 群聊 */
    BJVChatStatus_default,
    /** 私聊 */
    BJVChatStatus_private
};

/** 视频在大班课中占据的摄像头位置 */
typedef NS_ENUM(NSInteger, BJVCameraType) {
    /** 主摄像头位置 */
    BJVCameraType_main,
    /** 扩展摄像头位置 */
    BJVCameraType_extra
};

/** 视频源类型 */
typedef NS_ENUM(NSInteger, BJVMediaSource) {
    /** 主摄像头采集 */
    BJVMediaSource_mainCamera,
    /** 辅助摄像头采集 */
    BJVMediaSource_extraCamera,
    /** 媒体文件播放 */
    BJVMediaSource_mediaFile,
    /** 屏幕共享 */
    BJVMediaSource_screenShare,
    /** 辅助摄像头屏幕共享 */
    BJVMediaSource_extraScreenShare,
    /** 辅助文件播放 */
    BJVMediaSource_extraMediaFile,
    /** 所有类型，一般只在用户退出的回调时使用 */
    BJVMediaSource_all = -1
};

/** 直播间网络状况 */
typedef NS_ENUM(NSInteger, BJVNetworkStatus) {
    BJVNetworkStatus_normal = 0, // 正常
    BJVNetworkStatus_Bad_level1, // 较差
    BJVNetworkStatus_Bad_level2, // 差
    BJVNetworkStatus_Bad_level3, // 极差
    BJVNetworkStatus_Bad_level4, // 强提示的极差
    BJVNetworkStatus_Bad_level5 // 极差可阻塞UI的提示
};

/** 后端进程状态 */
typedef NS_ENUM(NSInteger, BJVTaskStatus) {
    /** 未知 */
    BJVTaskStatus_unknow = -1,
    /** 进行中 */
    BJVTaskStatus_processing,
    /** 完成 */
    BJVTaskStatus_finished,
    /** 失败 */
    BJVTaskStatus_failed,
    /** 超时 */
    BJVTaskStatus_timeOut
};

/** 录制类型 */
typedef NS_ENUM(NSInteger, BJVServerRecordingType) {
    /** 云端录制 */
    BJVServerRecordingType_cloud = 1,
    /** 推流录制 */
    BJVServerRecordingType_auto,
};

NS_ASSUME_NONNULL_END
