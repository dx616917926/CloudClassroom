//
//  HXZiLiaoUploadCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HXZiLiaoUploadCellDelegate <NSObject>

-(void)addPhotoForZiLiaoImageView:(UIImageView *)ziLiaoImageView hiddenAddBtn:(UIButton *)button;

-(void)tapZiLiaoImageView:(UIImageView *)ziLiaoImageView;

@end

@interface HXZiLiaoUploadCell : UITableViewCell

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *tipLabel;

@property(nonatomic,weak) id<HXZiLiaoUploadCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
