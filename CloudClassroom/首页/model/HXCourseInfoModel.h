//
//  HXCourseInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCourseInfoModel : NSObject

///年级
@property(nonatomic, copy) NSString *enterDate;
///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///班级计划课程ID
@property(nonatomic, copy) NSString *termCourseID;
///学生ID
@property(nonatomic, copy) NSString *student_id;
///学期
@property(nonatomic, copy) NSString *term;
///课件代码
@property(nonatomic, copy) NSString *coursecode;
///期末代码
@property(nonatomic, copy) NSString *modleCode;
///作业代码
@property(nonatomic, copy) NSString *jobCode;
///答疑代码
@property(nonatomic, copy) NSString *dnCode;
///总评成绩
@property(nonatomic, assign) CGFloat finalscore;
///课件成绩
@property(nonatomic, assign) CGFloat kjScore;
///作业成绩
@property(nonatomic, assign) CGFloat zyScore;
///期末成绩
@property(nonatomic, assign) CGFloat qmScore;
///是否显示课件  0:不显示  1:显示
@property(nonatomic, assign) NSInteger showKJ;
///是否显示作业  0:不显示  1:显示
@property(nonatomic, assign) NSInteger showZY;
///是否显示期末  0:不显示  1:显示
@property(nonatomic, assign) NSInteger showQM;
///是否显示答疑  0:不显示  1:显示
@property(nonatomic, assign) NSInteger showDN;
///课件按钮名称
@property(nonatomic, copy) NSString *kjButtonName;
///作业按钮名称
@property(nonatomic, copy) NSString *zyButtonName;
///期末按钮名称
@property(nonatomic, copy) NSString *qmButtonName;
///答疑按钮名称
@property(nonatomic, copy) NSString *dnButtonName;
///课程类别
@property(nonatomic, copy) NSString *courseTypeName;
///排名
@property(nonatomic, assign) NSInteger classRank;

@end

NS_ASSUME_NONNULL_END
