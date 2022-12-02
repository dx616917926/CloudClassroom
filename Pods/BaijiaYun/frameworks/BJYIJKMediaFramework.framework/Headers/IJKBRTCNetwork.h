//
//  BRTCNetwork.h
//  BRTC
//
//  Created by xyp on 2020/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IJKBRTCNetwork : NSObject

+ (NSString *)networkStatus;

///
+ (int)getWifiSignalStrength;

+ (void)requestGet:(NSString *)requestUrl callback:(void (^)(NSData *_Nullable data, NSError *_Nullable error))callback;
+ (void)requestPost:(NSString *)requestUrl jsonData:(NSData *)jsonData callback:(void (^)(NSData *_Nullable data, NSError *_Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
