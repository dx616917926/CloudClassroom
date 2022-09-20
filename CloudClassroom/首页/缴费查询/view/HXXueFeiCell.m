//
//  HXXueFeiCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/19.
//

#import "HXXueFeiCell.h"

@interface HXXueFeiCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *stateBtn;

//专业
@property(nonatomic,strong) UILabel *majorLabel;
@property(nonatomic,strong) UILabel *majorContentLabel;
//订单编号
@property(nonatomic,strong) UILabel *orderNoLabel;
@property(nonatomic,strong) UILabel *orderNoContentLabel;
//应缴金额
@property(nonatomic,strong) UILabel *yingJiaoLabel;
@property(nonatomic,strong) UILabel *yingJiaoContentLabel;
//已缴金额
@property(nonatomic,strong) UILabel *yiJiaoLabel;
@property(nonatomic,strong) UILabel *yiJiaoContentLabel;
//欠费金额
@property(nonatomic,strong) UILabel *qianJiaoLabel;
@property(nonatomic,strong) UILabel *qianJiaoContentLabel;
//支付方式
@property(nonatomic,strong) UILabel *paymentMethodLabel;
@property(nonatomic,strong) UILabel *paymentMethodContentLabel;
//支付方式
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UILabel *timeContentLabel;

@end

@implementation HXXueFeiCell

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



#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.stateBtn];
    [self.bigBackgroundView addSubview:self.majorLabel];
    [self.bigBackgroundView addSubview:self.majorContentLabel];
    [self.bigBackgroundView addSubview:self.orderNoLabel];
    [self.bigBackgroundView addSubview:self.orderNoContentLabel];
    [self.bigBackgroundView addSubview:self.yingJiaoLabel];
    [self.bigBackgroundView addSubview:self.yingJiaoContentLabel];
    [self.bigBackgroundView addSubview:self.yiJiaoLabel];
    [self.bigBackgroundView addSubview:self.yiJiaoContentLabel];
    [self.bigBackgroundView addSubview:self.qianJiaoLabel];
    [self.bigBackgroundView addSubview:self.qianJiaoContentLabel];
    [self.bigBackgroundView addSubview:self.paymentMethodLabel];
    [self.bigBackgroundView addSubview:self.paymentMethodContentLabel];
    [self.bigBackgroundView addSubview:self.timeLabel];
    [self.bigBackgroundView addSubview:self.timeContentLabel];
  
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    self.stateBtn.sd_layout
    .topSpaceToView(self.bigBackgroundView, 17)
    .rightSpaceToView(self.bigBackgroundView, 16);
    [self.stateBtn setupAutoSizeWithHorizontalPadding:10 buttonHeight:20];
   
    self.titleLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.stateBtn, 16)
    .heightIs(21);
   
    self.majorLabel.sd_layout
    .topSpaceToView(self.titleLabel, 16)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .widthIs(70)
    .heightIs(21);
    
    self.majorContentLabel.sd_layout
    .centerYEqualToView(self.majorLabel)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.majorLabel, 16)
    .heightRatioToView(self.majorLabel, 1);
    
    self.orderNoLabel.sd_layout
    .topSpaceToView(self.majorLabel, 16)
    .leftEqualToView(self.majorLabel)
    .widthRatioToView(self.majorLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.orderNoContentLabel.sd_layout
    .centerYEqualToView(self.orderNoLabel)
    .rightEqualToView(self.majorContentLabel)
    .widthRatioToView(self.majorContentLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.yingJiaoLabel.sd_layout
    .topSpaceToView(self.orderNoLabel, 16)
    .leftEqualToView(self.majorLabel)
    .widthRatioToView(self.majorLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.yingJiaoContentLabel.sd_layout
    .centerYEqualToView(self.yingJiaoLabel)
    .rightEqualToView(self.majorContentLabel)
    .widthRatioToView(self.majorContentLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.yiJiaoLabel.sd_layout
    .topSpaceToView(self.yingJiaoLabel, 16)
    .leftEqualToView(self.majorLabel)
    .widthRatioToView(self.majorLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.yiJiaoContentLabel.sd_layout
    .centerYEqualToView(self.yiJiaoLabel)
    .rightEqualToView(self.majorContentLabel)
    .widthRatioToView(self.majorContentLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.qianJiaoLabel.sd_layout
    .topSpaceToView(self.yiJiaoLabel, 16)
    .leftEqualToView(self.majorLabel)
    .widthRatioToView(self.majorLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.qianJiaoContentLabel.sd_layout
    .centerYEqualToView(self.qianJiaoLabel)
    .rightEqualToView(self.majorContentLabel)
    .widthRatioToView(self.majorContentLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.paymentMethodLabel.sd_layout
    .topSpaceToView(self.qianJiaoLabel, 16)
    .leftEqualToView(self.majorLabel)
    .widthRatioToView(self.majorLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.paymentMethodContentLabel.sd_layout
    .centerYEqualToView(self.paymentMethodLabel)
    .rightEqualToView(self.majorContentLabel)
    .widthRatioToView(self.majorContentLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.timeLabel.sd_layout
    .topSpaceToView(self.paymentMethodLabel, 16)
    .leftEqualToView(self.majorLabel)
    .widthRatioToView(self.majorLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
    
    self.timeContentLabel.sd_layout
    .centerYEqualToView(self.timeLabel)
    .rightEqualToView(self.majorContentLabel)
    .widthRatioToView(self.majorContentLabel, 1)
    .heightRatioToView(self.majorLabel, 1);
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

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = HXBoldFont(15);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _titleLabel.text = @"2021 学杂费";
    }
    return _titleLabel;
}

- (UIButton *)stateBtn{
    if (!_stateBtn) {
        _stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stateBtn.titleLabel.font = HXFont(12);
        _stateBtn.backgroundColor = COLOR_WITH_ALPHA(0xEAFBEC, 1);
        [_stateBtn setTitleColor:COLOR_WITH_ALPHA(0x5DC367, 1) forState:UIControlStateNormal];
        [_stateBtn setTitle:@"已完成" forState:UIControlStateNormal];
    }
    return _stateBtn;
}


- (UILabel *)majorLabel{
    if (!_majorLabel) {
        _majorLabel = [[UILabel alloc] init];
        _majorLabel.textAlignment = NSTextAlignmentLeft;
        _majorLabel.font = HXFont(15);
        _majorLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _majorLabel.text = @"专业";
    }
    return _majorLabel;
}

- (UILabel *)majorContentLabel{
    if (!_majorContentLabel) {
        _majorContentLabel = [[UILabel alloc] init];
        _majorContentLabel.textAlignment = NSTextAlignmentRight;
        _majorContentLabel.font = HXFont(15);
        _majorContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _majorContentLabel.text = @"计算机科学与技术";
    }
    return _majorContentLabel;
}

- (UILabel *)orderNoLabel{
    if (!_orderNoLabel) {
        _orderNoLabel = [[UILabel alloc] init];
        _orderNoLabel.textAlignment = NSTextAlignmentLeft;
        _orderNoLabel.font = HXFont(15);
        _orderNoLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _orderNoLabel.text = @"订单编号";
    }
    return _orderNoLabel;
}

- (UILabel *)orderNoContentLabel{
    if (!_orderNoContentLabel) {
        _orderNoContentLabel = [[UILabel alloc] init];
        _orderNoContentLabel.textAlignment = NSTextAlignmentRight;
        _orderNoContentLabel.font = HXFont(15);
        _orderNoContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _orderNoContentLabel.text = @"202206239876855";
    }
    return _orderNoContentLabel;
}

- (UILabel *)yingJiaoLabel{
    if (!_yingJiaoLabel) {
        _yingJiaoLabel = [[UILabel alloc] init];
        _yingJiaoLabel.textAlignment = NSTextAlignmentLeft;
        _yingJiaoLabel.font = HXFont(15);
        _yingJiaoLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _yingJiaoLabel.text = @"应缴金额";
    }
    return _yingJiaoLabel;
}

- (UILabel *)yingJiaoContentLabel{
    if (!_yingJiaoContentLabel) {
        _yingJiaoContentLabel = [[UILabel alloc] init];
        _yingJiaoContentLabel.textAlignment = NSTextAlignmentRight;
        _yingJiaoContentLabel.font = HXFont(15);
        _yingJiaoContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _yingJiaoContentLabel.text = @"￥50.00";
    }
    return _yingJiaoContentLabel;
}

- (UILabel *)yiJiaoLabel{
    if (!_yiJiaoLabel) {
        _yiJiaoLabel = [[UILabel alloc] init];
        _yiJiaoLabel.textAlignment = NSTextAlignmentLeft;
        _yiJiaoLabel.font = HXFont(15);
        _yiJiaoLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _yiJiaoLabel.text = @"已缴金额";
    }
    return _yiJiaoLabel;
}

- (UILabel *)yiJiaoContentLabel{
    if (!_yiJiaoContentLabel) {
        _yiJiaoContentLabel = [[UILabel alloc] init];
        _yiJiaoContentLabel.textAlignment = NSTextAlignmentRight;
        _yiJiaoContentLabel.font = HXFont(15);
        _yiJiaoContentLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _yiJiaoContentLabel.text = @"￥50.00";
    }
    return _yiJiaoContentLabel;
}

- (UILabel *)qianJiaoLabel{
    if (!_qianJiaoLabel) {
        _qianJiaoLabel = [[UILabel alloc] init];
        _qianJiaoLabel.textAlignment = NSTextAlignmentLeft;
        _qianJiaoLabel.font = HXFont(15);
        _qianJiaoLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _qianJiaoLabel.text = @"欠费金额";
    }
    return _qianJiaoLabel;
}

- (UILabel *)qianJiaoContentLabel{
    if (!_qianJiaoContentLabel) {
        _qianJiaoContentLabel = [[UILabel alloc] init];
        _qianJiaoContentLabel.textAlignment = NSTextAlignmentRight;
        _qianJiaoContentLabel.font = HXFont(15);
        _qianJiaoContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _qianJiaoContentLabel.text = @"0";
    }
    return _qianJiaoContentLabel;
}


- (UILabel *)paymentMethodLabel{
    if (!_paymentMethodLabel) {
        _paymentMethodLabel = [[UILabel alloc] init];
        _paymentMethodLabel.textAlignment = NSTextAlignmentLeft;
        _paymentMethodLabel.font = HXFont(15);
        _paymentMethodLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _paymentMethodLabel.text = @"支付方式";
    }
    return _paymentMethodLabel;
}

- (UILabel *)paymentMethodContentLabel{
    if (!_paymentMethodContentLabel) {
        _paymentMethodContentLabel = [[UILabel alloc] init];
        _paymentMethodContentLabel.textAlignment = NSTextAlignmentRight;
        _paymentMethodContentLabel.font = HXFont(15);
        _paymentMethodContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _paymentMethodContentLabel.text = @"微信支付";
    }
    return _paymentMethodContentLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.font = HXFont(15);
        _timeLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _timeLabel.text = @"支付时间";
    }
    return _timeLabel;
}

- (UILabel *)timeContentLabel{
    if (!_timeContentLabel) {
        _timeContentLabel = [[UILabel alloc] init];
        _timeContentLabel.textAlignment = NSTextAlignmentRight;
        _timeContentLabel.font = HXFont(15);
        _timeContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _timeContentLabel.text = @"2020.05.31 20:00";
    }
    return _timeContentLabel;
}



@end




