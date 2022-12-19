//
//  HXExamFuHeCell.h
//  CloudClassroom
//
//  Created by mac on 2022/11/18.
//

#import <UIKit/UIKit.h>
#import "DTCoreTextToolsHeader.h"
#import "HXExamPaperSuitQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXExamFuHeCell : UICollectionViewCell

@property(nonatomic,strong) HXExamPaperSuitQuestionModel *examPaperSuitQuestionModel;

@property(nonatomic,strong) UIViewController *examVc;

//点击答题卡，子题滑动到相应位置
-(void)scrollSubPosition:(NSInteger)position;

@end

NS_ASSUME_NONNULL_END
