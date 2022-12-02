//
//  BJRTCConfig.h
//  RTCatSDK
//
//  Created by 辛亚鹏 on 2018/8/8.
//  Copyright © 2018年 xinyapeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJRTCConfig : NSObject

@property (nonatomic, readonly) NSString *apiURL;
@property (nonatomic, readonly) NSString *wssURL;
@property (nonatomic, assign) NSString *signalingURL;
@property (nonatomic, readonly) NSString *tokenForTest;
@property (nonatomic, readonly) NSTimeInterval sessionTimeOut;
@property (nonatomic, strong) NSArray *iceServers;

+ (instancetype)sharedInstance;

@end
