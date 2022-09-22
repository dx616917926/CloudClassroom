//
//  HXMyMessageViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/9.
//

#import "HXMyMessageViewController.h"
#import "HXMyMessageCell.h"

@interface HXMyMessageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIButton *yiJianYiDuBtn;
@property(nonatomic,strong) UITableView *mainTableView;

@end

@implementation HXMyMessageViewController

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
-(void)yiJianYiDu:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
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
   
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
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
    return 5;
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
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -LazyLoad
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

