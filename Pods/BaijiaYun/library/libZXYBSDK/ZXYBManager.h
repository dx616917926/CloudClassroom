//
//  ZXYBManager.h
//  ZXYBSDK
//
//  Created by 朱先生 on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
@class ZXYBBleDevice;
@class ZXYBDataPacket;
@class ZXYBDeviceInfo;
@class ZXYBEnvPacket;
@class ZXYBPage;





NS_ASSUME_NONNULL_BEGIN

//点信息的状态
typedef enum : NSUInteger {
    XYPenStatus_Hover,//
    XYPenStatus_Down,//
    XYPenStatus_Move,//
    XYPenStatus_Up,
    XYPenStatus_Leave,
    
} PointState;

//蓝牙连接状态
typedef enum : NSUInteger {
    CONNECT_STATUS_UNKOWN = -1,//
    CONNECT_STATUS_DISCONNECT = 0,//
    CONNECT_STATUS_SUCCESS = 1,//
    CONNECT_STATUS_FAIL = 2,
    CONNECT_STATUS_CONNECTING = 3,
    CONNECT_STATUS_UNIT = 4,
    
} BluState;

//蓝牙错误码
typedef enum : NSUInteger {
    XYERR_OK = 0,//
    XYERR_DEVICE_NOFFOUND = -1,//
    XYERR_DEVICE_OPENFAIL = -2,//
    XYERR_DEVICE_NOTCONNECTED = -3,
    XYERR_DEVICE_UNAUTHORIZED = -4,
    XYERR_DEVICE_NOTSUPPORTED = -5,
    
} BluErrorCode;

typedef enum : NSUInteger {
    A4,//
    A5,//
} BordType;

/**
    蓝牙扫描
 */
@protocol ZXYBScanDeviceDelegate <NSObject>
//    @required
//    -(void) onStartSca;
//    @required
//    -(void) onStopScan;
    @required
    -(void) onScanDevice:(CBPeripheral *)peripheral;

    @required
    -(void)onScanError;
@end
/**
    蓝牙返回数据
 */
@protocol ZXYBDataAvailableDelegate <NSObject>
    @required
    -(void) onXYPackDataProc:(ZXYBDataPacket *) o;
    @required
    -(void) onXYEnvNotifyProc:(ZXYBEnvPacket *) o;
    @required
    -(void) onBtnIndexCallBack:(int) btn_index;
    @required
    -(void) onSoftKeyCallBack:(int) btn_index;
@end

/**
    蓝牙返回数据(离线)
 */
@protocol ZXYBStoragePageDelegate <NSObject>
    @required
    -(void) onPageDataWithPageIndex:(int)pageIndex withPageData:(ZXYBPage *)page;
    @required
    -(void) onStorageInfoWithPageNum:(int)pageNum withMemPercent:(int)memPercent;
    @required
    -(void) onErrCodeWithPageIndex:(int)pageIndex withErrCode:(int)errCode;
    @required
    -(void) onProgressWithPageIndex:(int)pageIndex  WithPageNum:(int)pageNum WithBlockProgress:(int)blockProgress WithBlockTotalProgess:(int)blockTotalProgess WithCurPos:(int)curPos;
@end

//***************** 类开始 *********************************************************

@interface ZXYBManager : NSObject

/***  蓝牙扫描协议 */
@property(nonatomic,strong) id<ZXYBScanDeviceDelegate> deviceDelegate;
/***  蓝牙传输数据协议 */
@property(nonatomic,strong) id<ZXYBDataAvailableDelegate> devDataDelegate;

/***  蓝牙传输数据协议 (离线) */
@property(nonatomic,strong) id<ZXYBStoragePageDelegate> storagePageDelegate;
//*****************  函数 *********************************************************

/***  单例 */
+ (instancetype)sharedInstance;

/***  搜索外设 */
- (int)searchDevice:(id<ZXYBScanDeviceDelegate>)deviceDelegate;

-(void)stopScan;

/***   连接外设 */
- (void)connectionPeripheral:(CBPeripheral *)peripheral Completion:(id<ZXYBDataAvailableDelegate>)delegate;

/**
 * @param boardType 0 A4 ;1 A5
*/
-(int) initializeWithType:(int) boardType;

/**
 *  设置工作区域
*/
-(void)setWorkRectFWithWidth:(CGFloat)width withHeight:(CGFloat)height withEqualratio:(BOOL)isEqualratio;

/***   断开外设 */
- (void)cancelConnectionPeripheral;

/***   获取外设信息 */
-(ZXYBDeviceInfo *) getXYDeviceInfo;

/** 查询离线数据*/
-(void)selectHistory;

/** 写入手写板命令*/
-(BOOL)writeCharacteristic:(NSString *)cmd;

/** 开始下载历史数据*/
-(int)loadStoragePagesWithPageNum:(int)pageNum withStartPageint:(int)startPage withStartCursor:(int)startCursor;
@end

NS_ASSUME_NONNULL_END
