//
//  HXHomePageViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "HXHomePageViewController.h"

#import "HXPaymentQueryViewController.h"//缴费查询
#import "HXScoreQueryViewController.h"//成绩查询
#import "HXMyBuKaoViewController.h"//我的补考
#import "HXFunctionCenterViewController.h"//更多

#import "HXKeJianLearnViewController.h"//课件学习
#import "HXPingShiZuoYeViewController.h"//平时作业
#import "HXQIMoKaoShiViewController.h"//期末考试
#import "HXStudyReportViewController.h"//学习报告
#import "HXClassRankViewController.h"//班级排名
#import "HXCurrentLearCell.h"
#import "GBLoopView.h"
#import "HXShowMajorView.h"

@interface HXHomePageViewController ()<UITableViewDelegate,UITableViewDataSource,HXCurrentLearCellDelegate>



//顶部个人信息栏
@property(nonatomic,strong) UIImageView *topBgImageView;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UILabel *welcomeLabel;
@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *personIdLabel;
@property(nonatomic,strong) UILabel *bkSchooldLabel;
@property(nonatomic,strong) UILabel *bkSchooldContentLabel;
@property(nonatomic,strong) UILabel *bkMajorLabel;
@property(nonatomic,strong) UIButton *bkMajorContentBtn;
@property(nonatomic,strong) UIView *paoMaDengView;
@property(nonatomic,strong) UIImageView *noticeImageView;
@property(nonatomic,strong) GBLoopView *loopView;

@property(nonatomic,strong) UIImageView *bottomBgImageView;

@property(nonatomic,strong) UITableView *mainTableView;
@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) UIView *btnsContainerView;
@property(nonatomic,strong) UIView *currentLearContainerView;
@property(nonatomic,strong) UILabel *currentLearLabel;

@property(nonatomic,strong) UIButton *baoDaoBtn;

@property(nonatomic,strong) NSMutableArray *bujuArray;
@property(nonatomic,strong) NSMutableArray *bujuBtns;

@property(nonatomic,strong) HXShowMajorView *showMajorView;


@end

@implementation HXHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
   
    
}


#pragma mark - Event
-(void)handleMiddleClick:(UIButton *)sender{
    NSInteger tag = sender.tag;
    switch (tag) {
        case 5000:
        {
           
        }
            break;
        case 5001:
        {
            HXPaymentQueryViewController *vc = [[HXPaymentQueryViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5002:
        {
            HXScoreQueryViewController *vc = [[HXScoreQueryViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5003:
        {
            HXMyBuKaoViewController *vc = [[HXMyBuKaoViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5004:
        {
           
        }
            break;
        case 5005:
        {
           
        }
            break;
        case 5006:
        {
           
        }
            break;
        case 5007:
        {
            HXFunctionCenterViewController *vc = [[HXFunctionCenterViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

//选择考专业
-(void)selectMajor:(UIButton *)sender{
//    if (self.examDateList.count<=0) return;
//    self.showMajorView.dataArray = self.examDateList;
    [self.showMajorView show];
    ///选择回调
    WeakSelf(weakSelf);
    self.showMajorView.selectMajorCallBack = ^(BOOL isRefresh, HXMajorModel * _Nonnull selectMajorModel) {
        if (isRefresh){
            
        }
    };
}

#pragma mark -<HXCurrentLearCellDelegate> flag:  8000:课件学习    8001:平时作业   8002:期末考试   8003:答疑室   8004:学习报告  8005:班级排名   8006:得分
-(void)handleClickEvent:(NSInteger)flag{
    
    switch (flag) {
        case 8000:
        {
            HXKeJianLearnViewController *vc = [[HXKeJianLearnViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8001:
        {
            HXPingShiZuoYeViewController *vc = [[HXPingShiZuoYeViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8002:
        {
            HXQIMoKaoShiViewController *vc = [[HXQIMoKaoShiViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8003:
        {
           
        }
            break;
        case 8004:
        {
            HXStudyReportViewController *vc = [[HXStudyReportViewController alloc] init];
            vc.sc_navigationBarHidden = YES;//隐藏导航栏
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8005:
        {
            HXClassRankViewController *vc = [[HXClassRankViewController alloc] init];
            vc.sc_navigationBarHidden = YES;//隐藏导航栏
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}
#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 242;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *currentLearCellIdentifier = @"HXCurrentLearCellIdentifier";
    HXCurrentLearCell *cell = [tableView dequeueReusableCellWithIdentifier:currentLearCellIdentifier];
    if (!cell) {
        cell = [[HXCurrentLearCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currentLearCellIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
    [self.view addSubview:self.bottomBgImageView];
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.topBgImageView];
    [self.topBgImageView addSubview:self.headImageView];
    [self.topBgImageView addSubview:self.welcomeLabel];
    [self.topBgImageView addSubview:self.nameLabel];
    [self.topBgImageView addSubview:self.personIdLabel];
    [self.topBgImageView addSubview:self.bkSchooldLabel];
    [self.topBgImageView addSubview:self.bkSchooldContentLabel];
    [self.topBgImageView addSubview:self.bkMajorLabel];
    [self.topBgImageView addSubview:self.bkMajorContentBtn];
    [self.topBgImageView addSubview:self.paoMaDengView];
    [self.paoMaDengView addSubview:self.loopView];
    [self.paoMaDengView addSubview:self.noticeImageView];
    
    
    self.topBgImageView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(528*kScreenWidth/750.0);
    
    
    
    self.bottomBgImageView.sd_layout
    .topSpaceToView(self.topBgImageView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(328*kScreenWidth/750.0);
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.topBgImageView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, kTabBarHeight);
    
    
    self.headImageView.sd_layout
    .topSpaceToView(self.topBgImageView, 70)
    .leftSpaceToView(self.topBgImageView, 40)
    .widthIs(68)
    .heightEqualToWidth();
    self.headImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.welcomeLabel.sd_layout
    .topEqualToView(self.headImageView)
    .leftSpaceToView(self.headImageView, 24)
    .rightSpaceToView(self.topBgImageView, 40)
    .heightIs(17);
    
    self.nameLabel.sd_layout
    .topSpaceToView(self.welcomeLabel, 0)
    .leftEqualToView(self.welcomeLabel)
    .rightEqualToView(self.welcomeLabel)
    .heightIs(28);
    
    self.personIdLabel.sd_layout
    .topSpaceToView(self.nameLabel, 2)
    .leftEqualToView(self.welcomeLabel)
    .rightEqualToView(self.welcomeLabel)
    .heightIs(18);
    
    self.bkSchooldLabel.sd_layout
    .topSpaceToView(self.headImageView, 30)
    .leftEqualToView(self.headImageView)
    .widthIs(70)
    .heightIs(20);
    
    self.bkSchooldContentLabel.sd_layout
    .centerYEqualToView(self.bkSchooldLabel)
    .rightSpaceToView(self.topBgImageView, 40)
    .leftSpaceToView(self.bkSchooldLabel, 20)
    .heightRatioToView(self.bkSchooldLabel, 1);
    
    self.bkMajorLabel.sd_layout
    .topSpaceToView(self.bkSchooldLabel, 13)
    .leftEqualToView(self.bkSchooldLabel)
    .rightEqualToView(self.bkSchooldLabel)
    .heightRatioToView(self.bkSchooldLabel, 1);
    
    self.bkMajorContentBtn.sd_layout
    .centerYEqualToView(self.bkMajorLabel)
    .rightEqualToView(self.bkSchooldContentLabel)
    .leftEqualToView(self.bkSchooldContentLabel)
    .heightRatioToView(self.bkSchooldContentLabel, 1);
    
    self.bkMajorContentBtn.imageView.sd_layout
    .rightEqualToView(self.bkMajorContentBtn)
    .centerYEqualToView(self.bkMajorContentBtn)
    .widthIs(9)
    .heightEqualToWidth();
    
    self.bkMajorContentBtn.titleLabel.sd_layout
    .centerYEqualToView(self.bkMajorContentBtn)
    .rightSpaceToView(self.bkMajorContentBtn.imageView, 5)
    .leftEqualToView(self.bkMajorContentBtn)
    .heightRatioToView(self.bkMajorContentBtn, 1);
    
    self.paoMaDengView.sd_layout
    .bottomSpaceToView(self.topBgImageView, 12)
    .leftSpaceToView(self.topBgImageView, 12)
    .rightSpaceToView(self.topBgImageView, 12)
    .heightIs(30);
    self.paoMaDengView.sd_cornerRadius = @8;
    
    self.noticeImageView.sd_layout
    .centerYEqualToView(self.paoMaDengView)
    .leftSpaceToView(self.paoMaDengView, 0)
    .widthIs(40)
    .heightIs(16);
    
    self.loopView.sd_layout
    .centerYEqualToView(self.paoMaDengView)
    .leftSpaceToView(self.noticeImageView, 5)
    .rightSpaceToView(self.paoMaDengView, 5)
    .heightIs(18);
    
    [self.loopView setTickerArrs:@[@"「学校通知」临近期末考试啦，同学们要抓紧复习呀..",@"长沙理工大学-行政管理-中国近代史纲要"]];
    [self.loopView start];
    
}

#pragma mark - LazyLoad
-(UIImageView *)topBgImageView{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.clipsToBounds = YES;
        _topBgImageView.userInteractionEnabled = YES;
        _topBgImageView.image = [UIImage imageNamed:@"hometopbg_icon"];
    }
    return _topBgImageView;
}

-(UIImageView *)bottomBgImageView{
    if (!_bottomBgImageView) {
        _bottomBgImageView = [[UIImageView alloc] init];
        _bottomBgImageView.clipsToBounds = YES;
        _bottomBgImageView.userInteractionEnabled = YES;
        _bottomBgImageView.image = [UIImage imageNamed:@"homebottombg_icon"];
    }
    return _bottomBgImageView;
}

-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.layer.borderWidth = 2;
        _headImageView.layer.borderColor = UIColor.whiteColor.CGColor;
        _headImageView.image = [UIImage imageNamed:@"defaulthead_icon"];
    }
    return _headImageView;
}

- (UILabel *)welcomeLabel{
    if (!_welcomeLabel) {
        _welcomeLabel = [[UILabel alloc] init];
        _welcomeLabel.font = HXBoldFont(12);
        _welcomeLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 0.5);
        _welcomeLabel.text = @"欢迎您";
    }
    return _welcomeLabel;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = HXBoldFont(20);
        _nameLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _nameLabel.text = @"张敏";
    }
    return _nameLabel;
}

- (UILabel *)personIdLabel{
    if (!_personIdLabel) {
        _personIdLabel = [[UILabel alloc] init];
        _personIdLabel.font = HXFont(13);
        _personIdLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _personIdLabel.text = @"432195199210261245";
    }
    return _personIdLabel;
}

- (UILabel *)bkSchooldLabel{
    if (!_bkSchooldLabel) {
        _bkSchooldLabel = [[UILabel alloc] init];
        _bkSchooldLabel.font = HXFont(14);
        _bkSchooldLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 0.5);
        _bkSchooldLabel.text = @"报考学校";
    }
    return _bkSchooldLabel;
}

- (UILabel *)bkSchooldContentLabel{
    if (!_bkSchooldContentLabel) {
        _bkSchooldContentLabel = [[UILabel alloc] init];
        _bkSchooldContentLabel.font = HXFont(14);
        _bkSchooldContentLabel.textAlignment = NSTextAlignmentRight;
        _bkSchooldContentLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _bkSchooldContentLabel.text = @"长沙理工大学";
    }
    return _bkSchooldContentLabel;
}

- (UILabel *)bkMajorLabel{
    if (!_bkMajorLabel) {
        _bkMajorLabel = [[UILabel alloc] init];
        _bkMajorLabel.font = HXFont(14);
        _bkMajorLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 0.5);
        _bkMajorLabel.text = @"报考专业";
    }
    return _bkMajorLabel;
}

-(UIButton *)bkMajorContentBtn{
    if (!_bkMajorContentBtn) {
        _bkMajorContentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bkMajorContentBtn.titleLabel.font = HXFont(14);
        _bkMajorContentBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_bkMajorContentBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_bkMajorContentBtn setImage:[UIImage imageNamed:@"whiteright_arrow"] forState:UIControlStateNormal];
        [_bkMajorContentBtn setTitle:@"行政管理" forState:UIControlStateNormal];
        [_bkMajorContentBtn addTarget:self action:@selector(selectMajor:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bkMajorContentBtn;
}

- (UIView *)paoMaDengView{
    if (!_paoMaDengView) {
        _paoMaDengView = [[UIView alloc] init];
        _paoMaDengView.backgroundColor = UIColor.whiteColor;
    }
    return _paoMaDengView;
}

-(UIImageView *)noticeImageView{
    if (!_noticeImageView) {
        _noticeImageView = [[UIImageView alloc] init];
        _noticeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _noticeImageView.userInteractionEnabled = YES;
        _noticeImageView.backgroundColor  = UIColor.whiteColor;
        _noticeImageView.image = [UIImage imageNamed:@"notice_icon"];
    }
    return _noticeImageView;
}

- (GBLoopView *)loopView{
    if (!_loopView) {
        _loopView =  [[GBLoopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 18)];
        [_loopView setDirection:GBLoopDirectionRight];
        [_loopView setBackColor:[UIColor whiteColor]];
        [_loopView setSpeed:60.0f];
    }
    return _loopView;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.bounces = YES;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _mainTableView.scrollIndicatorInsets = _mainTableView.contentInset;
        _mainTableView.tableHeaderView = self.tableHeaderView;
        _mainTableView.showsVerticalScrollIndicator = NO;
       
    }
    return _mainTableView;
}

-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] init];
        _tableHeaderView.sd_layout.widthIs(kScreenWidth);
        [_tableHeaderView addSubview:self.btnsContainerView];
        [_tableHeaderView addSubview:self.currentLearContainerView];
        [_tableHeaderView addSubview:self.baoDaoBtn];
        [self.currentLearContainerView addSubview:self.currentLearLabel];
        
        self.btnsContainerView.sd_layout
        .topSpaceToView(_tableHeaderView, 0)
        .leftSpaceToView(_tableHeaderView, 12)
        .rightSpaceToView(_tableHeaderView,12);
        
        for (UIButton *btn in self.bujuBtns) {
            btn.sd_layout.heightIs(73);
            btn.imageView.sd_layout
            .centerXEqualToView(btn)
            .topSpaceToView(btn, 0)
            .widthIs(47)
            .heightEqualToWidth();
            
            btn.titleLabel.sd_layout
            .bottomSpaceToView(btn, 0)
            .leftEqualToView(btn)
            .rightEqualToView(btn)
            .heightIs(17);
        }
        
        [self.btnsContainerView setupAutoMarginFlowItems:self.bujuBtns withPerRowItemsCount:4 itemWidth:60 verticalMargin:20 verticalEdgeInset:20 horizontalEdgeInset:20];
        self.btnsContainerView.sd_cornerRadius = @8;
        
        self.currentLearContainerView.sd_layout
        .topSpaceToView(self.btnsContainerView, 16)
        .leftEqualToView(_tableHeaderView)
        .rightEqualToView(_tableHeaderView)
        .heightIs(50);
        [self.currentLearContainerView updateLayout];
        
        
        // 左上和右上为圆角
        UIBezierPath *cornerRadiusPath = [UIBezierPath bezierPathWithRoundedRect:self.currentLearContainerView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(8, 8)];
        CAShapeLayer *cornerRadiusLayer = [ [CAShapeLayer alloc ] init];
        cornerRadiusLayer.frame = self.currentLearContainerView.bounds;
        cornerRadiusLayer.path = cornerRadiusPath.CGPath;
        self.currentLearContainerView.layer.mask = cornerRadiusLayer;
       
        self.currentLearLabel.sd_layout
        .centerYEqualToView(self.currentLearContainerView)
        .leftSpaceToView(self.currentLearContainerView, 12)
        .rightSpaceToView(self.currentLearContainerView, 12)
        .heightIs(23);
        
        
        self.baoDaoBtn.sd_layout
        .topSpaceToView(self.btnsContainerView, 26)
        .leftSpaceToView(_tableHeaderView, 12)
        .rightSpaceToView(_tableHeaderView, 12)
        .heightIs(40);
        self.baoDaoBtn.sd_cornerRadiusFromHeightRatio = @0.5;
        
        [_tableHeaderView setupAutoHeightWithBottomView:self.currentLearContainerView bottomMargin:0];
        
        [_tableHeaderView setNeedsLayout];
        [_tableHeaderView layoutIfNeeded];
    }
    return _tableHeaderView;
}

-(NSMutableArray *)bujuArray{
    if (!_bujuArray) {
        _bujuArray = [NSMutableArray array];
        [_bujuArray addObjectsFromArray:@[
            [@{@"title":@"财务缴费",@"iconName":@"caiwujiaofei_icon",@"handleEventTag":@(5000),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"缴费查询",@"iconName":@"payquery_icon",@"handleEventTag":@(5001),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"成绩查询",@"iconName":@"scorequery_icon",@"handleEventTag":@(5002),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的补考",@"iconName":@"mybukao_icon",@"handleEventTag":@(5003),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"毕业论文",@"iconName":@"lunwen_icon",@"handleEventTag":@(5004),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"学位英语",@"iconName":@"english_icon",@"handleEventTag":@(5005),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的直播",@"iconName":@"zhibo_icon",@"handleEventTag":@(5006),@"isShow":@(1)} mutableCopy],
            [@{@"title":@"更多",@"iconName":@"more_icon",@"handleEventTag":@(5007),@"isShow":@(1)} mutableCopy]
        ]];
    }
    return _bujuArray;
}


-(NSMutableArray *)bujuBtns{
    if (!_bujuBtns) {
        _bujuBtns = [NSMutableArray array];
    }
    return _bujuBtns;
}


- (UIView *)btnsContainerView{
    if (!_btnsContainerView) {
        _btnsContainerView = [[UIView alloc] init];
        _btnsContainerView.backgroundColor = UIColor.whiteColor;
        for (int i = 0; i<self.bujuArray.count; i++) {
            NSDictionary *dic = self.bujuArray[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXFont(13);
            btn.tag = [dic[@"handleEventTag"] integerValue];
            [btn setTitle:dic[@"title"] forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:dic[@"iconName"]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleMiddleClick:) forControlEvents:UIControlEventTouchUpInside];
            [_btnsContainerView addSubview:btn];
            [self.bujuBtns addObject:btn];
        }
    }
    return _btnsContainerView;;
}



- (UIView *)currentLearContainerView{
    if (!_currentLearContainerView) {
        _currentLearContainerView = [[UIView alloc] init];
        _currentLearContainerView.backgroundColor = COLOR_WITH_ALPHA(0xECF0FB, 1);
        _currentLearContainerView.layer.shadowColor = COLOR_WITH_ALPHA(0x163682, 0.03).CGColor;
        _currentLearContainerView.layer.shadowOffset = CGSizeMake(0,-2.5);
        _currentLearContainerView.layer.shadowOpacity = 1;
        _currentLearContainerView.layer.shadowRadius = 5;
    }
    return _currentLearContainerView;
}

- (UILabel *)currentLearLabel{
    if (!_currentLearLabel) {
        _currentLearLabel = [[UILabel alloc] init];
        _currentLearLabel.font = HXBoldFont(16)
        _currentLearLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _currentLearLabel.text = @"当前学习";
    }
    return _currentLearLabel;
}

-(UIButton *)baoDaoBtn{
    if (!_baoDaoBtn) {
        _baoDaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _baoDaoBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _baoDaoBtn.titleLabel.font = HXBoldFont(15);
        _baoDaoBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_baoDaoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_baoDaoBtn setTitle:@"去报道" forState:UIControlStateNormal];
        _baoDaoBtn.hidden = YES;
    }
    return _baoDaoBtn;
}

-(HXShowMajorView *)showMajorView{
    if (!_showMajorView) {
        _showMajorView = [[HXShowMajorView alloc] init];
    }
    return _showMajorView;
}

@end
