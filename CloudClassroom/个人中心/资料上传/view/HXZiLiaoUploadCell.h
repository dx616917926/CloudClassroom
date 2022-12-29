//
//  HXZiLiaoUploadCell.h
//  CloudClassroom
//
//  Created by mac on 2022/9/27.
//

#import <UIKit/UIKit.h>
#import "SDWebImage.h"
#import "HXImgModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HXZiLiaoUploadCellDelegate <NSObject>

-(void)addPhotoForZiLiaoImageView:(UIImageView *)ziLiaoImageView hiddenAddBtn:(UIButton *)button imgModel:(HXImgModel *)imgModel;

-(void)tapZiLiaoImageView:(UIImageView *)ziLiaoImageView imgModel:(HXImgModel *)imgModel;

@end

@interface HXZiLiaoUploadCell : UITableViewCell



@property(nonatomic,weak) id<HXZiLiaoUploadCellDelegate>delegate;

@property(nonatomic,strong) HXImgModel *imgModel;

@end

NS_ASSUME_NONNULL_END
