//
//  BJLQRCodeScanner.m
//  BJLiveUI
//
//  Created by xijia dai on 2020/10/29.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLQRCodeScanner.h"
#import "BJLAppearance.h"

@interface BJLQRCodeScanner () <AVCaptureMetadataOutputObjectsDelegate>

// scan
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic) AVCaptureDeviceInput *input;
@property (nonatomic) AVCaptureMetadataOutput *output;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic) BOOL enableOutputData;

// view
@property (nonatomic) UIView *scannerView, *scannerBorder, *scannerLine, *scannerGrid;
@property (nonatomic) UIView *warningView;

@end

@implementation BJLQRCodeScanner

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bjl_hidesNavigationBarWhenPushed = YES;
    [self makeSubviewsAndConstraints];
    [self addNotify];
}

- (void)dealloc {
    [self removeNotify];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)makeSubviewsAndConstraints {
    self.view.backgroundColor = [UIColor bjl_colorWithHexString:@"#313847"];
    UIButton *backButton = ({
        UIButton *button = [UIButton new];
        [button setImage:[UIImage bjl_imageNamed:@"bjl_scanner_back"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:backButton];
    [backButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(20.0);
        make.top.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(20.0);
        make.width.height.equalTo(@32.0);
    }];

    [self makeScannerView];
    [self makeTipView];

    [BJLAuthorization checkCameraAccessAndRequest:YES callback:^(BOOL granted, UIAlertController *_Nullable alert) {
        if (granted) {
            [self makeScanner];
            if (self && self.view && self.view.window) {
                [self startScan];
            }
        }
        else if (alert) {
            if (self.presentedViewController) {
                [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
            }
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    } completion:nil];
}

- (void)makeScannerView {
    UIImageView *scannerBorder = [self imageViewWithName:@"bjl_scanner_border"];
    scannerBorder.clipsToBounds = YES;
    // 改变约束后触发 layout 实现动画效果
    UIView *scannerView = [BJLHitTestView new];
    UIImageView *scannerGrid = [self imageViewWithName:@"bjl_scanner_grid"];
    scannerGrid.contentMode = UIViewContentModeScaleAspectFill;
    UIImageView *scannerLine = [self imageViewWithName:@"bjl_scanner_line"];

    [self.view addSubview:scannerBorder];
    [scannerBorder addSubview:scannerView];
    [scannerView addSubview:scannerGrid];
    [scannerView addSubview:scannerLine];
    [scannerBorder bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        BOOL iphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        make.center.equalTo(self.view);
        make.width.height.equalTo(iphone ? @244.0 : @368.0);
    }];
    [scannerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(scannerBorder);
    }];
    [scannerGrid bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.width.height.equalTo(scannerView);
        make.bottom.equalTo(scannerView.bjl_top);
    }];
    [scannerLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(scannerView);
        make.bottom.equalTo(scannerView.bjl_top);
        make.height.equalTo(@6.0);
    }];
    [scannerView layoutIfNeeded];
    self.scannerBorder = scannerBorder;
    self.scannerView = scannerView;
    self.scannerLine = scannerLine;
    self.scannerGrid = scannerGrid;

    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(scannerBorder, bounds)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (CGRectIsEmpty(scannerBorder.frame)
                 || CGRectIsNull(scannerBorder.frame)
                 || CGRectIsInfinite(scannerBorder.frame)) {
                 return YES;
             }
             [self restartScanAnimation];
             return NO;
         }];
}

- (void)restartScanAnimation {
    self.scannerView.transform = CGAffineTransformIdentity;
    CGFloat transFormY = CGRectGetHeight(self.scannerBorder.frame);
    [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.scannerView.transform = CGAffineTransformMakeTranslation(0, transFormY);
    } completion:^(BOOL finished) {
        [self restartScanAnimation];
    }];
}

- (void)makeTipView {
    UILabel *tipLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"支持扫码开启视频直播或扫码进直播间");
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor bjl_colorWithHexString:@"#333333"];
        label;
    });
    UIView *backgroundView = ({
        UIView *view = [UIView new];
        view.layer.cornerRadius = 18.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    [self.view addSubview:backgroundView];
    [backgroundView addSubview:tipLabel];
    [tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(backgroundView).insets(UIEdgeInsetsMake(0, 18.0, 0, 18.0));
    }];
    [backgroundView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(-27.0);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@36.0);
    }];
}

- (void)makeWarningView {
    if (self.warningView) {
        return;
    }

    UILabel *label = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"暂无法识别，请扫描云端课堂二维码");
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label;
    });
    self.warningView = ({
        UIView *view = [UIView new];
        view.layer.cornerRadius = 18.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        view;
    });
    [self.view addSubview:self.warningView];
    [self.warningView addSubview:label];
    [label bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.warningView).insets(UIEdgeInsetsMake(0, 18.0, 0, 18.0));
    }];
    [self.warningView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.scannerBorder.bjl_bottom).offset(15.0);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@36.0);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self startScan];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.enableOutputData = YES;
    });
}

#pragma mark - focus

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];

    if (self.session.running) {
        [self focus:point];
    }
}

- (void)focus:(CGPoint)aPoint {
    AVCaptureDevice *device = self.device;
    if ([device isFocusPointOfInterestSupported] &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        CGFloat focus_x = aPoint.x / screenWidth;
        CGFloat focus_y = aPoint.y / screenHeight;
        if ([device lockForConfiguration:nil]) {
            [device setFocusPointOfInterest:CGPointMake(focus_x, focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark -

- (void)hide {
    UINavigationController *navigation = [self.parentViewController bjl_as:[UINavigationController class]];
    BOOL isRoot = (navigation
                   && self == navigation.topViewController
                   && self == navigation.bjl_rootViewController);
    UIViewController *outermost = isRoot ? navigation : self;

    // pop
    if (navigation && !isRoot) {
        [navigation bjl_popViewControllerAnimated:YES completion:nil];
    }
    // dismiss
    else if (!outermost.parentViewController && outermost.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)hideWarningView {
    self.warningView.hidden = YES;
}

- (void)makeScanner {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {
        NSLog(@"creat input error %@", error);
        return;
    }
    self.output = [AVCaptureMetadataOutput new];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
        self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    }

    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)startScan {
    if (!self.session) {
        return;
    }
    self.preview.frame = [UIScreen mainScreen].bounds;
    [self deviceOrientationChanged];
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [self.session startRunning];
}

- (AVCaptureVideoOrientation)captureOritentationWithInterfaceOrientataion {
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    AVCaptureVideoOrientation captureOrientation = AVCaptureVideoOrientationPortrait;
    if (@available(iOS 13.0, *))
        interfaceOrientation = self.view.window.windowScene.interfaceOrientation;
    else
        interfaceOrientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            captureOrientation = AVCaptureVideoOrientationPortrait;
            break;

        case UIInterfaceOrientationLandscapeLeft:
            captureOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;

        case UIInterfaceOrientationLandscapeRight:
            captureOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;

        case UIInterfaceOrientationPortraitUpsideDown:
            captureOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;

        default:
            break;
    }
    return captureOrientation;
}

- (void)stopScan {
    [self.session stopRunning];
    // TODO: animation
}

#pragma mark -

- (void)addNotify {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeNotify {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationChanged {
    if (self.preview.connection.isVideoOrientationSupported) {
        self.preview.connection.videoOrientation = [self captureOritentationWithInterfaceOrientataion];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count <= 0) {
        return;
    }
    if (!self.enableOutputData) {
        return;
    }
    for (AVMetadataObject *object in metadataObjects) {
        NSString *message = bjl_as(object, AVMetadataMachineReadableCodeObject).stringValue;
        if (message) {
            if ([message containsString:@"baijiayun.com"]
                || [message containsString:@"bjhlliveapp"]) {
                if (self.outputMessageCallback) {
                    self.outputMessageCallback(message);
                }
                [self stopScan];
            }
            else {
                [self makeWarningView];
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                self.warningView.hidden = NO;
                [self performSelector:@selector(hideWarningView) withObject:nil afterDelay:2.0];
            }
            break;
        }
    }
}

#pragma mark - getter

- (UIImageView *)imageViewWithName:(NSString *)name {
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage bjl_imageNamed:name];
    imageView.accessibilityIdentifier = name;
    return imageView;
}

#pragma mark - override

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.scannerSupportOrientation ?: UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

@end
