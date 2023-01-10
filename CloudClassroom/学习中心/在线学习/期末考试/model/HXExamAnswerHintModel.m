//
//  HXExamAnswerHintModel.m
//  CloudClassroom
//
//  Created by mac on 2023/1/3.
//

#import "HXExamAnswerHintModel.h"

@implementation HXExamAnswerHintModel

-(NSString *)hint{

    NSString *str = [NSString stringWithFormat:@"解析:%@",_hint];
    if([str containsString:@"data:image/png;base64,"]){
        return [HXCommonUtil getReplaceStringFromBase64ImageStr:str maxSize:CGSizeMake(kScreenWidth-40, 1000000)];
    }else{
        return str;
    }
}

-(NSString *)answer{
    if([_answer containsString:@"data:image/png;base64,"]){
        return [HXCommonUtil getReplaceStringFromBase64ImageStr:_answer maxSize:CGSizeMake(kScreenWidth-40, 1000000)];
    }else{
        return _answer;
    }
}



@end
