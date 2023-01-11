//
//  HXCommonSelectCell.m
//  CloudClassroom
//
//  Created by mac on 2023/1/11.
//

#import "HXCommonSelectCell.h"

@interface HXCommonSelectCell ()

@property(nonatomic,strong) UILabel *titleLabel;

@end

@implementation HXCommonSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}


#pragma mark - Setter
-(void)setModel:(HXCommonSelectModel *)model{
    _model = model;
    
    self.titleLabel.text = model.content;
    if(model.isSelected){
        self.titleLabel.font = HXBoldFont(16);
        self.titleLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    }else{
        self.titleLabel.font = HXFont(16);
        self.titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
    }
}


#pragma mark - UI
-(void)createUI{
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.sd_layout.spaceToSuperView(UIEdgeInsetsMake(5, 10, 5, 10));
}
#pragma mark - lazyLoad

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXFont(16);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _titleLabel;
}



@end


