//
//  HXExamRecordCell.m
//  CloudClassroom
//
//  Created by mac on 2022/12/7.
//

#import "HXExamRecordCell.h"

@interface HXExamRecordCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *titleLabel;
//考试时间
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UILabel *scoreLabel;

@property(nonatomic,strong) UIButton *checkAnswerBtn;
@property(nonatomic,strong) UIButton *continueExamBtn;

@end

@implementation HXExamRecordCell

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
-(void)setExamRecordModel:(HXExamRecordModel *)examRecordModel{
    
    _examRecordModel = examRecordModel;
    

    if ([HXCommonUtil isNull:examRecordModel.continueExamUrl]) {
        self.continueExamBtn.sd_layout.rightSpaceToView(self.bigBackgroundView, 0).widthIs(0);
    }else{
        self.continueExamBtn.sd_layout.rightSpaceToView(self.bigBackgroundView, 14).widthIs(84);
    }
    
    if ([HXCommonUtil isNull:examRecordModel.viewUrl]) {
        self.checkAnswerBtn.sd_layout.rightSpaceToView(self.continueExamBtn, 0).widthIs(0);
    }else{
        self.checkAnswerBtn.sd_layout.rightSpaceToView(self.continueExamBtn, 14).widthIs(84);
    }
    self.titleLabel.text = [NSString stringWithFormat:@"第%ld次考试",(long)examRecordModel.index];
    
    self.timeLabel.text = [HXCommonUtil timestampSwitchTime:[examRecordModel.beginTime integerValue]/1000 andFormatter:@"yyyy.MM.dd HH:mm:ss"];
    if ([examRecordModel.score integerValue]==-1) {
        self.scoreLabel.text = @"交白卷";
    }else if ([examRecordModel.score integerValue]==0) {
        self.scoreLabel.text = @"处理中...";
    }else{
        self.scoreLabel.text = [examRecordModel.score stringByAppendingString:@"分"];
    }
    
}

#pragma mark - Event
-(void)clickCheckAnswerBtn:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkAnswer:checkAnswerBtn:)]) {
        [self.delegate checkAnswer:self.examRecordModel checkAnswerBtn:self.checkAnswerBtn];
    }
}

-(void)clickContinueExamBtn:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(continueExam:continueExamBtn:)]) {
        [self.delegate continueExam:self.examRecordModel continueExamBtn:self.continueExamBtn];
    }
}



#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.titleLabel];
    [self.bigBackgroundView addSubview:self.timeLabel];
    [self.bigBackgroundView addSubview:self.checkAnswerBtn];
    [self.bigBackgroundView addSubview:self.continueExamBtn];
    [self.bigBackgroundView addSubview:self.scoreLabel];
    
    
    
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 14)
    .widthIs(150)
    .heightIs(20);
    
    self.timeLabel.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftSpaceToView(self.titleLabel, 20)
    .rightSpaceToView(self.bigBackgroundView, 14)
    .heightIs(20);
   
    
   
    self.continueExamBtn.sd_layout
    .bottomSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.bigBackgroundView, 14)
    .widthIs(84)
    .heightIs(36);
    self.continueExamBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.checkAnswerBtn.sd_layout
    .centerYEqualToView(self.continueExamBtn)
    .rightSpaceToView(self.continueExamBtn, 14)
    .widthIs(84)
    .heightIs(36);
    self.checkAnswerBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.scoreLabel.sd_layout
    .bottomEqualToView(self.continueExamBtn)
    .leftSpaceToView(self.bigBackgroundView, 14)
    .rightSpaceToView(self.checkAnswerBtn, 10)
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

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = HXBoldFont(14);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
    }
    return _titleLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = HXFont(14);
        _timeLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UILabel *)scoreLabel{
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.font = HXBoldFont(14);
        _scoreLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
    }
    return _scoreLabel;
}





- (UIButton *)checkAnswerBtn{
    if (!_checkAnswerBtn) {
        _checkAnswerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkAnswerBtn.layer.borderWidth = 1;
        _checkAnswerBtn.layer.borderColor = COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        _checkAnswerBtn.backgroundColor = UIColor.whiteColor;
        _checkAnswerBtn.titleLabel.font = HXBoldFont(14);
        [_checkAnswerBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_checkAnswerBtn setTitle:@"查看答卷" forState:UIControlStateNormal];
        [_checkAnswerBtn addTarget:self action:@selector(clickCheckAnswerBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkAnswerBtn;
}

- (UIButton *)continueExamBtn{
    if (!_continueExamBtn) {
        _continueExamBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _continueExamBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _continueExamBtn.titleLabel.font = HXBoldFont(14);
        [_continueExamBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_continueExamBtn setTitle:@"继续作答" forState:UIControlStateNormal];
        [_continueExamBtn addTarget:self action:@selector(clickContinueExamBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _continueExamBtn;
}

@end




