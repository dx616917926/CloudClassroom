//
//  HXExamSubQuestionChoicesModel.m
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import "HXExamSubQuestionChoicesModel.h"

@implementation HXExamSubQuestionChoicesModel

//处理图片宽高
-(NSString *)subChoice_staticContent{
    if([_subChoice_staticContent containsString:@"data:image/png;base64,"]){
        return [HXCommonUtil getReplaceStringFromBase64ImageStr:_subChoice_staticContent maxSize:CGSizeMake(kScreenWidth-65, 1000000)];
    }else{
        return _subChoice_staticContent;
    }
}

@end
