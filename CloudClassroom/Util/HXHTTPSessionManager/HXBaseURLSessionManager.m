//
//  HXBaseURLSessionManager.m
//  HXCloudClass
//
//  Created by Mac on 2020/6/19.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import "HXBaseURLSessionManager.h"
#import "HXCheckUpdateTool.h"
#import "NSString+md5.h"

@implementation HXBaseURLSessionManager

+ (instancetype)sharedClient {
    
    static HXBaseURLSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *baseUreStr = [HXPublicParamTool sharedInstance].schoolDomainURL;
        _sharedClient = [[HXBaseURLSessionManager alloc] initWithBaseURL:HXSafeURL(baseUreStr)];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.requestSerializer.timeoutInterval = 30;
        
    });
    
    return _sharedClient;
}

//修改baseURL
+(void)setBaseURLStr:(NSString *)baseURLStr{
    [[HXBaseURLSessionManager sharedClient] setValue:[NSURL URLWithString:baseURLStr] forKey:NSStringFromSelector(@selector(baseURL))];
}

-(void)clearCookies
{
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

+ (void)doLoginWithUserName:(NSString *)userName
                andPassword:(NSString *)pwd
                   success : (void (^)(NSDictionary* dictionary))success
                   failure : (void (^)(NSString *message))failure
{
    HXBaseURLSessionManager *client = [HXBaseURLSessionManager sharedClient];
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userName forKey:@"userName"];
    [parameters setObject:pwd forKey:@"password"];
    
    [client POST:HXPOST_LOGIN parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dictionary) {
        
        NSLog(@"请求地址:%@",task.currentRequest.URL);
        NSLog(@"请求参数:%@",parameters);
        if(dictionary){
            NSString*code = [dictionary stringValueForKey:@"code"];
            NSString*message = [dictionary stringValueForKey:@"message"];
            if(![dictionary boolValueForKey:@"success"]){
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:message];
            }
            success(dictionary);
        }else{
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"请求地址:%@",task.currentRequest.URL);
        NSLog(@"请求参数:%@",parameters);
        failure(error.localizedDescription);
    }];
}

+ (void)getDataWithNSString : (NSString *)actionUrlStr
             withDictionary : (NSDictionary *) nsDic
                    success : (void (^)(NSDictionary* dictionary))success
                    failure : (void (^)(NSError *error))failure
{
    
    HXBaseURLSessionManager * client = [HXBaseURLSessionManager sharedClient];
    
    NSString *baseUreStr = [HXPublicParamTool sharedInstance].currentSchoolModel.schoolDomainURL;
    [[self class] setBaseURLStr:baseUreStr];
    
    NSMutableDictionary * parameters = [client commonParameters];
    
    [parameters addEntriesFromDictionary:nsDic];
    
    [client GET:actionUrlStr parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dictionary) {
        NSLog(@"请求地址:%@",task.currentRequest.URL);
        NSLog(@"请求参数:%@",parameters);
        if(dictionary){
            NSString*code = [dictionary stringValueForKey:@"code"];
            NSString*message = [dictionary stringValueForKey:@"message"];
            if ([code isEqualToString:@"1000"]) {//StatusCode 1000登录失败，1001登录成功
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:message completionBlock:^{
                    [HXNotificationCenter postNotificationName:SHOWLOGIN object:nil];
                }];
            }else if([code isEqualToString:@"999"]){//999 强制更新
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:message completionBlock:^{
                    [[HXCheckUpdateTool sharedInstance] checkUpdate];
                }];
                
            }else if(![dictionary boolValueForKey:@"success"] ){
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:message];
            }
            success(dictionary);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求地址:%@",task.currentRequest.URL);
        NSLog(@"请求参数:%@",parameters);
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        NSLog(@"接口错误信息%@",response);
        failure(error);
    }];
}

+ (void)postDataWithNSString : (NSString *)actionUrlStr
              withDictionary : (NSDictionary *)nsDic
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure
{
    HXBaseURLSessionManager * client = [HXBaseURLSessionManager sharedClient];
    //请求头设置
    [client.requestSerializer  setValue:[HXPublicParamTool sharedInstance].token forHTTPHeaderField:@"Authorization"];
    NSLog(@"=====token====:%@",[HXPublicParamTool sharedInstance].token);
    //md5=所有请求参数（除md5外）,按照ASIIC码升序排列，然后通过&拼接，最后加上密钥，生成md5值。
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    if(nsDic!=nil){
        NSString *md5Str = [self getMd5String:nsDic];
        NSDictionary *md5Dic = @{@"md5":HXSafeString(md5Str)};
        [parameters addEntriesFromDictionary:md5Dic];
        [parameters addEntriesFromDictionary:nsDic];
    }
    [client POST:actionUrlStr parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dictionary) {
        
        NSLog(@"___请求地址___:%@",task.currentRequest.URL);
        NSLog(@"=====请求参数====:%@",parameters);
        //401:表示token失效   402:表示被踢，需要重新登录
        NSString*code = [dictionary stringValueForKey:@"code"];
        NSString*message = [dictionary stringValueForKey:@"message"];
        if(dictionary){
            if ([code isEqualToString:@"402"]) {//402表示被踢，需要重新登录
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:message completionBlock:^{
                    [HXNotificationCenter postNotificationName:SHOWLOGIN object:nil];
                }];
                success(dictionary);
            }else if ([code isEqualToString:@"401"]) {//401表示token失效
                //重新获取token,再次发起请求
                [[self class] refreshTokeCallBack:^(bool sc) {
                    if(sc){
                        //刷新token，重新调取原来接口
                        [[self class] postDataWithNSString:actionUrlStr withDictionary:nsDic success:^(NSDictionary * _Nonnull dictionary) {
                            success(dictionary);
                        } failure:^(NSError * _Nonnull error) {
                            failure(error);
                        }];
                    }else{
                        [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:@"获取数据失败，请刷新"];
                        failure(nil);
                    }
                }];
            }else{
                if (![dictionary boolValueForKey:@"success"]) {
                    [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:message];
                }
                success(dictionary);
            }
        }else{
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"___请求地址___:%@",task.currentRequest.URL);
        NSLog(@"=====请求参数=====:%@",parameters);
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        NSLog(@"++++++接口错误信息+++++++:%@",response);
        if (![HXCommonUtil isNull:[error localizedDescription]]) {
            [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:[error localizedDescription]];
        }
        failure(error);
    }];
}

//刷新JWT的Token(如果返回false,则表示要重新登录)
+ (void)refreshTokeCallBack:(void (^)(bool success))callBack
{
    HXBaseURLSessionManager * client = [HXBaseURLSessionManager sharedClient];
    [[self class] setBaseURLStr:@"http://xueliapitest.edu-cj.com"];
    //请求头设置
    [client.requestSerializer  setValue:[HXPublicParamTool sharedInstance].token forHTTPHeaderField:@"Authorization"];
    NSLog(@"=====token====:%@",[HXPublicParamTool sharedInstance].token);
    NSDictionary *parameters = @{@"userName":HXSafeString([HXPublicParamTool sharedInstance].personId)};
    [client POST:HXPOST_RefreshToken parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dictionary) {
        NSString*code = [dictionary stringValueForKey:@"code"];
        NSString*message = [dictionary stringValueForKey:@"message"];
        if ([code isEqualToString:@"402"]) {//402表示被踢，需要重新登录
            [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:message completionBlock:^{
                [HXNotificationCenter postNotificationName:SHOWLOGIN object:nil];
            }];
        }else if([dictionary boolValueForKey:@"success"]){
            NSString*token = [dictionary[@"data"] stringValueForKey:@"token"];
            [HXPublicParamTool sharedInstance].token = token;
            callBack(YES);
        }else{
            callBack(NO);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callBack(NO);
    }];
}


+ (void)doLogout{
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_LOGIN withDictionary:nil success:^(NSDictionary * _Nonnull dictionary) {
        //
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSLog(@"退出登录成功！");
        }else{
            NSLog(@"退出登录失败！");
        }
    } failure:^(NSError * _Nonnull error) {
        //
        NSLog(@"退出登录失败！");
    }];
}

/// 公共请求参数
- (NSMutableDictionary *)commonParameters{
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    NSString *personID = [HXPublicParamTool sharedInstance].personId;
    NSString *studentID = [HXPublicParamTool sharedInstance].student_id;
    NSString *majorID = [HXPublicParamTool sharedInstance].major_id;
    if (personID) {
        [parameters setObject:personID forKey:@"personID"];
    }
    if (studentID) {
        [parameters setObject:studentID forKey:@"studentID"];
    }
    if (majorID) {
        [parameters setObject:majorID forKey:@"majorID"];
    }
    return parameters;
}

/// md5=所有请求参数（除md5外）,按照ASIIC码升序排列，然后通过&拼接，最后加上密钥【1poiulk*&】，生成md5值。
+ (NSString *)getMd5String:(NSDictionary *)dic{
    // 将dic中的全部key取出，并放到数组
    NSArray *keyArray = [dic allKeys];
    // 根据ASCII码,将参数key从小到大排序（升序）
    NSArray *resultArr = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *paramValueArr = [NSMutableArray arrayWithCapacity:resultArr.count];
    for (NSString *str in resultArr) {
        // 将key对应的value，存到数组
        NSString *tempValue = [dic stringValueForKey:str];
        if (tempValue.length > 0) {
            [paramValueArr addObject:[NSString stringWithFormat:@"%@=%@",str,tempValue]];
        }
    }
    //最后加上密钥
    [paramValueArr addObject:Md5Key];
    NSString *paramStr = [paramValueArr componentsJoinedByString:@"&"];
    NSLog(@"______________字符串拼接后结果_________:%@",paramStr);
    NSString *md5String = [paramStr md5String];
    NSLog(@"___________md5加密_________:%@",md5String);
    return md5String;
    
}

@end
