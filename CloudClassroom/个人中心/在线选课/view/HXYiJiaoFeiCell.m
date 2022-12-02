//
//  HXYiJiaoFeiCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXYiJiaoFeiCell.h"

@interface HXYiJiaoFeiCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *courseNameLabel;

//支付时间
@property(nonatomic,strong) UILabel *timeTitleLabel;
@property(nonatomic,strong) UILabel *timeContentLabel;
//订单编号
@property(nonatomic,strong) UILabel *orderNoTitleLabel;
@property(nonatomic,strong) UILabel *orderNoContentLabel;
//下单金额
@property(nonatomic,strong) UILabel *priceTitleLabel;
@property(nonatomic,strong) UILabel *priceContentLabel;
//支付方式
@property(nonatomic,strong) UILabel *paymentMethodTitleLabel;
@property(nonatomic,strong) UILabel *paymentMethodContentLabel;

@end

@implementation HXYiJiaoFeiCell

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
-(void)setCoursePayOrderModel:(HXCoursePayOrderModel *)coursePayOrderModel{
    
    _coursePayOrderModel = coursePayOrderModel;
    
    self.courseNameLabel.text = coursePayOrderModel.termCourseName;
    self.timeContentLabel.text = coursePayOrderModel.order_date;
    self.orderNoContentLabel.text = coursePayOrderModel.order_no;
    NSString *content = [NSString stringWithFormat:@"￥%.2f",coursePayOrderModel.price];
    NSArray *tempArray = [HXFloatToString(coursePayOrderModel.price) componentsSeparatedByString:@"."];
    NSString *needStr = [tempArray.firstObject stringByAppendingString:@"."];
    self.priceContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:needStr needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:content defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    self.paymentMethodContentLabel.text = coursePayOrderModel.order_type;

}

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.timeTitleLabel];
    [self.bigBackgroundView addSubview:self.timeContentLabel];
    [self.bigBackgroundView addSubview:self.orderNoTitleLabel];
    [self.bigBackgroundView addSubview:self.orderNoContentLabel];
    [self.bigBackgroundView addSubview:self.priceTitleLabel];
    [self.bigBackgroundView addSubview:self.priceContentLabel];
    [self.bigBackgroundView addSubview:self.paymentMethodTitleLabel];
    [self.bigBackgroundView addSubview:self.paymentMethodContentLabel];
    
    
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    
    
    self.courseNameLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 12)
    .rightSpaceToView(self.bigBackgroundView, 12)
    .heightIs(21);
    
    self.timeTitleLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 16)
    .leftSpaceToView(self.bigBackgroundView, 12)
    .widthIs(80)
    .heightIs(21);
    
    self.timeContentLabel.sd_layout
    .centerYEqualToView(self.timeTitleLabel)
    .rightSpaceToView(self.bigBackgroundView, 12)
    .leftSpaceToView(self.timeTitleLabel, 12)
    .heightIs(21);
    
    self.orderNoTitleLabel.sd_layout
    .topSpaceToView(self.timeTitleLabel, 16)
    .leftEqualToView(self.timeTitleLabel)
    .widthRatioToView(self.timeTitleLabel, 1)
    .heightRatioToView(self.timeTitleLabel, 1);
    
    self.orderNoContentLabel.sd_layout
    .centerYEqualToView(self.orderNoTitleLabel)
    .rightEqualToView(self.timeContentLabel)
    .widthRatioToView(self.timeContentLabel, 1)
    .heightRatioToView(self.timeContentLabel, 1);
    
    self.priceTitleLabel.sd_layout
    .topSpaceToView(self.orderNoTitleLabel, 16)
    .leftEqualToView(self.timeTitleLabel)
    .widthRatioToView(self.timeTitleLabel, 1)
    .heightRatioToView(self.timeTitleLabel, 1);
    
    self.priceContentLabel.sd_layout
    .centerYEqualToView(self.priceTitleLabel)
    .rightEqualToView(self.timeContentLabel)
    .widthRatioToView(self.timeContentLabel, 1)
    .heightRatioToView(self.timeContentLabel, 1);
    
    self.paymentMethodTitleLabel.sd_layout
    .topSpaceToView(self.priceTitleLabel, 16)
    .leftEqualToView(self.timeTitleLabel)
    .widthRatioToView(self.timeTitleLabel, 1)
    .heightRatioToView(self.timeTitleLabel, 1);
    
    self.paymentMethodContentLabel.sd_layout
    .centerYEqualToView(self.paymentMethodTitleLabel)
    .rightEqualToView(self.timeContentLabel)
    .widthRatioToView(self.timeContentLabel, 1)
    .heightRatioToView(self.timeContentLabel, 1);
    
    
    
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

- (UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.font = HXBoldFont(15);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
    }
    return _courseNameLabel;
}



- (UILabel *)timeTitleLabel{
    if (!_timeTitleLabel) {
        _timeTitleLabel = [[UILabel alloc] init];
        _timeTitleLabel.font = HXFont(15);
        _timeTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _timeTitleLabel.text = @"支付时间";
    }
    return _timeTitleLabel;
}

- (UILabel *)timeContentLabel{
    if (!_timeContentLabel) {
        _timeContentLabel = [[UILabel alloc] init];
        _timeContentLabel.textAlignment = NSTextAlignmentRight;
        _timeContentLabel.font = HXFont(15);
        _timeContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _timeContentLabel;
}

- (UILabel *)orderNoTitleLabel{
    if (!_orderNoTitleLabel) {
        _orderNoTitleLabel = [[UILabel alloc] init];
        _orderNoTitleLabel.font = HXFont(15);
        _orderNoTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _orderNoTitleLabel.text = @"订单编号";
    }
    return _orderNoTitleLabel;
}

- (UILabel *)orderNoContentLabel{
    if (!_orderNoContentLabel) {
        _orderNoContentLabel = [[UILabel alloc] init];
        _orderNoContentLabel.textAlignment = NSTextAlignmentRight;
        _orderNoContentLabel.font = HXFont(15);
        _orderNoContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _orderNoContentLabel;
}

- (UILabel *)priceTitleLabel{
    if (!_priceTitleLabel) {
        _priceTitleLabel = [[UILabel alloc] init];
        _priceTitleLabel.font = HXFont(15);
        _priceTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _priceTitleLabel.text = @"下单金额";
    }
    return _priceTitleLabel;
}

- (UILabel *)priceContentLabel{
    if (!_priceContentLabel) {
        _priceContentLabel = [[UILabel alloc] init];
        _priceContentLabel.textAlignment = NSTextAlignmentRight;
        _priceContentLabel.font = HXFont(15);
        _priceContentLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _priceContentLabel.isAttributedContent = YES;
        
    }
    return _priceContentLabel;
}


- (UILabel *)paymentMethodTitleLabel{
    if (!_paymentMethodTitleLabel) {
        _paymentMethodTitleLabel = [[UILabel alloc] init];
        _paymentMethodTitleLabel.font = HXFont(15);
        _paymentMethodTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _paymentMethodTitleLabel.text = @"支付方式";
    }
    return _paymentMethodTitleLabel;
}

- (UILabel *)paymentMethodContentLabel{
    if (!_paymentMethodContentLabel) {
        _paymentMethodContentLabel = [[UILabel alloc] init];
        _paymentMethodContentLabel.textAlignment = NSTextAlignmentRight;
        _paymentMethodContentLabel.font = HXFont(15);
        _paymentMethodContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _paymentMethodContentLabel;
}

@end



