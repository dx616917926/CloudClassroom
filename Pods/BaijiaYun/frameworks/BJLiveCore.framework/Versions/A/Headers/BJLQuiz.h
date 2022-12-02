//
//  BJLQuiz.h
//  BJLiveCore
//
//  Created by xijia dai on 2019/7/2.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLQuizState) {
    BJLQuizState_edit = 1, // 编辑
    BJLQuizState_start = 2, // 开始
    BJLQuizState_end = 3, // 结束
    BJLQuizState_solve = 4, // 发布答案
    BJLQuizState_delete = 5, // 删除
};

typedef NS_ENUM(NSInteger, BJLQuizQuestionType) {
    BJLQuizQuestionType_radio = 1, // 单选
    BJLQuizQuestionType_checkbox = 2, // 多选
    BJLQuizQuestionType_shortAnswer = 3, // 简答
    BJLQuizQuestionType_judgment = 4, // 判断
};

@class BJLQuiz, BJLQuizQuestion, BJLQuizQuestionSolution, BJLQuizOption;

// 测验
@interface BJLQuiz: NSObject

@property (nonatomic) NSString *ID; // 0 为新增，否则更新对应 ID 的测验
@property (nonatomic) NSString *title; // 测验名
@property (nonatomic) BJLQuizState state; // 测验状态，仅在加载测验列表时数据有效
@property (nonatomic) BOOL force; // 是否强制参加
@property (nonatomic) BOOL finish; // 测验是否已完成
@property (nonatomic, nullable) NSArray<BJLQuizQuestion *> *questions; // 问题数据，创建试卷时直接设置好问题的正确答案，由于创建时不存在 ID，因此不读取 solutions 属性的内容
@property (nonatomic, nullable) NSDictionary<NSString *, id> *solutions; // 问题解答，key -> question ID, value -> solution content，对于 value，Radio 类型的问题的值为选项 ID，Checkbox 类型的问题的值为选项 ID 数组，ShortAnswer 类型的问题值为简答的关键内容
- (void)updateSolutionsWithQuestions; // 便捷构造方法。根据 questions 的正确答案构造或更新问题 solutions，如果 solutions 不需要通过 questions 中信息生成或者 solutions 内容是自定义的，这种情况下不要调用此方法

@end

// 测验中的问题
@interface BJLQuizQuestion: NSObject

@property (nonatomic) NSString *ID; // 0 为新增，否则更新对应 ID 的问题
@property (nonatomic) NSString *content; // 问题内容
@property (nonatomic) BJLQuizQuestionType type; // 问题类型
@property (nonatomic, nullable) NSArray<BJLQuizOption *> *options; // 对于选择题，选项数据
@property (nonatomic, nullable) NSString *suggestSolution; // 对于简答题，建议的答案
@property (nonatomic) NSInteger solutionCount; // 回答了问题的人数

@end

// 测验中的问题的选项
@interface BJLQuizOption: NSObject

@property (nonatomic) NSString *ID; // 0 为新增，否则更新对应 ID 的选项
@property (nonatomic) NSString *content; // 选项内容
@property (nonatomic) BOOL right; // 是否是正确选项
@property (nonatomic) NSInteger solutionCount; // 选中该选项的人数

@end

NS_ASSUME_NONNULL_END
