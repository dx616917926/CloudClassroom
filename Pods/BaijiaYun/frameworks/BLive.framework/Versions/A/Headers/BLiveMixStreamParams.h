//
//  BLiveMixStreamParams.h
//  BLive
//
//  Created by xijia dai on 2022/2/24.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BLiveDef.h"

NS_ASSUME_NONNULL_BEGIN

@class BLiveMixStreamCell, BLiveMixStreamCanvas;

@interface BLiveMixStreamParams: NSObject

/// ID 为空将创建新的合流，否则，更新目标混流的信息
@property (nonatomic, nullable) NSString *taskID;
/// 合流布局模式，默认为画廊布局
@property (nonatomic) BLiveMixStreamMode mode;
/// 仅单路视频流是是否强制转码合流，默认 NO
@property (nonatomic) BOOL forceMix;
/// 合流的整体视频设置，默认为 BLiveMixStreamCanvas 初始值
@property (nonatomic, nullable) BLiveMixStreamCanvas *canvas;
/// 合流中单路流的视频窗口位置、大小等设置，默认为空数组
@property (nonatomic, nullable) NSArray<BLiveMixStreamCell *> *cells;

@end

@interface BLiveMixStreamCanvas: NSObject

/// 合流的视频宽高，默认 1280 * 720
@property (nonatomic) NSInteger width, height;
/// 合流视频是否是竖屏，默认 NO
@property (nonatomic) BOOL isPortrait;
/// 合流视频的背景色，默认黑色 "#000000"
@property (nonatomic) NSString *colorString;
/// 合流视频的显示模式，默认 BLiveContentMode_aspectFit
@property (nonatomic) BLiveContentMode fitMode;
/// 编码格式，默认 BLiveStreamCodec_h264
@property (nonatomic) BLiveStreamCodec codec;
/// 是否固定每一帧的质量，默认 YES
@property (nonatomic) BOOL useQp;
/// 视频码率，单位 bit，默认 1000 bit
@property (nonatomic) NSInteger bitrate;
/// 视频帧率，单位帧每秒，默认 15 帧每秒
@property (nonatomic) NSInteger fps;
/// 关键帧间隔，单位秒，默认 2 秒
@property (nonatomic) NSInteger gop;

@end

@interface BLiveMixStreamCell: NSObject

/// 单路流所属的用户 ID，默认为空，需要设置
@property (nonatomic) NSString *userID;
/// 单路流的在合流视频中起始位置，默认为 0
@property (nonatomic) NSInteger originX, originY;
/// 单路流的尺寸，默认 640 * 480
@property (nonatomic) NSInteger width, height;
/// 单路流的层次优先级，默认为 0
@property (nonatomic) NSInteger zOrder;
/// 单路流的显示模式，默认 BLiveContentMode_aspectFit
@property (nonatomic) BLiveContentMode fitMode;
/// 单路流的视频背景色，默认黑色 "#000000"
@property (nonatomic) NSString *colorString;
// 流类型，默认 BLiveStreamType_vloud
@property (nonatomic) BLiveStreamType type;

@end

NS_ASSUME_NONNULL_END
