//
//  HXXuanKeMoneyDetailCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/9.
//

#import "HXXuanKeMoneyDetailCell.h"

@interface HXXuanKeMoneyDetailCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIButton *xueQiBtn;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *priceLabel;


@end

@implementation HXXuanKeMoneyDetailCell

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
- (void)setIsHaveXueQi:(BOOL)isHaveXueQi{
    _isHaveXueQi = isHaveXueQi;
    if (!isHaveXueQi) {
        self.xueQiBtn.sd_layout.widthIs(0);
        self.courseNameLabel.sd_layout.leftSpaceToView(self.xueQiBtn, 0);
    }else{
        self.xueQiBtn.sd_layout.widthIs(50);
        self.courseNameLabel.sd_layout.leftSpaceToView(self.xueQiBtn, 8);
    }
}

#pragma mark - UI
-(void)createUI{

    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.xueQiBtn];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.priceLabel];
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.bigBackgroundView.sd_cornerRadius = @8;
    

    self.priceLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .widthIs(80)
    .heightIs(20);
    
    self.xueQiBtn.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .widthIs(50)
    .heightIs(21);
    self.xueQiBtn.sd_cornerRadius=@2;
    
    self.courseNameLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.xueQiBtn, 8)
    .rightSpaceToView(self.priceLabel, 16)
    .heightIs(20);
    
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


- (UIButton *)xueQiBtn{
    if (!_xueQiBtn) {
        _xueQiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _xueQiBtn.titleLabel.font = HXBoldFont(15);
        _xueQiBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 0.1);
        [_xueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_xueQiBtn setTitle:@"2022" forState:UIControlStateNormal];
    }
    return _xueQiBtn;
}

- (UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.font = HXBoldFont(15);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _courseNameLabel.text = @"马克思主义基本原理概论";
    }
    return _courseNameLabel;
}


- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = HXBoldFont(14);
        _priceLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.isAttributedContent = YES;
        _priceLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"50." needAttributed:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:@"￥50.00" defaultAttributed:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    }
    return _priceLabel;
}


@end

