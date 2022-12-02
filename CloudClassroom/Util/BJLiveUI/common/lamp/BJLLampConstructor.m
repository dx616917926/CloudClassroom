//
//  BJLLampUpdate.m
//  BJLiveUIBigClass
//
//  Created by lwl on 2021/9/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLLampConstructor.h"

@interface BJLLampConstructor ()

@property (nonatomic, readwrite) BJLLamp *lamp;
@property (nonatomic, readwrite, weak) UIView *lampView;
@property (nonatomic, readwrite) NSString *lampContent;
@property (nonatomic, readwrite) CGFloat containerViewWidth;
@property (nonatomic, readwrite) CGFloat containerViewHeight;
@property (nonatomic, readwrite) UILabel *lampLabel;
@property (nonatomic, readwrite) UILabel *lampLabelTwo;
@property (nonatomic, readwrite) CGSize labelSize;
@property (nonatomic, readwrite) CGFloat verticalRatio;
@property (nonatomic, readwrite) CGFloat horizontalRatio;
@property (nonatomic, readwrite) CGFloat verticalRatioTwo;
@property (nonatomic, readwrite) CGFloat horizontalRatioTwo;
// 用于移除lampLabel而增加的两个属性
@property (nonatomic, readwrite) UILabel *removeingLampLabel;
@property (nonatomic, readwrite) UILabel *removeingLampLabelTwo;

@end

@implementation BJLLampConstructor

- (void)updateLampWithLamp:(nullable BJLLamp *)lamp
                  lampView:(UIView *)lampView
               lampContent:(NSString *)lampContent
        containerViewWidth:(CGFloat)containerViewWidth
       containerViewHeight:(CGFloat)containerViewHeight {
    self.lamp = lamp;
    self.lampView = lampView;
    self.lampContent = lampContent;
    self.containerViewWidth = containerViewWidth;
    self.containerViewHeight = containerViewHeight;
    if (self.lamp.displayMode == BJLLampDisplayModeRoll) {
        [self updateLampInRoll];
    }
    else if (self.lamp.displayMode == BJLLampDisplayModeBlink) {
        [self updateLampInBlink];
    }
}

- (void)updateLampInRoll {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    if (!self.lampView) {
        return;
    }
    [self makeLamp];
    [self.lampLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.lampView.bjl_left).offset(self.labelSize.width + self.containerViewWidth);
        make.bottom.equalTo(self.lampView).multipliedBy(self.verticalRatio);
        make.size.equal.sizeOffset(self.labelSize);
    }];
    [self.lampView layoutIfNeeded];
    // animation
    CGFloat speed = 30.0; // 跑马灯速度
    NSTimeInterval duration = (self.labelSize.width + self.containerViewWidth) / speed;
    self.removeingLampLabel = self.lampLabel;
    bjl_weakify(self);
    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveLinear
        animations:^{
            bjl_strongify(self);
            // 设置动画结束后的最终位置
            [self.lampLabel bjl_updateConstraints:^(BJLConstraintMaker *make) {
                make.right.equalTo(self.lampView.bjl_left);
            }];
            [self.lampView layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            [self.lampLabel removeFromSuperview];
        }];

    // 第二个跑马灯
    if (self.lamp.count == 2) {
        [self.lampLabelTwo bjl_makeConstraints:^(BJLConstraintMaker *make) {
            // 第二个跑马灯比第一个跑马灯慢 60 的距离
            make.right.equalTo(self.lampView.bjl_left).offset(self.labelSize.width + self.containerViewWidth + 60);
            make.bottom.equalTo(self.lampView).multipliedBy(self.verticalRatioTwo);
            make.size.equal.sizeOffset(self.labelSize);
        }];
        [self.lampView layoutIfNeeded];
        self.removeingLampLabelTwo = self.lampLabelTwo;
        bjl_weakify(self);
        [UIView animateWithDuration:duration
            delay:0.0
            options:UIViewAnimationOptionCurveLinear
            animations:^{
                bjl_strongify(self);
                // 设置动画结束后的最终位置
                [self.lampLabelTwo bjl_updateConstraints:^(BJLConstraintMaker *make) {
                    make.right.equalTo(self.lampView.bjl_left);
                }];
                [self.lampView layoutIfNeeded];
            }
            completion:^(BOOL finished) {
                [self.lampLabelTwo removeFromSuperview];
            }];
        // 因为慢 60 距离，增加 2 秒
        duration += 2;
    }
    // 显示间隔
    [self performSelector:_cmd withObject:nil afterDelay:(duration + self.lamp.rollDuration)];
}

- (void)updateLampInBlink {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    if (!self.lampView) {
        return;
    }
    [self makeLamp];
    [self.lampLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.right.equalTo(self.lampView).multipliedBy(self.horizontalRatio);
        make.bottom.equalTo(self.lampView).multipliedBy(self.verticalRatio);
        make.size.equal.sizeOffset(self.labelSize);
    }];
    [self.lampView layoutIfNeeded];
    NSTimeInterval duration = self.lamp.blinkDuration;
    // 第二个跑马灯
    if (self.lamp.count == 2) {
        [self.lampLabelTwo bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.right.equalTo(self.lampView).multipliedBy(self.horizontalRatioTwo);
            make.bottom.equalTo(self.lampView).multipliedBy(self.verticalRatioTwo);
            make.size.equal.sizeOffset(self.labelSize);
        }];
        [self.lampView layoutIfNeeded];
    }
    // 定义局部变量，才能正确执行 removeFromSuperview 方法
    UILabel *lampLabel = self.lampLabel;
    UILabel *lampLabelTwo = self.lampLabelTwo;
    self.removeingLampLabel = self.lampLabel;
    self.removeingLampLabelTwo = self.lampLabelTwo;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [lampLabel removeFromSuperview];
        if (lampLabelTwo) {
            [lampLabelTwo removeFromSuperview];
        }
        [self.lampView layoutIfNeeded];
    });
    // 显示间隔
    [self performSelector:_cmd withObject:nil afterDelay:(duration + 0.2)];
}

- (void)makeLamp {
    // lampLabel
    self.lampLabel = [self makeLampLabel];
    // 文字边距
    self.labelSize = CGSizeMake(CGRectGetWidth(self.lampLabel.bounds) + 20.0, CGRectGetHeight(self.lampLabel.bounds) + 10.0);
    CGFloat minVerticalRatio = 0;
    if (self.containerViewHeight > 0) {
        minVerticalRatio = self.labelSize.height / (self.containerViewHeight);
    }
    NSInteger tempV = ceil(minVerticalRatio * 1000);
    // 垂直方向位置比例，产生从 垂直方向最小比例（精确到小数点后 3 位） 到 1 之间的一个随机比例，确定跑马灯的垂直方向的位置
    self.verticalRatio = ((arc4random() % (1000 - tempV)) + tempV) / 1000.0;
    CGFloat minHorizontalRatio = 0;
    if (self.containerViewWidth > 0) {
        minHorizontalRatio = self.labelSize.width / (self.containerViewWidth);
    }
    NSInteger tempH = ceil(minHorizontalRatio * 1000);
    // 水平方向位置比例，产生从 垂直方向最小比例（精确到小数点后 3 位） 到 1 之间的一个随机比例，确定跑马灯的水平方向的位置
    self.horizontalRatio = ((arc4random() % (1000 - tempH)) + tempH) / 1000.0;
    [self.lampView addSubview:self.lampLabel];

    if (self.lamp.count == 2) {
        self.lampLabelTwo = [self makeLampLabel];
        self.horizontalRatioTwo = ((arc4random() % (1000 - tempH)) + tempH) / 1000.0;
        self.verticalRatioTwo = ((arc4random() % (1000 - tempV)) + tempV) / 1000.0;
        // 避免极端情况陷入死循环
        int avoidDeadCirculation = 0;
        // 避免两个跑马灯有重叠
        while (((self.verticalRatioTwo < self.verticalRatio && self.verticalRatioTwo + minVerticalRatio >= self.verticalRatio)
                   || (self.verticalRatio <= self.verticalRatioTwo && self.verticalRatio + minVerticalRatio >= self.verticalRatioTwo))
               && avoidDeadCirculation < 10) {
            self.verticalRatioTwo = ((arc4random() % (1000 - tempV)) + tempV) / 1000.0;
            avoidDeadCirculation++;
        }
        [self.lampView addSubview:self.lampLabelTwo];
    }
}

- (UILabel *)makeLampLabel {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor bjl_colorWithHexString:self.lamp.backgroundColor alpha:self.lamp.backgroundAlpha];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 1.0;
    label.font = (self.lamp.isBold
                      ? [UIFont boldSystemFontOfSize:self.lamp.fontSize]
                      : [UIFont systemFontOfSize:self.lamp.fontSize]);
    label.textColor = [UIColor bjl_colorWithHexString:self.lamp.color alpha:self.lamp.alpha];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.lampContent;
    label.numberOfLines = 1;
    [label sizeToFit];
    label.userInteractionEnabled = NO;
    return label;
}

- (void)destoryLampLabel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.removeingLampLabel removeFromSuperview];
    if (self.removeingLampLabelTwo) {
        [self.removeingLampLabelTwo removeFromSuperview];
    }
}

@end
