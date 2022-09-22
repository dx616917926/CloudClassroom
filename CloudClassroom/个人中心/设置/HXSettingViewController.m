//
//  HXSettingViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/19.
//

#import "HXSettingViewController.h"
#import "HXFileManager.h"
#import "VICacheManager.h"

@interface HXSettingViewController ()

@property(nonatomic,strong) UIControl *qinChuCachControl;
@property(nonatomic,strong) UIImageView *qinChuCachImageView;
@property(nonatomic,strong) UILabel *qinChuCachTitleLabel;
@property(nonatomic,strong) UILabel *qinChuCachContentLabel;
@property(nonatomic,strong) UIImageView *qinChuCachArrow;

@property(nonatomic,strong) UIView *containerView;

@property(nonatomic,strong) UIControl *checkUpdateControl;
@property(nonatomic,strong) UIImageView *checkUpdateImageView;
@property(nonatomic,strong) UILabel *checkUpdateTitleLabel;
@property(nonatomic,strong) UILabel *checkUpdateContentLabel;
@property(nonatomic,strong) UIImageView *checkUpdateArrow;

@property(nonatomic,strong) UIView *line1;

@property(nonatomic,strong) UIControl *aboutUsControl;
@property(nonatomic,strong) UIImageView *aboutUsImageView;
@property(nonatomic,strong) UILabel *aboutUsTitleLabel;
@property(nonatomic,strong) UIImageView *aboutUsArrow;

@property(nonatomic,strong) UIView *line2;

@property(nonatomic,strong) UIControl *faceControl;
@property(nonatomic,strong) UIImageView *faceImageView;
@property(nonatomic,strong) UILabel *faceTitleLabel;
@property(nonatomic,strong) UISwitch *faceBtn;

@property(nonatomic,strong) UIView *line3;

@property(nonatomic,strong) UIControl *cancellationControl;
@property(nonatomic,strong) UIImageView *cancellationImageView;
@property(nonatomic,strong) UILabel *cancellationTitleLabel;
@property(nonatomic,strong) UIImageView *cancellationArrow;


@property(nonatomic,strong) UIButton *logOutBtn;

@end

@implementation HXSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //计算缓存
    [self calculateChuCach];
}


#pragma mark - Event
//清除缓存
-(void)qinChuCach{
    [self.view showLoadingWithMessage:@"清除缓存中……"];
    [VICacheManager cleanAllCacheWithError:nil];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * path = [paths firstObject];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    [self.view showSuccessWithMessage:@"清除完毕！"];
    
    [self calculateChuCach];
}

//计算缓存
-(void)calculateChuCach{
    WeakSelf(weakSelf);
    [HXFileManager calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        //
        NSUInteger totalSize2 = [VICacheManager calculateCachedSizeWithError:nil];
        NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:totalSize+totalSize2
                                                        countStyle:NSByteCountFormatterCountStyleFile];
        if ([fileSizeStr containsString:@"Zero"]) {
            weakSelf.qinChuCachContentLabel.text = @"0 KB";
        }else{
            weakSelf.qinChuCachContentLabel.text = [NSString stringWithFormat:@"%@", fileSizeStr];
        }
    }];
}

/// 开启人脸识别提示音  默认NO
- (void)enableFaceSound:(UISwitch *)st {
    [HXUserDefaults setBool:!st.on forKey:CloseFaceLivenessSound];
    [HXUserDefaults synchronize];
}

//退出登录
-(void)logOut:(UIButton *)sender{
    
}

#pragma mark - UI
-(void)createUI{
    
    self.sc_navigationBar.title = @"设置";
    
    [self.view addSubview:self.qinChuCachControl];
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.logOutBtn];
    
    [self.containerView addSubview:self.checkUpdateControl];
    [self.containerView addSubview:self.line1];
    [self.containerView addSubview:self.aboutUsControl];
    [self.containerView addSubview:self.line2];
    [self.containerView addSubview:self.faceControl];
    [self.containerView addSubview:self.line3];
    [self.containerView addSubview:self.cancellationControl];
    
    [self.qinChuCachControl addSubview:self.qinChuCachImageView];
    [self.qinChuCachControl addSubview:self.qinChuCachTitleLabel];
    [self.qinChuCachControl addSubview:self.qinChuCachContentLabel];
    [self.qinChuCachControl addSubview:self.qinChuCachArrow];
    
    [self.checkUpdateControl addSubview:self.checkUpdateImageView];
    [self.checkUpdateControl addSubview:self.checkUpdateTitleLabel];
    [self.checkUpdateControl addSubview:self.checkUpdateContentLabel];
    [self.checkUpdateControl addSubview:self.checkUpdateArrow];
    
    
    [self.aboutUsControl addSubview:self.aboutUsImageView];
    [self.aboutUsControl addSubview:self.aboutUsTitleLabel];
    [self.aboutUsControl addSubview:self.aboutUsArrow];
    
    [self.faceControl addSubview:self.faceImageView];
    [self.faceControl addSubview:self.faceTitleLabel];
    [self.faceControl addSubview:self.faceBtn];
    
    [self.cancellationControl addSubview:self.cancellationImageView];
    [self.cancellationControl addSubview:self.cancellationTitleLabel];
    [self.cancellationControl addSubview:self.cancellationArrow];
    
    
    self.qinChuCachControl.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight+20)
    .leftSpaceToView(self.view,12)
    .rightSpaceToView(self.view,12)
    .heightIs(53);
    self.qinChuCachControl.sd_cornerRadius=@8;
    
    
    self.containerView.sd_layout
    .topSpaceToView(self.qinChuCachControl, 16)
    .leftSpaceToView(self.view,12)
    .rightSpaceToView(self.view,12);
    self.containerView.sd_cornerRadius=@8;
    
    self.checkUpdateControl.sd_layout
    .topSpaceToView(self.containerView, 0)
    .leftEqualToView(self.containerView)
    .rightEqualToView(self.containerView)
    .heightIs(53);
    
    self.line1.sd_layout
    .topSpaceToView(self.checkUpdateControl, 0)
    .leftSpaceToView(self.containerView,16)
    .rightSpaceToView(self.containerView,16)
    .heightIs(0.5);
    
    self.aboutUsControl.sd_layout
    .topSpaceToView(self.line1, 0)
    .leftEqualToView(self.containerView)
    .rightEqualToView(self.containerView)
    .heightRatioToView(self.checkUpdateControl, 1);
    
    self.line2.sd_layout
    .topSpaceToView(self.aboutUsControl, 0)
    .leftEqualToView(self.line1)
    .rightEqualToView(self.line1)
    .heightRatioToView(self.line1, 1);
    
    self.faceControl.sd_layout
    .topSpaceToView(self.line2, 0)
    .leftEqualToView(self.containerView)
    .rightEqualToView(self.containerView)
    .heightRatioToView(self.checkUpdateControl, 1);
    
    self.line3.sd_layout
    .topSpaceToView(self.faceControl, 0)
    .leftEqualToView(self.line1)
    .rightEqualToView(self.line1)
    .heightRatioToView(self.line1, 1);
    
    self.cancellationControl.sd_layout
    .topSpaceToView(self.line3, 0)
    .leftEqualToView(self.containerView)
    .rightEqualToView(self.containerView)
    .heightRatioToView(self.checkUpdateControl, 1);
    
    [self.containerView setupAutoHeightWithBottomView:self.cancellationControl bottomMargin:0];
    
    
    self.logOutBtn.sd_layout
    .bottomSpaceToView(self.view, 60)
    .leftSpaceToView(self.view,12)
    .rightSpaceToView(self.view,12)
    .heightIs(36);
    self.logOutBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    //清除缓存
    self.qinChuCachImageView.sd_layout
    .centerYEqualToView(self.qinChuCachControl)
    .leftSpaceToView(self.qinChuCachControl, 12)
    .widthIs(27)
    .heightEqualToWidth();
    
    self.qinChuCachTitleLabel.sd_layout
    .centerYEqualToView(self.qinChuCachControl)
    .leftSpaceToView(self.qinChuCachImageView, 5)
    .widthIs(110)
    .heightIs(21);
    
    self.qinChuCachArrow.sd_layout
    .centerYEqualToView(self.qinChuCachControl)
    .rightSpaceToView(self.qinChuCachControl, 12)
    .widthIs(15)
    .heightEqualToWidth();
    
    self.qinChuCachContentLabel.sd_layout
    .centerYEqualToView(self.qinChuCachControl)
    .rightSpaceToView(self.qinChuCachArrow, 2)
    .widthIs(60)
    .heightIs(18);
    
    //检查更新
    self.checkUpdateImageView.sd_layout
    .centerYEqualToView(self.checkUpdateControl)
    .leftSpaceToView(self.checkUpdateControl, 12)
    .widthRatioToView(self.qinChuCachImageView, 1)
    .heightRatioToView(self.qinChuCachImageView, 1);
    
    self.checkUpdateTitleLabel.sd_layout
    .centerYEqualToView(self.checkUpdateControl)
    .leftSpaceToView(self.checkUpdateImageView, 5)
    .widthRatioToView(self.qinChuCachTitleLabel, 1)
    .heightRatioToView(self.qinChuCachTitleLabel, 1);
    
    self.checkUpdateArrow.sd_layout
    .centerYEqualToView(self.checkUpdateControl)
    .rightSpaceToView(self.checkUpdateControl, 12)
    .widthRatioToView(self.qinChuCachArrow, 1)
    .heightRatioToView(self.qinChuCachArrow, 1);
    
    self.checkUpdateContentLabel.sd_layout
    .centerYEqualToView(self.checkUpdateControl)
    .rightSpaceToView(self.checkUpdateArrow, 2)
    .widthRatioToView(self.qinChuCachContentLabel, 1)
    .heightRatioToView(self.qinChuCachContentLabel, 1);
    
    
    //关于我们
    self.aboutUsImageView.sd_layout
    .centerYEqualToView(self.aboutUsControl)
    .leftSpaceToView(self.aboutUsControl, 12)
    .widthRatioToView(self.qinChuCachImageView, 1)
    .heightRatioToView(self.qinChuCachImageView, 1);
    
    self.aboutUsTitleLabel.sd_layout
    .centerYEqualToView(self.aboutUsControl)
    .leftSpaceToView(self.aboutUsImageView, 5)
    .widthRatioToView(self.qinChuCachTitleLabel, 1)
    .heightRatioToView(self.qinChuCachTitleLabel, 1);
    
    self.aboutUsArrow.sd_layout
    .centerYEqualToView(self.aboutUsControl)
    .rightSpaceToView(self.aboutUsControl, 12)
    .widthRatioToView(self.qinChuCachArrow, 1)
    .heightRatioToView(self.qinChuCachArrow, 1);
    
    //人脸识别提示音
    self.faceImageView.sd_layout
    .centerYEqualToView(self.faceControl)
    .leftSpaceToView(self.faceControl, 12)
    .widthRatioToView(self.qinChuCachImageView, 1)
    .heightRatioToView(self.qinChuCachImageView, 1);
    
    self.faceTitleLabel.sd_layout
    .centerYEqualToView(self.faceControl)
    .leftSpaceToView(self.faceImageView, 5)
    .widthRatioToView(self.qinChuCachTitleLabel, 1)
    .heightRatioToView(self.qinChuCachTitleLabel, 1);
    
    self.faceBtn.sd_layout
    .centerYEqualToView(self.faceControl)
    .rightSpaceToView(self.faceControl, 12)
    .widthIs(60)
    .heightIs(32);
    
    //注销账号
    self.cancellationImageView.sd_layout
    .centerYEqualToView(self.cancellationControl)
    .leftSpaceToView(self.cancellationControl, 12)
    .widthRatioToView(self.qinChuCachImageView, 1)
    .heightRatioToView(self.qinChuCachImageView, 1);
    
    self.cancellationTitleLabel.sd_layout
    .centerYEqualToView(self.cancellationControl)
    .leftSpaceToView(self.cancellationImageView, 5)
    .widthRatioToView(self.qinChuCachTitleLabel, 1)
    .heightRatioToView(self.qinChuCachTitleLabel, 1);
    
    self.cancellationArrow.sd_layout
    .centerYEqualToView(self.cancellationControl)
    .rightSpaceToView(self.cancellationControl, 12)
    .widthRatioToView(self.qinChuCachArrow, 1)
    .heightRatioToView(self.qinChuCachArrow, 1);
    
    
   
}

#pragma mark - LazyLoad

-(UIControl *)qinChuCachControl{
    if (!_qinChuCachControl) {
        _qinChuCachControl = [[UIControl alloc] init];
        _qinChuCachControl.backgroundColor = UIColor.whiteColor;
        [_qinChuCachControl addTarget:self action:@selector(qinChuCach) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qinChuCachControl;
}


-(UIImageView *)qinChuCachImageView{
    if (!_qinChuCachImageView) {
        _qinChuCachImageView = [[UIImageView alloc] init];
        _qinChuCachImageView.image = [UIImage imageNamed:@"qinchucach_icon"];
    }
    return _qinChuCachImageView;
}

-(UILabel *)qinChuCachTitleLabel{
    if (!_qinChuCachTitleLabel) {
        _qinChuCachTitleLabel = [[UILabel alloc] init];
        _qinChuCachTitleLabel.textAlignment = NSTextAlignmentLeft;
        _qinChuCachTitleLabel.font = HXFont(15);
        _qinChuCachTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _qinChuCachTitleLabel.text = @"清除缓存";
    }
    return _qinChuCachTitleLabel;
}

-(UILabel *)qinChuCachContentLabel{
    if (!_qinChuCachContentLabel) {
        _qinChuCachContentLabel = [[UILabel alloc] init];
        _qinChuCachContentLabel.textAlignment = NSTextAlignmentRight;
        _qinChuCachContentLabel.font = HXFont(13);
        _qinChuCachContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
    }
    return _qinChuCachContentLabel;
}

-(UIImageView *)qinChuCachArrow{
    if (!_qinChuCachArrow) {
        _qinChuCachArrow = [[UIImageView alloc] init];
        _qinChuCachArrow.image = [UIImage imageNamed:@"set_arrow"];
    }
    return _qinChuCachArrow;
}


-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = UIColor.whiteColor;
    }
    return _containerView;
}


-(UIControl *)checkUpdateControl{
    if (!_checkUpdateControl) {
        _checkUpdateControl = [[UIControl alloc] init];
        _checkUpdateControl.backgroundColor = UIColor.whiteColor;
    }
    return _checkUpdateControl;
}


-(UIImageView *)checkUpdateImageView{
    if (!_checkUpdateImageView) {
        _checkUpdateImageView = [[UIImageView alloc] init];
        _checkUpdateImageView.image = [UIImage imageNamed:@"checkupdate_icon"];
    }
    return _checkUpdateImageView;
}

-(UILabel *)checkUpdateTitleLabel{
    if (!_checkUpdateTitleLabel) {
        _checkUpdateTitleLabel = [[UILabel alloc] init];
        _checkUpdateTitleLabel.textAlignment = NSTextAlignmentLeft;
        _checkUpdateTitleLabel.font = HXFont(15);
        _checkUpdateTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _checkUpdateTitleLabel.text = @"检查更新";
    }
    return _checkUpdateTitleLabel;
}

-(UILabel *)checkUpdateContentLabel{
    if (!_checkUpdateContentLabel) {
        _checkUpdateContentLabel = [[UILabel alloc] init];
        _checkUpdateContentLabel.textAlignment = NSTextAlignmentRight;
        _checkUpdateContentLabel.font = HXFont(13);
        _checkUpdateContentLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _checkUpdateContentLabel.text = [NSString stringWithFormat:@"V %@",APP_VERSION];
    }
    return _checkUpdateContentLabel;
}


-(UIImageView *)checkUpdateArrow{
    if (!_checkUpdateArrow) {
        _checkUpdateArrow = [[UIImageView alloc] init];
        _checkUpdateArrow.image = [UIImage imageNamed:@"set_arrow"];
    }
    return _checkUpdateArrow;
}


-(UIView *)line1{
    if (!_line1) {
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = COLOR_WITH_ALPHA(0xEBEBEB, 1);
    }
    return _line1;
}


-(UIControl *)aboutUsControl{
    if (!_aboutUsControl) {
        _aboutUsControl = [[UIControl alloc] init];
        _aboutUsControl.backgroundColor = UIColor.whiteColor;
    }
    return _aboutUsControl;
}


-(UIImageView *)aboutUsImageView{
    if (!_aboutUsImageView) {
        _aboutUsImageView = [[UIImageView alloc] init];
        _aboutUsImageView.image = [UIImage imageNamed:@"aboutus_icon"];
    }
    return _aboutUsImageView;
}

-(UILabel *)aboutUsTitleLabel{
    if (!_aboutUsTitleLabel) {
        _aboutUsTitleLabel = [[UILabel alloc] init];
        _aboutUsTitleLabel.textAlignment = NSTextAlignmentLeft;
        _aboutUsTitleLabel.font = HXFont(15);
        _aboutUsTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _aboutUsTitleLabel.text = @"关于我们";
    }
    return _aboutUsTitleLabel;
}


-(UIImageView *)aboutUsArrow{
    if (!_aboutUsArrow) {
        _aboutUsArrow = [[UIImageView alloc] init];
        _aboutUsArrow.image = [UIImage imageNamed:@"set_arrow"];
    }
    return _aboutUsArrow;
}


-(UIView *)line2{
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = COLOR_WITH_ALPHA(0xEBEBEB, 1);
    }
    return _line2;
}

-(UIControl *)faceControl{
    if (!_faceControl) {
        _faceControl = [[UIControl alloc] init];
        _faceControl.backgroundColor = UIColor.whiteColor;
    }
    return _faceControl;
}


-(UIImageView *)faceImageView{
    if (!_faceImageView) {
        _faceImageView = [[UIImageView alloc] init];
        _faceImageView.image = [UIImage imageNamed:@"face_icon"];
    }
    return _faceImageView;
}

-(UILabel *)faceTitleLabel{
    if (!_faceTitleLabel) {
        _faceTitleLabel = [[UILabel alloc] init];
        _faceTitleLabel.textAlignment = NSTextAlignmentLeft;
        _faceTitleLabel.font = HXFont(15);
        _faceTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _faceTitleLabel.text = @"人脸识别提示音";
    }
    return _faceTitleLabel;
}


-(UISwitch *)faceBtn{
    if (!_faceBtn) {
        _faceBtn = [[UISwitch alloc] init];
        _faceBtn.onTintColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _faceBtn.thumbTintColor = UIColor.whiteColor;
        _faceBtn.on = ![HXUserDefaults boolForKey:CloseFaceLivenessSound];
        [_faceBtn addTarget:self action:@selector(enableFaceSound:) forControlEvents:UIControlEventValueChanged];
    }
    return _faceBtn;
}


-(UIView *)line3{
    if (!_line3) {
        _line3 = [[UIView alloc] init];
        _line3.backgroundColor = COLOR_WITH_ALPHA(0xEBEBEB, 1);
    }
    return _line3;
}

-(UIControl *)cancellationControl{
    if (!_cancellationControl) {
        _cancellationControl = [[UIControl alloc] init];
        _cancellationControl.backgroundColor = UIColor.whiteColor;
    }
    return _cancellationControl;
}


-(UIImageView *)cancellationImageView{
    if (!_cancellationImageView) {
        _cancellationImageView = [[UIImageView alloc] init];
        _cancellationImageView.image = [UIImage imageNamed:@"cancellation_icon"];
    }
    return _cancellationImageView;
}

-(UILabel *)cancellationTitleLabel{
    if (!_cancellationTitleLabel) {
        _cancellationTitleLabel = [[UILabel alloc] init];
        _cancellationTitleLabel.textAlignment = NSTextAlignmentLeft;
        _cancellationTitleLabel.font = HXFont(15);
        _cancellationTitleLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _cancellationTitleLabel.text = @"注销账号";
    }
    return _cancellationTitleLabel;
}


-(UIImageView *)cancellationArrow{
    if (!_cancellationArrow) {
        _cancellationArrow = [[UIImageView alloc] init];
        _cancellationArrow.image = [UIImage imageNamed:@"set_arrow"];
    }
    return _cancellationArrow;
}

-(UIButton *)logOutBtn{
    if (!_logOutBtn) {
        _logOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _logOutBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _logOutBtn.titleLabel.font = HXBoldFont(15);
        [_logOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_logOutBtn setTitle:@"退出账号" forState:UIControlStateNormal];
        _logOutBtn.backgroundColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        [_logOutBtn addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logOutBtn;
}


@end
