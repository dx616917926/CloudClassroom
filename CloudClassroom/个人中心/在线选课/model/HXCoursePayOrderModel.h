//
//  HXCoursePayOrderModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCoursePayOrderModel : NSObject

///单号ID
@property(nonatomic, copy) NSString *order_id;
///课程ID
@property(nonatomic, copy) NSString *termcourse_id;
///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///学生ID
@property(nonatomic, copy) NSString *student_id;
///学期
@property(nonatomic, copy) NSString *term;
///缴费状态 1表示已缴费
@property(nonatomic, assign) NSInteger fee_status;
///订单号
@property(nonatomic, copy) NSString *order_no;
///订单日期
@property(nonatomic, copy) NSString *order_date;
///金额
@property(nonatomic, assign) CGFloat price;
///缴费方式 
@property(nonatomic, copy) NSString *order_type;

@end

NS_ASSUME_NONNULL_END
