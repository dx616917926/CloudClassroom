//
//  HXKeJianLearnCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXKeJianLearnCell.h"

@interface HXKeJianLearnCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *courseNameLabel;

@property(nonatomic,strong) UIButton *stateBtn;
//学习进度(分钟)
@property(nonatomic,strong) UILabel *jinDuTitleLabel;
@property(nonatomic,strong) UILabel *jinDuContentLabel;
//授课老师
@property(nonatomic,strong) UILabel *teacherTitleLabel;
@property(nonatomic,strong) UILabel *teacherContentLabel;
//学习时间
@property(nonatomic,strong) UILabel *timeTitleLabel;
@property(nonatomic,strong) UILabel *timeContentLabel;
//提示信息
@property(nonatomic,strong) UILabel *tipLabel;

@property(nonatomic,strong) UIButton *muLuBtn;
@property(nonatomic,strong) UIButton *startLearnBtn;

@end

@implementation HXKeJianLearnCell

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
-(void)setKeJianOrExamInfoModel:(HXKeJianOrExamInfoModel *)keJianOrExamInfoModel{
    
    _keJianOrExamInfoModel = keJianOrExamInfoModel;
    
    [self.stateBtn setTitle:@"进行中" forState:UIControlStateNormal];
    
    self.courseNameLabel.text = keJianOrExamInfoModel.termCourseName;
    
    NSString *attributedStr = [NSString stringWithFormat: @"%ld /",(long)keJianOrExamInfoModel.learnTime];
    NSString *content = [NSString stringWithFormat: @"%ld / %ld",(long)keJianOrExamInfoModel.learnTime,(long)keJianOrExamInfoModel.courseALlTime];
    self.jinDuContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:attributedStr needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1)} content:content  defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x999999, 1)}];
    
    self.teacherContentLabel.text = keJianOrExamInfoModel.author;
    self.timeContentLabel.text = [NSString stringWithFormat: @"%@   --   %@",keJianOrExamInfoModel.finaltime,keJianOrExamInfoModel.finaltimeEnd];
    self.tipLabel.hidden = [HXCommonUtil isNull:keJianOrExamInfoModel.showMessage];
    self.tipLabel.text = keJianOrExamInfoModel.showMessage;
    ///是否能考试或者看课
    if(keJianOrExamInfoModel.isCan==1){
        self.startLearnBtn.enabled =YES;
        self.startLearnBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    }else{
        self.startLearnBtn.enabled =NO;
        self.startLearnBtn.backgroundColor = COLOR_WITH_ALPHA(0xC6C8D0, 1);
    }
    
}

#pragma mark - Event
-(void)startLearn:(UIButton *)sender{
    if(self.delegate &&[self.delegate respondsToSelector:@selector(playCourse:)]){
        [self.delegate playCourse:self.keJianOrExamInfoModel];
    }
}


#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.stateBtn];
    [self.bigBackgroundView addSubview:self.jinDuTitleLabel];
    [self.bigBackgroundView addSubview:self.jinDuContentLabel];
    [self.bigBackgroundView addSubview:self.teacherTitleLabel];
    [self.bigBackgroundView addSubview:self.teacherContentLabel];
    [self.bigBackgroundView addSubview:self.timeTitleLabel];
    [self.bigBackgroundView addSubview:self.timeContentLabel];
    [self.bigBackgroundView addSubview:self.tipLabel];
    [self.bigBackgroundView addSubview:self.startLearnBtn];
    
    
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    self.stateBtn.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.bigBackgroundView, 18);
    [self.stateBtn setupAutoSizeWithHorizontalPadding:5 buttonHeight:20];
    self.stateBtn.sd_cornerRadius = @2;
    
    self.courseNameLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 14)
    .rightSpaceToView(self.stateBtn, 16)
    .heightIs(20);
    
    self.jinDuTitleLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 16)
    .leftEqualToView(self.courseNameLabel)
    .widthIs(110)
    .heightIs(21);
   
    self.jinDuContentLabel.sd_layout
    .centerYEqualToView(self.jinDuTitleLabel)
    .rightEqualToView(self.stateBtn)
    .leftSpaceToView(self.jinDuTitleLabel, 20)
    .heightRatioToView(self.jinDuTitleLabel, 1);
    
    self.teacherTitleLabel.sd_layout
    .topSpaceToView(self.jinDuTitleLabel, 12)
    .leftEqualToView(self.courseNameLabel)
    .widthRatioToView(self.jinDuTitleLabel, 1)
    .heightRatioToView(self.jinDuTitleLabel, 1);
   
    self.teacherContentLabel.sd_layout
    .centerYEqualToView(self.teacherTitleLabel)
    .leftEqualToView(self.jinDuContentLabel)
    .rightEqualToView(self.jinDuContentLabel)
    .heightRatioToView(self.jinDuContentLabel, 1);
    
    self.timeTitleLabel.sd_layout
    .topSpaceToView(self.teacherTitleLabel, 12)
    .leftEqualToView(self.courseNameLabel)
    .widthRatioToView(self.jinDuTitleLabel, 1)
    .heightRatioToView(self.jinDuTitleLabel, 1);
   
    self.timeContentLabel.sd_layout
    .topSpaceToView(self.timeTitleLabel, 10)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.stateBtn)
    .heightRatioToView(self.jinDuTitleLabel, 1);
   
    self.startLearnBtn.sd_layout
    .topSpaceToView(self.timeContentLabel, 20)
    .rightEqualToView(self.stateBtn)
    .widthIs(100)
    .heightIs(36);
    self.startLearnBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.startLearnBtn.imageView.sd_layout
    .centerYEqualToView(self.startLearnBtn)
    .leftSpaceToView(self.startLearnBtn, 12)
    .widthIs(13)
    .heightEqualToWidth();
    
    self.startLearnBtn.titleLabel.sd_layout
    .centerYEqualToView(self.startLearnBtn)
    .leftSpaceToView(self.startLearnBtn.imageView, 3)
    .rightSpaceToView(self.startLearnBtn, 3)
    .heightIs(20);
    
    
    self.tipLabel.sd_layout
    .centerYEqualToView(self.startLearnBtn)
    .leftSpaceToView(self.bigBackgroundView, 14)
    .rightSpaceToView(self.muLuBtn, 10)
    .heightIs(17);
    
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
        _courseNameLabel.font = HXBoldFont(14);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _courseNameLabel;
}


- (UIButton *)stateBtn{
    if (!_stateBtn) {
        _stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stateBtn.backgroundColor = COLOR_WITH_ALPHA(0xEAFBEC, 1);
        _stateBtn.titleLabel.font = HXFont(12);
        [_stateBtn setTitleColor:COLOR_WITH_ALPHA(0x5DC367, 1) forState:UIControlStateNormal];
       
    }
    return _stateBtn;
}

- (UILabel *)jinDuTitleLabel{
    if (!_jinDuTitleLabel) {
        _jinDuTitleLabel = [[UILabel alloc] init];
        _jinDuTitleLabel.font = HXFont(15);
        _jinDuTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _jinDuTitleLabel.text = @"学习进度(分钟)";
    }
    return _jinDuTitleLabel;
}

- (UILabel *)jinDuContentLabel{
    if (!_jinDuContentLabel) {
        _jinDuContentLabel = [[UILabel alloc] init];
        _jinDuContentLabel.textAlignment = NSTextAlignmentRight;
        _jinDuContentLabel.font = HXFont(15);
        _jinDuContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _jinDuContentLabel;
}

- (UILabel *)teacherTitleLabel{
    if (!_teacherTitleLabel) {
        _teacherTitleLabel = [[UILabel alloc] init];
        _teacherTitleLabel.font = HXFont(15);
        _teacherTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _teacherTitleLabel.text = @"授课老师";
    }
    return _teacherTitleLabel;
}

- (UILabel *)teacherContentLabel{
    if (!_teacherContentLabel) {
        _teacherContentLabel = [[UILabel alloc] init];
        _teacherContentLabel.textAlignment = NSTextAlignmentRight;
        _teacherContentLabel.font = HXFont(15);
        _teacherContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _teacherContentLabel;
}

- (UILabel *)timeTitleLabel{
    if (!_timeTitleLabel) {
        _timeTitleLabel = [[UILabel alloc] init];
        _timeTitleLabel.font = HXFont(15);
        _timeTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _timeTitleLabel.text = @"学习时间";
    }
    return _timeTitleLabel;
}

- (UILabel *)timeContentLabel{
    if (!_timeContentLabel) {
        _timeContentLabel = [[UILabel alloc] init];
        _timeContentLabel.textAlignment = NSTextAlignmentLeft;
        _timeContentLabel.font = HXFont(15);
        _timeContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _timeContentLabel;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.font = HXFont(12);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0xEF5959, 1);
        _tipLabel.hidden = YES;
    }
    return _tipLabel;
}



- (UIButton *)startLearnBtn{
    if (!_startLearnBtn) {
        _startLearnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startLearnBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _startLearnBtn.titleLabel.font = HXBoldFont(14);
        [_startLearnBtn setImage:[UIImage imageNamed:@"smallplay_icon"] forState:UIControlStateNormal];
        [_startLearnBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_startLearnBtn setTitle:@"开始学习" forState:UIControlStateNormal];
        [_startLearnBtn addTarget:self action:@selector(startLearn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startLearnBtn;
}

@end

