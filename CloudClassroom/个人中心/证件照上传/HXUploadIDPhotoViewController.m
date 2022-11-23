//
//  HXUploadIDPhotoViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/13.
//

#import "HXUploadIDPhotoViewController.h"
#import "HXFanKuiYouWuViewController.h"
#import "UIViewController+HXExtension.h"
#import "HXPhotoManager.h"
#import "HXPhotoInfoModel.h"
#import "SDWebImage.h"

@interface HXUploadIDPhotoViewController ()

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIView *topContainerView;
@property(nonatomic,strong) UIButton *zhengQueBtn;
@property(nonatomic,strong) UIImageView *tipImageView;
@property(nonatomic,strong) UILabel *yaoQiuLabel;
@property(nonatomic,strong) UILabel *yaoQiuContentLabel1;
@property(nonatomic,strong) UILabel *yaoQiuContentLabel2;
@property(nonatomic,strong) UILabel *yaoQiuContentLabel3;

@property(nonatomic,strong) UIView *bottomContainerView;
@property(nonatomic,strong) UIButton *uploadPhotoBtn;
@property(nonatomic,strong) UIImageView *photoImageView;
@property(nonatomic,strong) UIButton *addPhotoBtn;
@property(nonatomic,strong) UIButton *goUploadBtn;
@property(nonatomic,strong) UIButton *fanKuiYouWuBtn;
@property(nonatomic,strong) UIButton *confirmBtn;
@property(nonatomic,strong) UIButton *tipResultBtn;

@property(nonatomic,strong) HXPhotoInfoModel *photoInfoModel;

@property(nonatomic,strong) HXPhotoManager *photoManager;


@end

@implementation HXUploadIDPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    //获取证件照信息
    [self getPapersPhotoInfo];
    
   
}


#pragma mark - 获取证件照信息
-(void)getPapersPhotoInfo{
    NSString *student_id = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"student_id":HXSafeString(student_id)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetPapersPhotoInfo needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.photoInfoModel = [HXPhotoInfoModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            //刷新界面UI
            [self refreshUI];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

//刷新界面UI
-(void)refreshUI{
    
    if ([HXCommonUtil isNull:self.photoInfoModel.imgUrl]) {//没照片
        self.photoImageView.hidden = self.fanKuiYouWuBtn.hidden = self.confirmBtn.hidden = YES;
        self.addPhotoBtn.hidden = self.goUploadBtn.hidden = NO;
    }else{
        self.photoImageView.hidden = self.fanKuiYouWuBtn.hidden = self.confirmBtn.hidden = NO;
        self.addPhotoBtn.hidden = self.goUploadBtn.hidden = YES;
        [self.photoImageView sd_setImageWithURL:HXSafeURL(self.photoInfoModel.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
        ///照片确认状态    0:未确认       1:已确认
        if (self.photoInfoModel.comStatus==1) {
            self.fanKuiYouWuBtn.hidden = self.confirmBtn.hidden = YES;
            self.tipResultBtn.hidden = NO;
        }else{
            self.fanKuiYouWuBtn.hidden = self.confirmBtn.hidden = NO;
            self.tipResultBtn.hidden = YES;
        }
    }
}

#pragma mark - Event
//选择照片
-(void)addPhoto:(UIButton *)sender{
    WeakSelf(weakSelf);
    [self hx_presentSelectPhotoControllerWithManager:self.photoManager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        HXPhotoModel *photoModel = allList.firstObject;
        // 因为是编辑过的照片所以直接取
        weakSelf.photoImageView.hidden = NO;
        weakSelf.addPhotoBtn.hidden = YES;
        weakSelf.photoImageView.image = photoModel.photoEdit.editPreviewImage;
        
    } cancel:nil];

}

-(void)tapPhotoImageView:(UITapGestureRecognizer *)tap{
    //无照片添加照片
    if ([HXCommonUtil isNull:self.photoInfoModel.imgUrl ]){
        [self addPhoto:nil];
    }
    
}

//上传照片
-(void)uploadPhoto:(UIButton *)sender{
    NSString *encodedImageStr = [self imageChangeBase64:self.photoImageView.image];
    if (!self.photoImageView.image){
        [self.view showTostWithMessage:@"请添加图片"];
        return;
    }
    
    sender.userInteractionEnabled =NO;
    NSString *student_id = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"student_id":HXSafeString(student_id),
        @"sourseImgBase64":HXSafeString(encodedImageStr)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_SavePhotoUpload needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        sender.userInteractionEnabled = YES;
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSString *message =[dictionary stringValueForKey:@"message"];
        if (success) {
            [self.view showSuccessWithMessage:message];
            //上传成功，重新获取一次照片信息
            [self getPapersPhotoInfo];
        }else{
            [self.view showTostWithMessage:message];;
        }
    } failure:^(NSError * _Nonnull error) {
        sender.userInteractionEnabled = YES;
    }];
    
}

-(void)fanKuiYouWu:(UIButton *)sender{
    
    HXFanKuiYouWuViewController *vc = [[HXFanKuiYouWuViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

//确认照片
-(void)confirm:(UIButton *)sender{
    sender.userInteractionEnabled =NO;
    NSString *student_id = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"student_id":HXSafeString(student_id),
        @"comstatus":@(1)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_ComfirmPhoto needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        sender.userInteractionEnabled = YES;
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSString *message =[dictionary stringValueForKey:@"message"];
        if (success) {
            [self.view showSuccessWithMessage:message];
            self.fanKuiYouWuBtn.hidden = self.confirmBtn.hidden = YES;
            self.tipResultBtn.hidden = NO;
        }else{
            [self.view showTostWithMessage:message];;
        }
    } failure:^(NSError * _Nonnull error) {
        sender.userInteractionEnabled = YES;
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
    self.sc_navigationBar.title = @"证件照上传";
    
    [self.view addSubview:self.mainScrollView];
    
    [self.mainScrollView addSubview:self.topContainerView];
    [self.mainScrollView addSubview:self.bottomContainerView];
    
    [self.topContainerView addSubview:self.zhengQueBtn];
    [self.topContainerView addSubview:self.tipImageView];
    [self.topContainerView addSubview:self.yaoQiuLabel];
    [self.topContainerView addSubview:self.yaoQiuContentLabel1];
    [self.topContainerView addSubview:self.yaoQiuContentLabel2];
    [self.topContainerView addSubview:self.yaoQiuContentLabel3];
    
    [self.bottomContainerView addSubview:self.uploadPhotoBtn];
    [self.bottomContainerView addSubview:self.photoImageView];
    [self.bottomContainerView addSubview:self.addPhotoBtn];
    [self.bottomContainerView addSubview:self.goUploadBtn];
    [self.bottomContainerView addSubview:self.fanKuiYouWuBtn];
    [self.bottomContainerView addSubview:self.confirmBtn];
    [self.bottomContainerView addSubview:self.tipResultBtn];
    
    self.mainScrollView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    
    self.topContainerView.sd_layout
    .topSpaceToView(self.mainScrollView, 16)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    self.topContainerView.sd_cornerRadius = @10;
    
    self.zhengQueBtn.sd_layout
    .topSpaceToView(self.topContainerView, 16)
    .centerXEqualToView(self.topContainerView)
    .heightIs(21);
    
    self.zhengQueBtn.imageView.sd_layout
    .centerYEqualToView(self.zhengQueBtn)
    .leftEqualToView(self.zhengQueBtn)
    .widthIs(20)
    .heightEqualToWidth();
    
    self.zhengQueBtn.titleLabel.sd_layout
    .centerYEqualToView(self.zhengQueBtn)
    .leftSpaceToView(self.zhengQueBtn.imageView, 8)
    .heightIs(21);
    [self.zhengQueBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:80];
    
    [self.zhengQueBtn setupAutoWidthWithRightView:self.zhengQueBtn.titleLabel rightMargin:0];
    
    self.tipImageView.sd_layout
    .topSpaceToView(self.zhengQueBtn, 16)
    .centerXEqualToView(self.topContainerView)
    .widthIs(81)
    .heightIs(101);
    
    self.yaoQiuLabel.sd_layout
    .topSpaceToView(self.tipImageView, 20)
    .leftSpaceToView(self.topContainerView, 30)
    .rightSpaceToView(self.topContainerView, 30)
    .heightIs(16);
    
    self.yaoQiuContentLabel1.sd_layout
    .topSpaceToView(self.yaoQiuLabel, 6)
    .leftEqualToView(self.yaoQiuLabel)
    .rightEqualToView(self.yaoQiuLabel)
    .autoHeightRatio(0);
    
    self.yaoQiuContentLabel2.sd_layout
    .topSpaceToView(self.yaoQiuContentLabel1, 6)
    .leftEqualToView(self.yaoQiuLabel)
    .rightEqualToView(self.yaoQiuLabel)
    .autoHeightRatio(0);
    
    self.yaoQiuContentLabel3.sd_layout
    .topSpaceToView(self.yaoQiuContentLabel2, 6)
    .leftEqualToView(self.yaoQiuLabel)
    .rightEqualToView(self.yaoQiuLabel)
    .autoHeightRatio(0);
    
    [self.topContainerView setupAutoHeightWithBottomView:self.yaoQiuContentLabel3 bottomMargin:16];
    
    
    self.bottomContainerView.sd_layout
    .topSpaceToView(self.topContainerView, 12)
    .leftEqualToView(self.topContainerView)
    .rightEqualToView(self.topContainerView)
    .heightIs(300);
    self.bottomContainerView.sd_cornerRadius = @10;
    
    self.uploadPhotoBtn.sd_layout
    .topSpaceToView(self.bottomContainerView, 16)
    .centerXEqualToView(self.bottomContainerView)
    .heightIs(21);
    
    self.uploadPhotoBtn.imageView.sd_layout
    .centerYEqualToView(self.uploadPhotoBtn)
    .leftEqualToView(self.uploadPhotoBtn)
    .widthIs(20)
    .heightEqualToWidth();
    
    self.uploadPhotoBtn.titleLabel.sd_layout
    .centerYEqualToView(self.uploadPhotoBtn)
    .leftSpaceToView(self.uploadPhotoBtn.imageView, 8)
    .heightIs(21);
    [self.uploadPhotoBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:80];
    
    [self.uploadPhotoBtn setupAutoWidthWithRightView:self.uploadPhotoBtn.titleLabel rightMargin:0];
    
    self.addPhotoBtn.sd_layout
    .topSpaceToView(self.uploadPhotoBtn, 25)
    .centerXEqualToView(self.bottomContainerView)
    .widthIs(113)
    .heightIs(141);
    
    self.photoImageView.sd_layout
    .topEqualToView(self.addPhotoBtn)
    .leftEqualToView(self.addPhotoBtn)
    .rightEqualToView(self.addPhotoBtn)
    .bottomEqualToView(self.addPhotoBtn);
    
    self.goUploadBtn.sd_layout
    .topSpaceToView(self.addPhotoBtn, 30)
    .centerXEqualToView(self.bottomContainerView)
    .widthIs(113)
    .heightIs(36);
    self.goUploadBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.fanKuiYouWuBtn.sd_layout
    .topSpaceToView(self.addPhotoBtn, 30)
    .leftSpaceToView(self.bottomContainerView, 50)
    .widthIs(113)
    .heightIs(36);
    self.fanKuiYouWuBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.confirmBtn.sd_layout
    .centerYEqualToView(self.fanKuiYouWuBtn)
    .rightSpaceToView(self.bottomContainerView, 50)
    .widthRatioToView(self.fanKuiYouWuBtn, 1)
    .heightRatioToView(self.fanKuiYouWuBtn, 1);
    self.confirmBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.tipResultBtn.sd_layout
    .topSpaceToView(self.addPhotoBtn, 30)
    .centerXEqualToView(self.bottomContainerView)
    .widthIs(103)
    .heightIs(26);
    self.tipResultBtn.sd_cornerRadius = @2;
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.bottomContainerView bottomMargin:50];
    
}

#pragma mark - lazyLoad

- (HXPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _photoManager.selectPhotoFinishDismissAnimated = YES;
        _photoManager.cameraFinishDismissAnimated = YES;
        _photoManager.type = HXPhotoManagerSelectedTypePhoto;
        _photoManager.configuration.singleJumpEdit = YES;
        _photoManager.configuration.singleSelected = YES;
        _photoManager.configuration.lookGifPhoto = NO;
        _photoManager.configuration.lookLivePhoto = NO;
        _photoManager.configuration.photoEditConfigur.aspectRatio = HXPhotoEditAspectRatioType_Custom;
        _photoManager.configuration.photoEditConfigur.onlyCliping = YES;
    }
    return _photoManager;
}

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

-(UIView *)topContainerView{
    if (!_topContainerView) {
        _topContainerView = [[UIView alloc] init];
        _topContainerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _topContainerView;
}

- (UIButton *)zhengQueBtn{
    if (!_zhengQueBtn) {
        _zhengQueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _zhengQueBtn.titleLabel.font = HXBoldFont(15);
        _zhengQueBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_zhengQueBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_zhengQueBtn setImage:[UIImage imageNamed:@"zhengqueshifan_icon"] forState:UIControlStateNormal];
        [_zhengQueBtn setTitle:@"正确示范" forState:UIControlStateNormal];
       
    }
    return _zhengQueBtn;
}

-(UIImageView *)tipImageView{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.clipsToBounds = YES;
        _tipImageView.contentMode = UIViewContentModeScaleAspectFill;
        _tipImageView.image = [UIImage imageNamed:@"zhengqueshifanphoto_icon"];
    }
    return _tipImageView;
}

-(UILabel *)yaoQiuLabel{
    if (!_yaoQiuLabel) {
        _yaoQiuLabel = [[UILabel alloc] init];
        _yaoQiuLabel.textAlignment = NSTextAlignmentLeft;
        _yaoQiuLabel.font = HXBoldFont(11);
        _yaoQiuLabel.textColor = COLOR_WITH_ALPHA(0xEF5959, 1);
        _yaoQiuLabel.text = @"电子版图像要求：";
    }
    return _yaoQiuLabel;
}

-(UILabel *)yaoQiuContentLabel1{
    if (!_yaoQiuContentLabel1) {
        _yaoQiuContentLabel1 = [[UILabel alloc] init];
        _yaoQiuContentLabel1.textAlignment = NSTextAlignmentLeft;
        _yaoQiuContentLabel1.font = HXFont(12);
        _yaoQiuContentLabel1.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _yaoQiuContentLabel1.numberOfLines = 0;
        _yaoQiuContentLabel1.isAttributedContent = YES;
        _yaoQiuContentLabel1.attributedText = [HXCommonUtil getAttributedStringWithArray:@[@"100KB",@"192x144"] needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} content:@"1、蓝色背景，图像大小为100KB，高x宽 应为 192x144" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
    }
    return _yaoQiuContentLabel1;
}

-(UILabel *)yaoQiuContentLabel2{
    if (!_yaoQiuContentLabel2) {
        _yaoQiuContentLabel2 = [[UILabel alloc] init];
        _yaoQiuContentLabel2.textAlignment = NSTextAlignmentLeft;
        _yaoQiuContentLabel2.font = HXFont(12);
        _yaoQiuContentLabel2.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _yaoQiuContentLabel2.numberOfLines = 0;
        _yaoQiuContentLabel2.isAttributedContent = YES;
        _yaoQiuContentLabel2.attributedText = [HXCommonUtil getAttributedStringWithArray:@[@"标准证件照"] needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} content:@"2、鉴于毕业照片的严肃性，请同学务必提交标准证件照，生活照、手机自拍、以及PS、美图等工具修复的照片均不予审核通过" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
    }
    return _yaoQiuContentLabel2;
}

-(UILabel *)yaoQiuContentLabel3{
    if (!_yaoQiuContentLabel3) {
        _yaoQiuContentLabel3 = [[UILabel alloc] init];
        _yaoQiuContentLabel3.textAlignment = NSTextAlignmentLeft;
        _yaoQiuContentLabel3.font = HXFont(12);
        _yaoQiuContentLabel3.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _yaoQiuContentLabel3.numberOfLines = 0;
        _yaoQiuContentLabel3.isAttributedContent = YES;
        _yaoQiuContentLabel3.attributedText = [HXCommonUtil getAttributedStringWithArray:@[@".jpg"] needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} content:@"3、拍完照片后，照片以格式 .jpg 命名" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x333333, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
    }
    return _yaoQiuContentLabel3;
}

-(UIView *)bottomContainerView{
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        _bottomContainerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _bottomContainerView;
}

- (UIButton *)uploadPhotoBtn{
    if (!_uploadPhotoBtn) {
        _uploadPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _uploadPhotoBtn.titleLabel.font = HXBoldFont(15);
        _uploadPhotoBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_uploadPhotoBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_uploadPhotoBtn setImage:[UIImage imageNamed:@"uploadphoto_icon"] forState:UIControlStateNormal];
        [_uploadPhotoBtn setTitle:@"上传照片" forState:UIControlStateNormal];
        
    }
    return _uploadPhotoBtn;
}

- (UIButton *)addPhotoBtn{
    if (!_addPhotoBtn) {
        _addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addPhotoBtn setImage:[UIImage imageNamed:@"addphoto_icon"] forState:UIControlStateNormal];
        [_addPhotoBtn addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addPhotoBtn;
}

-(UIImageView *)photoImageView{
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.clipsToBounds = YES;
        _photoImageView.userInteractionEnabled = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoImageView:)];
        [_photoImageView addGestureRecognizer:tap];
    }
    return _photoImageView;
}


-(UIButton *)goUploadBtn{
    if (!_goUploadBtn) {
        _goUploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goUploadBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _goUploadBtn.titleLabel.font = HXBoldFont(14);
        [_goUploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_goUploadBtn setTitle:@"去上传" forState:UIControlStateNormal];
        _goUploadBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_goUploadBtn addTarget:self action:@selector(uploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goUploadBtn;
}


-(UIButton *)fanKuiYouWuBtn{
    if (!_fanKuiYouWuBtn) {
        _fanKuiYouWuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fanKuiYouWuBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _fanKuiYouWuBtn.titleLabel.font = HXBoldFont(14);
        _fanKuiYouWuBtn.layer.borderWidth = 1;
        _fanKuiYouWuBtn.layer.borderColor = COLOR_WITH_ALPHA(0x2E5BFD, 1) .CGColor;
        [_fanKuiYouWuBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_fanKuiYouWuBtn setTitle:@"反馈有误" forState:UIControlStateNormal];
        _fanKuiYouWuBtn.backgroundColor = [UIColor whiteColor];
        [_fanKuiYouWuBtn addTarget:self action:@selector(fanKuiYouWu:) forControlEvents:UIControlEventTouchUpInside];
        _fanKuiYouWuBtn.hidden = YES;
    }
    return _fanKuiYouWuBtn;
}

-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _confirmBtn.titleLabel.font = HXBoldFont(14);
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"确认无误" forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.hidden = YES;
    }
    return _confirmBtn;
}


-(UIButton *)tipResultBtn{
    if (!_tipResultBtn) {
        _tipResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _tipResultBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _tipResultBtn.titleLabel.font = HXBoldFont(12);
        [_tipResultBtn setTitleColor:COLOR_WITH_ALPHA(0x5DC367, 1) forState:UIControlStateNormal];
        [_tipResultBtn setTitle:@"已确认无误" forState:UIControlStateNormal];
        _tipResultBtn.backgroundColor = COLOR_WITH_ALPHA(0xF2FFF3, 1);
        _tipResultBtn.hidden = YES;
    }
    return _tipResultBtn;
}




@end
