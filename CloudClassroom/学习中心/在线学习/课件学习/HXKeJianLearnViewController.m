//
//  HXKeJianLearnViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXKeJianLearnViewController.h"
#import "HXMoocViewController.h"//慕课课件
#import "HXKeJianLearnCell.h"
#import "HXFaceConfigObject.h"
#import <TXMoviePlayer/TXMoviePlayerController.h>
#import "HXFaceRecognitionTool.h"

@interface HXKeJianLearnViewController ()<UITableViewDelegate,UITableViewDataSource,HXKeJianLearnCellDelegate>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) HXFaceConfigObject *faceConfigObject;

@end

@implementation HXKeJianLearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取人脸识别设置
    [self getFaceSet];
    //获取正考考试列表和看课列表
    [self getExamList];
    
}

#pragma mark -Setter
-(void)setCourseInfoModel:(HXCourseInfoModel *)courseInfoModel{
    _courseInfoModel = courseInfoModel;
}



#pragma mark - 获取人脸识别设置
-(void)getFaceSet{

    NSString *majorid = [HXPublicParamTool sharedInstance].major_id;
    NSDictionary *dic =@{
        @"majorid":HXSafeString(majorid),
        //班级计划学期ID（如果是补考，传补考开课ID）
        @"termcourseid":HXSafeString(self.courseInfoModel.termCourseID),
        //模块类型 1课件 2作业 3期末 0补考
        @"coursetype":@"1"

    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetFaceSet needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.faceConfigObject = [HXFaceConfigObject mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 获取正考考试列表和看课列表
-(void)getExamList{

    NSDictionary *dic =@{
        @"termcourse_id":HXSafeString(self.courseInfoModel.termCourseID),
        @"student_id":HXSafeString(self.courseInfoModel.student_id),
        @"moduletype":@"0",//课件kj：0    作业zy：1  期末qm：2  答疑dn：3
        @"revision":@"1" //pc:0  app:1  h5:2
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetExamList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXKeJianOrExamInfoModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
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


#pragma mark - 播放课件
-(void)beginCourse:(HXKeJianOrExamInfoModel *)keJianOrExamInfoModel{

    NSDictionary *dic =@{
        @"coursecode":HXSafeString(keJianOrExamInfoModel.examCode),
        @"looktype":@"1",//观看方式（PC = 0, APP = 1,H5 = 2）
        @"coursename":HXSafeString(keJianOrExamInfoModel.termCourseName),
        @"stemcode":HXSafeString(keJianOrExamInfoModel.stemCode)
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_BeginCourse needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.noDataTipView removeFromSuperview];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            //判断是否需要人脸识别和采集
            HXFaceRecognitionTool *tool = [[HXFaceRecognitionTool alloc] init];
            self.faceConfigObject.termCourseID = keJianOrExamInfoModel.termCourse_id;
            tool.faceConfig = self.faceConfigObject;
            tool.successBlack = ^{
                if([keJianOrExamInfoModel.stemCode containsString:@"HXDD"]){
                    TXMoviePlayerController *playerVC = [[TXMoviePlayerController alloc] init];
                    playerVC.barStyle = UIStatusBarStyleLightContent;
                    playerVC.cws_param = [dictionary dictionaryValueForKey:@"data"];
                    playerVC.showLearnFinishStyle = YES;
                    playerVC.ignoreLearnRecordErrorAlert = YES;
                    [self.navigationController pushViewController:playerVC animated:YES];
                }else{
                    HXMoocViewController *moocVC = [[HXMoocViewController alloc] init];
                    moocVC.titleName = keJianOrExamInfoModel.termCourseName;
                    moocVC.moocUrl = [dictionary stringValueForKey:@"data"];
                    [self.navigationController pushViewController:moocVC animated:YES];
                }
            };
            [tool showInViewController:self];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = self.courseInfoModel.kjButtonName;
   
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getExamList)];
    header.automaticallyChangeAlpha = YES;
    self.mainTableView.mj_header = header;
    
    
}

#pragma mark - <HXKeJianLearnCellDelegate>
-(void)playCourse:(HXKeJianOrExamInfoModel *)model{
   
    
    [self beginCourse:model];
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
    return 254;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *keJianLearnCellIdentifier = @"HXKeJianLearnCellIdentifier";
    HXKeJianLearnCell *cell = [tableView dequeueReusableCellWithIdentifier:keJianLearnCellIdentifier];
    if (!cell) {
        cell = [[HXKeJianLearnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:keJianLearnCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.keJianOrExamInfoModel = self.dataArray[indexPath.row];
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
