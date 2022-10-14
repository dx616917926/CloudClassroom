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

//权重后得分
@property(nonatomic,strong) UILabel *quanZhongFenTitleLabel;
@property(nonatomic,strong) UILabel *quanZhongFenContentLabel;

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

#pragma mark -Setter
-(void)setCourseReportModel:(HXCourseReportModel *)courseReportModel{
    _courseReportModel = courseReportModel;
    
    HXCourseItemModel *itemModel = (courseReportModel.type==1?courseReportModel.zyInfo.firstObject:courseReportModel.qmInfo.firstObject);
    self.titleIcon.image = [UIImage imageNamed:(courseReportModel.type==1?@"reportzuoye_icon":@"reportqimo_icon")];
    self.titleNameLabel.text = itemModel.moduleButtonName;
    
    self.quanZhongFenContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:(itemModel.moduleScore?:@"0") needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:[(itemModel.moduleScore?:@"0") stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    
    [self.containerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
            obj = nil;
    }];
    
    NSArray *array = (courseReportModel.type==1?courseReportModel.zyInfo:courseReportModel.qmInfo);
    for (int i=0; i<array.count; i++) {
        HXCourseItemModel *model = array[i];
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
        titleLabel.text = model.termCourseName;
        [view addSubview:titleLabel];
        
        UILabel *zuiGaoFenTitleLabel = [[UILabel alloc] init];
        zuiGaoFenTitleLabel.textAlignment = NSTextAlignmentCenter;
        zuiGaoFenTitleLabel.font = HXFont(14);
        zuiGaoFenTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        zuiGaoFenTitleLabel.text = @"最高分";
        [view addSubview:zuiGaoFenTitleLabel];
        
        UILabel *zuiGaoFenContentLabel = [[UILabel alloc] init];
        zuiGaoFenContentLabel.textAlignment = NSTextAlignmentCenter;
        zuiGaoFenContentLabel.font = HXFont(14);
        zuiGaoFenContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        zuiGaoFenContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:(model.getScore?:@"0") needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:[(model.getScore?:@"0") stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
        [view addSubview:zuiGaoFenContentLabel];
        
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
        maFenContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:(model.totalScore?:@"100") needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:[(model.totalScore?:@"100") stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
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
        ciShuContentLabel.attributedText = [HXCommonUtil getAttributedStringWith:HXIntToString(model.examCount) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:[HXIntToString(model.examCount) stringByAppendingString:@"次"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
        [view addSubview:ciShuContentLabel];
        
        titleLabel.sd_layout
        .topSpaceToView(view, 16)
        .leftSpaceToView(view, 16)
        .rightSpaceToView(view, 16)
        .heightIs(18);
        
        zuiGaoFenTitleLabel.sd_layout
        .topSpaceToView(titleLabel, 16)
        .leftEqualToView(view)
        .widthRatioToView(view, 0.33)
        .heightIs(19);
        
        zuiGaoFenContentLabel.sd_layout
        .topSpaceToView(zuiGaoFenTitleLabel, 6)
        .leftEqualToView(zuiGaoFenTitleLabel)
        .rightEqualToView(zuiGaoFenTitleLabel)
        .heightRatioToView(zuiGaoFenTitleLabel, 1);
        
        maFenTitleLabel.sd_layout
        .centerYEqualToView(zuiGaoFenTitleLabel)
        .centerXEqualToView(view)
        .widthRatioToView(zuiGaoFenTitleLabel, 1)
        .heightRatioToView(zuiGaoFenTitleLabel, 1);
        
        maFenContentLabel.sd_layout
        .centerYEqualToView(zuiGaoFenContentLabel)
        .leftEqualToView(maFenTitleLabel)
        .rightEqualToView(maFenTitleLabel)
        .heightRatioToView(zuiGaoFenTitleLabel, 1);
        
        ciShuTitleLabel.sd_layout
        .centerYEqualToView(zuiGaoFenTitleLabel)
        .rightEqualToView(view)
        .widthRatioToView(zuiGaoFenTitleLabel, 1)
        .heightRatioToView(zuiGaoFenTitleLabel, 1);
        
        ciShuContentLabel.sd_layout
        .centerYEqualToView(zuiGaoFenContentLabel)
        .leftEqualToView(ciShuTitleLabel)
        .rightEqualToView(ciShuTitleLabel)
        .heightRatioToView(zuiGaoFenTitleLabel, 1);
        
    }
    
    self.containerView.sd_layout.heightIs(127*array.count+16);
    [self.containerView updateLayout];
}

#pragma mark - UI
-(void)createUI{
    self.clipsToBounds = YES;
    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.titleIcon];
    [self.bigBackgroundView addSubview:self.titleNameLabel];
    [self.bigBackgroundView addSubview:self.quanZhongFenTitleLabel];
    [self.bigBackgroundView addSubview:self.quanZhongFenContentLabel];
    [self.bigBackgroundView addSubview:self.containerView];
   
    
    
    
    self.bigBackgroundView.sd_layout
    .topSpaceToView(self.contentView, 8)
    .leftSpaceToView(self.contentView, 12)
    .rightSpaceToView(self.contentView, 12)
    .bottomSpaceToView(self.contentView, 8);
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
    
    self.quanZhongFenTitleLabel.sd_layout
    .topSpaceToView(self.titleIcon, 17)
    .leftEqualToView(self.titleIcon)
    .widthIs(110)
    .heightIs(20);
   
    self.quanZhongFenContentLabel.sd_layout
    .centerYEqualToView(self.quanZhongFenTitleLabel)
    .rightSpaceToView(self.bigBackgroundView, 12)
    .leftSpaceToView(self.quanZhongFenTitleLabel, 20)
    .heightRatioToView(self.quanZhongFenTitleLabel, 1);
    
    self.containerView.sd_layout
    .topSpaceToView(self.quanZhongFenTitleLabel, 16)
    .leftSpaceToView(self.bigBackgroundView, 12)
    .rightSpaceToView(self.bigBackgroundView, 12)
    .heightIs(0);
  
    

    
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
        
    }
    return _titleNameLabel;
}


- (UILabel *)quanZhongFenTitleLabel{
    if (!_quanZhongFenTitleLabel) {
        _quanZhongFenTitleLabel = [[UILabel alloc] init];
        _quanZhongFenTitleLabel.font = HXFont(14);
        _quanZhongFenTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _quanZhongFenTitleLabel.text = @"权重后得分";
    }
    return _quanZhongFenTitleLabel;
}

- (UILabel *)quanZhongFenContentLabel{
    if (!_quanZhongFenContentLabel) {
        _quanZhongFenContentLabel = [[UILabel alloc] init];
        _quanZhongFenContentLabel.textAlignment = NSTextAlignmentRight;
        _quanZhongFenContentLabel.font = HXFont(15);
        _quanZhongFenContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _quanZhongFenContentLabel;
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
