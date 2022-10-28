//
//  HXScoreDetailsViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/7.
//

#import "HXScoreDetailsViewController.h"
#import "UIView+TransitionColor.h"
#import "HXScoreDetailModel.h"

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


@property(nonatomic,strong) UIView *middleContainerView;
@property(nonatomic,strong) NSMutableArray *middleViews;
@property(nonatomic,strong) UIView *lastBottomView;
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

@property(nonatomic,strong) UIView *keJianXueXiContainerView;
@property(nonatomic,strong) UILabel *keJianXueXiTitleLabel;
@property(nonatomic,strong) UILabel *keJianXueXiDeFenLabel;

@property(nonatomic,strong) UIView *pingShiZuoYeContainerView;
@property(nonatomic,strong) UILabel *pingShiZuoYeTitleLabel;
@property(nonatomic,strong) UILabel *pingShiZuoYeDeFenLabel;

@property(nonatomic,strong) UIView *xueXiBiaoXianContainerView;
@property(nonatomic,strong) UILabel *xueXiBiaoXianTitleLabel;
@property(nonatomic,strong) UILabel *xueXiBiaoXianDeFenLabel;

@property(nonatomic,strong) UIView *qiMoKaoShiContainerView;
@property(nonatomic,strong) UILabel *qiMoKaoShiTitleLabel;
@property(nonatomic,strong) UILabel *qiMoKaoShiDeFenLabel;

@property(nonatomic,strong) UIView *bukaoContainerView;
@property(nonatomic,strong) UILabel *bukaoTitleLabel;
@property(nonatomic,strong) UILabel *bukaoDeFenLabel;



@property(nonatomic,strong) HXScoreDetailModel *scoreDetailModel;

@end

@implementation HXScoreDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    //获取成绩详情
    [self getZKScoreDetail];
    
}

-(void)dealloc{
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

#pragma mark - 获取成绩详情
-(void)getZKScoreDetail{
    
    NSDictionary *dic =@{
        @"studentid":HXSafeString(self.scoreModel.studentID),
        @"termCourseid":HXSafeString(self.scoreModel.termCourseID)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetZKScoreDetail needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainScrollView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.scoreDetailModel = [HXScoreDetailModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            //刷新UI
            [self refreshUI];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainScrollView.mj_header endRefreshing];
    }];
    
}



#pragma mark - Event
-(void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

 
#pragma mark - 刷新UI
-(void)refreshUI{
    
    if (self.scoreDetailModel.isNetCourse) {
        self.courseIcon.sd_layout.widthIs(16);
        self.courseNameLabel.sd_layout.leftSpaceToView(self.courseIcon, 4);
    }else{
        self.courseIcon.sd_layout.widthIs(0);
        self.courseNameLabel.sd_layout.leftSpaceToView(self.courseIcon, 0);
    }

    [self.middleViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
   
   
    if (self.scoreDetailModel.selfRate==0) {
        [self.middleViews removeObject:self.keJianXueXiView];
    }

    if (self.scoreDetailModel.timeRate==0) {
        [self.middleViews removeObject:self.pingShiZuoYeView];
    }

    if (self.scoreDetailModel.workRate==0) {
        [self.middleViews removeObject:self.xueXiBiaoXianView];
    }

    if (self.scoreDetailModel.examRate==0) {
        [self.middleViews removeObject:self.qiMoKaoShiView];
    }
    
    [self.middleContainerView sd_addSubviews:self.middleViews];
    
    __block UIView *lastView = [UIView new];;
    [self.middleViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sd_layout
        .topSpaceToView(self.middleContainerView, (idx/2)*(16+77))
        .leftSpaceToView(self.middleContainerView, (_kpw(160)+(kScreenWidth-32-_kpw(160)*2))*(idx%2))
        .widthIs(_kpw(160))
        .heightIs(77);
        if (idx==self.middleViews.count-1) {
            lastView = obj;
        }
    }];
    
    [self.middleContainerView setupAutoHeightWithBottomViewsArray:@[self.lastBottomView,lastView] bottomMargin:0];
    
    self.keJianXueXiContainerView.sd_layout.heightIs((self.scoreDetailModel.selfRate >0?40:0));
    self.xueXiBiaoXianContainerView.sd_layout.heightIs((self.scoreDetailModel.workRate >0?40:0));
    self.pingShiZuoYeContainerView.sd_layout.heightIs((self.scoreDetailModel.timeRate>0?40:0));
    self.qiMoKaoShiContainerView.sd_layout.heightIs((self.scoreDetailModel.examRate>0?40:0));
    self.bukaoContainerView.sd_layout.heightIs((self.scoreDetailModel.addTestScore>0?40:0));

    
    self.courseNameLabel.text = self.scoreDetailModel.termCourseName;
    
    self.fenShuLabel.text = HXFloatToString(self.scoreDetailModel.showScore);
    
    
    self.keJianXueXiBFB.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.selfRate) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:[HXFloatToString(self.scoreDetailModel.selfRate) stringByAppendingString:@"%"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];

    
    self.pingShiZuoYeBFB.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.timeRate) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:[HXFloatToString(self.scoreDetailModel.timeRate) stringByAppendingString:@"%"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];

    
    self.xueXiBiaoXianBFB.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.workRate) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:[HXFloatToString(self.scoreDetailModel.workRate) stringByAppendingString:@"%"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];

    
    self.qiMoKaoShiBFB.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.examRate) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} content:[HXFloatToString(self.scoreDetailModel.examRate) stringByAppendingString:@"%"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x666666, 1),NSFontAttributeName:[UIFont systemFontOfSize:12]}];

    self.keJianXueXiDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.selfScore) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:[HXFloatToString(self.scoreDetailModel.selfScore) stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];

    self.xueXiBiaoXianDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.workScore) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:[HXFloatToString(self.scoreDetailModel.workScore) stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];

    self.pingShiZuoYeDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.timeScore) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:[HXFloatToString(self.scoreDetailModel.timeScore) stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];

    self.qiMoKaoShiDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.examScore) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:[HXFloatToString(self.scoreDetailModel.examScore) stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];

    self.bukaoDeFenLabel.attributedText = [HXCommonUtil getAttributedStringWith:HXFloatToString(self.scoreDetailModel.addTestScore) needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} content:[HXFloatToString(self.scoreDetailModel.addTestScore) stringByAppendingString:@"分"] defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont systemFontOfSize:10]}];
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
    
    [self.mainScrollView addSubview:self.middleContainerView];
    [self.mainScrollView addSubview:self.lastBottomView];
    
    [self.middleViews addObjectsFromArray:@[self.keJianXueXiView,self.pingShiZuoYeView,self.xueXiBiaoXianView,self.qiMoKaoShiView]];
    [self.middleContainerView sd_addSubviews:self.middleViews];
    

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
    
    [self.mainScrollView addSubview:self.detailsContainerView];
    
    [self.detailsContainerView addSubview:self.detailsTitleLabel];
    
    [self.detailsContainerView addSubview:self.keJianXueXiContainerView];
    [self.keJianXueXiContainerView addSubview:self.keJianXueXiTitleLabel];
    [self.keJianXueXiContainerView addSubview:self.keJianXueXiDeFenLabel];
    
    [self.detailsContainerView addSubview:self.xueXiBiaoXianContainerView];
    [self.xueXiBiaoXianContainerView addSubview:self.xueXiBiaoXianTitleLabel];
    [self.xueXiBiaoXianContainerView addSubview:self.xueXiBiaoXianDeFenLabel];
    
    [self.detailsContainerView addSubview:self.pingShiZuoYeContainerView];
    [self.pingShiZuoYeContainerView addSubview:self.pingShiZuoYeTitleLabel];
    [self.pingShiZuoYeContainerView addSubview:self.pingShiZuoYeDeFenLabel];
    
    [self.detailsContainerView addSubview:self.qiMoKaoShiContainerView];
    [self.qiMoKaoShiContainerView addSubview:self.qiMoKaoShiTitleLabel];
    [self.qiMoKaoShiContainerView addSubview:self.qiMoKaoShiDeFenLabel];
    
    [self.detailsContainerView addSubview:self.bukaoContainerView];
    [self.bukaoContainerView addSubview:self.bukaoTitleLabel];
    [self.bukaoContainerView addSubview:self.bukaoDeFenLabel];
    
    
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
    .heightIs(16);
    
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
    .bottomEqualToView(self.fenShuLabel).offset(-2)
    .leftSpaceToView(self.fenShuLabel, 4)
    .widthIs(30)
    .heightIs(23);
    
    self.tipLabel.sd_layout
    .topSpaceToView(self.fenShuLabel, 5)
    .leftEqualToView(self.courseIcon)
    .rightEqualToView(self.courseNameLabel)
    .autoHeightRatio(0);
    
    self.middleContainerView.sd_layout
    .topSpaceToView(self.mainScrollView, 25)
    .leftSpaceToView(self.mainScrollView, 16)
    .rightSpaceToView(self.mainScrollView, 16);

    self.lastBottomView.sd_layout
    .topEqualToView(self.middleContainerView)
    .leftEqualToView(self.middleContainerView)
    .rightEqualToView(self.middleContainerView)
    .heightIs(0);
    
    __block UIView *lastView = [UIView new];
    [self.middleViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sd_layout
        .topSpaceToView(self.middleContainerView, (idx/2)*(16+77))
        .leftSpaceToView(self.middleContainerView, (_kpw(160)+(kScreenWidth-32-_kpw(160)*2))*(idx%2))
        .widthIs(_kpw(160))
        .heightIs(77);
        if (idx==self.middleViews.count-1) {
            lastView = obj;
        }
    }];
    
    [self.middleContainerView setupAutoHeightWithBottomViewsArray:@[self.lastBottomView,lastView] bottomMargin:0];
    [self.middleContainerView updateLayout];
   
    // 模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    // 渐变
    [self.keJianXueXiView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0xFFFFFF, 0.3) endColor:COLOR_WITH_ALPHA(0xFFFFFF, 0.8)];
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
    .widthIs(27)
    .heightEqualToWidth();
    
    self.pingShiZuoYeNameLabel.sd_layout
    .bottomSpaceToView(self.pingShiZuoYeView, 16)
    .rightSpaceToView(self.pingShiZuoYeView, 14)
    .widthIs(60)
    .heightIs(18);
    
    self.pingShiZuoYeBFB.sd_layout
    .bottomSpaceToView(self.pingShiZuoYeNameLabel, 3)
    .rightSpaceToView(self.pingShiZuoYeView, 16)
    .widthRatioToView(self.pingShiZuoYeNameLabel, 1)
    .heightIs(21);
    
   
    
    self.xueXiBiaoXianIcon.sd_layout
    .centerYEqualToView(self.xueXiBiaoXianView)
    .leftSpaceToView(self.xueXiBiaoXianView, 20)
    .widthIs(27)
    .heightEqualToWidth();
    
    self.xueXiBiaoXianNameLabel.sd_layout
    .bottomSpaceToView(self.xueXiBiaoXianView, 16)
    .rightSpaceToView(self.xueXiBiaoXianView, 14)
    .widthIs(60)
    .heightIs(18);
    
    self.xueXiBiaoXianBFB.sd_layout
    .bottomSpaceToView(self.xueXiBiaoXianNameLabel, 3)
    .rightSpaceToView(self.xueXiBiaoXianView, 16)
    .widthRatioToView(self.xueXiBiaoXianNameLabel, 1)
    .heightIs(21);
    
    
    
    self.qiMoKaoShiIcon.sd_layout
    .centerYEqualToView(self.qiMoKaoShiView)
    .leftSpaceToView(self.qiMoKaoShiView, 20)
    .widthIs(27)
    .heightEqualToWidth();
    
    self.qiMoKaoShiNameLabel.sd_layout
    .bottomSpaceToView(self.qiMoKaoShiView, 16)
    .rightSpaceToView(self.qiMoKaoShiView, 14)
    .widthIs(60)
    .heightIs(18);
    
    self.qiMoKaoShiBFB.sd_layout
    .bottomSpaceToView(self.qiMoKaoShiNameLabel, 3)
    .rightSpaceToView(self.qiMoKaoShiView, 16)
    .widthRatioToView(self.qiMoKaoShiNameLabel, 1)
    .heightIs(21);
    
   
    
    self.detailsContainerView.sd_layout
    .topSpaceToView(self.middleContainerView, 20)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    
    self.detailsTitleLabel.sd_layout
    .topSpaceToView(self.detailsContainerView, 10)
    .leftSpaceToView(self.detailsContainerView, 16)
    .rightSpaceToView(self.detailsContainerView, 16)
    .heightIs(40);
    
    self.keJianXueXiContainerView.sd_layout
    .topSpaceToView(self.detailsTitleLabel, 0)
    .leftEqualToView(self.detailsContainerView)
    .rightEqualToView(self.detailsContainerView)
    .heightIs(40);
    
    self.keJianXueXiTitleLabel.sd_layout
    .centerYEqualToView(self.keJianXueXiContainerView)
    .leftSpaceToView(self.keJianXueXiContainerView, 16)
    .widthIs(80)
    .heightIs(21);
    
    self.keJianXueXiDeFenLabel.sd_layout
    .centerYEqualToView(self.keJianXueXiContainerView)
    .rightSpaceToView(self.keJianXueXiContainerView, 16)
    .widthIs(80)
    .heightIs(21);
    
    self.xueXiBiaoXianContainerView.sd_layout
    .topSpaceToView(self.keJianXueXiContainerView, 0)
    .leftEqualToView(self.detailsContainerView)
    .rightEqualToView(self.detailsContainerView)
    .heightIs(40);
    
    self.xueXiBiaoXianTitleLabel.sd_layout
    .centerYEqualToView(self.xueXiBiaoXianContainerView)
    .leftSpaceToView(self.xueXiBiaoXianContainerView, 16)
    .widthRatioToView(self.keJianXueXiTitleLabel, 1)
    .heightRatioToView(self.keJianXueXiTitleLabel, 1);
    
    self.xueXiBiaoXianDeFenLabel.sd_layout
    .centerYEqualToView(self.xueXiBiaoXianContainerView)
    .rightSpaceToView(self.xueXiBiaoXianContainerView, 16)
    .widthRatioToView(self.keJianXueXiDeFenLabel, 1)
    .heightRatioToView(self.keJianXueXiDeFenLabel, 1);
    
    self.pingShiZuoYeContainerView.sd_layout
    .topSpaceToView(self.xueXiBiaoXianContainerView, 0)
    .leftEqualToView(self.detailsContainerView)
    .rightEqualToView(self.detailsContainerView)
    .heightIs(40);
    
    self.pingShiZuoYeTitleLabel.sd_layout
    .centerYEqualToView(self.pingShiZuoYeContainerView)
    .leftSpaceToView(self.pingShiZuoYeContainerView, 16)
    .widthRatioToView(self.keJianXueXiTitleLabel, 1)
    .heightRatioToView(self.keJianXueXiTitleLabel, 1);
    
    self.pingShiZuoYeDeFenLabel.sd_layout
    .centerYEqualToView(self.pingShiZuoYeContainerView)
    .rightSpaceToView(self.pingShiZuoYeContainerView, 16)
    .widthRatioToView(self.keJianXueXiDeFenLabel, 1)
    .heightRatioToView(self.keJianXueXiDeFenLabel, 1);
    
    self.qiMoKaoShiContainerView.sd_layout
    .topSpaceToView(self.pingShiZuoYeContainerView, 0)
    .leftEqualToView(self.detailsContainerView)
    .rightEqualToView(self.detailsContainerView)
    .heightIs(40);
    
    self.qiMoKaoShiTitleLabel.sd_layout
    .centerYEqualToView(self.qiMoKaoShiContainerView)
    .leftSpaceToView(self.qiMoKaoShiContainerView, 16)
    .widthRatioToView(self.keJianXueXiTitleLabel, 1)
    .heightRatioToView(self.keJianXueXiTitleLabel, 1);
    
    self.qiMoKaoShiDeFenLabel.sd_layout
    .centerYEqualToView(self.qiMoKaoShiContainerView)
    .rightSpaceToView(self.qiMoKaoShiContainerView, 16)
    .widthRatioToView(self.keJianXueXiDeFenLabel, 1)
    .heightRatioToView(self.keJianXueXiDeFenLabel, 1);
    
    
    self.bukaoContainerView.sd_layout
    .topSpaceToView(self.qiMoKaoShiContainerView, 0)
    .leftEqualToView(self.detailsContainerView)
    .rightEqualToView(self.detailsContainerView)
    .heightIs(40);
    
    self.bukaoTitleLabel.sd_layout
    .centerYEqualToView(self.bukaoContainerView)
    .leftSpaceToView(self.bukaoContainerView, 16)
    .widthRatioToView(self.keJianXueXiTitleLabel, 1)
    .heightRatioToView(self.keJianXueXiTitleLabel, 1);
    
    self.bukaoDeFenLabel.sd_layout
    .centerYEqualToView(self.bukaoContainerView)
    .rightSpaceToView(self.bukaoContainerView, 16)
    .widthRatioToView(self.keJianXueXiDeFenLabel, 1)
    .heightRatioToView(self.keJianXueXiDeFenLabel, 1);
    
    [self.detailsContainerView setupAutoHeightWithBottomView:self.bukaoContainerView bottomMargin:10];
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.detailsContainerView bottomMargin:50];
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getZKScoreDetail)];
    header.automaticallyChangeAlpha = YES;
    self.mainScrollView.mj_header = header;
    
}



#pragma mark - LazyLoad
-(NSMutableArray *)middleViews{
    if (!_middleViews) {
        _middleViews = [NSMutableArray array];
    }
    return _middleViews;
}
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
       
    }
    return _courseNameLabel;
}


-(UILabel *)fenShuLabel{
    if (!_fenShuLabel) {
        _fenShuLabel = [[UILabel alloc] init];
        _fenShuLabel.textAlignment = NSTextAlignmentLeft;
        _fenShuLabel.font = [UIFont fontWithName: @"Verdana-Bold"  size:30];
        _fenShuLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
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
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = @"总分由各部分得分折合权重结算而来\n最终成绩默认取最高分";
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

-(UIView *)middleContainerView{
    if (!_middleContainerView) {
        _middleContainerView = [[UIView alloc] init];
        _middleContainerView.clipsToBounds = YES;
        _middleContainerView.backgroundColor = UIColor.clearColor;
        
    }
    return _middleContainerView;
}

-(UIView *)lastBottomView{
    if (!_lastBottomView) {
        _lastBottomView = [[UIView alloc] init];
        _lastBottomView.clipsToBounds = YES;
        _lastBottomView.backgroundColor = UIColor.clearColor;
    }
    return _lastBottomView;
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
        _keJianXueXiBFB.isAttributedContent = YES;
        
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
        _pingShiZuoYeBFB.isAttributedContent = YES;
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
        _xueXiBiaoXianBFB.isAttributedContent = YES;
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
        _qiMoKaoShiBFB.isAttributedContent = YES;
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


-(UIView *)keJianXueXiContainerView{
    if (!_keJianXueXiContainerView) {
        _keJianXueXiContainerView = [[UIView alloc] init];
        _keJianXueXiContainerView.clipsToBounds = YES;
        _keJianXueXiContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _keJianXueXiContainerView;
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
    }
        
    return _keJianXueXiDeFenLabel;
}

-(UIView *)xueXiBiaoXianContainerView{
    if (!_xueXiBiaoXianContainerView) {
        _xueXiBiaoXianContainerView = [[UIView alloc] init];
        _xueXiBiaoXianContainerView.clipsToBounds = YES;
        _xueXiBiaoXianContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _xueXiBiaoXianContainerView;
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
       
    }
    return _xueXiBiaoXianDeFenLabel;
}

-(UIView *)pingShiZuoYeContainerView{
    if (!_pingShiZuoYeContainerView) {
        _pingShiZuoYeContainerView = [[UIView alloc] init];
        _pingShiZuoYeContainerView.clipsToBounds = YES;
        _pingShiZuoYeContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _pingShiZuoYeContainerView;
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
        
    }
    return _pingShiZuoYeDeFenLabel;
}


-(UIView *)qiMoKaoShiContainerView{
    if (!_qiMoKaoShiContainerView) {
        _qiMoKaoShiContainerView = [[UIView alloc] init];
        _qiMoKaoShiContainerView.clipsToBounds = YES;
        _qiMoKaoShiContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _qiMoKaoShiContainerView;
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
       
    }
    return _qiMoKaoShiDeFenLabel;
}


-(UIView *)bukaoContainerView{
    if (!_bukaoContainerView) {
        _bukaoContainerView = [[UIView alloc] init];
        _bukaoContainerView.clipsToBounds = YES;
        _bukaoContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _bukaoContainerView;
}
-(UILabel *)bukaoTitleLabel{
    if (!_bukaoTitleLabel) {
        _bukaoTitleLabel = [[UILabel alloc] init];
        _bukaoTitleLabel.textAlignment = NSTextAlignmentLeft;
        _bukaoTitleLabel.font = HXFont(15);
        _bukaoTitleLabel.textColor =COLOR_WITH_ALPHA(0x999999, 1);
        _bukaoTitleLabel.text = @"补考成绩";
    }
    return _bukaoTitleLabel;
}

-(UILabel *)bukaoDeFenLabel{
    if (!_bukaoDeFenLabel) {
        _bukaoDeFenLabel = [[UILabel alloc] init];
        _bukaoDeFenLabel.textAlignment = NSTextAlignmentRight;
        _bukaoDeFenLabel.font = HXBoldFont(15);
        _bukaoDeFenLabel.textColor =COLOR_WITH_ALPHA(0x333333, 1);
       
    }
    return _bukaoDeFenLabel;
}

@end
