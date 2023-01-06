//
//  HXPingShiZuoYeCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import <UIKit/UIKit.h>
#import "HXExamModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HXPingShiZuoYeCellDelegate <NSObject>

///开始作业
-(void)startExam:(HXExamModel *)examModel startZuoYeBtn:(UIButton *)startZuoYeBtn;

///查看考试记录
-(void)chechExamRecord:(HXExamModel *)examModel;

@end

@interface HXPingShiZuoYeCell : UITableViewCell

@property(nonatomic,weak) id<HXPingShiZuoYeCellDelegate> delegate;

@property(nonatomic,strong) HXExamModel *examModel;

@end

NS_ASSUME_NONNULL_END
