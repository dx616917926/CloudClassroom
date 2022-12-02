//
//  BRTCUtil.h
//  BRTC-i
//
//  Created by lw0717 on 2020/10/30.
//  Copyright © 2020 boommeeting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IJKBRTCUtils : NSObject

/// 获取设备名称
+ (NSString *)deviceModelName;
/// 获取运营商信息
+ (NSString *)getCarrierInfo;
/// 获取 CPU 使用率
+ (float)appCPUsage;
/// 获取当前时间戳 ms 级
+ (NSNumber *)ts;
///
+ (void)setServerTimeInterval:(NSTimeInterval)timer;

+ (NSTimeInterval)getServerTimeInterval;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)uuidString;

+ (CGSize)getRealCaptureWidth:(int)width height:(int)height capturePosition:(AVCaptureDevicePosition)position;

+ (int)getDeviceWidth;

+ (int)getDeviceHeight;

+ (AVCaptureDevice *)currentDeviceByCapturePosition:(AVCaptureDevicePosition)position;

@end

NS_ASSUME_NONNULL_END
