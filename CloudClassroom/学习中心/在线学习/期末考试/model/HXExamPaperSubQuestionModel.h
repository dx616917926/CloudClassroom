//
//  HXExamPaperSubQuestionModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "HXExamSubQuestionChoicesModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamPaperSubQuestionModel : NSObject


///考试系统域名
@property(nonatomic, copy) NSString *domain;
///试卷ID
@property(nonatomic, copy) NSString *userExamId;

///子问题标题
@property(nonatomic, copy) NSString *sub_staticTitle;
///子问题code
@property(nonatomic, copy) NSString *sub_code;
///子问题id
@property(nonatomic, copy) NSString *sub_id;
///子问题所属题型类
@property(nonatomic, copy) NSString *sub_baseType;
///子问题答对所得分数
@property(nonatomic, copy) NSString *sub_scoreStr;
///子问题序号
@property(nonatomic, copy) NSString *sub_serial_no;

///带问题序号加空格的html问题标题(自己加的)
@property(nonatomic, strong) NSString *serialNoHtmlTitle;

///答案
@property(nonatomic, strong) NSString *answer;

///子问题选择题选项数组
@property(nonatomic, strong) NSArray<HXExamSubQuestionChoicesModel *> *subQuestionChoices;



@end

NS_ASSUME_NONNULL_END
