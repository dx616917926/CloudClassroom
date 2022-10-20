//
//  HXLiveCourseCell.m
//  CloudClassroom
//
//  Created by mac on 2022/10/17.
//

#import "HXLiveCourseCell.h"

@interface HXLiveCourseCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *courseIcon;
@property(nonatomic,strong) UILabel *courseNameLabel;
///共直播次数
@property(nonatomic,strong) UILabel *totalTitleLabel;
@property(nonatomic,strong) UILabel *totalContentLabel;
@property(nonatomic,strong) UIView *line1;
///已直播次数
@property(nonatomic,strong) UILabel *yiTitleLabel;
@property(nonatomic,strong) UILabel *yiContentLabel;
@property(nonatomic,strong) UIView *line2;
///已观看次数
@property(nonatomic,strong) UILabel *watchTitleLabel;
@property(nonatomic,strong) UILabel *watchContentLabel;

@property(nonatomic,strong) UIButton *checkBtn;

@property(nonatomic,strong) UILabel *nextTimeTitleLabel;
@property(nonatomic,strong) UILabel *nextTimeContentLabel;

@end

@implementation HXLiveCourseCell

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

-(void)check:(UIButton *)sender{
    
    
}

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseIcon];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.totalTitleLabel];
    [self.bigBackgroundView addSubview:self.totalContentLabel];
    [self.bigBackgroundView addSubview:self.line1];
    [self.bigBackgroundView addSubview:self.yiTitleLabel];
    [self.bigBackgroundView addSubview:self.yiContentLabel];
    [self.bigBackgroundView addSubview:self.line2];
    [self.bigBackgroundView addSubview:self.watchTitleLabel];
    [self.bigBackgroundView addSubview:self.watchContentLabel];
    [self.bigBackgroundView addSubview:self.checkBtn];
    [self.bigBackgroundView addSubview:self.nextTimeTitleLabel];
    [self.bigBackgroundView addSubview:self.nextTimeContentLabel];
  
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @2;
    
    self.courseIcon.sd_layout
    .topSpaceToView(self.bigBackgroundView, 12)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .widthIs(20)
    .heightEqualToWidth();
    
    self.courseNameLabel.sd_layout
    .centerYEqualToView(self.courseIcon)
    .leftSpaceToView(self.courseIcon, 4)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .heightIs(20);
    
    
    self.yiTitleLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 33)
    .centerXEqualToView(self.bigBackgroundView)
    .widthIs(_kpw(90))
    .heightIs(17);
    
    self.yiContentLabel.sd_layout
    .topSpaceToView(self.yiTitleLabel, 8)
    .centerXEqualToView(self.yiTitleLabel)
    .widthRatioToView(self.yiTitleLabel, 1)
    .heightIs(21);
    
    self.line1.sd_layout
    .topEqualToView(self.yiTitleLabel).offset(6)
    .rightSpaceToView(self.yiTitleLabel, 0)
    .widthIs(1)
    .heightIs(28);
    
    self.line2.sd_layout
    .topEqualToView(self.line1)
    .leftSpaceToView(self.yiTitleLabel, 0)
    .widthRatioToView(self.line1, 1)
    .heightRatioToView(self.line1, 1);
    
    
    self.totalTitleLabel.sd_layout
    .topEqualToView(self.yiTitleLabel)
    .rightSpaceToView(self.line1, 0)
    .widthRatioToView(self.yiTitleLabel, 1)
    .heightRatioToView(self.yiTitleLabel, 1);
    
    self.totalContentLabel.sd_layout
    .topEqualToView(self.yiContentLabel)
    .rightEqualToView(self.totalTitleLabel)
    .widthRatioToView(self.yiContentLabel, 1)
    .heightRatioToView(self.yiContentLabel, 1);
    
    self.watchTitleLabel.sd_layout
    .topEqualToView(self.yiTitleLabel)
    .leftSpaceToView(self.line2, 0)
    .widthRatioToView(self.yiTitleLabel, 1)
    .heightRatioToView(self.yiTitleLabel, 1);
    
    self.watchContentLabel.sd_layout
    .topEqualToView(self.yiContentLabel)
    .leftEqualToView(self.watchTitleLabel)
    .widthRatioToView(self.yiContentLabel, 1)
    .heightRatioToView(self.yiContentLabel, 1);
    
    
    self.checkBtn.sd_layout
    .topSpaceToView(self.yiContentLabel, 20)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .widthIs(87)
    .heightIs(36);
    self.checkBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.nextTimeTitleLabel.sd_layout
    .bottomEqualToView(self.checkBtn)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .widthIs(60)
    .heightIs(20);
    
    self.nextTimeContentLabel.sd_layout
    .centerYEqualToView(self.nextTimeTitleLabel)
    .leftSpaceToView(self.nextTimeTitleLabel, 3)
    .rightSpaceToView(self.checkBtn, 16)
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

-(UIImageView *)courseIcon{
    if(!_courseIcon){
        _courseIcon = [[UIImageView alloc] init];
        _courseIcon.image = [UIImage imageNamed:@"livecouse_icon"];
    }
    return _courseIcon;
}

- (UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.font = HXBoldFont(14);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _courseNameLabel.text = @"大学英语";
    }
    return _courseNameLabel;
}

- (UIView *)line1{
    if (!_line1) {
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = COLOR_WITH_ALPHA(0xE3E3E3, 1);
    }
    return _line1;
}

- (UIView *)line2{
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = COLOR_WITH_ALPHA(0xE3E3E3, 1);
    }
    return _line2;
}

- (UILabel *)yiTitleLabel{
    if (!_yiTitleLabel) {
        _yiTitleLabel = [[UILabel alloc] init];
        _yiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _yiTitleLabel.font = HXFont(12);
        _yiTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _yiTitleLabel.text = @"已直播次数";
    }
    return _yiTitleLabel;
}

- (UILabel *)yiContentLabel{
    if (!_yiContentLabel) {
        _yiContentLabel = [[UILabel alloc] init];
        _yiContentLabel.textAlignment = NSTextAlignmentCenter;
        _yiContentLabel.font = HXBoldFont(12);
        _yiContentLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _yiContentLabel.text = @"10";
    }
    return _yiContentLabel;
}

- (UILabel *)totalTitleLabel{
    if (!_totalTitleLabel) {
        _totalTitleLabel = [[UILabel alloc] init];
        _totalTitleLabel.textAlignment = NSTextAlignmentCenter;
        _totalTitleLabel.font = HXFont(12);
        _totalTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _totalTitleLabel.text = @"共直播次数";
    }
    return _totalTitleLabel;
}

- (UILabel *)totalContentLabel{
    if (!_totalContentLabel) {
        _totalContentLabel = [[UILabel alloc] init];
        _totalContentLabel.textAlignment = NSTextAlignmentCenter;
        _totalContentLabel.font = HXBoldFont(12);
        _totalContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _totalContentLabel.text = @"20";
    }
    return _totalContentLabel;
}

- (UILabel *)watchTitleLabel{
    if (!_watchTitleLabel) {
        _watchTitleLabel = [[UILabel alloc] init];
        _watchTitleLabel.textAlignment = NSTextAlignmentCenter;
        _watchTitleLabel.font = HXFont(12);
        _watchTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _watchTitleLabel.text = @"已观看次数";
    }
    return _watchTitleLabel;
}

- (UILabel *)watchContentLabel{
    if (!_watchContentLabel) {
        _watchContentLabel = [[UILabel alloc] init];
        _watchContentLabel.textAlignment = NSTextAlignmentCenter;
        _watchContentLabel.font = HXBoldFont(12);
        _watchContentLabel.textColor = COLOR_WITH_ALPHA(0x5DC367, 1);
        _watchContentLabel.text = @"5";
    }
    return _watchContentLabel;
}



- (UIButton *)checkBtn{
    if (!_checkBtn) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _checkBtn.titleLabel.font = HXFont(14);
        [_checkBtn setTitle:@"去查看" forState:UIControlStateNormal];
        [_checkBtn setTitleColor:COLOR_WITH_ALPHA(0xFFFFFF, 1) forState:UIControlStateNormal];
        [_checkBtn addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
        _checkBtn.userInteractionEnabled = NO;
    }
    return _checkBtn;
}

- (UILabel *)nextTimeTitleLabel{
    if (!_nextTimeTitleLabel) {
        _nextTimeTitleLabel = [[UILabel alloc] init];
        _nextTimeTitleLabel.font = HXFont(14);
        _nextTimeTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _nextTimeTitleLabel.text = @"下次直播";
    }
    return _nextTimeTitleLabel;
}


- (UILabel *)nextTimeContentLabel{
    if (!_nextTimeContentLabel) {
        _nextTimeContentLabel = [[UILabel alloc] init];
        _nextTimeContentLabel.font = HXFont(14);
        _nextTimeContentLabel.textColor = COLOR_WITH_ALPHA(0xFFA41B, 1);
        _nextTimeContentLabel.text = @"2022.09.02 10:00";
    }
    return _nextTimeContentLabel;
}


@end
