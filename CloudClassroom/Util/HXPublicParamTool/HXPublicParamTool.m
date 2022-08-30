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

@synthesize currentYear = _currentYear, userId = _userId, accessToken = _accessToken,username = _username,mobilePhone = _mobilePhone,email = _email,isLaunch = _isLaunch,accountantNoDate = _accountantNoDate, skillGrade = _skillGrade, partnerId = _partnerId,homeUrl = _homeUrl,logoUrl = _logoUrl,partnerName = _partnerName,code = _code,userCode = _userCode,token=_token,privacyUrl=_privacyUrl;

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

- (NSUserDefaults *)userDefault{
    if (!_userDefault) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    return _userDefault;
}

- (BOOL)isLogin{
    return [self.userDefault boolForKey:@"islogin"];
}
- (void)setIsLogin:(BOOL)isLogin{
    [self.userDefault setBool:isLogin forKey:@"islogin"];
}

- (BOOL)isLaunch{
    return [self.userDefault boolForKey:@"isLaunch"];
}
- (void)setIsLaunch:(BOOL)isLaunch{
    [self.userDefault setBool:isLaunch forKey:@"isLaunch"];
}

- (NSString *)token{
    if (!_token) {
        _token = [self.userDefault objectForKey:@"token"];
    }
    return _token;
}
- (void)setToken:(NSString *)token{
    _token = token;
    [self.userDefault setObject:token forKey:@"token"];
}

- (NSString *)partnerId{
    if (!_partnerId) {
        _partnerId = [self.userDefault objectForKey:@"partnerId"];
    }
    return _partnerId;
}
- (void)setpartnerId:(NSString *)partnerId{
    _partnerId = partnerId;
    [self.userDefault setObject:partnerId forKey:@"partnerId"];
}

- (NSString *)accessToken{
    if (!_accessToken) {
        _accessToken = [self.userDefault objectForKey:@"accessToken"];
    }
    return _accessToken;
}
- (void)setAccessToken:(NSString *)accessToken{
    _accessToken = accessToken;
    [self.userDefault setObject:accessToken forKey:@"accessToken"];
}

- (NSString *)homeUrl{
    if (!_homeUrl) {
        _homeUrl = [self.userDefault objectForKey:@"homeUrl"];
    }
    return _homeUrl;
}
- (void)setHomeUrl:(NSString *)homeUrl{
    _homeUrl = homeUrl;
    [self.userDefault setObject:homeUrl forKey:@"homeUrl"];
}

- (NSString *)logoUrl{
    if (!_logoUrl) {
        _logoUrl = [self.userDefault objectForKey:@"logoUrl"];
    }
    return _logoUrl;
}
- (void)setLogoUrl:(NSString *)logoUrl{
    _logoUrl = logoUrl;
    [self.userDefault setObject:logoUrl forKey:@"logoUrl"];
}

- (NSString *)partnerName{
    if (!_partnerName) {
        _partnerName = [self.userDefault objectForKey:@"partnerName"];
    }
    return _partnerName;
}
- (void)setPartnerName:(NSString *)partnerName{
    _partnerName = partnerName;
    [self.userDefault setObject:partnerName forKey:@"partnerName"];
}

- (NSString *)code{
    if (!_code) {
        _code = [self.userDefault objectForKey:@"code"];
    }
    return _code;
}
- (void)setCode:(NSString *)code{
    _code = code;
    [self.userDefault setObject:code forKey:@"code"];
}

- (NSString *)userId{
    if (!_userId) {
        _userId = [self.userDefault objectForKey:@"userId"];
    }
    return _userId;
}
- (void)setUserId:(NSString *)userId{
    _userId = userId;
    [self.userDefault setObject:userId forKey:@"userId"];
}

- (NSString *)userCode{
    if (!_userCode) {
        _userCode = [self.userDefault objectForKey:@"userCode"];
    }
    return _userCode;
}
- (void)setUserCode:(NSString *)userCode{
    _userCode = userCode;
    [self.userDefault setObject:userCode forKey:@"userCode"];
}

- (NSString *)currentYear{
    if (!_currentYear) {
        _currentYear = [self.userDefault objectForKey:@"currentYear"];
    }
    return _currentYear;
}
- (void)setCurrentYear:(NSString *)currentYear{
    _currentYear = currentYear;
    [self.userDefault setObject:currentYear forKey:@"currentYear"];
}

- (NSString *)privacyUrl{
    if (!_privacyUrl) {
        _privacyUrl = [self.userDefault objectForKey:@"privacyUrl"];
    }
    return _privacyUrl;
}
- (void)setPrivacyUrl:(NSString *)privacyUrl{
    _privacyUrl = privacyUrl;
    [self.userDefault setObject:privacyUrl forKey:@"privacyUrl"];
}


- (void)logOut {
    
    //清除内存中数据
    self.accessToken = nil;
    self.userId = nil;
    self.accountantNoDate = nil;
    self.skillGrade = nil;
    self.avatarImageUrl = nil;
    self.level = nil;
    self.levelName = nil;
    self.nowIntegral = nil;
    self.growthValue = nil;
    self.isLogin = NO;
    self.isLaunch = NO;
    self.mobilePhone = nil;
    self.email = nil;
    self.yearArray = nil;
    self.code = nil;
    self.userCode = nil;
    
    //清除沙盒中数据
    [self.userDefault removeObjectForKey:@"islogin"];
    [self.userDefault removeObjectForKey:@"isLaunch"];
    [self.userDefault removeObjectForKey:@"code"];
    [self.userDefault removeObjectForKey:@"partnerId"];
    [self.userDefault removeObjectForKey:@"currentYear"];
    [self.userDefault removeObjectForKey:KP_SERVER_KEY];
    [self.userDefault synchronize];
    

}

@end
