//
//  HXCourseJieSuanModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/24.
//

#import <Foundation/Foundation.h>
#import "HXOrderDetailInfoModel.h"
#import "HXFeeDetailInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXCourseJieSuanModel : NSObject

//fromFalg 1:在线选课  2:财务缴费
@property(nonatomic,assign) NSInteger fromFalg;

///可选的支付方式 在线支付方式选择（0：支付宝+微信   1支付宝    2微信   3银联）
@property(nonatomic, assign) NSInteger payType;
///订单号
@property(nonatomic, copy) NSString *orderNo;

///在线选课结算数组
@property(nonatomic, strong) NSArray<HXOrderDetailInfoModel *> *courseInfo;

//财务缴费结算数组
@property(nonatomic, strong) NSArray<HXFeeDetailInfoModel *> *feeInfo;



@end

NS_ASSUME_NONNULL_END
