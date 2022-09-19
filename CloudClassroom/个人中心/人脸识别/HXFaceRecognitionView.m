//
//  HXFaceRecognitionView.m
//  CloudClassroom
//
//  Created by mac on 2022/9/14.
//

#import "HXFaceRecognitionView.h"
#import "IDLFaceSDK/IDLFaceSDK.h"
#import "FaceParameterConfig.h"
#import <AVFoundation/AVFoundation.h>

@interface HXFaceRecognitionView ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, strong) UIView *backGroudView;
@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *closeBtn;

@property(nonatomic, strong) UIView *previewView;
@property(nonatomic,strong) UIImageView *circleImageView;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UIImageView *zhuanDongCircleImageView;

@property(nonatomic, strong) UIView *circleView;
@property(nonatomic, strong) UIView *remindView;
@property(nonatomic,strong) UILabel *remindLabel;
@property(nonatomic, strong) UIImageView *remindImageView;

@property(nonatomic,strong) UILabel *suggestLabel;//请正对摄像头


@property(nonatomic,strong) UILabel *tipLabel;
@property(nonatomic,strong) UIImageView *tipImageView;


@property(nonatomic,strong) UIButton *startRecognitionBtn;
@property(nonatomic,strong) UIImageView *playImageView;

@property(nonatomic, strong) UIViewController *parentViewController;

//
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property(nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

//本次识别是否结束
@property(nonatomic, assign) BOOL hasFinished;
//本次人脸对比时，已经失败的次数
@property(nonatomic, assign) NSInteger failTimes;

@end

@implementation HXFaceRecognitionView

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight)];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        //UI
        [self createUI];
    }
    return self;
}


- (void)dealloc{
    NSLog(@"百度人脸活体检测窗口已关闭!");
}


#pragma mark -  初始化百度人脸识别
- (void)startInitialIDLFaceManger {
    
    // 设置最小检测人脸阈值
    [[FaceSDKManager sharedInstance] setMinFaceSize:150];
    // 设置截取人脸图片宽
    [[FaceSDKManager sharedInstance] setCropFaceSizeWidth:300];
    // 设置截取人脸图片高
    [[FaceSDKManager sharedInstance] setCropFaceSizeHeight:400];
    // 设置人脸遮挡阀值
    [[FaceSDKManager sharedInstance] setOccluThreshold:0.5];
    // 设置亮度阀值
    [[FaceSDKManager sharedInstance] setMinIllumThreshold:60];
    [[FaceSDKManager sharedInstance] setMaxIllumThreshold:200];
    // 设置图像模糊阀值
    [[FaceSDKManager sharedInstance] setBlurThreshold:0.7];
    // 设置头部姿态角度
    [[FaceSDKManager sharedInstance] setEulurAngleThrPitch:10 yaw:10 roll:10];
    // 设置人脸检测精度阀值
    [[FaceSDKManager sharedInstance] setNotFaceThreshold:0.6];
    // 设置抠图的缩放倍数--数值越大抠图周边黑框越大
    [[FaceSDKManager sharedInstance] setCropEnlargeRatio:2.1f];
    // 设置照片采集张数
    [[FaceSDKManager sharedInstance] setMaxCropImageNum:1];
    // 设置超时时间
    [[FaceSDKManager sharedInstance] setConditionTimeout:10];
    // 设置原始图缩放比例
    [[FaceSDKManager sharedInstance] setImageWithScale:0.8f];
    // 设置图片加密类型，type=0 基于base64 加密；type=1 基于百度安全算法加密
    [[FaceSDKManager sharedInstance] setImageEncrypteType:0];
    // 设置人脸过远框比例
    [[FaceSDKManager sharedInstance] setMinRect:0.4];
    // 初始化SDK功能函数
    [[FaceSDKManager sharedInstance] initCollect];
    
    BOOL closeFaceLivenessSound = [HXUserDefaults boolForKey:CloseFaceLivenessSound];
    //只拍照
    if (self.faceConfig.faceCj) {
        [[IDLFaceDetectionManager sharedInstance] startInitial];
        [IDLFaceDetectionManager sharedInstance].enableSound = !closeFaceLivenessSound;
    }else{
        // 设置采集动作个数
        [IDLFaceLivenessManager sharedInstance].enableSound = !closeFaceLivenessSound;
        [[IDLFaceLivenessManager sharedInstance] livenesswithList:@[@(arc4random()%2)] order:NO numberOfLiveness:1];
        [[IDLFaceLivenessManager sharedInstance] startInitial];
    }
}


  
#pragma mark -重置百度人脸识别
- (void)resetIDLFaceManager {
    //只拍照
    if (self.faceConfig.faceCj) {
        [[IDLFaceDetectionManager sharedInstance] reset];
    }else{
        [[IDLFaceLivenessManager sharedInstance] reset];
        [[IDLFaceLivenessManager sharedInstance] livenesswithList:@[@(arc4random()%2)] order:NO numberOfLiveness:1];
    }
}


#pragma mark -  弹出
- (void)showInViewController:(UIViewController *)viewController{
    
    self.parentViewController = viewController;
    [self showInView:viewController.tabBarController?viewController.tabBarController.view:viewController.view];
}

//添加弹出移除的动画效果
- (void)showInView:(UIView *)view{
    
    if (self.status == HXFaceRecognitionStatusSimulate) {
        self.titleLabel.text = @"模拟人脸识别";
    }
    
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    [view addSubview:self];
    
    // 浮现
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        [self checkImageStatus];
    }];
}

#pragma mark - 检查照片状态
- (void)checkImageStatus {
    //主动开启相机进行拍照
    [self checkCameraAuthorization];
    //初始化百度人脸识别
    [self startInitialIDLFaceManger];
}

#pragma mark - 判断相机权限
- (void)checkCameraAuthorization {
    
    //判断权限
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"无法使用相机" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
        [self teardownAVCapture];
        return;
    }else if (status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {//权限
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    NSLog(@"授权相机成功！");
                    //不是模拟直接开始识别
                    if (self.status!=HXFaceRecognitionStatusSimulate) {
                        [self faceRecognitioning];
                    }
                }
            });
        }];
        return;
    }
    //不是模拟直接开始识别
    if (self.status!=HXFaceRecognitionStatusSimulate) {
        [self faceRecognitioning];
    }
}


#pragma  mark - 开始摄像头采集
- (void)setupAVCapture{
    
    NSError *error = nil;
    self.captureSession = [AVCaptureSession new];
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //前置摄像头
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            device = d;
            break;
        }
    }
    if (device.position != AVCaptureDevicePositionFront) {
        //弹框提示
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"前置摄像头开启失败！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
    }
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        //弹框提示
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]] message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
        [self teardownAVCapture];
        return;
    }
        
    if ([self.captureSession canAddInput:deviceInput]){
        [self.captureSession addInput:deviceInput];
    }else{
        //弹框提示
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"摄像头初始化失败！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
        
        [self teardownAVCapture];
        return;
    }

    // Make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ( [self.captureSession canAddOutput:self.videoDataOutput] )
        [self.captureSession addOutput:self.videoDataOutput];
    
    AVCaptureConnection* connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    // 调节摄像头翻转
    connection.videoMirrored = YES;
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [self.previewView layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
    
    CALayer *maskLayer = [CALayer layer];
    CGRect frame = self.headImageView.frame;
    frame.origin.x = (self.previewView.width-frame.size.width)/2.0;
    frame.origin.y = (self.previewView.height-frame.size.height)/2.0;
    maskLayer.frame = frame;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.cornerRadius = maskLayer.bounds.size.width/2.0;
    rootLayer.mask = maskLayer;
    
    self.previewView.hidden = NO;
    self.headImageView.hidden = YES;
    [self.captureSession startRunning];
   
}


#pragma  mark - 开始停止采集
- (void)teardownAVCapture{
    [self.previewLayer removeFromSuperlayer];
}



#pragma mark -关闭界面
- (void)close{
    //重置百度人脸识别
    [self resetIDLFaceManager];
    [self.playImageView stopAnimating];
    [self.captureSession stopRunning];
    [self.zhuanDongCircleImageView.layer removeAnimationForKey:@"rotationAnimation"];
    //停止采集
    [self teardownAVCapture];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


//点击开始人脸识别
-(void)startRecognition:(UIButton *)sender{
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"开始人脸识别"]||[[sender titleForState:UIControlStateNormal] isEqualToString:@"重新识别"]) {
        [self faceRecognitioning];
    }
}

//识别中...
-(void)faceRecognitioning{
    
    if (self.hasFinished) {
        return;
    }
    self.startRecognitionBtn.userInteractionEnabled = NO;
    [self.startRecognitionBtn setImage:nil forState:UIControlStateNormal];
    [self.startRecognitionBtn setTitle:nil forState:UIControlStateNormal];
    self.remindLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    self.remindLabel.text = @"识别中";
    
    self.suggestLabel.hidden = NO;
    self.remindView.hidden = NO;
    self.circleView.hidden = NO;
    self.zhuanDongCircleImageView.hidden = NO;
    self.playImageView.hidden = NO;
    self.previewView.hidden = NO;
    self.remindImageView.hidden = YES;
    self.headImageView.hidden = YES;
    
    
    [self setupAVCapture];
    [self resumeRotation];
    [self.playImageView startAnimating];
    [self.captureSession startRunning];
}

//停止识别
-(void)endFaceRecognitioning{
    
    
    
    self.remindView.hidden = NO;
    self.circleView.hidden = NO;
    self.previewView.hidden = NO;
    self.remindImageView.hidden = NO;
    self.suggestLabel.hidden =YES;
    self.headImageView.hidden = YES;
    self.zhuanDongCircleImageView.hidden = YES;
    self.playImageView.hidden = YES;
    
    [self pauseRotation];
    [self.playImageView stopAnimating];
    [self.captureSession stopRunning];
    
    //重置百度人脸识别
    [self resetIDLFaceManager];
}



#pragma mark - 识别中转动
- (void)addRotation{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 2;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion = NO;
    [self.zhuanDongCircleImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self pauseRotation];
}

//暂停转动
-(void)pauseRotation{
    CFTimeInterval pausedTime = [self.zhuanDongCircleImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.zhuanDongCircleImageView.layer.speed = 0.0;
    self.zhuanDongCircleImageView.layer.timeOffset = pausedTime;
}

//继续转动
-(void)resumeRotation{
    CFTimeInterval pausedTime = [self.zhuanDongCircleImageView.layer timeOffset];
    self.zhuanDongCircleImageView.layer.speed = 1.0;
    self.zhuanDongCircleImageView.layer.timeOffset = 0.0;
    self.zhuanDongCircleImageView.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.zhuanDongCircleImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.zhuanDongCircleImageView.layer.beginTime = timeSincePause;
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    UIImage* sampleImage = [self imageFromSamplePlanerPixelBuffer:sampleBuffer];
    
    
    if (self.faceConfig.faceCj) {//人脸拍照
        [self faceCapture:sampleImage];
    }else{//人脸对比
        [self faceProcesss:sampleImage];
    }
}

//人脸对比
- (void)faceProcesss:(UIImage *)image {
    if (self.hasFinished) {
        return;
    }
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    __weak typeof(self) weakSelf = self;
    [[IDLFaceLivenessManager sharedInstance] livenessNormalWithImage:image previewRect:rect detectRect:rect completionHandler:^(NSDictionary *images, FaceInfo *faceInfo, LivenessRemindCode remindCode) {
        switch (remindCode) {
            case LivenessRemindCodeOK: {
                weakSelf.hasFinished = YES;
            
                if (images[@"image"] != nil && [images[@"image"] count] != 0) {

                    NSArray *imageArr = images[@"image"];
                    FaceCropImageInfo *imageInfo = imageArr[0];
                    if (imageInfo.cropImageWithBlackEncryptStr) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            //停止识别
                            [weakSelf.captureSession stopRunning];
                            //上传
                            [weakSelf warningStatus:SuccessStatus warning:@"识别成功"];
                        });
                        
                    }else{
                       
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf resetIDLFaceManager];
                            weakSelf.hasFinished = NO;
                        });
                    }
                }else{
                   
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf resetIDLFaceManager];
                        weakSelf.hasFinished = NO;
                    });
                }
                break;
            }
            case LivenessRemindCodePitchOutofDownRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微抬头"];
              
                break;
            case LivenessRemindCodePitchOutofUpRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微低头"];
               
                break;
            case LivenessRemindCodeYawOutofLeftRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微向右转头"];
               
                break;
            case LivenessRemindCodeYawOutofRightRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微向左转头"];
               
                break;
            case LivenessRemindCodePoorIllumination:
                [weakSelf warningStatus:CommonStatus warning:@"光线再亮些"];
               
                break;
            case LivenessRemindCodeNoFaceDetected:
                [weakSelf warningStatus:CommonStatus warning:@"把脸移入框内"];
                
                break;
            case LivenessRemindCodeImageBlured:
                [weakSelf warningStatus:CommonStatus warning:@"请握稳手机"];
               
                break;
            case LivenessRemindCodeOcclusionLeftEye:
                [weakSelf warningStatus:OcclusionStatus warning:@"左眼有遮挡"];
               
                break;
            case LivenessRemindCodeOcclusionRightEye:
                [weakSelf warningStatus:OcclusionStatus warning:@"右眼有遮挡"];
                
                break;
            case LivenessRemindCodeOcclusionNose:
                [weakSelf warningStatus:OcclusionStatus warning:@"鼻子有遮挡"];
               
                break;
            case LivenessRemindCodeOcclusionMouth:
                [weakSelf warningStatus:OcclusionStatus warning:@"嘴巴有遮挡"];
               
                break;
            case LivenessRemindCodeOcclusionLeftContour:
                [weakSelf warningStatus:OcclusionStatus warning:@"左脸颊有遮挡"];
                
                break;
            case LivenessRemindCodeOcclusionRightContour:
                [weakSelf warningStatus:OcclusionStatus warning:@"右脸颊有遮挡"];
               
                break;
            case LivenessRemindCodeOcclusionChinCoutour:
                [weakSelf warningStatus:OcclusionStatus warning:@"下颚有遮挡"];
               
                break;
            case LivenessRemindCodeLeftEyeClosed:
                [weakSelf warningStatus:OcclusionStatus warning:@"左眼未睁开"];
               
                break;
            case LivenessRemindCodeRightEyeClosed:
                [weakSelf warningStatus:OcclusionStatus warning:@"右眼未睁开" ];
                
                break;
            case LivenessRemindCodeTooClose:
                [weakSelf warningStatus:CommonStatus warning:@"请将脸部离远一点"];
               
                break;
            case LivenessRemindCodeTooFar:
                [weakSelf warningStatus:CommonStatus warning:@"请将脸部靠近一点"];
                
                break;
            case LivenessRemindCodeBeyondPreviewFrame:
                [weakSelf warningStatus:CommonStatus warning:@"把脸移入框内"];
               
                break;
            case LivenessRemindCodeLiveEye:
                [weakSelf warningStatus:CommonStatus warning:@"眨眨眼"];
                
                break;
            case LivenessRemindCodeLiveMouth:
                [weakSelf warningStatus:CommonStatus warning:@"张张嘴"];
                
                break;
            case LivenessRemindCodeLiveYawRight:
                [weakSelf warningStatus:CommonStatus warning:@"向右缓慢转头"];
               
                break;
            case LivenessRemindCodeLiveYawLeft:
                [weakSelf warningStatus:CommonStatus warning:@"向左缓慢转头"];
                
                break;
            case LivenessRemindCodeLivePitchUp:
                [weakSelf warningStatus:CommonStatus warning:@"缓慢抬头"];
                
                break;
            case LivenessRemindCodeLivePitchDown:
                [weakSelf warningStatus:CommonStatus warning:@"缓慢低头"];
                
                break;
            case LivenessRemindCodeLiveYaw:
                [weakSelf warningStatus:CommonStatus warning:@"摇摇头"];
               
                break;
            case LivenessRemindCodeFaceIdChanged:
                [weakSelf warningStatus:CommonStatus warning:@"把脸移入框内"];
                
                break;
            case LivenessRemindCodeSingleLivenessFinished:
            {
                [weakSelf warningStatus:CommonStatus warning:@"非常好"];
            }
                break;
            case LivenessRemindCodeVerifyInitError:
                [weakSelf warningStatus:FailStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeTimeout: {
                [weakSelf warningStatus:Timeout warning:@"人脸识别超时"];
                break;
        
            }
            case LivenessRemindCodeConditionMeet: {
               
            }
                break;
            default:
                break;
        }
    }];
}

//人脸拍照
- (void)faceCapture:(UIImage *)image {
    
}


//提示
- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning{
    __weak typeof(self) weakSelf = self;
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (status == PoseStatus) {
            weakSelf.suggestLabel.text = @"请正对摄像头";
        }else if (status == OcclusionStatus) {
            weakSelf.suggestLabel.text = @"脸部有遮挡";
        }else if (status == CommonStatus) {
            weakSelf.suggestLabel.text = warning;
        }else if (status == SuccessStatus) {
            
            weakSelf.startRecognitionBtn.userInteractionEnabled = YES;
            weakSelf.remindLabel.textColor = COLOR_WITH_ALPHA(0x5EDA6A, 1);
            weakSelf.remindLabel.text = @"识别成功";
            weakSelf.remindImageView.image = [UIImage imageNamed:@"remindsuccess_icon"];
            [weakSelf.startRecognitionBtn setTitle:@"重新识别" forState:UIControlStateNormal];
            [weakSelf.startRecognitionBtn setImage:[UIImage imageNamed:@"facerest_icon"] forState:UIControlStateNormal];
            weakSelf.startRecognitionBtn.titleLabel.sd_layout.centerXEqualToView(self.startRecognitionBtn).offset(12);
            //模拟成功后可以重新识别
            if (weakSelf.status==HXFaceRecognitionStatusSimulate) {
                weakSelf.hasFinished = NO;
                //停止识别
                [weakSelf endFaceRecognitioning];
                
            }else{
                [weakSelf close];
            }
            
        }else if (status == FailStatus) {
            
            weakSelf.startRecognitionBtn.userInteractionEnabled = YES;
            weakSelf.remindLabel.textColor = COLOR_WITH_ALPHA(0xF54747, 1);
            weakSelf.remindLabel.text = @"识别失败";
            weakSelf.remindImageView.image = [UIImage imageNamed:@"remindfail_icon"];
            weakSelf.hasFinished = NO;
            //停止识别
            [weakSelf endFaceRecognitioning];
            
            
        }else if (status == Timeout){
            weakSelf.hasFinished = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                //对比超时也算一次失败
                weakSelf.failTimes ++;
                weakSelf.hasFinished = NO;
                
                [weakSelf.startRecognitionBtn setTitle:@"重新识别" forState:UIControlStateNormal];
                [weakSelf.startRecognitionBtn setImage:[UIImage imageNamed:@"facerest_icon"] forState:UIControlStateNormal];
                weakSelf.startRecognitionBtn.titleLabel.sd_layout.centerXEqualToView(self.startRecognitionBtn).offset(12);
                weakSelf.startRecognitionBtn.userInteractionEnabled = YES;
                weakSelf.remindLabel.textColor = COLOR_WITH_ALPHA(0xF54747, 1);
                weakSelf.remindLabel.text = @"识别超时";
                weakSelf.remindImageView.image = [UIImage imageNamed:@"remindfail_icon"];
                //停止识别
                [weakSelf endFaceRecognitioning];
               
                
            });
        }
    });
}



/**
 * 把 CMSampleBufferRef 转化成 UIImage 的方法，参考自：
 * https://stackoverflow.com/questions/19310437/convert-cmsamplebufferref-to-uiimage-with-yuv-color-space
 * note1 : SDK要求 colorSpace 为 CGColorSpaceCreateDeviceRGB
 * note2 : SDK需要 ARGB 格式的图片
 */
- (UIImage *)imageFromSamplePlanerPixelBuffer:(CMSampleBufferRef)sampleBuffer{
    @autoreleasepool {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent RGB color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little);
        // Create a Quartz image from the pixel data in the bitmap graphics context
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Free up the context and color space
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        // Create an image object from the Quartz image
        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        
        // Release the Quartz image
        CGImageRelease(quartzImage);
        return (image);
    }
}



#pragma mark - UI
-(void)createUI{
    [self addSubview:self.backGroudView];
    [self.backGroudView addSubview:self.navBarView];
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.closeBtn];
    
    [self.backGroudView addSubview:self.previewView];
    [self.backGroudView addSubview:self.circleView];
    [self.backGroudView addSubview:self.circleImageView];
    [self.backGroudView addSubview:self.headImageView];
    [self.backGroudView addSubview:self.zhuanDongCircleImageView];
    [self.backGroudView addSubview:self.remindImageView];
    [self.backGroudView addSubview:self.suggestLabel];
    
    [self.backGroudView addSubview:self.circleView];
    [self.circleView addSubview:self.remindView];
    [self.remindView addSubview:self.remindLabel];
    
    [self.backGroudView addSubview:self.tipLabel];
    [self.backGroudView addSubview:self.tipImageView];
    [self.backGroudView addSubview:self.startRecognitionBtn];
    
    [self.startRecognitionBtn addSubview:self.playImageView];
    
    self.backGroudView.sd_layout
    .topEqualToView(self)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .bottomEqualToView(self);
    
    
    self.navBarView.sd_layout
    .topEqualToView(self.backGroudView)
    .leftEqualToView(self.backGroudView)
    .rightEqualToView(self.backGroudView)
    .heightIs(kNavigationBarHeight);
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.navBarView, kStatusBarHeight)
    .centerXEqualToView(self.navBarView)
    .widthIs(200)
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.closeBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftEqualToView(self.navBarView)
    .widthIs(60)
    .heightIs(44);
    
    self.circleImageView.sd_layout
    .topSpaceToView(self.navBarView,100)
    .centerXEqualToView(self.backGroudView)
    .widthIs(183)
    .heightEqualToWidth();
    
    
    self.headImageView.sd_layout
    .centerXEqualToView(self.circleImageView)
    .centerYEqualToView(self.circleImageView)
    .widthIs(168)
    .heightEqualToWidth();
    [self.headImageView updateLayout];
    
    
    self.previewView.sd_layout
    .centerXEqualToView(self.headImageView)
    .centerYEqualToView(self.headImageView)
    .widthRatioToView(self.headImageView, 1.3)
    .heightRatioToView(self.headImageView,2.6);
    
    
    self.circleView.sd_layout
    .centerXEqualToView(self.headImageView)
    .centerYEqualToView(self.headImageView)
    .widthRatioToView(self.headImageView, 1)
    .heightRatioToView(self.headImageView, 1);
    self.circleView.sd_cornerRadiusFromHeightRatio=@0.5;
    [self.circleView updateLayout];
    

    self.zhuanDongCircleImageView.sd_layout
    .centerXEqualToView(self.circleImageView)
    .centerYEqualToView(self.circleImageView)
    .widthIs(172)
    .heightEqualToWidth();
    

    
    self.remindImageView.sd_layout
    .topSpaceToView(self.circleImageView,10)
    .centerXEqualToView(self.backGroudView)
    .widthIs(20)
    .heightEqualToWidth();
    
    self.suggestLabel.sd_layout
    .centerYEqualToView(self.remindImageView)
    .leftSpaceToView(self.backGroudView, 30)
    .rightSpaceToView(self.backGroudView, 30)
    .heightIs(20);
    
    
    self.remindView.sd_layout
    .bottomEqualToView(self.circleView)
    .leftEqualToView(self.circleView)
    .rightEqualToView(self.circleView)
    .heightIs(35);
    [self.remindView updateLayout];
    
    //取交集部分
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.remindView.frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
    
    CAShapeLayer *lineLayer =  [[CAShapeLayer alloc] init];
    lineLayer.frame = self.remindView.bounds;
    lineLayer.path = path.CGPath;
    [self.circleView.layer addSublayer:lineLayer];
    self.circleView.layer.mask = lineLayer;
    
    self.remindLabel.sd_layout
    .topSpaceToView(self.remindView, 2)
    .leftEqualToView(self.remindView)
    .rightEqualToView(self.remindView)
    .heightIs(24);
    
    
    self.tipLabel.sd_layout
    .topSpaceToView(self.remindImageView,30)
    .leftSpaceToView(self.backGroudView, 30)
    .rightSpaceToView(self.backGroudView, 30)
    .autoHeightRatio(0);
    
    self.tipImageView.sd_layout
    .topSpaceToView(self.tipLabel,50)
    .centerXEqualToView(self.backGroudView)
    .widthIs(233)
    .heightIs(72);
    
    
    self.startRecognitionBtn.sd_layout
    .bottomSpaceToView(self.backGroudView, 40+kScreenBottomMargin)
    .leftSpaceToView(self.backGroudView, 70)
    .rightSpaceToView(self.backGroudView, 70)
    .heightIs(36);
    self.startRecognitionBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.startRecognitionBtn.titleLabel.sd_layout
    .centerYEqualToView(self.startRecognitionBtn)
    .centerXEqualToView(self.startRecognitionBtn).offset(0)
    .heightIs(36);
    [self.startRecognitionBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    
    self.startRecognitionBtn.imageView.sd_layout
    .centerYEqualToView(self.startRecognitionBtn)
    .rightSpaceToView(self.startRecognitionBtn.titleLabel, 4)
    .widthIs(16)
    .heightIs(14);
   
    self.playImageView.sd_layout
    .centerXEqualToView(self.startRecognitionBtn)
    .centerYEqualToView(self.startRecognitionBtn)
    .widthIs(30)
    .heightIs(10);
    
    
    //添加旋转动画，默认暂停
    [self addRotation];
}


#pragma mark - LazyLoad
-(UIView *)backGroudView{
    if (!_backGroudView) {
        _backGroudView = [[UIView alloc] init];
        _backGroudView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _backGroudView;
}

-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc] init];
        _navBarView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    }
    return _navBarView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _titleLabel.text = @"人脸识别";
    }
    return _titleLabel;
}

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"closewhite_icon"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}


-(UIView *)previewView{
    if (!_previewView) {
        _previewView = [[UIView alloc] init];
    }
    return _previewView;
}



-(UIImageView *)circleImageView{
    if (!_circleImageView) {
        _circleImageView = [[UIImageView alloc] init];
        _circleImageView.image = [UIImage imageNamed:@"circle_icon"];
    }
    return _circleImageView;
}

-(UIImageView *)zhuanDongCircleImageView{
    if (!_zhuanDongCircleImageView) {
        _zhuanDongCircleImageView = [[UIImageView alloc] init];
        _zhuanDongCircleImageView.image = [UIImage imageNamed:@"zhuandongcircle_icon"];
        _zhuanDongCircleImageView.hidden = YES;
    }
    return _zhuanDongCircleImageView;
}


-(UIView *)circleView{
    if (!_circleView) {
        _circleView = [[UIView alloc] init];
        _circleView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.6);
        _circleView.hidden = YES;
    }
    return _circleView;
}


-(UIView *)remindView{
    if (!_remindView) {
        _remindView = [[UIView alloc] init];
        _remindView.backgroundColor = UIColor.clearColor;
        _remindView.hidden = YES;
    }
    return _remindView;
}



-(UILabel *)remindLabel{
    if (!_remindLabel) {
        _remindLabel = [[UILabel alloc] init];
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.font = HXBoldFont(14);
        _remindLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _remindLabel.text = @"识别中";
    }
    return _remindLabel;
}

-(UILabel *)suggestLabel{
    if (!_suggestLabel) {
        _suggestLabel = [[UILabel alloc] init];
        _suggestLabel.textAlignment = NSTextAlignmentCenter;
        _suggestLabel.font = HXBoldFont(14);
        _suggestLabel.textColor = COLOR_WITH_ALPHA(0xF29D1C, 1);
        _suggestLabel.hidden = YES;
    }
    return _suggestLabel;
}

-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.image = [UIImage imageNamed:@"facedefault_icon"];
    }
    return _headImageView;
}

-(UIImageView *)remindImageView{
    if (!_remindImageView) {
        _remindImageView = [[UIImageView alloc] init];
        _remindImageView.hidden = YES;
    }
    return _remindImageView;
}


-(UIImageView *)tipImageView{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.image = [UIImage imageNamed:@"facetip_icon"];
    }
    return _tipImageView;
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = HXBoldFont(14);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = @"为了在学习和考试过程中顺利通过人脸对比，学生可以提前进行模拟人脸识别，平台不会泄露个人隐私信息";
    }
    return _tipLabel;
}


-(UIButton *)startRecognitionBtn{
    if (!_startRecognitionBtn) {
        _startRecognitionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startRecognitionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _startRecognitionBtn.titleLabel.font = HXBoldFont(15);
        [_startRecognitionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startRecognitionBtn setTitle:@"开始人脸识别" forState:UIControlStateNormal];
        _startRecognitionBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_startRecognitionBtn addTarget:self action:@selector(startRecognition:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startRecognitionBtn;
}

-(UIImageView *)playImageView{
    if (!_playImageView) {
        _playImageView = [[UIImageView alloc] init];
        _playImageView.contentMode = UIViewContentModeScaleAspectFit;
        //创建图片集
        NSMutableArray *imageArray = [NSMutableArray array];
        for (NSInteger i=1; i<5; i++) {
            UIImage *tempImage = [UIImage imageNamed:[NSString stringWithFormat:@"dongdian_%ld",(long)i]];
            [imageArray addObject:tempImage];
        }
        //设置播放图片集
        _playImageView.animationImages = imageArray;
        //设置动画时间
        _playImageView.animationDuration = 1.5;
        //设置循环播放次数，0为一直循环
        _playImageView.animationRepeatCount = 0;
        _playImageView.hidden = YES;
        [_playImageView stopAnimating];
    }
    return _playImageView;
}

@end
