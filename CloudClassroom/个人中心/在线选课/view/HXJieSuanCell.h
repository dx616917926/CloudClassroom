//
//  HXJieSuanCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import <UIKit/UIKit.h>
#import "HXOrderDetailInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXJieSuanCell : UITableViewCell

//是否第一和最后
@property(nonatomic,assign) BOOL isFirst;
@property(nonatomic,assign) BOOL isLast;
//是否有学期
@property(nonatomic,assign) BOOL isHaveXueQi;

@property(nonatomic,strong) HXOrderDetailInfoModel *orderDetailInfoModel;

@end

NS_ASSUME_NONNULL_END
