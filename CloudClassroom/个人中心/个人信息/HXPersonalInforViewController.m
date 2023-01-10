//
//  HXPersonalInforViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXPersonalInforViewController.h"
#import "HXGenerateSignatureViewController.h"
#import "HXPersonalInforCell.h"
#import "HXToSignCell.h"
#import "HXXinXiYouWuShowView.h"


@interface HXPersonalInforViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *backBtn;

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) UIImageView *topBgImageView;
@property(nonatomic,strong) UIView *containerView;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UILabel *basicInforLabel;

@property(nonatomic,strong) UIView *tableFooterView;
@property(nonatomic,strong) UIButton *xinXiYouWuBtn;
@property(nonatomic,strong) UIButton *xinXiWuWuBtn;
//已提交反馈
@property(nonatomic,strong) UIButton *fanKuiResultBtn;

@property(nonatomic,strong) NSArray *basicInfoArray;
@property(nonatomic,strong) NSArray *xuexiInfoArray;


@property(nonatomic,strong) NSDictionary *personalInfo;

@end

@implementation HXPersonalInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    //数据初始化
    [self dataInitialization];
    //获取个人信息
    [self getPersonalInfoList];
    
    
}

#pragma mark -数据初始化
-(void)dataInitialization{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"personalInfor" ofType:@"plist"];
    NSDictionary *personalInforDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *array1 = [personalInforDictionary objectForKey:@"basicInfoArray"];//基础信息
    NSArray *array2 = [personalInforDictionary objectForKey:@"xuexiInfoArray"];//学习信息
    
    
    self.basicInfoArray = [HXPersonalInforModel mj_objectArrayWithKeyValuesArray:array1];
    self.xuexiInfoArray = [HXPersonalInforModel mj_objectArrayWithKeyValuesArray:array2];
    
    [self.mainTableView reloadData];
}


#pragma mark - 获取个人信息
-(void)getPersonalInfoList{
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetPersonalInfoList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *array = [dictionary objectForKey:@"data"];
            NSDictionary *personalInfo = array.firstObject;
            self.personalInfo = personalInfo;
            [self.basicInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXPersonalInforModel *model = obj;
                if ([model.title isEqualToString:@"姓名"]) {
                    model.content = [personalInfo stringValueForKey:@"name"];
                }else if ([model.title isEqualToString:@"性别"]) {
                    model.content = [personalInfo stringValueForKey:@"sex"];
                }else if ([model.title isEqualToString:@"出生日期"]) {
                    model.content = [personalInfo stringValueForKey:@"birthDate"];
                }else if ([model.title isEqualToString:@"身份证号"]) {
                    model.content = [personalInfo stringValueForKey:@"personId"];
                }else if ([model.title isEqualToString:@"邮政编码"]) {
                    model.content = [personalInfo stringValueForKey:@"postCode"];
                }else if ([model.title isEqualToString:@"民族"]) {
                    model.content = [personalInfo stringValueForKey:@"nationality"];
                }else if ([model.title isEqualToString:@"政治面貌"]) {
                    model.content = [personalInfo stringValueForKey:@"politicalName"];
                }else if ([model.title isEqualToString:@"电子邮箱"]) {
                    model.content = [personalInfo stringValueForKey:@"email"];
                }else if ([model.title isEqualToString:@"工作单位"]) {
                    model.content = [personalInfo stringValueForKey:@"company"];
                }else if ([model.title isEqualToString:@"联系地址"]) {
                    model.content = [personalInfo stringValueForKey:@"contactAddr"];
                }
            }];
            
            [self.xuexiInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXPersonalInforModel *model = obj;
                if ([model.title isEqualToString:@"学号"]) {
                    model.content = [personalInfo stringValueForKey:@"studentNo"];
                }else if ([model.title isEqualToString:@"考生号"]) {
                    model.content = [personalInfo stringValueForKey:@"examineeNo"];
                }else if ([model.title isEqualToString:@"学籍状态"]) {
                    model.content = [personalInfo stringValueForKey:@"studentStateName"];
                }else if ([model.title isEqualToString:@"年级"]) {
                    model.content = [personalInfo stringValueForKey:@"enterDate"];
                }else if ([model.title isEqualToString:@"学习形式"]) {
                    model.content = [personalInfo stringValueForKey:@"studyTypeName"];
                }else if ([model.title isEqualToString:@"层次"]) {
                    model.content = [personalInfo stringValueForKey:@"educationName"];
                }else if ([model.title isEqualToString:@"专业名称"]) {
                    model.content = [personalInfo stringValueForKey:@"mmajorName"];
                }else if ([model.title isEqualToString:@"学制"]) {
                    model.content = [personalInfo stringValueForKey:@"studyYearReal"];
                }else if ([model.title isEqualToString:@"函授站"]) {
                    model.content = [personalInfo stringValueForKey:@"subSchoolName"];
                }else if ([model.title isEqualToString:@"入学日期"]) {
                    model.content = [personalInfo stringValueForKey:@"rxrq"];
                }else if ([model.title isEqualToString:@"签名图片"]) {
                    model.content = @"未签名";
                }
            }];
            //获取签名照片
            [self getStudentSignature];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 获取签名照片
-(void)getStudentSignature{
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetStudentSignature needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSDictionary *dic = [dictionary dictionaryValueForKey:@"data"];
            NSString *studentSignatureImg = [dic stringValueForKey:@"studentSignatureImg"];
            [self.xuexiInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXPersonalInforModel *model = obj;
                if ([model.title isEqualToString:@"签名图片"]) {
                    if ([HXCommonUtil isNull:studentSignatureImg]) {
                        model.content = @"未签名";
                    }else{
                        model.content = @"已签名";
                    }
                    model.signImgUrl = studentSignatureImg;
                    *stop = YES;
                    return;
                }
               
            }];
           
            NSInteger isConfirmed = [[self.personalInfo stringValueForKey:@"isConfirmed"] integerValue];
            self.fanKuiResultBtn.hidden = YES;
            self.xinXiWuWuBtn.hidden = self.xinXiYouWuBtn.hidden = (isConfirmed==1||isConfirmed==2);
            [self.headImageView sd_setImageWithURL:HXSafeURL(self.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
            [self.mainTableView reloadData];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark - 信息确认
-(void)confirmPersonalInfo:(NSString *)errorInfo isConfirmed:(NSInteger)isConfirmed{
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSString *politicalState_id = [self.personalInfo stringValueForKey:@"politicalState_id"];
    NSString *nationality = [self.personalInfo stringValueForKey:@"nationality"];
    NSString *postCode = [self.personalInfo stringValueForKey:@"postCode"];
    NSString *contactTel = [self.personalInfo stringValueForKey:@"contactTel"];
    NSString *email = [self.personalInfo stringValueForKey:@"email"];
    NSString *contactAddr = [self.personalInfo stringValueForKey:@"contactAddr"];
    NSString *company = [self.personalInfo stringValueForKey:@"company"];
    
    
    NSDictionary *dic =@{
        @"isconfirmed":@(isConfirmed),//1表示确认无误 2表示确认有误
        @"studentid":HXSafeString(studentId),
        @"politicalstate_id":politicalState_id,
        @"nationality":nationality,
        @"postcode":postCode,
        @"contacttel":contactTel,
        @"email":email,
        @"contactaddr":contactAddr,
        @"company":company,
        @"errorinfo":HXSafeString(errorInfo)
        
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_ConfirmYesor needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            [self.view showTostWithMessage:[dictionary stringValueForKey:@"message"]];
            self.fanKuiResultBtn.hidden = NO;
            self.xinXiWuWuBtn.hidden = self.xinXiYouWuBtn.hidden = YES;
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}



#pragma mark - Event
-(void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

//跳转去签名
-(void)toSign:(UIButton *)sender{
    HXGenerateSignatureViewController *vc = [[HXGenerateSignatureViewController alloc] init];
    WeakSelf(weakSelf);
    vc.generateSignatureCallBack = ^{
        StrongSelf(strongSelf);
        //获取签名照片
        [strongSelf getStudentSignature];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showXinXiYouWuShowView{
    HXXinXiYouWuShowView *xinXiYouWuShowView = [[HXXinXiYouWuShowView alloc] init];
    [xinXiYouWuShowView show];
    WeakSelf(weakSelf);
    xinXiYouWuShowView.confirmErrorInfoCallBack = ^(NSString * _Nonnull errorInfo) {
        StrongSelf(strongSelf);
        [strongSelf confirmPersonalInfo:errorInfo isConfirmed:2];
    };
}

-(void)clickXinXiWuWuBtn:(UIButton *)sender{
    [self confirmPersonalInfo:nil isConfirmed:1];
}


#pragma mark - <UIScrollViewDelegate>根据滑动距离来变化导航栏背景色的alpha
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
    CGFloat y = scrollView.contentOffset.y;
    CGFloat alpha =(y*1.0)/kNavigationBarHeight;
    self.navBarView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, alpha);
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?self.basicInfoArray.count:self.xuexiInfoArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==1?60:0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
        view.backgroundColor = UIColor.whiteColor;
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = HXBoldFont(17);
        titleLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        titleLabel.text = @"学习信息";
        [view addSubview:titleLabel];
        titleLabel.sd_layout
        .bottomSpaceToView(view, 10)
        .leftSpaceToView(view, 20)
        .rightSpaceToView(view, 20)
        .heightIs(24);
        return view;
    }else{
        return nil;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HXPersonalInforModel *personalInforModel =(indexPath.section==0?self.basicInfoArray[indexPath.row]:self.xuexiInfoArray[indexPath.row]);
    if ([personalInforModel.title isEqualToString:@"签名图片"]) {
        return 57;
    }else{
        CGFloat rowHeight = [tableView cellHeightForIndexPath:indexPath
                                                        model:personalInforModel keyPath:@"personalInforModel"
                                                    cellClass:([HXPersonalInforCell class])
                                             contentViewWidth:kScreenWidth];
        return rowHeight;
    }
    
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    HXPersonalInforModel *personalInforModel =(indexPath.section==0?self.basicInfoArray[indexPath.row]:self.xuexiInfoArray[indexPath.row]);
    if ([personalInforModel.title isEqualToString:@"签名图片"]) {
        static NSString *toSignCellIdentifier = @"HXToSignCellIdentifier";
        HXToSignCell *toSignCell = [tableView dequeueReusableCellWithIdentifier:toSignCellIdentifier];
        if (!toSignCell) {
            toSignCell = [[HXToSignCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:toSignCellIdentifier];
        }
        [toSignCell.signBtn addTarget:self action:@selector(toSign:) forControlEvents:UIControlEventTouchUpInside];
        toSignCell.selectionStyle = UITableViewCellSelectionStyleNone;
        toSignCell.personalInforModel = personalInforModel;
        return toSignCell;
    }else{
        static NSString *personalInforCellIdentifier = @"HXPersonalInforCellIdentifier";
        HXPersonalInforCell *cell = [tableView dequeueReusableCellWithIdentifier:personalInforCellIdentifier];
        if (!cell) {
            cell = [[HXPersonalInforCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:personalInforCellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.personalInforModel = personalInforModel;
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.navBarView];
    
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.backBtn];
    
    self.navBarView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(kNavigationBarHeight);
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.navBarView, kStatusBarHeight)
    .centerXEqualToView(self.navBarView)
    .widthIs(100)
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.backBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftEqualToView(self.navBarView)
    .widthIs(60)
    .heightIs(44);
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, 0);
    
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
        _titleLabel.text = @"个人信息";
    }
    return _titleLabel;
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navi_whiteback"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}


-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.bounces = NO;
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
        _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, kScreenBottomMargin, 0);
        _mainTableView.scrollIndicatorInsets = _mainTableView.contentInset;
        _mainTableView.tableHeaderView = self.tableHeaderView;
        _mainTableView.tableFooterView = self.tableFooterView;
        _mainTableView.showsVerticalScrollIndicator = NO;
       
    }
    return _mainTableView;
}

-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] init];
        _tableHeaderView.sd_layout.widthIs(kScreenWidth);
        [_tableHeaderView addSubview:self.topBgImageView];
        [_tableHeaderView addSubview:self.containerView];
        [_tableHeaderView addSubview:self.headImageView];
        [self.containerView addSubview:self.basicInforLabel];
       
        
        self.topBgImageView.sd_layout
        .topSpaceToView(_tableHeaderView, 0)
        .leftEqualToView(_tableHeaderView)
        .rightEqualToView(_tableHeaderView)
        .heightIs(183);
        
        self.containerView.sd_layout
        .topSpaceToView(_tableHeaderView, 160)
        .leftEqualToView(_tableHeaderView)
        .rightEqualToView(_tableHeaderView)
        .heightIs(90);
        [self.containerView updateLayout];
        
        self.headImageView.sd_layout
        .centerXEqualToView(_tableHeaderView)
        .topEqualToView(self.containerView).offset(-40)
        .widthIs(80)
        .heightEqualToWidth();
        self.headImageView.sd_cornerRadiusFromHeightRatio = @0.5;
        
        self.basicInforLabel.sd_layout
        .bottomSpaceToView(self.containerView, 20)
        .leftSpaceToView(self.containerView, 20)
        .rightSpaceToView(self.containerView, 20)
        .heightIs(24);
       
        
        // 左上和右上为圆角
        UIBezierPath *cornerRadiusPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(17, 17)];
        CAShapeLayer *cornerRadiusLayer = [ [CAShapeLayer alloc ] init];
        cornerRadiusLayer.frame = self.containerView.bounds;
        cornerRadiusLayer.path = cornerRadiusPath.CGPath;
        self.containerView.layer.mask = cornerRadiusLayer;
        
        // 模糊
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualView.layer.cornerRadius = 8;
        visualView.frame = self.containerView.bounds;
        [self.containerView addSubview:visualView];
        [self.containerView insertSubview:visualView belowSubview:self.basicInforLabel];
       
    
        [_tableHeaderView setupAutoHeightWithBottomView:self.containerView bottomMargin:0];
        
        [_tableHeaderView setNeedsLayout];
        [_tableHeaderView layoutIfNeeded];
    }
    return _tableHeaderView;
}

-(UIImageView *)topBgImageView{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.clipsToBounds = YES;
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.image = [UIImage imageNamed:@"personalinforbg_icon"];
    }
    return _topBgImageView;
}



-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.clipsToBounds = YES;
        _containerView.layer.borderWidth = 1;
        _containerView.layer.borderColor = UIColor.whiteColor.CGColor;
        _containerView.backgroundColor =COLOR_WITH_ALPHA(0xFFFFFF, 0.3);
    }
    return _containerView;
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

-(UILabel *)basicInforLabel{
    if (!_basicInforLabel) {
        _basicInforLabel = [[UILabel alloc] init];
        _basicInforLabel.textAlignment = NSTextAlignmentLeft;
        _basicInforLabel.font = HXBoldFont(17);
        _basicInforLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _basicInforLabel.text = @"基础信息";
    }
    return _basicInforLabel;
}



-(UIView *)tableFooterView{
    if (!_tableFooterView) {
        _tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        _tableFooterView.backgroundColor=UIColor.whiteColor;
        _tableFooterView.clipsToBounds = YES;
        [_tableFooterView addSubview:self.xinXiWuWuBtn];
        [_tableFooterView addSubview:self.xinXiYouWuBtn];
        [_tableFooterView addSubview:self.fanKuiResultBtn];
        
       self.xinXiYouWuBtn.sd_layout
        .topSpaceToView(_tableFooterView, 30)
        .leftSpaceToView(_tableFooterView, _kpw(63))
        .widthIs(113)
        .heightIs(36);
        self.xinXiYouWuBtn.sd_cornerRadiusFromHeightRatio=@0.5;
        
        self.xinXiWuWuBtn.sd_layout
         .centerYEqualToView(self.xinXiYouWuBtn)
         .rightSpaceToView(_tableFooterView, _kpw(63))
         .widthRatioToView(self.xinXiYouWuBtn, 1)
         .heightRatioToView(self.xinXiYouWuBtn, 1);
         self.xinXiWuWuBtn.sd_cornerRadiusFromHeightRatio=@0.5;
        
        self.fanKuiResultBtn.sd_layout
        .centerYEqualToView(self.xinXiYouWuBtn)
        .centerXEqualToView(_tableFooterView)
        .widthIs(103)
        .heightIs(26);
        self.fanKuiResultBtn.sd_cornerRadius =@2;
    
    }
    return _tableFooterView;
}

-(UIButton *)xinXiYouWuBtn{
    if (!_xinXiYouWuBtn) {
        _xinXiYouWuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _xinXiYouWuBtn.titleLabel.font = HXBoldFont(14);
        _xinXiYouWuBtn.backgroundColor= UIColor.whiteColor;
        _xinXiYouWuBtn.layer.borderWidth =1;
        _xinXiYouWuBtn.layer.borderColor =COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        [_xinXiYouWuBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_xinXiYouWuBtn setTitle:@"信息有误" forState:UIControlStateNormal];
        [_xinXiYouWuBtn setImage:[UIImage imageNamed:@"dacha_icon"] forState:UIControlStateNormal];
        [_xinXiYouWuBtn addTarget:self action:@selector(showXinXiYouWuShowView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _xinXiYouWuBtn;
}

-(UIButton *)xinXiWuWuBtn{
    if (!_xinXiWuWuBtn) {
        _xinXiWuWuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _xinXiWuWuBtn.titleLabel.font = HXBoldFont(14);
        _xinXiWuWuBtn.backgroundColor= COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_xinXiWuWuBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_xinXiWuWuBtn setTitle:@"信息无误" forState:UIControlStateNormal];
        [_xinXiWuWuBtn setImage:[UIImage imageNamed:@"dagou_icon"] forState:UIControlStateNormal];
        [_xinXiWuWuBtn addTarget:self action:@selector(clickXinXiWuWuBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _xinXiWuWuBtn;
}

-(UIButton *)fanKuiResultBtn{
    if (!_fanKuiResultBtn) {
        _fanKuiResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fanKuiResultBtn.titleLabel.font = HXBoldFont(12);
        _fanKuiResultBtn.backgroundColor= COLOR_WITH_ALPHA(0xEAEAEA, 1);
        [_fanKuiResultBtn setTitleColor:COLOR_WITH_ALPHA(0x818181, 1) forState:UIControlStateNormal];
        [_fanKuiResultBtn setTitle:@"已提交反馈" forState:UIControlStateNormal];
        _fanKuiResultBtn.hidden = YES;
    }
    return _fanKuiResultBtn;
}


@end
