//
//  HXXuanKeMoneyDetailCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/9.
//

#import <UIKit/UIKit.h>
#import "HXCourseOrderModel.h"
#import "HXStudentFeeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXXuanKeMoneyDetailCell : UITableViewCell
//是否有学期
@property(nonatomic,assign) BOOL isHaveXueQi;

@property(nonatomic,strong) HXCourseOrderModel *courseOrderModel;

@property(nonatomic,strong) HXStudentFeeModel *studentFeeModel;

@end

NS_ASSUME_NONNULL_END
