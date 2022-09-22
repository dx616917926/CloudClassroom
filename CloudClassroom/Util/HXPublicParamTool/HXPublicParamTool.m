//
//  HXPublicParamTool.m
//  HXCloudClass
//
//  Created by Mac on 2020/7/22.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import "HXPublicParamTool.h"

@interface HXPublicParamTool()

@property (nonatomic,strong)NSUserDefaults * userDefault;

@end


@implementation HXPublicParamTool

@synthesize isLogin = _isLogin , userId = _userId , accessToken = _accessToken;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HXPublicParamTool *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}


+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}


#pragma mark - Setter/Getter
- (NSUserDefaults *)userDefault{
    if (!_userDefault) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    return _userDefault;
}

- (BOOL)isLogin{
    if (!_isLogin) {
        _isLogin = [self.userDefault boolForKey:@"islogin"];
    }
    return _isLogin;
}
- (void)setIsLogin:(BOOL)isLogin{
    _isLogin = isLogin;
    [self.userDefault setBool:isLogin forKey:@"islogin"];
}

-(void)setUserId:(NSString *)userId{
    _userId = userId;
    [self.userDefault setObject:userId forKey:@"userId"];
}

-(NSString *)userId{
    if (!_userId) {
        _userId = [self.userDefault objectForKey:@"userId"];
    }
    return _userId;
}


- (void)logOut {
    
    //清除内存中数据
    self.accessToken = nil;
    self.userId = nil;

    //清除沙盒中数据
    [self.userDefault removeObjectForKey:@"islogin"];
    [self.userDefault removeObjectForKey:@"isLaunch"];
    [self.userDefault removeObjectForKey:KP_SERVER_KEY];
    [self.userDefault synchronize];
    

}

@end
