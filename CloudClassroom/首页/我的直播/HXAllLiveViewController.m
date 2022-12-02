//
//  HXAllLiveViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/10/18.
//

#import "HXAllLiveViewController.h"
#import "HXLiveDetailViewController.h"
#import "HXMyLiveCell.h"
#import "HXEnterLiveInfoModel.h"
#import "HXLivePlaybackInfoModel.h"
#import <SafariServices/SafariServices.h>
#import <BJLiveCore/BJLiveCore.h>
#import "BJLiveUIBase.h"
#import "BJPlaybackUI.h"

@interface HXAllLiveViewController ()<UITableViewDelegate,UITableViewDataSource,HXMyLiveCellDelegate,BJLRoomVCDelegate,BJVRequestTokenDelegate>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) NSMutableArray *dataArray;


@end

@implementation HXAllLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    //获取每一门课的直播列表
    [self getDirectBroadcastDetail];
}


#pragma mark - Setter

-(void)setLiveCourseModel:(HXLiveCourseModel *)liveCourseModel{
    _liveCourseModel = liveCourseModel;
}



#pragma mark - <HXMyLiveCellDelegate>观看直播
-(void)watchLiveWithDetailModel:(HXLiveDetailModel *)liveDetailModel{
    
    ///直播状态（0未开始 1正在直播 2已结束）
    if (liveDetailModel.dbStatus==1) {
        
        if (@available(iOS 10, *)) {
            
            [self.view showLoading];

            //获取进入直播间的参数
            NSDictionary *dic = @{
                @"detailid":HXSafeString(liveDetailModel.detailID),
                @"studentid":HXSafeString(liveDetailModel.student_id)
                
            };
            WeakSelf(weakSelf);
            [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetEnterInfo needMd5:YES withDictionary:dic success:^(NSDictionary * _Nullable dictionary) {
                
                BOOL success = [dictionary boolValueForKey:@"success"];
                if (success) {
                    [weakSelf.view hideLoading];
                    
                    HXEnterLiveInfoModel *enterLiveInfoModel =[HXEnterLiveInfoModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
                    
                    //创建直播房间
                    BJLRoomID *roomID = [[BJLRoomID alloc] init];
                    roomID.roomID = enterLiveInfoModel.room_id;
                    roomID.apiSign = enterLiveInfoModel.sign;
                    //创建用户
                    BJLUser *user = [BJLUser userWithNumber:enterLiveInfoModel.user_number name:enterLiveInfoModel.user_name groupID:0 avatar:enterLiveInfoModel.user_avatar role:enterLiveInfoModel.user_role];
                    roomID.user = user;
                    //进入直播间
                    [weakSelf enterRoomWithRoomID:roomID domain:enterLiveInfoModel.private_domain];
                }else{
                    NSString *message = [dictionary stringValueForKey:@"message" WithHolder:@"获取数据失败,请重试!"];
                    [weakSelf.view showErrorWithMessage:message];
                }
                
            } failure:^(NSError *error) {
                [weakSelf.view showErrorWithMessage:@"获取数据失败，请重试！"];
            }];
            
        }else{
            NSLog(@"系统版本太低，不支持播放！");
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"系统检测到您的设备操作系统版本过低，不支持观看直播，建议您升级设备操作系统！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:confirmAction];
            [self.presentedViewController?self.presentedViewController:self presentViewController:alertC animated:YES completion:nil];
        }
    }else if (liveDetailModel.dbStatus==2){
        //不能回放
        if (liveDetailModel.playMessage.length>0) {
            [self.view showTostWithMessage:liveDetailModel.playMessage];
            return;
        }
        
        //回放
        [self.view showLoading];
        
        //获取直播回放参数
        NSDictionary *dic = @{
            @"detailid":HXSafeString(liveDetailModel.detailID),
            @"studentid":HXSafeString(liveDetailModel.student_id)
        };
        
        WeakSelf(weakSelf);
        [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetPlayInfo needMd5:YES withDictionary:dic success:^(NSDictionary * _Nullable dictionary) {
            
            BOOL success = [dictionary boolValueForKey:@"success"];
            if (success) {
                [weakSelf.view hideLoading];
    
                HXLivePlaybackInfoModel *playbackInfoModel =[HXLivePlaybackInfoModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
                if (playbackInfoModel.playMessage) {
                    [self.view showTostWithMessage:playbackInfoModel.playMessage];
                    return;
                }
                //进入回放直播间
                [weakSelf enterPlaybackRoomWithData:playbackInfoModel];
            }else{
                NSString *message = [dictionary stringValueForKey:@"message" WithHolder:@"获取数据失败,请重试!"];
                [weakSelf.view showErrorWithMessage:message];
            }
        } failure:^(NSError *error) {
            [weakSelf.view showErrorWithMessage:@"获取数据失败，请重试！"];
        }];
        
    }else{
        [self.view showTostWithMessage:@"未开播"];
    }
}


//进入直播间
- (void)enterRoomWithRoomID:(BJLRoomID *)roomID domain:(NSString *)domain
{
    if (domain.length) {
        [BJLRoom setPrivateDomainPrefix:domain];
    }
        
    BJLRoomViewController *roomViewController = [BJLRoomViewController instanceWithRoomType:BJLRoomVCTypeBigClass roomID:roomID];
    roomViewController.delegate = self;
    [self bjl_presentFullScreenViewController:roomViewController animated:YES completion:nil];
}

//进入回放直播间
- (void)enterPlaybackRoomWithData:(HXLivePlaybackInfoModel *)livePlaybackInfoModel{
    
   
    if (livePlaybackInfoModel.private_domain.length) {
        [[BJVAppConfig sharedInstance] setPrivateDomainPrefix:livePlaybackInfoModel.private_domain];
    }
   
    [BJVideoPlayerCore setTokenDelegate:self];
    
    BJPPlaybackOptions *playbackOptions = [[BJPPlaybackOptions alloc] init];
    playbackOptions.playerType = BJVPlayerType_IJKPlayer;
    playbackOptions.playTimeRecordEnabled = NO;
    playbackOptions.clipedVersion = -1;
    playbackOptions.userName = HXSafeString(livePlaybackInfoModel.user_name);
    playbackOptions.userNumber = HXSafeString(livePlaybackInfoModel.user_number);
    
    BJPRoomViewController *vc = [BJPRoomViewController onlinePlaybackRoomWithClassID:HXSafeString(livePlaybackInfoModel.classID)
                                                                           sessionID:HXSafeString(livePlaybackInfoModel.sessionID)
                                                                               token:HXSafeString(livePlaybackInfoModel.token)
                                                                           accessKey:nil
                                                                             options:playbackOptions];
    
//    [vc setCustomLamp:[PUPlayOptionsManager getLamp]];    //跑马灯
    [self bjl_presentFullScreenViewController:vc animated:YES completion:nil];
    
//    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(vc, roomDidExit) observer:^BOOL{
//        bjl_strongify(self);
        // 监听退出直播间, 注意使用weak, 避免循环引用
        NSLog(@"退出回放房间");
        return YES;
    }];
    
    bjl_weakify(vc);
    [vc setNoticeLinkCallback:^(NSURL * _Nullable linkURL) {
        bjl_strongify(vc);
        if (linkURL) {
            SFSafariViewController *sfVC = [[SFSafariViewController alloc] initWithURL:linkURL];
            [vc bjl_presentViewController:sfVC animated:YES completion:nil];
        }
    }];
}

#pragma mark - <BJLRoomVCDelegate>进入直播间事件回调

/** 进入直播间 - 成功 */
- (void)roomViewControllerEnterRoomSuccess:(BJLRoomViewController *)roomViewController {
    NSLog(@"进入直播间 - 成功");
}

/** 进入直播间 - 失败 */
- (void)roomViewController:(BJLRoomViewController *)roomViewController enterRoomFailureWithError:(BJLError *)error {
    NSLog(@"进入直播间 - 失败 [%@]", error);
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"%@[%ld]",error.localizedDescription,error.code] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:confirmAction];
    [self.presentedViewController?self.presentedViewController:self presentViewController:alertC animated:YES completion:nil];
}

/**
即将退出直播间 - 正常/异常
正常退出 `error` 为 `nil`，否则为异常退出
参考 `BJLErrorCode` */
- (void)roomViewController:(BJLRoomViewController *)roomViewController willExitWithError:(nullable BJLError *)error {

}

/**
 退出直播间 - 正常/异常
 正常退出 `error` 为 `nil`，否则为异常退出
 参考 `BJLErrorCode` */
- (void)roomViewController:(BJLRoomViewController *)roomViewController didExitWithError:(nullable BJLError *)error {
    NSLog(@"退出直播间 [%@]",error);
    
//    if (error) {
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"%@[%ld]",error.localizedDescription,error.code] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        }];
//        [alertC addAction:confirmAction];
//        [self.presentedViewController?self.presentedViewController:self presentViewController:alertC animated:YES completion:nil];
//    }
}

#pragma mark - <BJVRequestTokenDelegate>

- (void)requestTokenWithClassID:(NSString *)classID
                      sessionID:(nullable NSString *)sessionID
                     completion:(void (^)(NSString * _Nullable token, NSError * _Nullable error))completion {
    completion(@"",nil);
}

#pragma mark - 获取每一门课的直播列表
-(void)getDirectBroadcastDetail{
    
    NSString *classID = [HXPublicParamTool sharedInstance].class_id;
    
    NSDictionary *dic =@{
        @"classid":HXSafeString(classID),
        @"dbtype":@(self.liveCourseModel.dbType),
        @"dbmanageid":HXSafeString(self.liveCourseModel.dbManageID),
        @"selecttype":@(0)//0全部直播 1往期直播
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetDirectBroadcastDetail needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXLiveDetailModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
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


#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return 182;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myLiveCellIdentifier = @"HXMyLiveCellIdentifier";
    HXMyLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:myLiveCellIdentifier];
    if (!cell) {
        cell = [[HXMyLiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myLiveCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.liveDetailModel = self.dataArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXLiveDetailViewController *vc = [[HXLiveDetailViewController alloc] init];
    HXLiveDetailModel *liveDetailModel = self.dataArray[indexPath.row];
    vc.liveDetailModel = liveDetailModel;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UI
-(void)createUI{
   
    [self.view addSubview:self.mainTableView];
   
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, 0);
    [self.mainTableView updateLayout];
    
    self.noDataTipView.tipTitle = @"暂无直播～";
    self.noDataTipView.frame = self.mainTableView.frame;
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getDirectBroadcastDetail)];
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

@end
