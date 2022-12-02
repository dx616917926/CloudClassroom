//
//  BJVCloudVideoPlayerProtocol.h
//  BJVideoPlayerCore
//
//  Created by ney on 2022/4/1.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJVCloudVideoPlayerProtocol <NSObject>
@required

/** 是否静音 */
@property (nonatomic, assign) BOOL mute;

/** 云插播的控制器 */
@property (nonatomic, readonly, nullable) UIView *playerView;

/** 视频的尺寸 */
@property (nonatomic, assign, readonly) CGSize videoSize;

/** 播放 */
- (void)play;

/** 暂停 */
- (void)pause;
@end

NS_ASSUME_NONNULL_END
