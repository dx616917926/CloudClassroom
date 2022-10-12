//
//  HXFindPasswordViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/10/11.
//

#import "HXFindPasswordViewController.h"

@interface HXFindPasswordViewController ()

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

@end

@implementation HXFindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}

#pragma mark - Event
-(void)sendVCode:(UIButton *)sender{
    
    
}

-(void)confirm:(UIButton *)sender{
    
    
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"找回密码";
   
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
    return _vCodeLabel;
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

@end
