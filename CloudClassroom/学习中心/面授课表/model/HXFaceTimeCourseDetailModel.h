//
//  HXFaceTimeCourseDetailModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXFaceTimeCourseDetailModel : NSObject

///排课ID
@property(nonatomic,strong) NSString *paiKeId;
///课程名称
@property(nonatomic,strong) NSString *termCourseName;
///排课日期
@property(nonatomic,strong) NSString *arrangingDate;
///开始时间
@property(nonatomic,strong) NSString *beginDate;
///结束时间
@property(nonatomic,strong) NSString *endDate;
///教师
@property(nonatomic,strong) NSString *teacherName;
///上课地址
@property(nonatomic,strong) NSString *roomName;
///上课时间
@property(nonatomic,strong) NSString *classTime;
///课程状态 0未开始 1进行中  2已结束
@property(nonatomic,assign) NSInteger courseState;

@end

NS_ASSUME_NONNULL_END
