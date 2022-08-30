//
//  HXBaseURLSessionManager.h
//  HXCloudClass
//
//  Created by Mac on 2020/6/19.
//  Copyright © 2020 华夏大地教育网. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

#define HXPOST_GetDomainNameList                                  @"/api/User/GetList"//获取域名

//获取token
#define HXGET_TOKEN                                               @"/api/ApiLogin/Login"

//登录
#define HXPOST_LOGIN                                              @"/XG/LoginInfoXG/Login"

//退出登录
#define HXPOST_APPQuite                                           @"/XG/ReturnBackXG/APPQuite"

//修改密码
#define HXPOST_ChangePassword                                     @"/XG/UserInfoXG/changePassword"

//获取机构Logo
#define HXPOST_GetOzLogo                                          @"/XG/UserInfoXG/getOzLogo"

//获取用户信息
#define HXPOST_GetUserInfo                                        @"/XG/UserInfoXG/getUserInfo"

//生成用户二维码
#define HXPOST_CreateUserQRCode                                   @"/XG/ClueManageXG/CreateQRCode"

//获取招生老师本月每天招生数量
#define HXPOST_GetUserEnrollmentDetails                           @"/XG/UserInfoXG/GetUserEnrollmentDetails"

//获取用户招生权限
#define HXPOST_GetUserRights                                      @"/XG/EnrollInfoXG/GetUserRights"

//获取筛选条件
#define HXPOST_GetSearchConditions                                @"/XG/EnrollInfoXG/GetSearchConditions"

//获取学历报名信息
#define HXPOST_GetEnrollInfoList                                  @"/XG/EnrollInfoXG/GetEnrollInfoList"

//获取非学历报名信息
#define HXPOST_GetEnrollNonEduInfoList                            @"/XG/EnrollInfoXG/GetEnrollNonEduInfoList"

//获取机构咨询师
#define HXPOST_GetConsultantList                                  @"/XG/EnrollInfoXG/GetConsultantList"

//转移咨询师
#define HXPOST_SaveConsultanttransfer                             @"/XG/EnrollInfoXG/SaveConsultanttransfer"

//获取报名学生基本信息
#define HXPOST_GetEnrollBasicInfo                                 @"/XG/EnrollInfoXG/GetEnrollBasicInfo"

//获取报名学生报考信息
#define HXPOST_GetEnrollExamInfo                                  @"/XG/EnrollInfoXG/GetEnrollExamInfo"

//获取报名学生其他信息
#define HXPOST_GetEnrollOtherInfo                                 @"/XG/EnrollInfoXG/GetEnrollOtherInfo"

//获取报名学生资料信息
#define HXPOST_GetEnrollFileInfo                                  @"/XG/EnrollInfoXG/GetEnrollFileInfo"

//报名学生上传图片
#define HXPOST_UploadStudentFile                                  @"/XG/EnrollInfoXG/uploadEnrollFile"

//获取报名学生缴费信息
#define HXPOST_GetEnrollFeeInfo                                   @"/XG/EnrollInfoXG/GetEnrollFeeInfo"

//添加学历报名信息
#define HXPOST_SaveEnrollInfo                                     @"/XG/EnrollInfoXG/SaveEnrollInfo"

//修改学历报名信息
#define HXPOST_UpdateEnrollInfo                                   @"/XG/EnrollInfoXG/UpdateEnrollInfo"

//获取报考类型
#define HXPOST_GetVersionList                                     @"/XG/EnrollInfoXG/GetVersionList"

//获取机构已有专业的学校归属地
#define HXPOST_GetProvinceByVersionList                           @"/XG/EnrollInfoXG/GetProvinceByVersionList"

//获取生源省份
#define HXPOST_GetProvince                                        @"/XG/EnrollInfoXG/GetProvince"

//获取生源省份-省市区
#define HXPOST_GetAeraListByProCity                                        @"/XG/StudentInfoXG/GetAeraListByProCity"

//获取注册时间
#define HXPOST_GetEnterDateByVersionList                          @"/XG/EnrollInfoXG/GetEnterDateByVersionList"

//获取报考学校
#define HXPOST_GetBkSchoolByProvinceList                          @"/XG/EnrollInfoXG/GetBkSchoolByProvinceList"

//获取机构已有专业的学习形式
#define HXPOST_GetEnrollMajorExistingStudyTypeList                @"/XG/EnrollInfoXG/GetEnrollMajorExistingStudyTypeList"

//获取机构已有专业的报考层次
#define HXPOST_GetEnrollMajorExistingEducationTypeList            @"/XG/EnrollInfoXG/GetEnrollMajorExistingEducationTypeList"

//获取机构已有专业的招生专业库专业
#define HXPOST_GetEnrollMajorExistingEnrollMajorList              @"/XG/EnrollInfoXG/GetEnrollMajorExistingEnrollMajorList"

//获取招生缴费适用区域
#define HXPOST_GetEnrollapplyAreaList                             @"/XG/EnrollInfoXG/GetEnrollapplyAreaList"

//获取支付类型
#define HXPOST_GetPayMode                                         @"/XG/EnrollInfoXG/GetPayMode"

//获取分期方式
#define HXPOST_GetInstallments                                    @"/XG/EnrollInfoXG/GetInstallments"

//获取支付模式
#define HXPOST_GetPayMode                                         @"/XG/EnrollInfoXG/GetPayMode"

//获取支付模式
#define HXPOST_GetPayType                                         @"/XG/EnrollInfoXG/GetPayType"

//获取银联支付账号套
#define HXPOST_GetPayTypeAliPay                                   @"/XG/QRCodeManageXG/GetPayTypeAliPay"

//获取机构分校
#define HXPOST_GetAttheInfoByOzIdList                             @"/XG/EnrollInfoXG/GetAttheInfoByOzIdList"

//获取机构来源类型
#define HXPOST_GetDataSourceByOzIdList                            @"/XG/EnrollInfoXG/GetDataSourceByOzIdList"

//获取具体来源
#define HXPOST_GetDataSourceTagByOzId                             @"/XG/QRCodeManageXG/GetDataSourceTagByOzId"

//获取民族
#define HXPOST_GetNationList                                      @"/XG/EnrollInfoXG/GetNationList"

//获取学校归属地
#define HXPOST_GetProvinceList                                    @"/XG/EnrollInfoXG/GetNationList_1625625823838"

//获取政治面貌
#define HXPOST_GetPolitic                                         @"/XG/EnrollInfoXG/GetPolitic"

//获取学历
#define HXPOST_GetEducation                                       @"/XG/EnrollInfoXG/GetEducation"

//获取缴费信息
#define HXPOST_GetEnrollFeeList                                   @"/XG/EnrollInfoXG/GetEnrollFeeList"

//获取非学历证书项目
#define HXPOST_GetNonTypeByOzId                                   @"/XG/EnrollInfoXG/GetNonTypeByOzId"

//获取非学历证书级别
#define HXPOST_GetNonEduInfoByOzId                                @"/XG/EnrollInfoXG/GetNonEduInfoByOzId"

//获取非学历报考班型
#define HXPOST_GetNonEduClassListByOzId                           @"/XG/EnrollInfoXG/GetNonEduClassListByOzId"

//获取获取招生类型
#define HXPOST_GetZsType                                          @"/XG/EnrollInfoXG/GetZsType"

//获取招生老师发起的申请
#define HXPOST_GetMeSpList                                        @"/XG/SpDetailXG/GetMeSpList"

//获取待审核和已审核数据
#define HXPOST_GetSpDetailList                                    @"/XG/SpDetailXG/GetSpDetailList"

//获取优惠审批详情
#define HXPOST_GetDiscountSpDetail                                @"/XG/SpDetailXG/GetDiscountSpDetail"

//获取异动审批详情
#define HXPOST_GetChangeSpDetail                                  @"/XG/SpDetailXG/GetChangeSpDetail"

//获取退费审批详情
#define HXPOST_GetRefundSpDetail                                  @"/XG/SpDetailXG/GetRefundSpDetail"

//获取退费已缴明细详情
#define HXPOST_GetSpRefundInfo                                    @"/XG/SpDetailXG/GetSpRefundInfo"

//审批
#define HXPOST_Audit                                              @"/XG/SpDetailXG/Audit"

//获取异动学生基本信息
#define HXPOST_GetChangeStudentBasicInfo                          @"/XG/StudentInfoXG/GetChangeStudentBasicInfo"

//获取异动学生报考信息
#define HXPOST_GetChangeStudentExamInfo                           @"/XG/StudentInfoXG/GetChangeStudentExamInfo"

//获取异动学生其他信息
#define HXPOST_GetChangeStudentOtherInfo                          @"/XG/StudentInfoXG/GetChangeStudentOtherInfo"

//获取异动学生缴费信息
#define HXPOST_GetChangeStudentFeeOrderInfo                       @"/XG/StudentInfoXG/GetChangeStudentFeeOrderInfo"

//生成报名链接或报名协议
#define HXPOST_CreateQRCode                                       @"/XG/EnrollInfoXG/CreateQRCode"

//获取总优惠金额
#define HXPOST_GetspReviewAny                                     @"/XG/EnrollInfoXG/GetspReviewAny"

//保存上传发票
#define HXPOST_SaveInvoiceurl                                     @"/XG/EnrollInfoXG/SaveInvoiceurl"

//上传缴费凭证
#define HXPOST_SavePaymentUrll                                    @"/XG/EnrollFeeXG/SavePaymentUrl"

//获取新生报名表单或协议下载链接
#define HXPOST_GetDownPdf                                         @"/XG/EnrollInfoXG/getDownPdf"

//获取学历报名详情
#define HXPOST_GetEnrollInfo                                      @"/XG/EnrollInfoXG/GetEnrollInfo"

//获取隐私协议
#define HXPOST_Get_PrivacyUrl                                     @"/api/User/GetPrivacyUrl"

//获取直招实缴列表
#define HXPOST_GetZhiZHaoShiJiaoList                              @"/XG/EnrollFeeXG/GetEnrollFeeList"

//获取续缴订单列表
#define HXPOST_GetPayCheckList                                    @"/XG/EnrollFeeXG/GetPayCheckList"

//获取直招实缴详情
#define HXPOST_GetZhiZHaoShiJiaoInfo                              @"/XG/EnrollFeeXG/GetEnrollFeeInfo"

//获取续缴订单详情
#define HXPOST_GetPayCheckInfo                                    @"/XG/EnrollFeeXG/GetPayCheckInfo"

//获取招生的缴费标准记录
#define HXPOST_GetZhiZHaoShiJiaoBiaoZhun                          @"/XG/EnrollFeeXG/GetFeeTypeListInfo"

//获取续缴订单缴费信息
#define HXPOST_GetOrderFeeInfoList                                @"/XG/EnrollFeeXG/GetOrderFeeInfoList"

//保存直招实缴
#define HXPOST_SaveZhiZhaoShiJiao                                 @"/XG/EnrollFeeXG/Save"

//保存续缴
#define HXPOST_SavePaySave                                        @"/XG/EnrollFeeXG/PaySave"

//生成学生报名表单
#define HXPOST_GenerateBdPdf                                      @"/XG/EnrollFeeXG/HtmlToBdPdf"

//生成学生发票收据
#define HXPOST_GenerateFpPdf                                      @"/XG/EnrollFeeXG/HtmlToFpPdf"

//获取收据凭证下载链接
#define HXPOST_GetDownShouJuPdf                                   @"/XG/EnrollFeeXG/getDownPdf"

//获取跟进状态
#define HXPOST_GetFollowState                                     @"/XG/ClueManageXG/GetFollowState"

//获取客户类型
#define HXPOST_GetClueType                                        @"/XG/ClueManageXG/GetClueType"

//获取所有报考类型
#define HXPOST_GetAllVersionList                                  @"/XG/ClueManageXG/GetAllVersionList"

//获取释放类型
#define HXPOST_GetReleaseType                                     @"/XG/ClueManageXG/GetReleaseType"

//获取我的线索
#define HXPOST_GetMyClueList                                      @"/XG/ClueManageXG/GetMyClueList"

//获取线索公海
#define HXPOST_GetClueGhList                                      @"/XG/ClueManageXG/GetClueGhList"

//获取我的客户
#define HXPOST_GetMyCustomerList                                  @"/XG/ClueManageXG/GetMyCustomerList"

//获取客户公海
#define HXPOST_GetCustomerList                                    @"/XG/ClueManageXG/GetCustomerList"

//获取跟进方式
#define HXPOST_GetClueContactTypeByOzId                           @"/XG/ClueManageXG/GetClueContactTypeByOzId"

//获取接听状态、重要等级
#define HXPOST_GetCulabel                                         @"/XG/ClueManageXG/GetCulabel"

//获取跟进阶段
#define HXPOST_GetFollowNotes                                     @"/XG/ClueManageXG/GetFollowNotes"

//获取我的客户检索条件
#define HXPOST_GetMyKhSearchConditions                            @"/XG/ClueManageXG/GetMyKhSearchConditions"

//获取我的线索检索条件
#define HXPOST_GetMyXsSearchConditions                            @"/XG/ClueManageXG/GetMyXsSearchConditions"

//获取公海检索条件
#define HXPOST_GetCommonSeaSearchConditions                       @"/XG/ClueManageXG/GetSearchConditions"

//获取跟进记录
#define HXPOST_GetCustNotesList                                   @"/XG/ClueManageXG/GetCustNotesList"

//获取报名跟进记录
#define HXPOST_GetEnrollNotesList                                 @"/XG/EnrollInfoXG/GetEnrollNotesList"

//获取客户详情
#define HXPOST_GetClueInfo                                        @"/XG/ClueManageXG/GetClueInfo"

//获取报考信息
#define HXPOST_GetClueExamInfo                                    @"/XG/ClueManageXG/GetClueExamInfo"

//获取相关联系人信息
#define HXPOST_GetClueBearUserInfo                                @"/XG/ClueManageXG/GetClueBearUserInfo"

//获取线索客户详情
#define HXPOST_GetCustInfo                                        @"/XG/ClueManageXG/GetCustInfo"

//分配
#define HXPOST_Distribution                                       @"/XG/ClueManageXG/Distribution"

//领取
#define HXPOST_Receive                                            @"/XG/ClueManageXG/Receive"

//转移
#define HXPOST_Change                                             @"/XG/ClueManageXG/Change"

//释放
#define HXPOST_Release                                            @"/XG/ClueManageXG/Release"

//转客户
#define HXPOST_Customer                                           @"/XG/ClueManageXG/Customer"

//移除公海
#define HXPOST_Delete                                             @"/XG/ClueManageXG/Delete"

//同步报名/转报名
#define HXPOST_SyncRegister                                       @"/XG/ClueManageXG/SyncRegister"

//保存线索跟进记录数据
#define HXPOST_DataManagerSave                                    @"/XG/ClueManageXG/DataManagerSave"

//保存意向跟进记录数据
#define HXPOST_CustSave                                           @"/XG/ClueManageXG/CustSave"

//保存报名跟进记录数据
#define HXPOST_EnrollNotesSave                                    @"/XG/EnrollInfoXG/EnrollNotesSave"

//获取当前状态
#define HXPOST_GetClueLables                                      @"/XG/ClueManageXG/GetClueLables"

//添加修改线索客户公海
#define HXPOST_SaveClue                                           @"/XG/ClueManageXG/SaveClue"

//添加修改线索管理
#define HXPOST_SaveMyClue                                         @"/XG/ClueManageXG/SaveMyClue"

//添加修改客户管理
#define HXPOST_SaveMyKh                                           @"/XG/ClueManageXG/SaveMyKh"

//获取是否添加微信QQ
#define HXPOST_GetIsWeChartQQ                                     @"/XG/ClueManageXG/GetIsWeChartQQ"

//获取线索客户统计
#define HXPOST_GetClueStatistics                                  @"/XG/ClueManageXG/GetClueStatistics"

//获取用户线索客户权限
#define HXPOST_GetUserCustRoles                                   @"/XG/ClueManageXG/GetUserCustRoles"

//获取用户线索客户权限
#define HXPOST_CRMCall                                            @"/XG/ClueManageXG/CRMCall"

//自助报名列表
#define HXPOST_GetQRCodeList                                      @"/XG/QRCodeManageXG/GetQRCodeList"

//查询自助报名学生的缴费明细单
#define HXPOST_GetEnrollSelfHelpFeeStandardList                   @"/XG/QRCodeManageXG/GetEnrollSelfHelpFeeStandardList"

//生成招生二维码
#define HXPOST_CreateZhaoShengQRCode                              @"/XG/QRCodeManageXG/CreateQRCode"

//查询二维码详情
#define HXPOST_GetQRCodeInfo                                      @"/XG/QRCodeManageXG/GetQRCodeInfo"

//查询审核范围
#define HXPOST_GetSpRule                                          @"/XG/QRCodeManageXG/GetSpRule"

//查询二维码学生列表
#define HXPOST_GetStudentListByQrCode                             @"/XG/QRCodeManageXG/GetStudentListByQrCode"

//查询自助报名查看详情
#define HXPOST_GetSelfHelpEnrollBm                                @"/XG/QRCodeManageXG/GetSelfHelpEnrollBm"

//保存自助报名
#define HXPOST_SaveSelfHelpBm                                     @"/XG/QRCodeManageXG/SaveSelfHelpBm"

//获取申请人
#define HXPOST_GetUserByOz                                        @"/XG/QRCodeManageXG/GetUserByOz"

//获取报名链接模版设置
#define HXPOST_GetTemplateVersion                                 @"/XG/EnrollInfoXG/GetTemplateVersion"

//获取组织架构
#define HXPOST_GetOrg                                             @"/XG/StatisticsXG/GetOrg"

//获取报名周期统计
#define HXPOST_GetRegistrationCycleStatistics                     @"/XG/StatisticsXG/GetRegistrationCycleStatistics"

//获取报名周期统计
#define HXPOST_GetSZTotalStatistics                               @"/XG/StatisticsXG/GetSZTotalStatistics"

//获取外呼方式
#define HXPOST_GetWhType                                          @"/XG/StatisticsXG/GetWhType"

//获取通时统计
#define HXPOST_GetCallDurationStatistics                          @"/XG/StatisticsXG/GetCallDurationStatistics"

//获取话单详情统计
#define HXPOST_GetCallDurationDetailStatistics                    @"/XG/StatisticsXG/GetCallDurationDetailStatistics"

//获取财务统计
#define HXPOST_GetEnrollFeeStatistics                             @"/XG/EnrollFeeXG/GetEnrollFeeStatistics"

//获取销转比统计
#define HXPOST_GetSalesRatioStatistics                            @"/XG/StatisticsXG/GetSalesRatioStatistics"

//获取报名流水统计
#define HXPOST_GetBmFlowStatistic                                 @"/XG/StatisticsXG/GetBmFlowStatistic"

//获取用户页面权限
#define HXPOST_GetPageRoleList                                    @"/XG/UserInfoXG/GetPageRoleList"

//获取财务续缴订单检索条件
#define HXPOST_GetXuJiaoSearchConditions                          @"/XG/EnrollFeeXG/GetSearchConditions"

//获取学生统计
#define HXPOST_GetStudentStatistics                               @"/XG/StudentInfoXG/GetStudentStatistics"

//获取学生库筛选条件
#define HXPOST_GetStudentInfoSearchConditions                     @"/XG/StudentInfoXG/GetSearchConditions"

//获取学历学生信息
#define HXPOST_GetStudentInfoList                                 @"/XG/StudentInfoXG/GetStudentInfoList"

//获取非学历学生信息
#define HXPOST_GetStudentNonEduInfoList                           @"/XG/StudentInfoXG/GetStudentNonEduInfoList"

//获取学生详情
#define HXPOST_GetStudentInfo                                     @"/XG/StudentInfoXG/GetStudentInfo"

//转移班主任
#define HXPOST_Ttransfer                                          @"/XG/StudentInfoXG/Ttransfer"

//认领/分配班主任
#define HXPOST_SyncBzr                                            @"/XG/StudentInfoXG/SyncBzr"

//重置密码
#define HXPOST_RestorPwd                                          @"/XG/StudentInfoXG/RestorPwd"

//获取学生公海信息
#define HXPOST_GetStudentBzrList                                  @"/XG/StudentInfoXG/GetStudentBzrList"

//获取学生基本信息
#define HXPOST_GetStudentBasicInfo                                @"/XG/StudentInfoXG/GetStudentBasicInfo"

//获取学生报考信息
#define HXPOST_GetStudentExamInfo                                 @"/XG/StudentInfoXG/GetStudentExamInfo"

//获取学生其他信息
#define HXPOST_GetStudentOtherInfo                                @"/XG/StudentInfoXG/GetStudentOtherInfo"

//获取学生系统信息
#define HXPOST_GetStudentSystemInfo                               @"/XG/StudentInfoXG/GetStudentSystemInfo"

//学生保存跟进记录
#define HXPOST_StudentSaveNotes                                   @"/XG/StudentInfoXG/SaveNotes"

//获取学生跟进记录
#define HXPOST_GetStudentNotesList                                @"/XG/StudentInfoXG/GetStudentNotesList"

//修改学历学生信息
#define HXPOST_UpdateStudentInfo                                  @"/XG/StudentInfoXG/UpdateStudentInfo"

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
+ (void)postDataWithNSString:(NSString *)actionUrlStr
              withDictionary:(nullable NSDictionary *) nsDic
                     success:(void (^)(NSDictionary* dictionary))success
                     failure:(void (^)(NSError *error))failure;

/**
 退出登录请求
 */
+ (void)doLogout;

@end

NS_ASSUME_NONNULL_END
