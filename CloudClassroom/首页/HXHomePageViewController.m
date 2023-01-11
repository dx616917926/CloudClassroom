//
//  HXHomePageViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "HXHomePageViewController.h"
#import "HXFinancePaymentViewController.h"//财务缴费
#import "HXPaymentQueryViewController.h"//缴费查询
#import "HXScoreQueryViewController.h"//成绩查询
#import "HXMyBuKaoViewController.h"//我的补考
#import "HXLiveCourseViewController.h"//直播课程
#import "HXFunctionCenterViewController.h"//更多

#import "HXKeJianLearnViewController.h"//课件学习
#import "HXPingShiZuoYeViewController.h"//平时作业
#import "HXQIMoKaoShiViewController.h"//期末考试
#import "HXStudyReportViewController.h"//学习报告
#import "HXClassRankViewController.h"//班级排名
#import "SDWebImage.h"
#import "HXCurrentLearCell.h"
#import "GBLoopView.h"
#import "HXShowMajorView.h"
#import "HXDegreeEnglishShowView.h"
#import "HXHomeStudentInfoModel.h"
#import "HXMajorInfoModel.h"
#import "HXMessageInfoModel.h"
#import "HXHomeMenuModel.h"

#import <objc/runtime.h>

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

@property(nonatomic,strong) HXHomeStudentInfoModel *homeStudentInfoModel;

@property(nonatomic,strong) NSMutableArray *majorArray;
@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) HXNoDataTipView *noDataView;

@end

@implementation HXHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    //获取首页公告信息
    [self getHomeMessageInfo];
    //
    [self loadData];
    //登录成功的通知
    [HXNotificationCenter addObserver:self selector:@selector(loadData) name:LOGINSUCCESS object:nil];
}

-(void)loadData{
    //获取首页专业信息
    [self getHomeMajorInfo];
    //获取首页信息
    [self getHomeStudentInfo];
    //获取首页菜单
    [self getHomeMenu];
}

#pragma mark - 获取首页专业信息
-(void)getHomeMajorInfo{
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetHomeMajorInfo needMd5:YES  withDictionary:nil success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXMajorInfoModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self.majorArray removeAllObjects];
            [self.majorArray addObjectsFromArray:list];
            //登录获得的major_id
            NSString *major_id = [HXPublicParamTool sharedInstance].major_id;
             __block HXMajorInfoModel *selectMajorInfoModel = list.firstObject;
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXMajorInfoModel *majorInfoModel = obj;
                if([majorInfoModel.major_Id isEqualToString:major_id]){
                    selectMajorInfoModel = majorInfoModel;
                    *stop = YES;
                    return;
                }
            }];
            [HXPublicParamTool sharedInstance].currentSemesterid = selectMajorInfoModel.semesterid;
            [HXPublicParamTool sharedInstance].student_id = selectMajorInfoModel.student_id;
            //获取当前学期学习列表
            [self getOnlineCourseList:selectMajorInfoModel.semesterid];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 获取首页信息
-(void)getHomeStudentInfo{
    NSString *major_id = [HXPublicParamTool sharedInstance].major_id;
    NSString *studentid = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"major_id":HXSafeString(major_id),
        @"studentid":HXSafeString(studentid)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetHomeStudentInfo needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.homeStudentInfoModel = [HXHomeStudentInfoModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            [self.headImageView sd_setImageWithURL:HXSafeURL(self.homeStudentInfoModel.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
            self.nameLabel.text = self.homeStudentInfoModel.name;
            self.personIdLabel.text = self.homeStudentInfoModel.personId;
            self.bkSchooldContentLabel.text = self.homeStudentInfoModel.subSchoolName;
            [self.bkMajorContentBtn setTitle:self.homeStudentInfoModel.majorlongName forState:UIControlStateNormal];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
    
}



#pragma mark - 获取学习列表(当前学期和全部学期)
-(void)getOnlineCourseList:(NSString *)semesterid{
    
    //学期，如果是当前学期，则传具体的学期，如果是所有学期，则传0
    NSString *major_id = [HXPublicParamTool sharedInstance].major_id;
    NSDictionary *dic =@{
        @"majorid":HXSafeString(major_id),
        @"term":HXSafeString(semesterid)
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetOnlineCourseList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXSemesterModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            HXSemesterModel *semesterModel = list.firstObject;
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:semesterModel.courseList];
            [self.mainTableView reloadData];
            if (self.dataArray.count==0) {
                self.mainTableView.tableFooterView = self.noDataView;
            }else{
                self.mainTableView.tableFooterView = nil;
            }
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark - 获取首页公告信息
-(void)getHomeMessageInfo{
    
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetHomeMessageInfo needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXMessageInfoModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            __block NSMutableArray *messageTitles = [NSMutableArray array];
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXMessageInfoModel *model = obj;
                [messageTitles addObject:model.messageTitle];
            }];
            
            [self.loopView setTickerArrs:messageTitles];
            [self.loopView start];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark - 获取首页菜单
-(void)getHomeMenu{
    NSDictionary *dic = @{
        @"type":@(1)//菜单类型：1首页菜单，2个人中心菜单，3个人中心附件菜单
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetHomeMenu needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXHomeMenuModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self refreshHomeMenuLayout:list];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 是否可以申请学位英语
-(void)canApplyDegreeEnglish{
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_IsCanApply needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSDictionary *data = [dictionary dictionaryValueForKey:@"data"];
            //是否可以进入申请学位 0表示不可以 1表示可以
            BOOL isCan = [data boolValueForKey:@"isCan"];
            //原因类型 1非本科生生，不能申请学位证书 2学位申请暂未开放报名 3未满足学位申请的条件
            NSInteger type = [[data stringValueForKey:@"type"] integerValue];
            if (!isCan) {
                HXDegreeEnglishShowView *degreeEnglishShowView =[[HXDegreeEnglishShowView alloc] init];
                if (type==1) {
                    degreeEnglishShowView.type = FeiBenKeShengType;
                }else if (type==2) {
                    degreeEnglishShowView.type = WeiKaiFangBaoMingType;
                }else if (type==3) {
                    degreeEnglishShowView.type = WeiManZuTiaoJianType;
                }
                [degreeEnglishShowView show];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 重新布局功能模块
-(void)refreshHomeMenuLayout:(NSArray<HXHomeMenuModel*>*)list{
    ///移除重新布局
    [self.bujuBtns removeAllObjects];
    [self.btnsContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //移除关联对象
        objc_removeAssociatedObjects(obj);
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    
    __block NSMutableArray *tempArray =[NSMutableArray array];
    [list enumerateObjectsUsingBlock:^(HXHomeMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.isShow==1){
            [tempArray addObject:obj];
        }
    }];
    if(tempArray.count<=8){
        [tempArray enumerateObjectsUsingBlock:^(HXHomeMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            //将数据关联按钮
            objc_setAssociatedObject(btn, &kMenuBtnModuleCode, obj.moduleCode, OBJC_ASSOCIATION_RETAIN);
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXFont(13);
            [btn setTitle:obj.moduleName forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn sd_setImageWithURL:HXSafeURL(obj.moduleIcon)  forState:UIControlStateNormal placeholderImage:nil];
            [btn addTarget:self action:@selector(handleHomeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [_btnsContainerView addSubview:btn];
            [self.bujuBtns addObject:btn];
            
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
        }];
    }else{
        NSArray *tempList = [tempArray subarrayWithRange:NSMakeRange(0, 7)];
        [tempList enumerateObjectsUsingBlock:^(HXHomeMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            //将数据关联按钮
            objc_setAssociatedObject(btn, &kMenuBtnModuleCode, obj.moduleCode, OBJC_ASSOCIATION_RETAIN);
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXFont(13);
            [btn setTitle:obj.moduleName forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn sd_setImageWithURL:HXSafeURL(obj.moduleIcon)  forState:UIControlStateNormal placeholderImage:nil];
            [btn addTarget:self action:@selector(handleHomeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [_btnsContainerView addSubview:btn];
            [self.bujuBtns addObject:btn];
            
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
        }];
        //更多
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //将数据关联按钮
        objc_setAssociatedObject(btn, &kMenuBtnModuleCode, @"More", OBJC_ASSOCIATION_RETAIN);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = HXFont(13);
        [btn setTitle:@"更多" forState:UIControlStateNormal];
        [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"more_icon"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleHomeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btnsContainerView addSubview:btn];
        [self.bujuBtns addObject:btn];
        
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
    
        
    [self.btnsContainerView setupAutoMarginFlowItems:self.bujuBtns withPerRowItemsCount:4 itemWidth:70 verticalMargin:20 verticalEdgeInset:20 horizontalEdgeInset:20];
}

#pragma mark - Event
-(void)handleHomeMenuClick:(UIButton *)sender{
    
    NSString *moduleCode = objc_getAssociatedObject(sender, &kMenuBtnModuleCode);
    
    if([moduleCode isEqualToString:@"OnlineFee"]){//在线缴费
        HXFinancePaymentViewController *vc = [[HXFinancePaymentViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"FeeQuery"]){//缴费查询
        HXPaymentQueryViewController *vc = [[HXPaymentQueryViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"ScoreQuery"]){//成绩查询
        HXScoreQueryViewController *vc = [[HXScoreQueryViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"BKList"]){//我的补考
        HXMyBuKaoViewController *vc = [[HXMyBuKaoViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"GraduationThesis"]){//毕业论文
        
        
    }else if([moduleCode isEqualToString:@"DegreeEnglish"]){//学位英语
        //是否可以申请学位英语
        [self canApplyDegreeEnglish];
    }else if([moduleCode isEqualToString:@"ZBList"]){//我的直播
        HXLiveCourseViewController *vc = [[HXLiveCourseViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([moduleCode isEqualToString:@"More"]){//更多
        HXFunctionCenterViewController *vc = [[HXFunctionCenterViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark -切换专业
-(void)selectMajor:(UIButton *)sender{
    if (self.majorArray.count<=0) return;
    self.showMajorView.dataArray = self.majorArray;
    [self.showMajorView show];
    ///选择回调
    WeakSelf(weakSelf);
    self.showMajorView.selectMajorCallBack = ^(BOOL isRefresh, HXMajorInfoModel * _Nonnull selectMajorModel, NSInteger idx) {
        if (isRefresh){
            //重新选定
            [HXPublicParamTool sharedInstance].major_id = selectMajorModel.major_Id;
            HXMajorInfoModel *majorInfoModel = weakSelf.majorArray[idx];
            [weakSelf.bkMajorContentBtn setTitle:majorInfoModel.majorLongName forState:UIControlStateNormal];
            [HXPublicParamTool sharedInstance].currentSemesterid = majorInfoModel.semesterid;
            [HXPublicParamTool sharedInstance].student_id = majorInfoModel.student_id;;
            //获取学习列表(当前学期和全部学期)
            [weakSelf getOnlineCourseList:majorInfoModel.semesterid];
            //重新获取首页信息
            [weakSelf getHomeStudentInfo];
            //修改专业通知
            [HXNotificationCenter postNotificationName:kChangeMajorSuccessNotification object:nil];
        }
    };
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
    return self.dataArray.count;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.courseInfoModel = self.dataArray[indexPath.row];
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
        .heightIs(0.704*kScreenWidth);
    
    
    
    self.bottomBgImageView.sd_layout
        .topSpaceToView(self.topBgImageView, 0)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .heightIs(0.437*kScreenWidth);
    
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
    
    
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    [self.mainTableView.mj_header beginRefreshing];
    
}

#pragma mark - LazyLoad
-(NSMutableArray *)majorArray{
    if(!_majorArray){
        _majorArray = [NSMutableArray array];
    }
    return _majorArray;
}

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
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
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
        
    }
    return _nameLabel;
}

- (UILabel *)personIdLabel{
    if (!_personIdLabel) {
        _personIdLabel = [[UILabel alloc] init];
        _personIdLabel.font = HXFont(13);
        _personIdLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        
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
        
        [self.btnsContainerView setupAutoMarginFlowItems:self.bujuBtns withPerRowItemsCount:4 itemWidth:70 verticalMargin:20 verticalEdgeInset:20 horizontalEdgeInset:20];
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
            [@{@"title":@"在线缴费",@"iconName":@"caiwujiaofei_icon",@"moduleCode":@"OnlineFee",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"缴费查询",@"iconName":@"payquery_icon",@"moduleCode":@"FeeQuery",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"成绩查询",@"iconName":@"scorequery_icon",@"moduleCode":@"ScoreQuery",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的补考",@"iconName":@"mybukao_icon",@"moduleCode":@"BKList",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"毕业论文",@"iconName":@"lunwen_icon",@"moduleCode":@"GraduationThesis",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"学位英语",@"iconName":@"english_icon",@"moduleCode":@"DegreeEnglish",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"我的直播",@"iconName":@"zhibo_icon",@"moduleCode":@"ZBList",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"更多",@"iconName":@"more_icon",@"moduleCode":@"More",@"isShow":@(1)} mutableCopy]
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
            //将数据关联按钮
            objc_setAssociatedObject(btn, &kMenuBtnModuleCode, dic[@"moduleCode"], OBJC_ASSOCIATION_RETAIN);
            [btn setTitle:dic[@"title"] forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:dic[@"iconName"]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleHomeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
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

-(HXNoDataTipView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[HXNoDataTipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 400)];
        _noDataView.tipTitle = @"没开通网课";
    }
    return _noDataView;
}

@end
