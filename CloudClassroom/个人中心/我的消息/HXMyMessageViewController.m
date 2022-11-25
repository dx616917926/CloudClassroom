//
//  HXMyMessageViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/9.
//

#import "HXMyMessageViewController.h"
#import "HXMessageDetailInfoViewController.h"
#import "HXMyMessageCell.h"

@interface HXMyMessageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIButton *yiJianYiDuBtn;
@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,assign) NSInteger pageIndex;

@property(nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HXMyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    //获取我的消息
    [self getMessageInfo];
}

#pragma mark - 获取我的消息
-(void)getMessageInfo{
    
    self.pageIndex = 1;
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    
    NSDictionary *dic =@{
        @"pageindex":@(self.pageIndex),
        @"pagesize":@(15),
        @"studentid":HXSafeString(studentId),
        @"type":@(1)//类型: 1学生，2老师，3管理员

    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetMessageInfo needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSDictionary *dic= [dictionary dictionaryValueForKey:@"data"];
        if (success) {
            NSArray *list = [HXMyMessageInfoModel mj_objectArrayWithKeyValuesArray:dic[@"items"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            if (list.count == 15) {
                self.mainTableView.mj_footer.hidden = NO;
            }else{
                self.mainTableView.mj_footer.hidden = YES;
            }
            [self.mainTableView reloadData];
            //查出是否有未读
            __block BOOL weiDu = NO;
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXMyMessageInfoModel *model = obj;
                if (model.statusID==0) {
                    weiDu = YES;
                    *stop = YES;
                    return;
                }
            }];
            self.yiJianYiDuBtn.selected = !weiDu;
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}

-(void)loadMoreData{
    
    self.pageIndex++;
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    
    NSDictionary *dic =@{
        @"pageindex":@(self.pageIndex),
        @"pagesize":@(15),
        @"studentid":HXSafeString(studentId),
        @"type":@(1)//类型: 1学生，2老师，3管理员

    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetMessageInfo needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_footer endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        NSDictionary *dic= [dictionary dictionaryValueForKey:@"data"];
        if (success) {
            NSArray *list = [HXMyMessageInfoModel mj_objectArrayWithKeyValuesArray:dic[@"items"]];
            if (list.count == 15) {
                self.mainTableView.mj_footer.hidden = NO;
            }else{
                self.mainTableView.mj_footer.hidden = YES;
            }
            [self.dataArray addObjectsFromArray:list];
            [self.mainTableView reloadData];
            //查出是否有未读
            __block BOOL weiDu = NO;
            [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXMyMessageInfoModel *model = obj;
                if (model.statusID==0) {
                    weiDu = YES;
                    *stop = YES;
                    return;
                }
            }];
            self.yiJianYiDuBtn.selected = !weiDu;
        }else{
            self.pageIndex--;
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_footer endRefreshing];
        self.pageIndex--;
    }];
}

#pragma mark - 消息一键已读
-(void)upDateMessageStatusByStudentId{
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId),
        @"type":@(1)//类型: 1学生，2老师，3管理员

    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_UpdateMessageStatusByStudentId needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
    
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.yiJianYiDuBtn.selected = YES;
            //重新获取消息
            [self getMessageInfo];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - Event
-(void)yiJianYiDu:(UIButton *)sender{
    if (sender.isSelected) {
        return;
    }
    [self upDateMessageStatusByStudentId];
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"我的消息";
    
    [self.view addSubview:self.yiJianYiDuBtn];
    [self.view addSubview:self.mainTableView];
    
    self.yiJianYiDuBtn.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .rightEqualToView(self.view)
    .widthIs(200)
    .heightIs(36);
    
    self.yiJianYiDuBtn.titleLabel.sd_layout
    .centerYEqualToView(self.yiJianYiDuBtn)
    .rightSpaceToView(self.yiJianYiDuBtn, 12)
    .heightIs(17);
    
    self.yiJianYiDuBtn.imageView.sd_layout
    .centerYEqualToView(self.yiJianYiDuBtn)
    .rightSpaceToView(self.yiJianYiDuBtn.titleLabel, 3)
    .widthIs(12)
    .heightEqualToWidth();
    
    [self.yiJianYiDuBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.yiJianYiDuBtn, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    self.noDataTipView.tipTitle = @"暂无消息～";
    self.noDataTipView.type = NoType3;
   
    
    // 下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getMessageInfo)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.mainTableView.mj_footer = footer;
    self.mainTableView.mj_footer.hidden = YES;
    
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myMessageCellIdentifier = @"HXMyMessageCellIdentifier";
    HXMyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:myMessageCellIdentifier];
    if (!cell) {
        cell = [[HXMyMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myMessageCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.myMessageInfoModel = self.dataArray[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXMessageDetailInfoViewController *vc =[[HXMessageDetailInfoViewController alloc] init];
    vc.myMessageInfoModel = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -LazyLoad
-(NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIButton *)yiJianYiDuBtn{
    if (!_yiJianYiDuBtn) {
        _yiJianYiDuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _yiJianYiDuBtn.titleLabel.font = HXFont(12);
        _yiJianYiDuBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_yiJianYiDuBtn setTitleColor:COLOR_WITH_ALPHA(0x3F4A61, 1) forState:UIControlStateNormal];
        [_yiJianYiDuBtn setTitleColor:COLOR_WITH_ALPHA(0xB2B8C3, 1) forState:UIControlStateSelected];
        [_yiJianYiDuBtn setTitle:@"一键已读" forState:UIControlStateNormal];
        [_yiJianYiDuBtn setImage:[UIImage imageNamed:@"noyidu_icon"] forState:UIControlStateNormal];
        [_yiJianYiDuBtn setImage:[UIImage imageNamed:@"yidu_icon"] forState:UIControlStateSelected];
        [_yiJianYiDuBtn addTarget:self action:@selector(yiJianYiDu:) forControlEvents:UIControlEventTouchUpInside];
        _yiJianYiDuBtn.selected = YES;
    }
    return _yiJianYiDuBtn;
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
        
    }
    return _mainTableView;
}

@end

