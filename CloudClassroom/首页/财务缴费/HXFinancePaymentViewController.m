//
//  HXFinancePaymentViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import "HXFinancePaymentViewController.h"
#import "HXJieSuanViewController.h"
#import "HXFinancePaymentCell.h"



@interface HXFinancePaymentViewController ()<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) UIView *bottomView;

@property(nonatomic,strong) UIButton *jieSuanBtn;
@property(nonatomic,strong) UILabel *heJiLabel;
@property(nonatomic,strong) UILabel *totalPriceLabel;


@property(nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HXFinancePaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取财务缴费列表
    [self getFeeList];
    //监听支付成功通知，重新获取数据
    [HXNotificationCenter addObserver:self selector:@selector(paySuccess) name:kPaySuccessNotification object:nil];
}


#pragma mark -监听支付成功通知，重新获取数据
-(void)paySuccess{
    //延迟获取，不然出现接口失败
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getFeeList];
    });
}


#pragma mark - 获取财务缴费列表
-(void)getFeeList{
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetFeeList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXStudentFeeModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            [self.mainTableView reloadData];
            if (list.count==0) {
                [self.view addSubview:self.noDataTipView];
            }else{
                [self.noDataTipView removeFromSuperview];
            }
            
            //合计
            if (list.count>0) {
                HXStudentFeeModel *model = list.firstObject;
                NSString *content = [NSString stringWithFormat:@"￥%.2f",model.totalBalance];
                NSArray *tempArray = [HXFloatToString(model.totalBalance) componentsSeparatedByString:@"."];
                NSString *needStr = [tempArray.firstObject stringByAppendingString:@"."];
                self.totalPriceLabel.attributedText = [HXCommonUtil getAttributedStringWith:needStr needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:16]} content:content defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}


#pragma mark - 结算
-(void)jieSuan:(UIControl *)sender{
    
    HXStudentFeeModel *model = self.dataArray.firstObject;
    
    if (self.dataArray.count==0) {
        [self.view showTostWithMessage:@"无缴费项目"];
        return;
    }
    
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
   
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId),
        @"batchid":HXSafeString(model.batchID)
    };
    [self.view showLoading];
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_FeeOrderAdd needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        [self.view hideLoading];
        if (success) {
            HXCourseJieSuanModel *jieSuanModel = [HXCourseJieSuanModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            jieSuanModel.fromFalg = 2;
            HXJieSuanViewController *vc = [[HXJieSuanViewController alloc] init];
            vc.isHaveXueQi = YES;
            vc.jieSuanModel = jieSuanModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view hideLoading];
    }];
    
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
    return 94;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *financePaymentCellIdentifier = @"HXFinancePaymentCellIdentifier";
    HXFinancePaymentCell *cell = [tableView dequeueReusableCellWithIdentifier:financePaymentCellIdentifier];
    if (!cell) {
        cell = [[HXFinancePaymentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:financePaymentCellIdentifier];
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
    
    self.sc_navigationBar.title = @"在线缴费";
    
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.bottomView];
    
   
    [self.bottomView addSubview:self.jieSuanBtn];
    [self.bottomView addSubview:self.totalPriceLabel];
    [self.bottomView addSubview:self.heJiLabel];
   
    
    self.bottomView.sd_layout
    .bottomEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(80);
    
    self.jieSuanBtn.sd_layout
    .centerYEqualToView(self.bottomView).offset(-10)
    .rightSpaceToView(self.bottomView, 16)
    .widthIs(100)
    .heightIs(40);
    self.jieSuanBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.heJiLabel.sd_layout
    .centerYEqualToView(self.jieSuanBtn)
    .leftSpaceToView(self.bottomView, 12)
    .widthIs(30)
    .heightIs(17);
    
    self.totalPriceLabel.sd_layout
    .centerYEqualToView(self.heJiLabel)
    .leftSpaceToView(self.heJiLabel, 2)
    .heightIs(22);
    
    [self.totalPriceLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.bottomView, 0);
    
    self.noDataTipView.tipTitle = @"暂无缴费内容～";
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getFeeList)];
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

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _bottomView;
}



- (UIButton *)jieSuanBtn{
    if (!_jieSuanBtn) {
        _jieSuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _jieSuanBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _jieSuanBtn.titleLabel.font = HXBoldFont(15);
        [_jieSuanBtn setTitleColor:COLOR_WITH_ALPHA(0xFFFFFF, 1) forState:UIControlStateNormal];
        [_jieSuanBtn setTitle:@"结算" forState:UIControlStateNormal];
        [_jieSuanBtn addTarget:self action:@selector(jieSuan:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _jieSuanBtn;
}

- (UILabel *)heJiLabel{
    if (!_heJiLabel) {
        _heJiLabel = [[UILabel alloc] init];
        _heJiLabel.textAlignment = NSTextAlignmentRight;
        _heJiLabel.font = HXFont(12);
        _heJiLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _heJiLabel.text = @"合计:";
    }
    return _heJiLabel;
}

- (UILabel *)totalPriceLabel{
    if (!_totalPriceLabel) {
        _totalPriceLabel = [[UILabel alloc] init];
        _totalPriceLabel.font = HXBoldFont(14);
        _totalPriceLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _totalPriceLabel.textAlignment = NSTextAlignmentRight;
        _totalPriceLabel.isAttributedContent = YES;
        _totalPriceLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"0." needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:16]} content:@"￥0.00" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
    }
    return _totalPriceLabel;
}






@end

