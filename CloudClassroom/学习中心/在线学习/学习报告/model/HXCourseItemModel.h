//
//  HXCourseItemModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCourseItemModel : NSObject


///课件版块显示的名称
@property(nonatomic, copy) NSString *kjButtonName;
///课程名
@property(nonatomic, copy) NSString *termCourseName;
///比例
@property(nonatomic, copy) NSString *selfRate;
///课件原始成绩
@property(nonatomic, copy) NSString *oriSelfScore;
///课件成绩（乘比例后的成绩）
@property(nonatomic, copy) NSString *selfScore;
///已学习时长(分钟)
@property(nonatomic, assign) NSInteger learnTime;
///总时长（分钟）
@property(nonatomic, assign) NSInteger totalTime;


///版块显示的名称
@property(nonatomic, copy) NSString *moduleButtonName;
///比例
@property(nonatomic, copy) NSString *moduleRate;
///平时作业成绩（乘比例后的成绩）
@property(nonatomic, copy) NSString *moduleScore;
///考试次数
@property(nonatomic, assign) NSInteger examCount;
///每次考试的总分
@property(nonatomic, copy) NSString *totalScore;
///每次考试的得分
@property(nonatomic, copy) NSString *getScore;

@end

NS_ASSUME_NONNULL_END
