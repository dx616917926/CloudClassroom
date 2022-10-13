//
//  HXQIMoKaoShiViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXQIMoKaoShiViewController.h"
#import "HXQiMoKaoShiCell.h"

@interface HXQIMoKaoShiViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) HXKeJianOrExamInfoModel *keJianOrExamInfoModel;

@property(nonatomic,strong) NSMutableArray *dataArray;


@end

@implementation HXQIMoKaoShiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取正考考试列表和看课列表/获取补考考试列表
    (self.isBuKao?[self getBKExamList]: [self getExamList]);
}

#pragma mark -Setter
-(void)setCourseInfoModel:(HXCourseInfoModel *)courseInfoModel{
    _courseInfoModel = courseInfoModel;
}

#pragma mark - 获取正考考试列表和看课列表
-(void)getExamList{

    NSDictionary *dic =@{
        @"termcourse_id":HXSafeString(self.courseInfoModel.termCourseID),
        @"student_id":HXSafeString(self.courseInfoModel.student_id),
        @"moduletype":@"2",//课件kj：0    作业zy：1  期末qm：2  答疑dn：3
        @"revision":@"1" //pc:0  app:1  h5:2
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetExamList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXKeJianOrExamInfoModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            self.keJianOrExamInfoModel = list.firstObject;
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:self.keJianOrExamInfoModel.examPara];
            [self.mainTableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}

#pragma mark - 获取补考考试列表
-(void)getBKExamList{

    NSDictionary *dic =@{
        @"bkcourse_id":HXSafeString(self.buKaoModel.bkCourse_id),
        @"moduletype":@"2",//课件kj：0    作业zy：1  期末qm：2  答疑dn：3
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetBKExamList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.keJianOrExamInfoModel = [HXKeJianOrExamInfoModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:self.keJianOrExamInfoModel.examPara];
            [self.mainTableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
    }];
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"期末考试";
   
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:(self.isBuKao?@selector(getBKExamList):@selector(getExamList))];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
   
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return 217;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *qiMoKaoShiCellIdentifier = @"HXQiMoKaoShiCellIdentifier";
    HXQiMoKaoShiCell *cell = [tableView dequeueReusableCellWithIdentifier:qiMoKaoShiCellIdentifier];
    if (!cell) {
        cell = [[HXQiMoKaoShiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:qiMoKaoShiCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HXExamParaModel *examParaModel = self.dataArray[indexPath.row];
    examParaModel.showMessage = self.keJianOrExamInfoModel.showMessage;
    cell.examParaModel = examParaModel;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        _mainTableView.tableHeaderView =tableHeaderView;
       
    }
    return _mainTableView;
}

@end


