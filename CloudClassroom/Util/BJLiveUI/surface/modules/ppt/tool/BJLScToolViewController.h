//
//  BJLScToolViewController.h
//  BJLiveUI
//
//  Created by xyp on 2020/8/19.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLScToolViewController: UIViewController

@property (nonatomic, readonly) BOOL expectedHidden;

@property (nonatomic, nullable) void (^showCoursewareCallback)(void);
@property (nonatomic, nullable) void (^pptButtonClickCallback)(BOOL isSelected);

@property (nonatomic, strong, nullable) void (^countDownTimerCallback)(BJLScToolViewController *vc);
@property (nonatomic, strong, nullable) void (^questionAnswerCallback)(BJLScToolViewController *vc);
@property (nonatomic, strong, nullable) void (^envelopeRainCallback)(BJLScToolViewController *vc);
@property (nonatomic, strong, nullable) void (^rollCallCallback)(BJLScToolViewController *vc);
@property (nonatomic, strong, nullable) void (^questionResponderCallback)(BJLScToolViewController *vc);

- (instancetype)initWithRoom:(BJLRoom *)room;

- (void)removeFromView:(UIView *)removeView
        addToSuperView:(UIView *)superView
      shouldFullScreen:(BOOL)shouldFullScreen;
- (void)updateToolViewHidden:(BOOL)shouldHidden;
- (void)updateToolViewOffset:(CGFloat)offset;
- (BOOL)pptButtonIsSelect;

- (void)showRollCallBadgePoint:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
