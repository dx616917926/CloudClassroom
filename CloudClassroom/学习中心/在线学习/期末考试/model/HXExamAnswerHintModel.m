//
//  HXExamAnswerHintModel.m
//  CloudClassroom
//
//  Created by mac on 2023/1/3.
//

#import "HXExamAnswerHintModel.h"

@implementation HXExamAnswerHintModel

-(NSString *)hint{
//    if ([HXCommonUtil isNull:_hint]) {
//        return _hint;
//    }
    return [NSString stringWithFormat:@"解析:%@",_hint];
}




@end
