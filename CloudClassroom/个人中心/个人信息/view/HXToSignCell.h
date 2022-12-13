//
//  HXToSignCell.h
//  CloudClassroom
//
//  Created by mac on 2022/12/12.
//

#import <UIKit/UIKit.h>
#import "SDWebImage.h"
#import "HXPersonalInforModel.h"



NS_ASSUME_NONNULL_BEGIN

@interface HXToSignCell : UITableViewCell

@property(nonatomic,strong) UIButton *signBtn;

@property(nonatomic,strong)  HXPersonalInforModel *personalInforModel;

@end

NS_ASSUME_NONNULL_END
