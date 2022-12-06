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
-(void)setIsFirst:(BOOL)isFirst{
    _isFirst = isFirst;
    self.bigBackgroundView.layer.mask = nil;
    if (isFirst) {
        //圆角
       UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8 ,8)];
       CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
       maskLayer.frame =self.bigBackgroundView.bounds;
       maskLayer.path = maskPath.CGPath;
       self.bigBackgroundView.layer.mask = maskLayer;
    }
    
}

-(void)setIsLast:(BOOL)isLast{
    _isLast = isLast;
    self.bottomLine.hidden = NO;
    if (isLast) {
        self.bottomLine.hidden = YES;
        //圆角
       UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackgroundView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8 ,8)];
       CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
       maskLayer.frame =self.bigBackgroundView.bounds;
       maskLayer.path = maskPath.CGPath;
       self.bigBackgroundView.layer.mask = maskLayer;
    }
}

-(void)setIsBoth:(BOOL)isBoth{
    _isBoth = isBoth;
    if (isBoth) {
        self.bottomLine.hidden = NO;
        //圆角
       UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bigBackgroundView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8 ,8)];
       CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
       maskLayer.frame =self.bigBackgroundView.bounds;
       maskLayer.path = maskPath.CGPath;
       self.bigBackgroundView.layer.mask = maskLayer;
    }
}

-(void)setScoreModel:(HXScoreModel *)scoreModel{
    
    _scoreModel = scoreModel;
    
    if(scoreModel.isNetCourse){
        self.courseIcon.sd_layout.widthIs(16);
        self.courseNameLabel.sd_layout.leftSpaceToView(self.courseIcon, 2);
    }else{
        self.courseIcon.sd_layout.widthIs(0);
        self.courseNameLabel.sd_layout.leftSpaceToView(self.courseIcon, 0);
    }
    [self.courseNameLabel updateLayout];
    
    self.courseNameLabel.text = scoreModel.termCourseName;
    self.xueQiLabel.text = scoreModel.term;
    
    //分数字体颜色未及格（60分以下）用红色标红，及格（60分及60分以上）用主题色
    if([scoreModel.finalScore integerValue]>=60){
        self.deFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:(scoreModel.finalScore?:@"0") needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:[(scoreModel.finalScore?:@"0") stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    }else{
        self.deFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:(scoreModel.finalScore?:@"0") needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:[(scoreModel.finalScore?:@"0") stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
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
    .topSpaceToView(self.bigBackgroundView, 16)
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
        
    }
    return _courseNameLabel;
}

- (UILabel *)xueQiLabel{
    if (!_xueQiLabel) {
        _xueQiLabel = [[UILabel alloc] init];
        _xueQiLabel.font = HXFont(12);
        _xueQiLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        
    }
    return _xueQiLabel;
}

- (UILabel *)deFenLabel{
    if (!_deFenLabel) {
        _deFenLabel = [[UILabel alloc] init];
        _deFenLabel.textAlignment = NSTextAlignmentRight;
        _deFenLabel.font = HXFont(10);
        _deFenLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
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
