//
//  HXZiLiaoDownLoadViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/23.
//

#import "HXZiLiaoDownLoadViewController.h"
#import "HXZiLiaoDownLoadCell.h"
#import <QuickLook/QuickLook.h>


@interface HXZiLiaoDownLoadViewController ()<UITableViewDelegate,UITableViewDataSource,HXZiLiaoDownLoadCellDelegate,UIDocumentPickerDelegate,QLPreviewControllerDataSource>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic, copy) NSString *downLoadUrl;
@property (nonatomic, strong) QLPreviewController *QLController;
@property (nonatomic, copy) NSURL *fileURL;

@end

@implementation HXZiLiaoDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取下载资源列表
    [self getResource];
    
    self.QLController = [[QLPreviewController alloc] init];
    self.QLController.dataSource = self;
}

#pragma mark - 获取下载资源列表
-(void)getResource{
  
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetResource needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXZiLiaoDownLoadModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            [self.mainTableView reloadData];
            if (list.count==0) {
                [self.mainTableView addSubview:self.noDataTipView];
            }else{
                [self.noDataTipView removeFromSuperview];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"资料下载";
   
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    [self.mainTableView updateLayout];
    
    self.noDataTipView.tipTitle = @"暂无资料～";
    self.noDataTipView.frame = self.mainTableView.bounds;
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getResource)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
   
}

#pragma mark - <UHXZiLiaoDownLoadCellDelegate>下载资料
-(void)ziLiaoDownLoad:(HXZiLiaoDownLoadModel *)ziLiaoDownLoadModel{
    NSString *downLoadUrl = [HXCommonUtil stringEncoding:ziLiaoDownLoadModel.filePath];
    if ([HXCommonUtil isNull:downLoadUrl]){
        [self.view showTostWithMessage:@"资源无效"];
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 1. 创建会话管理者
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    // 2. 创建下载路径和请求对象
    NSURL *URL = [NSURL URLWithString:downLoadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSString *fileName = ziLiaoDownLoadModel.fileName;
    [self.view showLoadingWithMessage:@"正在下载..."];

    //下载文件
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){

    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *url = [documentsDirectoryURL URLByAppendingPathComponent:fileName];
        return url;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [self.view hideLoading];
        self.fileURL = filePath;
        [self presentViewController:self.QLController animated:YES completion:nil];
        //刷新界面,如果不刷新的话，不重新走一遍代理方法，返回的url还是上一次的url
        [self.QLController refreshCurrentPreviewItem];
    }];
    [downloadTask resume];
}


#pragma mark - QLPreviewControllerDataSource
/// 文件路径
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileURL;
}
/// 文件数
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}


#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return 142;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ziLiaoDownLoadCellIdentifier = @"HXZiLiaoDownLoadCellIdentifier";
    HXZiLiaoDownLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:ziLiaoDownLoadCellIdentifier];
    if (!cell) {
        cell = [[HXZiLiaoDownLoadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ziLiaoDownLoadCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.ziLiaoDownLoadModel = self.dataArray[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end


