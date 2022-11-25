//
//  HXLiveCourseModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXLiveCourseModel : NSObject

///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///学生ID
@property(nonatomic, copy) NSString *student_id;
///消息标题
@property(nonatomic, copy) NSString *messagetitle;
///学生姓名
@property(nonatomic, copy) NSString *stuName;
///直播总次数
@property(nonatomic, assign) NSInteger dbTotalNum;
///已直播次数
@property(nonatomic, assign) NSInteger dbPlayNum;
///出勤直播次数
@property(nonatomic, assign) NSInteger dbJoinNum;
///消息标题
@property(nonatomic, assign) NSInteger dbType;
///下次直播时间
@property(nonatomic, copy) NSString *dbNextTime;
///直播主表ID
@property(nonatomic, copy) NSString *dbManageID;

@end

NS_ASSUME_NONNULL_END
