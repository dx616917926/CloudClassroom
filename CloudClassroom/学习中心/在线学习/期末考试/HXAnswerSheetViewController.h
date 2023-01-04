//
//  HXAnswerSheetViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/11/21.
//

#import "HXBaseViewController.h"
#import "HXExamViewController.h"
#import "HXExamPaperModel.h"

NS_ASSUME_NONNULL_BEGIN
///点击题目回调
typedef void (^AnswerSheetBlock)(NSInteger position,NSInteger fuhe_position,BOOL isFuhe);

@interface HXAnswerSheetViewController : HXBaseViewController

@property(nonatomic,strong) HXExamPaperModel *examPaperModel;



@property (nonatomic, copy) AnswerSheetBlock  answerSheetBlock;

@property(nonatomic,strong) HXExamViewController *examVc;

@end

NS_ASSUME_NONNULL_END
