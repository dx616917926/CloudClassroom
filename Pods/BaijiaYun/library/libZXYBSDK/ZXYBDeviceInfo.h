	//
//  ZXYBDeviceInfo.h
//  ZXYBSDK
//
//  Created by 朱先生 on 2021/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXYBDeviceInfo : NSObject

@property (nonatomic,assign) int boardType;
@property (nonatomic,assign) int maxX;
@property (nonatomic,assign) int maxY;
@property (nonatomic,assign) int pressure;

@property (nonatomic,strong) NSString *bleAdress;
@property (nonatomic,strong) NSString *bleName;
   //序列号
@property (nonatomic,strong) NSString *serialnum;
   //厂商名称
@property (nonatomic,strong) NSString *vendor;
   //产品名称
@property (nonatomic,strong) NSString *product;
   //版本号
@property (nonatomic,strong) NSString *version;


- (instancetype)initWithBoardType:(int)boardType withMaxX:(int)maxX withMaxY:(int)maxY withPressure:(int)pressure;


@end

NS_ASSUME_NONNULL_END
