//
//  HXExamRecordCell.h
//  CloudClassroom
//
//  Created by mac on 2022/12/7.
//

#import <UIKit/UIKit.h>
#import "HXExamRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HXExamRecordCellDelegate <NSObject>

///查看答卷
-(void)checkAnswer:(HXExamRecordModel *)examRecordModel checkAnswerBtn:(UIButton *)checkAnswerBtn;

///继续作答
-(void)continueExam:(HXExamRecordModel *)examRecordModel continueExamBtn:(UIButton *)continueExamBtn;

@end

@interface HXExamRecordCell : UITableViewCell

@property(nonatomic,weak) id<HXExamRecordCellDelegate> delegate;

@property(nonatomic,strong) HXExamRecordModel *examRecordModel;

@end

NS_ASSUME_NONNULL_END
