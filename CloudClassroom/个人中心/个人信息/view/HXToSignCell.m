//
//  HXToSignCell.m
//  CloudClassroom
//
//  Created by mac on 2022/12/12.
//

#import "HXToSignCell.h"

@interface HXToSignCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *signStateLabel;
@property(nonatomic,strong) UIImageView *signImageView;

@property(nonatomic,strong) UIView *lineView;

@end

@implementation HXToSignCell

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
-(void)setPersonalInforModel:(HXPersonalInforModel *)personalInforModel{
    
    _personalInforModel = personalInforModel;
    
    self.titleLabel.text = personalInforModel.title;
    self.signStateLabel.text = personalInforModel.content;
    if ([HXCommonUtil isNull:personalInforModel.signImgUrl]) {
        self.signStateLabel.textColor = COLOR_WITH_ALPHA(0xF8A528, 1);
        self.signImageView.hidden = YES;
        self.signBtn.hidden = NO;
    }else{
        self.signStateLabel.textColor = COLOR_WITH_ALPHA(0x5DC367, 1);
        self.signImageView.hidden = NO;
        self.signBtn.hidden = YES;
        [self.signImageView sd_setImageWithURL:HXSafeURL(personalInforModel.signImgUrl) placeholderImage:nil options:SDWebImageRefreshCached];
    }
}


#pragma mark - Event
-(void)clickSignBtn{
    
    
}

#pragma mark - UI
-(void)createUI{
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.signStateLabel];
    [self.bigBackgroundView addSubview:self.signImageView];
    [self.bigBackgroundView addSubview:self.signBtn];
    [self.bigBackgroundView addSubview:self.lineView];
    
    self.bigBackgroundView.sd_layout
    .topEqualToView(self.contentView)
    .leftEqualToView(self.contentView)
    .rightEqualToView(self.contentView)
    .bottomEqualToView(self.contentView);
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 18)
    .leftSpaceToView(self.bigBackgroundView, 20)
    .widthIs(70)
    .heightIs(21);
    
    self.signStateLabel.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftSpaceToView(self.titleLabel, 8)
    .heightIs(21);
    [self.signStateLabel setSingleLineAutoResizeWithMaxWidth:80];
    
    self.signBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .widthIs(80)
    .heightIs(36);
    self.signBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.signImageView.sd_layout
    .centerYEqualToView(self.titleLabel)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .widthIs(100)
    .heightIs(50);
    
    
    self.lineView.sd_layout
    .topSpaceToView(self.titleLabel, 18)
    .leftSpaceToView(self.bigBackgroundView, 20)
    .rightSpaceToView(self.bigBackgroundView, 20)
    .bottomEqualToView(self.bigBackgroundView)
    .heightIs(0.5);
    
    
}


#pragma mark - LazyLoad
-(UIView *)bigBackgroundView{
    if (!_bigBackgroundView) {
        _bigBackgroundView = [[UIView alloc] init];
        _bigBackgroundView.clipsToBounds = YES;
        _bigBackgroundView.backgroundColor =UIColor.whiteColor;
    }
    return _bigBackgroundView;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.clipsToBounds = YES;
        _lineView.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _lineView;
}



-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = HXFont(15);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _titleLabel;
}

-(UILabel *)signStateLabel{
    if (!_signStateLabel) {
        _signStateLabel = [[UILabel alloc] init];
        _signStateLabel.textAlignment = NSTextAlignmentLeft;
        _signStateLabel.font = HXBoldFont(15);
        _signStateLabel.textColor = COLOR_WITH_ALPHA(0xF8A528, 1);
        _signStateLabel.text = @"未签名";
    }
    return _signStateLabel;
}


-(UIButton *)signBtn{
    if (!_signBtn) {
        _signBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _signBtn.titleLabel.font = HXBoldFont(14);
        _signBtn.backgroundColor= UIColor.whiteColor;
        _signBtn.layer.borderWidth =1;
        _signBtn.layer.borderColor =COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        [_signBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_signBtn setTitle:@"去签名" forState:UIControlStateNormal];
       
    }
    return _signBtn;
}

-(UIImageView *)signImageView{
    if (!_signImageView) {
        _signImageView = [[UIImageView alloc] init];
        _signImageView.contentMode = UIViewContentModeScaleAspectFill;
        _signImageView.clipsToBounds = YES;
        _signImageView.userInteractionEnabled = YES;
        _signImageView.hidden = YES;
    }
    return _signImageView;
}

@end

