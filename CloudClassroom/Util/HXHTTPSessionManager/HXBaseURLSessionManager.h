//
//  HXBaseURLSessionManager.h
//  HXCloudClass
//
//  Created by Mac on 2020/6/19.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

/*******************************************************************************登录*******************************************************************************************************/
#define HXPOST_GetDomainNameList                                  @"/api/User/GetList"//获取域名

//刷新JWT的Token（如果返回false，则表示要重新登录）
#define HXPOST_RefreshToken                                        @"/api/Login/RefreshToken"

//登录
#define HXPOST_LOGIN                                              @"/api/Login/Login"

//找回密码
#define HXPOST_FindPassword                                       @"/api/Login/FindPassword"

//通过手机号获取验证码
#define HXPOST_GetVCode                                           @"/api/Login/GetVCode"


/*******************************************************************************补考相关操作*******************************************************************************************************/
//获取补考列表
#define HXPOST_GetBKList                                           @"/api/BKList/GetBKList"

//获取补考考试列表
#define HXPOST_GetBKExamList                                       @"/api/BKList/GetBKExamList"


/*******************************************************************************正考相关操作*******************************************************************************************************/
//获取学习列表(当前学期和全部学期)
#define HXPOST_GetOnlineCourseList                                 @"/api/CourseList/GetOnlineCourseList"

//获取正考考试列表和看课列表
#define HXPOST_GetExamList                                         @"/api/CourseList/GetExamList"

//播放课件
#define HXPOST_BeginCourse                                         @"/api/CourseList/BeginCourse"

//班级排名
#define HXPOST_GetClassRank                                        @"/api/CourseList/GetClassRank"

//学习报告
#define HXPOST_GetCourseReport                                     @"/api/CourseList/GetCourseReport"

//教学计划
#define HXPOST_GetClassPlan                                        @"/api/CourseList/GetClassPlan"



/*******************************************************************************学员首页相关接口*******************************************************************************************************/
//获取首页信息
#define HXPOST_GetHomeStudentInfo                                  @"/api/MyHomeIndex/GetHomeStudentInfo"

//获取首页专业信息
#define HXPOST_GetHomeMajorInfo                                    @"/api/MyHomeIndex/GetHomeMajorInfo"

//获取首页公告信息
#define HXPOST_GetHomeMessageInfo                                  @"/api/MyHomeIndex/GetHomeMessageInfo"

//获取首页菜单
#define HXPOST_GetHomeMenu                                         @"/api/MyHomeIndex/GetHomeMenu"



/*******************************************************************************人脸识别相关信息*******************************************************************************************************/
//获取人脸识别设置
#define HXPOST_GetFaceSet                                          @"/api/FaceList/GetFaceSet"

//人脸识别
#define HXPOST_FaceMatch                                           @"/api/FaceList/FaceMatch"




/*******************************************************************************成绩相关操作*******************************************************************************************************/
//成绩查询
#define HXPOST_GetScoreClassPlan                                   @"/api/ScoreList/GetClassPlan"




/*******************************************************************************考试相关接口*******************************************************************************************************/
//开始考试
#define HXPOST_BeginExam                                           @"/api/ExamList/BeginExam"

//获取考试记录列表
#define HXPOST_GetExamRecordList                                   @"/api/ExamList/GetExamRecordList"

//继续考试与查看答案(只有提交试卷后的试卷才可以查看答案)
#define HXPOST_ContinueExam                                        @"/api/ExamList/ContinueExam"

//试题每题提交答案
#define HXPOST_SaveSingleQuestion                                  @"/api/ExamList/SaveSingleQuestion"

//提交试卷
#define HXPOST_SavePaper                                           @"/api/ExamList/SavePaper"

//错题反馈
#define HXPOST_SaveErrorFeedback                                   @"/api/ExamList/SaveErrorFeedback"




@interface HXBaseURLSessionManager : AFHTTPSessionManager

/**
 @return HXBaseURLSessionManager
 */
+ (instancetype)sharedClient;

- (void)clearCookies;

//修改baseURL
+(void)setBaseURLStr:(NSString *)baseURL;
/**
 登录请求
 */
+ (void)doLoginWithUserName:(NSString *)userName
                andPassword:(NSString *)pwd
                    success:(void (^)(NSDictionary* dictionary))success
                    failure:(void (^)(NSString *messsage))failure;

/**
 普通GET请求
 */
+ (void)getDataWithNSString:(NSString *)actionUrlStr
             withDictionary:(nullable NSDictionary *) nsDic
                    success:(void (^)(NSDictionary* dictionary))success
                    failure:(void (^)(NSError *error))failure;

/**
 普通POST请求
 */
+ (void)postDataWithNSString : (NSString *)actionUrlStr
                     needMd5 : (BOOL )needMd5
              withDictionary : (NSDictionary *)nsDic
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure;
                     

/**刷新JWT的Token(如果返回false,则表示要重新登录)
 */
+ (void)refreshTokeCallBack:(void (^)(bool success))callBack;



@end

NS_ASSUME_NONNULL_END
