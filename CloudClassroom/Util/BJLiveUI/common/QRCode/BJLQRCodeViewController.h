//
//  BJLQRCodeViewController.h
//  BJLiveUI
//
//  Created by xijia dai on 2020/11/12.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/BJLViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLQRCodeViewController: BJLViewController

- (instancetype)initWithQRCodeImage:(UIImage *)image;
@property (nonatomic, nullable) void (^closeCallback)(void);

// 小班课颜色主题适配
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) UIColor *titleColor;
@property (nonatomic) UIColor *tipColor;

@end

NS_ASSUME_NONNULL_END
