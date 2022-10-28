//
//  HXScoreDetailModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXScoreDetailModel : NSObject

///学生ID
@property(nonatomic, copy) NSString *studentID;
///班级计划学期ID
@property(nonatomic, copy) NSString *termCourseID;
///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///显示的成绩
@property(nonatomic, assign) CGFloat showScore;
///总评成绩
@property(nonatomic, assign) CGFloat commonTestScore;
///正考总成绩
@property(nonatomic, assign) CGFloat finalScore;
///补考成绩
@property(nonatomic, assign) CGFloat addTestScore;
///课件成绩
@property(nonatomic, assign) CGFloat selfScore;
///作业成绩
@property(nonatomic, assign) CGFloat timeScore;
///学习表现成绩
@property(nonatomic, assign) CGFloat workScore;
///期末成绩
@property(nonatomic, assign) CGFloat examScore;
///课件比例
@property(nonatomic, assign) CGFloat selfRate;
///作业比例
@property(nonatomic, assign) CGFloat timeRate;
///学习表现比例
@property(nonatomic, assign) CGFloat workRate;
///期末比例
@property(nonatomic, assign) CGFloat examRate;
///是否网课
@property(nonatomic, assign) BOOL isNetCourse;

@end

NS_ASSUME_NONNULL_END
