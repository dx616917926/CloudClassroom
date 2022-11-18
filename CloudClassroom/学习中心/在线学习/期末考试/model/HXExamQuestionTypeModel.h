//
//  HXExamQuestionTypeModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/15.
//

#import <Foundation/Foundation.h>
#import "HXExamPaperSuitQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamQuestionTypeModel : NSObject
///问题类型子标题
@property(nonatomic, copy) NSString *pqt_paperSubTitle;
///问题类型子标题描述
@property(nonatomic, copy) NSString *pqt_paperSubTitleDesc;
///问题类型标题   1.单选题
@property(nonatomic, copy) NSString *pqt_title;
///问题类型ID
@property(nonatomic, copy) NSString *pqt_id;
///问题数组、子问题数组
@property(nonatomic, strong) NSArray<HXExamPaperSuitQuestionModel *> *paperSuitQuestions;


@end

NS_ASSUME_NONNULL_END
