//
//  ZXYBEnvPacket.h
//  ZXYBSDK
//
//  Created by 朱先生 on 2021/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXYBEnvPacket : NSObject

@property(nonatomic,assign)int flag;
@property(nonatomic,assign)int status;
@property(nonatomic,assign)int penBattery;
@property(nonatomic,assign)int isSleep;

@end

NS_ASSUME_NONNULL_END
