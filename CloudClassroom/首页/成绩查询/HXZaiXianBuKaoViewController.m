//
//  HXZaiXianBuKaoViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import "HXZaiXianBuKaoViewController.h"
#import "HXScoreDetailsViewController.h"
#import "HXZaiXianXueQiCell.h"
#import "HXZaiXianCell.h"


@interface HXZaiXianBuKaoViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) UITableView *mainTableView;
@property(nonatomic,strong) UICollectionView *mainCollectionView;

@end

@implementation HXZaiXianBuKaoViewController

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


#pragma mark - <UICollectionViewDataSource,UICollectionViewDelegate>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 10;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HXZaiXianXueQiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HXZaiXianXueQiCell class]) forIndexPath:indexPath];
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
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
    return 50;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *zaiXianCellIdentifier = @"HXZaiXianCellIdentifier";
    HXZaiXianCell *cell = [tableView dequeueReusableCellWithIdentifier:zaiXianCellIdentifier];
    if (!cell) {
        cell = [[HXZaiXianCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zaiXianCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.isFirst = (indexPath.row==0);
    cell.isLast = (indexPath.row==4);
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
   
    [self.view addSubview:self.mainCollectionView];
    [self.view addSubview:self.mainTableView];
   
    self.mainCollectionView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(58);
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.mainCollectionView, 4)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, 0);
    [self.mainTableView updateLayout];
    
    self.noDataTipView.tipTitle = @"暂无考试成绩～";
    self.noDataTipView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.mainTableView.mj_footer = footer;
    self.mainTableView.mj_footer.hidden = YES;
}

#pragma mark -LazyLoad
-(UICollectionView *)mainCollectionView{
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 16;
        layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 0);
        float width = 85;
        layout.itemSize = CGSizeMake(width,34);
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = VCBackgroundColor;
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        if (@available(iOS 11.0, *)) {
            _mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _mainCollectionView.scrollIndicatorInsets = _mainCollectionView.contentInset;
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        ///注册cell
        [_mainCollectionView registerClass:[HXZaiXianXueQiCell class]
                 forCellWithReuseIdentifier:NSStringFromClass([HXZaiXianXueQiCell class])];
       
    }
    return _mainCollectionView;;
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
        
       
    }
    return _mainTableView;
}

@end
