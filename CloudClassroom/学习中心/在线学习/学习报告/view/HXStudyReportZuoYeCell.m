//
//  HXStudyReportZuoYeCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import "HXStudyReportZuoYeCell.h"

@interface HXStudyReportZuoYeCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *titleIcon;
@property(nonatomic,strong) UILabel *titleNameLabel;

//最终得分
@property(nonatomic,strong) UILabel *deFenTitleLabel;
@property(nonatomic,strong) UILabel *deFenContentLabel;

@property(nonatomic,strong) UIView *containerView;

@end

@implementation HXStudyReportZuoYeCell

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
    [self.bigBackgroundView addSubview:self.containerView];
   
    
    
    
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
    
    self.containerView.sd_layout
    .topSpaceToView(self.deFenTitleLabel, 16)
    .leftSpaceToView(self.bigBackgroundView, 12)
    .rightSpaceToView(self.bigBackgroundView, 12);
    
    
    
    [self.containerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
            obj = nil;
    }];
    
    UIView *lastView;
    
    for (int i=0; i<2; i++) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = COLOR_WITH_ALPHA(0xF8FAFE, 1);
        [self.containerView addSubview:view];
        view.sd_layout
        .topSpaceToView(self.containerView, (16+111)*i)
        .leftEqualToView(self.containerView)
        .rightEqualToView(self.containerView)
        .heightIs(111);
        view.sd_cornerRadius = @2;
        
       UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = HXBoldFont(13);
        titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        titleLabel.text = [NSString stringWithFormat:@"平时作业 %d",i+1];
        [view addSubview:titleLabel];
        
        UILabel *deFenTitleLabel = [[UILabel alloc] init];
        deFenTitleLabel.textAlignment = NSTextAlignmentCenter;
        deFenTitleLabel.font = HXFont(14);
        deFenTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        deFenTitleLabel.text = @"最终得分";
        [view addSubview:deFenTitleLabel];
        
        UILabel *deFenContentLabel = [[UILabel alloc] init];
        deFenContentLabel.textAlignment = NSTextAlignmentCenter;
        deFenContentLabel.font = HXFont(14);
        deFenContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        deFenContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"12" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content: @"12分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
        [view addSubview:deFenContentLabel];
        
        UILabel *maFenTitleLabel = [[UILabel alloc] init];
        maFenTitleLabel.textAlignment = NSTextAlignmentCenter;
        maFenTitleLabel.font = HXFont(14);
        maFenTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        maFenTitleLabel.text = @"满分";
        [view addSubview:maFenTitleLabel];
        
        UILabel *maFenContentLabel = [[UILabel alloc] init];
        maFenContentLabel.textAlignment = NSTextAlignmentCenter;
        maFenContentLabel.font = HXFont(15);
        maFenContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        maFenContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"100" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content: @"100分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
        [view addSubview:maFenContentLabel];
        
        UILabel *ciShuTitleLabel = [[UILabel alloc] init];
        ciShuTitleLabel.textAlignment = NSTextAlignmentCenter;
        ciShuTitleLabel.font = HXFont(14);
        ciShuTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        ciShuTitleLabel.text = @"考试次数";
        [view addSubview:ciShuTitleLabel];
        
        UILabel *ciShuContentLabel = [[UILabel alloc] init];
        ciShuContentLabel.textAlignment = NSTextAlignmentCenter;
        ciShuContentLabel.font = HXFont(15);
        ciShuContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        ciShuContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"5" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content: @"5次" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
        [view addSubview:ciShuContentLabel];
        
        titleLabel.sd_layout
        .topSpaceToView(view, 16)
        .leftSpaceToView(view, 16)
        .rightSpaceToView(view, 16)
        .heightIs(18);
        
        deFenTitleLabel.sd_layout
        .topSpaceToView(titleLabel, 16)
        .leftEqualToView(view)
        .widthRatioToView(view, 0.33)
        .heightIs(19);
        
        deFenContentLabel.sd_layout
        .topSpaceToView(deFenTitleLabel, 6)
        .leftEqualToView(deFenTitleLabel)
        .rightEqualToView(deFenTitleLabel)
        .heightRatioToView(deFenTitleLabel, 1);
        
        maFenTitleLabel.sd_layout
        .centerYEqualToView(deFenTitleLabel)
        .centerXEqualToView(view)
        .widthRatioToView(deFenTitleLabel, 1)
        .heightRatioToView(deFenTitleLabel, 1);
        
        maFenContentLabel.sd_layout
        .centerYEqualToView(deFenContentLabel)
        .leftEqualToView(maFenTitleLabel)
        .rightEqualToView(maFenTitleLabel)
        .heightRatioToView(deFenTitleLabel, 1);
        
        ciShuTitleLabel.sd_layout
        .centerYEqualToView(deFenTitleLabel)
        .rightEqualToView(view)
        .widthRatioToView(deFenTitleLabel, 1)
        .heightRatioToView(deFenTitleLabel, 1);
        
        ciShuContentLabel.sd_layout
        .centerYEqualToView(deFenContentLabel)
        .leftEqualToView(ciShuTitleLabel)
        .rightEqualToView(ciShuTitleLabel)
        .heightRatioToView(deFenTitleLabel, 1);
        
        lastView = view;
    }
    [self.containerView setupAutoHeightWithBottomView:lastView bottomMargin:0];
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
        _titleIcon.image = [UIImage imageNamed:@"reportzuoye_icon"];
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
        _deFenTitleLabel.text = @"最终得分";
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



-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}



@end
