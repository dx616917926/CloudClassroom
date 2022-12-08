//
//  HXExamSessionManager.m
//  CloudClassroom
//
//  Created by mac on 2022/11/9.
//

#import "HXExamSessionManager.h"
#import "HXCheckUpdateTool.h"
#import "NSString+md5.h"

@interface HXExamSessionManager ()


@end

@implementation HXExamSessionManager

+ (instancetype)sharedClient {
    
    static HXExamSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HXExamSessionManager alloc] init];
        _sharedClient.requestSerializer= [AFHTTPRequestSerializer serializer];//非json请求
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];//json返回
        _sharedClient.requestSerializer.timeoutInterval = 60;
    });
    return _sharedClient;
}

#pragma mark - 修改baseURL
+(void)setBaseURLStr:(NSString *)baseURLStr{
    [[HXExamSessionManager sharedClient] setValue:[NSURL URLWithString:baseURLStr] forKey:NSStringFromSelector(@selector(baseURL))];
}



#pragma mark - GET请求
+ (void)getDataWithNSString : (NSString *)actionUrlStr
             withDictionary : (NSDictionary *) nsDic
                    success : (void (^)(NSDictionary* dictionary))success
                    failure : (void (^)(NSError *error))failure
{
    
    HXExamSessionManager * client = [HXExamSessionManager sharedClient];
    
    
    [client GET:actionUrlStr parameters:nsDic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dictionary) {
        NSLog(@"\n==============================请求地址==============================\n%@\n",task.currentRequest.URL);
        NSLog(@"\n______________________请求参数______________________\n%@\n",nsDic);
//        NSString*code = [dictionary stringValueForKey:@"code"];
//        NSString*message = [dictionary stringValueForKey:@"message"];
        if(dictionary){
            success(dictionary);
        }else{
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n==============================请求地址==============================\n%@\n",task.currentRequest.URL);
        NSLog(@"\n______________________请求参数______________________\n%@\n",nsDic);
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        NSLog(@"接口错误信息%@",response);
        failure(error);
    }];
}

#pragma mark - POST请求
+ (void)postDataWithNSString : (NSString * _Nullable)actionUrlStr
                     needMd5 : (BOOL )needMd5
                     pingKey : (NSString *_Nullable)pingKey
              withDictionary : (NSDictionary * _Nullable)nsDic
                     success : (void (^)(NSDictionary* _Nullable dictionary))success
                     failure : (void (^)(NSError * _Nullable error))failure
{
   
    HXExamSessionManager * client = [HXExamSessionManager sharedClient];
   
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    if(needMd5){
        //md5=所有请求参数（除md5外）,按照ASIIC码升序排列，然后通过&拼接，最后加上密钥，生成md5值。
        NSString *md5Str = [self getMd5String:nsDic pingKey:pingKey];
        NSDictionary *md5Dic = @{@"m":HXSafeString(md5Str)};
        [parameters addEntriesFromDictionary:nsDic];
        [parameters addEntriesFromDictionary:md5Dic];
    }else{
        [parameters addEntriesFromDictionary:nsDic];
    }
    [client POST:actionUrlStr parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dictionary) {
        
        NSLog(@"\n===============================请求地址==============================\n%@\n",task.currentRequest.URL);
        NSLog(@"\n______________________请求参数______________________\n%@\n",parameters);
        //401:表示token失效   402:表示被踢，需要重新登录
        NSString*code = [dictionary stringValueForKey:@"code"];
        NSString*message = [dictionary stringValueForKey:@"message"];
        NSLog(@"\n______________________code______________________\n%@\n",code);
        if(dictionary){
            success(dictionary);
        }else{
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n==============================请求地址==============================\n%@\n",task.currentRequest.URL);
        NSLog(@"\n______________________请求参数______________________\n%@\n",parameters);
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        NSLog(@"\n______________________接口错误信息______________________\n%@\n",response);
        if (![HXCommonUtil isNull:[error localizedDescription]]) {
            [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:[error localizedDescription]];
        }
        failure(error);
        
    }];
}



#pragma mark -  md5=所有请求参数（除md5外）,按照ASIIC码升序排列，然后通过&拼接，最后加上密钥Md5Key，生成md5值。
+ (NSString *)getMd5String:(NSDictionary *)dic pingKey:(NSString *)pingKey{
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
        [paramValueArr addObject:[NSString stringWithFormat:@"%@=%@",str,tempValue]];
    }
    //最后加上密钥
    if (pingKey) {
        [paramValueArr addObject:pingKey];
    }
    NSString *paramStr = [[paramValueArr componentsJoinedByString:@"&"] lowercaseString];
    NSLog(@"\n______________________字符串拼接后结果______________________\n%@\n",paramStr);
    NSString *md5String = [paramStr md5String];
    return md5String;
    
}



#pragma mark - 清除cookie
-(void)clearCookies
{
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

#pragma mark - 获取session

+(NSString *)getsession:(NSString *)url{

    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:url]];
    NSString *sessionId;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"JSESSIONID"]) {
            NSDictionary *properties = cookie.properties;
            sessionId = properties[@"Value"];
            break;
        }
    }
    return sessionId;
}

@end

