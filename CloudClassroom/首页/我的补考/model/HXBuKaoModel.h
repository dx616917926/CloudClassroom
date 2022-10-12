//
//  HXBuKaoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXBuKaoModel : NSObject

///学生ID
@property(nonatomic, copy) NSString *student_id;
///身份证
@property(nonatomic, copy) NSString *personId;
///补考开课表ID
@property(nonatomic, copy) NSString *bkCourse_id;
///是否显示作业模块   1:显示  0:不显示
@property(nonatomic, assign) NSInteger showZY;
///是否显示期末模块   1:显示  0:不显示
@property(nonatomic, assign) NSInteger showQM;
///作业名称
@property(nonatomic, copy) NSString *zyButtonName;
///期末名称
@property(nonatomic, copy) NSString *qmButtonName;
///课程名
@property(nonatomic, copy) NSString *termCourseName;
///补考平时作业代码
@property(nonatomic, copy) NSString *zyCode;
///补考期末考试模块代码
@property(nonatomic, copy) NSString *qmCode;


@end

NS_ASSUME_NONNULL_END
