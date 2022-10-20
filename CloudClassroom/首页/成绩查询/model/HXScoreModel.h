//
//  HXScoreModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXScoreModel : NSObject
///学生ID
@property(nonatomic, copy) NSString *studentID;
///班级计划学期ID
@property(nonatomic, copy) NSString *termCourseID;
///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///总评成绩
@property(nonatomic, copy) NSString *commonTestScore;
///补考成绩
@property(nonatomic, copy) NSString *addTestScore;
///最终得分
@property(nonatomic, copy) NSString *finalScore;
///显示的得分
@property(nonatomic, copy) NSString *showScore;
///是否通过
@property(nonatomic, assign) BOOL isPass;
///是否网课
@property(nonatomic, assign) BOOL isNetCourse;
///学期
@property(nonatomic, copy) NSString *term;


//********************在线补考参数*****************//
///批次名称
@property(nonatomic, copy) NSString *batchName;
///在线补考成绩
@property(nonatomic, copy) NSString *testScore;


@end

NS_ASSUME_NONNULL_END
