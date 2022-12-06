//
//  HXJieSuanCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import <UIKit/UIKit.h>
#import "HXOrderDetailInfoModel.h"
#import "HXFeeDetailInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXJieSuanCell : UITableViewCell

//是否第一和最后
@property(nonatomic,assign) BOOL isFirst;
@property(nonatomic,assign) BOOL isLast;
@property(nonatomic,assign) BOOL isBoth;
//是否有学期
@property(nonatomic,assign) BOOL isHaveXueQi;
//在线选课费项
@property(nonatomic,strong) HXOrderDetailInfoModel *orderDetailInfoModel;
//财务缴费费项
@property(nonatomic,strong) HXFeeDetailInfoModel *feeDetailInfoModel;

@end

NS_ASSUME_NONNULL_END
