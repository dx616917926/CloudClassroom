//
//  HXExamQuestionChoiceModel.m
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import "HXExamQuestionChoiceModel.h"

@implementation HXExamQuestionChoiceModel

//处理图片宽高
-(NSString *)choice_staticContent{
    if([_choice_staticContent containsString:@"data:image/png;base64,"]){
        return [HXCommonUtil getReplaceStringFromBase64ImageStr:_choice_staticContent maxSize:CGSizeMake(kScreenWidth-65, 1000000)];
    }else{
        return _choice_staticContent;
    }
}

@end
