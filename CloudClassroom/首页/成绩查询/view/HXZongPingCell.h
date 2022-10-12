//
//  HXZongPingCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import <UIKit/UIKit.h>
#import "HXScoreModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXZongPingCell : UITableViewCell

//是否第一和最后
@property(nonatomic,assign) BOOL isFirst;
@property(nonatomic,assign) BOOL isLast;

@property(nonatomic,strong) HXScoreModel *scoreModel;

@end

NS_ASSUME_NONNULL_END
