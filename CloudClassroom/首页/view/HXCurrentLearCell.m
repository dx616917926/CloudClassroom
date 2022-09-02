//
//  HXCurrentLearCell.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "HXCurrentLearCell.h"

@interface HXCurrentLearCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UIButton *typeBtn;

@property(nonatomic,strong) UIView *btnsContainerView;
@property(nonatomic,strong) UIButton *keJianBtn;
@property(nonatomic,strong) UIButton *keJianStateBtn;
@property(nonatomic,strong) UIButton *zuoYeBtn;
@property(nonatomic,strong) UIButton *zuoYeStateBtn;
@property(nonatomic,strong) UIButton *kaoShiBtn;
@property(nonatomic,strong) UIButton *kaoShiStateBtn;
@property(nonatomic,strong) UIButton *daYiShiBtn;
@property(nonatomic,strong) UIButton *daYiShiStateBtn;

@property(nonatomic,strong) UIView *lineView;

@property(nonatomic,strong) UIControl *xueXiBaoGaoView;
@property(nonatomic,strong) UIButton *xueXiBaoGaoBtn;
@property(nonatomic,strong) UILabel *xueXiBaoGaoContentLabel;
@property(nonatomic,strong) UIImageView *xueXiBaoGaoArrow;

@property(nonatomic,strong) UIControl *rankView;
@property(nonatomic,strong) UIButton *rankBtn;
@property(nonatomic,strong) UILabel *rankContentLabel;
@property(nonatomic,strong) UIImageView *rankArrow;

@property(nonatomic,strong) UIControl *scoreView;
@property(nonatomic,strong) UIButton *scoreBtn;
@property(nonatomic,strong) UILabel *scoreContentLabel;
@property(nonatomic,strong) UIImageView *scoreArrow;



@end

@implementation HXCurrentLearCell

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

#pragma mark -Event
-(void)clickEvent:(UIControl *)sender{
    NSInteger tag = sender.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleClickEvent:)]) {
        [self.delegate handleClickEvent:tag];
    }
}


#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
    self.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.typeBtn];
    [self.bigBackgroundView addSubview:self.btnsContainerView];
    [self.btnsContainerView addSubview:self.keJianBtn];
    [self.keJianBtn addSubview:self.keJianStateBtn];
    [self.btnsContainerView addSubview:self.zuoYeBtn];
    [self.zuoYeBtn addSubview:self.zuoYeStateBtn];
    [self.btnsContainerView addSubview:self.kaoShiBtn];
    [self.kaoShiBtn addSubview:self.kaoShiStateBtn];
    [self.btnsContainerView addSubview:self.daYiShiBtn];
    [self.daYiShiBtn addSubview:self.daYiShiStateBtn];
    [self.bigBackgroundView addSubview:self.lineView];
    
    [self.bigBackgroundView addSubview:self.xueXiBaoGaoView];
    [self.xueXiBaoGaoView addSubview:self.xueXiBaoGaoBtn];
    [self.xueXiBaoGaoView addSubview:self.xueXiBaoGaoContentLabel];
    [self.xueXiBaoGaoView addSubview:self.xueXiBaoGaoArrow];
    
    [self.bigBackgroundView addSubview:self.rankView];
    [self.rankView addSubview:self.rankBtn];
    [self.rankView addSubview:self.rankContentLabel];
    [self.rankView addSubview:self.rankArrow];
    
    [self.bigBackgroundView addSubview:self.scoreView];
    [self.scoreView addSubview:self.scoreBtn];
    [self.scoreView addSubview:self.scoreContentLabel];
    [self.scoreView addSubview:self.scoreArrow];
    
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    self.typeBtn.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.bigBackgroundView, 16);
    [self.typeBtn setupAutoSizeWithHorizontalPadding:5 buttonHeight:20];
    self.typeBtn.sd_cornerRadius = @2;
    
    self.courseNameLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.typeBtn, 20)
    .heightIs(20);

    self.btnsContainerView.sd_layout
    .topSpaceToView(self.courseNameLabel,3)
    .leftSpaceToView(self.bigBackgroundView, 0)
    .rightSpaceToView(self.bigBackgroundView,0);
    
    self.keJianBtn.sd_layout.heightIs(68);
    self.keJianBtn.imageView.sd_layout
    .centerXEqualToView(self.keJianBtn)
    .topSpaceToView(self.keJianBtn, 0)
    .widthIs(47)
    .heightEqualToWidth();
    
    self.keJianStateBtn.sd_layout
    .topEqualToView(self.keJianBtn).offset(-10)
    .rightEqualToView(self.keJianBtn).offset(15)
    .widthIs(30)
    .heightIs(15);
    self.keJianStateBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.keJianBtn.titleLabel.sd_layout
    .bottomSpaceToView(self.keJianBtn, 0)
    .leftEqualToView(self.keJianBtn)
    .rightEqualToView(self.keJianBtn)
    .heightIs(17);
    
    self.zuoYeBtn.sd_layout.heightRatioToView(self.keJianBtn, 1);
    self.zuoYeBtn.imageView.sd_layout
    .centerXEqualToView(self.zuoYeBtn)
    .topSpaceToView(self.zuoYeBtn, 0)
    .widthIs(47)
    .heightEqualToWidth();
    
    self.zuoYeStateBtn.sd_layout
    .topEqualToView(self.zuoYeBtn).offset(-10)
    .rightEqualToView(self.zuoYeBtn).offset(15)
    .widthIs(30)
    .heightIs(15);
    self.zuoYeStateBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.zuoYeBtn.titleLabel.sd_layout
    .bottomSpaceToView(self.zuoYeBtn, 0)
    .leftEqualToView(self.zuoYeBtn)
    .rightEqualToView(self.zuoYeBtn)
    .heightIs(17);
    
    
    self.kaoShiBtn.sd_layout.heightRatioToView(self.keJianBtn, 1);
    self.kaoShiBtn.imageView.sd_layout
    .centerXEqualToView(self.kaoShiBtn)
    .topSpaceToView(self.kaoShiBtn, 0)
    .widthIs(47)
    .heightEqualToWidth();
    
    self.kaoShiStateBtn.sd_layout
    .topEqualToView(self.kaoShiBtn).offset(-10)
    .rightEqualToView(self.kaoShiBtn).offset(15)
    .widthIs(30)
    .heightIs(15);;
    self.kaoShiStateBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.kaoShiBtn.titleLabel.sd_layout
    .bottomSpaceToView(self.kaoShiBtn, 0)
    .leftEqualToView(self.kaoShiBtn)
    .rightEqualToView(self.kaoShiBtn)
    .heightIs(17);
    
    self.daYiShiBtn.sd_layout.heightRatioToView(self.keJianBtn, 1);
    self.daYiShiBtn.imageView.sd_layout
    .centerXEqualToView(self.daYiShiBtn)
    .topSpaceToView(self.daYiShiBtn, 0)
    .widthIs(47)
    .heightEqualToWidth();
    
    self.daYiShiStateBtn.sd_layout
    .topEqualToView(self.daYiShiBtn).offset(-10)
    .rightEqualToView(self.daYiShiBtn).offset(15)
    .widthIs(30)
    .heightIs(15);
    self.daYiShiStateBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.daYiShiBtn.titleLabel.sd_layout
    .bottomSpaceToView(self.daYiShiBtn, 0)
    .leftEqualToView(self.daYiShiBtn)
    .rightEqualToView(self.daYiShiBtn)
    .heightIs(17);
    
    [self.btnsContainerView setupAutoMarginFlowItems:@[self.keJianBtn,self.zuoYeBtn,self.kaoShiBtn,self.daYiShiBtn] withPerRowItemsCount:4 itemWidth:60 verticalMargin:20 verticalEdgeInset:20 horizontalEdgeInset:20];
    
    self.lineView.sd_layout
    .topSpaceToView(self.btnsContainerView, 0)
    .leftEqualToView(self.bigBackgroundView)
    .rightEqualToView(self.bigBackgroundView)
    .heightIs(1);
    
    self.rankView.sd_layout
    .centerXEqualToView(self.bigBackgroundView)
    .topSpaceToView(self.lineView, 0)
    .bottomEqualToView(self.bigBackgroundView)
    .widthRatioToView(self.bigBackgroundView, 0.33);
    
    self.xueXiBaoGaoView.sd_layout
    .leftEqualToView(self.bigBackgroundView)
    .rightSpaceToView(self.rankView, 0)
    .topEqualToView(self.rankView)
    .bottomEqualToView(self.rankView);
    
    self.scoreView.sd_layout
    .rightEqualToView(self.bigBackgroundView)
    .leftSpaceToView(self.rankView, 0)
    .topEqualToView(self.rankView)
    .bottomEqualToView(self.rankView);
    
    //班级排名
    self.rankBtn.sd_layout
    .centerXEqualToView(self.rankView)
    .topSpaceToView(self.rankView, 15)
    .heightIs(18);
    
    self.rankBtn.imageView.sd_layout
    .centerYEqualToView(self.rankBtn)
    .leftEqualToView(self.rankBtn)
    .widthIs(18)
    .heightEqualToWidth();
    
    self.rankBtn.titleLabel.sd_layout
    .centerYEqualToView(self.rankBtn)
    .leftSpaceToView(self.rankBtn.imageView, 4)
    .heightRatioToView(self.rankBtn, 1);
    [self.rankBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:70];
    
    [self.rankBtn setupAutoWidthWithRightView:self.rankBtn.titleLabel rightMargin:0];
    
    
    self.rankContentLabel.sd_layout
    .centerXEqualToView(self.rankView).offset(-2)
    .topSpaceToView(self.rankBtn, 8)
    .heightIs(17);
    [self.rankContentLabel setSingleLineAutoResizeWithMaxWidth:40];
    
    self.rankArrow.sd_layout
    .centerYEqualToView(self.rankContentLabel)
    .leftSpaceToView(self.rankContentLabel, 5)
    .widthIs(4)
    .heightIs(7);
    
    //学习报告
    self.xueXiBaoGaoBtn.sd_layout
    .centerXEqualToView(self.xueXiBaoGaoView)
    .topSpaceToView(self.xueXiBaoGaoView, 15)
    .heightIs(18);
    
    self.xueXiBaoGaoBtn.imageView.sd_layout
    .centerYEqualToView(self.xueXiBaoGaoBtn)
    .leftEqualToView(self.xueXiBaoGaoBtn)
    .widthIs(18)
    .heightEqualToWidth();
    
    self.xueXiBaoGaoBtn.titleLabel.sd_layout
    .centerYEqualToView(self.xueXiBaoGaoBtn)
    .leftSpaceToView(self.xueXiBaoGaoBtn.imageView, 4)
    .heightRatioToView(self.xueXiBaoGaoBtn, 1);
    [self.xueXiBaoGaoBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:70];
    
    [self.xueXiBaoGaoBtn setupAutoWidthWithRightView:self.xueXiBaoGaoBtn.titleLabel rightMargin:0];
    
    
    self.xueXiBaoGaoContentLabel.sd_layout
    .centerXEqualToView(self.xueXiBaoGaoView).offset(-2)
    .topSpaceToView(self.xueXiBaoGaoBtn, 8)
    .heightIs(17);
    [self.xueXiBaoGaoContentLabel setSingleLineAutoResizeWithMaxWidth:40];
    
    self.xueXiBaoGaoArrow.sd_layout
    .centerYEqualToView(self.xueXiBaoGaoContentLabel)
    .leftSpaceToView(self.xueXiBaoGaoContentLabel, 5)
    .widthIs(4)
    .heightIs(7);
    
    //得分
    self.scoreBtn.sd_layout
    .centerXEqualToView(self.scoreView)
    .topSpaceToView(self.scoreView, 15)
    .heightIs(18);
    
    self.scoreBtn.imageView.sd_layout
    .centerYEqualToView(self.scoreBtn)
    .leftEqualToView(self.scoreBtn)
    .widthIs(18)
    .heightEqualToWidth();
    
    self.scoreBtn.titleLabel.sd_layout
    .centerYEqualToView(self.scoreBtn)
    .leftSpaceToView(self.scoreBtn.imageView, 4)
    .heightRatioToView(self.scoreBtn, 1);
    [self.scoreBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:70];
    
    [self.scoreBtn setupAutoWidthWithRightView:self.scoreBtn.titleLabel rightMargin:0];
    
    
    self.scoreContentLabel.sd_layout
    .centerXEqualToView(self.scoreView).offset(-2)
    .topSpaceToView(self.scoreBtn, 8)
    .heightIs(17);
    [self.scoreContentLabel setSingleLineAutoResizeWithMaxWidth:40];
    
    self.scoreArrow.sd_layout
    .centerYEqualToView(self.scoreContentLabel)
    .leftSpaceToView(self.scoreContentLabel, 5)
    .widthIs(4)
    .heightIs(7);
    
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
        _courseNameLabel.text = @"中国近代史纲要";
    }
    return _courseNameLabel;
}

- (UIButton *)typeBtn{
    if (!_typeBtn) {
        _typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeBtn.backgroundColor = COLOR_WITH_ALPHA(0xEAEFFF, 1);
        _typeBtn.titleLabel.font = HXFont(12);
        [_typeBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_typeBtn setTitle:@"专业课" forState:UIControlStateNormal];
    }
    return _typeBtn;
}

-(UIView *)btnsContainerView{
    if (!_btnsContainerView) {
        _btnsContainerView = [[UIView alloc] init];
        _btnsContainerView.backgroundColor = [UIColor whiteColor];
        _btnsContainerView.clipsToBounds = YES;
    }
    return _btnsContainerView;
}

- (UIButton *)keJianBtn{
    if (!_keJianBtn) {
        _keJianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _keJianBtn.titleLabel.font = HXFont(13);
        _keJianBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_keJianBtn setImage:[UIImage imageNamed:@"kejian_icon"] forState:UIControlStateNormal];
        [_keJianBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_keJianBtn setTitle:@"课件学习" forState:UIControlStateNormal];
        _keJianBtn.tag = 8000;
        [_keJianBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keJianBtn;
}

- (UIButton *)keJianStateBtn{
    if (!_keJianStateBtn) {
        _keJianStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _keJianStateBtn.backgroundColor = COLOR_WITH_ALPHA(0xF8A528, 0.1);
        _keJianStateBtn.titleLabel.font = HXFont(10);
        [_keJianStateBtn setTitleColor:COLOR_WITH_ALPHA(0xF8A528, 1) forState:UIControlStateNormal];
        [_keJianStateBtn setTitle:@"56%" forState:UIControlStateNormal];
    }
    return _keJianStateBtn;
}

- (UIButton *)zuoYeBtn{
    if (!_zuoYeBtn) {
        _zuoYeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _zuoYeBtn.titleLabel.font = HXFont(13);
        _zuoYeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_zuoYeBtn setImage:[UIImage imageNamed:@"zuoye_icon"] forState:UIControlStateNormal];
        [_zuoYeBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_zuoYeBtn setTitle:@"平时作业" forState:UIControlStateNormal];
        _zuoYeBtn.tag = 8001;
        [_zuoYeBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zuoYeBtn;
}

- (UIButton *)zuoYeStateBtn{
    if (!_zuoYeStateBtn) {
        _zuoYeStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _zuoYeStateBtn.backgroundColor = COLOR_WITH_ALPHA(0xFDEDED, 1);
        _zuoYeStateBtn.titleLabel.font = HXFont(10);
        [_zuoYeStateBtn setTitleColor:COLOR_WITH_ALPHA(0xED4F4F, 1) forState:UIControlStateNormal];
        [_zuoYeStateBtn setTitle:@"12分" forState:UIControlStateNormal];
    }
    return _zuoYeStateBtn;
}

- (UIButton *)kaoShiBtn{
    if (!_kaoShiBtn) {
        _kaoShiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _kaoShiBtn.titleLabel.font = HXFont(13);
        _kaoShiBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_kaoShiBtn setImage:[UIImage imageNamed:@"kaoshi_icon"] forState:UIControlStateNormal];
        [_kaoShiBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_kaoShiBtn setTitle:@"期末考试" forState:UIControlStateNormal];
        _kaoShiBtn.tag = 8002;
        [_kaoShiBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _kaoShiBtn;
}

- (UIButton *)kaoShiStateBtn{
    if (!_kaoShiStateBtn) {
        _kaoShiStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _kaoShiStateBtn.backgroundColor = COLOR_WITH_ALPHA(0xEAFBEC, 1);
        _kaoShiStateBtn.titleLabel.font = HXFont(10);
        [_kaoShiStateBtn setTitleColor:COLOR_WITH_ALPHA(0x5DC367, 1) forState:UIControlStateNormal];
        [_kaoShiStateBtn setTitle:@"84分" forState:UIControlStateNormal];
    }
    return _kaoShiStateBtn;
}

- (UIButton *)daYiShiBtn{
    if (!_daYiShiBtn) {
        _daYiShiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _daYiShiBtn.titleLabel.font = HXFont(13);
        _daYiShiBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_daYiShiBtn setImage:[UIImage imageNamed:@"dayishi_icon"] forState:UIControlStateNormal];
        [_daYiShiBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_daYiShiBtn setTitle:@"答疑室" forState:UIControlStateNormal];
        _daYiShiBtn.tag = 8003;
        [_daYiShiBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _daYiShiBtn;
}

- (UIButton *)daYiShiStateBtn{
    if (!_daYiShiStateBtn) {
        _daYiShiStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _daYiShiStateBtn.backgroundColor = COLOR_WITH_ALPHA(0xEAFBEC, 1);
        _daYiShiStateBtn.titleLabel.font = HXFont(10);
        [_daYiShiStateBtn setTitleColor:COLOR_WITH_ALPHA(0x5DC367, 1) forState:UIControlStateNormal];
        [_daYiShiStateBtn setTitle:@"99+" forState:UIControlStateNormal];
    }
    return _daYiShiStateBtn;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = COLOR_WITH_ALPHA(0xF0F0F0, 1);
    }
    return _lineView;
}


-(UIControl *)xueXiBaoGaoView{
    if (!_xueXiBaoGaoView) {
        _xueXiBaoGaoView = [[UIControl alloc] init];
        _xueXiBaoGaoView.backgroundColor = [UIColor whiteColor];
        _xueXiBaoGaoView.clipsToBounds = YES;
        _xueXiBaoGaoView.tag = 8004;
        [_xueXiBaoGaoView addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _xueXiBaoGaoView;
}

- (UIButton *)xueXiBaoGaoBtn{
    if (!_xueXiBaoGaoBtn) {
        _xueXiBaoGaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _xueXiBaoGaoBtn.userInteractionEnabled = NO;
        _xueXiBaoGaoBtn.titleLabel.font = HXFont(13);
        _xueXiBaoGaoBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_xueXiBaoGaoBtn setImage:[UIImage imageNamed:@"xuexibaogao_icon"] forState:UIControlStateNormal];
        [_xueXiBaoGaoBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_xueXiBaoGaoBtn setTitle:@"学习报告" forState:UIControlStateNormal];
    }
    return _xueXiBaoGaoBtn;
}



- (UILabel *)xueXiBaoGaoContentLabel{
    if (!_xueXiBaoGaoContentLabel) {
        _xueXiBaoGaoContentLabel = [[UILabel alloc] init];
        _xueXiBaoGaoContentLabel.font = HXBoldFont(12);
        _xueXiBaoGaoContentLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _xueXiBaoGaoContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"9" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} content: @"9分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x999999, 1),NSFontAttributeName:[UIFont systemFontOfSize:8]}];

    }
    return _xueXiBaoGaoContentLabel;
}

- (UIImageView *)xueXiBaoGaoArrow{
    if (!_xueXiBaoGaoArrow) {
        _xueXiBaoGaoArrow = [[UIImageView alloc] init];
        _xueXiBaoGaoArrow.image = [UIImage imageNamed:@"blackright_arrow"];
    }
    return _xueXiBaoGaoArrow;
}

-(UIControl *)rankView{
    if (!_rankView) {
        _rankView = [[UIControl alloc] init];
        _rankView.backgroundColor = [UIColor whiteColor];
        _rankView.clipsToBounds = YES;
        _rankView.tag = 8005;
        [_rankView addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rankView;
}

- (UIButton *)rankBtn{
    if (!_rankBtn) {
        _rankBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rankBtn.userInteractionEnabled = NO;
        _rankBtn.titleLabel.font = HXFont(13);
        _rankBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_rankBtn setImage:[UIImage imageNamed:@"rank_icon"] forState:UIControlStateNormal];
        [_rankBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_rankBtn setTitle:@"班级排名" forState:UIControlStateNormal];
    }
    return _rankBtn;
}



- (UILabel *)rankContentLabel{
    if (!_rankContentLabel) {
        _rankContentLabel = [[UILabel alloc] init];
        _rankContentLabel.font = HXBoldFont(12);
        _rankContentLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _rankContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"12" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} content: @"12名" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x999999, 1),NSFontAttributeName:[UIFont systemFontOfSize:8]}];
    }
    return _rankContentLabel;
}

- (UIImageView *)rankArrow{
    if (!_rankArrow) {
        _rankArrow = [[UIImageView alloc] init];
        _rankArrow.image = [UIImage imageNamed:@"blackright_arrow"];
    }
    return _rankArrow;
}

-(UIControl *)scoreView{
    if (!_scoreView) {
        _scoreView = [[UIControl alloc] init];
        _scoreView.backgroundColor = [UIColor whiteColor];
        _scoreView.clipsToBounds = YES;
        _scoreView.tag = 8006;
        [_scoreView addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scoreView;
}

- (UIButton *)scoreBtn{
    if (!_scoreBtn) {
        _scoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scoreBtn.userInteractionEnabled = NO;
        _scoreBtn.titleLabel.font = HXFont(13);
        _scoreBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_scoreBtn setImage:[UIImage imageNamed:@"score_icon1"] forState:UIControlStateNormal];
        [_scoreBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_scoreBtn setTitle:@"得分" forState:UIControlStateNormal];
    }
    return _scoreBtn;
}


- (UILabel *)scoreContentLabel{
    if (!_scoreContentLabel) {
        _scoreContentLabel = [[UILabel alloc] init];
        _scoreContentLabel.font =HXBoldFont(12);
        _scoreContentLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _scoreContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"86" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} content: @"86分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x999999, 1),NSFontAttributeName:[UIFont systemFontOfSize:8]}];
    }
    return _scoreContentLabel;
}

- (UIImageView *)scoreArrow{
    if (!_scoreArrow) {
        _scoreArrow = [[UIImageView alloc] init];
        _scoreArrow.image = [UIImage imageNamed:@"blackright_arrow"];
    }
    return _scoreArrow;
}


@end
