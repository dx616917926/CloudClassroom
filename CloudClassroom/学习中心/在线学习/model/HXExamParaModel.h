//
//  HXExamParaModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXExamParaModel : NSObject
///是否允许查看答案
@property(nonatomic, assign) BOOL allowSeeAnswer;
///是否允许查看答案继续
@property(nonatomic, assign) BOOL allowSeeAnswerOnContinue;
///是否允许查看结果
@property(nonatomic, assign) BOOL allowSeeResult;
///开始时间戳
@property(nonatomic, copy) NSString *beginTime;
///结束时间戳
@property(nonatomic, copy) NSString *endTime;
///是否能考试
@property(nonatomic, assign) BOOL canExam;
///
@property(nonatomic, assign) BOOL canStart;
///
@property(nonatomic, assign) BOOL clientJudge;
///
@property(nonatomic, assign) BOOL confuseChoice;
///
@property(nonatomic, copy) NSString *confuseOrder;
///
@property(nonatomic, copy) NSString *examId;
///
@property(nonatomic, copy) NSString *examTitle;
///
@property(nonatomic, assign) NSInteger leftExamNum;
///
@property(nonatomic, assign) NSInteger limitTime;
///
@property(nonatomic, assign) NSInteger maxCreateTime;
///
@property(nonatomic, assign) NSInteger maxExamNum;
///
@property(nonatomic, assign) BOOL scoreSecret;
///
@property(nonatomic, assign) BOOL singleCheck;

///提示信息
@property(nonatomic, copy) NSString *showMessage;


@end

NS_ASSUME_NONNULL_END
