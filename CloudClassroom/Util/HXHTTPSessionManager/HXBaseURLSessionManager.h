//
//  HXBaseURLSessionManager.h
//  HXCloudClass
//
//  Created by Mac on 2020/6/19.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN



#pragma mark ----------------------------------------------登录-------------------------------------------------

#define HXPOST_GetDomainNameList                                  @"/api/User/GetList"//获取域名

//刷新JWT的Token（如果返回false，则表示要重新登录）
#define HXPOST_RefreshToken                                        @"/api/Login/RefreshToken"

//登录
#define HXPOST_LOGIN                                              @"/api/Login/Login"

//找回密码
#define HXPOST_FindPassword                                       @"/api/Login/FindPassword"

//通过手机号获取验证码
#define HXPOST_GetVCode                                           @"/api/Login/GetVCode"

///修改密码
#define HXPOST_UpdatePassword                                     @"/api/Login/UpdatePassword"



#pragma mark ----------------------------------------------补考相关操作-------------------------------------------------

//获取补考列表
#define HXPOST_GetBKList                                           @"/api/BKList/GetBKList"

//获取补考考试列表
#define HXPOST_GetBKExamList                                       @"/api/BKList/GetBKExamList"


#pragma mark ----------------------------------------------正考相关操作-------------------------------------------------

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



#pragma mark ----------------------------------------------学员首页相关接口-------------------------------------------------

//获取首页信息
#define HXPOST_GetHomeStudentInfo                                  @"/api/MyHomeIndex/GetHomeStudentInfo"

//获取首页专业信息
#define HXPOST_GetHomeMajorInfo                                    @"/api/MyHomeIndex/GetHomeMajorInfo"

//获取首页公告信息
#define HXPOST_GetHomeMessageInfo                                  @"/api/MyHomeIndex/GetHomeMessageInfo"

//获取首页菜单
#define HXPOST_GetHomeMenu                                         @"/api/MyHomeIndex/GetHomeMenu"


#pragma mark ----------------------------------------------个人信息相关操作-------------------------------------------------

//获取个人信息
#define HXPOST_GetPersonalInfoList                                  @"/api/PersonalInfo/GetPersonalInfoList"

//信息无误确认
#define HXPOST_ConfirmYesor                                         @"/api/PersonalInfo/ConfirmYesor"

//学生确认签名
#define HXPOST_SaveStudentSignature                                 @"/api/PersonalInfo/SaveStudentSignature"

//显示签名照片
#define HXPOST_GetStudentSignature                                  @"/api/PersonalInfo/GetStudentSignature"


#pragma mark ----------------------------------------------资源下载-------------------------------------------------

//获取资源列表
#define HXPOST_GetResource                                  @"/api/MyResource/GetResource"


#pragma mark ----------------------------------------------人脸识别相关信息-------------------------------------------------

//获取人脸识别设置
#define HXPOST_GetFaceSet                                          @"/api/FaceList/GetFaceSet"

//人脸识别
#define HXPOST_FaceMatch                                           @"/api/FaceList/FaceMatch"


#pragma mark ----------------------------------------------成绩相关操作-------------------------------------------------

//总评成绩查询
#define HXPOST_GetZKScore                                   @"/api/ScoreList/GetZKScore"

//在线补考成绩查询
#define HXPOST_GetBKScore                                   @"/api/ScoreList/GetBKScore"

//成绩详情
#define HXPOST_GetZKScoreDetail                             @"/api/ScoreList/GetZKScoreDetail"



#pragma mark ----------------------------------------------考试相关接口-------------------------------------------------

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


#pragma mark ----------------------------------------------证件照上传-------------------------------------------------

//获取证件照信息
#define HXPOST_GetPapersPhotoInfo                                  @"/api/MyPhotoUpload/GetPapersPhotoInfo"

//上传证件照
#define HXPOST_SavePhotoUpload                                     @"/api/MyPhotoUpload/SavePhotoUpload"

//确认照片
#define HXPOST_ComfirmPhoto                                        @"/api/MyPhotoUpload/ComfirmPhoto"



#pragma mark ----------------------------------------------我的消息-------------------------------------------------

//获取我的消息
#define HXPOST_GetMessageInfo                                     @"/api/MyMessage/GetMessageInfo"

//消息一键已读
#define HXPOST_UpdateMessageStatusByStudentId                     @"/api/MyMessage/UpdateMessageStatusByStudentId"

//查看消息详情
#define HXPOST_GetMessageDetailInfo                               @"/api/MyMessage/GetMessageDetailInfo"

//获取未读消息数
#define HXPOST_GetNoReadCount                                     @"/api/MyMessage/GetNoReadCount"


#pragma mark ----------------------------------------------缴费相关操作-------------------------------------------------

//选课列表
#define HXPOST_GetCourseOrder                                     @"/api/OrderList/GetCourseOrder"

//已缴费列表
#define HXPOST_GetCoursePayOrder                                  @"/api/OrderList/GetCoursePayOrder"

//结算（去下单）
#define HXPOST_CourseOrderAdd                                     @"/api/OrderList/CourseOrderAdd"

//支付宝、微信支付
#define HXPOST_CourseOrderPay                                     @"/api/OrderList/Pay"



#pragma mark ----------------------------------------------财务缴费相关操作-------------------------------------------------

//财务缴费列表
#define HXPOST_GetFeeList                                         @"/api/FeeList/GetCourseFeeList"

//财务已缴费列表
#define HXPOST_GetCourseFeeHaveList                               @"/api/FeeList/GetCourseFeeHaveList"

//结算（去下单）
#define HXPOST_FeeOrderAdd                                        @"/api/FeeList/FeeOrderAdd"




#pragma mark ----------------------------------------------直播管理接口-------------------------------------------------

//直播课程列表
#define HXPOST_GetDirectBroadcastList                             @"/api/DirectBroadcastList/GetDirectBroadcastList"

//每一门课的直播列表
#define HXPOST_GetDirectBroadcastDetail                           @"/api/DirectBroadcastList/GetDirectBroadcastDetail"

//获取直播详情
#define HXPOST_GetLiveDetail                                      @"/api/DirectBroadcastList/GetLiveDetail"

//获取进入直播间的参数
#define HXPOST_GetEnterInfo                                       @"/api/DirectBroadcastList/GetEnterInfo"

//获取直播回放参数
#define HXPOST_GetPlayInfo                                        @"/api/DirectBroadcastList/GetPlayInfo"

//直播课程提醒
#define HXPOST_GetRemind                                          @"/api/DirectBroadcastList/GetRemind"

//直播签到
#define HXPOST_SignFaceMatchInfo                                  @"/api/DirectBroadcastList/SignFaceMatchInfo"



#pragma mark ----------------------------------------------面授课表接口-------------------------------------------------

//面授课表
#define HXPOST_GetCourseArrangingList                             @"/api/CourseArrangingList/GetCourseArrangingList"

//面授课表详情
#define HXPOST_GetCourseArrangingDetai                            @"/api/CourseArrangingList/GetCourseArrangingDetai"






@interface HXBaseURLSessionManager : AFHTTPSessionManager

/**
 @return HXBaseURLSessionManager
 */
+ (instancetype)sharedClient;


//修改baseURL
+(void)setBaseURLStr:(NSString *)baseURL;
/**
 登录请求
 */
+ (void)doLoginWithUserName:(NSString * _Nullable)userName
                andPassword:(NSString * _Nullable)pwd
                    success:(void (^)(NSDictionary* _Nullable dictionary))success
                    failure:(void (^)(NSString * _Nullable messsage))failure;

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
                     

/**刷新JWT的Token(如果返回false,则表示要重新登录)
 */
+ (void)refreshTokeCallBack:(void (^)(bool success))callBack;


/**清除cookie
 */
- (void)clearCookies;

@end

NS_ASSUME_NONNULL_END
