//
//  HXNotificationNameDefines.h
//  HXXiaoGuan
//
//  Created by mac on 2021/5/31.
//

#ifndef HXNotificationNameDefines_h
#define HXNotificationNameDefines_h


#define SHOWLOGIN         @"HXShowLoginVC"
#define LOGINSUCCESS      @"HXLoginSuccess"
#define NeedReAuthorize   @"HXNeedReAuthorize"

static NSString * const kThemeDidChangeNotification = @"ThemeDidChangeNotification";
//修改学历报名信息成功通知
static NSString * const kUpdateEnrollInfoSuccessNotification = @"UpdateEnrollInfoSuccessNotification";
//修改专业Id通知,重新获取缴费信息
static NSString * const kChangeMajorNotification = @"ChangeMajorNotification";
//修改报名缴费条目的金额通知
static NSString * const kChangeEnrollFeeNotification = @"ChangeEnrollFeeNotification";

//修改直招实缴缴费条目的本次实收金额通知
static NSString * const kChangeZhiZhaoShiJiaoFeeNotification = @"ChangeZhiZhaoShiJiaoFeeNotification";

//保存直招实缴成功通知
static NSString * const kSaveZhiZhaoShiJiaoSuccessNotification = @"SaveZhiZhaoShiJiaoSuccessNotification";

//保存跟进记录成功通知
static NSString * const kSaveGenJinRecordsSuccessNotification = @"SaveGenJinRecordsSuccessNotification";

//学生保存跟进记录成功通知
static NSString * const kSaveStudentGenJinRecordsSuccessNotification = @"SaveStudentGenJinRecordsSuccessNotification";

//刷新我的意向列表数据通知
static NSString * const kRefreshMyClientsListSuccessNotification = @"RefreshMyClientsListSuccessNotification";

//刷新我的线索列表数据通知
static NSString * const kRefreshMyCluesListSuccessNotification = @"RefreshMyCluesListSuccessNotification";

//刷新线索客户公海列表数据通知
static NSString * const kRefreshCommonSeaListSuccessNotification = @"RefreshCommonSeaListSuccessNotification";

//刷新自助报名列表数据通知
static NSString * const kRefreshZiZhuBaoMingListSuccessNotification = @"RefreshZiZhuBaoMingListSuccessNotification";

//通时通次统计cell滑动通知
static NSString * const kTongShiTongJiCellScrollNotification = @"TongShiTongJiCellScrollNotification";
//报名流水cell滑动通知
static NSString * const kBaoMingLiuShuiCellScrollNotification = @"BaoMingLiuShuiCellScrollNotification";

//话单统计cell滑动通知
static NSString * const kHuaDanTongJiCellScrollNotification = @"HuaDanTongJiCellScrollNotification";

//首咨分配cell滑动通知
static NSString * const kShouZiFenPeiCellScrollNotification = @"ShouZiFenPeiCellScrollNotification";

//首联统计cell滑动通知
static NSString * const kShouLianTongJiCellScrollNotification = @"ShouLianTongJiCellScrollNotification";

//回访统计cell滑动通知
static NSString * const kHuiFangTongJiCellScrollNotification = @"HuiFangTongJiCellScrollNotification";

//持有统计cell滑动通知
static NSString * const kChiYouTongJiCellScrollNotification = @"kChiYouTongJiCellScrollNotification";


//修改学生信息成功通知
static NSString * const kUpdateStudentInfoSuccessNotification = @"kUpdateStudentInfoSuccessNotification";

#endif /* HXNotificationNameDefines_h */
