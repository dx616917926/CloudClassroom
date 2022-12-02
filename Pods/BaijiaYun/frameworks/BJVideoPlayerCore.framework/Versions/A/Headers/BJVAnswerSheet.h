//
//  BJVAnswerSheet.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BJVAnswerSheetOption;
@class BJVAnswerSheetUserDetail;
@class BJVUser;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJVAnswerSheetType) {
    BJVAnswerSheetType_Choosen, // 选择题
    BJVAnswerSheetType_Judgement // 判断题
};

/** 答题器 */

#pragma mark - BJVAnswerSheet

@interface BJVAnswerSheet: NSObject

@property (nonatomic, readonly) NSString *ID;

// 题目类型: 判断题或者选择题
@property (nonatomic) BJVAnswerSheetType answerType;

// 答题限制时间,单位为秒
@property (nonatomic) NSInteger duration;

// 题目描述
@property (nonatomic) NSString *questionDescription;

// 开始时间
@property (nonatomic, readonly) NSTimeInterval startTimeInterval;

// 发布人数
@property (nonatomic, readonly) NSInteger userCountParticipate;

// 提交人数
@property (nonatomic, readonly) NSInteger userCountSubmit;

// 答题正确人数
@property (nonatomic, readonly) NSInteger userCountCorrect;

// 答题结束后是否要显示正确答案,在发布答题之前设置，默认不显示
@property (nonatomic) BOOL shouldShowCorrectAnswer;

// 用户答题详情
@property (nonatomic, readonly) NSArray<BJVAnswerSheetUserDetail *> *userDetails;

// 题目选项内容
@property (nonatomic) NSArray<BJVAnswerSheetOption *> *options;

// 结束时间,默认是0
@property (nonatomic) NSTimeInterval endTimeInterval;

- (instancetype)initWithAnswerType:(BJVAnswerSheetType)type;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - BJVAnswerSheetOption

@interface BJVAnswerSheetOption: NSObject

/** 选项名：A, B, C, D */
@property (nonatomic) NSString *key;

/** 选项被选择的次数 */
@property (nonatomic, readonly) NSInteger choosenTimes;

/** 是否是答案选项 */
@property (nonatomic) BOOL isAnswer;

/** 提交答案时使用，表示此选项是否被选中 */
@property (nonatomic) BOOL selected;

- (instancetype)initWithID:(NSString *)ID isAnswer:(BOOL)isAnswer;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - BJVAnswerSheetUserDetail

@interface BJVAnswerSheetUserDetail: NSObject

@property (nonatomic, readonly) NSString *userNumber;

@property (nonatomic, readonly) BJVUser *user;

// 作答是否正确
@property (nonatomic, readonly) BOOL isCorrect;

// 作答所用时间
@property (nonatomic, readonly) NSInteger time;

// 答题选项
@property (nonatomic, readonly) NSArray<NSString *> *choices;

@end

NS_ASSUME_NONNULL_END
