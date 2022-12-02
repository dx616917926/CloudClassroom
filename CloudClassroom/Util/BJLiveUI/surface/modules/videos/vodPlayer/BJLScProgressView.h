//
//  BJLScProgressView.h
//  BJLiveUI
//
//  Created by 辛亚鹏 on 2021/7/20.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//
//  进度条view

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScProgressView: UIView

@property (nonatomic, readonly) UISlider *slider;

- (void)updateCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
