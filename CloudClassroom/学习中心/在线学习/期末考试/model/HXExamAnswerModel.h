//
//  HXExamAnswerModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXExamAnswerModel : NSObject

///问题类型ID
@property(nonatomic, copy) NSString *pqt_id;
///考生答案
@property(nonatomic, copy) NSString *answer;
///阅卷评语
@property(nonatomic, copy) NSString *checkMemo;
///答案附件,格式: fileId/fileName 多个用逗号分割;
@property(nonatomic, copy) NSString *file;
///
@property(nonatomic, copy) NSString *finalCheckMemo;
///终评分数
@property(nonatomic, copy) NSString *finalScore;
///
@property(nonatomic, copy) NSString *twoCheckMemo;
///二评分数
@property(nonatomic, copy) NSString *twoScore;
///一评分数
@property(nonatomic, copy) NSString *oneScore;
///是否正确
@property(nonatomic, assign) BOOL right;
///
@property(nonatomic, copy) NSString *score;

@end

NS_ASSUME_NONNULL_END
