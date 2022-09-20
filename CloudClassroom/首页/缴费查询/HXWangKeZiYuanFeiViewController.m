//
//  HXWangKeZiYuanFeiViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/19.
//

#import "HXWangKeZiYuanFeiViewController.h"
#import "HXWangKeZiYuanFeiCell.h"

@interface HXWangKeZiYuanFeiViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) UIView *containerView;
//总计缴费
@property(nonatomic,strong) UIView *totalPaymentView;
@property(nonatomic,strong) UILabel *totalPaymentTitleLabel;
@property(nonatomic,strong) UILabel *totalPaymentMoneyLabel;
//购买课程
@property(nonatomic,strong) UIView *buyCourseView;
@property(nonatomic,strong) UILabel *buyCourseTitleLabel;
@property(nonatomic,strong) UILabel *buyCourseMoneyLabel;


@end

@implementation HXWangKeZiYuanFeiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}



-(void)loadData{
    [self.mainTableView.mj_header endRefreshing];
}

-(void)loadMoreData{
    [self.mainTableView.mj_footer endRefreshing];
}


#pragma mark - Event


#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 214;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *wangKeZiYuanFeiCellIdentifier = @"HXWangKeZiYuanFeiCellIdentifier";
    HXWangKeZiYuanFeiCell *cell = [tableView dequeueReusableCellWithIdentifier:wangKeZiYuanFeiCellIdentifier];
    if (!cell) {
        cell = [[HXWangKeZiYuanFeiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wangKeZiYuanFeiCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.mainTableView.mj_footer = footer;
    self.mainTableView.mj_footer.hidden = YES;
}

#pragma mark -LazyLoad
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
        [self.containerView addSubview:self.totalPaymentView];
        [self.totalPaymentView addSubview:self.totalPaymentTitleLabel];
        [self.totalPaymentView addSubview:self.totalPaymentMoneyLabel];
        [self.containerView addSubview:self.buyCourseView];
        [self.buyCourseView addSubview:self.buyCourseTitleLabel];
        [self.buyCourseView addSubview:self.buyCourseMoneyLabel];
       
        
        self.containerView.sd_layout
        .bottomSpaceToView(_tableHeaderView, 6)
        .leftSpaceToView(_tableHeaderView, 12)
        .rightSpaceToView(_tableHeaderView, 12)
        .heightIs(70);
        self.containerView.sd_cornerRadius=@8;
        
        self.totalPaymentView.sd_layout
        .centerYEqualToView(self.containerView)
        .leftEqualToView(self.containerView)
        .heightRatioToView(self.containerView, 1)
        .widthRatioToView(self.containerView, 0.5);
        
        self.totalPaymentTitleLabel.sd_layout
        .topSpaceToView(self.totalPaymentView, 16)
        .leftEqualToView(self.totalPaymentView)
        .rightEqualToView(self.totalPaymentView)
        .heightIs(17);
        
        self.totalPaymentMoneyLabel.sd_layout
        .bottomSpaceToView(self.totalPaymentView, 13)
        .leftEqualToView(self.totalPaymentView)
        .rightEqualToView(self.totalPaymentView)
        .heightIs(20);
        
        self.buyCourseView.sd_layout
        .centerYEqualToView(self.containerView)
        .rightEqualToView(self.containerView)
        .heightRatioToView(self.containerView, 1)
        .widthRatioToView(self.containerView, 0.5);
        
        self.buyCourseTitleLabel.sd_layout
        .topSpaceToView(self.buyCourseView, 16)
        .leftEqualToView(self.buyCourseView)
        .rightEqualToView(self.buyCourseView)
        .heightRatioToView(self.totalPaymentTitleLabel, 1);
        
        self.buyCourseMoneyLabel.sd_layout
        .bottomSpaceToView(self.buyCourseView, 13)
        .leftEqualToView(self.buyCourseView)
        .rightEqualToView(self.buyCourseView)
        .heightRatioToView(self.totalPaymentMoneyLabel, 1);
        
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

-(UIView *)totalPaymentView{
    if (!_totalPaymentView) {
        _totalPaymentView = [[UIView alloc] init];
        _totalPaymentView.backgroundColor = UIColor.whiteColor;
    }
    return _totalPaymentView;
}

- (UILabel *)totalPaymentTitleLabel{
    if (!_totalPaymentTitleLabel) {
        _totalPaymentTitleLabel = [[UILabel alloc] init];
        _totalPaymentTitleLabel.textAlignment = NSTextAlignmentCenter;
        _totalPaymentTitleLabel.font = HXFont(12);
        _totalPaymentTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _totalPaymentTitleLabel.text = @"总计缴费";
    }
    return _totalPaymentTitleLabel;
}

- (UILabel *)totalPaymentMoneyLabel{
    if (!_totalPaymentMoneyLabel) {
        _totalPaymentMoneyLabel = [[UILabel alloc] init];
        _totalPaymentMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _totalPaymentMoneyLabel.font = HXBoldFont(14);
        _totalPaymentMoneyLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _totalPaymentMoneyLabel.text = @"5000";
    }
    return _totalPaymentMoneyLabel;
}

-(UIView *)buyCourseView{
    if (!_buyCourseView) {
        _buyCourseView = [[UIView alloc] init];
        _buyCourseView.backgroundColor = UIColor.whiteColor;
    }
    return _buyCourseView;
}

- (UILabel *)buyCourseTitleLabel{
    if (!_buyCourseTitleLabel) {
        _buyCourseTitleLabel = [[UILabel alloc] init];
        _buyCourseTitleLabel.textAlignment = NSTextAlignmentCenter;
        _buyCourseTitleLabel.font = HXFont(12);
        _buyCourseTitleLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _buyCourseTitleLabel.text = @"购买课程";
    }
    return _buyCourseTitleLabel;
}

- (UILabel *)buyCourseMoneyLabel{
    if (!_buyCourseMoneyLabel) {
        _buyCourseMoneyLabel = [[UILabel alloc] init];
        _buyCourseMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _buyCourseMoneyLabel.font = HXBoldFont(14);
        _buyCourseMoneyLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _buyCourseMoneyLabel.text = @"2000";
    }
    return _buyCourseMoneyLabel;
}



@end


