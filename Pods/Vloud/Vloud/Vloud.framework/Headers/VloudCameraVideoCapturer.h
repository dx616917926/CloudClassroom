/***********************
auth: cszdlt@qq.com
date: 2020-03-30 15:11:43
name: VloudCapture.h
************************/

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "VloudCapture.h"

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@protocol VloudCameraVideoCapturerDelegate <NSObject>
@optional
- (RTC_OBJC_TYPE(RTCVideoFrame) *)processVideoFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)videoFrame;
- (void)captureSessionInterruption:(int)reason;
- (void)captureSessionInterruptionEnded;
- (void)runtimeError:(NSError *)error hasRetriedOnFatalError:(BOOL)hasRetriedOnFatalError;
- (void)didStartRunning;
- (void)didStopRunning;
- (void)cameraAuthorization:(AVAuthorizationStatus)authorStatus;
@end


RTC_OBJC_EXPORT
@interface VloudCameraVideoCapturer : NSObject<VloudVideoCapture>

@property (nonatomic, weak) id<VloudCameraVideoCapturerDelegate> cameraDelegate; // 获得采集数据后外抛

// Capture session that is used for capturing. Valid from initialization to dealloc.
@property(readonly, nonatomic) AVCaptureSession *captureSession;

// 当前是否正在使用前置摄像头, 调用 -setFrontCamera: 和 -switchCamera 方法会修改此属性
@property (nonatomic, assign, readonly, getter=isUsingFrontCamera) BOOL usingFrontCamera;

// Returns list of available capture devices that support video capture.
+ (NSArray<AVCaptureDevice *> *)captureDevices;
// Returns list of formats that are supported by this class for this device.
+ (NSArray<AVCaptureDeviceFormat *> *)supportedFormatsForDevice:(AVCaptureDevice *)device;

- (instancetype) init;

- (void)switchCamera; 

- (void)setVideoCapturerDelegate:(id<VloudVideoCapturerDelegate> __nullable)delegate;
- (void)setVideoCapturerDelegate:(id<VloudVideoCapturerDelegate> __nullable)delegate personalControlDirection:(BOOL)personalControlDirection;
- (void)startCaptureWithWidth:(NSInteger)width
                       height:(NSInteger)height
                          fps:(NSInteger)fps;
- (BOOL)startCapture;

- (void)stopCapture;

- (void)setFrontCamera:(BOOL)isFront;

- (void)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer changeRotation:(NSNumber *)changeRotation;

@end
NS_ASSUME_NONNULL_END
