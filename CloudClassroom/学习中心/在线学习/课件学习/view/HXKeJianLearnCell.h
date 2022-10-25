//
//  HXKeJianLearnCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import <UIKit/UIKit.h>
#import "HXKeJianOrExamInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol HXKeJianLearnCellDelegate <NSObject>

///开始学习
-(void)playCourse:(HXKeJianOrExamInfoModel *)model;

@end

@interface HXKeJianLearnCell : UITableViewCell

@property(nonatomic,weak) id<HXKeJianLearnCellDelegate> delegate;

@property(nonatomic,strong) HXKeJianOrExamInfoModel *keJianOrExamInfoModel;

@end

NS_ASSUME_NONNULL_END
