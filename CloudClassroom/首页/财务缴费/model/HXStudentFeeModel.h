//
//  HXStudentFeeModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXStudentFeeModel : NSObject
///缴费项ID
@property(nonatomic, copy) NSString *feeId;
///年级
@property(nonatomic, copy) NSString *enterdate;
///站点
@property(nonatomic, copy) NSString *subSchoolName;
///专业名称
@property(nonatomic, copy) NSString *majorlongname;
///费项
@property(nonatomic, copy) NSString *paybackName;
///应缴费用
@property(nonatomic, assign) CGFloat payable;
///已缴费用
@property(nonatomic, assign) CGFloat paidIn;
///待缴费用
@property(nonatomic, assign) CGFloat balance;
///订单号
@property(nonatomic, copy) NSString *orderNo;
///缴费状态 0 未缴费 1已缴费
@property(nonatomic, assign) NSInteger feeStatus;
///缴费日期
@property(nonatomic, copy) NSString *orderDate;
///批次名称
@property(nonatomic, copy) NSString *batchName;
///批次ID
@property(nonatomic, copy) NSString *batchID;



@end

NS_ASSUME_NONNULL_END
