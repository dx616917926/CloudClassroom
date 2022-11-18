//
//  HXExamSessionManager.h
//  CloudClassroom
//
//  Created by mac on 2022/11/9.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN


///1、获取考试列表  {moduleCode}  班级里已开通模块
#define    HXEXAM_MODULES_LIST    @"/exam-admin/home/module/exams/mobile/code/%@"  //

///2、开始考试  用于考试数据的初始化，得到考试试卷和考试服务器的url      {examId} 考试模块id
#define   HXEXAM_START_JSON       @"/exam-admin/home/my/exam/start/json/%@?credit=true&site_preference=mobile&ct=client"



@interface HXExamSessionManager : AFHTTPSessionManager


/**
 @return HXBaseURLSessionManager
 */
+ (instancetype)sharedClient;


//修改baseURL
+(void)setBaseURLStr:(NSString *)baseURL;

/**
 普通GET请求
 */
+ (void)getDataWithNSString:(NSString * _Nullable)actionUrlStr
             withDictionary:(NSDictionary * _Nullable)nsDic
                    success:(void (^)(NSDictionary* _Nullable dictionary))success
                    failure:(void (^)(NSError * _Nullable error))failure;

/**
 普通POST请求
 */
+ (void)postDataWithNSString : (NSString * _Nullable)actionUrlStr
                     needMd5 : (BOOL )needMd5
              withDictionary : (NSDictionary * _Nullable)nsDic
                     success : (void (^)(NSDictionary * _Nullable dictionary))success
                     failure : (void (^)(NSError * _Nullable error))failure;
                     


/**清除cookie
 */
- (void)clearCookies;

+(NSString *)getsession:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
