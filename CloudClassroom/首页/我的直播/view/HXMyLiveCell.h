//
//  HXMyLiveCell.h
//  CloudClassroom
//
//  Created by mac on 2022/10/18.
//

#import <UIKit/UIKit.h>
#import "HXLiveDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@class HXMyLiveCell;

@protocol HXMyLiveCellDelegate <NSObject>

/// 点击了播放按钮
- (void)watchLiveWithDetailModel:(HXLiveDetailModel *)liveDetailModel;

@end


@interface HXMyLiveCell : UITableViewCell

@property(nonatomic,strong) HXLiveDetailModel *liveDetailModel;

@property(nonatomic, weak) id<HXMyLiveCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
