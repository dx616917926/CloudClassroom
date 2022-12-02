//
//  BJLQRCodeViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2020/11/12.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLQRCodeViewController.h"
#import "BJLWindowTopBar.h"
#import "BJLAppearance.h"

@interface BJLQRCodeViewController ()

@property (nonatomic) UIImage *QRCodeImage;

@end

@implementation BJLQRCodeViewController

- (instancetype)initWithQRCodeImage:(UIImage *)image {
    if (self = [super init]) {
        self.QRCodeImage = image;
        self.backgroundColor = BJLTheme.windowBackgroundColor;
        self.titleColor = BJLTheme.viewTextColor;
        self.lineColor = BJLTheme.separateLineColor;
        self.tipColor = BJLTheme.viewSubTextColor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
}

- (void)setupSubViews {
    self.view.backgroundColor = self.backgroundColor;
    self.view.layer.shadowColor = BJLTheme.windowShadowColor.CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowRadius = 5.0;
    self.view.layer.shadowOpacity = 0.3;

    // top bar
    UIView *topBar = [UIView new];
    [self.view addSubview:topBar];
    [topBar bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@32.0);
    }];

    UILabel *titleLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = @"titleLabel";
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = self.titleColor;
        label.font = [UIFont systemFontOfSize:14];
        label.text = BJLLocalizedString(@"扫码视频直播");
        label;
    });
    [topBar addSubview:titleLabel];
    [titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(topBar).offset(10.0);
        make.top.bottom.equalTo(topBar);
    }];

    UIButton *closeButton = ({
        UIButton *button = [UIButton new];
        [button setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [topBar addSubview:closeButton];
    [closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(topBar).offset(-10.0);
        make.top.bottom.equalTo(topBar);
        make.width.equalTo(topBar.bjl_height);
    }];

    UIView *topGapLine = ({
        UIView *view = [BJLHitTestView new];
        view.backgroundColor = self.lineColor;
        bjl_return view;
    });
    [topBar addSubview:topGapLine];
    [topGapLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.left.right.equalTo(topBar);
        make.height.equalTo(@(BJLScOnePixel));
    }];

    // content view
    UIView *contentView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = @"contentView";
        view;
    });
    [self.view addSubview:contentView];
    [contentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(topBar.bjl_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];

    UIImageView *imageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.QRCodeImage];
        imageView.accessibilityIdentifier = @"imageView";
        imageView;
    });
    [contentView addSubview:imageView];
    [imageView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(contentView);
        make.centerY.equalTo(contentView).offset(-15.0);
        make.width.height.equalTo(@200.0);
    }];

    UILabel *tipLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = @"tipLabel";
        label.textColor = self.tipColor;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = BJLLocalizedString(@"请使用云端课堂APP扫码直播");
        label;
    });
    [contentView addSubview:tipLabel];
    [tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(imageView.bjl_bottom).offset(20);
        make.bottom.lessThanOrEqualTo(contentView).offset(-10.0);
    }];
}

- (void)close {
    if (self.closeCallback) {
        self.closeCallback();
    }
    [self bjl_removeFromParentViewControllerAndSuperiew];
}

@end
