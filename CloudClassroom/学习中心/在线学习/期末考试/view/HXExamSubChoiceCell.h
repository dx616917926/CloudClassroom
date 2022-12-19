//
//  HXExamSubChoiceCell.h
//  CloudClassroom
//
//  Created by mac on 2022/11/18.
//

#import <UIKit/UIKit.h>
#import "DTCoreTextToolsHeader.h"
#import "HXExamPaperSubQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamSubChoiceCell : UICollectionViewCell

@property(nonatomic,strong) HXExamPaperSubQuestionModel *examPaperSubQuestionModel;

@property(nonatomic,strong) UIViewController *examVc;

@end

NS_ASSUME_NONNULL_END
