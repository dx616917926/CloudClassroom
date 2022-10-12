//
//  HXMajorInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/10.
//

#import <Foundation/Foundation.h>
#import "HXSemesterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXMajorInfoModel : NSObject

//年级
@property(nonatomic, copy) NSString *enterDate;
//
@property(nonatomic, copy) NSString *studyYearReal;
//专业id
@property(nonatomic, copy) NSString *major_Id;
//专业名称
@property(nonatomic, copy) NSString *majorLongName;
//当前学期id
@property(nonatomic, copy) NSString *semesterid;

//学期数组
@property(nonatomic, strong) NSArray<HXSemesterModel *> *semesters;

//是否选中 默认否
@property(nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
