//
//  HXSchoolVerifyViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/13.
//

#import "HXSchoolVerifyViewController.h"
#import "QRCodeReaderViewController.h"

@interface HXSchoolVerifyViewController ()

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *backBtn;

@property(nonatomic,strong) UIImageView *tipImageView;
@property(nonatomic,strong) UILabel *tipLabel;
@property(nonatomic,strong) UIButton *scanVerifyBtn;

@end

@implementation HXSchoolVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.canGoBack) {
        //禁用全局滑动手势
        HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
        navigationController.enableInnerInactiveGesture = NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //开启全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = YES;
}

#pragma mark - Event
-(void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scanVerify:(UIButton *)sender{
    
    //判断权限
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法使用相机"
                                                        message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
    }else if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        
        QRCodeReaderViewController *qvc = [[QRCodeReaderViewController alloc] initWithHintTitle:@"请到学校网站扫描二维码进行验证"];
        
        __weak typeof(QRCodeReaderViewController *) weakqvc = qvc;
        [qvc setCompletionWithBlock:^(NSString *resultAsString) {
            [weakqvc.codeReader stopScanning];
            
            NSData *jsonData = [resultAsString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            if (error || !dic) {
                [weakqvc.navigationController popViewControllerAnimated:YES];
                [self.view showErrorWithMessage:@"未能识别此二维码"];
                return;
            }
            
            NSLog(@"二维码扫描结果：%@",dic);
            //            HXSchoolObject *school = [HXSchoolObject mj_objectWithKeyValues:dic];
            
            if (self.scanSuccessBlock) {
                
                //                BOOL success = [[HXDBManager defaultDBManager] saveSchoolInfoWithschoolObject:school];
                if (1) {
                    
                    [weakqvc.navigationController popToRootViewControllerAnimated:YES];
                    self.scanSuccessBlock();
                }else{
                    NSLog(@"学校数据保存失败!!!!");
                    [weakqvc.navigationController popViewControllerAnimated:YES];
                    [self.view showErrorWithMessage:@"未能识别此二维码"];
                }
            }
        }];
        
        [self.navigationController pushViewController:qvc animated:YES];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此设备不支持扫描二维码！请检查摄像头是否能够正常使用！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alert show];
    }
}


#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.tipImageView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.scanVerifyBtn];
    
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
    
    self.tipImageView.sd_layout
        .topSpaceToView(self.navBarView,40)
        .centerXEqualToView(self.view)
        .widthIs(157)
        .heightIs(196);
    
    self.tipLabel.sd_layout
        .topSpaceToView(self.tipImageView,40)
        .leftSpaceToView(self.view, 40)
        .rightSpaceToView(self.view, 40)
        .heightIs(23);
    
    self.scanVerifyBtn.sd_layout
        .topSpaceToView(self.tipLabel,34)
        .leftSpaceToView(self.view, 40)
        .rightSpaceToView(self.view, 40)
        .heightIs(36);
    self.scanVerifyBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
}


#pragma mark - LazyLoad
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
        _titleLabel.text = @"学校验证";
    }
    return _titleLabel;
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navi_blackback"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UIImageView *)tipImageView{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.image = [UIImage imageNamed:@"scantip_icon"];
    }
    return _tipImageView;
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = HXBoldFont(16);
        _tipLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _tipLabel.text = @"请到学校网站扫描二维码进行验证";
    }
    return _tipLabel;
}


-(UIButton *)scanVerifyBtn{
    if (!_scanVerifyBtn) {
        _scanVerifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scanVerifyBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _scanVerifyBtn.titleLabel.font = HXBoldFont(15);
        [_scanVerifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_scanVerifyBtn setTitle:@"扫码验证" forState:UIControlStateNormal];
        _scanVerifyBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_scanVerifyBtn addTarget:self action:@selector(scanVerify:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanVerifyBtn;
}



@end
