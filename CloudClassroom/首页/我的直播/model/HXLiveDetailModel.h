//
//  HXLiveDetailModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXLiveDetailModel : NSObject
///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///直播名称
@property(nonatomic, copy) NSString *dbName;
///直播时间
@property(nonatomic, copy) NSString *dbTime;
///教师名称
@property(nonatomic, copy) NSString *teacherName;
///直播状态（0未开始 1正在直播 2已结束）
@property(nonatomic, assign) NSInteger dbStatus;
///参与状态（0未参与 1已参与）
@property(nonatomic, assign) NSInteger joinStatus;
///直播类型 （1公开课 2非公开课）
@property(nonatomic, assign) NSInteger dbType;
///学生ID
@property(nonatomic, copy) NSString *student_id;
///每一次直播ID
@property(nonatomic, copy) NSString *detailID;
///直播主表ID
@property(nonatomic, copy) NSString *dbManageID;
///回放提示信息，如果有文字，则放文字，没有则显示回放按钮
@property(nonatomic, copy) NSString *playMessage;
///是否显示签到按钮
@property(nonatomic, assign) NSInteger showSignButton;
///经度
@property(nonatomic, copy) NSString *longitude;
///纬度
@property(nonatomic, copy) NSString *latitude;
///签到地址
@property(nonatomic, copy) NSString *signAddress;
///签到半径范围（单位米）
@property(nonatomic, assign) NSInteger signArea;
///签到提示信息（如果为空，则表示可以签到，否则弹出该提示信息）
@property(nonatomic, copy) NSString *signMessge;
///签到半径范围（单位米）
@property(nonatomic, assign) NSInteger faceTag;
///签到状态 0未签到 1已签到
@property(nonatomic, assign) NSInteger signStatus;
///直播观看时长
@property(nonatomic, assign) NSInteger dbLearnTime;
///直播总时长
@property(nonatomic, assign) NSInteger dbTotalTime;
///回看时长
@property(nonatomic, assign) NSInteger playLearnTime;
///回看次数
@property(nonatomic, assign) NSInteger playLearnCount;
///直播简介
@property(nonatomic, copy) NSString *dbMemo;


@end

NS_ASSUME_NONNULL_END
