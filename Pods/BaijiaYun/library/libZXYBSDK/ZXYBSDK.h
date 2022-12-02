//
//  ZXYBSDK.h
//  ZXYBSdk
//
//  Created by 朱先生 on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import "ZXYBManager.h"
@class CBPeripheral;
@class ZXYBDeviceInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ZXYBSDK : NSObject

/**
 boardType 0 A4 1A 5
 */
+(void)XYInitWithType:(int)boardType;

/**
 Open blueTooth
 */
+(int)XYOpenWithBle:(CBPeripheral *)device Completion:(id<ZXYBDataAvailableDelegate>)delegate;

/**
 close blueTooth
 */
+(void)XYClose;

/**
 start scan blueTooth
 */
+(int)scanBluetool:(id<ZXYBScanDeviceDelegate>)deviceDelegate;

/**
 stop scan blueTooth
 */
+(void)stopScan;

/**
 getXYDeviceInfo 蓝牙信息
 */
+(ZXYBDeviceInfo *)getXYDeviceInfo;

//+(BOOL)isConnect;

+(void)setWorkRectFWithWidth:(CGFloat)width withHeight:(CGFloat)height withEqualratio:(BOOL)isEqualratio;

/**
    命令写入
 */
+(void)writeData:(NSString *) value;

/**
 * 查询离线存储数据
 */
+(void)getXYOffLineStorege;

/**
    设置离线数据协议
 */
+(void)setStoragePageDelegate:(id<ZXYBStoragePageDelegate>)storageDelegate;

/**
    设置离线数据协议
 */
+(int)getStoragePagesWithPageNumber:(int)pageNum withStartPage:(int)startPage withStartCursor:(int)startCursor;

@end

NS_ASSUME_NONNULL_END
