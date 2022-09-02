//
//  HXStudyReportViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXStudyReportViewController.h"
#import "UIView+TransitionColor.h"
#import "HXStudyReportKeJianCell.h"

@interface HXStudyReportViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIImageView *topBgImageView;
@property(nonatomic,strong) UIButton *backBtn;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *fenShuLabel;
@property(nonatomic,strong) UILabel *fenLabel;
@property(nonatomic,strong) UILabel *tipLabel;

@property(nonatomic,strong) UIView *showContainerView;
//课件学习
@property(nonatomic,strong) UIView *keJianXueXiView;
@property(nonatomic,strong) UILabel *keJianXueTitleLabel;
@property(nonatomic,strong) UILabel *keJianXueContentLabel;
//平时作业
@property(nonatomic,strong) UIView *pingShiZuoYeView;
@property(nonatomic,strong) UILabel *pingShiZuoYeTitleLabel;
@property(nonatomic,strong) UILabel *pingShiZuoYeContentLabel;
//学习表现
@property(nonatomic,strong) UIView *xueXiBiaoXianView;
@property(nonatomic,strong) UILabel *xueXiBiaoXianTitleLabel;
@property(nonatomic,strong) UILabel *xueXiBiaoXianContentLabel;
//期末考试
@property(nonatomic,strong) UIView *qiMoKaoShiView;
@property(nonatomic,strong) UILabel *qiMoKaoShiTitleLabel;
@property(nonatomic,strong) UILabel *qiMoKaoShiContentLabel;

@property(nonatomic,strong) UITableView *mainTableView;

@end

@implementation HXStudyReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}

#pragma mark - Event
-(void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 178;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *studyReportKeJianCellIdentifier = @"HXStudyReportKeJianCellIdentifier";
    HXStudyReportKeJianCell *cell = [tableView dequeueReusableCellWithIdentifier:studyReportKeJianCellIdentifier];
    if (!cell) {
        cell = [[HXStudyReportKeJianCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studyReportKeJianCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
   
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.topBgImageView];
    [self.view addSubview:self.showContainerView];
    [self.topBgImageView addSubview:self.titleLabel];
    [self.topBgImageView addSubview:self.backBtn];
    [self.topBgImageView addSubview:self.fenShuLabel];
    [self.topBgImageView addSubview:self.fenLabel];
    [self.topBgImageView addSubview:self.tipLabel];
    
    [self.showContainerView addSubview:self.keJianXueXiView];
    [self.keJianXueXiView addSubview:self.keJianXueTitleLabel];
    [self.keJianXueXiView addSubview:self.keJianXueContentLabel];
    
    [self.showContainerView addSubview:self.pingShiZuoYeView];
    [self.pingShiZuoYeView addSubview:self.pingShiZuoYeTitleLabel];
    [self.pingShiZuoYeView addSubview:self.pingShiZuoYeContentLabel];
    
    [self.showContainerView addSubview:self.xueXiBiaoXianView];
    [self.xueXiBiaoXianView addSubview:self.xueXiBiaoXianTitleLabel];
    [self.xueXiBiaoXianView addSubview:self.xueXiBiaoXianContentLabel];
    
    [self.showContainerView addSubview:self.qiMoKaoShiView];
    [self.qiMoKaoShiView addSubview:self.qiMoKaoShiTitleLabel];
    [self.qiMoKaoShiView addSubview:self.qiMoKaoShiContentLabel];
    
    
    self.topBgImageView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(456*kScreenWidth/750.0);
    

    
    self.showContainerView.sd_layout
    .bottomEqualToView(self.topBgImageView).offset(0)
    .leftSpaceToView(self.view, 12)
    .rightSpaceToView(self.view, 12);
    
    
    
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.showContainerView, 0)
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
    
    self.fenShuLabel.sd_layout
    .topSpaceToView(self.titleLabel, 26)
    .leftSpaceToView(self.topBgImageView, 34)
    .heightIs(43);
    [self.fenShuLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    self.fenLabel.sd_layout
    .bottomEqualToView(self.fenShuLabel).offset(-5)
    .leftSpaceToView(self.fenShuLabel, 4)
    .widthIs(30)
    .heightIs(23);
    
    self.tipLabel.sd_layout
    .topSpaceToView(self.fenShuLabel, 5)
    .leftEqualToView(self.fenShuLabel)
    .rightSpaceToView(self.topBgImageView, 34)
    .heightIs(16);
    
    //课件学习
    self.keJianXueXiView.sd_layout.heightIs(50);
    
    self.keJianXueTitleLabel.sd_layout
    .topSpaceToView(self.keJianXueXiView, 0)
    .leftEqualToView(self.keJianXueXiView)
    .rightEqualToView(self.keJianXueXiView)
    .heightIs(20);
    
    self.keJianXueContentLabel.sd_layout
    .bottomSpaceToView(self.keJianXueXiView, 0)
    .leftEqualToView(self.keJianXueXiView)
    .rightEqualToView(self.keJianXueXiView)
    .heightIs(20);
    
    //平时作业
    self.pingShiZuoYeView.sd_layout.heightRatioToView(self.keJianXueXiView, 1);
    
    self.pingShiZuoYeTitleLabel.sd_layout
    .topSpaceToView(self.pingShiZuoYeView, 0)
    .leftEqualToView(self.pingShiZuoYeView)
    .rightEqualToView(self.pingShiZuoYeView)
    .heightRatioToView(self.keJianXueTitleLabel, 1);
    
    self.pingShiZuoYeContentLabel.sd_layout
    .bottomSpaceToView(self.pingShiZuoYeView, 0)
    .leftEqualToView(self.pingShiZuoYeView)
    .rightEqualToView(self.pingShiZuoYeView)
    .heightRatioToView(self.keJianXueContentLabel, 1);
    
    //学习表现
    self.xueXiBiaoXianView.sd_layout.heightRatioToView(self.keJianXueXiView, 1);
    
    self.xueXiBiaoXianTitleLabel.sd_layout
    .topSpaceToView(self.xueXiBiaoXianView, 0)
    .leftEqualToView(self.xueXiBiaoXianView)
    .rightEqualToView(self.xueXiBiaoXianView)
    .heightRatioToView(self.keJianXueTitleLabel, 1);
    
    self.xueXiBiaoXianContentLabel.sd_layout
    .bottomSpaceToView(self.xueXiBiaoXianView, 0)
    .leftEqualToView(self.xueXiBiaoXianView)
    .rightEqualToView(self.xueXiBiaoXianView)
    .heightRatioToView(self.keJianXueContentLabel, 1);
    
    //期末考试
    self.qiMoKaoShiView.sd_layout.heightRatioToView(self.keJianXueXiView, 1);
    
    self.qiMoKaoShiTitleLabel.sd_layout
    .topSpaceToView(self.qiMoKaoShiView, 0)
    .leftEqualToView(self.qiMoKaoShiView)
    .rightEqualToView(self.qiMoKaoShiView)
    .heightRatioToView(self.keJianXueTitleLabel, 1);
    
    self.qiMoKaoShiContentLabel.sd_layout
    .bottomSpaceToView(self.qiMoKaoShiView, 0)
    .leftEqualToView(self.qiMoKaoShiView)
    .rightEqualToView(self.qiMoKaoShiView)
    .heightRatioToView(self.keJianXueContentLabel, 1);
    
    
    [self.showContainerView setupAutoMarginFlowItems:@[self.keJianXueXiView,self.pingShiZuoYeView,self.xueXiBiaoXianView,self.qiMoKaoShiView] withPerRowItemsCount:4 itemWidth:60 verticalMargin:20 verticalEdgeInset:15 horizontalEdgeInset:20];
    
    [self.showContainerView updateLayout];
    self.showContainerView.sd_layout.bottomEqualToView(self.topBgImageView).offset(CGRectGetHeight(self.showContainerView.bounds)*0.5);
    // 渐变
    [self.showContainerView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0xFFFFFF, 0.5) endColor:COLOR_WITH_ALPHA(0xFFFFFF, 1)];
    // 模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualView.layer.cornerRadius = 8;
    visualView.frame = self.showContainerView.bounds;
    [self.showContainerView addSubview:visualView];
    
    //调换位置
    [self.showContainerView insertSubview:self.keJianXueXiView aboveSubview:visualView];
    [self.showContainerView insertSubview:self.pingShiZuoYeView aboveSubview:visualView];
    [self.showContainerView insertSubview:self.xueXiBiaoXianView aboveSubview:visualView];
    [self.showContainerView insertSubview:self.qiMoKaoShiView aboveSubview:visualView];
    
    
    
}

#pragma mark - LazyLoad
-(UIImageView *)topBgImageView{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.clipsToBounds = YES;
        _topBgImageView.userInteractionEnabled = YES;
        _topBgImageView.image = [UIImage imageNamed:@"studyreport_bg"];
    }
    return _topBgImageView;
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navi_whiteback"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.text = @"学习报告";
    }
    return _titleLabel;
}


-(UILabel *)fenShuLabel{
    if (!_fenShuLabel) {
        _fenShuLabel = [[UILabel alloc] init];
        _fenShuLabel.textAlignment = NSTextAlignmentLeft;
        _fenShuLabel.font = [UIFont fontWithName: @"Verdana-Bold"  size:36];
        _fenShuLabel.textColor = COLOR_WITH_ALPHA(0xFFDE30, 1);
        _fenShuLabel.text = @"64";
    }
    return _fenShuLabel;
}

-(UIView *)showContainerView{
    if (!_showContainerView) {
        _showContainerView = [[UIView alloc] init];
        _showContainerView.clipsToBounds = YES;
        _showContainerView.layer.borderWidth = 1;
        _showContainerView.layer.borderColor = UIColor.whiteColor.CGColor;
        _showContainerView.backgroundColor = UIColor.clearColor;
        _showContainerView.layer.cornerRadius = 8;
        _showContainerView.layer.shadowColor = COLOR_WITH_ALPHA(0xB6C3DB, 1).CGColor;
        _showContainerView.layer.shadowOffset = CGSizeMake(0,2);
        _showContainerView.layer.shadowOpacity = 1;
        _showContainerView.layer.shadowRadius = 15;
    }
    return _showContainerView;
}

-(UILabel *)fenLabel{
    if (!_fenLabel) {
        _fenLabel = [[UILabel alloc] init];
        _fenLabel.textAlignment = NSTextAlignmentLeft;
        _fenLabel.font = HXFont(16);
        _fenLabel.textColor = UIColor.whiteColor;
        _fenLabel.text = @"分";
    }
    return _fenLabel;
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.font = HXFont(11);
        _tipLabel.textColor = UIColor.whiteColor;
        _tipLabel.text = @"总分由各部分得分折合权重结算而来";
    }
    return _tipLabel;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.bounces = YES;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.showsVerticalScrollIndicator = NO;
        if ([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_mainTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        self.extendedLayoutIncludesOpaqueBars = YES;
        if (@available(iOS 11.0, *)) {
            _mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _mainTableView.estimatedRowHeight = 0;
            _mainTableView.estimatedSectionHeaderHeight = 0;
            _mainTableView.estimatedSectionFooterHeight = 0;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, kScreenBottomMargin, 0);
        _mainTableView.scrollIndicatorInsets = _mainTableView.contentInset;
        
        //头部
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        UILabel *detailLabel = [[UILabel alloc] init];
        detailLabel.font = HXBoldFont(16);
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        detailLabel.text = @"成绩详情";
        [tableHeaderView addSubview:detailLabel];
        detailLabel.sd_layout
        .centerXEqualToView(tableHeaderView)
        .centerYEqualToView(tableHeaderView)
        .widthIs(100)
        .heightIs(23);
        _mainTableView.tableHeaderView = tableHeaderView;
        
    }
    return _mainTableView;
}


-(UIView *)keJianXueXiView{
    if (!_keJianXueXiView) {
        _keJianXueXiView = [[UIView alloc] init];
        _keJianXueXiView.backgroundColor = UIColor.clearColor;
        _keJianXueXiView.clipsToBounds = YES;
    }
    return _keJianXueXiView;
}


- (UILabel *)keJianXueTitleLabel{
    if (!_keJianXueTitleLabel) {
        _keJianXueTitleLabel = [[UILabel alloc] init];
        _keJianXueTitleLabel.textAlignment = NSTextAlignmentCenter;
        _keJianXueTitleLabel.font =HXFont(14);
        _keJianXueTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _keJianXueTitleLabel.text = @"课件学习";
    }
    return _keJianXueTitleLabel;
}

- (UILabel *)keJianXueContentLabel{
    if (!_keJianXueContentLabel) {
        _keJianXueContentLabel = [[UILabel alloc] init];
        _keJianXueContentLabel.textAlignment = NSTextAlignmentCenter;
        _keJianXueContentLabel.font = HXBoldFont(14);
        _keJianXueContentLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _keJianXueContentLabel.text = @"10%";
    }
    return _keJianXueContentLabel;
}

-(UIView *)pingShiZuoYeView{
    if (!_pingShiZuoYeView) {
        _pingShiZuoYeView = [[UIView alloc] init];
        _pingShiZuoYeView.backgroundColor = UIColor.clearColor;
        _pingShiZuoYeView.clipsToBounds = YES;
    }
    return _pingShiZuoYeView;
}


- (UILabel *)pingShiZuoYeTitleLabel{
    if (!_pingShiZuoYeTitleLabel) {
        _pingShiZuoYeTitleLabel = [[UILabel alloc] init];
        _pingShiZuoYeTitleLabel.textAlignment = NSTextAlignmentCenter;
        _pingShiZuoYeTitleLabel.font =HXFont(14);
        _pingShiZuoYeTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _pingShiZuoYeTitleLabel.text = @"平时作业";
    }
    return _pingShiZuoYeTitleLabel;
}

- (UILabel *)pingShiZuoYeContentLabel{
    if (!_pingShiZuoYeContentLabel) {
        _pingShiZuoYeContentLabel = [[UILabel alloc] init];
        _pingShiZuoYeContentLabel.textAlignment = NSTextAlignmentCenter;
        _pingShiZuoYeContentLabel.font = HXBoldFont(14);
        _pingShiZuoYeContentLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _pingShiZuoYeContentLabel.text = @"10%";
    }
    return _pingShiZuoYeContentLabel;
}

-(UIView *)xueXiBiaoXianView{
    if (!_xueXiBiaoXianView) {
        _xueXiBiaoXianView = [[UIView alloc] init];
        _xueXiBiaoXianView.backgroundColor = UIColor.clearColor;
        _xueXiBiaoXianView.clipsToBounds = YES;
    }
    return _xueXiBiaoXianView;
}


- (UILabel *)xueXiBiaoXianTitleLabel{
    if (!_xueXiBiaoXianTitleLabel) {
        _xueXiBiaoXianTitleLabel = [[UILabel alloc] init];
        _xueXiBiaoXianTitleLabel.textAlignment = NSTextAlignmentCenter;
        _xueXiBiaoXianTitleLabel.font =HXFont(14);
        _xueXiBiaoXianTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _xueXiBiaoXianTitleLabel.text = @"学习表现";
    }
    return _xueXiBiaoXianTitleLabel;
}

- (UILabel *)xueXiBiaoXianContentLabel{
    if (!_xueXiBiaoXianContentLabel) {
        _xueXiBiaoXianContentLabel = [[UILabel alloc] init];
        _xueXiBiaoXianContentLabel.textAlignment = NSTextAlignmentCenter;
        _xueXiBiaoXianContentLabel.font = HXBoldFont(14);
        _xueXiBiaoXianContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _xueXiBiaoXianContentLabel.text = @"10";
    }
    return _xueXiBiaoXianContentLabel;
}

-(UIView *)qiMoKaoShiView{
    if (!_qiMoKaoShiView) {
        _qiMoKaoShiView = [[UIView alloc] init];
        _qiMoKaoShiView.backgroundColor = UIColor.clearColor;
        _qiMoKaoShiView.clipsToBounds = YES;
    }
    return _qiMoKaoShiView;
}


- (UILabel *)qiMoKaoShiTitleLabel{
    if (!_qiMoKaoShiTitleLabel) {
        _qiMoKaoShiTitleLabel = [[UILabel alloc] init];
        _qiMoKaoShiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _qiMoKaoShiTitleLabel.font =HXFont(14);
        _qiMoKaoShiTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _qiMoKaoShiTitleLabel.text = @"期末考试";
    }
    return _qiMoKaoShiTitleLabel;
}

- (UILabel *)qiMoKaoShiContentLabel{
    if (!_qiMoKaoShiContentLabel) {
        _qiMoKaoShiContentLabel = [[UILabel alloc] init];
        _qiMoKaoShiContentLabel.textAlignment = NSTextAlignmentCenter;
        _qiMoKaoShiContentLabel.font = HXBoldFont(14);
        _qiMoKaoShiContentLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _qiMoKaoShiContentLabel.text = @"80%";
    }
    return _qiMoKaoShiContentLabel;
}


@end
