//
//  HXSemesterModel.m
//  CloudClassroom
//
//  Created by mac on 2022/10/10.
//

#import "HXSemesterModel.h"

@implementation HXSemesterModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
        @"semesterid" : @"id",
        @"courseList" : @"courseInfoModel"
    };
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"courseList" : @"HXCourseInfoModel"
             };
}

@end
