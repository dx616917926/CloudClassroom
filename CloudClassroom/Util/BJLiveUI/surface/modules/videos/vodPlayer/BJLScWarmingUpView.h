//
//  BJLScWarmingUpView.h
//  BJLiveUI
//
//  Created by 辛亚鹏 on 2021/7/20.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//
//  暖场的点播视频, 使用 BJYIJKPlayer 播放点播视频

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLiveCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScWarmingUpView: UIView

- (instancetype)initWithList:(NSArray *)list isLoop:(BOOL)isLoop room:(BJLRoom *)room NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@property (nonatomic, nullable, copy) void (^scaleCallback)(BOOL shoudFullScreen);

- (void)updateView:(BOOL)isFullScreen;

@end

NS_ASSUME_NONNULL_END
