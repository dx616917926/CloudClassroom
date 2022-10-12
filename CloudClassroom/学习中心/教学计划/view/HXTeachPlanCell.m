//
//  HXTeachPlanCell.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXTeachPlanCell.h"

@interface HXTeachPlanCell ()

@property(nonatomic,strong) UIView *bigBackgroundView;
@property(nonatomic,strong) UIImageView *courseIcon;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *xueQiLabel;
@property(nonatomic,strong) UIButton *typeBtn;

@property(nonatomic,strong) UIView *showContainerView;
//总学分
@property(nonatomic,strong) UIView *zongXueFenView;
@property(nonatomic,strong) UILabel *zongXueFenTitleLabel;
@property(nonatomic,strong) UILabel *zongXueFenContentLabel;
//总学时
@property(nonatomic,strong) UIView *zongXueShiView;
@property(nonatomic,strong) UILabel *zongXueShiTitleLabel;
@property(nonatomic,strong) UILabel *zongXueShiContentLabel;
//考核方式
@property(nonatomic,strong) UIView *kaoHeFangShiView;
@property(nonatomic,strong) UILabel *kaoHeFangShiTitleLabel;
@property(nonatomic,strong) UILabel *kaoHeFangShiContentLabel;
//网学
@property(nonatomic,strong) UIView *wangXueView;
@property(nonatomic,strong) UILabel *wangXueTitleLabel;
@property(nonatomic,strong) UILabel *wangXueContentLabel;
//课内学时
@property(nonatomic,strong) UIView *keNeiXueShiView;
@property(nonatomic,strong) UILabel *keNeiXueShiTitleLabel;
@property(nonatomic,strong) UILabel *keNeiXueShiContentLabel;
//上机学时
@property(nonatomic,strong) UIView *shangJiXueShiView;
@property(nonatomic,strong) UILabel *shangJiXueShiTitleLabel;
@property(nonatomic,strong) UILabel *shangJiXueShiContentLabel;
//实践学时
@property(nonatomic,strong) UIView *shiJianXueShiView;
@property(nonatomic,strong) UILabel *shiJianXueShiTitleLabel;
@property(nonatomic,strong) UILabel *shiJianXueShiContentLabel;
//自学学时
@property(nonatomic,strong) UIView *ziXueXueShiView;
@property(nonatomic,strong) UILabel *ziXueXueShiTitleLabel;
@property(nonatomic,strong) UILabel *ziXueXueShiContentLabel;


@end

@implementation HXTeachPlanCell

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
-(void)setClassPlanModel:(HXClassPlanModel *)classPlanModel{
    
    _classPlanModel = classPlanModel;
    
    self.courseNameLabel.text = classPlanModel.courseName;
    self.xueQiLabel.text = classPlanModel.term;
    [self.typeBtn setTitle:classPlanModel.courseTypeName forState:UIControlStateNormal];
    self.zongXueFenContentLabel.text = HXIntToString(classPlanModel.coursePoint);
    self.zongXueShiContentLabel.text = HXIntToString(classPlanModel.courseTotalHour);
    self.kaoHeFangShiContentLabel.text = classPlanModel.checkLookName;
    self.wangXueContentLabel.textColor = (classPlanModel.isNetCourse==1?COLOR_WITH_ALPHA(0x2E5BFD, 1):COLOR_WITH_ALPHA(0xF8A528, 1));
    self.wangXueContentLabel.text = (classPlanModel.isNetCourse==1?@"是":@"否");
    self.keNeiXueShiContentLabel.text = HXIntToString(classPlanModel.classHour);
    self.shangJiXueShiContentLabel.text = HXIntToString(classPlanModel.computerHour);
    self.shiJianXueShiContentLabel.text = HXIntToString(classPlanModel.practiseHour);
    self.ziXueXueShiContentLabel.text = HXIntToString(classPlanModel.practiseHour);
    
}


#pragma mark - UI
-(void)createUI{

    self.contentView.backgroundColor = VCBackgroundColor;
    self.backgroundColor =VCBackgroundColor;
    
    [self.contentView addSubview:self.bigBackgroundView];
    [self.bigBackgroundView addSubview:self.courseIcon];
    [self.bigBackgroundView addSubview:self.courseNameLabel];
    [self.bigBackgroundView addSubview:self.xueQiLabel];
    [self.bigBackgroundView addSubview:self.typeBtn];
    [self.bigBackgroundView addSubview:self.showContainerView];
    //
    [self.showContainerView addSubview:self.zongXueFenView];
    [self.zongXueFenView addSubview:self.zongXueFenTitleLabel];
    [self.zongXueFenView addSubview:self.zongXueFenContentLabel];
    //
    [self.showContainerView addSubview:self.zongXueShiView];
    [self.zongXueShiView addSubview:self.zongXueShiTitleLabel];
    [self.zongXueShiView addSubview:self.zongXueShiContentLabel];
    //
    [self.showContainerView addSubview:self.kaoHeFangShiView];
    [self.kaoHeFangShiView addSubview:self.kaoHeFangShiTitleLabel];
    [self.kaoHeFangShiView addSubview:self.kaoHeFangShiContentLabel];
    //
    [self.showContainerView addSubview:self.wangXueView];
    [self.wangXueView addSubview:self.wangXueTitleLabel];
    [self.wangXueView addSubview:self.wangXueContentLabel];
    //
    [self.showContainerView addSubview:self.keNeiXueShiView];
    [self.keNeiXueShiView addSubview:self.keNeiXueShiTitleLabel];
    [self.keNeiXueShiView addSubview:self.keNeiXueShiContentLabel];
    //
    [self.showContainerView addSubview:self.shangJiXueShiView];
    [self.shangJiXueShiView addSubview:self.shangJiXueShiTitleLabel];
    [self.shangJiXueShiView addSubview:self.shangJiXueShiContentLabel];
    //
    [self.showContainerView addSubview:self.shiJianXueShiView];
    [self.shiJianXueShiView addSubview:self.shiJianXueShiTitleLabel];
    [self.shiJianXueShiView addSubview:self.shiJianXueShiContentLabel];
    //
    [self.showContainerView addSubview:self.ziXueXueShiView];
    [self.ziXueXueShiView addSubview:self.ziXueXueShiTitleLabel];
    [self.ziXueXueShiView addSubview:self.ziXueXueShiContentLabel];
    
    
    
    self.bigBackgroundView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(6, 12, 6, 12));
    self.bigBackgroundView.sd_cornerRadius = @8;
    
    self.typeBtn.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .rightSpaceToView(self.bigBackgroundView, 16);
    [self.typeBtn setupAutoSizeWithHorizontalPadding:5 buttonHeight:20];
    self.typeBtn.sd_cornerRadius = @2;
    
    self.courseIcon.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.bigBackgroundView, 16)
    .heightIs(20)
    .widthEqualToHeight();
    
    self.courseNameLabel.sd_layout
    .topSpaceToView(self.bigBackgroundView, 16)
    .leftSpaceToView(self.courseIcon, 4)
    .heightIs(20);
    [self.courseNameLabel setSingleLineAutoResizeWithMaxWidth:_kpw(200)];
    
    self.xueQiLabel.sd_layout
    .centerYEqualToView(self.courseNameLabel)
    .leftSpaceToView(self.courseNameLabel, 6)
    .heightIs(17);
    [self.xueQiLabel setSingleLineAutoResizeWithMaxWidth:70];

    self.showContainerView.sd_layout
    .topSpaceToView(self.courseNameLabel,3)
    .leftSpaceToView(self.bigBackgroundView, 0)
    .rightSpaceToView(self.bigBackgroundView,0);
    
    //总学分
    self.zongXueFenView.sd_layout.heightIs(45);
    
    self.zongXueFenTitleLabel.sd_layout
    .topSpaceToView(self.zongXueFenView, 0)
    .leftEqualToView(self.zongXueFenView)
    .rightEqualToView(self.zongXueFenView)
    .heightIs(17);
    
    self.zongXueFenContentLabel.sd_layout
    .bottomSpaceToView(self.zongXueFenView, 0)
    .leftEqualToView(self.zongXueFenView)
    .rightEqualToView(self.zongXueFenView)
    .heightIs(20);
    
    //总学时
    self.zongXueShiView.sd_layout.heightRatioToView(self.zongXueFenView, 1);
    
    self.zongXueShiTitleLabel.sd_layout
    .topSpaceToView(self.zongXueShiView, 0)
    .leftEqualToView(self.zongXueShiView)
    .rightEqualToView(self.zongXueShiView)
    .heightRatioToView(self.zongXueFenTitleLabel, 1);
    
    self.zongXueShiContentLabel.sd_layout
    .bottomSpaceToView(self.zongXueShiView, 0)
    .leftEqualToView(self.zongXueShiView)
    .rightEqualToView(self.zongXueShiView)
    .heightRatioToView(self.zongXueFenContentLabel, 1);
    
    //考核方式
    self.kaoHeFangShiView.sd_layout.heightRatioToView(self.zongXueFenView, 1);
    
    self.kaoHeFangShiTitleLabel.sd_layout
    .topSpaceToView(self.kaoHeFangShiView, 0)
    .leftEqualToView(self.kaoHeFangShiView)
    .rightEqualToView(self.kaoHeFangShiView)
    .heightRatioToView(self.zongXueFenTitleLabel, 1);
    
    self.kaoHeFangShiContentLabel.sd_layout
    .bottomSpaceToView(self.kaoHeFangShiView, 0)
    .leftEqualToView(self.kaoHeFangShiView)
    .rightEqualToView(self.kaoHeFangShiView)
    .heightRatioToView(self.zongXueFenContentLabel, 1);
    
    //网学
    self.wangXueView.sd_layout.heightRatioToView(self.zongXueFenView, 1);
    
    self.wangXueTitleLabel.sd_layout
    .topSpaceToView(self.wangXueView, 0)
    .leftEqualToView(self.wangXueView)
    .rightEqualToView(self.wangXueView)
    .heightRatioToView(self.zongXueFenTitleLabel, 1);
    
    self.wangXueContentLabel.sd_layout
    .bottomSpaceToView(self.wangXueView, 0)
    .leftEqualToView(self.wangXueView)
    .rightEqualToView(self.wangXueView)
    .heightRatioToView(self.zongXueFenContentLabel, 1);
    
    //课内学时
    self.keNeiXueShiView.sd_layout.heightRatioToView(self.zongXueFenView, 1);
    
    self.keNeiXueShiTitleLabel.sd_layout
    .topSpaceToView(self.keNeiXueShiView, 0)
    .leftEqualToView(self.keNeiXueShiView)
    .rightEqualToView(self.keNeiXueShiView)
    .heightRatioToView(self.zongXueFenTitleLabel, 1);
    
    self.keNeiXueShiContentLabel.sd_layout
    .bottomSpaceToView(self.keNeiXueShiView, 0)
    .leftEqualToView(self.keNeiXueShiView)
    .rightEqualToView(self.keNeiXueShiView)
    .heightRatioToView(self.zongXueFenContentLabel, 1);
    
    //上机学时
    self.shangJiXueShiView.sd_layout.heightRatioToView(self.zongXueFenView, 1);
    
    self.shangJiXueShiTitleLabel.sd_layout
    .topSpaceToView(self.shangJiXueShiView, 0)
    .leftEqualToView(self.shangJiXueShiView)
    .rightEqualToView(self.shangJiXueShiView)
    .heightRatioToView(self.zongXueFenTitleLabel, 1);
    
    self.shangJiXueShiContentLabel.sd_layout
    .bottomSpaceToView(self.shangJiXueShiView, 0)
    .leftEqualToView(self.shangJiXueShiView)
    .rightEqualToView(self.shangJiXueShiView)
    .heightRatioToView(self.zongXueFenContentLabel, 1);
    
    //实践学时
    self.shiJianXueShiView.sd_layout.heightRatioToView(self.zongXueFenView, 1);
    
    self.shiJianXueShiTitleLabel.sd_layout
    .topSpaceToView(self.shiJianXueShiView, 0)
    .leftEqualToView(self.shiJianXueShiView)
    .rightEqualToView(self.shiJianXueShiView)
    .heightRatioToView(self.zongXueFenTitleLabel, 1);
    
    self.shiJianXueShiContentLabel.sd_layout
    .bottomSpaceToView(self.shiJianXueShiView, 0)
    .leftEqualToView(self.shiJianXueShiView)
    .rightEqualToView(self.shiJianXueShiView)
    .heightRatioToView(self.zongXueFenContentLabel, 1);
    
    //自学学时
    self.ziXueXueShiView.sd_layout.heightRatioToView(self.zongXueFenView, 1);
    
    self.ziXueXueShiTitleLabel.sd_layout
    .topSpaceToView(self.ziXueXueShiView, 0)
    .leftEqualToView(self.ziXueXueShiView)
    .rightEqualToView(self.ziXueXueShiView)
    .heightRatioToView(self.zongXueFenTitleLabel, 1);
    
    self.ziXueXueShiContentLabel.sd_layout
    .bottomSpaceToView(self.ziXueXueShiView, 0)
    .leftEqualToView(self.ziXueXueShiView)
    .rightEqualToView(self.ziXueXueShiView)
    .heightRatioToView(self.zongXueFenContentLabel, 1);
    
    
    
    [self.showContainerView setupAutoMarginFlowItems:@[self.zongXueFenView,self.zongXueShiView,self.kaoHeFangShiView,self.wangXueView,self.keNeiXueShiView,self.shangJiXueShiView,self.shiJianXueShiView,self.ziXueXueShiView] withPerRowItemsCount:4 itemWidth:60 verticalMargin:15 verticalEdgeInset:15 horizontalEdgeInset:20];
    
   
    
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

- (UIImageView *)courseIcon{
    if (!_courseIcon) {
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
        
    }
    return _courseNameLabel;
}

- (UILabel *)xueQiLabel{
    if (!_xueQiLabel) {
        _xueQiLabel = [[UILabel alloc] init];
        _xueQiLabel.font = HXFont(12);
        _xueQiLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
       
    }
    return _xueQiLabel;
}

- (UIButton *)typeBtn{
    if (!_typeBtn) {
        _typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeBtn.backgroundColor = COLOR_WITH_ALPHA(0xEAEFFF, 1);
        _typeBtn.titleLabel.font = HXFont(12);
        [_typeBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        
    }
    return _typeBtn;
}

-(UIView *)showContainerView{
    if (!_showContainerView) {
        _showContainerView = [[UIView alloc] init];
        _showContainerView.backgroundColor = [UIColor whiteColor];
        _showContainerView.clipsToBounds = YES;
    }
    return _showContainerView;
}

-(UIView *)zongXueFenView{
    if (!_zongXueFenView) {
        _zongXueFenView = [[UIView alloc] init];
        _zongXueFenView.backgroundColor = [UIColor whiteColor];
        _zongXueFenView.clipsToBounds = YES;
    }
    return _zongXueFenView;
}


- (UILabel *)zongXueFenTitleLabel{
    if (!_zongXueFenTitleLabel) {
        _zongXueFenTitleLabel = [[UILabel alloc] init];
        _zongXueFenTitleLabel.textAlignment = NSTextAlignmentCenter;
        _zongXueFenTitleLabel.font =HXFont(12);
        _zongXueFenTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _zongXueFenTitleLabel.text = @"总学分";
    }
    return _zongXueFenTitleLabel;
}

- (UILabel *)zongXueFenContentLabel{
    if (!_zongXueFenContentLabel) {
        _zongXueFenContentLabel = [[UILabel alloc] init];
        _zongXueFenContentLabel.textAlignment = NSTextAlignmentCenter;
        _zongXueFenContentLabel.font =HXBoldFont(14);
        _zongXueFenContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _zongXueFenContentLabel;
}


-(UIView *)zongXueShiView{
    if (!_zongXueShiView) {
        _zongXueShiView = [[UIView alloc] init];
        _zongXueShiView.backgroundColor = [UIColor whiteColor];
        _zongXueShiView.clipsToBounds = YES;
    }
    return _zongXueShiView;
}


- (UILabel *)zongXueShiTitleLabel{
    if (!_zongXueShiTitleLabel) {
        _zongXueShiTitleLabel = [[UILabel alloc] init];
        _zongXueShiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _zongXueShiTitleLabel.font =HXFont(12);
        _zongXueShiTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _zongXueShiTitleLabel.text = @"总学时";
    }
    return _zongXueShiTitleLabel;
}

- (UILabel *)zongXueShiContentLabel{
    if (!_zongXueShiContentLabel) {
        _zongXueShiContentLabel = [[UILabel alloc] init];
        _zongXueShiContentLabel.textAlignment = NSTextAlignmentCenter;
        _zongXueShiContentLabel.font =HXBoldFont(14);
        _zongXueShiContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _zongXueShiContentLabel;
}


-(UIView *)kaoHeFangShiView{
    if (!_kaoHeFangShiView) {
        _kaoHeFangShiView = [[UIView alloc] init];
        _kaoHeFangShiView.backgroundColor = [UIColor whiteColor];
        _kaoHeFangShiView.clipsToBounds = YES;
    }
    return _kaoHeFangShiView;
}


- (UILabel *)kaoHeFangShiTitleLabel{
    if (!_kaoHeFangShiTitleLabel) {
        _kaoHeFangShiTitleLabel = [[UILabel alloc] init];
        _kaoHeFangShiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _kaoHeFangShiTitleLabel.font =HXFont(12);
        _kaoHeFangShiTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _kaoHeFangShiTitleLabel.text = @"考核方式";
    }
    return _kaoHeFangShiTitleLabel;
}

- (UILabel *)kaoHeFangShiContentLabel{
    if (!_kaoHeFangShiContentLabel) {
        _kaoHeFangShiContentLabel = [[UILabel alloc] init];
        _kaoHeFangShiContentLabel.textAlignment = NSTextAlignmentCenter;
        _kaoHeFangShiContentLabel.font =HXBoldFont(14);
        _kaoHeFangShiContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _kaoHeFangShiContentLabel;
}

-(UIView *)wangXueView{
    if (!_wangXueView) {
        _wangXueView = [[UIView alloc] init];
        _wangXueView.backgroundColor = [UIColor whiteColor];
        _wangXueView.clipsToBounds = YES;
    }
    return _wangXueView;
}


- (UILabel *)wangXueTitleLabel{
    if (!_wangXueTitleLabel) {
        _wangXueTitleLabel = [[UILabel alloc] init];
        _wangXueTitleLabel.textAlignment = NSTextAlignmentCenter;
        _wangXueTitleLabel.font =HXFont(12);
        _wangXueTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _wangXueTitleLabel.text = @"网学";
    }
    return _wangXueTitleLabel;
}

- (UILabel *)wangXueContentLabel{
    if (!_wangXueContentLabel) {
        _wangXueContentLabel = [[UILabel alloc] init];
        _wangXueContentLabel.textAlignment = NSTextAlignmentCenter;
        _wangXueContentLabel.font =HXBoldFont(14);

    }
    return _wangXueContentLabel;
}

-(UIView *)keNeiXueShiView{
    if (!_keNeiXueShiView) {
        _keNeiXueShiView = [[UIView alloc] init];
        _keNeiXueShiView.backgroundColor = [UIColor whiteColor];
        _keNeiXueShiView.clipsToBounds = YES;
    }
    return _keNeiXueShiView;
}


- (UILabel *)keNeiXueShiTitleLabel{
    if (!_keNeiXueShiTitleLabel) {
        _keNeiXueShiTitleLabel = [[UILabel alloc] init];
        _keNeiXueShiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _keNeiXueShiTitleLabel.font =HXFont(12);
        _keNeiXueShiTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _keNeiXueShiTitleLabel.text = @"课内学时";
    }
    return _keNeiXueShiTitleLabel;
}

- (UILabel *)keNeiXueShiContentLabel{
    if (!_keNeiXueShiContentLabel) {
        _keNeiXueShiContentLabel = [[UILabel alloc] init];
        _keNeiXueShiContentLabel.textAlignment = NSTextAlignmentCenter;
        _keNeiXueShiContentLabel.font =HXBoldFont(14);
        _keNeiXueShiContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _keNeiXueShiContentLabel;
}

-(UIView *)shangJiXueShiView{
    if (!_shangJiXueShiView) {
        _shangJiXueShiView = [[UIView alloc] init];
        _shangJiXueShiView.backgroundColor = [UIColor whiteColor];
        _shangJiXueShiView.clipsToBounds = YES;
    }
    return _shangJiXueShiView;
}


- (UILabel *)shangJiXueShiTitleLabel{
    if (!_shangJiXueShiTitleLabel) {
        _shangJiXueShiTitleLabel = [[UILabel alloc] init];
        _shangJiXueShiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _shangJiXueShiTitleLabel.font =HXFont(12);
        _shangJiXueShiTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _shangJiXueShiTitleLabel.text = @"上机学时";
    }
    return _shangJiXueShiTitleLabel;
}

- (UILabel *)shangJiXueShiContentLabel{
    if (!_shangJiXueShiContentLabel) {
        _shangJiXueShiContentLabel = [[UILabel alloc] init];
        _shangJiXueShiContentLabel.textAlignment = NSTextAlignmentCenter;
        _shangJiXueShiContentLabel.font =HXBoldFont(14);
        _shangJiXueShiContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _shangJiXueShiContentLabel;
}


-(UIView *)shiJianXueShiView{
    if (!_shiJianXueShiView) {
        _shiJianXueShiView = [[UIView alloc] init];
        _shiJianXueShiView.backgroundColor = [UIColor whiteColor];
        _shiJianXueShiView.clipsToBounds = YES;
    }
    return _shiJianXueShiView;
}


- (UILabel *)shiJianXueShiTitleLabel{
    if (!_shiJianXueShiTitleLabel) {
        _shiJianXueShiTitleLabel = [[UILabel alloc] init];
        _shiJianXueShiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _shiJianXueShiTitleLabel.font =HXFont(12);
        _shiJianXueShiTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _shiJianXueShiTitleLabel.text = @"实践学时";
    }
    return _shiJianXueShiTitleLabel;
}

- (UILabel *)shiJianXueShiContentLabel{
    if (!_shiJianXueShiContentLabel) {
        _shiJianXueShiContentLabel = [[UILabel alloc] init];
        _shiJianXueShiContentLabel.textAlignment = NSTextAlignmentCenter;
        _shiJianXueShiContentLabel.font =HXBoldFont(14);
        _shiJianXueShiContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _shiJianXueShiContentLabel;
}

-(UIView *)ziXueXueShiView{
    if (!_ziXueXueShiView) {
        _ziXueXueShiView = [[UIView alloc] init];
        _ziXueXueShiView.backgroundColor = [UIColor whiteColor];
        _ziXueXueShiView.clipsToBounds = YES;
    }
    return _ziXueXueShiView;
}


- (UILabel *)ziXueXueShiTitleLabel{
    if (!_ziXueXueShiTitleLabel) {
        _ziXueXueShiTitleLabel = [[UILabel alloc] init];
        _ziXueXueShiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _ziXueXueShiTitleLabel.font =HXFont(12);
        _ziXueXueShiTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _ziXueXueShiTitleLabel.text = @"自学学时";
    }
    return _ziXueXueShiTitleLabel;
}

- (UILabel *)ziXueXueShiContentLabel{
    if (!_ziXueXueShiContentLabel) {
        _ziXueXueShiContentLabel = [[UILabel alloc] init];
        _ziXueXueShiContentLabel.textAlignment = NSTextAlignmentCenter;
        _ziXueXueShiContentLabel.font =HXBoldFont(14);
        _ziXueXueShiContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _ziXueXueShiContentLabel;
}

@end

