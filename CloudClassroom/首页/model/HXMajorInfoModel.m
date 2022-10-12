//
//  HXMajorInfoModel.m
//  CloudClassroom
//
//  Created by mac on 2022/10/10.
//

#import "HXMajorInfoModel.h"

@implementation HXMajorInfoModel


+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"semesterList" : @"HXSemesterModel"
             };
}

@end
