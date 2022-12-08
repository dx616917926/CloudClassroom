//
//  HXExamAnswerModel.m
//  CloudClassroom
//
//  Created by mac on 2022/12/8.
//

#import "HXExamAnswerModel.h"

@implementation HXExamAnswerModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
        @"pqt_id" : @"id"
    };
}

@end
