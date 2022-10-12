//
//  HXFindPasswordViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/10/11.
//

#import "HXFindPasswordViewController.h"
#import "Utilities.h"
#import "NSString+HXString.h"

@interface HXFindPasswordViewController ()<UITextFieldDelegate>

@property(nonatomic,strong) UIScrollView *mainScrollView;
@property(nonatomic,strong) UIView *bigWhiteView;
//身份证号码
@property(nonatomic,strong) UILabel *personIDLabel;
@property(nonatomic,strong) UITextField *personIDTextField;
@property(nonatomic,strong) UIView *line1;
//手机号码
@property(nonatomic,strong) UILabel *cellPhoneLabel;
@property(nonatomic,strong) UITextField *cellPhoneTextField;
@property(nonatomic,strong) UIView *line2;
//验证码
@property(nonatomic,strong) UILabel *vCodeLabel;
@property(nonatomic,strong) UITextField *vCodeTextField;
@property(nonatomic,strong) UIButton *sendVCodeBtn;
@property(nonatomic,strong) UIView *line3;
//新密码
@property(nonatomic,strong) UILabel *passwordLabel;
@property(nonatomic,strong) UITextField *passwordTextField;
@property(nonatomic,strong) UIView *line4;
//确认新密码
@property(nonatomic,strong) UILabel *againPasswordLabel;
@property(nonatomic,strong) UITextField *againPasswordTextField;

//密码应不少于8位，包含字母、数字
@property(nonatomic,strong) UILabel *tipLabel;

@property(nonatomic,strong) UIButton *confirmBtn;

@property(nonatomic,strong)NSTimer *codeTimer;//获取验证码定时器
@property(nonatomic,assign) integer_t timer_count;//倒计时时间

@end

@implementation HXFindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.timer_count = 60;
    //UI
    [self createUI];
}


-(void)dealloc{
    [self.codeTimer invalidate];
    self.codeTimer = nil;
}


#pragma mark - Event
-(void)sendVCode:(UIButton *)sender{
    if (self.personIDTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请输入身份证号码"];
        [self.personIDTextField becomeFirstResponder];
        return;
    }
    if(![Utilities isValidateTelNumber:self.cellPhoneTextField.text]){
        [self.view showTostWithMessage:@"请输入手机号码"];
        [self.cellPhoneTextField becomeFirstResponder];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self.codeTimer fire];
    
    NSDictionary *dic =@{
        @"personid":HXSafeString(self.personIDTextField.text),
        @"cellphone":HXSafeString(self.cellPhoneTextField.text)
    };
    
    //通过手机号获取验证码
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetVCode needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        BOOL success = [dictionary boolValueForKey:@"success"];
        [self.view showTostWithMessage:[dictionary stringValueForKey:@"message"]];
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

-(void)confirm:(UIButton *)sender{
    
    if (self.personIDTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请输入身份证号码"];
        [self.personIDTextField becomeFirstResponder];
        return;
    }
    
    if (self.cellPhoneTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请输入手机号码"];
        [self.cellPhoneTextField becomeFirstResponder];
        return;
    }
    
    if (self.vCodeTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请输入验证码"];
        [self.vCodeTextField becomeFirstResponder];
        return;
    }
    
    if (self.passwordTextField.text.length < 8) {
        [self.view showTostWithMessage:@"密码应不少于8位"];
        [self.againPasswordTextField becomeFirstResponder];
        return;
    }
    
    if ([NSString isOnlyNumString:self.passwordTextField.text] || [NSString isOnlyLetterString:self.passwordTextField.text]) {
        [self.view showTostWithMessage:@"新密码必须包含字母、数字"];
        [self.againPasswordTextField becomeFirstResponder];
        return;
    }
    
    if (self.againPasswordTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请再次输入新密码"];
        [self.againPasswordTextField becomeFirstResponder];
        return;
    }
    
    if (![self.againPasswordTextField.text isEqualToString:self.passwordTextField.text])
    {
        [self.view showTostWithMessage:@"两次密码输入不一致"];
        return;
    }
    
    [self.view endEditing:YES];
    
    
    NSDictionary *dic =@{
        @"personid":HXSafeString(self.personIDTextField.text),
        @"cellphone":HXSafeString(self.cellPhoneTextField.text),
        @"vcode":HXSafeString(self.vCodeTextField.text),
        @"newpassword":HXSafeString(self.passwordTextField.text)
    };
    //找回密码
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_FindPassword needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSString *message = [dictionary stringValueForKey:@"message"];
        if(success){
            [self.view showTostWithMessage:message];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [self.view showTostWithMessage:message];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}


//定时器倒计时
- (void)getSmsTimerMethod{
    self.timer_count --;
    NSString *title = [NSString stringWithFormat:@"已发送%ds",_timer_count];
    [self.sendVCodeBtn setTitle:title forState:UIControlStateNormal];
    self.sendVCodeBtn.userInteractionEnabled = NO;
    [self.sendVCodeBtn setTitleColor:COLOR_WITH_ALPHA(0xA8BBFF, 1) forState:UIControlStateNormal];
    self.sendVCodeBtn.layer.borderColor = COLOR_WITH_ALPHA(0xA8BBFF, 1).CGColor;
    if (self.timer_count == 0){
        self.timer_count = 60;
        [self.codeTimer invalidate];
        self.codeTimer = nil;
        [self.sendVCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [self.sendVCodeBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        self.sendVCodeBtn.layer.borderColor = COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        self.sendVCodeBtn.userInteractionEnabled = YES;
    }
}



#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"找回密码";
    
    [self.view addSubview:self.mainScrollView];
   
    [self.mainScrollView addSubview:self.bigWhiteView];

    [self.bigWhiteView addSubview:self.personIDLabel];
    [self.bigWhiteView addSubview:self.personIDTextField];
    [self.bigWhiteView addSubview:self.line1];
    [self.bigWhiteView addSubview:self.cellPhoneLabel];
    [self.bigWhiteView addSubview:self.cellPhoneTextField];
    [self.bigWhiteView addSubview:self.line2];
    [self.bigWhiteView addSubview:self.vCodeLabel];
    [self.bigWhiteView addSubview:self.vCodeTextField];
    [self.bigWhiteView addSubview:self.sendVCodeBtn];
    [self.bigWhiteView addSubview:self.line3];
    [self.bigWhiteView addSubview:self.passwordLabel];
    [self.bigWhiteView addSubview:self.passwordTextField];
    [self.bigWhiteView addSubview:self.line4];
    [self.bigWhiteView addSubview:self.againPasswordLabel];
    [self.bigWhiteView addSubview:self.againPasswordTextField];

    [self.mainScrollView addSubview:self.tipLabel];
    [self.mainScrollView addSubview:self.confirmBtn];

    self.mainScrollView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);

    self.bigWhiteView.sd_layout
    .topSpaceToView(self.mainScrollView, 16)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    self.bigWhiteView.sd_cornerRadius=@4;

    self.personIDLabel.sd_layout
    .topEqualToView(self.bigWhiteView)
    .leftSpaceToView(self.bigWhiteView, 12)
    .widthIs(80)
    .heightIs(54);

    self.personIDTextField.sd_layout
    .centerYEqualToView(self.personIDLabel)
    .rightSpaceToView(self.bigWhiteView, 12)
    .leftSpaceToView(self.personIDLabel, 12)
    .heightRatioToView(self.personIDLabel, 1);

    self.line1.sd_layout
    .topSpaceToView(self.personIDLabel, 0)
    .leftSpaceToView(self.bigWhiteView, 12)
    .rightSpaceToView(self.bigWhiteView, 12)
    .heightIs(0.5);

    self.cellPhoneLabel.sd_layout
    .topSpaceToView(self.line1, 0)
    .leftEqualToView(self.personIDLabel)
    .rightEqualToView(self.personIDLabel)
    .heightRatioToView(self.personIDLabel, 1);

    self.cellPhoneTextField.sd_layout
    .centerYEqualToView(self.cellPhoneLabel)
    .leftEqualToView(self.personIDTextField)
    .rightEqualToView(self.personIDTextField)
    .heightRatioToView(self.personIDTextField, 1);

    self.line2.sd_layout
    .topSpaceToView(self.cellPhoneLabel, 0)
    .leftEqualToView(self.line1)
    .rightEqualToView(self.line1)
    .heightRatioToView(self.line1, 1);

    self.vCodeLabel.sd_layout
    .topSpaceToView(self.line2, 0)
    .leftEqualToView(self.personIDLabel)
    .rightEqualToView(self.personIDLabel)
    .heightRatioToView(self.personIDLabel, 1);

    self.sendVCodeBtn.sd_layout
    .centerYEqualToView(self.vCodeLabel)
    .rightEqualToView(self.personIDTextField)
    .widthIs(80)
    .heightIs(30);
    self.sendVCodeBtn.sd_cornerRadiusFromHeightRatio=@0.5;

    self.vCodeTextField.sd_layout
    .centerYEqualToView(self.vCodeLabel)
    .leftSpaceToView(self.vCodeLabel, 12)
    .rightSpaceToView(self.sendVCodeBtn, 12)
    .heightRatioToView(self.personIDTextField, 1);

    self.line3.sd_layout
    .topSpaceToView(self.vCodeLabel, 0)
    .leftEqualToView(self.line1)
    .rightEqualToView(self.line1)
    .heightRatioToView(self.line1, 1);

    self.passwordLabel.sd_layout
    .topSpaceToView(self.line3, 0)
    .leftEqualToView(self.personIDLabel)
    .rightEqualToView(self.personIDLabel)
    .heightRatioToView(self.personIDLabel, 1);

    self.passwordTextField.sd_layout
    .centerYEqualToView(self.passwordLabel)
    .leftEqualToView(self.personIDTextField)
    .rightEqualToView(self.personIDTextField)
    .heightRatioToView(self.personIDTextField, 1);

    self.line4.sd_layout
    .topSpaceToView(self.passwordLabel, 0)
    .leftEqualToView(self.line1)
    .rightEqualToView(self.line1)
    .heightRatioToView(self.line1, 1);

    self.againPasswordLabel.sd_layout
    .topSpaceToView(self.line4, 0)
    .leftEqualToView(self.personIDLabel)
    .rightEqualToView(self.personIDLabel)
    .heightRatioToView(self.personIDLabel, 1);

    self.againPasswordTextField.sd_layout
    .centerYEqualToView(self.againPasswordLabel)
    .leftEqualToView(self.personIDTextField)
    .rightEqualToView(self.personIDTextField)
    .heightRatioToView(self.personIDTextField, 1);

    [self.bigWhiteView setupAutoHeightWithBottomView:self.againPasswordLabel bottomMargin:0];

    self.tipLabel.sd_layout
    .topSpaceToView(self.bigWhiteView, 14)
    .leftSpaceToView(self.mainScrollView, 24)
    .rightSpaceToView(self.mainScrollView, 24)
    .heightIs(17);

    self.confirmBtn.sd_layout
    .topSpaceToView(self.tipLabel, 40)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12)
    .heightIs(36);
    self.confirmBtn.sd_cornerRadiusFromHeightRatio=@0.5;

    [self.mainScrollView setupAutoContentSizeWithBottomView:self.confirmBtn bottomMargin:100];
    
    
    
}


#pragma mark - LazyLoad
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.clearColor;
        _mainScrollView.bounces = NO;
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

-(UIView *)bigWhiteView{
    if(!_bigWhiteView){
        _bigWhiteView =[[UIView alloc] init];
        _bigWhiteView.backgroundColor = UIColor.whiteColor;
    }
    return _bigWhiteView;
}

-(UILabel *)personIDLabel{
    if (!_personIDLabel) {
        _personIDLabel = [[UILabel alloc] init];
        _personIDLabel.textAlignment = NSTextAlignmentLeft;
        _personIDLabel.font = HXFont(15);
        _personIDLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _personIDLabel.text = @"身份证号码";
    }
    return _personIDLabel;
}

-(UITextField *)personIDTextField{
    if (!_personIDTextField) {
        _personIDTextField = [[UITextField alloc] init];
        _personIDTextField.textAlignment = NSTextAlignmentRight;
        _personIDTextField.font = HXBoldFont(15);
        _personIDTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _personIDTextField.delegate = self;
        _personIDTextField.placeholder = @"请输入身份证号码";
        _personIDTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _personIDTextField;
}

-(UIView *)line1{
    if (!_line1) {
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _line1;
}

-(UILabel *)cellPhoneLabel{
    if (!_cellPhoneLabel) {
        _cellPhoneLabel = [[UILabel alloc] init];
        _cellPhoneLabel.textAlignment = NSTextAlignmentLeft;
        _cellPhoneLabel.font = HXFont(15);
        _cellPhoneLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _cellPhoneLabel.text = @"手机号码";
    }
    return _cellPhoneLabel;
}

-(UITextField *)cellPhoneTextField{
    if (!_cellPhoneTextField) {
        _cellPhoneTextField = [[UITextField alloc] init];
        _cellPhoneTextField.textAlignment = NSTextAlignmentRight;
        _cellPhoneTextField.font = HXBoldFont(15);
        _cellPhoneTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _cellPhoneTextField.delegate = self;
        _cellPhoneTextField.placeholder = @"请输入手机号码";
        _cellPhoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _cellPhoneTextField;
}

-(UIView *)line2{
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _line2;
}


-(UILabel *)vCodeLabel{
    if (!_vCodeLabel) {
        _vCodeLabel = [[UILabel alloc] init];
        _vCodeLabel.textAlignment = NSTextAlignmentLeft;
        _vCodeLabel.font = HXFont(15);
        _vCodeLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _vCodeLabel.text = @"验证码";
    }
    return _vCodeLabel;
}

-(UITextField *)vCodeTextField{
    if (!_vCodeTextField) {
        _vCodeTextField = [[UITextField alloc] init];
        _vCodeTextField.textAlignment = NSTextAlignmentRight;
        _vCodeTextField.font = HXBoldFont(15);
        _vCodeTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _vCodeTextField.delegate = self;
        _vCodeTextField.placeholder = @"请输入验证码";
        _vCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _vCodeTextField;
}

-(UIView *)line3{
    if (!_line3) {
        _line3 = [[UIView alloc] init];
        _line3.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _line3;
}

-(UILabel *)passwordLabel{
    if (!_passwordLabel) {
        _passwordLabel = [[UILabel alloc] init];
        _passwordLabel.textAlignment = NSTextAlignmentLeft;
        _passwordLabel.font = HXFont(15);
        _passwordLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _passwordLabel.text = @"新密码";
    }
    return _passwordLabel;
}

-(UIButton *)sendVCodeBtn{
    if (!_sendVCodeBtn) {
        _sendVCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendVCodeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _sendVCodeBtn.titleLabel.font = HXFont(12);
        _sendVCodeBtn.layer.borderWidth =1;
        _sendVCodeBtn.layer.borderColor =COLOR_WITH_ALPHA(0x2E5BFD, 1) .CGColor;
        [_sendVCodeBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_sendVCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        _sendVCodeBtn.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        [_sendVCodeBtn addTarget:self action:@selector(sendVCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendVCodeBtn;
}

-(UITextField *)passwordTextField{
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.textAlignment = NSTextAlignmentRight;
        _passwordTextField.font = HXBoldFont(15);
        _passwordTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _passwordTextField.delegate = self;
        _passwordTextField.placeholder = @"请输入新密码";
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _passwordTextField;
}

-(UIView *)line4{
    if (!_line4) {
        _line4 = [[UIView alloc] init];
        _line4.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _line4;
}

-(UILabel *)againPasswordLabel{
    if (!_againPasswordLabel) {
        _againPasswordLabel = [[UILabel alloc] init];
        _againPasswordLabel.textAlignment = NSTextAlignmentLeft;
        _againPasswordLabel.font = HXFont(15);
        _againPasswordLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _againPasswordLabel.text = @"确认新密码";
    }
    return _againPasswordLabel;
}

-(UITextField *)againPasswordTextField{
    if (!_againPasswordTextField) {
        _againPasswordTextField = [[UITextField alloc] init];
        _againPasswordTextField.textAlignment = NSTextAlignmentRight;
        _againPasswordTextField.font = HXBoldFont(15);
        _againPasswordTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _againPasswordTextField.delegate = self;
        _againPasswordTextField.placeholder = @"请再次输入新密码";
        _againPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _againPasswordTextField;
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.font = HXFont(12);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _tipLabel.text = @"密码应不少于8位，包含字母、数字";
    }
    return _tipLabel;
}

-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _confirmBtn.titleLabel.font = HXBoldFont(15);
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"确认修改" forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

-(NSTimer *)codeTimer{
    if(!_codeTimer){
        _codeTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(getSmsTimerMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_codeTimer forMode:NSRunLoopCommonModes];
    }
    return _codeTimer;
}

@end
