//
//  HXMyLiveCell.m
//  CloudClassroom
//
//  Created by mac on 2022/10/18.
//

#import "HXMyLiveCell.h"

@interface  HXMyLiveCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *courseIcon;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *numLabel;

@property(nonatomic,strong) UIButton *stateBtn;
@property(nonatomic,strong) UIImageView *arrowIcon;
///直播时间
@property(nonatomic,strong) UILabel *liveTimeTitleLabel;
@property(nonatomic,strong) UILabel *liveTimeContentLabel;
///直播老师
@property(nonatomic,strong) UILabel *liveTeacherTitleLabel;
@property(nonatomic,strong) UILabel *liveTeacherContentLabel;

@property(nonatomic,strong) UILabel *watchStateLabel;

@property(nonatomic,strong) UIButton *watchBtn;
@property(nonatomic,strong) UILabel *tipLabel;


@end

@implementation HXMyLiveCell

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

-(void)watch:(UIButton *)sender{
    
    
}

#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseIcon];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.numLabel];
    [self.bigBackgroundView addSubview:self.stateBtn];
    [self.bigBackgroundView addSubview:self.arrowIcon];
    [self.bigBackgroundView addSubview:self.liveTimeTitleLabel];
    [self.bigBackgroundView addSubview:self.liveTimeContentLabel];
    [self.bigBackgroundView addSubview:self.liveTeacherTitleLabel];
    [self.bigBackgroundView addSubview:self.liveTeacherContentLabel];
    [self.bigBackgroundView addSubview:self.watchStateLabel];
    [self.bigBackgroundView addSubview:self.watchBtn];
    [self.bigBackgroundView addSubview:self.tipLabel];
    
  
    
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
    .heightIs(20);
    [self.courseNameLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    self.numLabel.sd_layout
    .centerYEqualToView(self.courseIcon)
    .leftSpaceToView(self.courseNameLabel, 0)
    .heightIs(17);
    [self.numLabel setSingleLineAutoResizeWithMaxWidth:80];
    
    self.arrowIcon.sd_layout
    .centerYEqualToView(self.courseIcon)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .widthIs(16)
    .heightEqualToWidth();
    
    self.stateBtn.sd_layout
    .centerYEqualToView(self.courseIcon)
    .rightSpaceToView(self.arrowIcon, 8)
    .widthIs(60)
    .heightIs(20);
    self.stateBtn.sd_cornerRadius=@2;
    
    self.liveTimeTitleLabel.sd_layout
    .topSpaceToView(self.courseIcon, 16)
    .leftEqualToView(self.courseIcon)
    .widthIs(70)
    .heightIs(21);
    
    self.liveTimeContentLabel.sd_layout
    .centerYEqualToView(self.liveTimeTitleLabel)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.liveTimeTitleLabel, 10)
    .heightIs(21);
    
    self.liveTeacherTitleLabel.sd_layout
    .topSpaceToView(self.liveTimeTitleLabel, 12)
    .leftEqualToView(self.liveTimeTitleLabel)
    .widthRatioToView(self.liveTimeTitleLabel, 1)
    .heightRatioToView(self.liveTimeTitleLabel, 1);
    
    self.liveTeacherContentLabel.sd_layout
    .centerYEqualToView(self.liveTeacherTitleLabel)
    .rightEqualToView(self.liveTimeContentLabel)
    .widthRatioToView(self.liveTimeContentLabel, 1)
    .heightRatioToView(self.liveTimeContentLabel, 1);
    
    self.watchBtn.sd_layout
    .topSpaceToView(self.liveTeacherContentLabel, 20)
    .rightEqualToView(self.liveTeacherContentLabel)
    .widthIs(87)
    .heightIs(36);
    self.watchBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.watchStateLabel.sd_layout
    .centerYEqualToView(self.watchBtn)
    .leftEqualToView(self.courseIcon)
    .widthIs(60)
    .heightIs(20);
    
    self.tipLabel.sd_layout
    .centerYEqualToView(self.watchBtn)
    .rightEqualToView(self.watchBtn)
    .leftSpaceToView(self.watchStateLabel, 16)
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
        _courseIcon.image = [UIImage imageNamed:@"shuben_icon"];
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

- (UILabel *)numLabel{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.font = HXFont(12);
        _numLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _numLabel.text = @"（第3次）";
    }
    return _numLabel;
}


- (UIButton *)stateBtn{
    if (!_stateBtn) {
        _stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stateBtn.backgroundColor = COLOR_WITH_ALPHA(0xEFFFEC, 1);
        _stateBtn.titleLabel.font = HXFont(12);
        [_stateBtn setTitle:@"正在直播" forState:UIControlStateNormal];
        [_stateBtn setTitleColor:COLOR_WITH_ALPHA(0x5DC367, 1) forState:UIControlStateNormal];
    }
    return _stateBtn;
}


-(UIImageView *)arrowIcon{
    if(!_arrowIcon){
        _arrowIcon = [[UIImageView alloc] init];
        _arrowIcon.image = [UIImage imageNamed:@"set_arrow"];
    }
    return _arrowIcon;
}


- (UILabel *)liveTimeTitleLabel{
    if (!_liveTimeTitleLabel) {
        _liveTimeTitleLabel = [[UILabel alloc] init];
        _liveTimeTitleLabel.textAlignment = NSTextAlignmentLeft;
        _liveTimeTitleLabel.font = HXFont(15);
        _liveTimeTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _liveTimeTitleLabel.text = @"直播时间";
    }
    return _liveTimeTitleLabel;
}

- (UILabel *)liveTimeContentLabel{
    if (!_liveTimeContentLabel) {
        _liveTimeContentLabel = [[UILabel alloc] init];
        _liveTimeContentLabel.textAlignment = NSTextAlignmentRight;
        _liveTimeContentLabel.font = HXFont(15);
        _liveTimeContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _liveTimeContentLabel.text = @"2022.07.07 19:00-20:00";
    }
    return _liveTimeContentLabel;
}

- (UILabel *)liveTeacherTitleLabel{
    if (!_liveTeacherTitleLabel) {
        _liveTeacherTitleLabel = [[UILabel alloc] init];
        _liveTeacherTitleLabel.textAlignment = NSTextAlignmentLeft;
        _liveTeacherTitleLabel.font = HXFont(15);
        _liveTeacherTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _liveTeacherTitleLabel.text = @"直播老师";
    }
    return _liveTeacherTitleLabel;
}

- (UILabel *)liveTeacherContentLabel{
    if (!_liveTeacherContentLabel) {
        _liveTeacherContentLabel = [[UILabel alloc] init];
        _liveTeacherContentLabel.textAlignment = NSTextAlignmentRight;
        _liveTeacherContentLabel.font = HXFont(15);
        _liveTeacherContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _liveTeacherContentLabel.text = @"张小小";
    }
    return _liveTeacherContentLabel;
}

- (UILabel *)watchStateLabel{
    if (!_watchStateLabel) {
        _watchStateLabel = [[UILabel alloc] init];
        _watchStateLabel.textAlignment = NSTextAlignmentLeft;
        _watchStateLabel.font = HXFont(14);
        _watchStateLabel.textColor = COLOR_WITH_ALPHA(0xFFA41B, 1);
        _watchStateLabel.text = @"未观看";
    }
    return _watchStateLabel;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentRight;
        _tipLabel.font = HXFont(14);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _tipLabel.hidden  = YES;
        _tipLabel.text = @"未在回放时间内";
    }
    return _tipLabel;
}


- (UIButton *)watchBtn{
    if (!_watchBtn) {
        _watchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _watchBtn.backgroundColor = COLOR_WITH_ALPHA(0xECF4FF, 1);
        _watchBtn.titleLabel.font = HXBoldFont(14);
        [_watchBtn setTitle:@"观看回放" forState:UIControlStateNormal];
        [_watchBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_watchBtn addTarget:self action:@selector(watch:) forControlEvents:UIControlEventTouchUpInside];
        _watchBtn.userInteractionEnabled = NO;
    }
    return _watchBtn;
}


@end

