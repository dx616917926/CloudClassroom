//
//  BJLScMediaControlView.h
//  BJLiveCore
//
//  Created by 辛亚鹏 on 2021/7/20.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//
//  时间 进度条 播放/暂停 全屏

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScMediaControlView: UIView

@property (nonatomic, nullable, copy) void (^playCallback)(BOOL shouldPlay);
@property (nonatomic, nullable, copy) void (^scaleCallback)(BOOL shoudFullScreen);
@property (nonatomic, nullable, copy) void (^mediaSeekCallback)(NSTimeInterval toTime);

- (void)updateCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
- (void)updateScaleButtonSelected:(BOOL)isSelected;
- (void)updatePlayButtonSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
