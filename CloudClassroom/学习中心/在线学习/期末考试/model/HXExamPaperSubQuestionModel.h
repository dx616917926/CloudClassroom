//
//  HXExamPaperSubQuestionModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "HXExamSubQuestionChoicesModel.h"
#import "HXExamAnswerHintModel.h"
#import "HXExamAnswerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamPaperSubQuestionModel : NSObject

/***************************自定义数据***********************************/
//开始考试或继续考试
@property(nonatomic,assign)  BOOL isContinuerExam;
///考试系统域名
@property(nonatomic, copy) NSString *domain;
///试卷ID
@property(nonatomic, copy) NSString *userExamId;
///带问题序号加空格的html问题标题(自己加的)
@property(nonatomic, strong) NSString *serialNoHtmlTitle;
//是否是多选题
@property(nonatomic, assign) BOOL isDuoXuan;
//是否是问答题
@property(nonatomic, assign) BOOL isWenDa;
///答案
@property(nonatomic, strong) NSString *answer;
///学生答案
@property(nonatomic, strong) HXExamAnswerModel *answerModel;
///解析
@property(nonatomic, strong) HXExamAnswerHintModel *hintModel;

//附件图片数组
@property (nonatomic,strong) NSMutableArray *fuJianImages;

//附件,调用上传附件接口后返回的“tmpFileName”,多个逗号分割
@property (nonatomic,strong) NSMutableArray *attach;


/***************************接口返回数据***********************************/
///子问题标题
@property(nonatomic, copy) NSString *sub_staticTitle;
///子问题code
@property(nonatomic, copy) NSString *sub_code;
///子问题id
@property(nonatomic, copy) NSString *sub_id;
///子问题所属题型类。 1.单选      2.多选       3.问答
@property(nonatomic, assign) NSInteger sub_baseType;
///子问题答对所得分数
@property(nonatomic, copy) NSString *sub_scoreStr;
///子问题序号
@property(nonatomic, copy) NSString *sub_serial_no;



///子问题选择题选项数组
@property(nonatomic, strong) NSArray<HXExamSubQuestionChoicesModel *> *subQuestionChoices;



@end

NS_ASSUME_NONNULL_END
