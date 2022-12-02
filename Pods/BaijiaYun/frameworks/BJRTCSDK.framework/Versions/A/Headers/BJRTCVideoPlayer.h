//
//  BJRTCVideoPlayer.h
//  BJRTCSDK
//
//  Created by Chengchao on 8/9/18.
//  Copyright © 2018 xinyapeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//
typedef NS_ENUM(NSUInteger, BJRTCVideoGravity) {
    /// 保持纵横比; 填充图层边界。等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪 这个不会有黑边 会裁剪
    BJRTCVideoGravity_AspectFill                = 0,
    /// 保持纵横比; 适合图层范围。等比例填充，直到一个维度到达区域边界 这个有黑边 不会裁剪
    BJRTCVideoGravity_AspectFit                 = 1,
    /// 拉伸以填充图层边界，非均匀模式。两个维度完全填充至整个视图区域
    BJRTCVideoGravity_ScaleToFill               = 2,
};

/**
 *
 */
typedef NS_ENUM(NSUInteger, BJRTCVideoPlayerType) {
    /**
     *  本地视频流播放器
     */
    BJRTC_LOCAL_VIDEO_PLAYER,
    /**
     *  远程视频流播放器
     */
    BJRTC_REMOTE_VIDEO_PLAYER
    
};

@class BJRTCVideoPlayer;

/**
 * BJRTCVideoPlayer delegate
 */
@protocol BJRTCVideoPlayerDelegate <NSObject>

@optional;
/// 播放器Size调整
- (void)videoPlayer:(BJRTCVideoPlayer *)videoPlayer didChangeVideoSize:(CGSize)size;
///
- (void)firstFrameRenderedOnVideoPlayer:(BJRTCVideoPlayer *)videoPlayer;

@end

/// 视频播放器
@interface BJRTCVideoPlayer: NSObject

/**
 *  初始化播放器
 *
 *  @param frame CGRect
 *
 *  @return BJRTCVideoPlayer
 */
- (instancetype)initWithFrame:(CGRect)frame;


/**
 *  初始化播放器
 *  默认为远程视频播放器
 *  @param frame CGRect
 *  @param type  VideoPlayerType
 *  @return BJRTCVideoPlayer
 *
 */
- (instancetype)initWithFrame:(CGRect)frame type:(BJRTCVideoPlayerType)type;


/**
 *  播放器的 video
 */
@property (nonatomic, strong) UIView *view;
/**
 *  播放器的 delegate
 */
@property (nonatomic, weak) id<BJRTCVideoPlayerDelegate> delegate;

@property (nonatomic, copy) NSString *sessionID;

@property (nonatomic, copy) NSString *userID;

/// 播放器的 type
@property (nonatomic, readonly) BJRTCVideoPlayerType type;
/// remote stream才有
@property (nonatomic, readonly) CGSize videoDimensions;

@property (nonatomic, assign) BJRTCVideoGravity videoGravity;

@end
