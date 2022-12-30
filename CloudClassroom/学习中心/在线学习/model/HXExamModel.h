//
//  HXExamModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXExamModel : NSObject
///提交试卷后能否看见答案    1能   0不能
@property (nonatomic,assign) BOOL  allowSeeAnswer;
///续考期间允许查看答案
@property (nonatomic,assign) BOOL allowSeeAnswerOnContinue;
///允许查看答卷
@property (nonatomic,assign) BOOL allowSeeResult;
///
@property(nonatomic, copy) NSString *beginTime;
///
@property(nonatomic, copy) NSString *endTime;
///开始时间（课件和考试）
@property(nonatomic, copy) NSString *finaltime;
///结束时间（课件和考试）
@property(nonatomic, copy) NSString *finaltimeEnd;
///能否考试
@property (nonatomic,assign) BOOL canExam;
///
@property (nonatomic,assign) BOOL canStart;
///是否在客户端判卷
@property (nonatomic,assign) BOOL clientJudge;
///
@property (nonatomic,assign) BOOL confuseChoice;
///
@property (nonatomic,assign) BOOL confuseOrder;
///
@property(nonatomic, copy) NSString *examId;
///
@property(nonatomic, copy) NSString *paperId;
///
@property(nonatomic, copy) NSString *userExamId;
///
@property(nonatomic, copy) NSString *userId;
///剩余考试次数
@property(nonatomic, assign) NSInteger leftExamNum;
///最大考试次数
@property(nonatomic, assign) NSInteger maxExamNum;
///
@property(nonatomic, assign) NSInteger limitTime;
///最大考试次数
@property(nonatomic, assign) NSInteger maxCreateTime;
///分数是否保密
@property (nonatomic,assign) BOOL scoreSecret;
///
@property (nonatomic,assign) BOOL singleCheck;
///试卷编码(用于获取考试列表)
@property(nonatomic, copy) NSString *logicId;
///
@property(nonatomic, copy) NSString *examTitle;
///提示信息
@property(nonatomic, copy) NSString *showMessage;



@end

NS_ASSUME_NONNULL_END
