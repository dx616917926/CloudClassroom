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

-(NSString *)serialNoHtmlTitle{
    NSString *html = [NSString stringWithFormat:@"%@&nbsp;&nbsp;%@",self.psq_serial_no,self.psq_staticTitle];
    return html;
}
@end
