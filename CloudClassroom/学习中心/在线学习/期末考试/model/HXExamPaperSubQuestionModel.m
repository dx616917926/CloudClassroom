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

//处理图片宽高
-(NSString *)sub_staticTitle{
    if([_sub_staticTitle containsString:@"data:image/png;base64,"]){
        return [HXCommonUtil getReplaceStringFromBase64ImageStr:_sub_staticTitle maxSize:CGSizeMake(kScreenWidth-20, 1000000)];
    }else{
        return _sub_staticTitle;
    }
}

-(NSString *)serialNoHtmlTitle{
    NSString *html;
    if (_isDuoXuan) {
        html=  [NSString stringWithFormat:@"(多选题)%@&nbsp;&nbsp;%@",self.sub_serial_no,self.sub_staticTitle];
    }else{
        html=  [NSString stringWithFormat:@"%@&nbsp;&nbsp;%@",self.sub_serial_no,self.sub_staticTitle];
    }
    return html;
}

@end
