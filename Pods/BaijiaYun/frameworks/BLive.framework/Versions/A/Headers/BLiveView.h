//
//  BLiveView.h
//  BLive
//
//  Created by xijia dai on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase.h>
#import <Foundation/Foundation.h>

#import "BLiveDef.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BLiveViewState) {
    BLiveViewState_unload,
    BLiveViewState_loading,
    BLiveViewState_stalled,
    BLiveViewState_ready,
    BLiveViewState_playing,
    BLiveViewState_paused,
    BLiveViewState_failed,
    BLiveViewState_reachEnd,
    BLiveViewState_stopped
};

@interface BLiveView: UIView

/// 当前播放视图所关联的合流信息
@property (nonatomic, nullable) NSArray<BLiveMixStreamDefinitionInfo *> *mixStreamInfo;

/// 尺寸变化回调
@property (nonatomic, copy) void (^playerSizeChangeCallback)(CGSize size);

/// 设置缓存最大延迟时间
- (void)setMaxBufferTime:(int)maxBufferTime;
- (int)getMaxBufferTime;

/// 设置显示模式
- (void)setScalingMode:(BLiveContentMode)scalingMode;

/// 停止播放，清理播放视图
- (void)clear;

@end

NS_ASSUME_NONNULL_END
