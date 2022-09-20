//
//  HXWangKeZiYuanFeiCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/19.
//

#import "HXWangKeZiYuanFeiCell.h"

@interface HXWangKeZiYuanFeiCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *stateBtn;

//下单金额
@property(nonatomic,strong) UILabel *xiaDanLabel;
@property(nonatomic,strong) UILabel *xiaDanContentLabel;
//支付方式
@property(nonatomic,strong) UILabel *paymentMethodLabel;
@property(nonatomic,strong) UILabel *paymentMethodContentLabel;
//支付时间
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UILabel *timeContentLabel;
//订单编号
@property(nonatomic,strong) UILabel *orderNoLabel;
@property(nonatomic,strong) UILabel *orderNoContentLabel;

@end

@implementation HXWangKeZiYuanFeiCell

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
    [self.bigBackgroundView addSubview:self.xiaDanLabel];
    [self.bigBackgroundView addSubview:self.xiaDanContentLabel];
    [self.bigBackgroundView addSubview:self.paymentMethodLabel];
    [self.bigBackgroundView addSubview:self.paymentMethodContentLabel];
    [self.bigBackgroundView addSubview:self.timeLabel];
    [self.bigBackgroundView addSubview:self.timeContentLabel];
    [self.bigBackgroundView addSubview:self.orderNoLabel];
    [self.bigBackgroundView addSubview:self.orderNoContentLabel];
  
    
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
   
    self.xiaDanLabel.sd_layout
    .topSpaceToView(self.titleLabel, 16)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .widthIs(70)
    .heightIs(21);
    
    self.xiaDanContentLabel.sd_layout
    .centerYEqualToView(self.xiaDanLabel)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.xiaDanLabel, 16)
    .heightRatioToView(self.xiaDanLabel, 1);
    
    
    
    self.paymentMethodLabel.sd_layout
    .topSpaceToView(self.xiaDanLabel, 16)
    .leftEqualToView(self.xiaDanLabel)
    .widthRatioToView(self.xiaDanLabel, 1)
    .heightRatioToView(self.xiaDanLabel, 1);
    
    self.paymentMethodContentLabel.sd_layout
    .centerYEqualToView(self.paymentMethodLabel)
    .rightEqualToView(self.xiaDanContentLabel)
    .widthRatioToView(self.xiaDanContentLabel, 1)
    .heightRatioToView(self.xiaDanLabel, 1);
    
    self.timeLabel.sd_layout
    .topSpaceToView(self.paymentMethodLabel, 16)
    .leftEqualToView(self.xiaDanLabel)
    .widthRatioToView(self.xiaDanLabel, 1)
    .heightRatioToView(self.xiaDanLabel, 1);
    
    self.timeContentLabel.sd_layout
    .centerYEqualToView(self.timeLabel)
    .rightEqualToView(self.xiaDanContentLabel)
    .widthRatioToView(self.xiaDanContentLabel, 1)
    .heightRatioToView(self.xiaDanLabel, 1);
    
    
    self.orderNoLabel.sd_layout
    .topSpaceToView(self.timeLabel, 16)
    .leftEqualToView(self.xiaDanLabel)
    .widthRatioToView(self.xiaDanLabel, 1)
    .heightRatioToView(self.xiaDanLabel, 1);
    
    self.orderNoContentLabel.sd_layout
    .centerYEqualToView(self.orderNoLabel)
    .rightEqualToView(self.xiaDanContentLabel)
    .widthRatioToView(self.xiaDanContentLabel, 1)
    .heightRatioToView(self.xiaDanLabel, 1);
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
        _titleLabel.text = @"中国近代史纲要";
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


- (UILabel *)xiaDanLabel{
    if (!_xiaDanLabel) {
        _xiaDanLabel = [[UILabel alloc] init];
        _xiaDanLabel.textAlignment = NSTextAlignmentLeft;
        _xiaDanLabel.font = HXFont(15);
        _xiaDanLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _xiaDanLabel.text = @"下单金额";
    }
    return _xiaDanLabel;
}

- (UILabel *)xiaDanContentLabel{
    if (!_xiaDanContentLabel) {
        _xiaDanContentLabel = [[UILabel alloc] init];
        _xiaDanContentLabel.textAlignment = NSTextAlignmentRight;
        _xiaDanContentLabel.font = HXFont(15);
        _xiaDanContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _xiaDanContentLabel.text = @"￥50.00";
    }
    return _xiaDanContentLabel;
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


@end





