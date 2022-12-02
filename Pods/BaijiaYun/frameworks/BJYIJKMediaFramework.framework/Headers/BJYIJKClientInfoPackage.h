//
//  BJYIJKClientInfoPackage.h
//  BJYIJKMediaFramework
//
//  Created by 李亮 on 2022/6/9.
//  Copyright © 2022 bilibili. All rights reserved.
//

#ifndef BJYIJKMediaInfoPackage_h
#define BJYIJKMediaInfoPackage_h

#import <Foundation/Foundation.h>

@interface BJYIJKClientInfoPackage : NSObject
@property(nonatomic)  NSInteger sampleTime;
@property(nonatomic)  NSInteger reportInterval;
@property(nonatomic)  NSString *appId;
@property(nonatomic)  NSString *roomId;
@property(nonatomic)  NSString *userId;
@property(nonatomic)  NSString *userNumber;
@property(nonatomic)  NSString *comments;
@property(nonatomic)  NSString *url;
@property(nonatomic)  NSInteger source;
@property(nonatomic)  NSString *reportId;
@property(nonatomic)  NSString *eid;
@property(nonatomic)  NSString *deviceId;
@property(nonatomic)  NSInteger ts;
@property(nonatomic)  NSString *platform;
@property(nonatomic)  NSString *device;
@property(nonatomic)  NSString *network;
@property(nonatomic)  NSInteger seq;
@property(nonatomic)  bool isAppToggleBackground;
@end

#endif /* BJYIJKMediaInfoPackage_h */
