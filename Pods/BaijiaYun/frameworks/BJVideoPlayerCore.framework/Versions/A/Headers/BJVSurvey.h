//
//  BJVSurvey.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BJVSurveyOption;

/** 测验结果 */
typedef NS_ENUM(NSInteger, BJVSurveyResult) {
    /** 正确 */
    BJVSurveyResultRight = 0,
    /** 错误 */
    BJVSurveyResultWrong = 1,
    /** 没有标准答案 */
    BJVSurveyResultNA = -1
};

/**
 测验题目
 */
@interface BJVSurvey: NSObject

/** 序号 */
@property (nonatomic) NSInteger order;
/** 题干 */
@property (nonatomic, copy) NSString *question;
/** 选项 */
@property (nonatomic, copy) NSArray<BJVSurveyOption *> *options;

@end

/**
 测验选项
 */
@interface BJVSurveyOption: NSObject

/**
 key: 选项 A, B, C, D;
 value: 选项描述 */
@property (nonatomic, copy) NSString *key, *value;
/** 是否是答案选项 */
@property (nonatomic) BOOL isAnswer;

/** 答题结果中选择此选项的人数 */
@property (nonatomic) NSInteger userCount;

@end

NS_ASSUME_NONNULL_END
