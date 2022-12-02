//
//  BJLCameraCheckView.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <AVKit/AVKit.h>

#import "BJLCameraCheckView.h"
#import "BJLAppearance.h"

const CGFloat previewWidth = 276.0;
const CGFloat previewHeight = 156.0;
NSString *BJLCameraDeviceCellReuseIdentifier = @"BJLCameraDeviceCellReuseIdentifier";

@interface BJLCameraCheckView ()

@property (nonatomic) UIView *previewView;
@property (nonatomic) UIImageView *previewPlaceholder;
@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoInput;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) NSArray<AVCaptureDevice *> *captureDevices;
@property (nonatomic) AVCaptureDevice *currentDevice;

@end

@implementation BJLCameraCheckView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeSubviews];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.session stopRunning];
}

- (void)makeSubviews {
    self.tipLabel.text = BJLLocalizedString(@"选择摄像头");
    [self.tableView registerClass:[BJLMediaDeviceCell class] forCellReuseIdentifier:BJLCameraDeviceCellReuseIdentifier];
    [self.arrowButton bjl_setImage:nil forState:UIControlStateNormal];

    self.previewView = ({
        UIView *view = [UIView new];
        view.layer.masksToBounds = YES;
        view.backgroundColor = BJLTheme.roomBackgroundColor;
        view;
    });
    [self addSubview:self.previewView];
    [self.previewView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.size.equal.sizeOffset(CGSizeMake(previewWidth, previewHeight));
        make.top.equalTo(self.arrowButton.bjl_bottom).offset(35.0);
    }];

    self.previewPlaceholder = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_check_camera_placeholder"]];
        imageView;
    });
    [self.previewView addSubview:self.previewPlaceholder];
    [self.previewPlaceholder bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.previewView);
        make.size.equal.sizeOffset(CGSizeMake(120.0, 120.0));
    }];

    AVAuthorizationStatus cameraAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (cameraAuthStatus != AVAuthorizationStatusAuthorized) {
        [BJLAuthorization checkMicrophoneAccessAndRequest:YES callback:^(BOOL granted, UIAlertController *_Nullable alert) {
            if (granted) {
                [self setupAVSession];
            }
            else {
                [self makeCheckedViewWithError:BJLErrorMake(BJLErrorCode_invalidCalling, @"未授权")];
                if (alert) {
                    [self.parentViewController presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
    }
    else {
        [self setupAVSession];
    }
}

- (void)setupAVSession {
    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset1280x720];

    NSMutableArray<AVCaptureDeviceType> *deviceTypes = [NSMutableArray new];
    [deviceTypes addObject:AVCaptureDeviceTypeBuiltInWideAngleCamera];
    //    [deviceTypes addObject:AVCaptureDeviceTypeBuiltInTelephotoCamera];
    //    if (@available(iOS 11.1, *)) {
    //        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInTrueDepthCamera];
    //    }
    //    if (@available(iOS 13.0, *)) {
    //        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
    //        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInDualWideCamera];
    //        [deviceTypes addObject:AVCaptureDeviceTypeBuiltInTripleCamera];
    //    }
    AVCaptureDevice *defaultFrontCamera = nil;
    // 优先使用首选的前置相机
    AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    for (AVCaptureDevice *device in deviceSession.devices) {
        if (!device.connected) {
            continue;
        }
        if (device.position == AVCaptureDevicePositionFront) {
            if (!device) {
                defaultFrontCamera = device;
            }
            else if (defaultFrontCamera.deviceType != AVCaptureDeviceTypeBuiltInWideAngleCamera
                     && device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera) {
                defaultFrontCamera = device;
            }
        }
    }
    self.captureDevices = deviceSession.devices;
    if (!defaultFrontCamera) {
        defaultFrontCamera = self.captureDevices.firstObject;
    }
    if (!defaultFrontCamera) {
        [self makeCheckedViewWithError:BJLErrorMake(BJLErrorCode_cancelled, @"未发现设备，检测中请务必保持设备正常连接")];
        return;
    }
    self.currentDevice = defaultFrontCamera;

    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.currentDevice error:&error];
    if (error) {
        [self makeCheckedViewWithError:error];
        return;
    }
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    self.videoInput = videoInput;
    [session commitConfiguration];
    self.session = session;

    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    if ([previewLayer.connection isVideoOrientationSupported]) {
        previewLayer.connection.videoOrientation = [self captureOritention];
    }
    [self.previewView.layer addSublayer:previewLayer];
    self.previewLayer = previewLayer;
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.previewView, bounds)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [CATransaction begin];
             [CATransaction setDisableActions:YES];
             self.previewLayer.frame = self.previewView.bounds;
             [CATransaction commit];
             return YES;
         }];

    [session startRunning];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.window && self.superview && !self.checkLabel) {
            [self makeCheckedViewWithError:nil];
        }
    });
}

- (void)makeCheckedViewWithError:(nullable BJLError *)error {
    if (self.checkLabel) {
        return;
    }
    bjl_weakify(self);
    [self makeCheckedViewWithTitle:BJLLocalizedString(@"通过摄像头能清晰的看到图像吗？")
        confirmMessage:BJLLocalizedString(@"能看到")
        confirmHander:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self.session stopRunning];
            if (self.cameraCheckCompletion) {
                self.cameraCheckCompletion(YES, NO);
            }
        }
        opposeMessage:BJLLocalizedString(@"看不到")
        opposeHander:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            [self.session stopRunning];
            if (self.cameraCheckCompletion) {
                self.cameraCheckCompletion(NO, !error);
            }
        }
        error:error];
}

- (void)updateOrientation:(UIInterfaceOrientation)orientation {
    self.orientation = orientation;
    if (self.session.isRunning) {
        if ([self.previewLayer.connection isVideoOrientationSupported]) {
            self.previewLayer.connection.videoOrientation = [self captureOritention];
        }
    }
}

- (void)changeVideoInputWithDevice:(AVCaptureDevice *)device {
    [self.session stopRunning];
    [self.session removeInput:self.videoInput];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        [self makeCheckedViewWithError:error];
        return;
    }
    if ([self.session canAddInput:videoInput]) {
        [self.session addInput:videoInput];
    }
    self.currentDevice = device;
    self.videoInput = videoInput;
    [self.session commitConfiguration];
    [self.session startRunning];
}

#pragma mark -

- (NSArray *)dataSource {
    return self.captureDevices;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.captureDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLMediaDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:BJLCameraDeviceCellReuseIdentifier forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    NSInteger currentDeviceIndex = [self indexOfCaptureDevice:self.currentDevice];
    AVCaptureDevice *device = [self.captureDevices bjl_objectAtIndex:index];
    [cell updateName:device.localizedName selected:index == currentDeviceIndex];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AVCaptureDevice *device = [self.captureDevices bjl_objectAtIndex:indexPath.row];
    [tableView removeFromSuperview];
    [self changeVideoInputWithDevice:device];
}

#pragma mark -

- (void)setCurrentDevice:(AVCaptureDevice *)currentDevice {
    _currentDevice = currentDevice;
    [self.arrowButton bjl_setTitle:currentDevice.localizedName forState:UIControlStateNormal];
    self->_cameraName = currentDevice.localizedName;
}

- (NSInteger)indexOfCaptureDevice:(AVCaptureDevice *)device {
    for (NSInteger i = 0; i < self.captureDevices.count; i++) {
        AVCaptureDevice *currentDevice = [self.captureDevices bjl_objectAtIndex:i];
        if ([self sameCaptureDevice:device device:currentDevice]) {
            return i;
        }
    }
    return 0;
}

- (BOOL)sameCaptureDevice:(AVCaptureDevice *)device device:(AVCaptureDevice *)otherDevice {
    if ([device.uniqueID isEqualToString:otherDevice.uniqueID]) {
        return YES;
    }
    return NO;
}

- (AVCaptureVideoOrientation)captureOritention {
    switch (self.orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;

        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;

        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;

        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;

        default:
            return AVCaptureVideoOrientationLandscapeLeft;
    }
}

@end
