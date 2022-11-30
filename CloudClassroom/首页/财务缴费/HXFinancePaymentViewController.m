//
//  HXFinancePaymentViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import "HXFinancePaymentViewController.h"
#import "HXJieSuanViewController.h"
#import "HXFinancePaymentCell.h"
#import "HXShowMoneyDetailsrView.h"


@interface HXFinancePaymentViewController ()<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIButton *allSelectBtn;
@property(nonatomic,strong) UIButton *jieSuanBtn;
@property(nonatomic,strong) UIControl *checkDetailsControl;
@property(nonatomic,strong) UIButton *checkDetailsBtn;
@property(nonatomic,strong) UILabel *selectNumLabel;
@property(nonatomic,strong) UILabel *heJiLabel;
@property(nonatomic,strong) UILabel *totalPriceLabel;

@property(nonatomic,strong) HXShowMoneyDetailsrView *showMoneyDetailsrView;

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
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}

#pragma mark - 查看明细

-(void)checkDetails:(UIControl *)sender{
    
    __block NSMutableArray *array = [NSMutableArray array];
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXStudentFeeModel *model = obj;
        if (model.isSeleted) {
            [array addObject:model];
        }
    }];
    
    if (array.count==0) {
        [self.view showTostWithMessage:@"请选择缴费项目"];
        return;
    }
    self.showMoneyDetailsrView.fromFalg = 2;
    self.showMoneyDetailsrView.isHaveXueQi = YES;
    self.showMoneyDetailsrView.dataArray = array;
    WeakSelf(weakSelf);
    self.showMoneyDetailsrView.callBack = ^{
        weakSelf.checkDetailsBtn.selected = weakSelf.showMoneyDetailsrView.isShow;
    };
    
    if (!self.showMoneyDetailsrView.isShow) {
        [self.showMoneyDetailsrView show];
    }else{
        [self.showMoneyDetailsrView dismiss];
    }
        
}

#pragma mark - 结算
-(void)jieSuan:(UIControl *)sender{
    
    if (self.showMoneyDetailsrView.isShow) {
        [self.showMoneyDetailsrView dismiss];
    }
    
    __block NSMutableArray *array = [NSMutableArray array];
    __block NSMutableArray *batchIDsArray = [NSMutableArray array];
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXStudentFeeModel *model = obj;
        if (model.isSeleted) {
            [array addObject:model];
            [batchIDsArray addObject:model.batchID];
        }
    }];
    
    if (array.count==0) {
        [self.view showTostWithMessage:@"请选择缴费项目"];
        return;
    }
    
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSString *batchIDs = [batchIDsArray componentsJoinedByString:@","];
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId),
        @"batchid":HXSafeString(batchIDs)
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
#pragma mark - 全选
-(void)allSelect:(UIControl *)sender{
    sender.selected = !sender.selected;

    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXStudentFeeModel *model = obj;
        model.isSeleted = sender.selected;
    }];
    [self.mainTableView reloadData];
    //计算合计
    [self calculateTotalPrice];

    if (self.showMoneyDetailsrView.isShow) {
        [self.showMoneyDetailsrView dismiss];
    }
}

#pragma mark - 计算合计
-(void)calculateTotalPrice{
    __block CGFloat total = 0.00;
    __block NSInteger count = 0;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXStudentFeeModel *model = obj;
        if (model.isSeleted) {
            total+=model.balance;
            count++;
        }
    }];
    
    NSString *content = [NSString stringWithFormat:@"￥%.2f",total];
    NSArray *tempArray = [HXFloatToString(total) componentsSeparatedByString:@"."];
    NSString *needStr = [tempArray.firstObject stringByAppendingString:@"."];
    self.totalPriceLabel.attributedText = [HXCommonUtil getAttributedStringWith:needStr needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:content defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    
    self.selectNumLabel.text = [NSString stringWithFormat:@"已选%ld个",(long)count];
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
    return 124;
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
    HXStudentFeeModel *model = self.dataArray[indexPath.row];
    model.isSeleted = !model.isSeleted;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //计算合计
    [self calculateTotalPrice];
    
}

#pragma mark - UI
-(void)createUI{
    
    self.sc_navigationBar.title = @"财务缴费";
    
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.allSelectBtn];
    [self.bottomView addSubview:self.jieSuanBtn];
    [self.bottomView addSubview:self.checkDetailsControl];
    [self.bottomView addSubview:self.checkDetailsBtn];
    [self.bottomView addSubview:self.totalPriceLabel];
    [self.bottomView addSubview:self.heJiLabel];
    [self.bottomView addSubview:self.selectNumLabel];
    
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
    
    self.allSelectBtn.sd_layout
    .centerYEqualToView(self.jieSuanBtn)
    .leftEqualToView(self.bottomView)
    .widthIs(100)
    .heightIs(40);
    
    self.allSelectBtn.imageView.sd_layout
    .centerYEqualToView(self.allSelectBtn)
    .leftSpaceToView(self.allSelectBtn, 28)
    .widthIs(22)
    .heightEqualToWidth();
    
    self.allSelectBtn.titleLabel.sd_layout
    .centerYEqualToView(self.allSelectBtn)
    .leftSpaceToView(self.allSelectBtn.imageView, 8)
    .rightSpaceToView(self.allSelectBtn, 8)
    .heightIs(20);
    
    self.checkDetailsBtn.sd_layout
    .bottomEqualToView(self.jieSuanBtn)
    .rightSpaceToView(self.jieSuanBtn, 16)
    .widthIs(100)
    .heightIs(20);
    
    self.checkDetailsBtn.imageView.sd_layout
    .centerYEqualToView(self.checkDetailsBtn)
    .rightEqualToView(self.checkDetailsBtn)
    .widthIs(10)
    .heightIs(6);
    
    self.checkDetailsBtn.titleLabel.sd_layout
    .centerYEqualToView(self.checkDetailsBtn)
    .rightSpaceToView(self.checkDetailsBtn.imageView, 4)
    .leftSpaceToView(self.checkDetailsBtn, 4)
    .heightIs(16);
    
    
    self.totalPriceLabel.sd_layout
    .rightEqualToView(self.checkDetailsBtn)
    .bottomSpaceToView(self.checkDetailsBtn, 0)
    .heightIs(20);
    
    [self.totalPriceLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    self.heJiLabel.sd_layout
    .centerYEqualToView(self.totalPriceLabel)
    .rightSpaceToView(self.totalPriceLabel, 0)
    .widthIs(30)
    .heightIs(17);
    
    self.checkDetailsControl.sd_layout
    .topEqualToView(self.totalPriceLabel)
    .bottomEqualToView(self.checkDetailsBtn)
    .rightEqualToView(self.checkDetailsBtn)
    .leftEqualToView(self.checkDetailsBtn);
    
    self.selectNumLabel.sd_layout
    .centerYEqualToView(self.totalPriceLabel)
    .rightSpaceToView(self.heJiLabel, 4)
    .leftSpaceToView(self.allSelectBtn, 10)
    .heightIs(17);
   
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.bottomView, 0);
    
    
    self.noDataTipView.tipTitle = @"暂无缴费内容～";
    
    
    
    // 刷新
//    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
//    header.automaticallyChangeAlpha = YES;
//    self.mainTableView.mj_header = header;
//    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
//    self.mainTableView.mj_footer = footer;
//    self.mainTableView.mj_footer.hidden = YES;
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

- (UIButton *)allSelectBtn{
    if (!_allSelectBtn) {
        _allSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allSelectBtn.titleLabel.font = HXFont(14);
        _allSelectBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_allSelectBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_allSelectBtn setImage:[UIImage imageNamed:@"noselect_icon"] forState:UIControlStateNormal];
        [_allSelectBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        [_allSelectBtn addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allSelectBtn;
}

-(UIControl *)checkDetailsControl{
    if (!_checkDetailsControl) {
        _checkDetailsControl = [[UIControl alloc] init];
        [_checkDetailsControl addTarget:self action:@selector(checkDetails:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkDetailsControl;
}

- (UIButton *)checkDetailsBtn{
    if (!_checkDetailsBtn) {
        _checkDetailsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkDetailsBtn.titleLabel.font = HXFont(12);
        _checkDetailsBtn.userInteractionEnabled = NO;
        _checkDetailsBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_checkDetailsBtn setTitleColor:COLOR_WITH_ALPHA(0xED4F4F, 1) forState:UIControlStateNormal];
        [_checkDetailsBtn setTitle:@"查看明细" forState:UIControlStateNormal];
        [_checkDetailsBtn setImage:[UIImage imageNamed:@"reduparrow_icon"] forState:UIControlStateNormal];
        [_checkDetailsBtn setImage:[UIImage imageNamed:@"reddownarrow_icon"] forState:UIControlStateSelected];
    }
    return _checkDetailsBtn;
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
        _totalPriceLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"0." needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:@"￥0.00" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    }
    return _totalPriceLabel;
}


- (UILabel *)selectNumLabel{
    if (!_selectNumLabel) {
        _selectNumLabel = [[UILabel alloc] init];
        _selectNumLabel.textAlignment = NSTextAlignmentRight;
        _selectNumLabel.font = HXFont(12);
        _selectNumLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
    }
    return _selectNumLabel;
}

-(HXShowMoneyDetailsrView *)showMoneyDetailsrView{
    if (!_showMoneyDetailsrView) {
        _showMoneyDetailsrView = [[HXShowMoneyDetailsrView alloc] init];
        _showMoneyDetailsrView.isHaveXueQi = YES;
    }
    return _showMoneyDetailsrView;
}

@end

