//
//  HXFinancePaymentCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import "HXFinancePaymentCell.h"

@interface HXFinancePaymentCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIButton *xueQiBtn;
@property(nonatomic,strong) UILabel *feeNameLabel;
@property(nonatomic,strong) UILabel *priceLabel;
//专业
@property(nonatomic,strong) UILabel *majorLabel;
@property(nonatomic,strong) UILabel *majorContentLabel;


@end

@implementation HXFinancePaymentCell

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

-(void)setStudentFeeModel:(HXStudentFeeModel *)studentFeeModel{
    
    _studentFeeModel = studentFeeModel;
    
   
    
    [self.xueQiBtn setTitle:studentFeeModel.batchName forState:UIControlStateNormal];
    self.feeNameLabel.text = studentFeeModel.paybackName;
    self.majorContentLabel.text = studentFeeModel.majorlongname;
    
    
    
    NSString *content = [NSString stringWithFormat:@"￥%.2f",studentFeeModel.balance];
    NSArray *tempArray = [HXFloatToString(studentFeeModel.balance) componentsSeparatedByString:@"."];
    NSString *needStr = [tempArray.firstObject stringByAppendingString:@"."];
    self.priceLabel.attributedText = [HXCommonUtil getAttributedStringWith:needStr needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:content defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
}

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    
    [self.bigBackgroundView addSubview:self.xueQiBtn];
    [self.bigBackgroundView addSubview:self.feeNameLabel];
    [self.bigBackgroundView addSubview:self.priceLabel];
    [self.bigBackgroundView addSubview:self.majorLabel];
    [self.bigBackgroundView addSubview:self.majorContentLabel];
    
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
   
    
    self.xueQiBtn.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 16);
    [self.xueQiBtn setupAutoSizeWithHorizontalPadding:6 buttonHeight:21];
    self.xueQiBtn.sd_cornerRadius = @2;
    
    self.priceLabel.sd_layout
    .centerYEqualToView(self.xueQiBtn)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .widthIs(80)
    .heightIs(20);
    
    self.feeNameLabel.sd_layout
    .centerYEqualToView(self.xueQiBtn)
    .leftSpaceToView(self.xueQiBtn, 8)
    .rightSpaceToView(self.priceLabel, 16)
    .heightIs(21);
    
    self.majorLabel.sd_layout
    .topSpaceToView(self.xueQiBtn, 12)
    .leftEqualToView(self.xueQiBtn)
    .widthIs(40)
    .heightIs(17);
    
    self.majorContentLabel.sd_layout
    .centerYEqualToView(self.majorLabel)
    .leftSpaceToView(self.majorLabel, 16)
    .rightEqualToView(self.priceLabel)
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



- (UIButton *)xueQiBtn{
    if (!_xueQiBtn) {
        _xueQiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _xueQiBtn.titleLabel.font = HXBoldFont(15);
        _xueQiBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 0.1);
        [_xueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        
    }
    return _xueQiBtn;
}

- (UILabel *)feeNameLabel{
    if (!_feeNameLabel) {
        _feeNameLabel = [[UILabel alloc] init];
        _feeNameLabel.font = HXBoldFont(15);
        _feeNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _feeNameLabel;
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

- (UILabel *)majorLabel{
    if (!_majorLabel) {
        _majorLabel = [[UILabel alloc] init];
        _majorLabel.textAlignment = NSTextAlignmentLeft;
        _majorLabel.font = HXFont(12);
        _majorLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _majorLabel.text = @"专业";
    }
    return _majorLabel;
}

- (UILabel *)majorContentLabel{
    if (!_majorContentLabel) {
        _majorContentLabel = [[UILabel alloc] init];
        _majorContentLabel.textAlignment = NSTextAlignmentRight;
        _majorContentLabel.font = HXFont(12);
        _majorContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _majorContentLabel;
}


@end



