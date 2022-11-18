//
//  HXPingShiZuoYeViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXPingShiZuoYeViewController.h"
#import "HXExamViewController.h"
#import "HXPingShiZuoYeCell.h"
#import "HXFaceConfigObject.h"
#import "HXKeJianOrExamInfoModel.h"

@interface HXPingShiZuoYeViewController ()<UITableViewDelegate,UITableViewDataSource,HXPingShiZuoYeCellDelegate>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) HXKeJianOrExamInfoModel *keJianOrExamInfoModel;

@property(nonatomic,strong) HXFaceConfigObject *faceConfigObject;

@end

@implementation HXPingShiZuoYeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    //获取人脸识别设置
    [self getFaceSet];
    //获取正考考试列表和看课列表/获取补考考试列表
    (self.isBuKao?[self getBKExamList]: [self getExamList]);
   
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
        @"coursetype":(self.isBuKao?@"0":@"2")

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
        @"moduletype":@"1",//课件kj：0    作业zy：1  期末qm：2  答疑dn：3
        @"revision":@"1" //pc:0  app:1  h5:2
    };
    
    [self.view showLoading];
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetExamList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXKeJianOrExamInfoModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            self.keJianOrExamInfoModel = list.firstObject;
            if (![HXCommonUtil isNull:self.keJianOrExamInfoModel .examPara.examURL]) {
                [self requestAuthorize:self.keJianOrExamInfoModel .examPara];
            }else{
                [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view hideLoading];
        [self.mainTableView.mj_header endRefreshing];
    }];
}

#pragma mark - 获取补考考试列表
-(void)getBKExamList{

    NSDictionary *dic =@{
        @"bkcourse_id":HXSafeString(self.buKaoModel.bkCourse_id),
        @"moduletype":@"1",//课件kj：0    作业zy：1  期末qm：2  答疑dn：3
    };
    
    [self.view showLoading];
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetBKExamList needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        [self.mainTableView.mj_header endRefreshing];
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXKeJianOrExamInfoModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            self.keJianOrExamInfoModel = list.firstObject;
            if (![HXCommonUtil isNull: self.keJianOrExamInfoModel.examPara.examURL]) {
                [self requestAuthorize: self.keJianOrExamInfoModel.examPara];
            }else{
                [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view hideLoading];
        [self.mainTableView.mj_header endRefreshing];
    }];
}

#pragma mark - 请求授权
-(void)requestAuthorize:(HXExamParaModel *)examPara{
    
    [self.view showLoading];
    
    [HXExamSessionManager getDataWithNSString:examPara.examURL withDictionary:nil success:^(NSDictionary * _Nullable dictionary) {
        //
        [self.view hideLoading];
        if ([dictionary boolValueForKey:@"success"]) {
            [self requestExamModulesListData:examPara];
        }else{
            [self.view showErrorWithMessage:[dictionary stringValueForKey:@"errMsg"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //返回
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } failure:^(NSError * _Nullable error) {
        [self.view hideLoading];
        [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
    }];
}

//获取考试列表
-(void)requestExamModulesListData:(HXExamParaModel *)examPara{
    
    [self.view showLoading];
    
    NSString * url = [NSString stringWithFormat:@"%@"HXEXAM_MODULES_LIST,examPara.domain,examPara.moduleCode];
    NSLog(@"\n______________________获取考试列表URL:______________________\n%@\n",url);
    [HXExamSessionManager getDataWithNSString:url withDictionary:nil success:^(NSDictionary * _Nullable dictionary) {
        
        if ([dictionary boolValueForKey:@"success"]) {
            [self.view hideLoading];
            NSArray *list = [HXExamModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"exams"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            [self.mainTableView reloadData];
            if(list.count==0){
                [self.view addSubview:self.noDataTipView];
            }else{
                [self.noDataTipView removeFromSuperview];
            }
        }else{
            [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
        }
    } failure:^(NSError * _Nullable error) {
        [self.view hideLoading];
        [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
    }];
}

#pragma mark - 获取考试的链接
-(void)getExamUrl:(NSString *)examStartPath{
    
    [self.view showLoading];
    [HXExamSessionManager getDataWithNSString:examStartPath withDictionary:nil success:^(NSDictionary * _Nullable dictionary) {
        
        if ([dictionary boolValueForKey:@"success"]) {
            [self.view hideLoading];
            NSString *examUrl = [dictionary objectForKey:@"url"];
            [self getEaxmHTMLStr:examUrl];
        }else{
            [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
        }
    } failure:^(NSError * _Nullable error) {
        [self.view hideLoading];
        [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
    }];
}

#pragma mark - 获取考试的HTMLStr参数
-(void)getEaxmHTMLStr:(NSString *)examUrl{
    
    [self.view showLoading];
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:examUrl parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.view hideLoading];
        NSString *htmlStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",htmlStr);
        [self getEaxmJsonWithExamUrl:examUrl htmlStr:htmlStr];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view hideLoading];
        [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
    }];
}


-(void)getEaxmJsonWithExamUrl:(NSString *)examUrl htmlStr:(NSString *)htmlStr {
    
    NSArray *tempA = [examUrl componentsSeparatedByString:@"/resource/"];
    NSString *t = tempA.lastObject;
    NSArray *tempB = [t componentsSeparatedByString:@"/"];
//    NSString *url = @"https://eplatform.edu-edu.com.cn/exam/student/exam/resource/htmlToJson/paper/19745/88111";
    NSDictionary *dic = @{@"paperHtml":htmlStr};
    NSString *url = [NSString stringWithFormat:@"%@/exam/student/exam/resource/htmlToJson/%@/%@/%@",self.keJianOrExamInfoModel.examPara.domain,tempB[0],tempB[1],tempB[2]];
    
    [self.view showLoading];
    
    [HXExamSessionManager postDataWithNSString:url needMd5:NO withDictionary:dic success:^(NSDictionary * _Nullable dictionary) {
        [self.view hideLoading];
        NSLog(@"%@",dictionary);
        if (dictionary) {
            HXExamPaperModel *examPaperModel = [HXExamPaperModel mj_objectWithKeyValues:dictionary];
            HXExamViewController *examVC = [[HXExamViewController alloc] init];
            examVC.sc_navigationBarHidden = YES;//隐藏导航栏
            examVC.examPaperModel = examPaperModel;
            [self.navigationController pushViewController:examVC animated:YES];
            
        }
    } failure:^(NSError * _Nullable error) {
        [self.view hideLoading];
        [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
    }];
    
    
}







#pragma mark - <HXPingShiZuoYeCellDelegate>开始作业
-(void)startExam:(HXExamModel *)examModel{
    //开始考试  用于考试数据的初始化，得到考试试卷和考试服务器的url
    [self.view showLoading];
    NSString * url = [NSString stringWithFormat:@"%@"HXEXAM_START_JSON,self.keJianOrExamInfoModel.examPara.domain,examModel.examId];
    
    [HXExamSessionManager getDataWithNSString:url withDictionary:nil success:^(NSDictionary * _Nullable dictionary) {
        
        if ([dictionary boolValueForKey:@"success"]) {
            [self.view hideLoading];
            NSString *examStartPath = [dictionary objectForKey:@"url"];
            //获取考试的链接
            [self getExamUrl:examStartPath];
        }else{
            [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
        }
    } failure:^(NSError * _Nullable error) {
        [self.view hideLoading];
        [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
    }];
    
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
    static NSString *pingShiZuoYeCellIdentifier = @"HXPingShiZuoYeCellIdentifier";
    HXPingShiZuoYeCell *cell = [tableView dequeueReusableCellWithIdentifier:pingShiZuoYeCellIdentifier];
    if (!cell) {
        cell = [[HXPingShiZuoYeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pingShiZuoYeCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    HXExamModel *examModel = self.dataArray[indexPath.row];
    examModel.showMessage = self.keJianOrExamInfoModel.showMessage;
    cell.examModel = examModel;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"平时作业";
   
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

