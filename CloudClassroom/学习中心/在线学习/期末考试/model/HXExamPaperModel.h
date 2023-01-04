//
//  HXExamPaperModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "HXExamQuestionTypeModel.h"
#import "HXExamAnswerModel.h"
#import "HXExamAnswerHintModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamPaperModel : NSObject

//开始考试或继续考试
@property(nonatomic,assign)  BOOL isContinuerExam;

/***************************自定义数据***********************************/
///考试系统域名
@property(nonatomic, copy) NSString *domain;
///
@property(nonatomic, copy) NSString *userExamId;



/***************************接口返回数据***********************************/
///试卷标题
@property(nonatomic, copy) NSString *paper_title;
///试卷标题描述
@property(nonatomic, copy) NSString *paper_titleDesc;
///试卷题型数组
@property(nonatomic, strong) NSArray<HXExamQuestionTypeModel *> *questionGroups;

///已答的题目答案
@property(nonatomic, strong) NSArray<HXExamAnswerModel *> *answers;

///试卷题目详情解析
@property(nonatomic, strong) NSArray<HXExamAnswerHintModel *> *jieXis;


@end

NS_ASSUME_NONNULL_END
