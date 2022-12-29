//
//  HXZiLiaoUploadViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/27.
//

#import "HXZiLiaoUploadViewController.h"
#import "HXZiLiaoUploadCell.h"
#import "HXPhotoManager.h"
#import "GKPhotoBrowser.h"
#import "GKCover.h"
#import "UIViewController+HXExtension.h"
#import "HXMaterialModel.h"


@interface HXZiLiaoUploadViewController ()<UITableViewDelegate,UITableViewDataSource,HXZiLiaoUploadCellDelegate>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) HXPhotoManager *photoManager;
/** 这里用weak是防止GKPhotoBrowser被强引用，导致不能释放 */
@property (nonatomic, weak) GKPhotoBrowser *browser;

@property(nonatomic,strong) NSArray *titles;
@property(nonatomic,strong) NSArray *tips;

@property(nonatomic,strong) HXMaterialModel *materialModel;

@property(nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HXZiLiaoUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取新生材料
    [self getMaterialList];
}

-(void)dealloc{
    
}

#pragma mark - 获取新生材料
-(void)getMaterialList{
  
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetMaterialList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.materialModel = [HXMaterialModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]].firstObject;
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:self.materialModel.imgList];
            [self.mainTableView reloadData];
            if (self.materialModel.imgList.count==0) {
                [self.mainTableView addSubview:self.noDataTipView];
            }else{
                [self.noDataTipView removeFromSuperview];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}
#pragma mark - 学生上传新生材料
-(void)uploadStudentFile:(NSString *)encodedImageStr typeName:(NSString *)typeName{
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic = @{
        @"student_id":HXSafeString(studentId),
        @"sourceimagebase64":HXSafeString(encodedImageStr),
        @"typename":HXSafeString(typeName),
        
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_SaveMaterial needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            [self.view showSuccessWithMessage:[dictionary stringValueForKey:@"message"]];
            //刷新数据
            [self getMaterialList];
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





#pragma mark - <HXZiLiaoUploadCellDelegate>
-(void)addPhotoForZiLiaoImageView:(UIImageView *)ziLiaoImageView hiddenAddBtn:(nonnull UIButton *)button imgModel:(nonnull HXImgModel *)imgModel{
    WeakSelf(weakSelf);
    [self hx_presentSelectPhotoControllerWithManager:self.photoManager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        HXPhotoModel *photoModel = allList.firstObject;
        // 因为是编辑过的照片所以直接取
        ziLiaoImageView.image = photoModel.photoEdit.editPreviewImage;
        button.hidden = YES;
        //上传图片
        [weakSelf uploadStudentFile:[self imageChangeBase64:photoModel.photoEdit.editPreviewImage] typeName:imgModel.typeName];
    } cancel:nil];
    
}

-(void)tapZiLiaoImageView:(UIImageView *)ziLiaoImageView imgModel:(nonnull HXImgModel *)imgModel{
    ///审核状态 0-待审核 1-审核通过 2-重新上传  (1-审核通过不能再上传了)
    if (self.materialModel.checkStatus==1) {
        NSMutableArray *photos = [NSMutableArray new];
        GKPhoto *photo = [GKPhoto new];
        photo.image = ziLiaoImageView.image;
        photo.sourceImageView = ziLiaoImageView;
        [photos addObject:photo];
        [self.browser resetPhotoBrowserWithPhotos:photos];
        [self.browser showFromVC:self];
    }else{
        WeakSelf(weakSelf);
        [self hx_presentSelectPhotoControllerWithManager:self.photoManager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            HXPhotoModel *photoModel = allList.firstObject;
            // 因为是编辑过的照片所以直接取
            ziLiaoImageView.image = photoModel.photoEdit.editPreviewImage;
            //上传图片
            [weakSelf uploadStudentFile:[self imageChangeBase64:photoModel.photoEdit.editPreviewImage] typeName:imgModel.typeName];
        } cancel:nil];
    }
    
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return 230;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ziLiaoUploadCellIdentifier = @"HXZiLiaoUploadCellIdentifier";
    HXZiLiaoUploadCell *cell = [tableView dequeueReusableCellWithIdentifier:ziLiaoUploadCellIdentifier];
    if (!cell) {
        cell = [[HXZiLiaoUploadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ziLiaoUploadCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.imgModel = self.dataArray[indexPath.row];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI
-(void)createUI{
    
    
    
    self.sc_navigationBar.title = @"资料上传";
   
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    [self.mainTableView updateLayout];
    
    self.noDataTipView.tipTitle = @"暂无资料上传～";
    self.noDataTipView.frame = self.mainTableView.bounds;
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getMaterialList)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    
    
}

#pragma mark -LazyLoad
-(NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.bounces = YES;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = VCBackgroundColor;
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
        _mainTableView.showsVerticalScrollIndicator = NO;
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        _mainTableView.tableHeaderView =tableHeaderView;
       
    }
    return _mainTableView;
}

- (HXPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _photoManager.selectPhotoFinishDismissAnimated = NO;
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

-(GKPhotoBrowser *)browser{
    if (!_browser) {
        _browser = [GKPhotoBrowser photoBrowserWithPhotos:[NSArray array] currentIndex:0];
        _browser.showStyle = GKPhotoBrowserShowStyleZoom;        // 缩放显示
        _browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;   // 缩放隐藏
        _browser.loadStyle = GKPhotoBrowserLoadStyleIndeterminateMask; // 不明确的加载方式带阴影
        _browser.maxZoomScale = 5.0f;
        _browser.doubleZoomScale = 2.0f;
        _browser.isAdaptiveSafeArea = YES;
        _browser.hidesCountLabel = YES;
        _browser.pageControl.hidden = YES;
        _browser.isScreenRotateDisabled = YES;
        _browser.isHideSourceView = NO;
//        _browser.delegate = self;
        
    }
    return _browser;
}

@end



