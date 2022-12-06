//
//  HXExamPaperModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "HXExamQuestionTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamPaperModel : NSObject

///考试系统域名
@property(nonatomic, copy) NSString *domain;
///
@property(nonatomic, copy) NSString *userExamId;
///试卷标题
@property(nonatomic, copy) NSString *paper_title;
///试卷标题描述
@property(nonatomic, copy) NSString *paper_titleDesc;
///试卷题型数组
@property(nonatomic, strong) NSArray<HXExamQuestionTypeModel *> *questionGroups;

@end

NS_ASSUME_NONNULL_END
