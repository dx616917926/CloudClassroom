//
//  HXCourseOrderModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCourseOrderModel : NSObject


///学生ID
@property(nonatomic, copy) NSString *student_id;
///课程ID
@property(nonatomic, copy) NSString *termCourse_id;
///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///学期
@property(nonatomic, copy) NSString *term;
///单价
@property(nonatomic, assign) CGFloat iPrice;

///是否选择
@property(nonatomic, assign) BOOL isSeleted;

@end

NS_ASSUME_NONNULL_END
