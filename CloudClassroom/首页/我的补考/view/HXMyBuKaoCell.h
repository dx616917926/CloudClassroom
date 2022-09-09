//
//  HXMyBuKaoCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HXMyBuKaoCellDelegate <NSObject>

//type:0 作业  1:考试
-(void)jumpType:(NSInteger)type;

@end

@interface HXMyBuKaoCell : UITableViewCell

@property(nonatomic,weak) id<HXMyBuKaoCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
