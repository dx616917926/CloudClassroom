//
//  HXMyMessageCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/9.
//

#import <UIKit/UIKit.h>
#import "HXMyMessageInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXMyMessageCell : UITableViewCell

@property(nonatomic,strong) HXMyMessageInfoModel *myMessageInfoModel;

@end

NS_ASSUME_NONNULL_END
