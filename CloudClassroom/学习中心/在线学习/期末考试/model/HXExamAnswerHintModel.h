//
//  HXExamAnswerHintModel.h
//  CloudClassroom
//
//  Created by mac on 2023/1/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXExamAnswerHintModel : NSObject

///题目ID
@property(nonatomic, copy) NSString *questionId;
///父级ID
@property(nonatomic, copy) NSString *parentId;
///正确答案
@property(nonatomic, copy) NSString *answer;
///题目解析
@property(nonatomic, copy) NSString *hint;
///题目分数
@property(nonatomic, copy) NSString *score;
///基础数据类型 1:单选题 2:多选题 3:问答题 4:复合题
@property(nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
