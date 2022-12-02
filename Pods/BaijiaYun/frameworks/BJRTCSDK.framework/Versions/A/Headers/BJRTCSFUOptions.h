//
//  SFUSessionOptions.h
//  RTCatSDK
//
//  Created by 辛亚鹏 on 2018/8/8.
//  Copyright © 2018年 xinyapeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <BJRTCSDK/BJRTCDefines.h>

@interface BJRTCStreamProp : NSObject
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) double minBitrate;
@property (nonatomic, assign) double maxBitrate;
@property (nonatomic, assign) int fps;
@property (nonatomic, assign) BOOL enabled;
@end

@interface BJRTCSFUOptions : NSObject

@property (nonatomic, copy) NSString *userNumber;
@property (nonatomic, copy) NSString *area;   //区域
@property (nonatomic, copy) NSString *mediaServerAddress; //媒体服务器地址
@property (nonatomic, copy) NSString *signalingURL;
@property (nonatomic, copy) NSString *protocol;

@property (nonatomic, assign) BOOL enableSimulcast;
@property (nonatomic, assign) BOOL streaAutoStop;
@property (nonatomic, assign) BOOL shouldAutoReconnect;

@property (nonatomic, strong) NSNumber *firPeriod; // 关键帧问讯时间

@property (nonatomic, assign) BOOL isAutoSwitch; // 自动切节点开关

@property (nonatomic, strong) NSMutableArray<NSString *> *thresholds; // 自动切节点相关判定参数

@property (nonatomic, assign) int autoReconnectCountMax;

@property (nonatomic, assign) BJRTCSupportedCodec localCodec;

@property (nonatomic, assign) BOOL isChangePubArea; // 目前仅针对主session的推流切节点

@property (nonatomic, strong) BJRTCStreamProp *smallStreamProp; // 小流参数

+ (instancetype)defaultOptions;
+ (instancetype)defaultOptionsWithSimulcastSwitch:(BOOL)simulcastSwitch;

@end
