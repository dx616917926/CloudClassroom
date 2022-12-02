//
//  BJPPlaybackOptions.h
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/6/5.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <Foundation/Foundation.h>
#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

@interface BJPPlaybackOptions: NSObject <BJLYYModel>

@property (nonatomic, assign) BJVPlayerType playerType; // 播放器类型
@property (nonatomic, assign) BOOL advertisementEnabled; // 播放广告，暂不支持
@property (nonatomic, assign) BOOL autoplay; // 自动播放
@property (nonatomic, assign) BOOL sliderDragEnabled; // 能否拖动进度条
@property (nonatomic, assign) BOOL playTimeRecordEnabled; // 开启记忆播放
@property (nonatomic, assign) BOOL encryptEnabled; // 开启加密
@property (nonatomic, assign) BOOL backgroundAudioEnabled; // 开启后台播放，必须在工程的 background modes 中添加 audio 才会生效
@property (nonatomic, assign) BOOL remoteControlEnabled; // 开启远程控制
@property (nonatomic, strong) UIImage *remoteControlImage; // 远程控制图片
@property (nonatomic, assign) BOOL disablePPTAnimation; // 回放是否禁用动效课件
@property (nonatomic, assign) BJVMajorPlayType majorPlayType; // 主屏播放器内容（视频/ppt）

/**
 裁剪后的回放视频的version
 #discussion  -1: 裁剪后的主版本,  0: 裁剪前的原始视频.
 #discussion 默认 clipedVersion 为 -1
 */
@property (nonatomic, assign) NSInteger clipedVersion;
@property (nonatomic, assign) NSTimeInterval initialPlayTime; // 起始播放时间

/**
 分组, 设置后则返回对应分组的聊天信息
 #discussion 默认 group 为 -1, 即返回所有分组的聊天信息
 */
@property (nonatomic) NSInteger groupID;

/**
 偏好清晰度列表
 
 #discussion 优先使用此列表中的清晰度播放在线视频，优先级按数组元素顺序递减
 #discussion 列表元素为清晰度的标识字符串，现有标识符：low（标清），high（高清），superHD（超清），720p，1080p，audio（纯音频），可根据实际情况动态扩展
 #discussion 此设置对播放本地视频无效
 */
@property (nonatomic, strong) NSArray<NSString *> *preferredDefinitionList;

/**
 第三方用户名和编号
 
 #discussion 用于上报统计
 */
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userNumber;

@end
