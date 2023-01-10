//
//  HXExamPaperSuitQuestionModel.m
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import "HXExamPaperSuitQuestionModel.h"

@implementation HXExamPaperSuitQuestionModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"questionChoices" : @"HXExamQuestionChoiceModel",
             @"subQuestions" : @"HXExamPaperSubQuestionModel"
             };
}

//处理图片宽高
-(NSString *)psq_staticTitle{
    if([_psq_staticTitle containsString:@"data:image/png;base64,"]){
        return [HXCommonUtil getReplaceStringFromBase64ImageStr:_psq_staticTitle maxSize:CGSizeMake(kScreenWidth-20, 1000000)];
    }else{
        return _psq_staticTitle;
    }
}

-(NSString *)serialNoHtmlTitle{
    NSString *html = [NSString stringWithFormat:@"%@&nbsp;&nbsp;%@",self.psq_serial_no,self.psq_staticTitle];
    return html;
}
@end
