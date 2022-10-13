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

@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) NSMutableArray *bukaoArray;

@end

@implementation HXZaiXianBuKaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //在线补考成绩查询
    [self getBKScore];
}



#pragma mark - 在线补考成绩查询
-(void)getBKScore{

    NSString *studentid = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentid)
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetBKScore needMd5:YES withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXScoreBatchModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            [self.mainCollectionView reloadData];
            if(list.count==0){
                [self.view addSubview:self.noDataTipView];
            }else{
                [self.noDataTipView removeFromSuperview];
            }
            HXScoreBatchModel *scoreBatchModel = self.dataArray.firstObject;
            scoreBatchModel.isSelected = YES;
            [self.bukaoArray removeAllObjects];
            [self.bukaoArray addObjectsFromArray:scoreBatchModel.bkInfo];
            [self.mainTableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}


#pragma mark - Event


#pragma mark - <UICollectionViewDataSource,UICollectionViewDelegate>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HXZaiXianXueQiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HXZaiXianXueQiCell class]) forIndexPath:indexPath];
    cell.scoreBatchModel = self.dataArray[indexPath.row];
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXScoreBatchModel *model = obj;
        model.isSelected = NO;
        if(indexPath.row==idx){
            model.isSelected = YES;
            [self.bukaoArray removeAllObjects];
            [self.bukaoArray addObjectsFromArray:model.bkInfo];
        }
    }];
    [self.mainCollectionView reloadData];
    [self.mainTableView reloadData];
}



#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bukaoArray.count;
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
    cell.isLast = (indexPath.row==self.bukaoArray.count-1);
    cell.scoreModel = self.bukaoArray[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getBKScore)];
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

-(NSMutableArray *)bukaoArray{
    if(!_bukaoArray){
        _bukaoArray = [NSMutableArray array];
    }
    return _bukaoArray;
}

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
