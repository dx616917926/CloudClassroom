//
//  BJLScCommandLotteryView.m
//  BJLiveUI
//
//  Created by xyp on 2020/8/28.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLScCommandLotteryView.h"
#import "BJLScAppearance.h"

@interface BJLScCommandLotteryView ()

@property (nonatomic, readwrite) CGSize expectSize;

@end

@implementation BJLScCommandLotteryView

- (instancetype)initWithCommand:(NSString *)command {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self makeSubviews:command];
    }
    return self;
}

- (void)makeSubviews:(NSString *)command {
    self.backgroundColor = BJLTheme.windowBackgroundColor;

    self.layer.shadowOpacity = 0.8;
    self.layer.shadowColor = BJLTheme.windowShadowColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowRadius = 2.0;

    self.layer.borderColor = BJLTheme.separateLineColor.CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 4.0;

    UILabel *tipLabel = [UILabel new];
    tipLabel.textColor = BJLTheme.viewSubTextColor;
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.text = BJLLocalizedString(@"点击输入口令");

    UIView *line = [UIView new];
    line.backgroundColor = BJLTheme.separateLineColor;

    UILabel *commandLabel = [UILabel new];
    commandLabel.numberOfLines = 3.0;
    commandLabel.font = [UIFont systemFontOfSize:14];
    commandLabel.textColor = BJLTheme.brandColor;
    commandLabel.text = command;

    [self addSubview:tipLabel];
    [self addSubview:line];
    [self addSubview:commandLabel];

    CGSize tipSize = [self bjl_suitableSizeWithText:tipLabel.text attributedText:nil maxWidth:100];
    CGSize commandSize = [self bjl_suitableSizeWithText:commandLabel.text attributedText:nil maxWidth:100];

    [tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.top.right.equalTo(self).inset(5);
        make.width.equalTo(@(tipSize.width));
        make.height.equalTo(@20);
    }];

    [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(tipLabel);
        make.bottom.equalTo(tipLabel.bjl_bottom).offset(3);
        make.height.equalTo(@1);
    }];

    [commandLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(line.bjl_bottom);
        make.left.equalTo(tipLabel);
        make.right.equalTo(tipLabel).offset(-5);
        make.height.equalTo(@(commandSize.height + 5));
        //        make.bottom.equalTo(self).offset(-5);
    }];

    CGFloat w = tipSize.width;
    CGFloat h = 20 + 1 + 5 + commandSize.height + 25;
    self.expectSize = CGSizeMake(w, h);
}

@end

#pragma mark -

@interface BJLScCommandCountDownView ()

@property (nonatomic) UILabel *countdownLabel;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger duration;

@end

@implementation BJLScCommandCountDownView

- (instancetype)initWithDuration:(NSInteger)duration {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.duration = duration;
        [self makeSubviews];
        [self makeTimer];
    }
    return self;
}

- (void)destory {
    if (self.timer || self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)makeSubviews {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_sc_lottery_countdown"]];
    [self addSubview:imageView];

    self.countdownLabel = ({
        UILabel *label = [UILabel new];
        label.text = [NSString stringWithFormat:@"%td", self.duration];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        label;
    });
    [self addSubview:self.countdownLabel];

    [imageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self);
    }];
    [self.countdownLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.bjl_centerY);
    }];
}

- (void)makeTimer {
    bjl_weakify(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *_Nonnull timer) {
        bjl_strongify(self);
        self.duration--;
        if (self.duration > 0) {
            self.countdownLabel.text = [NSString stringWithFormat:@"%td", self.duration];
        }
        else {
            [self destory];
            if (self.countOverCallback) {
                self.countOverCallback();
            }
        }
    }];
}

@end