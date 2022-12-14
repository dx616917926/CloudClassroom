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
        CGRect viewMaxRect = CGRectMake(0, 0, kScreenWidth-65, 1000000);
        NSString *a = [_choice_staticContent stringByReplacingOccurrencesOfString:@"width=" withString:@"FG="];
        NSString *b = [a stringByReplacingOccurrencesOfString:@"height=" withString:@"FG="];
        NSArray *c = [b componentsSeparatedByString:@"FG="];
        NSArray *w = [c[1] componentsSeparatedByString:@"\""];
        NSArray *h = [c[2] componentsSeparatedByString:@"\""];
        CGFloat width = [w[1] floatValue];
        CGFloat height = [h[1] floatValue];
        //图片大小处理
        CGFloat widthPx = 0;
        CGFloat heightPx = 0;
        if (width>=viewMaxRect.size.width) {//超过规定宽度，等比例缩放
            CGFloat imgSizeScale = height/width;
            widthPx = viewMaxRect.size.width;
            heightPx = widthPx * imgSizeScale;
        }else{
            widthPx = width;
            heightPx = height;
        }
        NSString *newImageInfo = [NSString stringWithFormat:@"%@width=\"%.f\" height=\"%.f\">",c.firstObject,widthPx,heightPx];
        return  newImageInfo;
    }else{
        return _choice_staticContent;
    }
}

@end
