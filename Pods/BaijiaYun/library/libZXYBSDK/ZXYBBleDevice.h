//
//  ZXYBBleDevice.h
//  ZXYBSDK
//
//  Created by 朱先生 on 2021/2/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXYBBleDevice : NSObject

@property(nonatomic,strong)NSString *address;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,assign)int rssi;
@property(nonatomic,assign)int type;
@property(nonatomic,strong)NSMutableArray *scanRecord;

@end

NS_ASSUME_NONNULL_END
