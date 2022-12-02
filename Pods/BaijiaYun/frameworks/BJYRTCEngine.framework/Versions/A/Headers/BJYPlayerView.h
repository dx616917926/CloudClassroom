//
//  BJYPlayerView.h
//  BJYRTCEngine
//
//  Created by bjy on 2018/11/1.
//  Copyright © 2018 BaiJiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJYRTCEngineDefines.h"

//
typedef NS_ENUM(NSUInteger, BJYRTCVideoGravity) {
    /// 保持纵横比; 填充图层边界。等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪 这个不会有黑边 会裁剪
    BJYRTCVideoGravity_AspectFill               = 0,
    /// 保持纵横比; 适合图层范围。等比例填充，直到一个维度到达区域边界 这个有黑边 不会裁剪
    BJYRTCVideoGravity_AspectFit                = 1,
    /// 拉伸以填充图层边界，非均匀模式。两个维度完全填充至整个视图区域
    BJYRTCVideoGravity_ScaleToFill              = 2,
};

@class BJYPlayerView;

@protocol BJYPlayerViewDelegate <NSObject>

- (void)playerView:(BJYPlayerView *)playerView didChangeSize:(CGSize)size at:(BJYRTCSessionType)sessionType;

@end

@interface BJYPlayerView : UIView

@property (nonatomic, weak) id<BJYPlayerViewDelegate> delegate;

@property (nonatomic, readonly) NSString *sessionID;
@property (nonatomic, readonly) NSString *userID;

@property (nonatomic, readonly) CGSize videoDimensions;

@property (nonatomic, assign) BJYRTCVideoGravity videoGravity;

@end
