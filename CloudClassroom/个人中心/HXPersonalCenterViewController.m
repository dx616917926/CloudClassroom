//
//  HXPersonalCenterViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "HXPersonalCenterViewController.h"
#import "HXPersonalInforViewController.h"//个人信息
#import "HXMyMessageViewController.h"//我的消息
#import "HXUploadIDPhotoViewController.h"//证件照上传
#import "HXModifyPwdViewController.h"//修改密码
#import "HXZiLiaoDownLoadViewController.h"//资料下载
#import "HXZaiXianXuanKeViewController.h"//在线选课
#import "HXSettingViewController.h"//设置
#import "HXZiLiaoUploadViewController.h"//资料上传
#import "SDWebImage.h"
#import "UIImage+Extension.h"
#import "HXFaceRecognitionTool.h"
#import "HXHomeStudentInfoModel.h"
#import "HXMyMessageInfoModel.h"
#import "HXHomeMenuModel.h"

@interface HXPersonalCenterViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIImageView *topBgImageView;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *xueHaoLabel;
@property(nonatomic,strong) UIButton *personalInfoBtn;

@property(nonatomic,strong) UIView *keChenContainerView;
@property(nonatomic,strong) UIView *lineView;
//本期合格课程(门)
@property(nonatomic,strong) UIControl *benQiControl;
@property(nonatomic,strong) UILabel *benQiNumLabel;
@property(nonatomic,strong) UILabel *benQiTitleLabel;
//累计合格课程(门)
@property(nonatomic,strong) UIControl *leiJiControl;
@property(nonatomic,strong) UILabel *leiJiNumLabel;
@property(nonatomic,strong) UILabel *leiJiTitleLabel;

@property(nonatomic,strong) UIView *middleContainerView;
@property(nonatomic,strong) NSMutableArray *middleBujuArray;
@property(nonatomic,strong) NSMutableArray *middleBujuBtns;


@property(nonatomic,strong) UIImageView *messageRedImageView;
@property(nonatomic,strong) UILabel *messageNumlabel;


@property(nonatomic,strong) UIView *bottomContainerView;
@property(nonatomic,strong) NSMutableArray *bottomBujuArray;
@property(nonatomic,strong) NSMutableArray *bottomBujuBtns;

@property(nonatomic,strong) HXHomeStudentInfoModel *homeStudentInfoModel;

@end

@implementation HXPersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //
    [self loadData];
    //登录成功的通知
    [HXNotificationCenter addObserver:self selector:@selector(loadData) name:LOGINSUCCESS object:nil];
    //监听修改专业通知
    [HXNotificationCenter addObserver:self selector:@selector(loadData) name:kChangeMajorSuccessNotification object:nil];
}

-(void)loadData{
    //获取首页信息
    [self getHomeStudentInfo];
    //获取未读消息数
    [self getNoReadCount];
    //获取个人中心菜单
    [self getMiddleMenuList];
    //获取个人中心附件菜单
    [self getBottomMenuList];
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
        [self.mainScrollView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.homeStudentInfoModel = [HXHomeStudentInfoModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            [[SDImageCache sharedImageCache] clearMemory];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            [self.headImageView sd_setImageWithURL:HXSafeURL(self.homeStudentInfoModel.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
            self.nameLabel.text = self.homeStudentInfoModel.name;
            
            self.benQiNumLabel.text = self.homeStudentInfoModel.termQuaCourseCount;
            self.leiJiNumLabel.text = self.homeStudentInfoModel.totalQuaCourseCount;
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainScrollView.mj_header endRefreshing];
    }];
    
}


#pragma mark - 获取个人中心菜单
-(void)getMiddleMenuList{
    NSDictionary *dic = @{
        @"type":@(2)//菜单类型：1首页菜单，2个人中心菜单，3个人中心附件菜单
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetHomeMenu needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXHomeMenuModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self refreshMiddleMenuLayout:list];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 获取个人中心附件菜单
-(void)getBottomMenuList{
    NSDictionary *dic = @{
        @"type":@(3)//菜单类型：1首页菜单，2个人中心菜单，3个人中心附件菜单
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetHomeMenu needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXHomeMenuModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self refreshBottomMenuLayout:list];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 获取未读消息数
-(void)getNoReadCount{
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId),
        @"type":@(1)//类型: 1学生，2老师，3管理员

    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetNoReadCount needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSDictionary *dic= [dictionary dictionaryValueForKey:@"data"];
        if (success) {
            //查出是否有未读
            NSInteger count = [[dic stringValueForKey:@"noReadCount"] integerValue];
            if (count>0) {
                self.messageRedImageView.hidden = NO;
                self.messageNumlabel.text = count>99?@"99+":HXIntToString(count);
            }else{
                self.messageRedImageView.hidden = YES;
                self.messageNumlabel.text = nil;
            }
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark - 重新布局个人中心菜单
-(void)refreshMiddleMenuLayout:(NSArray<HXHomeMenuModel*>*)list{
    ///移除重新布局
    [self.middleBujuBtns removeAllObjects];
    [self.middleContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //移除关联对象
        objc_removeAssociatedObjects(obj);
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    
    [list enumerateObjectsUsingBlock:^(HXHomeMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.isShow==1){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            //将数据关联按钮
            objc_setAssociatedObject(btn, &kMenuBtnModuleCode, obj.moduleCode, OBJC_ASSOCIATION_RETAIN);
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXFont(13);
            [btn setTitle:obj.moduleName forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn sd_setImageWithURL:HXSafeURL(obj.moduleIcon)  forState:UIControlStateNormal placeholderImage:nil];
            [btn addTarget:self action:@selector(handleMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.middleContainerView addSubview:btn];
            [self.middleBujuBtns addObject:btn];
            
            btn.sd_layout.heightIs(60);
            btn.imageView.sd_layout
                .centerXEqualToView(btn)
                .topSpaceToView(btn, 0)
                .widthIs(30)
                .heightEqualToWidth();
            
            btn.titleLabel.sd_layout
                .bottomSpaceToView(btn, 0)
                .leftEqualToView(btn)
                .rightEqualToView(btn)
                .heightIs(17);
        }
    }];
    [self.middleContainerView setupAutoMarginFlowItems:self.middleBujuBtns withPerRowItemsCount:4 itemWidth:70 verticalMargin:20 verticalEdgeInset:40 horizontalEdgeInset:15];
}

#pragma mark - 重新布局个人中心附件菜单
-(void)refreshBottomMenuLayout:(NSArray<HXHomeMenuModel*>*)list{
    ///移除重新布局
    [self.bottomBujuBtns removeAllObjects];
    [self.bottomContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //移除关联对象
        objc_removeAssociatedObjects(obj);
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    
    [list enumerateObjectsUsingBlock:^(HXHomeMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.isShow==1){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            //将数据关联按钮
            objc_setAssociatedObject(btn, &kMenuBtnModuleCode, obj.moduleCode, OBJC_ASSOCIATION_RETAIN);
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXFont(13);
            [btn setTitle:obj.moduleName forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn sd_setImageWithURL:HXSafeURL(obj.moduleIcon)  forState:UIControlStateNormal placeholderImage:nil];
            [btn addTarget:self action:@selector(handleMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomContainerView addSubview:btn];
            [self.bottomBujuBtns addObject:btn];
            
            btn.sd_layout.heightIs(60);
            btn.imageView.sd_layout
                .centerXEqualToView(btn)
                .topSpaceToView(btn, 0)
                .widthIs(30)
                .heightEqualToWidth();
            
            btn.titleLabel.sd_layout
                .bottomSpaceToView(btn, 0)
                .leftEqualToView(btn)
                .rightEqualToView(btn)
                .heightIs(17);
        }
    }];
    [self.bottomContainerView setupAutoMarginFlowItems:self.bottomBujuBtns withPerRowItemsCount:4 itemWidth:70 verticalMargin:20 verticalEdgeInset:26 horizontalEdgeInset:15];
}

#pragma mark -Event

-(void)checkPersonalInfor:(UIButton *)sender{
    HXPersonalInforViewController *vc = [[HXPersonalInforViewController alloc] init];
    vc.sc_navigationBarHidden = YES;
    vc.hidesBottomBarWhenPushed = YES;
    vc.imgUrl = self.homeStudentInfoModel.imgUrl;
    [self.navigationController pushViewController:vc animated:YES];
}



-(void)handleMenuClick:(UIButton *)sender{
    
    NSString *moduleCode = objc_getAssociatedObject(sender, &kMenuBtnModuleCode);
    
    if([moduleCode isEqualToString:@"MessageList"]){//我的消息
        HXMyMessageViewController *vc = [[HXMyMessageViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"UpPhoto"]){//证件照上传
        HXUploadIDPhotoViewController *vc = [[HXUploadIDPhotoViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"facerRZ"]){//人脸识别
        HXFaceConfigObject *faceConfig = [[HXFaceConfigObject alloc] init];
        faceConfig.imageStatus = ([HXCommonUtil isNull:self.homeStudentInfoModel.imgUrl]?-1:1);
        faceConfig.imageURL = self.homeStudentInfoModel.imgUrl;
        faceConfig.courseType = 4;
        HXFaceRecognitionView *faceView = [[HXFaceRecognitionView alloc] init];
        faceView.status = HXFaceRecognitionStatusSimulate;
        faceView.faceConfig = faceConfig;
        [faceView showInViewController:self];
    }else if([moduleCode isEqualToString:@"UpPwd"]){//修改密码
        HXModifyPwdViewController *vc = [[HXModifyPwdViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"Information"]){//资料下载
        HXZiLiaoDownLoadViewController *vc = [[HXZiLiaoDownLoadViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"ChooseCourse"]){//在线选课
        HXZaiXianXuanKeViewController *vc = [[HXZaiXianXuanKeViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"Set"]){//设置
        HXSettingViewController *vc = [[HXSettingViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"DataUpload"]){//资料上传
        HXZiLiaoUploadViewController *vc = [[HXZiLiaoUploadViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([moduleCode isEqualToString:@"Registration"]){//毕业登记表
       
    }
    
}

#pragma mark - <UIScrollViewDelegate>根据滑动距离来变化导航栏背景色的alpha
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
    CGFloat y = scrollView.contentOffset.y;
    CGFloat alpha =(y*1.0)/kNavigationBarHeight;
    self.navBarView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, alpha);
}

#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = COLOR_WITH_ALPHA(0xF3F5F9, 1);
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.navBarView];
    
    [self.navBarView addSubview:self.titleLabel];
    
    [self.mainScrollView addSubview:self.topBgImageView];
    [self.mainScrollView addSubview:self.headImageView];
    [self.mainScrollView addSubview:self.nameLabel];
    [self.mainScrollView addSubview:self.xueHaoLabel];
    [self.mainScrollView addSubview:self.personalInfoBtn];
    [self.mainScrollView addSubview:self.middleContainerView];
    [self.mainScrollView addSubview:self.keChenContainerView];
    [self.mainScrollView addSubview:self.bottomContainerView];
    
    [self.keChenContainerView addSubview:self.benQiControl];
    [self.keChenContainerView addSubview:self.lineView];
    [self.keChenContainerView addSubview:self.leiJiControl];
    [self.benQiControl addSubview:self.benQiNumLabel];
    [self.benQiControl addSubview:self.benQiTitleLabel];
    [self.leiJiControl addSubview:self.leiJiNumLabel];
    [self.leiJiControl addSubview:self.leiJiTitleLabel];
    
    
    
    
    self.navBarView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(kNavigationBarHeight);
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.navBarView, kStatusBarHeight)
    .centerXEqualToView(self.navBarView)
    .widthIs(200)
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.mainScrollView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, kTabBarHeight);
    
    
    self.topBgImageView.sd_layout
    .topSpaceToView(self.mainScrollView, 0)
    .leftEqualToView(self.mainScrollView)
    .rightEqualToView(self.mainScrollView)
    .heightIs(400);
    
    
    self.headImageView.sd_layout
    .topSpaceToView(self.mainScrollView, kNavigationBarHeight+30)
    .leftSpaceToView(self.mainScrollView, 40)
    .widthIs(46)
    .heightEqualToWidth();
    self.headImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.personalInfoBtn.sd_layout
    .centerYEqualToView(self.headImageView)
    .rightSpaceToView(self.mainScrollView, 12)
    .widthIs(100)
    .heightIs(30);
    
    self.personalInfoBtn.imageView.sd_layout
    .centerYEqualToView(self.personalInfoBtn)
    .rightSpaceToView(self.personalInfoBtn, 22)
    .widthIs(7)
    .heightIs(13);
    
    self.personalInfoBtn.titleLabel.sd_layout
    .centerYEqualToView(self.personalInfoBtn)
    .rightSpaceToView(self.personalInfoBtn.imageView, 5)
    .leftEqualToView(self.personalInfoBtn)
    .heightIs(17);
    
    
    self.nameLabel.sd_layout
    .topEqualToView(self.headImageView).offset(3)
    .leftSpaceToView(self.headImageView, 16)
    .rightSpaceToView(self.personalInfoBtn, 16)
    .heightIs(23);
    
    self.xueHaoLabel.sd_layout
    .topSpaceToView(self.nameLabel, 0)
    .leftEqualToView(self.nameLabel)
    .rightEqualToView(self.nameLabel)
    .heightIs(17);
    
    
    self.keChenContainerView.sd_layout
    .topSpaceToView(self.headImageView, 34)
    .leftSpaceToView(self.mainScrollView, 24)
    .rightSpaceToView(self.mainScrollView, 24)
    .heightIs(68);
    
    self.middleContainerView.sd_layout
    .topSpaceToView(self.keChenContainerView, -20)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    
    self.bottomContainerView.sd_layout
    .topSpaceToView(self.middleContainerView, 16)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    
    self.lineView.sd_layout
    .centerYEqualToView(self.keChenContainerView)
    .centerXEqualToView(self.keChenContainerView)
    .heightIs(34)
    .widthIs(1);
    
    self.benQiControl.sd_layout
    .topEqualToView(self.keChenContainerView)
    .leftEqualToView(self.keChenContainerView)
    .rightSpaceToView(self.lineView, 0)
    .bottomEqualToView(self.keChenContainerView);
    
    self.leiJiControl.sd_layout
    .topEqualToView(self.keChenContainerView)
    .rightEqualToView(self.keChenContainerView)
    .leftSpaceToView(self.lineView, 0)
    .bottomEqualToView(self.keChenContainerView);
    
    
    self.benQiNumLabel.sd_layout
    .topSpaceToView(self.benQiControl, 13)
    .leftEqualToView(self.benQiControl)
    .rightEqualToView(self.benQiControl)
    .heightIs(23);
    
    self.benQiTitleLabel.sd_layout
    .bottomSpaceToView(self.benQiControl, 13)
    .leftEqualToView(self.benQiControl)
    .rightEqualToView(self.benQiControl)
    .heightIs(17);
    
    self.leiJiNumLabel.sd_layout
    .topSpaceToView(self.leiJiControl, 13)
    .leftEqualToView(self.leiJiControl)
    .rightEqualToView(self.leiJiControl)
    .heightIs(23);
    
    self.leiJiTitleLabel.sd_layout
    .bottomSpaceToView(self.leiJiControl, 13)
    .leftEqualToView(self.leiJiControl)
    .rightEqualToView(self.leiJiControl)
    .heightIs(17);
    
    
    
    for (UIButton *btn in self.middleBujuBtns) {
        btn.sd_layout.heightIs(60);
        btn.imageView.sd_layout
        .centerXEqualToView(btn)
        .topSpaceToView(btn, 0)
        .widthIs(30)
        .heightEqualToWidth();
        
        btn.titleLabel.sd_layout
        .bottomSpaceToView(btn, 0)
        .leftEqualToView(btn)
        .rightEqualToView(btn)
        .heightIs(17);
        if ([[btn titleForState:UIControlStateNormal] isEqualToString:@"我的消息"]) {
            [btn addSubview:self.messageRedImageView];
            [self.messageRedImageView addSubview:self.messageNumlabel];
            self.messageRedImageView.sd_layout
            .topEqualToView(btn).offset(-10)
            .rightEqualToView(btn).offset(10)
            .widthIs(30)
            .heightIs(15);
            
            self.messageNumlabel.sd_layout
            .centerYEqualToView(self.messageRedImageView)
            .leftSpaceToView(self.messageRedImageView, 2)
            .rightSpaceToView(self.messageRedImageView, 2)
            .heightIs(13);
        }
    }
    
    [self.middleContainerView setupAutoMarginFlowItems:self.middleBujuBtns withPerRowItemsCount:4 itemWidth:70 verticalMargin:20 verticalEdgeInset:40 horizontalEdgeInset:15];
    
    for (UIButton *btn in self.bottomBujuBtns) {
        btn.sd_layout.heightIs(60);
        btn.imageView.sd_layout
        .centerXEqualToView(btn)
        .topSpaceToView(btn, 0)
        .widthIs(30)
        .heightEqualToWidth();
        
        btn.titleLabel.sd_layout
        .bottomSpaceToView(btn, 0)
        .leftEqualToView(btn)
        .rightEqualToView(btn)
        .heightIs(17);
    }
    
    [self.bottomContainerView setupAutoMarginFlowItems:self.bottomBujuBtns withPerRowItemsCount:4 itemWidth:70 verticalMargin:20 verticalEdgeInset:26 horizontalEdgeInset:15];
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.bottomContainerView bottomMargin:100];
    
    // 下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    header.automaticallyChangeAlpha = YES;
    self.mainScrollView.mj_header = header;
    [self.mainScrollView.mj_header beginRefreshing];
}

#pragma mark - LazyLoad

-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc] init];
        _navBarView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 0);
    }
    return _navBarView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _titleLabel.text = @"个人中心";
    }
    return _titleLabel;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.clearColor;
        _mainScrollView.bounces = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        if (@available(iOS 11.0, *)) {
            _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _mainScrollView;
}


-(UIImageView *)topBgImageView{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.clipsToBounds = YES;
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.image = [UIImage imageNamed:@"personalcenterbg_icon"];
    }
    return _topBgImageView;
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



- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = HXBoldFont(16);
        _nameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _nameLabel;
}

- (UILabel *)xueHaoLabel{
    if (!_xueHaoLabel) {
        _xueHaoLabel = [[UILabel alloc] init];
        _xueHaoLabel.font = HXFont(13);
        _xueHaoLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _xueHaoLabel.text = [NSString stringWithFormat:@"学号 %@",[HXPublicParamTool sharedInstance].studentNo];
    }
    return _xueHaoLabel;
}

- (UIButton *)personalInfoBtn{
    if (!_personalInfoBtn) {
        _personalInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _personalInfoBtn.titleLabel.font = HXFont(13);
        _personalInfoBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_personalInfoBtn setTitleColor:COLOR_WITH_ALPHA(0x737EA2, 1) forState:UIControlStateNormal];
        [_personalInfoBtn setImage:[UIImage imageNamed:@"smallblackright_arrow"] forState:UIControlStateNormal];
        [_personalInfoBtn setTitle:@"个人信息" forState:UIControlStateNormal];
        [_personalInfoBtn addTarget:self action:@selector(checkPersonalInfor:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _personalInfoBtn;
}

- (UIView *)keChenContainerView{
    if (!_keChenContainerView) {
        _keChenContainerView = [[UIView alloc] init];
        _keChenContainerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _keChenContainerView.layer.cornerRadius = 8;
        _keChenContainerView.layer.shadowColor = COLOR_WITH_ALPHA(0xB6C3DB, 0.24).CGColor;
        _keChenContainerView.layer.shadowOffset = CGSizeMake(0,2);
        _keChenContainerView.layer.shadowOpacity = 1;
        _keChenContainerView.layer.shadowRadius = 15;
    }
    return _keChenContainerView;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = COLOR_WITH_ALPHA(0xE6E7EC, 1);
    }
    return _lineView;
}

- (UIControl *)benQiControl{
    if (!_benQiControl) {
        _benQiControl = [[UIControl alloc] init];
        _benQiControl.backgroundColor = UIColor.clearColor;
    }
    return _benQiControl;
}

- (UILabel *)benQiNumLabel{
    if (!_benQiNumLabel) {
        _benQiNumLabel = [[UILabel alloc] init];
        _benQiNumLabel.textAlignment = NSTextAlignmentCenter;
        _benQiNumLabel.font = HXBoldFont(16);
        _benQiNumLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _benQiNumLabel;
}

- (UILabel *)benQiTitleLabel{
    if (!_benQiTitleLabel) {
        _benQiTitleLabel = [[UILabel alloc] init];
        _benQiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _benQiTitleLabel.font = HXFont(12);
        _benQiTitleLabel.textColor = COLOR_WITH_ALPHA(0x737EA3, 1);
        _benQiTitleLabel.text = @"本期合格课程(门)";
    }
    return _benQiTitleLabel;
}



- (UIControl *)leiJiControl{
    if (!_leiJiControl) {
        _leiJiControl = [[UIControl alloc] init];
        _leiJiControl.backgroundColor = UIColor.clearColor;
    }
    return _leiJiControl;
}

- (UILabel *)leiJiNumLabel{
    if (!_leiJiNumLabel) {
        _leiJiNumLabel = [[UILabel alloc] init];
        _leiJiNumLabel.textAlignment = NSTextAlignmentCenter;
        _leiJiNumLabel.font = HXBoldFont(16);
        _leiJiNumLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _leiJiNumLabel;
}

- (UILabel *)leiJiTitleLabel{
    if (!_leiJiTitleLabel) {
        _leiJiTitleLabel = [[UILabel alloc] init];
        _leiJiTitleLabel.textAlignment = NSTextAlignmentCenter;
        _leiJiTitleLabel.font = HXFont(12);
        _leiJiTitleLabel.textColor = COLOR_WITH_ALPHA(0x737EA3, 1);
        _leiJiTitleLabel.text = @"累计合格课程(门)";
    }
    return _leiJiTitleLabel;
}

-(NSMutableArray *)middleBujuArray{
    if (!_middleBujuArray) {
        _middleBujuArray = [NSMutableArray array];
        [_middleBujuArray addObjectsFromArray:@[
            [@{@"title":@"我的消息",@"iconName":@"mymessage_icon",@"moduleCode":@"MessageList",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"证件照上传",@"iconName":@"personidupload_icon",@"moduleCode":@"UpPhoto",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"人脸识别",@"iconName":@"facerecognition_icon",@"moduleCode":@"FacerRZ",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"修改密码",@"iconName":@"changepwd_icon",@"moduleCode":@"UpPwd",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"资料下载",@"iconName":@"ziliaodownload_icon",@"moduleCode":@"Information",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"在线选课",@"iconName":@"zaixianxuabke_icon",@"moduleCode":@"ChooseCourse",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"设置",@"iconName":@"setting_icon",@"moduleCode":@"Set",@"isShow":@(1)} mutableCopy]
        ]];
    }
    return _middleBujuArray;
}


-(NSMutableArray *)middleBujuBtns{
    if (!_middleBujuBtns) {
        _middleBujuBtns = [NSMutableArray array];
    }
    return _middleBujuBtns;
}

- (UIView *)middleContainerView{
    if (!_middleContainerView) {
        _middleContainerView = [[UIView alloc] init];
        _middleContainerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _middleContainerView.layer.cornerRadius = 10;
        for (int i = 0; i<self.middleBujuArray.count; i++) {
            NSDictionary *dic = self.middleBujuArray[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXBoldFont(13);
            //将数据关联按钮
            objc_setAssociatedObject(btn, &kMenuBtnModuleCode, dic[@"moduleCode"], OBJC_ASSOCIATION_RETAIN);
            [btn setTitle:dic[@"title"] forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:dic[@"iconName"]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [_middleContainerView addSubview:btn];
            [self.middleBujuBtns addObject:btn];
        }
    }
    return _middleContainerView;
}



-(UIImageView *)messageRedImageView{
    if (!_messageRedImageView) {
        _messageRedImageView = [[UIImageView alloc] init];
        _messageRedImageView.image = [UIImage resizedImageWithName:@"messagered_icon"];
        _messageRedImageView.hidden = YES;
    }
    return _messageRedImageView;
}

-(UILabel *)messageNumlabel{
    if (!_messageNumlabel) {
        _messageNumlabel = [[UILabel alloc] init];
        _messageNumlabel.textAlignment = NSTextAlignmentCenter;
        _messageNumlabel.textColor = UIColor.whiteColor;
        _messageNumlabel.font = HXBoldFont(11);
    }
    return _messageNumlabel;
}


-(NSMutableArray *)bottomBujuArray{
    if (!_bottomBujuArray) {
        _bottomBujuArray = [NSMutableArray array];
        [_bottomBujuArray addObjectsFromArray:@[
            [@{@"title":@"资料上传",@"iconName":@"ziliaoupload_icon",@"moduleCode":@"DataUpload",@"isShow":@(1)} mutableCopy],
            [@{@"title":@"毕业登记表",@"iconName":@"dengjibiao_icon",@"moduleCode":@"Registration",@"isShow":@(1)} mutableCopy]
        ]];
    }
    return _bottomBujuArray;
}

-(NSMutableArray *)bottomBujuBtns{
    if (!_bottomBujuBtns) {
        _bottomBujuBtns = [NSMutableArray array];
    }
    return _bottomBujuBtns;
}

- (UIView *)bottomContainerView{
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        _bottomContainerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _bottomContainerView.layer.cornerRadius = 10;
        for (int i = 0; i<self.bottomBujuArray.count; i++) {
            NSDictionary *dic = self.bottomBujuArray[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.font = HXBoldFont(13);
            //将数据关联按钮
            objc_setAssociatedObject(btn, &kMenuBtnModuleCode, dic[@"moduleCode"], OBJC_ASSOCIATION_RETAIN);
            [btn setTitle:dic[@"title"] forState:UIControlStateNormal];
            [btn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:dic[@"iconName"]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleMenuClick:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomContainerView addSubview:btn];
            [self.bottomBujuBtns addObject:btn];
        }
    }
    return _bottomContainerView;
}

@end
