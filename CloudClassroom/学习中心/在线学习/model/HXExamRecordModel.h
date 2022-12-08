//
//  HXExamRecordModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXExamRecordModel : NSObject

///提交试卷后能否看见答案
@property (nonatomic,assign) BOOL  allowSeeAnswer;
///能否继续作答
@property (nonatomic,assign) BOOL  canContinue;
///
@property (nonatomic,assign) BOOL  checked;

///
@property(nonatomic, copy) NSString *accountId;
///开始时间
@property(nonatomic, copy) NSString *beginTime;
///
@property(nonatomic, copy) NSString *context;
///
@property(nonatomic, copy) NSString *examId;
///
@property(nonatomic, copy) NSString *limitTime;
///
@property(nonatomic, copy) NSString *paperId;
///
@property(nonatomic, copy) NSString *paperSuitId;
///得分
@property(nonatomic, copy) NSString *score;
///
@property(nonatomic, copy) NSString *serverId;
///
@property(nonatomic, copy) NSString *viewUrl;

///
@property (nonatomic,assign) NSInteger  index;

@end

NS_ASSUME_NONNULL_END
