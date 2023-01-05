//
//  HXExamPaperSuitQuestionModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "HXExamQuestionChoiceModel.h"
#import "HXExamPaperSubQuestionModel.h"
#import "HXExamAnswerHintModel.h"
#import "HXExamAnswerModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXExamPaperSuitQuestionModel : NSObject

/***************************自定义数据***********************************/
//开始考试或继续考试
@property(nonatomic,assign)  BOOL isContinuerExam;
///考试系统域名
@property(nonatomic, copy) NSString *domain;
///试卷ID
@property(nonatomic, copy) NSString *userExamId;
///题型名称
@property(nonatomic, copy) NSString *pqt_title;
//是否是多选题
@property(nonatomic, assign) BOOL isDuoXuan;
//是否是问答题
@property(nonatomic, assign) BOOL isWenDa;
//是否是复合型题
@property(nonatomic, assign) BOOL isFuHe;
///答案
@property(nonatomic, strong) NSString *answer;
///学生答案
@property(nonatomic, strong) HXExamAnswerModel *answerModel;
///解析
@property(nonatomic, strong) HXExamAnswerHintModel *hintModel;
///复合题中小题的位置（从0 开始）
@property (nonatomic,assign) NSInteger fuhe_position;

//附件图片数组
@property (nonatomic,strong) NSMutableArray *fuJianImages;


/***************************接口返回数据***********************************/

///问题标题
@property(nonatomic, copy) NSString *psq_staticTitle;
///带问题序号加空格的html问题标题(自己加的)
@property(nonatomic, strong) NSString *serialNoHtmlTitle;
///问题code
@property(nonatomic, copy) NSString *psq_code;
///问题id
@property(nonatomic, copy) NSString *psq_id;
///问题所属题型类 1.单选    2.多选     3.问答      4.复合
@property(nonatomic, assign) NSInteger psq_baseType;
///问题答对所得分数
@property(nonatomic, copy) NSString *psq_scoreStr;
///问题序号
@property(nonatomic, copy) NSString *psq_serial_no;
///选择题选项数组
@property(nonatomic, strong) NSArray<HXExamQuestionChoiceModel *> *questionChoices;

///问答题子问题数组
@property(nonatomic, strong) NSArray<HXExamPaperSubQuestionModel *> *subQuestions;




@end

NS_ASSUME_NONNULL_END
