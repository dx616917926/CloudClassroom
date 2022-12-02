//
//  BJLMediaUser.h
//  BJLiveCore
//
//  Created by HuangJie on 2019/3/21.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    BOOL autoPlay;
    NSInteger definitionIndex;
} BJLAutoPlayVideo;

static inline BJLAutoPlayVideo BJLAutoPlayVideoMake(BOOL autoPlay, NSInteger definitionIndex) {
    return (BJLAutoPlayVideo){.autoPlay = autoPlay, .definitionIndex = definitionIndex};
}

@interface BJLMediaUser: BJLUser

// 音视频流唯一标识, 单个用户可能推送多路音视频流
@property (nonatomic, readonly) NSString *mediaID;

// 视频源类型
@property (nonatomic, readonly) BJLMediaSource mediaSource;

// 视频在大班课中占据的摄像头位置
@property (nonatomic, readonly) BJLCameraType cameraType;

// 视频开关
@property (nonatomic, readonly) BOOL videoOn;

// 音频开关
@property (nonatomic, readonly) BOOL audioOn;

// 视频画面加载状态
@property (nonatomic, readonly) BOOL isLoading;

// 参考 `BJLLiveDefinitionKey`、`BJLLiveDefinitionNameForKey()`
@property (nonatomic, readonly) NSArray<BJLLiveDefinitionKey> *definitions;

- (BOOL)isSameCameraUser:(__kindof BJLMediaUser *)user;

- (BOOL)isSameMediaUser:(__kindof BJLMediaUser *)user;

- (BOOL)containedInMediaUsers:(NSArray<BJLMediaUser *> *)mediaUsers;

@end

NS_ASSUME_NONNULL_END
