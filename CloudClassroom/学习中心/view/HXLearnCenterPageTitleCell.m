//
//  HXLearnCenterPageTitleCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXLearnCenterPageTitleCell.h"

@interface HXLearnCenterPageTitleCell ()

@property (nonatomic, strong) UIImageView *cycle;

@end

@implementation HXLearnCenterPageTitleCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    [self.contentView addSubview:self.cycle];
    self.cycle.sd_layout
    .bottomSpaceToView(self.contentView, 5)
    .centerXEqualToView(self.contentView)
    .widthIs(19)
    .heightIs(5);
    
}


//通过此父类方法配置cell是否被选中
- (void)configCellOfSelected:(BOOL)selected {
    [super configCellOfSelected:selected];
    self.cycle.hidden = !selected;
}

//通过此父类方法配置cell动画 progress0~1
- (void)showAnimationOfProgress:(CGFloat)progress type:(XLPageTitleCellAnimationType)type {
    [super showAnimationOfProgress:progress type:type];
    
    //已选中的item
    if (type == XLPageTitleCellAnimationTypeSelected) {
        
    }else if (type == XLPageTitleCellAnimationTypeWillSelected){
        //将要选中的item
        
        
    }
}


#pragma mark -LazyLoad
-(UIImageView *)cycle{
    if (!_cycle) {
        _cycle = [[UIImageView alloc] init];
        _cycle.image = [UIImage imageNamed:@"cycle_icon"];
    }
    return _cycle;
}

@end
