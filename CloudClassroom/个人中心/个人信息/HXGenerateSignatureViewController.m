//
//  HXGenerateSignatureViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/12/29.
//

#import "HXGenerateSignatureViewController.h"
#import "HXSignView.h"

@interface HXGenerateSignatureViewController ()

//画布
@property(nonatomic,strong) UIView *backView;
@property(nonatomic,strong) HXSignView *signView;
//清除签名
@property(nonatomic,strong) UIButton *clearBtn;
//生成签名图片
@property(nonatomic,strong) UIButton *generateBtn;

@end

@implementation HXGenerateSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UI
    [self createUI];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //禁用全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = NO;
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //开启全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = YES;
   
}


#pragma mark - 清除签名
- (void)clearBtnClick{
    [self.signView clearSignature];
}

#pragma mark - 生成签名图片
- (void)generateBtnClick{
    UIImage *image  =  [self.signView getSignatureImage];
    NSString *encodedImageStr = [self imageChangeBase64:image];
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic = @{
        @"student_id":HXSafeString(studentId),
        @"sourceimagebase64":HXSafeString(encodedImageStr)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_SaveStudentSignature needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            [self.view showSuccessWithMessage:[dictionary stringValueForKey:@"message"]];
            //生成签名回调刷新界面
            if (self.generateSignatureCallBack) {
                self.generateSignatureCallBack();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [self.view hideLoading];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view hideLoading];
    }];
    
}

#pragma mark -- image转化成Base64位
-(NSString *)imageChangeBase64: (UIImage *)image{
    UIImage*compressImage = [HXCommonUtil compressImageSize:image toByte:250000];
    NSData*imageData =  UIImageJPEGRepresentation(compressImage, 1);
    NSLog(@"压缩后图片大小：%.2f M",(float)imageData.length/(1024*1024.0f));
    return [NSString stringWithFormat:@"%@",[imageData base64EncodedStringWithOptions:0]];
}

#pragma mark - UI
-(void)createUI{
    
    self.sc_navigationBar.title = @"签名";
    
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.signView];
    [self.view addSubview:self.clearBtn];
    [self.view addSubview:self.generateBtn];
    
    self.backView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight+50)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(200);
    
    self.signView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    [self.signView updateLayout];
    
    self.clearBtn.sd_layout
     .topSpaceToView(self.backView, 30)
     .leftSpaceToView(self.view, 63)
     .widthIs(113)
     .heightIs(36);
     self.clearBtn.sd_cornerRadiusFromHeightRatio=@0.5;
     
     self.generateBtn.sd_layout
      .centerYEqualToView(self.clearBtn)
      .rightSpaceToView(self.view, 63)
      .widthRatioToView(self.clearBtn, 1)
      .heightRatioToView(self.clearBtn, 1);
      self.generateBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
}

#pragma mark - LazyLoad
-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = UIColor.whiteColor;
        _backView.layer.borderWidth = 2;
        _backView.layer.borderColor = [[UIColor redColor] CGColor];
    }
    return _backView;
}

-(HXSignView *)signView{
    if (!_signView) {
        _signView = [[HXSignView alloc] init];
    }
    return _signView;
}


-(UIButton *)clearBtn{
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearBtn.titleLabel.font = HXBoldFont(14);
        _clearBtn.backgroundColor= UIColor.whiteColor;
        _clearBtn.layer.borderWidth =1;
        _clearBtn.layer.borderColor =COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        [_clearBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_clearBtn setTitle:@"清除签名" forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearBtn;
}

-(UIButton *)generateBtn{
    if (!_generateBtn) {
        _generateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _generateBtn.titleLabel.font = HXBoldFont(14);
        _generateBtn.backgroundColor= COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_generateBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_generateBtn setTitle:@"生成签名" forState:UIControlStateNormal];
        [_generateBtn addTarget:self action:@selector(generateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _generateBtn;
}


@end
