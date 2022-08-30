//
//  HXCalendarCollectionCell.h
//  HXXiaoGuan
//
//  Created by mac on 2021/6/1.
//

#import <UIKit/UIKit.h>
#import "HXCalendarDayItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXCalendarCollectionCell : UICollectionViewCell

@property (nonatomic,strong)HXCalendarDayItem *item;
@property (nonatomic,assign)BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
