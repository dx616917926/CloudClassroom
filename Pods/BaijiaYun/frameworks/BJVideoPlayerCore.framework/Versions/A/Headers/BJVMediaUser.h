//
//  BJVMediaUser.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJVUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJVMediaUser: BJVUser

// 音视频流唯一标识, 单个用户可能推送多路音视频流
@property (nonatomic, readonly) NSString *mediaID;

// 视频源类型
@property (nonatomic, readonly) BJVMediaSource mediaSource;

// 视频在大班课中占据的摄像头位置
@property (nonatomic, readonly) BJVCameraType cameraType;

// 视频开关
@property (nonatomic, readonly) BOOL videoOn;

// 音频开关
@property (nonatomic, readonly) BOOL audioOn;

// 视频画面加载状态
@property (nonatomic, readonly) BOOL isLoading;

@end

NS_ASSUME_NONNULL_END
