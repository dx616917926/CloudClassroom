//
//  BJYRoomOptions.h
//  BJYRTCEngine
//
//  Created by lw0717 on 2018/12/28.
//  Copyright © 2018年 BaiJiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLIve/BLive.h>
#import "BJYRTCEngineDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJYRoomOptions : NSObject

/// 引擎类型
@property (nonatomic, assign) BJYEngineType engineType;
// 是否使用 BLive 接口
@property (nonatomic) BOOL useBLive;
// BLive 角色，默认观众
@property (nonatomic) BLiveRoleType roleType;
/// 房间标识
@property (nonatomic, copy) NSString *roomID;
/// 用户标识 音视频用来区分user的
@property (nonatomic, copy) NSString *userID;
/// 用户昵称 日志上报时使用
@property (nonatomic, copy) NSString *userName;
/// 用户标识 要分辨userID对应那个人时使用 同一节课同一user情况下 userNumber不变
@property (nonatomic, copy) NSString *userNumber;
/// 初始摄像头位置，默认前置摄像头
@property (nonatomic, assign) BJYCameraFace cameFace;

/// 视频分辨率 初始化房间使用的分辨率 进房间后失效
@property (nonatomic, assign) BJYVideoResolution resolution;

/// 小流分辨率，进房间后设置无效
@property (nonatomic, assign) BJYVideoResolution lowResolution;

/// 音量变化回调开关
@property (nonatomic, assign) BOOL volumeSwitch;

/// 是否开启debug模式，打印底层日志
@property (nonatomic, assign) BOOL isDebug;

/// 声网APPID
@property (nonatomic, copy) NSString *agora_appID;  // todo: 冗余项，可以合并成一个

/// 百家云信令服务器地址
@property (nonatomic, copy) NSString *bjy_signalServer;
/// 服务器效果不理想，目前不建议开启
@property (nonatomic, assign) BOOL bjy_simulcast;
/// 百家云视频编码
@property (nonatomic, assign) BJYVideoSupportedCodec bjy_codec;
/// 百家云webRTCInfo
@property (nonatomic, strong) NSDictionary *bjy_webRTCInfo;

/// 腾讯云APPID
@property (nonatomic, copy) NSString *trtc_appID; // todo: 冗余项，可以合并成一个

/// 卡顿相关配置项
@property (nonatomic, strong) NSArray *blockThresholdInfo;


/// todo : BRTC sign 实验用，后续需删除
@property (nonatomic, strong) NSString *sign;

/// 是否本地处理推流角度 
@property (nonatomic, assign) BOOL close_cvo;

/// 使用brtc区分环境使用
@property (nonatomic, copy) NSString *brtc_domain;

@property (nonatomic, copy) NSString *brtc_comments;

@end

NS_ASSUME_NONNULL_END
