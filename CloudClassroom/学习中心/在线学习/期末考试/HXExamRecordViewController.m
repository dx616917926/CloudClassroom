//
//  HXExamRecordViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/12/7.
//

#import "HXExamRecordViewController.h"
#import "HXExamViewController.h"
#import "HXExamRecordCell.h"



@interface HXExamRecordViewController ()<UITableViewDelegate,UITableViewDataSource,HXExamRecordCellDelegate>

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) NSMutableArray *dataArray;

//当前继续作答的考试
@property(nonatomic,strong) HXExamRecordModel *currentExamRecordModel;
//试卷试题
@property(nonatomic,strong) HXExamPaperModel *examPaperModel;

@end

@implementation HXExamRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UI
    [self createUI];
    //获取考试记录
    [self getExamRecordList];
}

#pragma mark - Setter

-(void)setExamId:(NSString *)examId{
    _examId = examId;
}

-(void)setExamPara:(HXExamParaModel *)examPara{
    _examPara = examPara;
}

#pragma mark - 获取考试记录
-(void)getExamRecordList{
    
    NSString *url = [NSString stringWithFormat:HXEXAM_CheckRecord,self.examPara.domain,self.examId];
    
    HXExamParaModel *examPara = self.examPara;
    
    //获取当前时间戳
    NSString *d = [HXCommonUtil getNowTimeTimestamp];
    NSString *vr = HXSafeString(examPara.vr);
    NSString *vs = HXSafeString(examPara.vs);
    NSString *va = HXSafeString(examPara.vac);
    NSString *limitedTime = HXSafeString(examPara.limitedTime);
    NSString *allowCount = HXSafeString(examPara.allowCount);
    NSString *syncUrl = HXSafeString(examPara.syncURL);
    //用于加密的参数,生成m
    NSDictionary *md5Dic= @{
        @"vr":vr,
        @"vs":vs,
        @"va":va,
        @"limitedTime":limitedTime,
        @"allowCount":allowCount,
        @"d":d,
        @"syncUrl":syncUrl,
    };
    NSString *md5Str = [HXCommonUtil getMd5String:md5Dic pingKey:nil];
    //拼接请求地址
    NSString *pingDicUrl = [HXCommonUtil  stringEncoding:[NSString stringWithFormat:@"%@?vr=%@&vs=%@&va=%@&limitedTime=%@&allowCount=%@&d=%@&syncUrl=%@&m=%@",url,vr,vs,va,limitedTime,allowCount,d,syncUrl,md5Str]];
    
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    
    [self.view showLoading];
    
    [manager GET:pingDicUrl parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.mainTableView.mj_header endRefreshing];
        [self.view hideLoading];
        NSDictionary *dictionary = responseObject;
        NSArray *list = [HXExamRecordModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"records"]];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:list];
        [self.mainTableView reloadData];
        if(list.count==0){
            [self.view addSubview:self.noDataTipView];
        }else{
            [self.noDataTipView removeFromSuperview];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.mainTableView.mj_header endRefreshing];
        [self.view showErrorWithMessage:error.description.lowercaseString];
    }];
}

#pragma mark - 继续作答
-(void)continueExam:(HXExamRecordModel *)examRecordModel{
    NSString *url = [NSString stringWithFormat:@"%@/exam/student/exam/finished/json/%@",self.examPara.domain,examRecordModel.examId];
    
    [self.view showLoading];
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    [manager GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.view hideLoading];
        NSDictionary *dic = responseObject;
        self.currentExamRecordModel = examRecordModel;
//        [self getExamUrl: [dic stringValueForKey:@"resultUrl"]];
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.description.lowercaseString];
    }];
    
}

#pragma mark - 查看答卷
-(void)checkAnswer:(HXExamRecordModel *)examRecordModel{
    
    [self.view showLoading];
    [HXExamSessionManager getDataWithNSString:examRecordModel.viewUrl withDictionary:nil success:^(NSDictionary * _Nullable dictionary) {
        
        if ([dictionary boolValueForKey:@"success"]) {
            [self.view hideLoading];
            NSDictionary*userExam = [dictionary dictionaryValueForKey:@"userExam"];
            NSString *examUrl = [dictionary objectForKey:@"url"];
            
            NSString *userExamId = [userExam stringValueForKey:@"id"];
            //获取考试的HTMLStr参数
            [self getEaxmHTMLStr:examUrl userExamId:userExamId];
        }else{
            [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
        }
    } failure:^(NSError * _Nullable error) {
        [self.view showErrorWithMessage:@"获取数据失败,请重试!"];
    }];
}






#pragma mark - 1.获取考试的HTMLStr参数
-(void)getEaxmHTMLStr:(NSString *)examUrl userExamId:(NSString *)userExamId{
    
    [self.view showLoading];
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    //返回的数据不是json
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:examUrl parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.view hideLoading];
        NSString *htmlStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",htmlStr);
        [self getEaxmJsonWithExamUrl:examUrl htmlStr:htmlStr userExamId:userExamId];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.description.lowercaseString];
    }];
}

#pragma mark - 2.用html作为参数去获取试卷json数据
-(void)getEaxmJsonWithExamUrl:(NSString *)examUrl htmlStr:(NSString *)htmlStr userExamId:(NSString *)userExamId{
    
    NSArray *tempA = [examUrl componentsSeparatedByString:@"/resource/"];
    NSString *t = tempA.lastObject;
    NSArray *tempB = [t componentsSeparatedByString:@"/"];
    NSDictionary *dic = @{@"paperHtml":htmlStr};
    NSString *url = [NSString stringWithFormat:@"%@/exam/student/exam/resource/htmlToJson/%@/%@/%@",self.examPara.domain,tempB[0],tempB[1],tempB[2]];
    
    [self.view showLoading];
  
    [HXExamSessionManager postDataWithNSString:url needMd5:NO pingKey:nil withDictionary:dic success:^(NSDictionary * _Nullable dictionary) {
        [self.view hideLoading];
        NSLog(@"%@",dictionary);
        if (dictionary) {
            HXExamPaperModel *examPaperModel = [HXExamPaperModel mj_objectWithKeyValues:dictionary];
            examPaperModel.domain = self.examPara.domain;
            examPaperModel.userExamId = self.currentExamRecordModel.examId;
            self.examPaperModel = examPaperModel;
            //获取考试答案
            [self getEaxmAnswersWithUserExamId:userExamId];
            
        }
    } failure:^(NSError * _Nullable error) {
        [self.view showErrorWithMessage:error.description.lowercaseString];
    }];
    
}

#pragma mark - 3.获取考试答案
-(void)getEaxmAnswersWithUserExamId:(NSString *)userExamId{
    
    NSString *url = [NSString stringWithFormat:@"%@/exam/student/exam/myanswer/list/%@",self.examPara.domain,userExamId];
    
    [self.view showLoading];
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];

    [manager GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.view hideLoading];
        NSLog(@"%@",responseObject);
        NSDictionary *dic = responseObject;
        NSArray *list = [HXExamAnswerModel mj_objectArrayWithKeyValuesArray:[dic objectForKey:@"answers"]];
        self.examPaperModel.isContinuerExam = NO;
        self.examPaperModel.answers = list;
        //获取试卷解析
        [self getEaxmJieXiWithUserExamId:userExamId];
       
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.description.lowercaseString];
    }];
}

#pragma mark - 4.获取试卷解析
-(void)getEaxmJieXiWithUserExamId:(NSString *)userExamId{
    
    NSString *url = [NSString stringWithFormat:@"%@/exam/student/exam/answer/%@",self.examPara.domain,userExamId];
    
    [self.view showLoading];
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];

    [manager GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.view hideLoading];
        NSLog(@"%@",responseObject);
        NSDictionary *dic = responseObject;
        NSArray *list = [HXExamAnswerHintModel mj_objectArrayWithKeyValuesArray:[dic objectForKey:@"answers"]];
        self.examPaperModel.isContinuerExam = NO;
        self.examPaperModel.jieXis = list;
        HXExamViewController *examVC = [[HXExamViewController alloc] init];
        examVC.sc_navigationBarHidden = YES;//隐藏导航栏
        examVC.examPaperModel = self.examPaperModel;
        [self.navigationController pushViewController:examVC animated:YES];
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.description.lowercaseString];
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
    
    return 118;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *examRecordCellIdentifier = @"HXExamRecordCellIdentifier";
    HXExamRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:examRecordCellIdentifier];
    if (!cell) {
        cell = [[HXExamRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:examRecordCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    HXExamRecordModel *examRecordModel = self.dataArray[indexPath.row];
    examRecordModel.index = self.dataArray.count-indexPath.row;
    cell.examRecordModel = examRecordModel;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.title = @"考试记录";
    
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.sd_layout
        .topSpaceToView(self.view, kNavigationBarHeight)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .bottomEqualToView(self.view);
    
    self.noDataTipView.tipTitle = @"暂无考试记录";
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getExamRecordList)];
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
