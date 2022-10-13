//
//  HXStudyReportViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXStudyReportViewController.h"
#import "UIView+TransitionColor.h"
#import "HXStudyReportKeJianCell.h"
#import "HXStudyReportXXBXCell.h"
#import "HXStudyReportZuoYeCell.h"
#import "HXCourseReportModel.h"

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

@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) HXCourseReportModel *courseReportModel;

@property(nonatomic,strong) HXCourseReportModel *zyCourseReportModel;

@property(nonatomic,strong) HXCourseReportModel *qmCourseReportModel;

@end

@implementation HXStudyReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取学习报告
    [self getCourseReport];
}


#pragma mark - 获取学习报告
-(void)getCourseReport{

    NSDictionary *dic =@{
        @"termcourse_id":HXSafeString(self.courseInfoModel.termCourseID),
        @"student_id":HXSafeString(self.courseInfoModel.student_id)
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetCourseReport needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.courseReportModel = [HXCourseReportModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            //刷新界面数据
            [self refreshUI];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}

-(void)refreshUI{
    
    self.fenShuLabel.text = self.courseReportModel.finalScore;
    
    HXCourseItemModel *kejianModule = self.courseReportModel.kjInfo.firstObject;
    HXCourseItemModel *xxbxModule = self.courseReportModel.xxbxInfo;
    HXCourseItemModel *zyModule = self.courseReportModel.zyInfo.firstObject;
    HXCourseItemModel *qmModule = self.courseReportModel.qmInfo.firstObject;
    
    self.zyCourseReportModel = [[HXCourseReportModel alloc] init];
    self.zyCourseReportModel.type = 1;
    self.zyCourseReportModel.zyInfo = self.courseReportModel.zyInfo;
    
    self.qmCourseReportModel = [[HXCourseReportModel alloc] init];
    self.qmCourseReportModel.type = 2;
    self.qmCourseReportModel.qmInfo = self.courseReportModel.qmInfo;
    
//    self.keJianXueTitleLabel.text = (kejianModule.kjButtonName?kejianModule.kjButtonName: @"课件学习");
    self.keJianXueContentLabel.text = (kejianModule.selfRate?kejianModule.selfRate:@"0%");
//    self.xueXiBiaoXianTitleLabel.text = (xxbxModule.moduleButtonName?xxbxModule.moduleButtonName:@"学习表现");
    self.xueXiBiaoXianContentLabel.text = (xxbxModule.moduleRate?xxbxModule.moduleRate:@"0%");
//    self.pingShiZuoYeTitleLabel.text = (zyModule.moduleButtonName?zyModule.moduleButtonName:@"平时作业");
    self.pingShiZuoYeContentLabel.text = (zyModule.moduleRate?zyModule.moduleRate:@"0%");
//    self.qiMoKaoShiTitleLabel.text = (qmModule.moduleButtonName?qmModule.moduleButtonName:@"期末考试");
    self.qiMoKaoShiContentLabel.text = (qmModule.moduleRate?qmModule.moduleRate:@"0%");
    
    
    [self.mainTableView reloadData];
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
    return 4;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        return (self.courseReportModel.kjInfo.count>0?(127*self.courseReportModel.kjInfo.count+106):0);
    }else if (indexPath.row==1) {
        return 148;
    }else if (indexPath.row==2) {
        return (self.courseReportModel.zyInfo.count>0?(127*self.courseReportModel.zyInfo.count+106):0);
    }else{
        return (self.courseReportModel.qmInfo.count>0?(127*self.courseReportModel.qmInfo.count+106):0);
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *keJianCellIdentifier = @"HXStudyReportKeJianCellIdentifier";
    HXStudyReportKeJianCell *keJianCell = [tableView dequeueReusableCellWithIdentifier:keJianCellIdentifier];
    
    static NSString *xXBXCellIdentifier = @"HXStudyReportXXBXCellIdentifier";
    HXStudyReportXXBXCell *xXBXCell = [tableView dequeueReusableCellWithIdentifier:xXBXCellIdentifier];
    
    static NSString *zuoYeCellIdentifier = @"HXStudyReportZuoYeCellIdentifier";
    HXStudyReportZuoYeCell *zuoYeCell = [tableView dequeueReusableCellWithIdentifier:zuoYeCellIdentifier];
    
    if (indexPath.row==0) {//课件学习
        keJianCell.selectionStyle = UITableViewCellSelectionStyleNone;
        keJianCell = [[HXStudyReportKeJianCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:keJianCellIdentifier];
        keJianCell.courseReportModel = self.courseReportModel;
        return keJianCell;
    }else if (indexPath.row==1) {//学习表现
        xXBXCell.selectionStyle = UITableViewCellSelectionStyleNone;
        xXBXCell = [[HXStudyReportXXBXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:xXBXCellIdentifier];
        xXBXCell.courseItemModel = self.courseReportModel.xxbxInfo;
        return xXBXCell;
    }else  if (indexPath.row==2) {//平时作业
        zuoYeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        zuoYeCell = [[HXStudyReportZuoYeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zuoYeCellIdentifier];
        HXCourseReportModel *courseReportModel = self.zyCourseReportModel;
        zuoYeCell.courseReportModel = courseReportModel;
        return zuoYeCell;
    }else{//期末考试
        zuoYeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        zuoYeCell = [[HXStudyReportZuoYeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zuoYeCellIdentifier];
        HXCourseReportModel *courseReportModel = self.qmCourseReportModel;
        zuoYeCell.courseReportModel = courseReportModel;
        return zuoYeCell;
    }
    
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
    
    [self.showContainerView addSubview:self.xueXiBiaoXianView];
    [self.xueXiBiaoXianView addSubview:self.xueXiBiaoXianTitleLabel];
    [self.xueXiBiaoXianView addSubview:self.xueXiBiaoXianContentLabel];
    
    [self.showContainerView addSubview:self.pingShiZuoYeView];
    [self.pingShiZuoYeView addSubview:self.pingShiZuoYeTitleLabel];
    [self.pingShiZuoYeView addSubview:self.pingShiZuoYeContentLabel];
    
    
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
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
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
    
    
    [self.showContainerView setupAutoMarginFlowItems:@[self.keJianXueXiView,self.xueXiBiaoXianView,self.pingShiZuoYeView,self.qiMoKaoShiView] withPerRowItemsCount:4 itemWidth:60 verticalMargin:20 verticalEdgeInset:15 horizontalEdgeInset:20];
    
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
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getCourseReport)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    
}

#pragma mark - LazyLoad
-(NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

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
        _keJianXueContentLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);

    }
    return _keJianXueContentLabel;
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
        _xueXiBiaoXianContentLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
    }
    return _xueXiBiaoXianContentLabel;
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
        _pingShiZuoYeContentLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
    }
    return _pingShiZuoYeContentLabel;
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
        
    }
    return _qiMoKaoShiContentLabel;
}


@end
