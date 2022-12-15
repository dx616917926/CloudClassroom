//
//  HXExamAnswerCell.h
//  CloudClassroom
//
//  Created by mac on 2022/11/17.
//

#import <UIKit/UIKit.h>
#import "DTCoreTextToolsHeader.h"
#import "HXExamPaperSuitQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamAnswerCell : UICollectionViewCell

@property(nonatomic,strong) UIViewController *examVc;

@property(nonatomic,strong) HXExamPaperSuitQuestionModel *examPaperSuitQuestionModel;

@end

NS_ASSUME_NONNULL_END
