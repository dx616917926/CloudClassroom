//
//  HXKeJianOrExamInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/11.
//

#import <Foundation/Foundation.h>
#import "HXExamParaModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXKeJianOrExamInfoModel : NSObject

///学生ID
@property(nonatomic, copy) NSString *student_id;
///身份证
@property(nonatomic, copy) NSString *personId;
///班级计划学期ID
@property(nonatomic, copy) NSString *termCourse_id;
///补考开课ID
@property(nonatomic, copy) NSString *bkCourse_id;
///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///开始时间（课件和考试）
@property(nonatomic, copy) NSString *finaltime;
///结束时间（课件和考试）
@property(nonatomic, copy) NSString *finaltimeEnd;
///是否能考试或者看课
@property(nonatomic, assign) NSInteger isCan;
///提示信息
@property(nonatomic, copy) NSString *showMessage;
///考试代码（课件代码)
@property(nonatomic, copy) NSString *examCode;
///限制考试次数
@property(nonatomic, assign) NSInteger allowCount_CJ;
///是否查看分数 1表示查看   0表示不查看
@property(nonatomic, assign) NSInteger vs_CJ;
///考试限制时长（分钟）
@property(nonatomic, assign) NSInteger limitedTime_CJ;
///是否可以查看答卷，1是可以，0是不可以
@property(nonatomic, assign) NSInteger vr_CJ;
///续考期间是否能查看正确答案，1是可以，0是不可以
@property(nonatomic, assign) NSInteger vac_CJ;
///是否可以继续考试，1是可以，0是不可以
@property(nonatomic, assign) NSInteger resume_CJ;
///已学时长（分钟）
@property(nonatomic, assign) NSInteger learnTime;
///课件总时长（分钟）
@property(nonatomic, assign) NSInteger courseALlTime;
///作者
@property(nonatomic, copy) NSString *author;
///批次名称
@property(nonatomic, copy) NSString *batchName;
///模块类型 1作业 2期末考试
@property(nonatomic, assign) NSInteger moduleType;

///课件来源:HXDD   MOOC
@property(nonatomic, copy) NSString *stemCode;

///作业考试数组
@property(nonatomic, strong) NSArray<HXExamParaModel*> *examPara;


@end

NS_ASSUME_NONNULL_END
