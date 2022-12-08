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
///问题答案
@property(nonatomic, copy) NSString *answer;
///
@property(nonatomic, copy) NSString *checkMemo;
///
@property(nonatomic, copy) NSString *file;
///
@property(nonatomic, copy) NSString *finalCheckMemo;
///
@property(nonatomic, copy) NSString *finalScore;
///
@property(nonatomic, copy) NSString *twoCheckMemo;
///
@property(nonatomic, copy) NSString *twoScore;
///
@property(nonatomic, copy) NSString *oneScore;
///
@property(nonatomic, assign) BOOL right;
///
@property(nonatomic, copy) NSString *score;

@end

NS_ASSUME_NONNULL_END
