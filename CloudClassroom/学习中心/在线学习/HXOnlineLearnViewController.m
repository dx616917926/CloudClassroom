//
//  HXOnlineLearnViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXOnlineLearnViewController.h"
#import "HXKeJianLearnViewController.h"//课件学习
#import "HXPingShiZuoYeViewController.h"//平时作业
#import "HXQIMoKaoShiViewController.h"//期末考试
#import "HXStudyReportViewController.h"//学习报告
#import "HXClassRankViewController.h"//班级排名
#import "HXCurrentLearCell.h"
#import "HXOnlineLearnShowTipView.h"
#import "HXSemesterModel.h"


@interface HXOnlineLearnViewController ()<UITableViewDelegate,UITableViewDataSource,HXCurrentLearCellDelegate>

@property(nonatomic,strong) UIView *topView;
@property(nonatomic,strong) UIButton *ganTanBtn;
@property(nonatomic,strong) UIButton *currentXueQiBtn;
@property(nonatomic,strong) UIButton *allXueQiBtn;
@property(nonatomic,strong) UIButton *selectXueQiBtn;
@property(nonatomic,strong) UITableView *mainTableView;

//是否是当前学期
@property(nonatomic,assign) BOOL isCuurentSemester;

@property(nonatomic,strong) NSMutableArray *currentDataArray;
@property(nonatomic,strong) NSMutableArray *allDataArray;

@end

@implementation HXOnlineLearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    self.isCuurentSemester = YES;
    //
    [self loadData];
    //监听修改专业通知
    [HXNotificationCenter addObserver:self selector:@selector(loadData) name:kChangeMajorSuccessNotification object:nil];
}

-(void)dealloc{
    [HXNotificationCenter removeObserver:self];
}


-(void)loadData{
    //获取当前学期
    [self getCurrentSemester];
    //获取全部学期
    [self getAllSemester];
}
#pragma mark - 获取当前学期
-(void)getCurrentSemester{
    
    [self.view showLoading];
    //学期，如果是当前学期，则传具体的学期，如果是所有学期，则传0
    NSString *major_id = [HXPublicParamTool sharedInstance].major_id;
    NSString *currentSemesterid = [HXPublicParamTool sharedInstance].currentSemesterid;
    NSDictionary *dic =@{
        @"majorid":HXSafeString(major_id),
        @"term":HXSafeString(currentSemesterid)
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetOnlineCourseList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXSemesterModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            HXSemesterModel *semesterModel = list.firstObject;
            [self.currentDataArray removeAllObjects];
            [self.currentDataArray addObjectsFromArray:semesterModel.courseList];
            [self.mainTableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view hideLoading];
        [self.mainTableView.mj_header endRefreshing];
    }];
}

#pragma mark - 获取全部学期
-(void)getAllSemester{
    
    //学期，如果是当前学期，则传具体的学期，如果是所有学期，则传0
    NSString *major_id = [HXPublicParamTool sharedInstance].major_id;
    NSDictionary *dic =@{
        @"majorid":HXSafeString(major_id),
        @"term":@"0"
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetOnlineCourseList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXSemesterModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self.allDataArray removeAllObjects];
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXSemesterModel *semesterModel = obj;
                [self.allDataArray addObjectsFromArray:semesterModel.courseList];
            }];
            [self.mainTableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}


#pragma mark - Event
//选择当前学期和所有学期
-(void)selectXueQi:(UIButton *)sender{
    if (sender==self.selectXueQiBtn) {
        return;
    }
    self.selectXueQiBtn.backgroundColor = UIColor.whiteColor;
    self.selectXueQiBtn.titleLabel.font = HXFont(15);
    [self.selectXueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x999999, 1) forState:UIControlStateNormal];
    
    sender.backgroundColor = COLOR_WITH_ALPHA(0xDDE4FF, 1);
    sender.titleLabel.font = HXBoldFont(15);
    [sender setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
    self.selectXueQiBtn = sender;
    
    if (sender==self.currentXueQiBtn) {
        self.isCuurentSemester =YES;
    }else{
        self.isCuurentSemester = NO;
    }
    
    [self.mainTableView reloadData];
    
}


-(void)showTip:(UIButton *)sender{
    HXOnlineLearnShowTipView *onlineLearnShowTipView =[[HXOnlineLearnShowTipView alloc] init];
    [onlineLearnShowTipView show];
}

#pragma mark -<HXCurrentLearCellDelegate> flag:  8000:课件学习    8001:平时作业   8002:期末考试   8003:答疑室   8004:学习报告  8005:班级排名   8006:得分
-(void)handleClickEvent:(NSInteger)flag courseInfoModel:(nonnull HXCourseInfoModel *)courseInfoModel{
    
    switch (flag) {
        case 8000:
        {
            HXKeJianLearnViewController *vc = [[HXKeJianLearnViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.courseInfoModel = courseInfoModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8001:
        {
            HXPingShiZuoYeViewController *vc = [[HXPingShiZuoYeViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.courseInfoModel = courseInfoModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8002:
        {
            HXQIMoKaoShiViewController *vc = [[HXQIMoKaoShiViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.courseInfoModel = courseInfoModel;
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
            vc.courseInfoModel = courseInfoModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8005:
        {
            HXClassRankViewController *vc = [[HXClassRankViewController alloc] init];
            vc.sc_navigationBarHidden = YES;//隐藏导航栏
            vc.hidesBottomBarWhenPushed = YES;
            vc.courseInfoModel = courseInfoModel;
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
    return (self.isCuurentSemester?self.currentDataArray.count:self.allDataArray.count);
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
    cell.courseInfoModel = (self.isCuurentSemester?self.currentDataArray[indexPath.row]:self.allDataArray[indexPath.row]);
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UI
-(void)createUI{
    [self.view addSubview:self.topView];
    [self.view addSubview:self.mainTableView];
    [self.topView addSubview:self.ganTanBtn];
    [self.topView addSubview:self.currentXueQiBtn];
    [self.topView addSubview:self.allXueQiBtn];
    
    self.selectXueQiBtn = self.currentXueQiBtn;
    
    self.topView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(58);
    
    self.ganTanBtn.sd_layout
    .centerYEqualToView(self.topView)
    .rightEqualToView(self.topView)
    .widthIs(50)
    .heightRatioToView(self.topView, 1);
    
    self.currentXueQiBtn.sd_layout
    .centerYEqualToView(self.topView)
    .leftSpaceToView(self.topView, 12)
    .widthIs(_kpw(147))
    .heightIs(34);
    self.currentXueQiBtn.sd_cornerRadius =@5;
    
    self.allXueQiBtn.sd_layout
    .centerYEqualToView(self.topView)
    .leftSpaceToView(self.currentXueQiBtn, _kpw(18))
    .widthRatioToView(self.currentXueQiBtn, 1)
    .heightRatioToView(self.currentXueQiBtn, 1);
    self.allXueQiBtn.sd_cornerRadius =@5;
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.topView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, 0);
    [self.mainTableView updateLayout];
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        (self.isCuurentSemester? [self getCurrentSemester]:[self getAllSemester]);
    }];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    
    self.noDataTipView.frame = self.mainTableView.frame;
}

#pragma mark -LazyLoad

-(NSMutableArray *)currentDataArray{
    if(!_currentDataArray){
        _currentDataArray = [NSMutableArray array];
    }
    return _currentDataArray;
}

-(NSMutableArray *)allDataArray{
    if(!_allDataArray){
        _allDataArray = [NSMutableArray array];
    }
    return _allDataArray;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = VCBackgroundColor;
    }
    return _topView;
}

- (UIButton *)currentXueQiBtn{
    if (!_currentXueQiBtn) {
        _currentXueQiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _currentXueQiBtn.backgroundColor = COLOR_WITH_ALPHA(0xDDE4FF, 1);
        _currentXueQiBtn.titleLabel.font = HXBoldFont(15);
        [_currentXueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_currentXueQiBtn setTitle:@"当前学期" forState:UIControlStateNormal];
        [_currentXueQiBtn addTarget:self action:@selector(selectXueQi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _currentXueQiBtn;
}

- (UIButton *)allXueQiBtn{
    if (!_allXueQiBtn) {
        _allXueQiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allXueQiBtn.backgroundColor = UIColor.whiteColor;
        _allXueQiBtn.titleLabel.font = HXFont(15);
        [_allXueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x999999, 1) forState:UIControlStateNormal];
        [_allXueQiBtn setTitle:@"所有学期" forState:UIControlStateNormal];
        [_allXueQiBtn addTarget:self action:@selector(selectXueQi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allXueQiBtn;
}

- (UIButton *)ganTanBtn{
    if (!_ganTanBtn) {
        _ganTanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ganTanBtn setImage:[UIImage imageNamed:@"gantan_icon"] forState:UIControlStateNormal];
        [_ganTanBtn addTarget:self action:@selector(showTip:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ganTanBtn;
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
        _mainTableView.showsVerticalScrollIndicator = NO;
       
    }
    return _mainTableView;
}



@end
