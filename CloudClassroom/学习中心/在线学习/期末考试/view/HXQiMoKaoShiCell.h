//
//  HXQiMoKaoShiCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import <UIKit/UIKit.h>
#import "HXExamModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol HXQiMoKaoShiCellDelegate <NSObject>

///开始考试
-(void)startExam:(HXExamModel *)examModel startKaoShiBtn:(UIButton *)startKaoShiBtn;

///查看考试记录
-(void)chechExamRecord:(HXExamModel *)examModel;

@end

@interface HXQiMoKaoShiCell : UITableViewCell


@property(nonatomic,weak) id<HXQiMoKaoShiCellDelegate> delegate;


@property(nonatomic,strong) HXExamModel *examModel;

@end

NS_ASSUME_NONNULL_END
