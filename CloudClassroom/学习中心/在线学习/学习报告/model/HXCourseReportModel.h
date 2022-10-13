//
//  HXCourseReportModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/12.
//

#import <Foundation/Foundation.h>
#import "HXCourseItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXCourseReportModel : NSObject

//总评成绩
@property(nonatomic, copy) NSString *finalScore;

//课件学习数组
@property(nonatomic, strong) NSArray<HXCourseItemModel *> *kjInfo;

//学习表现
@property(nonatomic, strong) HXCourseItemModel *xxbxInfo;

//平时作业数组
@property(nonatomic, strong) NSArray<HXCourseItemModel *> *zyInfo;

//期末考试数组
@property(nonatomic, strong) NSArray<HXCourseItemModel *> *qmInfo;

///1:作业  2：期末
@property(nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
