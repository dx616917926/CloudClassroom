//
//  HXZongPingViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import "HXZongPingViewController.h"
#import "HXScoreDetailsViewController.h"
#import "HXZongPingCell.h"

@interface HXZongPingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HXZongPingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //成绩查询
    [self getScoreList];
}



#pragma mark - 总评成绩查询
-(void)getScoreList{

    NSString *studentid = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentid)
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetZKScore needMd5:YES withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXScoreModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            [self.mainTableView reloadData];
            if(list.count==0){
                [self.view addSubview:self.noDataTipView];
            }else{
                [self.noDataTipView removeFromSuperview];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}


#pragma mark - Event


#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *zongPingCellIdentifier = @"HXZongPingCellIdentifier";
    HXZongPingCell *cell = [tableView dequeueReusableCellWithIdentifier:zongPingCellIdentifier];
    if (!cell) {
        cell = [[HXZongPingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zongPingCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.isFirst = (indexPath.row==0);
    cell.isLast = (indexPath.row==self.dataArray.count-1);
    cell.scoreModel = self.dataArray[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HXScoreDetailsViewController *vc = [[HXScoreDetailsViewController alloc] init];
    vc.sc_navigationBarHidden = YES;
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
    
    self.noDataTipView.tipTitle = @"暂无考试成绩～";
    self.noDataTipView.frame = self.mainTableView.frame;
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getScoreList)];
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
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
        _mainTableView.tableHeaderView =tableHeaderView;
       
    }
    return _mainTableView;
}

@end
