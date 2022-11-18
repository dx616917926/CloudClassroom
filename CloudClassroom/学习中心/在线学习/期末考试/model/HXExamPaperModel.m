//
//  HXExamPaperModel.m
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import "HXExamPaperModel.h"

@implementation HXExamPaperModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"questionGroups" : @"HXExamQuestionTypeModel"
             };
}

@end
