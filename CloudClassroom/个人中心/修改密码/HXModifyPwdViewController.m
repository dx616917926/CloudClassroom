//
//  HXModifyPwdViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/23.
//

#import "HXModifyPwdViewController.h"
#import "NSString+HXString.h"

@interface HXModifyPwdViewController ()<UITextFieldDelegate>

@property(nonatomic,strong) UIView *topContainerView;

@property(nonatomic,strong) UILabel *yuanPwdLabel;
@property(nonatomic,strong) UITextField *yuanPwdTextField;
@property(nonatomic,strong) UIView *line1;
@property(nonatomic,strong) UILabel *xinPwdLabel;
@property(nonatomic,strong) UITextField *xinPwdTextField;
@property(nonatomic,strong) UIView *line2;
@property(nonatomic,strong) UILabel *confirmPwdLabel;
@property(nonatomic,strong) UITextField *confirmPwdTextField;

@property(nonatomic,strong) UILabel *tipLabel;

@property(nonatomic,strong) UIButton *modifyBtn;



@end

@implementation HXModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}


#pragma mark - Event
-(void)modify:(UIButton *)sender{
    if (self.yuanPwdTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请输入原始密码"];
        [self.yuanPwdTextField becomeFirstResponder];
        return;
    }
    
    if (self.xinPwdTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请输入新密码"];
        [self.xinPwdTextField becomeFirstResponder];
        return;
    }
    
    if (self.xinPwdTextField.text.length < 8 || self.xinPwdTextField.text.length > 20) {
        [self.view showTostWithMessage:@"新密码需8-20位字符"];
        return;
    }
    
    if ([NSString isOnlyNumString:self.xinPwdTextField.text] || [NSString isOnlyLetterString:self.xinPwdTextField.text]) {
        [self.view showTostWithMessage:@"新密码必须包含字母/数字/字符中两种以上组合"];
        return;
    }
    
    if (self.confirmPwdTextField.text.length == 0) {
        [self.view showTostWithMessage:@"请输入确认密码"];
        [self.confirmPwdTextField becomeFirstResponder];
        return;
    }
    
    if (![self.xinPwdTextField.text isEqualToString:self.confirmPwdTextField.text])
    {
        [self.view showTostWithMessage:@"两次密码输入不一致"];
        return;
    }
    
    [self.view endEditing:YES];
    
    
    NSDictionary *dic =@{
        @"oldpassword":HXSafeString(self.yuanPwdTextField.text),
        @"newpassword":HXSafeString(self.xinPwdTextField.text)

    };
    //找回密码
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_UpdatePassword needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSString *message = [dictionary stringValueForKey:@"message"];
        if(success){
            [self.view showTostWithMessage:message];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //退出登录--弹登录框！
                [HXNotificationCenter postNotificationName:SHOWLOGIN object:nil];
            });
        }else{
            [self.view showTostWithMessage:message];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
    
}



#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"修改密码";
    
    [self.view addSubview:self.topContainerView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.modifyBtn];
    
    [self.topContainerView addSubview:self.yuanPwdLabel];
    [self.topContainerView addSubview:self.yuanPwdTextField];
    [self.topContainerView addSubview:self.line1];
    [self.topContainerView addSubview:self.xinPwdLabel];
    [self.topContainerView addSubview:self.xinPwdTextField];
    [self.topContainerView addSubview:self.line2];
    [self.topContainerView addSubview:self.confirmPwdLabel];
    [self.topContainerView addSubview:self.confirmPwdTextField];
    
    
    self.topContainerView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight+16)
    .leftSpaceToView(self.view,12)
    .rightSpaceToView(self.view,12);
    self.topContainerView.sd_cornerRadius=@4;
    
    self.yuanPwdLabel.sd_layout
    .topSpaceToView(self.topContainerView, 18)
    .leftSpaceToView(self.topContainerView, 12)
    .widthIs(90)
    .heightIs(21);
    
    self.yuanPwdTextField.sd_layout
    .centerYEqualToView(self.yuanPwdLabel)
    .leftSpaceToView(self.yuanPwdLabel, 12)
    .rightSpaceToView(self.topContainerView, 12)
    .heightIs(40);
    
    self.line1.sd_layout
    .topSpaceToView(self.yuanPwdLabel, 18)
    .leftEqualToView(self.yuanPwdLabel)
    .rightEqualToView(self.yuanPwdTextField)
    .heightIs(0.5);
    
    self.xinPwdLabel.sd_layout
    .topSpaceToView(self.line1, 18)
    .leftEqualToView(self.yuanPwdLabel)
    .widthRatioToView(self.yuanPwdLabel, 1)
    .heightRatioToView(self.yuanPwdLabel, 1);
    
    self.xinPwdTextField.sd_layout
    .centerYEqualToView(self.xinPwdLabel)
    .leftEqualToView(self.yuanPwdTextField)
    .rightEqualToView(self.yuanPwdTextField)
    .heightRatioToView(self.yuanPwdTextField, 1);
    
    self.line2.sd_layout
    .topSpaceToView(self.xinPwdLabel, 18)
    .leftEqualToView(self.line1)
    .rightEqualToView(self.line1)
    .heightRatioToView(self.line1, 1);
    
    self.confirmPwdLabel.sd_layout
    .topSpaceToView(self.line2, 18)
    .leftEqualToView(self.yuanPwdLabel)
    .widthRatioToView(self.yuanPwdLabel, 1)
    .heightRatioToView(self.yuanPwdLabel, 1);
    
    self.confirmPwdTextField.sd_layout
    .centerYEqualToView(self.confirmPwdLabel)
    .leftEqualToView(self.yuanPwdTextField)
    .rightEqualToView(self.yuanPwdTextField)
    .heightRatioToView(self.yuanPwdTextField, 1);
    
    [self.topContainerView setupAutoHeightWithBottomView:self.confirmPwdLabel bottomMargin:18];
    
    
    self.tipLabel.sd_layout
    .topSpaceToView(self.topContainerView, 14)
    .leftSpaceToView(self.view,12)
    .rightSpaceToView(self.view,12)
    .heightIs(17);
    
    
    self.modifyBtn.sd_layout
    .topSpaceToView(self.tipLabel, 40)
    .leftSpaceToView(self.view,12)
    .rightSpaceToView(self.view,12)
    .heightIs(36);
    self.modifyBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    
}


#pragma mark - LazyLoad
-(UIView *)topContainerView{
    if (!_topContainerView) {
        _topContainerView = [[UIView alloc] init];
        _topContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _topContainerView;
}


-(UILabel *)yuanPwdLabel{
    if (!_yuanPwdLabel) {
        _yuanPwdLabel = [[UILabel alloc] init];
        _yuanPwdLabel.textAlignment = NSTextAlignmentLeft;
        _yuanPwdLabel.font = HXFont(15);
        _yuanPwdLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _yuanPwdLabel.text = @"原始密码";
    }
    return _yuanPwdLabel;
}

-(UITextField *)yuanPwdTextField{
    if (!_yuanPwdTextField) {
        _yuanPwdTextField = [[UITextField alloc] init];
        _yuanPwdTextField.textAlignment = NSTextAlignmentRight;
        _yuanPwdTextField.font = HXBoldFont(15);
        _yuanPwdTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _yuanPwdTextField.delegate = self;
        _yuanPwdTextField.placeholder = @"请输入原始密码";
        _yuanPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _yuanPwdTextField;
}


-(UIView *)line1{
    if (!_line1) {
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _line1;
}

-(UILabel *)xinPwdLabel{
    if (!_xinPwdLabel) {
        _xinPwdLabel = [[UILabel alloc] init];
        _xinPwdLabel.textAlignment = NSTextAlignmentLeft;
        _xinPwdLabel.font = HXFont(15);
        _xinPwdLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _xinPwdLabel.text = @"新密码";
    }
    return _xinPwdLabel;
}

-(UITextField *)xinPwdTextField{
    if (!_xinPwdTextField) {
        _xinPwdTextField = [[UITextField alloc] init];
        _xinPwdTextField.textAlignment = NSTextAlignmentRight;
        _xinPwdTextField.font = HXBoldFont(15);
        _xinPwdTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _xinPwdTextField.delegate = self;
        _xinPwdTextField.placeholder = @"请输入新密码";
        _xinPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _xinPwdTextField;
}


-(UIView *)line2{
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = COLOR_WITH_ALPHA(0xE6E6E6, 1);
    }
    return _line2;
}

-(UILabel *)confirmPwdLabel{
    if (!_confirmPwdLabel) {
        _confirmPwdLabel = [[UILabel alloc] init];
        _confirmPwdLabel.textAlignment = NSTextAlignmentLeft;
        _confirmPwdLabel.font = HXFont(15);
        _confirmPwdLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _confirmPwdLabel.text = @"确认新密码";
    }
    return _confirmPwdLabel;
}

-(UITextField *)confirmPwdTextField{
    if (!_confirmPwdTextField) {
        _confirmPwdTextField = [[UITextField alloc] init];
        _confirmPwdTextField.textAlignment = NSTextAlignmentRight;
        _confirmPwdTextField.font = HXBoldFont(15);
        _confirmPwdTextField.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _confirmPwdTextField.delegate = self;
        _confirmPwdTextField.placeholder = @"请再次输入新密码";
        _confirmPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _confirmPwdTextField;
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


-(UIButton *)modifyBtn{
    if (!_modifyBtn) {
        _modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _modifyBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _modifyBtn.titleLabel.font = HXBoldFont(15);
        [_modifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_modifyBtn setTitle:@"确认修改" forState:UIControlStateNormal];
        _modifyBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_modifyBtn addTarget:self action:@selector(modify:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modifyBtn;
}

@end
