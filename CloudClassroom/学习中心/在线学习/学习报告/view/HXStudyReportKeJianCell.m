//
//  HXStudyReportKeJianCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXStudyReportKeJianCell.h"

@interface HXStudyReportKeJianCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *titleIcon;
@property(nonatomic,strong) UILabel *titleNameLabel;

//最终得分
@property(nonatomic,strong) UILabel *deFenTitleLabel;
@property(nonatomic,strong) UILabel *deFenContentLabel;
//满分
@property(nonatomic,strong) UILabel *maFenTitleLabel;
@property(nonatomic,strong) UILabel *maFenContentLabel;
//满分
@property(nonatomic,strong) UILabel *ciShuTitleLabel;
@property(nonatomic,strong) UILabel *ciShuContentLabel;


@end

@implementation HXStudyReportKeJianCell

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
    [self.bigBackgroundView addSubview:self.titleIcon];
    [self.bigBackgroundView addSubview:self.titleNameLabel];
    [self.bigBackgroundView addSubview:self.deFenTitleLabel];
    [self.bigBackgroundView addSubview:self.deFenContentLabel];
    [self.bigBackgroundView addSubview:self.maFenTitleLabel];
    [self.bigBackgroundView addSubview:self.maFenContentLabel];
    [self.bigBackgroundView addSubview:self.ciShuTitleLabel];
    [self.bigBackgroundView addSubview:self.ciShuContentLabel];
    
    
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(8, 12, 8, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    self.titleIcon.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 12)
    .widthIs(18)
    .heightEqualToWidth();
    
    self.titleNameLabel.sd_layout
    .centerYEqualToView(self.titleIcon)
    .leftSpaceToView(self.titleIcon, 6)
    .rightSpaceToView(self.bigBackgroundView, 12)
    .heightIs(21);
    
    self.deFenTitleLabel.sd_layout
    .topSpaceToView(self.titleIcon, 17)
    .leftEqualToView(self.titleIcon)
    .widthIs(110)
    .heightIs(20);
   
    self.deFenContentLabel.sd_layout
    .centerYEqualToView(self.deFenTitleLabel)
    .rightSpaceToView(self.bigBackgroundView, 12)
    .leftSpaceToView(self.deFenTitleLabel, 20)
    .heightRatioToView(self.deFenTitleLabel, 1);
    
    self.maFenTitleLabel.sd_layout
    .topSpaceToView(self.deFenTitleLabel, 17)
    .leftEqualToView(self.deFenTitleLabel)
    .widthRatioToView(self.deFenTitleLabel, 1)
    .heightRatioToView(self.deFenTitleLabel, 1);
   
    self.maFenContentLabel.sd_layout
    .centerYEqualToView(self.maFenTitleLabel)
    .leftEqualToView(self.deFenContentLabel)
    .rightEqualToView(self.deFenContentLabel)
    .heightRatioToView(self.deFenTitleLabel, 1);
    
    self.ciShuTitleLabel.sd_layout
    .topSpaceToView(self.maFenTitleLabel, 17)
    .leftEqualToView(self.deFenTitleLabel)
    .widthRatioToView(self.deFenTitleLabel, 1)
    .heightRatioToView(self.deFenTitleLabel, 1);
   
    self.ciShuContentLabel.sd_layout
    .centerYEqualToView(self.ciShuTitleLabel)
    .leftEqualToView(self.deFenContentLabel)
    .rightEqualToView(self.deFenContentLabel)
    .heightRatioToView(self.deFenTitleLabel, 1);
    

    
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

- (UIImageView *)titleIcon{
    if (!_titleIcon) {
        _titleIcon = [[UIImageView alloc] init];
        _titleIcon.image = [UIImage imageNamed:@"wangluo_icon"];
    }
    return _titleIcon;
}

- (UILabel *)titleNameLabel{
    if (!_titleNameLabel) {
        _titleNameLabel = [[UILabel alloc] init];
        _titleNameLabel.font = HXBoldFont(15);
        _titleNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _titleNameLabel.text = @"课件学习(网络)";
    }
    return _titleNameLabel;
}




- (UILabel *)deFenTitleLabel{
    if (!_deFenTitleLabel) {
        _deFenTitleLabel = [[UILabel alloc] init];
        _deFenTitleLabel.font = HXFont(14);
        _deFenTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _deFenTitleLabel.text = @"权重后得分";
    }
    return _deFenTitleLabel;
}

- (UILabel *)deFenContentLabel{
    if (!_deFenContentLabel) {
        _deFenContentLabel = [[UILabel alloc] init];
        _deFenContentLabel.textAlignment = NSTextAlignmentRight;
        _deFenContentLabel.font = HXFont(15);
        _deFenContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _deFenContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"12" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content: @"12分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    }
    return _deFenContentLabel;
}



- (UILabel *)maFenTitleLabel{
    if (!_maFenTitleLabel) {
        _maFenTitleLabel = [[UILabel alloc] init];
        _maFenTitleLabel.font = HXFont(14);
        _maFenTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _maFenTitleLabel.text = @"学习分/满分";
    }
    return _maFenTitleLabel;
}

- (UILabel *)maFenContentLabel{
    if (!_maFenContentLabel) {
        _maFenContentLabel = [[UILabel alloc] init];
        _maFenContentLabel.textAlignment = NSTextAlignmentRight;
        _maFenContentLabel.font = HXFont(15);
        _maFenContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _maFenContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"65" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content: @"65/100分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    }
    return _maFenContentLabel;
}

- (UILabel *)ciShuTitleLabel{
    if (!_ciShuTitleLabel) {
        _ciShuTitleLabel = [[UILabel alloc] init];
        _ciShuTitleLabel.font = HXFont(14);
        _ciShuTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _ciShuTitleLabel.text = @"考试次数";
    }
    return _ciShuTitleLabel;
}

- (UILabel *)ciShuContentLabel{
    if (!_ciShuContentLabel) {
        _ciShuContentLabel = [[UILabel alloc] init];
        _ciShuContentLabel.textAlignment = NSTextAlignmentRight;
        _ciShuContentLabel.font = HXFont(15);
        _ciShuContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _ciShuContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"5" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content: @"5次" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    }
    return _ciShuContentLabel;
}


@end



