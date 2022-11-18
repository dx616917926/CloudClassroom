//
//  HXExamQuestionTypeModel.m
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import "HXExamQuestionTypeModel.h"

@implementation HXExamQuestionTypeModel


+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"paperSuitQuestions" : @"HXExamPaperSuitQuestionModel"
             };
}

@end
