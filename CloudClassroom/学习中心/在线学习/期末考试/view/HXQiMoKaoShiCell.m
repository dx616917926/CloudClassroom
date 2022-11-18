//
//  HXQiMoKaoShiCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXQiMoKaoShiCell.h"

@interface HXQiMoKaoShiCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *courseNameLabel;

@property(nonatomic,strong) UIButton *stateBtn;
//剩余考试次数
@property(nonatomic,strong) UILabel *ciShuTitleLabel;
@property(nonatomic,strong) UILabel *ciShuContentLabel;
//考试时间
@property(nonatomic,strong) UILabel *timeTitleLabel;
@property(nonatomic,strong) UILabel *timeContentLabel;

@property(nonatomic,strong) UILabel *tipLabel;
@property(nonatomic,strong) UIButton *chechRecordBtn;
@property(nonatomic,strong) UIButton *startKaoShiBtn;

@end

@implementation HXQiMoKaoShiCell

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
-(void)setExamModel:(HXExamModel *)examModel{
    _examModel = examModel;
    
    [self.stateBtn setTitle:@"进行中" forState:UIControlStateNormal];
    
    self.courseNameLabel.text = examModel.examTitle;
    self.ciShuContentLabel.text = HXIntToString(examModel.leftExamNum);
    self.timeContentLabel.text = [NSString stringWithFormat:@"%@   --   %@",[HXCommonUtil timestampSwitchTime:[examModel.beginTime integerValue]/1000 andFormatter:nil],[HXCommonUtil timestampSwitchTime:[examModel.endTime integerValue]/1000 andFormatter:nil]];
    
    self.chechRecordBtn.hidden = (examModel.leftExamNum == examModel.maxExamNum);
    
    self.startKaoShiBtn.enabled = examModel.canExam;
    self.startKaoShiBtn.backgroundColor = examModel.canExam? COLOR_WITH_ALPHA(0x2E5BFD, 1):COLOR_WITH_ALPHA(0xC6C8D0, 1);
    
    self.tipLabel.hidden =!(![HXCommonUtil isNull:examModel.showMessage]&&!examModel.canExam);
    self.tipLabel.text = examModel.showMessage;
}

#pragma mark - Event
-(void)chechRecord:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chechExamRecord:)]) {
        [self.delegate chechExamRecord:self.examModel];
    }
}

-(void)startKaoShi:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startExam:)]) {
        [self.delegate startExam:self.examModel];
    }
}



#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.stateBtn];
    [self.bigBackgroundView addSubview:self.ciShuTitleLabel];
    [self.bigBackgroundView addSubview:self.ciShuContentLabel];
    [self.bigBackgroundView addSubview:self.timeTitleLabel];
    [self.bigBackgroundView addSubview:self.timeContentLabel];
    [self.bigBackgroundView addSubview:self.tipLabel];
    [self.bigBackgroundView addSubview:self.chechRecordBtn];
    [self.bigBackgroundView addSubview:self.startKaoShiBtn];
    
    
    
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
    
    self.ciShuTitleLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 16)
    .leftEqualToView(self.courseNameLabel)
    .widthIs(110)
    .heightIs(21);
   
    self.ciShuContentLabel.sd_layout
    .centerYEqualToView(self.ciShuTitleLabel)
    .rightSpaceToView(self.bigBackgroundView, 18)
    .leftSpaceToView(self.ciShuTitleLabel, 20)
    .heightRatioToView(self.ciShuTitleLabel, 1);
    
   
    
    self.timeTitleLabel.sd_layout
    .topSpaceToView(self.ciShuTitleLabel, 12)
    .leftEqualToView(self.courseNameLabel)
    .widthRatioToView(self.ciShuTitleLabel, 1)
    .heightRatioToView(self.ciShuTitleLabel, 1);
   
    self.timeContentLabel.sd_layout
    .topSpaceToView(self.timeTitleLabel, 10)
    .leftEqualToView(self.courseNameLabel)
    .rightEqualToView(self.stateBtn)
    .heightRatioToView(self.ciShuTitleLabel, 1);
   
    self.startKaoShiBtn.sd_layout
    .topSpaceToView(self.timeContentLabel, 20)
    .rightEqualToView(self.stateBtn)
    .widthIs(105)
    .heightIs(36);
    self.startKaoShiBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.startKaoShiBtn.imageView.sd_layout
    .centerYEqualToView(self.startKaoShiBtn)
    .leftSpaceToView(self.startKaoShiBtn, 12)
    .widthIs(13)
    .heightIs(15);
    
    self.startKaoShiBtn.titleLabel.sd_layout
    .centerYEqualToView(self.startKaoShiBtn)
    .leftSpaceToView(self.startKaoShiBtn.imageView, 3)
    .rightSpaceToView(self.startKaoShiBtn, 3)
    .heightIs(20);
    
    self.chechRecordBtn.sd_layout
    .centerYEqualToView(self.startKaoShiBtn)
    .rightSpaceToView(self.startKaoShiBtn, 12)
    .widthIs(108)
    .heightRatioToView(self.startKaoShiBtn, 1);
    self.chechRecordBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.tipLabel.sd_layout
    .centerYEqualToView(self.startKaoShiBtn)
    .leftSpaceToView(self.bigBackgroundView, 14)
    .rightSpaceToView(self.chechRecordBtn, 10)
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
        [_stateBtn setTitle:@"进行中" forState:UIControlStateNormal];
    }
    return _stateBtn;
}

- (UILabel *)ciShuTitleLabel{
    if (!_ciShuTitleLabel) {
        _ciShuTitleLabel = [[UILabel alloc] init];
        _ciShuTitleLabel.font = HXFont(15);
        _ciShuTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _ciShuTitleLabel.text = @"剩余考试次数";
    }
    return _ciShuTitleLabel;
}

- (UILabel *)ciShuContentLabel{
    if (!_ciShuContentLabel) {
        _ciShuContentLabel = [[UILabel alloc] init];
        _ciShuContentLabel.textAlignment = NSTextAlignmentRight;
        _ciShuContentLabel.font = HXFont(15);
        _ciShuContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _ciShuContentLabel;
}



- (UILabel *)timeTitleLabel{
    if (!_timeTitleLabel) {
        _timeTitleLabel = [[UILabel alloc] init];
        _timeTitleLabel.font = HXFont(15);
        _timeTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _timeTitleLabel.text = @"考试时间";
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

- (UIButton *)chechRecordBtn{
    if (!_chechRecordBtn) {
        _chechRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chechRecordBtn.layer.borderWidth = 1;
        _chechRecordBtn.layer.borderColor = COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        _chechRecordBtn.backgroundColor = UIColor.whiteColor;
        _chechRecordBtn.titleLabel.font = HXBoldFont(14);
        [_chechRecordBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_chechRecordBtn setTitle:@"查看考试记录" forState:UIControlStateNormal];
        [_chechRecordBtn addTarget:self action:@selector(chechRecord:) forControlEvents:UIControlEventTouchUpInside];
        _chechRecordBtn.hidden = YES;
    }
    return _chechRecordBtn;
}

- (UIButton *)startKaoShiBtn{
    if (!_startKaoShiBtn) {
        _startKaoShiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startKaoShiBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _startKaoShiBtn.titleLabel.font = HXBoldFont(14);
        [_startKaoShiBtn setImage:[UIImage imageNamed:@"pingshizuoye_icon"] forState:UIControlStateNormal];
        [_startKaoShiBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_startKaoShiBtn setTitle:@"开始考试" forState:UIControlStateNormal];
        [_startKaoShiBtn addTarget:self action:@selector(startKaoShi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startKaoShiBtn;
}

@end



