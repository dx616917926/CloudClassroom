//
//  BJLConstants.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-11-26.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <BJLiveBase/UIKit+BJL_M9Dev.h>

NS_ASSUME_NONNULL_BEGIN

/** WebSocket 请求超时时间 */
FOUNDATION_EXPORT const NSTimeInterval BJLWebSocketTimeoutInterval;

/** 服务端信令协议的版本 */
FOUNDATION_EXPORT const NSInteger BJLRoomServerVersion;

/** 部署环境(内部使用) */
typedef NS_ENUM(NSInteger, BJLDeployType) {
    BJLDeployType_www, // 正式环境
    BJLDeployType_beta,
    BJLDeployType_test,
    _BJLDeployType_count
};

/** 用户角色 */
typedef NS_ENUM(NSInteger, BJLUserRole) {
    /** 学生 */
    BJLUserRole_student = 0,
    /** 老师 */
    BJLUserRole_teacher = 1,
    /** 助教 */
    BJLUserRole_assistant = 2,
    /** 游客 */
    BJLUserRole_guest = 3 // 内部使用
};

/** 用户音视频可用状态 */
typedef NS_ENUM(NSInteger, BJLUserMediaState) {
    /** 可用的 */
    BJLUserMediaState_available = 0,
    /** 某种原因不可用 */
    BJLUserMediaState_unavailable = 1,
    /** 未授权的 */
    BJLUserMediaState_unauthorized = 2,
    /** 被占用的 */
    BJLUserMediaState_occupied = 3,
    /** 在后台的 */
    BJLUserMediaState_backstage = 4
};

/** 直播间类型 */
typedef NS_ENUM(NSInteger, BJLRoomType) {
    /** 大班课 */
    BJLRoomType_1vNClass = 2,
    /** 小班课 & 1v1 (专业版) */
    BJLRoomType_interactiveClass = 4,
    /** 1v1 (基础版) */
    BJLRoomType_1v1Class = 6,
    /** 双师 */
    BJLRoomType_doubleTeachersClass = 5,
    /// REMOVED:
    // BJLRoomType_1to1 = 1 - 旧版一对一
    // BJLRoomType_smallClass = 3 - 旧版小班课
};

/** 是横版UI还是竖版UI */
typedef NS_ENUM(NSInteger, BJLRoomUIOrientation) {
    /** 横版UI */
    BJLRoomUIOrientationLandscape = 1,
    /** 竖版UI */
    BJLRoomUIOrientationPortrait = 2,
};

/** 直播间分组类型 */
typedef NS_ENUM(NSInteger, BJLRoomGroupType) {
    /** 普通未分组大班课 */
    BJLRoomGroupType_noGroup = 0,
    /** 分组直播 */
    BJLRoomGroupType_group = 1,
    /** 大小班课程 */
    BJLRoomGroupType_onlinedoubleTeachers = 2,
};

/** 新版直播间分组类型 */
typedef NS_ENUM(NSInteger, BJLRoomNewGroupType) {
    /** 普通大班课 */
    BJLRoomNewGroupType_normal = 0,
    /** 新版分组课堂 */
    BJLRoomNewGroupType_group = 1,
    /** 新版线上双师 */
    BJLRoomNewGroupType_onlinedoubleTeachers = 2,
};

/** 专业版小班课直播间模板类型 */
typedef NS_ENUM(NSInteger, BJLIcTemplateType) {
    /** 用户视频位于上侧 */
    BJLIcTemplateType_userVideoUpside = 1,
    /** 1v1 (专业版) */
    BJLIcTemplateType_1v1 = 3
};

/** 客户端类型 */
typedef NS_ENUM(NSUInteger, BJLClientType) {
    /** PC 网页 */
    BJLClientType_PCWeb = 0,
    /** PC 客户端 */
    BJLClientType_PCApp = 1,
    /** M 站 */
    BJLClientType_MobileWeb = 2,
    /** iOS 客户端 */
    BJLClientType_iOSApp = 3,
    /** Android 客户端 */
    BJLClientType_AndroidApp = 4,
    /** Mac 客户端 */
    BJLClientType_MacApp = 5,
    /** 微信小程序 */
    BJLClientType_MiniProgram = 6
};

typedef NS_ENUM(NSUInteger, BJLPlayerType) {
    BJLPlayerType_BJYAVSDK = 0,
    BJLPlayerType_BJYRTC = 1,
    BJLPlayerType_TRTC = 3,
    BJLPlayerType_BRTC_TRTC = 4,
    BJLPlayerType_BRTC = 5
    // REMOVED: BJLPlayerType_AGORA = 2
};

/** 在线状态 */
typedef NS_ENUM(NSInteger, BJLOnlineState) {
    /** 在线 */
    BJLOnlineState_visible = 0,
    /** 隐身 */
    BJLOnlineState_invisible = 1,
    /** 离线 */
    BJLOnlineState_offline = 2
};

/** 媒体类型限制 */
typedef NS_ENUM(NSInteger, BJLMediaLimit) {
    /** 无限制 */
    BJLMediaLimit_none = 0,
    /** 只支持音频 */
    BJLMediaLimit_audioOnly = 1
};

/** 链路类型 */
typedef NS_ENUM(NSInteger, BJLLinkType) {
    /** TCP */
    BJLLinkType_TCP = 0,
    /** UDP */
    BJLLinkType_UDP = 1
};
static inline BOOL BJLLinkTypeValidate(BJLLinkType linkType) {
    return linkType == BJLLinkType_TCP || linkType == BJLLinkType_UDP;
}
static inline BJLLinkType BJLLinkTypeValidify(BJLLinkType linkType) {
    return linkType == BJLLinkType_TCP ? BJLLinkType_TCP : BJLLinkType_UDP;
}

/** 视频画面采集方向 */
typedef NS_ENUM(NSInteger, BJLVideoRecordingOrientation) {
    /** 横屏采集 */
    BJLVideoRecordingOrientation_alwaysLandscape,
    /** 竖屏采集 */
    BJLVideoRecordingOrientation_alwaysPortrait,
    /** 根据设备方向自适应采集 */
    BJLVideoRecordingOrientation_auto
};

/** 视频画面显示模式 */
typedef NS_ENUM(NSInteger, BJLVideoContentMode) {
    /** 保持比例，自适应显示 */
    BJLVideoContentMode_aspectFit,
    /** 保持比例，填充显示 */
    BJLVideoContentMode_aspectFill
};

/** 视频画面显示方向 */
typedef NS_ENUM(NSInteger, BJLVideoOrientation) {
    /** 自动 - 使用设备方向 */
    BJLVideoOrientation_auto,
    /** 纵向 */
    BJLVideoOrientation_portrait,
    /** 横向 */
    BJLVideoOrientation_landscape
};

/** 视频清晰度 - 采集 */
typedef NS_ENUM(NSInteger, BJLVideoDefinition) {
    /** 流畅 */
    BJLVideoDefinition_std,
    /** 360p */
    BJLVideoDefinition_360p,
    /** 高清 */
    BJLVideoDefinition_high,
    /** 720p */
    BJLVideoDefinition_720p,
    /** 1080p */
    BJLVideoDefinition_1080p,
    /** 清晰度数量 */
    _BJLVideoDefinition_count,
    /** 默认 */
    BJLVideoDefinition_default = BJLVideoDefinition_std
};
/** 视频清晰度 - 播放
typedef NS_ENUM(NSInteger, BJLLiveDefinition) {
    // 流畅
    BJLLiveDefinition_low,
    // 标清
    BJLLiveDefinition_std,
    // 高清
    BJLLiveDefinition_high,
    // 超清
    BJLLiveDefinition_super,
    // 720p
    BJLLiveDefinition_720p,
    // 1080p
    BJLLiveDefinition_1080p
}; */

/** 视频清晰度 - 播放 */
typedef NSString *BJLLiveDefinitionKey NS_STRING_ENUM;
FOUNDATION_EXPORT BJLLiveDefinitionKey const BJLLiveDefinitionKey_low; // 流畅
FOUNDATION_EXPORT BJLLiveDefinitionKey const BJLLiveDefinitionKey_std; // 标清
FOUNDATION_EXPORT BJLLiveDefinitionKey const BJLLiveDefinitionKey_high; // 高清
FOUNDATION_EXPORT BJLLiveDefinitionKey const BJLLiveDefinitionKey_super; // 超清
FOUNDATION_EXPORT BJLLiveDefinitionKey const BJLLiveDefinitionKey_720p; // 720p
FOUNDATION_EXPORT BJLLiveDefinitionKey const BJLLiveDefinitionKey_1080; // 1080p
FOUNDATION_EXPORT NSString *_Nonnull BJLLiveDefinitionNameForKey(BJLLiveDefinitionKey key);

/** 美颜 */
typedef NS_ENUM(NSInteger, BJLVideoBeautifyLevel) {
    BJLVideoBeautifyLevel_0,
    BJLVideoBeautifyLevel_1,
    BJLVideoBeautifyLevel_2,
    BJLVideoBeautifyLevel_3,
    BJLVideoBeautifyLevel_4,
    BJLVideoBeautifyLevel_5,
    BJLVideoBeautifyLevel_off = BJLVideoBeautifyLevel_0,
    BJLVideoBeautifyLevel_on = BJLVideoBeautifyLevel_5,
    BJLVideoBeautifyLevel_default = BJLVideoBeautifyLevel_off
};

typedef NS_ENUM(NSInteger, BJLAudioQuality) {
    /** 人声模式：采样率：16k；单声道；编码码率：16kbps；具备几个模式中最强的网络抗性，适合语音通话为主的场景，比如在线会议，语音通话等。*/
    BJLAudioQualitySpeech = 1,
    /** 默认模式：采样率：48k；单声道；编码码率：50kbps；介于 Speech 和 Music 之间的档位，SDK 默认档位，推荐选择。*/
    BJLAudioQualityDefault = 2,
    /** 音乐模式：采样率：48k；全频带立体声；编码码率：128kbps；适合需要高保真传输音乐的场景，比如在线K歌、音乐直播等。*/
    BJLAudioQualityMusic = 3,
};

/** 礼物类型 */
typedef NS_ENUM(NSInteger, BJLGiftType) {
    /** 可乐 */
    BJLGiftType_cola = 1,
    /** 咖啡 */
    BJLGiftType_coffee = 2,
    /** 橙汁 */
    BJLGiftType_orangeJuice = 3,
    /** 冰红茶 */
    BJLGiftType_tea = 4,
    /** 大麦茶 */
    BJLGiftType_barleyTea = 5
};

typedef NS_ENUM(NSInteger, BJLTextMaxLength) {
    /** 聊天消息最大字符数 */
    BJLTextMaxLength_chat = 400,
    /** 公告最大字符数 */
    BJLTextMaxLength_notice = 140,
    /** 问答最大字符数 */
    BJLTextMaxLength_question = 280
};

/** 聊天状态 */
typedef NS_ENUM(NSInteger, BJLChatStatus) {
    /** 群聊 */
    BJLChatStatus_default,
    /** 私聊 */
    BJLChatStatus_private
};

/** 视频在大班课中占据的摄像头位置 */
typedef NS_ENUM(NSInteger, BJLCameraType) {
    /** 主摄像头位置 */
    BJLCameraType_main,
    /** 扩展摄像头位置 */
    BJLCameraType_extra
};

/** 视频源类型 */
typedef NS_ENUM(NSInteger, BJLMediaSource) {
    /** 主摄像头采集 */
    BJLMediaSource_mainCamera,
    /** 辅助摄像头采集 */
    BJLMediaSource_extraCamera,
    /** 媒体文件播放 */
    BJLMediaSource_mediaFile,
    /** 屏幕共享 */
    BJLMediaSource_screenShare,
    /** 辅助摄像头屏幕共享 */
    BJLMediaSource_extraScreenShare,
    /** 辅助文件播放 */
    BJLMediaSource_extraMediaFile,
    /** 所有类型，一般只在用户退出的回调时使用 */
    BJLMediaSource_all = -1
};

/** 直播间网络状况 */
typedef NS_ENUM(NSInteger, BJLNetworkStatus) {
    BJLNetworkStatus_normal = 0, // 正常
    BJLNetworkStatus_Bad_level1, // 较差
    BJLNetworkStatus_Bad_level2, // 差
    BJLNetworkStatus_Bad_level3, // 极差
    BJLNetworkStatus_Bad_level4, // 强提示的极差
    BJLNetworkStatus_Bad_level5 // 极差可阻塞UI的提示
};

/** 后端进程状态 */
typedef NS_ENUM(NSInteger, BJLTaskStatus) {
    /** 未知 */
    BJLTaskStatus_unknow = -1,
    /** 进行中 */
    BJLTaskStatus_processing,
    /** 完成 */
    BJLTaskStatus_finished,
    /** 失败 */
    BJLTaskStatus_failed,
    /** 超时 */
    BJLTaskStatus_timeOut
};

/** 录制类型 */
typedef NS_ENUM(NSInteger, BJLServerRecordingType) {
    /** 云端录制 */
    BJLServerRecordingType_cloud = 1,
    /** 推流录制 */
    BJLServerRecordingType_auto,
};

/** 直播带货房间类型类型 */
typedef NS_ENUM(NSInteger, BJLSellType) {
    /** 未开启带货 */
    BJLSellTypeNotSupport = 0,
    /** 纯视频带货模板 */
    BJLSellTypeWithPureVideo,
    /** ppt带货模板 */
    BJLSellTypeWithPPT,
};

/** 线上双师当前学生切班状态 */
typedef NS_ENUM(NSInteger, BJLOnlineDoubleRoomType) {
    /** 非线上双师班型 */
    BJLOnlineDoubleRoomType_notSupport = 0,
    /** 线上双师大班集合 */
    BJLOnlineDoubleRoomType_classGathered,
    /** 线上双师分组讨论 */
    BJLOnlineDoubleRoomType_group
};

#pragma mark - AutoLayout Constraints

static inline void BJLConstrains_edgesEqual(UIView *view, id targetItem) {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:targetItem
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:0.0]
        .active = YES;
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:targetItem
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:0.0]
        .active = YES;
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:targetItem
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0]
        .active = YES;
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:targetItem
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:0.0]
        .active = YES;
}

NS_ASSUME_NONNULL_END
