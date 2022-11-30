//
//  HXZaiXianXuanKeCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXZaiXianXuanKeCell.h"

@interface HXZaiXianXuanKeCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIButton *selectBtn;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *termLabel;
@property(nonatomic,strong) UILabel *priceLabel;


@end

@implementation HXZaiXianXuanKeCell

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
-(void)setCourseOrderModel:(HXCourseOrderModel *)courseOrderModel{
    
    _courseOrderModel = courseOrderModel;
    
    self.selectBtn.selected = courseOrderModel.isSeleted;
    
    self.courseNameLabel.text = courseOrderModel.termCourseName;
    self.termLabel.text = [NSString stringWithFormat:@"第%@学期",courseOrderModel.term];
    NSString *content = [NSString stringWithFormat:@"￥%.2f",courseOrderModel.iPrice];
    NSArray *tempArray = [HXFloatToString(courseOrderModel.iPrice) componentsSeparatedByString:@"."];
    NSString *needStr = [tempArray.firstObject stringByAppendingString:@"."];
    self.priceLabel.attributedText = [HXCommonUtil getAttributedStringWith:needStr needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:content defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    
}

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.selectBtn];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.termLabel];
    [self.bigBackgroundView addSubview:self.priceLabel];
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(8, 12, 8, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    self.selectBtn.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .widthIs(22)
    .heightEqualToWidth();
    
    self.priceLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .widthIs(80)
    .heightIs(20);
    
    self.courseNameLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundView).offset(-10)
    .leftSpaceToView(self.selectBtn, 12)
    .rightSpaceToView(self.priceLabel, 16)
    .heightIs(21);
    
    
    self.termLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 2)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightIs(16);
    
}


#pragma mark - LazyLoad
-(UIView *)bigBackgroundView{
    if (!_bigBackgroundView) {
        _bigBackgroundView = [[UIView alloc] init];
        _bigBackgroundView.backgroundColor = [UIColor whiteColor];
        _bigBackgroundView.clipsToBounds = YES;
    }
    return _bigBackgroundView;
}

- (UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setImage:[UIImage imageNamed:@"noselect_icon"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        _selectBtn.userInteractionEnabled = NO;
    }
    return _selectBtn;
}

- (UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.font = HXBoldFont(15);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _courseNameLabel;
}

- (UILabel *)termLabel{
    if (!_termLabel) {
        _termLabel = [[UILabel alloc] init];
        _termLabel.font = HXFont(11);
        _termLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        
    }
    return _termLabel;
}


- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = HXBoldFont(14);
        _priceLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.isAttributedContent = YES;
        
    }
    return _priceLabel;
}


@end


