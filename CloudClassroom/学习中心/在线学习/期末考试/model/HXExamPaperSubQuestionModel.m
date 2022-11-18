//
//  HXExamPaperSubQuestionModel.m
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import "HXExamPaperSubQuestionModel.h"

@implementation HXExamPaperSubQuestionModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"subQuestionChoices" : @"HXExamSubQuestionChoicesModel"
             };
}

-(NSString *)serialNoHtmlTitle{
    NSString *html = [NSString stringWithFormat:@"%@&nbsp;&nbsp;%@",self.sub_serial_no,self.sub_staticTitle];
    return html;
}

@end
