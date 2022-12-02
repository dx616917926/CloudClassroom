//
//  BJVQuiz.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJVQuizState) {
    BJVQuizState_edit = 1, // 编辑
    BJVQuizState_start = 2, // 开始
    BJVQuizState_end = 3, // 结束
    BJVQuizState_solve = 4, // 发布答案
    BJVQuizState_delete = 5, // 删除
};

typedef NS_ENUM(NSInteger, BJVQuizQuestionType) {
    BJVQuizQuestionType_radio = 1, // 单选
    BJVQuizQuestionType_checkbox = 2, // 多选
    BJVQuizQuestionType_shortAnswer = 3, // 简答
    BJVQuizQuestionType_judgment = 4, // 判断
};

@class BJVQuiz, BJVQuizQuestion, BJVQuizQuestionSolution, BJVQuizOption;

// 测验
@interface BJVQuiz: NSObject

@property (nonatomic) NSString *ID; // 0 为新增，否则更新对应 ID 的测验
@property (nonatomic) NSString *title; // 测验名
@property (nonatomic) BJVQuizState state; // 测验状态，仅在加载测验列表时数据有效
@property (nonatomic) BOOL force; // 是否强制参加
@property (nonatomic) BOOL finish; // 测验是否已完成
@property (nonatomic, nullable) NSArray<BJVQuizQuestion *> *questions; // 问题数据，创建试卷时直接设置好问题的正确答案，由于创建时不存在 ID，因此不读取 solutions 属性的内容
@property (nonatomic, nullable) NSDictionary<NSString *, id> *solutions; // 问题解答，key -> question ID, value -> solution content，对于 value，Radio 类型的问题的值为选项 ID，Checkbox 类型的问题的值为选项 ID 数组，ShortAnswer 类型的问题值为简答的关键内容
- (void)updateSolutionsWithQuestions; // 便捷构造方法。根据 questions 的正确答案构造或更新问题 solutions，如果 solutions 不需要通过 questions 中信息生成或者 solutions 内容是自定义的，这种情况下不要调用此方法

@end

// 测验中的问题
@interface BJVQuizQuestion: NSObject

@property (nonatomic) NSString *ID; // 0 为新增，否则更新对应 ID 的问题
@property (nonatomic) NSString *content; // 问题内容
@property (nonatomic) BJVQuizQuestionType type; // 问题类型
@property (nonatomic, nullable) NSArray<BJVQuizOption *> *options; // 对于选择题，选项数据
@property (nonatomic, nullable) NSString *suggestSolution; // 对于简答题，建议的答案
@property (nonatomic) NSInteger solutionCount; // 回答了问题的人数

@end

// 测验中的问题的选项
@interface BJVQuizOption: NSObject

@property (nonatomic) NSString *ID; // 0 为新增，否则更新对应 ID 的选项
@property (nonatomic) NSString *content; // 选项内容
@property (nonatomic) BOOL right; // 是否是正确选项
@property (nonatomic) NSInteger solutionCount; // 选中该选项的人数

@end

NS_ASSUME_NONNULL_END
