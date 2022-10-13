//
//  HXClassPlanModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXClassPlanModel : NSObject


///课程性质
@property(nonatomic, copy) NSString *courseTypeName;
///课程类别
@property(nonatomic, copy) NSString *typeName;
///班级名称
@property(nonatomic, copy) NSString *className;
///课程名称
@property(nonatomic, copy) NSString *courseName;
///课程编码
@property(nonatomic, copy) NSString *courseCode;
///总学时
@property(nonatomic, assign) NSInteger courseTotalHour;
///课内学时
@property(nonatomic, assign) NSInteger classHour;
///上机学时
@property(nonatomic, assign) NSInteger computerHour;
///实践学时
@property(nonatomic, assign) NSInteger practiseHour;
///自学学时
@property(nonatomic, assign) NSInteger designHour;
///总学分
@property(nonatomic, assign) NSInteger coursePoint;
///考核方式
@property(nonatomic, copy) NSString *checkLookName;
///是否网课
@property(nonatomic, assign) NSInteger isNetCourse;
///学期
@property(nonatomic, copy) NSString *term;


@end

NS_ASSUME_NONNULL_END
