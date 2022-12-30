//
//  HXXueFeiViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/19.
//

#import "HXXueFeiViewController.h"
#import "HXXueFeiCell.h"

@interface HXXueFeiViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) UIView *containerView;
//应缴费(元)
@property(nonatomic,strong) UIView *yingJiaoView;
@property(nonatomic,strong) UILabel *yingJiaoTitleLabel;
@property(nonatomic,strong) UILabel *yingJiaoMoneyLabel;
//已缴(元)
@property(nonatomic,strong) UIView *yiJiaoView;
@property(nonatomic,strong) UILabel *yiJiaoTitleLabel;
@property(nonatomic,strong) UILabel *yiJiaoMoneyLabel;
//欠缴(元)
@property(nonatomic,strong) UIView *qianJiaoView;
@property(nonatomic,strong) UILabel *qianJiaoTitleLabel;
@property(nonatomic,strong) UILabel *qianJiaoMoneyLabel;

@property(nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HXXueFeiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    //获取财务已缴费列表
    [self getCourseFeeHaveList];
}



#pragma mark - 获取财务已缴费列表
-(void)getCourseFeeHaveList{
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetCourseFeeHaveList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXStudentFeeModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            
            if (list.count==0) {
                [self.mainTableView addSubview:self.noDataTipView];
            }else{
                [self.noDataTipView removeFromSuperview];
            }
            
            HXStudentFeeModel *model = list.firstObject;
            
            self.yingJiaoMoneyLabel.text = [NSString stringWithFormat:@"%.2f",model.totalPayable];
            self.yiJiaoMoneyLabel.text = [NSString stringWithFormat:@"%.2f",model.totalPaidIn];
            self.qianJiaoMoneyLabel.text = [NSString stringWithFormat:@"%.2f",model.totalBalance];
            
            [self.mainTableView reloadData];
            
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
    return 324;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *xueFeiCellIdentifier = @"HXXueFeiCellIdentifier";
    HXXueFeiCell *cell = [tableView dequeueReusableCellWithIdentifier:xueFeiCellIdentifier];
    if (!cell) {
        cell = [[HXXueFeiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:xueFeiCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.studentFeeModel = self.dataArray[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    
    self.noDataTipView.tipTitle = @"暂无缴费信息～";
    self.noDataTipView.frame = self.mainTableView.frame;
   
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getCourseFeeHaveList)];
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
        _mainTableView.tableHeaderView =self.tableHeaderView;
       
    }
    return _mainTableView;
}


-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 92)];
        
        [_tableHeaderView addSubview:self.containerView];
        [self.containerView addSubview:self.yingJiaoView];
        [self.yingJiaoView addSubview:self.yingJiaoTitleLabel];
        [self.yingJiaoView addSubview:self.yingJiaoMoneyLabel];
        [self.containerView addSubview:self.yiJiaoView];
        [self.yiJiaoView addSubview:self.yiJiaoTitleLabel];
        [self.yiJiaoView addSubview:self.yiJiaoMoneyLabel];
        [self.containerView addSubview:self.qianJiaoView];
        [self.qianJiaoView addSubview:self.qianJiaoTitleLabel];
        [self.qianJiaoView addSubview:self.qianJiaoMoneyLabel];
        
        self.containerView.sd_layout
        .bottomSpaceToView(_tableHeaderView, 6)
        .leftSpaceToView(_tableHeaderView, 12)
        .rightSpaceToView(_tableHeaderView, 12)
        .heightIs(70);
        self.containerView.sd_cornerRadius=@8;
        
        self.yiJiaoView.sd_layout
        .centerYEqualToView(self.containerView)
        .centerXEqualToView(self.containerView)
        .heightRatioToView(self.containerView, 1)
        .widthRatioToView(self.containerView, 0.33);
        
        self.yiJiaoTitleLabel.sd_layout
        .topSpaceToView(self.yiJiaoView, 16)
        .leftEqualToView(self.yiJiaoView)
        .rightEqualToView(self.yiJiaoView)
        .heightIs(17);
        
        self.yiJiaoMoneyLabel.sd_layout
        .bottomSpaceToView(self.yiJiaoView, 13)
        .leftEqualToView(self.yiJiaoView)
        .rightEqualToView(self.yiJiaoView)
        .heightIs(20);
        
        self.yingJiaoView.sd_layout
        .centerYEqualToView(self.containerView)
        .leftEqualToView(self.containerView)
        .rightSpaceToView(self.yiJiaoView, 0)
        .heightRatioToView(self.containerView, 1);
        
        self.yingJiaoTitleLabel.sd_layout
        .topSpaceToView(self.yingJiaoView, 16)
        .leftEqualToView(self.yingJiaoView)
        .rightEqualToView(self.yingJiaoView)
        .heightRatioToView(self.yiJiaoTitleLabel, 1);
        
        self.yingJiaoMoneyLabel.sd_layout
        .bottomSpaceToView(self.yingJiaoView, 13)
        .leftEqualToView(self.yingJiaoView)
        .rightEqualToView(self.yingJiaoView)
        .heightRatioToView(self.yiJiaoMoneyLabel, 1);
        
        self.qianJiaoView.sd_layout
        .centerYEqualToView(self.containerView)
        .rightEqualToView(self.containerView)
        .leftSpaceToView(self.yiJiaoView, 0)
        .heightRatioToView(self.containerView, 1);
        
        self.qianJiaoTitleLabel.sd_layout
        .topSpaceToView(self.qianJiaoView, 16)
        .leftEqualToView(self.qianJiaoView)
        .rightEqualToView(self.qianJiaoView)
        .heightRatioToView(self.yiJiaoTitleLabel, 1);
        
        self.qianJiaoMoneyLabel.sd_layout
        .bottomSpaceToView(self.qianJiaoView, 13)
        .leftEqualToView(self.qianJiaoView)
        .rightEqualToView(self.qianJiaoView)
        .heightRatioToView(self.yiJiaoMoneyLabel, 1);
        
        
        
        
    }
    return _tableHeaderView;
}


-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = UIColor.whiteColor;
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

-(UIView *)yingJiaoView{
    if (!_yingJiaoView) {
        _yingJiaoView = [[UIView alloc] init];
        _yingJiaoView.backgroundColor = UIColor.whiteColor;
    }
    return _yingJiaoView;
}

- (UILabel *)yingJiaoTitleLabel{
    if (!_yingJiaoTitleLabel) {
        _yingJiaoTitleLabel = [[UILabel alloc] init];
        _yingJiaoTitleLabel.textAlignment = NSTextAlignmentCenter;
        _yingJiaoTitleLabel.font = HXFont(12);
        _yingJiaoTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _yingJiaoTitleLabel.text = @"应缴费(元)";
    }
    return _yingJiaoTitleLabel;
}

- (UILabel *)yingJiaoMoneyLabel{
    if (!_yingJiaoMoneyLabel) {
        _yingJiaoMoneyLabel = [[UILabel alloc] init];
        _yingJiaoMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _yingJiaoMoneyLabel.font = HXBoldFont(14);
        _yingJiaoMoneyLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
    }
    return _yingJiaoMoneyLabel;
}

-(UIView *)yiJiaoView{
    if (!_yiJiaoView) {
        _yiJiaoView = [[UIView alloc] init];
        _yiJiaoView.backgroundColor = UIColor.whiteColor;
    }
    return _yiJiaoView;
}

- (UILabel *)yiJiaoTitleLabel{
    if (!_yiJiaoTitleLabel) {
        _yiJiaoTitleLabel = [[UILabel alloc] init];
        _yiJiaoTitleLabel.textAlignment = NSTextAlignmentCenter;
        _yiJiaoTitleLabel.font = HXFont(12);
        _yiJiaoTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _yiJiaoTitleLabel.text = @"已缴(元)";
    }
    return _yiJiaoTitleLabel;
}

- (UILabel *)yiJiaoMoneyLabel{
    if (!_yiJiaoMoneyLabel) {
        _yiJiaoMoneyLabel = [[UILabel alloc] init];
        _yiJiaoMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _yiJiaoMoneyLabel.font = HXBoldFont(14);
        _yiJiaoMoneyLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
    }
    return _yiJiaoMoneyLabel;
}

-(UIView *)qianJiaoView{
    if (!_qianJiaoView) {
        _qianJiaoView = [[UIView alloc] init];
        _qianJiaoView.backgroundColor = UIColor.whiteColor;
    }
    return _qianJiaoView;
}

- (UILabel *)qianJiaoTitleLabel{
    if (!_qianJiaoTitleLabel) {
        _qianJiaoTitleLabel = [[UILabel alloc] init];
        _qianJiaoTitleLabel.textAlignment = NSTextAlignmentCenter;
        _qianJiaoTitleLabel.font = HXFont(12);
        _qianJiaoTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _qianJiaoTitleLabel.text = @"欠缴(元)";
    }
    return _qianJiaoTitleLabel;
}

- (UILabel *)qianJiaoMoneyLabel{
    if (!_qianJiaoMoneyLabel) {
        _qianJiaoMoneyLabel = [[UILabel alloc] init];
        _qianJiaoMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _qianJiaoMoneyLabel.font = HXBoldFont(14);
        _qianJiaoMoneyLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        
    }
    return _qianJiaoMoneyLabel;
}

@end

