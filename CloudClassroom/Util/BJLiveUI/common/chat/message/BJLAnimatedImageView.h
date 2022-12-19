//
//  BJLAnimatedImageView.h
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/12/9.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BJLAnimatedImage;
@protocol BJLAnimatedImageViewDebugDelegate;

//
//  An `BJLAnimatedImageView` can take an `BJLAnimatedImage` and plays it automatically when in view hierarchy and stops when removed.
//  The animation can also be controlled with the `UIImageView` methods `-start/stop/isAnimating`.
//  It is a fully compatible `UIImageView` subclass and can be used as a drop-in component to work with existing code paths expecting to display a `UIImage`.
//  Under the hood it uses a `CADisplayLink` for playback, which can be inspected with `currentFrame` & `currentFrameIndex`.
//
@interface BJLAnimatedImageView: UIImageView

// Setting `[UIImageView.image]` to a non-`nil` value clears out existing `animatedImage`.
// And vice versa, setting `animatedImage` will initially populate the `[UIImageView.image]` to its `posterImage` and then start animating and hold `currentFrame`.
@property (nonatomic, strong) BJLAnimatedImage *animatedImage;
@property (nonatomic, copy) void (^loopCompletionBlock)(NSUInteger loopCountRemaining);

@property (nonatomic, strong, readonly) UIImage *currentFrame;
@property (nonatomic, assign, readonly) NSUInteger currentFrameIndex;

// The animation runloop mode. Enables playback during scrolling by allowing timer events (i.e. animation) with NSRunLoopCommonModes.
// To keep scrolling smooth on single-core devices such as iPhone 3GS/4 and iPod Touch 4th gen, the default run loop mode is NSDefaultRunLoopMode. Otherwise, the default is NSDefaultRunLoopMode.
@property (nonatomic, copy) NSRunLoopMode runLoopMode;

@end