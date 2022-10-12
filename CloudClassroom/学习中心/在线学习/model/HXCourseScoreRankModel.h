//
//  HXCourseScoreRankModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCourseScoreRankModel : NSObject

///排名
@property(nonatomic, assign) NSInteger rownum;
///姓名
@property(nonatomic, copy) NSString *name;
///头像地址
@property(nonatomic, copy) NSString *imgUrl;
///学生id
@property(nonatomic, copy) NSString *student_Id;
///课程id
@property(nonatomic, copy) NSString *termCourse_Id;
///分数
@property(nonatomic, assign) CGFloat finalScore;
///状态 是否自己
@property(nonatomic, assign) NSInteger state;

@end

NS_ASSUME_NONNULL_END
