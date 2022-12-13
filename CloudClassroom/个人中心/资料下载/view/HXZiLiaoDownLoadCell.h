//
//  HXZiLiaoDownLoadCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/23.
//

#import <UIKit/UIKit.h>
#import "HXZiLiaoDownLoadModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HXZiLiaoDownLoadCellDelegate <NSObject>

///下载资料
-(void)ziLiaoDownLoad:(HXZiLiaoDownLoadModel *)ziLiaoDownLoadModel;

@end

@interface HXZiLiaoDownLoadCell : UITableViewCell

@property(nonatomic,weak) id<HXZiLiaoDownLoadCellDelegate> delegate;

@property(nonatomic,strong) HXZiLiaoDownLoadModel *ziLiaoDownLoadModel;

@end

NS_ASSUME_NONNULL_END
