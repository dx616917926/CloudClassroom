//
//  HXExamPaperSuitQuestionModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "HXExamQuestionChoiceModel.h"
#import "HXExamPaperSubQuestionModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXExamPaperSuitQuestionModel : NSObject

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

///问题标题
@property(nonatomic, copy) NSString *psq_staticTitle;
///带问题序号加空格的html问题标题(自己加的)
@property(nonatomic, strong) NSString *serialNoHtmlTitle;
///问题code
@property(nonatomic, copy) NSString *psq_code;
///问题id
@property(nonatomic, copy) NSString *psq_id;
///问题所属题型类
@property(nonatomic, copy) NSString *psq_baseType;
///问题答对所得分数
@property(nonatomic, copy) NSString *psq_scoreStr;
///问题序号
@property(nonatomic, copy) NSString *psq_serial_no;
///选择题选项数组
@property(nonatomic, strong) NSArray<HXExamQuestionChoiceModel *> *questionChoices;

///问答题子问题数组
@property(nonatomic, strong) NSArray<HXExamPaperSubQuestionModel *> *subQuestions;

//
@property (nonatomic,assign) BOOL shouldScroll;
///复合题中小题的位置（从0 开始）
@property (nonatomic,assign) NSInteger fuhe_position;

@end

NS_ASSUME_NONNULL_END
