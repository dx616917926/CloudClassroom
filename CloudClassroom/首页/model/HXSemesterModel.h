//
//  HXSemesterModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/10.
//

#import <Foundation/Foundation.h>
#import "HXCourseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXSemesterModel : NSObject

//学期id
@property(nonatomic, copy) NSString *semesterid;
//学期名称
@property(nonatomic, copy) NSString *name;
//学期名称
@property(nonatomic, copy) NSString *termName;
//学期状态（0表示学期已结束、1表示当前学期、2表示学期未开始）
@property(nonatomic, assign) NSInteger termStatus;

//课程数组
@property(nonatomic, strong) NSArray<HXCourseInfoModel *> *courseList;

@end

NS_ASSUME_NONNULL_END
