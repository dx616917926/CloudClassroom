//
//  HXLoginViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "HXLoginViewController.h"
#import "UIView+TransitionColor.h"
#import "HXSchoolVerifyViewController.h"
#import "HXFindPasswordViewController.h"
#import "AppDelegate.h"
#import "SDWebImage.h"

@interface HXLoginViewController ()<UITextFieldDelegate>

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *scanBtn;

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIImageView *schoolLogoImageView;
@property(nonatomic,strong) UILabel *schoolNameLabel;
@property(nonatomic,strong) UILabel *pingTaiLabel;

@property(nonatomic,strong) UIView *containerView;
@property(nonatomic,strong) UIButton *accountBtn;
@property(nonatomic,strong) UITextField *accountTextField;
@property(nonatomic,strong) UIButton *pwdBtn;
@property(nonatomic,strong) UITextField *pwdTextField;

@property(nonatomic,strong) UIButton *retrievePwdBtn;
@property(nonatomic,strong) UIView *lineView;
@property(nonatomic,strong) UIButton *loginBtn;

@property(nonatomic,strong) UIImageView *bottomBgImageView;
@property(nonatomic,strong) UIImageView *schoolBgImageView;

@end

@implementation HXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}



#pragma mark - Event
-(void)loginButtonClick:(UIButton *)sender{
    
    self.loginBtn.userInteractionEnabled = NO;
    [self.view endEditing:YES];
    
    //默认有值
    NSString *schoolDomainURL = [HXPublicParamTool sharedInstance].schoolDomainURL;
    if (schoolDomainURL.length<=0) {
        self.loginBtn.userInteractionEnabled = YES;
        [self.view showTostWithMessage:@"请到学校网站扫面二维码进行验证"];
        return;
    }
    
    if ([HXCommonUtil isNull:self.accountTextField.text]) {
        self.loginBtn.userInteractionEnabled = YES;
        [self.view showTostWithMessage:@"帐号必须填写"];
        return;
    }
    
    if ([HXCommonUtil isNull:self.pwdTextField.text]) {
        self.loginBtn.userInteractionEnabled = YES;
        [self.view showTostWithMessage:@"密码必须填写"];
        return;
    }
    
    [self.view showLoadingWithMessage:@"登录中…"];
    WeakSelf(weakSelf);
    [HXBaseURLSessionManager doLoginWithUserName:HXSafeString(self.accountTextField.text) andPassword:HXSafeString(self.pwdTextField.text) success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            [weakSelf.view showSuccessWithMessage:@"登录成功!"];
            weakSelf.loginBtn.userInteractionEnabled = YES;
            [HXPublicParamTool sharedInstance].isLogin = YES;
            NSDictionary *data = [dictionary dictionaryValueForKey:@"data"];
            NSString *token = [data stringValueForKey:@"token"];
            NSString *student_id = [data stringValueForKey:@"student_id"];
            NSString *name = [data stringValueForKey:@"name"];
            NSString *personId = [data stringValueForKey:@"personId"];
            NSString *major_id = [data stringValueForKey:@"major_id"];
            NSString *examineeNo = [data stringValueForKey:@"examineeNo"];
            NSString *studentNo = [data stringValueForKey:@"studentNo"];
            NSString *class_id = [data stringValueForKey:@"class_id"];
            NSString *enterDate = [data stringValueForKey:@"enterDate"];
            NSString *subSchool_id = [data stringValueForKey:@"subSchool_id"];
            NSString *studentState_id = [data stringValueForKey:@"studentState_id"];
            NSString *uuid = [data stringValueForKey:@"uuid"];
            [HXPublicParamTool sharedInstance].token = token;
            [HXPublicParamTool sharedInstance].student_id = student_id;
            [HXPublicParamTool sharedInstance].name = name;
            [HXPublicParamTool sharedInstance].student_id = student_id;
            [HXPublicParamTool sharedInstance].personId = personId;
            [HXPublicParamTool sharedInstance].major_id = major_id;
            [HXPublicParamTool sharedInstance].examineeNo = examineeNo;
            [HXPublicParamTool sharedInstance].studentNo = studentNo;
            [HXPublicParamTool sharedInstance].class_id = class_id;
            [HXPublicParamTool sharedInstance].enterDate = enterDate;
            [HXPublicParamTool sharedInstance].subSchool_id = subSchool_id;
            [HXPublicParamTool sharedInstance].studentState_id = studentState_id;
            [HXPublicParamTool sharedInstance].uuid = uuid;
            //发送登录成功的通知
            [HXNotificationCenter postNotificationName:LOGINSUCCESS object:nil];
            [weakSelf dismissViewControllerAnimated:YES completion:^{
            }];
            [[[UIApplication sharedApplication].delegate window] setRootViewController:[(AppDelegate*)[UIApplication sharedApplication].delegate mainTabBarController]];
        }else{
            weakSelf.loginBtn.userInteractionEnabled = YES;
            [weakSelf.view hideLoading];
        }

    } failure:^(NSString * _Nonnull messsage) {
        weakSelf.loginBtn.userInteractionEnabled = YES;
        [weakSelf.view showErrorWithMessage:messsage];
    }];
    
}

-(void)scan:(UIButton *)sender{
    HXSchoolVerifyViewController *vc = [[HXSchoolVerifyViewController alloc]init];
    vc.sc_navigationBarHidden = YES;
    vc.canGoBack = YES;
    [self.navigationController pushViewController:vc animated:YES];
    WeakSelf(weakSelf);
    vc.scanSuccessBlock = ^(HXSchoolModel * _Nonnull school) {
        [HXPublicParamTool sharedInstance].currentSchoolModel = school;
        [HXPublicParamTool sharedInstance].schoolDomainURL = @"http://xueliapitest.edu-cj.com";
        [HXBaseURLSessionManager setBaseURLStr:[HXPublicParamTool sharedInstance].schoolDomainURL];
        weakSelf.bottomBgImageView.hidden = YES;
        weakSelf.pingTaiLabel.hidden = NO;
        weakSelf.schoolNameLabel.text = school.schoolName_Cn;
        [weakSelf.schoolLogoImageView sd_setImageWithURL:[NSURL URLWithString:school.schoolLogoUrl] placeholderImage:[UIImage imageNamed:@"defaultshcool_icon"]];
        [weakSelf.schoolBgImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"defaultshcoolbg_icon"] options:SDWebImageRefreshCached];
    };
}

-(void)findPwd:(UIButton *)sender{
    //默认有值
    NSString *schoolDomainURL = [HXPublicParamTool sharedInstance].schoolDomainURL;
    if (schoolDomainURL.length<=0) {
        self.loginBtn.userInteractionEnabled = YES;
        [self.view showTostWithMessage:@"请到学校网站扫面二维码进行验证"];
        return;
    }
    HXFindPasswordViewController *vc = [[HXFindPasswordViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = COLOR_WITH_ALPHA(0xF5F7FF, 1);
    [self.view addSubview:self.schoolBgImageView];
    [self.view addSubview:self.bottomBgImageView];
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.navBarView];
    
    
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.scanBtn];
    
    [self.mainScrollView addSubview:self.schoolLogoImageView];
    [self.mainScrollView addSubview:self.schoolNameLabel];
    [self.mainScrollView addSubview:self.pingTaiLabel];
    [self.mainScrollView addSubview:self.containerView];
    [self.containerView addSubview:self.accountBtn];
    [self.containerView addSubview:self.accountTextField];
    [self.containerView addSubview:self.pwdBtn];
    [self.containerView addSubview:self.pwdTextField];
    [self.containerView addSubview:self.retrievePwdBtn];
    [self.retrievePwdBtn addSubview:self.lineView];
    [self.containerView addSubview:self.loginBtn];
    
    
    
    
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
    
    self.scanBtn.sd_layout
        .centerYEqualToView(self.titleLabel)
        .rightEqualToView(self.navBarView)
        .widthIs(80)
        .heightRatioToView(self.titleLabel, 1);
    
    self.scanBtn.imageView.sd_layout
        .centerYEqualToView(self.scanBtn)
        .rightSpaceToView(self.scanBtn, 16)
        .widthIs(16)
        .heightEqualToWidth();
    
    self.bottomBgImageView.sd_layout
        .bottomEqualToView(self.view)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .heightIs(522);
    
    self.schoolBgImageView.sd_layout
        .bottomEqualToView(self.view)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .heightIs(_kph(213+kScreenBottomMargin));
    
    [self.schoolBgImageView updateLayout];
    
    [self.schoolBgImageView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0xF5F7FE, 1) endColor:COLOR_WITH_ALPHA(0xF5F7FE, 0.2)];
    
    self.mainScrollView.sd_layout
        .topSpaceToView(self.navBarView, 0)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .bottomEqualToView(self.view);
    
    
    self.schoolLogoImageView.sd_layout
        .topSpaceToView(self.mainScrollView, 46)
        .centerXEqualToView(self.mainScrollView)
        .widthIs(70)
        .heightEqualToWidth();
    self.schoolLogoImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.schoolNameLabel.sd_layout
        .topSpaceToView(self.schoolLogoImageView, 14)
        .leftSpaceToView(self.mainScrollView, 20)
        .rightSpaceToView(self.mainScrollView, 20)
        .heightIs(23);
    
    self.pingTaiLabel.sd_layout
        .topSpaceToView(self.schoolNameLabel, 4)
        .leftSpaceToView(self.mainScrollView, 20)
        .rightSpaceToView(self.mainScrollView, 20)
        .heightIs(16);
    
    
    self.containerView.sd_layout
        .topSpaceToView(self.schoolNameLabel, 42)
        .leftSpaceToView(self.mainScrollView, 20)
        .rightSpaceToView(self.mainScrollView, 20)
        .heightIs(338);
    self.containerView.sd_cornerRadius = @16;
    
    
    self.accountBtn.sd_layout
        .topSpaceToView(self.containerView, 30)
        .leftSpaceToView(self.containerView, 20)
        .heightIs(21)
        .widthIs(100);
    
    self.accountBtn.imageView.sd_layout
        .centerYEqualToView(self.accountBtn)
        .leftEqualToView(self.accountBtn)
        .widthIs(20)
        .heightEqualToWidth();
    
    self.accountBtn.titleLabel.sd_layout
        .centerYEqualToView(self.accountBtn)
        .leftSpaceToView(self.accountBtn.imageView, 6)
        .rightEqualToView(self.accountBtn)
        .heightIs(21);
    
    
    self.accountTextField.sd_layout
        .topSpaceToView(self.accountBtn, 8)
        .leftSpaceToView(self.containerView, 20)
        .rightSpaceToView(self.containerView, 20)
        .heightIs(40);
    self.accountTextField.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.pwdBtn.sd_layout
        .topSpaceToView(self.accountTextField, 17)
        .leftEqualToView(self.accountBtn)
        .widthRatioToView(self.accountBtn, 1)
        .heightRatioToView(self.accountBtn, 1);
    
    self.pwdBtn.imageView.sd_layout
        .centerYEqualToView(self.pwdBtn)
        .leftEqualToView(self.pwdBtn)
        .widthIs(20)
        .heightEqualToWidth();
    
    self.pwdBtn.titleLabel.sd_layout
        .centerYEqualToView(self.pwdBtn)
        .leftSpaceToView(self.pwdBtn.imageView, 6)
        .rightEqualToView(self.pwdBtn)
        .heightIs(21);
    
    
    self.pwdTextField.sd_layout
        .topSpaceToView(self.pwdBtn, 8)
        .leftEqualToView(self.accountTextField)
        .rightEqualToView(self.accountTextField)
        .heightRatioToView(self.accountTextField, 1);
    self.pwdTextField.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.retrievePwdBtn.sd_layout
        .topSpaceToView(self.pwdTextField, 10)
        .rightSpaceToView(self.containerView, 20)
        .widthIs(60)
        .heightIs(28);
    
    self.lineView.sd_layout
        .bottomSpaceToView(self.retrievePwdBtn, 5)
        .centerXEqualToView(self.retrievePwdBtn)
        .widthIs(48)
        .heightIs(1);
    
    self.loginBtn.sd_layout
        .topSpaceToView(self.retrievePwdBtn, 30)
        .leftEqualToView(self.accountTextField)
        .rightEqualToView(self.accountTextField)
        .heightIs(36);
    self.loginBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.containerView bottomMargin:50];
    
    //默认有值
    HXSchoolModel *defaultSchool = [HXPublicParamTool sharedInstance].currentSchoolModel;
    if (defaultSchool.schoolDomainURL.length>0) {
        self.bottomBgImageView.hidden = YES;
        self.pingTaiLabel.hidden = NO;
        self.schoolNameLabel.text = defaultSchool.schoolName_Cn;
        [self.schoolLogoImageView sd_setImageWithURL:[NSURL URLWithString:defaultSchool.schoolLogoUrl] placeholderImage:[UIImage imageNamed:@"defaultshcool_icon"]];
        [self.schoolBgImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"defaultshcoolbg_icon"] options:SDWebImageRefreshCached];
        [HXPublicParamTool sharedInstance].schoolDomainURL = @"http://xueliapitest.edu-cj.com";
        [HXBaseURLSessionManager setBaseURLStr:[HXPublicParamTool sharedInstance].schoolDomainURL];
    }
    
#ifdef DEBUG
    self.accountTextField.text = @"20190005";
    self.pwdTextField.text = @"dx123456";
#endif
    
}

-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc] init];
        _navBarView.backgroundColor = COLOR_WITH_ALPHA(0xF5F7FF, 1);
    }
    return _navBarView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _titleLabel.text = @"登录";
    }
    return _titleLabel;
}

- (UIButton *)scanBtn{
    if (!_scanBtn) {
        _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanBtn setImage:[UIImage imageNamed:@"scan_icon"] forState:UIControlStateNormal];
        [_scanBtn addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanBtn;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.clearColor;
        _mainScrollView.bounces = YES;
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


-(UIImageView *)schoolLogoImageView{
    if (!_schoolLogoImageView) {
        _schoolLogoImageView = [[UIImageView alloc] init];
        _schoolLogoImageView.image = [UIImage imageNamed:@"defaultshcool_icon"];
    }
    return _schoolLogoImageView;
}

-(UIImageView *)bottomBgImageView{
    if (!_bottomBgImageView) {
        _bottomBgImageView = [[UIImageView alloc] init];
        _bottomBgImageView.image = [UIImage imageNamed:@"loginbottombg_icon"];
    }
    return _bottomBgImageView;
}


-(UIImageView *)schoolBgImageView{
    if (!_schoolBgImageView) {
        _schoolBgImageView = [[UIImageView alloc] init];
        _schoolBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _schoolBgImageView;
}


-(UILabel *)schoolNameLabel{
    if (!_schoolNameLabel) {
        _schoolNameLabel = [[UILabel alloc] init];
        _schoolNameLabel.textAlignment = NSTextAlignmentCenter;
        _schoolNameLabel.font = HXBoldFont(16);
        _schoolNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _schoolNameLabel.text = @"高等学历继续教育教学教务平台";
    }
    return _schoolNameLabel;
}

-(UILabel *)pingTaiLabel{
    if (!_pingTaiLabel) {
        _pingTaiLabel = [[UILabel alloc] init];
        _pingTaiLabel.textAlignment = NSTextAlignmentCenter;
        _pingTaiLabel.font = HXFont(11);
        _pingTaiLabel.textColor = COLOR_WITH_ALPHA(0x333333, 0.37);
        _pingTaiLabel.text = @"高等学历继续教育教学教务平台";
        _pingTaiLabel.hidden = YES;
    }
    return _pingTaiLabel;
}

-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _containerView;
}


- (UIButton *)accountBtn{
    if (!_accountBtn) {
        _accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _accountBtn.titleLabel.font = HXBoldFont(15);
        _accountBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_accountBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_accountBtn setTitle:@"账号" forState:UIControlStateNormal];
        [_accountBtn setImage:[UIImage imageNamed:@"account_icon"] forState:UIControlStateNormal];
    }
    return _accountBtn;
}

-(UITextField *)accountTextField{
    if (!_accountTextField) {
        _accountTextField = [[UITextField alloc] init];
        _accountTextField.backgroundColor = COLOR_WITH_ALPHA(0xF6F6F6, 1);
        _accountTextField.delegate = self;
        _accountTextField.placeholder = @"请输入账号";
        _accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _accountTextField.leftView = leftView;
        _accountTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _accountTextField;
}

- (UIButton *)pwdBtn{
    if (!_pwdBtn) {
        _pwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pwdBtn.titleLabel.font = HXBoldFont(15);
        _pwdBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_pwdBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_pwdBtn setTitle:@"密码" forState:UIControlStateNormal];
        [_pwdBtn setImage:[UIImage imageNamed:@"pwd_icon"] forState:UIControlStateNormal];
    }
    return _pwdBtn;
}



-(UITextField *)pwdTextField{
    if (!_pwdTextField) {
        _pwdTextField = [[UITextField alloc] init];
        _pwdTextField.backgroundColor = COLOR_WITH_ALPHA(0xF6F6F6, 1);
        //        _pwdTextField.secureTextEntry = YES;
        _pwdTextField.delegate = self;
        _pwdTextField.placeholder = @"请输入密码";
        _pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _pwdTextField.leftView = leftView;
        _pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _pwdTextField;
}

-(UIButton *)retrievePwdBtn{
    if (!_retrievePwdBtn) {
        _retrievePwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _retrievePwdBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        _retrievePwdBtn.titleLabel.font = HXBoldFont(12);
        [_retrievePwdBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_retrievePwdBtn setTitle:@"找回密码" forState:UIControlStateNormal];
        [_retrievePwdBtn addTarget:self action:@selector(findPwd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retrievePwdBtn;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColor.blackColor;
    }
    return _lineView;
}


-(UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _loginBtn.titleLabel.font = HXBoldFont(15);
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        _loginBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_loginBtn addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}



@end
