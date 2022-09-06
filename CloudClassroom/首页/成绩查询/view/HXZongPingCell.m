//
//  HXZongPingCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import "HXZongPingCell.h"

@interface HXZongPingCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *courseIcon;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *xueQiLabel;
@property(nonatomic,strong) UILabel *deFenLabel;
@property(nonatomic,strong) UIImageView *arrowIcon;
@property(nonatomic,strong) UIView *bottomLine;

@end

@implementation HXZongPingCell

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
-(void)setIndex:(NSInteger)index{
    _index = index;
    self.bottomLine.hidden = NO;
    self.bigBackgroundView.layer.mask = nil;
    if (index==0) {
        //圆角
       UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8 ,8)];
       CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
       maskLayer.frame =self.bigBackgroundView.bounds;
       maskLayer.path = maskPath.CGPath;
       self.bigBackgroundView.layer.mask = maskLayer;
    }
    if (index==4) {
        self.bottomLine.hidden = YES;
        //圆角
       UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackgroundView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10 ,10)];
       CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
       maskLayer.frame =self.bigBackgroundView.bounds;
       maskLayer.path = maskPath.CGPath;
       self.bigBackgroundView.layer.mask = maskLayer;
    }
}

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseIcon];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.xueQiLabel];
    [self.bigBackgroundView addSubview:self.deFenLabel];
    [self.bigBackgroundView addSubview:self.arrowIcon];
    [self.bigBackgroundView addSubview:self.bottomLine];
    
    self.bigBackgroundView.sd_layout
    .topEqualToView(self.contentView)
    .leftSpaceToView(self.contentView, 12)
    .widthIs(kScreenWidth-24)
    .heightIs(70);
    
    
    self.courseIcon.sd_layout
    .topSpaceToView(self.bigBackgroundView, 17)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .widthIs(16)
    .heightEqualToWidth();
    
    self.arrowIcon.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .widthIs(6)
    .heightIs(11);
    
    self.deFenLabel.sd_layout
    .centerYEqualToView(self.bigBackgroundView)
    .rightSpaceToView(self.arrowIcon, 5)
    .heightIs(20);
    [self.deFenLabel setSingleLineAutoResizeWithMaxWidth:80];
    
    
    self.courseNameLabel.sd_layout
    .centerYEqualToView(self.courseIcon)
    .leftSpaceToView(self.courseIcon, 2)
    .rightSpaceToView(self.deFenLabel, 16)
    .heightIs(18);
    
    self.xueQiLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 2)
    .leftEqualToView(self.courseIcon)
    .rightEqualToView(self.courseNameLabel)
    .heightIs(17);
    
    self.bottomLine.sd_layout
    .bottomEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .heightIs(1);
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

- (UIImageView *)courseIcon{
    if (!_courseIcon) {
        _courseIcon = [[UIImageView alloc] init];
        _courseIcon.image = [UIImage imageNamed:@"wang_icon"];
    }
    return _courseIcon;
}

- (UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.font = HXFont(13);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _courseNameLabel.text = @"毛泽东思想和中国特色社会主义理论体系概论";
    }
    return _courseNameLabel;
}

- (UILabel *)xueQiLabel{
    if (!_xueQiLabel) {
        _xueQiLabel = [[UILabel alloc] init];
        _xueQiLabel.font = HXFont(12);
        _xueQiLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _xueQiLabel.text = @"第一学期";
    }
    return _xueQiLabel;
}

- (UILabel *)deFenLabel{
    if (!_deFenLabel) {
        _deFenLabel = [[UILabel alloc] init];
        _deFenLabel.textAlignment = NSTextAlignmentRight;
        _deFenLabel.font = HXFont(10);
        _deFenLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _deFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"68" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:@"68分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    }
    return _deFenLabel;
}

- (UIImageView *)arrowIcon{
    if (!_arrowIcon) {
        _arrowIcon = [[UIImageView alloc] init];
        _arrowIcon.image = [UIImage imageNamed:@"blackright_arrow"];
    }
    return _arrowIcon;
}

-(UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR_WITH_ALPHA(0xEBEBEB, 1);
    }
    return _bottomLine;
}

@end
