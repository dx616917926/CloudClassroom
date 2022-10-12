//
//  HXMyBuKaoCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/7.
//

#import "HXMyBuKaoCell.h"

@interface HXMyBuKaoCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *courseCodeLabel;

@property(nonatomic,strong) UIButton *zuoYeBtn;
@property(nonatomic,strong) UIButton *kaoShiBtn;

@end

@implementation HXMyBuKaoCell

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
-(void)setBuKaoModel:(HXBuKaoModel *)buKaoModel{
    
    _buKaoModel = buKaoModel;
    
    self.courseNameLabel.text = buKaoModel.termCourseName;
    self.courseCodeLabel.text = [NSString stringWithFormat:@"课程编码 %@",buKaoModel.zyCode];
    self.zuoYeBtn.hidden = buKaoModel.showZY==1?NO:YES;
    self.kaoShiBtn.hidden = buKaoModel.showQM==1?NO:YES;
    [self.zuoYeBtn setTitle:(buKaoModel.zyButtonName?buKaoModel.zyButtonName:@"平时作业") forState:UIControlStateNormal];
    [self.kaoShiBtn setTitle:(buKaoModel.qmButtonName?buKaoModel.qmButtonName:@"期末考试") forState:UIControlStateNormal];
    
}

#pragma mark - Event
-(void)clickEvent:(UIButton *)sender{
    NSInteger type = sender.tag-70000;
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpType:buKaoModel:)]) {
        [self.delegate jumpType:type buKaoModel:self.buKaoModel];
    }
}



#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.courseCodeLabel];
    [self.bigBackgroundView addSubview:self.zuoYeBtn];
    [self.bigBackgroundView addSubview:self.kaoShiBtn];
  
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(8, 12, 8, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
   
    self.courseCodeLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 14)
    .rightSpaceToView(self.bigBackgroundView, 16)
    .heightIs(17);
    [self.courseCodeLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    self.courseNameLabel.sd_layout
    .centerYEqualToView(self.courseCodeLabel)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.courseCodeLabel, 16)
    .heightIs(20);
    
    
    self.zuoYeBtn.sd_layout
    .topSpaceToView(self.courseNameLabel, 16)
    .leftSpaceToView(self.bigBackgroundView, 60)
    .widthIs(100)
    .heightIs(20);
    
    self.zuoYeBtn.imageView.sd_layout
    .centerYEqualToView(self.zuoYeBtn)
    .leftEqualToView(self.zuoYeBtn)
    .widthIs(20)
    .heightEqualToWidth();
    
    self.zuoYeBtn.titleLabel.sd_layout
    .centerYEqualToView(self.zuoYeBtn)
    .leftSpaceToView(self.zuoYeBtn.imageView, 4)
    .rightSpaceToView(self.zuoYeBtn, 4)
    .heightIs(18);
    
    self.kaoShiBtn.sd_layout
    .centerYEqualToView(self.zuoYeBtn)
    .leftSpaceToView(self.zuoYeBtn, _kpw(65))
    .widthIs(100)
    .heightIs(20);
    
    self.kaoShiBtn.imageView.sd_layout
    .centerYEqualToView(self.kaoShiBtn)
    .leftEqualToView(self.kaoShiBtn)
    .widthIs(20)
    .heightEqualToWidth();
    
    self.kaoShiBtn.titleLabel.sd_layout
    .centerYEqualToView(self.kaoShiBtn)
    .leftSpaceToView(self.kaoShiBtn.imageView, 4)
    .rightSpaceToView(self.kaoShiBtn, 4)
    .heightIs(18);
    
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

- (UILabel *)courseCodeLabel{
    if (!_courseCodeLabel) {
        _courseCodeLabel = [[UILabel alloc] init];
        _courseCodeLabel.textAlignment = NSTextAlignmentRight;
        _courseCodeLabel.font = HXFont(12);
        _courseCodeLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        
    }
    return _courseCodeLabel;
}



- (UIButton *)zuoYeBtn{
    if (!_zuoYeBtn) {
        _zuoYeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _zuoYeBtn.tag = 70000;
        _zuoYeBtn.titleLabel.font = HXFont(14);
        [_zuoYeBtn setImage:[UIImage imageNamed:@"zuoye_icon"] forState:UIControlStateNormal];
        [_zuoYeBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_zuoYeBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zuoYeBtn;
}


- (UIButton *)kaoShiBtn{
    if (!_kaoShiBtn) {
        _kaoShiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _kaoShiBtn.tag = 70001;
        _kaoShiBtn.titleLabel.font = HXFont(14);
        [_kaoShiBtn setImage:[UIImage imageNamed:@"kaoshi_icon"] forState:UIControlStateNormal];
        [_kaoShiBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_kaoShiBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _kaoShiBtn;
}

@end



