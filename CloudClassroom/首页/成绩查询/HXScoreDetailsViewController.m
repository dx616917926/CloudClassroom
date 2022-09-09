//
//  HXScoreDetailsViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/7.
//

#import "HXScoreDetailsViewController.h"
#import "UIView+TransitionColor.h"

@interface HXScoreDetailsViewController ()

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIImageView *topBgImageView;
@property(nonatomic,strong) UIButton *backBtn;
@property(nonatomic,strong) UILabel *titleLabel;

@property(nonatomic,strong) UIImageView *courseIcon;
@property(nonatomic,strong) UILabel *courseNameLabel;
@property(nonatomic,strong) UILabel *fenShuLabel;
@property(nonatomic,strong) UILabel *fenLabel;
@property(nonatomic,strong) UILabel *tipLabel;
@property(nonatomic,strong) UIImageView *deFenIcon;

@property(nonatomic,strong) UIImageView *bottomBgImageView;
//课件学习
@property(nonatomic,strong) UIView *keJianXueXiView;
@property(nonatomic,strong) UIImageView *keJianXueXiIcon;
@property(nonatomic,strong) UILabel *keJianXueXiBFB;
@property(nonatomic,strong) UILabel *keJianXueXiNameLabel;
//平时作业
@property(nonatomic,strong) UIView *pingShiZuoYeView;
@property(nonatomic,strong) UIImageView *pingShiZuoYeIcon;
@property(nonatomic,strong) UILabel *pingShiZuoYeBFB;
@property(nonatomic,strong) UILabel *pingShiZuoYeNameLabel;
//学习表现
@property(nonatomic,strong) UIView *xueXiBiaoXianView;
@property(nonatomic,strong) UIImageView *xueXiBiaoXianIcon;
@property(nonatomic,strong) UILabel *xueXiBiaoXianBFB;
@property(nonatomic,strong) UILabel *xueXiBiaoXianNameLabel;
//期末考试
@property(nonatomic,strong) UIView *qiMoKaoShiView;
@property(nonatomic,strong) UIImageView *qiMoKaoShiIcon;
@property(nonatomic,strong) UILabel *qiMoKaoShiBFB;
@property(nonatomic,strong) UILabel *qiMoKaoShiNameLabel;

//成绩详情
@property(nonatomic,strong) UIView *detailsContainerView;
@property(nonatomic,strong) UILabel *detailsTitleLabel;
@property(nonatomic,strong) UILabel *keJianXueXiTitleLabel;
@property(nonatomic,strong) UILabel *keJianXueXiDeFenLabel;
@property(nonatomic,strong) UILabel *pingShiZuoYeTitleLabel;
@property(nonatomic,strong) UILabel *pingShiZuoYeDeFenLabel;
@property(nonatomic,strong) UILabel *xueXiBiaoXianTitleLabel;
@property(nonatomic,strong) UILabel *xueXiBiaoXianDeFenLabel;
@property(nonatomic,strong) UILabel *qiMoKaoShiTitleLabel;
@property(nonatomic,strong) UILabel *qiMoKaoShiDeFenLabel;



@end

@implementation HXScoreDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

#pragma mark - Event
-(void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
    
    [self.view addSubview:self.bottomBgImageView];
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.topBgImageView];
   
    [self.topBgImageView addSubview:self.titleLabel];
    [self.topBgImageView addSubview:self.backBtn];
    [self.topBgImageView addSubview:self.courseIcon];
    [self.topBgImageView addSubview:self.courseNameLabel];
    [self.topBgImageView addSubview:self.deFenIcon];
    [self.topBgImageView addSubview:self.fenShuLabel];
    [self.topBgImageView addSubview:self.fenLabel];
    [self.topBgImageView addSubview:self.tipLabel];
    
    [self.mainScrollView addSubview:self.keJianXueXiView];
    [self.mainScrollView addSubview:self.pingShiZuoYeView];
    [self.mainScrollView addSubview:self.xueXiBiaoXianView];
    [self.mainScrollView addSubview:self.qiMoKaoShiView];
    [self.mainScrollView addSubview:self.detailsContainerView];
    
    [self.keJianXueXiView addSubview:self.keJianXueXiIcon];
    [self.keJianXueXiView addSubview:self.keJianXueXiBFB];
    [self.keJianXueXiView addSubview:self.keJianXueXiNameLabel];
    
    [self.pingShiZuoYeView addSubview:self.pingShiZuoYeIcon];
    [self.pingShiZuoYeView addSubview:self.pingShiZuoYeBFB];
    [self.pingShiZuoYeView addSubview:self.pingShiZuoYeNameLabel];
    
    [self.xueXiBiaoXianView addSubview:self.xueXiBiaoXianIcon];
    [self.xueXiBiaoXianView addSubview:self.xueXiBiaoXianBFB];
    [self.xueXiBiaoXianView addSubview:self.xueXiBiaoXianNameLabel];
    
    [self.qiMoKaoShiView addSubview:self.qiMoKaoShiIcon];
    [self.qiMoKaoShiView addSubview:self.qiMoKaoShiBFB];
    [self.qiMoKaoShiView addSubview:self.qiMoKaoShiNameLabel];
    
    [self.detailsContainerView addSubview:self.detailsTitleLabel];
    [self.detailsContainerView addSubview:self.keJianXueXiTitleLabel];
    [self.detailsContainerView addSubview:self.keJianXueXiDeFenLabel];
    [self.detailsContainerView addSubview:self.xueXiBiaoXianTitleLabel];
    [self.detailsContainerView addSubview:self.xueXiBiaoXianDeFenLabel];
    [self.detailsContainerView addSubview:self.pingShiZuoYeTitleLabel];
    [self.detailsContainerView addSubview:self.pingShiZuoYeDeFenLabel];
    [self.detailsContainerView addSubview:self.qiMoKaoShiTitleLabel];
    [self.detailsContainerView addSubview:self.qiMoKaoShiDeFenLabel];
    
    
    self.topBgImageView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(189*kScreenWidth/375.0);
    

    self.bottomBgImageView.sd_layout
    .topSpaceToView(self.topBgImageView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(189*kScreenWidth/375.0);
    
    
    self.mainScrollView.sd_layout
    .topSpaceToView(self.topBgImageView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, 0);
    
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.topBgImageView, kStatusBarHeight)
    .centerXEqualToView(self.topBgImageView)
    .widthIs(100)
    .heightIs(23);
    
    self.backBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftEqualToView(self.topBgImageView)
    .widthIs(60)
    .heightIs(44);
    
   
    
    self.deFenIcon.sd_layout
    .topSpaceToView(self.titleLabel, 35)
    .rightSpaceToView(self.topBgImageView, 30)
    .widthIs(87)
    .heightIs(80);
    
    self.courseIcon.sd_layout
    .topEqualToView(self.deFenIcon)
    .leftSpaceToView(self.topBgImageView, 30)
    .widthIs(16)
    .heightEqualToWidth();
    
    self.courseNameLabel.sd_layout
    .centerYEqualToView(self.courseIcon)
    .leftSpaceToView(self.courseIcon, 4)
    .rightSpaceToView(self.deFenIcon, 16)
    .heightIs(18);
    
    
    self.fenShuLabel.sd_layout
    .topSpaceToView(self.courseNameLabel, 9)
    .leftEqualToView(self.courseIcon)
    .heightIs(35);
    [self.fenShuLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    self.fenLabel.sd_layout
    .bottomEqualToView(self.fenShuLabel).offset(-5)
    .leftSpaceToView(self.fenShuLabel, 4)
    .widthIs(30)
    .heightIs(23);
    
    self.tipLabel.sd_layout
    .topSpaceToView(self.fenShuLabel, 5)
    .leftEqualToView(self.fenShuLabel)
    .rightEqualToView(self.courseNameLabel)
    .heightIs(16);
    
    
    self.keJianXueXiView.sd_layout
    .topSpaceToView(self.mainScrollView, 25)
    .leftSpaceToView(self.mainScrollView, 16)
    .widthIs(_kpw(160))
    .heightIs(77);
    [self.keJianXueXiView updateLayout];

    
    self.pingShiZuoYeView.sd_layout
    .centerYEqualToView(self.keJianXueXiView)
    .rightSpaceToView(self.mainScrollView, 16)
    .widthRatioToView(self.keJianXueXiView, 1)
    .heightRatioToView(self.keJianXueXiView, 1);
    [self.pingShiZuoYeView updateLayout];
    
    self.xueXiBiaoXianView.sd_layout
    .topSpaceToView(self.keJianXueXiView, 16)
    .leftEqualToView(self.keJianXueXiView)
    .widthRatioToView(self.keJianXueXiView, 1)
    .heightRatioToView(self.keJianXueXiView, 1);
    [self.xueXiBiaoXianView updateLayout];
    
    self.qiMoKaoShiView.sd_layout
    .centerYEqualToView(self.xueXiBiaoXianView)
    .rightEqualToView(self.pingShiZuoYeView)
    .widthRatioToView(self.keJianXueXiView, 1)
    .heightRatioToView(self.keJianXueXiView, 1);
    [self.qiMoKaoShiView updateLayout];
    
    
    // 渐变
    [self.keJianXueXiView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0xFFFFFF, 0.3) endColor:COLOR_WITH_ALPHA(0xFFFFFF, 0.8)];
    // 模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *keJianXueXiVisualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    keJianXueXiVisualView.clipsToBounds = YES;
    keJianXueXiVisualView.layer.cornerRadius = 6;
    keJianXueXiVisualView.frame = self.keJianXueXiView.bounds;
    [self.keJianXueXiView addSubview:keJianXueXiVisualView];
    [self.keJianXueXiView insertSubview:keJianXueXiVisualView belowSubview:self.keJianXueXiIcon];
    
    // 渐变
    [self.pingShiZuoYeView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0xFFFFFF, 0.3) endColor:COLOR_WITH_ALPHA(0xFFFFFF, 0.8)];
    UIVisualEffectView *pingShiZuoYeVisualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    pingShiZuoYeVisualView.clipsToBounds = YES;
    pingShiZuoYeVisualView.layer.cornerRadius = 6;
    pingShiZuoYeVisualView.frame = self.pingShiZuoYeView.bounds;
    [self.pingShiZuoYeView addSubview:pingShiZuoYeVisualView];
    [self.pingShiZuoYeView insertSubview:pingShiZuoYeVisualView belowSubview:self.pingShiZuoYeIcon];
    
    // 渐变
    [self.xueXiBiaoXianView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0xFFFFFF, 0.3) endColor:COLOR_WITH_ALPHA(0xFFFFFF, 0.8)];
    UIVisualEffectView *xueXiBiaoXianVisualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    xueXiBiaoXianVisualView.clipsToBounds = YES;
    xueXiBiaoXianVisualView.layer.cornerRadius = 6;
    xueXiBiaoXianVisualView.frame = self.xueXiBiaoXianView.bounds;
    [self.xueXiBiaoXianView addSubview:xueXiBiaoXianVisualView];
    [self.xueXiBiaoXianView insertSubview:xueXiBiaoXianVisualView belowSubview:self.xueXiBiaoXianIcon];
    
    // 渐变
    [self.qiMoKaoShiView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0xFFFFFF, 0.3) endColor:COLOR_WITH_ALPHA(0xFFFFFF, 0.8)];
    UIVisualEffectView *qiMoKaoShiVisualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    qiMoKaoShiVisualView.clipsToBounds = YES;
    qiMoKaoShiVisualView.layer.cornerRadius = 6;
    qiMoKaoShiVisualView.frame = self.qiMoKaoShiView.bounds;
    [self.qiMoKaoShiView addSubview:qiMoKaoShiVisualView];
    [self.qiMoKaoShiView insertSubview:qiMoKaoShiVisualView belowSubview:self.qiMoKaoShiIcon];
    
    
    self.keJianXueXiIcon.sd_layout
    .centerYEqualToView(self.keJianXueXiView)
    .leftSpaceToView(self.keJianXueXiView, 20)
    .widthIs(27)
    .heightEqualToWidth();
    
    self.keJianXueXiNameLabel.sd_layout
    .bottomSpaceToView(self.keJianXueXiView, 16)
    .rightSpaceToView(self.keJianXueXiView, 14)
    .widthIs(60)
    .heightIs(18);
    
    self.keJianXueXiBFB.sd_layout
    .bottomSpaceToView(self.keJianXueXiNameLabel, 3)
    .rightSpaceToView(self.keJianXueXiView, 16)
    .widthRatioToView(self.keJianXueXiNameLabel, 1)
    .heightIs(21);
    
    
    self.pingShiZuoYeIcon.sd_layout
    .centerYEqualToView(self.pingShiZuoYeView)
    .leftSpaceToView(self.pingShiZuoYeView, 20)
    .widthRatioToView(self.keJianXueXiIcon, 1)
    .heightRatioToView(self.keJianXueXiIcon, 1);
    
    self.pingShiZuoYeNameLabel.sd_layout
    .bottomSpaceToView(self.pingShiZuoYeView, 16)
    .rightSpaceToView(self.pingShiZuoYeView, 14)
    .widthRatioToView(self.keJianXueXiNameLabel, 1)
    .heightRatioToView(self.keJianXueXiNameLabel, 1);
    
    self.pingShiZuoYeBFB.sd_layout
    .bottomSpaceToView(self.pingShiZuoYeNameLabel, 3)
    .rightSpaceToView(self.pingShiZuoYeView, 16)
    .widthRatioToView(self.keJianXueXiNameLabel, 1)
    .heightRatioToView(self.keJianXueXiBFB, 1);
    
    self.xueXiBiaoXianIcon.sd_layout
    .centerYEqualToView(self.xueXiBiaoXianView)
    .leftSpaceToView(self.xueXiBiaoXianView, 20)
    .widthRatioToView(self.keJianXueXiIcon, 1)
    .heightRatioToView(self.keJianXueXiIcon, 1);
    
    self.xueXiBiaoXianNameLabel.sd_layout
    .bottomSpaceToView(self.xueXiBiaoXianView, 16)
    .rightSpaceToView(self.xueXiBiaoXianView, 14)
    .widthRatioToView(self.keJianXueXiNameLabel, 1)
    .heightRatioToView(self.keJianXueXiNameLabel, 1);
    
    self.xueXiBiaoXianBFB.sd_layout
    .bottomSpaceToView(self.xueXiBiaoXianNameLabel, 3)
    .rightSpaceToView(self.xueXiBiaoXianView, 16)
    .widthRatioToView(self.keJianXueXiNameLabel, 1)
    .heightRatioToView(self.keJianXueXiBFB, 1);
    
    self.qiMoKaoShiIcon.sd_layout
    .centerYEqualToView(self.qiMoKaoShiView)
    .leftSpaceToView(self.qiMoKaoShiView, 20)
    .widthRatioToView(self.keJianXueXiIcon, 1)
    .heightRatioToView(self.keJianXueXiIcon, 1);
    
    self.qiMoKaoShiNameLabel.sd_layout
    .bottomSpaceToView(self.qiMoKaoShiView, 16)
    .rightSpaceToView(self.qiMoKaoShiView, 14)
    .widthRatioToView(self.keJianXueXiNameLabel, 1)
    .heightRatioToView(self.keJianXueXiNameLabel, 1);
    
    self.qiMoKaoShiBFB.sd_layout
    .bottomSpaceToView(self.qiMoKaoShiNameLabel, 3)
    .rightSpaceToView(self.qiMoKaoShiView, 16)
    .widthRatioToView(self.keJianXueXiNameLabel, 1)
    .heightRatioToView(self.keJianXueXiBFB, 1);
    
    self.detailsContainerView.sd_layout
    .topSpaceToView(self.xueXiBiaoXianView, 20)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    
    self.detailsTitleLabel.sd_layout
    .topSpaceToView(self.detailsContainerView, 16)
    .leftSpaceToView(self.detailsContainerView, 16)
    .rightSpaceToView(self.detailsContainerView, 16)
    .heightIs(21);
    
    self.keJianXueXiTitleLabel.sd_layout
    .topSpaceToView(self.detailsTitleLabel, 16)
    .leftEqualToView(self.detailsTitleLabel)
    .widthIs(70)
    .heightIs(21);
    
    self.keJianXueXiDeFenLabel.sd_layout
    .centerYEqualToView(self.keJianXueXiTitleLabel)
    .rightSpaceToView(self.detailsContainerView, 16)
    .widthIs(80)
    .heightIs(21);
    
    self.xueXiBiaoXianTitleLabel.sd_layout
    .topSpaceToView(self.keJianXueXiTitleLabel, 16)
    .leftEqualToView(self.keJianXueXiTitleLabel)
    .widthRatioToView(self.keJianXueXiTitleLabel, 1)
    .heightRatioToView(self.keJianXueXiTitleLabel, 1);
    
    self.xueXiBiaoXianDeFenLabel.sd_layout
    .centerYEqualToView(self.xueXiBiaoXianTitleLabel)
    .rightEqualToView(self.keJianXueXiDeFenLabel)
    .widthRatioToView(self.keJianXueXiDeFenLabel, 1)
    .heightRatioToView(self.keJianXueXiDeFenLabel, 1);
    
    self.pingShiZuoYeTitleLabel.sd_layout
    .topSpaceToView(self.xueXiBiaoXianTitleLabel, 16)
    .leftEqualToView(self.keJianXueXiTitleLabel)
    .widthRatioToView(self.keJianXueXiTitleLabel, 1)
    .heightRatioToView(self.keJianXueXiTitleLabel, 1);
    
    self.pingShiZuoYeDeFenLabel.sd_layout
    .centerYEqualToView(self.pingShiZuoYeTitleLabel)
    .rightEqualToView(self.keJianXueXiDeFenLabel)
    .widthRatioToView(self.keJianXueXiDeFenLabel, 1)
    .heightRatioToView(self.keJianXueXiDeFenLabel, 1);
    
    self.qiMoKaoShiTitleLabel.sd_layout
    .topSpaceToView(self.pingShiZuoYeTitleLabel, 16)
    .leftEqualToView(self.keJianXueXiTitleLabel)
    .widthRatioToView(self.keJianXueXiTitleLabel, 1)
    .heightRatioToView(self.keJianXueXiTitleLabel, 1);
    
    self.qiMoKaoShiDeFenLabel.sd_layout
    .centerYEqualToView(self.qiMoKaoShiTitleLabel)
    .rightEqualToView(self.keJianXueXiDeFenLabel)
    .widthRatioToView(self.keJianXueXiDeFenLabel, 1)
    .heightRatioToView(self.keJianXueXiDeFenLabel, 1);
    
    [self.detailsContainerView setupAutoHeightWithBottomView:self.qiMoKaoShiTitleLabel bottomMargin:16];
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.detailsContainerView bottomMargin:50];
    
}



#pragma mark - LazyLoad
-(UIImageView *)topBgImageView{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.clipsToBounds = YES;
        _topBgImageView.userInteractionEnabled = YES;
        _topBgImageView.image = [UIImage imageNamed:@"scoretop_bg"];
    }
    return _topBgImageView;
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navi_blackback"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _titleLabel.text = @"成绩详情";
    }
    return _titleLabel;
}

- (UIImageView *)courseIcon{
    if (!_courseIcon) {
        _courseIcon = [[UIImageView alloc] init];
        _courseIcon.image = [UIImage imageNamed:@"wang_icon"];
    }
    return _courseIcon;
}

- (UIImageView *)deFenIcon{
    if (!_deFenIcon) {
        _deFenIcon = [[UIImageView alloc] init];
        _deFenIcon.image = [UIImage imageNamed:@"defen_icon"];
    }
    return _deFenIcon;
}

- (UILabel *)courseNameLabel{
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
        _courseNameLabel.font = HXBoldFont(13);
        _courseNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _courseNameLabel.text = @"计算机科学与技术";
    }
    return _courseNameLabel;
}


-(UILabel *)fenShuLabel{
    if (!_fenShuLabel) {
        _fenShuLabel = [[UILabel alloc] init];
        _fenShuLabel.textAlignment = NSTextAlignmentLeft;
        _fenShuLabel.font = [UIFont fontWithName: @"Verdana-Bold"  size:30];
        _fenShuLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _fenShuLabel.text = @"64";
    }
    return _fenShuLabel;
}

-(UILabel *)fenLabel{
    if (!_fenLabel) {
        _fenLabel = [[UILabel alloc] init];
        _fenLabel.textAlignment = NSTextAlignmentLeft;
        _fenLabel.font = HXFont(16);
        _fenLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _fenLabel.text = @"分";
    }
    return _fenLabel;
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.font = HXFont(11);
        _tipLabel.textColor =COLOR_WITH_ALPHA(0x999999, 1);
        _tipLabel.text = @"总分由各部分得分折合权重结算而来";
    }
    return _tipLabel;
}

-(UIImageView *)bottomBgImageView{
    if (!_bottomBgImageView) {
        _bottomBgImageView = [[UIImageView alloc] init];
        _bottomBgImageView.clipsToBounds = YES;
        _bottomBgImageView.userInteractionEnabled = YES;
        _bottomBgImageView.image = [UIImage imageNamed:@"scorebottom_bg"];
    }
    return _bottomBgImageView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.clearColor;
        _mainScrollView.showsVerticalScrollIndicator = NO;
    }
    return _mainScrollView;
}

-(UIView *)keJianXueXiView{
    if (!_keJianXueXiView) {
        _keJianXueXiView = [[UIView alloc] init];
        _keJianXueXiView.clipsToBounds = YES;
        _keJianXueXiView.layer.borderWidth = 1;
        _keJianXueXiView.layer.borderColor = UIColor.whiteColor.CGColor;
        _keJianXueXiView.backgroundColor = UIColor.clearColor;
        _keJianXueXiView.layer.cornerRadius = 6;
    }
    return _keJianXueXiView;
}

-(UIImageView *)keJianXueXiIcon{
    if (!_keJianXueXiIcon) {
        _keJianXueXiIcon = [[UIImageView alloc] init];
        _keJianXueXiIcon.userInteractionEnabled = YES;
        _keJianXueXiIcon.image = [UIImage imageNamed:@"kejianxuexi_icon"];
    }
    return _keJianXueXiIcon;
}

-(UILabel *)keJianXueXiBFB{
    if (!_keJianXueXiBFB) {
        _keJianXueXiBFB = [[UILabel alloc] init];
        _keJianXueXiBFB.textAlignment = NSTextAlignmentRight;
        _keJianXueXiBFB.font = HXBoldFont(18);
        _keJianXueXiBFB.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _keJianXueXiBFB.attributedText = [HXCommonUtil getAttributedStringWith:@"10" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:@"10%" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    }
    return _keJianXueXiBFB;
}

-(UILabel *)keJianXueXiNameLabel{
    if (!_keJianXueXiNameLabel) {
        _keJianXueXiNameLabel = [[UILabel alloc] init];
        _keJianXueXiNameLabel.textAlignment = NSTextAlignmentRight;
        _keJianXueXiNameLabel.font = HXFont(13);
        _keJianXueXiNameLabel.textColor =COLOR_WITH_ALPHA(0x666666, 1);
        _keJianXueXiNameLabel.text = @"课件学习";
    }
    return _keJianXueXiNameLabel;
}

-(UIView *)pingShiZuoYeView{
    if (!_pingShiZuoYeView) {
        _pingShiZuoYeView = [[UIView alloc] init];
        _pingShiZuoYeView.clipsToBounds = YES;
        _pingShiZuoYeView.layer.borderWidth = 1;
        _pingShiZuoYeView.layer.borderColor = UIColor.whiteColor.CGColor;
        _pingShiZuoYeView.backgroundColor = UIColor.clearColor;
        _pingShiZuoYeView.layer.cornerRadius = 6;
    }
    return _pingShiZuoYeView;
}

-(UIImageView *)pingShiZuoYeIcon{
    if (!_pingShiZuoYeIcon) {
        _pingShiZuoYeIcon = [[UIImageView alloc] init];
        _pingShiZuoYeIcon.userInteractionEnabled = YES;
        _pingShiZuoYeIcon.image = [UIImage imageNamed:@"scorepingshizuoye_icon"];
    }
    return _pingShiZuoYeIcon;
}

-(UILabel *)pingShiZuoYeBFB{
    if (!_pingShiZuoYeBFB) {
        _pingShiZuoYeBFB = [[UILabel alloc] init];
        _pingShiZuoYeBFB.textAlignment = NSTextAlignmentRight;
        _pingShiZuoYeBFB.font = HXBoldFont(18);
        _pingShiZuoYeBFB.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _pingShiZuoYeBFB.attributedText = [HXCommonUtil getAttributedStringWith:@"10" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:@"10%" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    }
    return _pingShiZuoYeBFB;
}

-(UILabel *)pingShiZuoYeNameLabel{
    if (!_pingShiZuoYeNameLabel) {
        _pingShiZuoYeNameLabel = [[UILabel alloc] init];
        _pingShiZuoYeNameLabel.textAlignment = NSTextAlignmentRight;
        _pingShiZuoYeNameLabel.font = HXFont(13);
        _pingShiZuoYeNameLabel.textColor =COLOR_WITH_ALPHA(0x666666, 1);
        _pingShiZuoYeNameLabel.text = @"平时作业";
    }
    return _pingShiZuoYeNameLabel;
}

-(UIView *)xueXiBiaoXianView{
    if (!_xueXiBiaoXianView) {
        _xueXiBiaoXianView = [[UIView alloc] init];
        _xueXiBiaoXianView.clipsToBounds = YES;
        _xueXiBiaoXianView.layer.borderWidth = 1;
        _xueXiBiaoXianView.layer.borderColor = UIColor.whiteColor.CGColor;
        _xueXiBiaoXianView.backgroundColor = UIColor.clearColor;
        _xueXiBiaoXianView.layer.cornerRadius = 6;
    }
    return _xueXiBiaoXianView;
}

-(UIImageView *)xueXiBiaoXianIcon{
    if (!_xueXiBiaoXianIcon) {
        _xueXiBiaoXianIcon = [[UIImageView alloc] init];
        _xueXiBiaoXianIcon.userInteractionEnabled = YES;
        _xueXiBiaoXianIcon.image = [UIImage imageNamed:@"xuexibiaoxian_icon"];
    }
    return _xueXiBiaoXianIcon;
}

-(UILabel *)xueXiBiaoXianBFB{
    if (!_xueXiBiaoXianBFB) {
        _xueXiBiaoXianBFB = [[UILabel alloc] init];
        _xueXiBiaoXianBFB.textAlignment = NSTextAlignmentRight;
        _xueXiBiaoXianBFB.font = HXBoldFont(18);
        _xueXiBiaoXianBFB.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _xueXiBiaoXianBFB.attributedText = [HXCommonUtil getAttributedStringWith:@"0" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:@"0%" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    }
    return _xueXiBiaoXianBFB;
}

-(UILabel *)xueXiBiaoXianNameLabel{
    if (!_xueXiBiaoXianNameLabel) {
        _xueXiBiaoXianNameLabel = [[UILabel alloc] init];
        _xueXiBiaoXianNameLabel.textAlignment = NSTextAlignmentRight;
        _xueXiBiaoXianNameLabel.font = HXFont(13);
        _xueXiBiaoXianNameLabel.textColor =COLOR_WITH_ALPHA(0x666666, 1);
        _xueXiBiaoXianNameLabel.text = @"学习表现";
    }
    return _xueXiBiaoXianNameLabel;
}

-(UIView *)qiMoKaoShiView{
    if (!_qiMoKaoShiView) {
        _qiMoKaoShiView = [[UIView alloc] init];
        _qiMoKaoShiView.clipsToBounds = YES;
        _qiMoKaoShiView.layer.borderWidth = 1;
        _qiMoKaoShiView.layer.borderColor = UIColor.whiteColor.CGColor;
        _qiMoKaoShiView.backgroundColor = UIColor.clearColor;
        _qiMoKaoShiView.layer.cornerRadius = 6;
    }
    return _qiMoKaoShiView;
}

-(UIImageView *)qiMoKaoShiIcon{
    if (!_qiMoKaoShiIcon) {
        _qiMoKaoShiIcon = [[UIImageView alloc] init];
        _qiMoKaoShiIcon.userInteractionEnabled = YES;
        _qiMoKaoShiIcon.image = [UIImage imageNamed:@"qimokaoshi_icon"];
    }
    return _qiMoKaoShiIcon;
}

-(UILabel *)qiMoKaoShiBFB{
    if (!_qiMoKaoShiBFB) {
        _qiMoKaoShiBFB = [[UILabel alloc] init];
        _qiMoKaoShiBFB.textAlignment = NSTextAlignmentRight;
        _qiMoKaoShiBFB.font = HXBoldFont(18);
        _qiMoKaoShiBFB.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _qiMoKaoShiBFB.attributedText = [HXCommonUtil getAttributedStringWith:@"0" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:@"0%" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    }
    return _qiMoKaoShiBFB;
}

-(UILabel *)qiMoKaoShiNameLabel{
    if (!_qiMoKaoShiNameLabel) {
        _qiMoKaoShiNameLabel = [[UILabel alloc] init];
        _qiMoKaoShiNameLabel.textAlignment = NSTextAlignmentRight;
        _qiMoKaoShiNameLabel.font = HXFont(13);
        _qiMoKaoShiNameLabel.textColor =COLOR_WITH_ALPHA(0x666666, 1);
        _qiMoKaoShiNameLabel.text = @"期末考试";
    }
    return _qiMoKaoShiNameLabel;
}

-(UIView *)detailsContainerView{
    if (!_detailsContainerView) {
        _detailsContainerView = [[UIView alloc] init];
        _detailsContainerView.clipsToBounds = YES;
        _detailsContainerView.backgroundColor = UIColor.whiteColor;
        _detailsContainerView.layer.cornerRadius = 6;
    }
    return _detailsContainerView;
}

-(UILabel *)detailsTitleLabel{
    if (!_detailsTitleLabel) {
        _detailsTitleLabel = [[UILabel alloc] init];
        _detailsTitleLabel.textAlignment = NSTextAlignmentLeft;
        _detailsTitleLabel.font = HXBoldFont(15);
        _detailsTitleLabel.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _detailsTitleLabel.text = @"成绩详情";
    }
    return _detailsTitleLabel;
}

-(UILabel *)keJianXueXiTitleLabel{
    if (!_keJianXueXiTitleLabel) {
        _keJianXueXiTitleLabel = [[UILabel alloc] init];
        _keJianXueXiTitleLabel.textAlignment = NSTextAlignmentLeft;
        _keJianXueXiTitleLabel.font = HXFont(15);
        _keJianXueXiTitleLabel.textColor =COLOR_WITH_ALPHA(0x999999, 1);
        _keJianXueXiTitleLabel.text = @"课件学习";
    }
    return _keJianXueXiTitleLabel;
}

-(UILabel *)keJianXueXiDeFenLabel{
    if (!_keJianXueXiDeFenLabel) {
        _keJianXueXiDeFenLabel = [[UILabel alloc] init];
        _keJianXueXiDeFenLabel.textAlignment = NSTextAlignmentRight;
        _keJianXueXiDeFenLabel.font = HXBoldFont(15);
        _keJianXueXiDeFenLabel.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _keJianXueXiDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"88" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:@"88分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    }
    return _keJianXueXiDeFenLabel;
}

-(UILabel *)xueXiBiaoXianTitleLabel{
    if (!_xueXiBiaoXianTitleLabel) {
        _xueXiBiaoXianTitleLabel = [[UILabel alloc] init];
        _xueXiBiaoXianTitleLabel.textAlignment = NSTextAlignmentLeft;
        _xueXiBiaoXianTitleLabel.font = HXFont(15);
        _xueXiBiaoXianTitleLabel.textColor =COLOR_WITH_ALPHA(0x999999, 1);
        _xueXiBiaoXianTitleLabel.text = @"学习表现";
    }
    return _xueXiBiaoXianTitleLabel;
}

-(UILabel *)xueXiBiaoXianDeFenLabel{
    if (!_xueXiBiaoXianDeFenLabel) {
        _xueXiBiaoXianDeFenLabel = [[UILabel alloc] init];
        _xueXiBiaoXianDeFenLabel.textAlignment = NSTextAlignmentRight;
        _xueXiBiaoXianDeFenLabel.font = HXBoldFont(15);
        _xueXiBiaoXianDeFenLabel.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _xueXiBiaoXianDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"88" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:@"88分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    }
    return _xueXiBiaoXianDeFenLabel;
}

-(UILabel *)pingShiZuoYeTitleLabel{
    if (!_pingShiZuoYeTitleLabel) {
        _pingShiZuoYeTitleLabel = [[UILabel alloc] init];
        _pingShiZuoYeTitleLabel.textAlignment = NSTextAlignmentLeft;
        _pingShiZuoYeTitleLabel.font = HXFont(15);
        _pingShiZuoYeTitleLabel.textColor =COLOR_WITH_ALPHA(0x999999, 1);
        _pingShiZuoYeTitleLabel.text = @"平时作业";
    }
    return _pingShiZuoYeTitleLabel;
}

-(UILabel *)pingShiZuoYeDeFenLabel{
    if (!_pingShiZuoYeDeFenLabel) {
        _pingShiZuoYeDeFenLabel = [[UILabel alloc] init];
        _pingShiZuoYeDeFenLabel.textAlignment = NSTextAlignmentRight;
        _pingShiZuoYeDeFenLabel.font = HXBoldFont(15);
        _pingShiZuoYeDeFenLabel.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _pingShiZuoYeDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"88" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:@"88分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    }
    return _pingShiZuoYeDeFenLabel;
}

-(UILabel *)qiMoKaoShiTitleLabel{
    if (!_qiMoKaoShiTitleLabel) {
        _qiMoKaoShiTitleLabel = [[UILabel alloc] init];
        _qiMoKaoShiTitleLabel.textAlignment = NSTextAlignmentLeft;
        _qiMoKaoShiTitleLabel.font = HXFont(15);
        _qiMoKaoShiTitleLabel.textColor =COLOR_WITH_ALPHA(0x999999, 1);
        _qiMoKaoShiTitleLabel.text = @"期末考试";
    }
    return _qiMoKaoShiTitleLabel;
}

-(UILabel *)qiMoKaoShiDeFenLabel{
    if (!_qiMoKaoShiDeFenLabel) {
        _qiMoKaoShiDeFenLabel = [[UILabel alloc] init];
        _qiMoKaoShiDeFenLabel.textAlignment = NSTextAlignmentRight;
        _qiMoKaoShiDeFenLabel.font = HXBoldFont(15);
        _qiMoKaoShiDeFenLabel.textColor =COLOR_WITH_ALPHA(0x333333, 1);
        _qiMoKaoShiDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"88" needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:@"88分" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    }
    return _qiMoKaoShiDeFenLabel;
}




@end
