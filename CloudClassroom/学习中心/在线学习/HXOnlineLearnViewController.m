//
//  HXOnlineLearnViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXOnlineLearnViewController.h"
#import "HXCurrentLearCell.h"
#import "HXOnlineLearnShowTipView.h"

@interface HXOnlineLearnViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView *topView;
@property(nonatomic,strong) UIButton *ganTanBtn;
@property(nonatomic,strong) UIButton *currentXueQiBtn;
@property(nonatomic,strong) UIButton *allXueQiBtn;
@property(nonatomic,strong) UIButton *selectXueQiBtn;

@property(nonatomic,strong) UITableView *mainTableView;


@end

@implementation HXOnlineLearnViewController

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
-(void)selectXueQi:(UIButton *)sender{
    if (sender==self.selectXueQiBtn) {
        return;
    }
    self.selectXueQiBtn.backgroundColor = UIColor.whiteColor;
    self.selectXueQiBtn.titleLabel.font = HXFont(15);
    [self.selectXueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x999999, 1) forState:UIControlStateNormal];
    
    sender.backgroundColor = COLOR_WITH_ALPHA(0xDDE4FF, 1);
    sender.titleLabel.font = HXBoldFont(15);
    [sender setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
    self.selectXueQiBtn = sender;
    
}


-(void)showTip:(UIButton *)sender{
    HXOnlineLearnShowTipView *onlineLearnShowTipView =[[HXOnlineLearnShowTipView alloc] init];
    [onlineLearnShowTipView show];
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
    return 242;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *currentLearCellIdentifier = @"HXCurrentLearCellIdentifier";
    HXCurrentLearCell *cell = [tableView dequeueReusableCellWithIdentifier:currentLearCellIdentifier];
    if (!cell) {
        cell = [[HXCurrentLearCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currentLearCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UI
-(void)createUI{
    [self.view addSubview:self.topView];
    [self.view addSubview:self.mainTableView];
    [self.topView addSubview:self.ganTanBtn];
    [self.topView addSubview:self.currentXueQiBtn];
    [self.topView addSubview:self.allXueQiBtn];
    
    self.selectXueQiBtn = self.currentXueQiBtn;
    
    self.topView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(58);
    
    self.ganTanBtn.sd_layout
    .centerYEqualToView(self.topView)
    .rightEqualToView(self.topView)
    .widthIs(50)
    .heightRatioToView(self.topView, 1);
    
    self.currentXueQiBtn.sd_layout
    .centerYEqualToView(self.topView)
    .leftSpaceToView(self.topView, 12)
    .widthIs(_kpw(147))
    .heightIs(34);
    self.currentXueQiBtn.sd_cornerRadius =@5;
    
    self.allXueQiBtn.sd_layout
    .centerYEqualToView(self.topView)
    .leftSpaceToView(self.currentXueQiBtn, _kpw(18))
    .widthRatioToView(self.currentXueQiBtn, 1)
    .heightRatioToView(self.currentXueQiBtn, 1);
    self.allXueQiBtn.sd_cornerRadius =@5;
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.topView, 0)
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

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = VCBackgroundColor;
    }
    return _topView;
}

- (UIButton *)currentXueQiBtn{
    if (!_currentXueQiBtn) {
        _currentXueQiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _currentXueQiBtn.backgroundColor = COLOR_WITH_ALPHA(0xDDE4FF, 1);
        _currentXueQiBtn.titleLabel.font = HXBoldFont(15);
        [_currentXueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_currentXueQiBtn setTitle:@"当前学期" forState:UIControlStateNormal];
        [_currentXueQiBtn addTarget:self action:@selector(selectXueQi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _currentXueQiBtn;
}

- (UIButton *)allXueQiBtn{
    if (!_allXueQiBtn) {
        _allXueQiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allXueQiBtn.backgroundColor = UIColor.whiteColor;
        _allXueQiBtn.titleLabel.font = HXFont(15);
        [_allXueQiBtn setTitleColor:COLOR_WITH_ALPHA(0x999999, 1) forState:UIControlStateNormal];
        [_allXueQiBtn setTitle:@"所有学期" forState:UIControlStateNormal];
        [_allXueQiBtn addTarget:self action:@selector(selectXueQi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allXueQiBtn;
}

- (UIButton *)ganTanBtn{
    if (!_ganTanBtn) {
        _ganTanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ganTanBtn setImage:[UIImage imageNamed:@"gantan_icon"] forState:UIControlStateNormal];
        [_ganTanBtn addTarget:self action:@selector(showTip:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ganTanBtn;
}


-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.bounces = YES;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
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
        _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _mainTableView.scrollIndicatorInsets = _mainTableView.contentInset;
        _mainTableView.showsVerticalScrollIndicator = NO;
       
    }
    return _mainTableView;
}



@end
