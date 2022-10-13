//
//  HXCourseReportModel.m
//  CloudClassroom
//
//  Created by mac on 2022/10/12.
//

#import "HXCourseReportModel.h"

@implementation HXCourseReportModel


+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"kjInfo" : @"HXCourseItemModel",
             @"zyInfo" : @"HXCourseItemModel",
             @"qmInfo" : @"HXCourseItemModel"
             };
}
@end
