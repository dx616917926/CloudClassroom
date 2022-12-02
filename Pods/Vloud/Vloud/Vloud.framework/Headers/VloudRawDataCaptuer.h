//
//  VloudRawDataCaptuer.h
//  products
//
//  Created by DeskMac on 2020/12/24.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "VloudCapture.h"

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum VloudVideoRotation : NSInteger VloudVideoRotation;
enum VloudVideoRotation : NSInteger {
    VloudVideoRotation_0,
    VloudVideoRotation_90,
    VloudVideoRotation_180,
    VloudVideoRotation_270,
};

RTC_OBJC_EXPORT
@interface VloudRawDataCaptuer : NSObject<VloudVideoCapture>

- (instancetype)init;

- (void)setVideoCapturerDelegate:(id<VloudVideoCapturerDelegate> __nullable)delegate;
- (void)setVideoCapturerDelegate:(id<VloudVideoCapturerDelegate> __nullable)delegate personalControlDirection:(BOOL)personalControlDirection;

// Starts the capture session asynchronously.
- (void)startCaptureWithWidth:(NSInteger)width
                       height:(NSInteger)height
                          fps:(NSInteger)fps;

- (void)stopCapture;

- (void)sendRawData:(CMSampleBufferRef)sampleBuffer rotation:(NSNumber *)rotation;

@end

NS_ASSUME_NONNULL_END
