//
//  HXPublicParamTool.h
//  HXCloudClass
//
//  Created by Mac on 2020/7/22.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HXPublicParamTool : NSObject

+ (instancetype)sharedInstance;

//是否登录成功
@property(nonatomic,assign) BOOL isLogin;
//userId
@property (nonatomic, strong) NSString *userId;
//token
@property (nonatomic, strong) NSString *accessToken;

//退出登录
- (void)logOut;

@end
