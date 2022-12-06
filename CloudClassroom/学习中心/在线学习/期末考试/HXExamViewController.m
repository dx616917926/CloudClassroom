//
//  HXExamController.m
//  CloudClassroom
//
//  Created by mac on 2022/11/16.
//

#import "HXExamViewController.h"
#import "HXAnswerSheetViewController.h"
#import "HXExamChoiceCell.h"//选择题
#import "HXExamAnswerCell.h"//问答题
#import "HXExamFuHeCell.h"//复合题
#import "HXFloatButtonView.h"
#import "HXExamErrorReportView.h"
#import "IQKeyboardManager.h"

@interface HXExamViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HXFloatButtonViewDelegate>

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *jiaoJuanBtn;
@property(nonatomic,strong) UIButton *answerSheetBtn;

@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIButton *upBtn;
@property(nonatomic,strong) UIButton *downBtn;


@property(nonatomic,strong) UICollectionView *mainCollectionView;

//错误反馈按钮
@property(nonatomic, strong) HXFloatButtonView *errorReportButton;

@property(nonatomic,strong) NSMutableArray *dataArray;

///当前的位置
@property (nonatomic, strong) NSIndexPath *indexPathNow;

///复合题中小题的位置（从0 开始）
@property (nonatomic,assign) BOOL shouldScroll;;
@property (nonatomic,assign) NSInteger fuhe_position;


@end

@implementation HXExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UI
    [self createUI];
    
    [self.mainCollectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //禁用全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = NO;
    
    //    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    //    manager.enable = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //开启全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = YES;
    
    //    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    //    manager.enable = YES;
}

#pragma mark - Setter
-(void)setExamPaperModel:(HXExamPaperModel *)examPaperModel{
    _examPaperModel = examPaperModel;
    
    [self.dataArray removeAllObjects];
    //处理试卷数据
    [self.examPaperModel.questionGroups enumerateObjectsUsingBlock:^(HXExamQuestionTypeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        HXExamQuestionTypeModel *examQuestionTypeModel = obj;
        
        [examQuestionTypeModel.paperSuitQuestions enumerateObjectsUsingBlock:^(HXExamPaperSuitQuestionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HXExamPaperSuitQuestionModel *examPaperSuitQuestionModel = obj;
            examPaperSuitQuestionModel.pqt_title = examQuestionTypeModel.pqt_title;
            examPaperSuitQuestionModel.isDuoXuan = (examPaperSuitQuestionModel.subQuestions.count==0&&[examPaperSuitQuestionModel.pqt_title containsString:@"多选题"]);
            examPaperSuitQuestionModel.isWenDa = (examPaperSuitQuestionModel.subQuestions.count==0&&examPaperSuitQuestionModel.questionChoices.count==0);
            examPaperSuitQuestionModel.isFuHe = (examPaperSuitQuestionModel.subQuestions.count>0&&examPaperSuitQuestionModel.questionChoices.count==0);
            [self.dataArray addObject:obj];
        }];
        
    }];
}


#pragma mark - 提交试题答案
-(void)saveQuestion:(HXExamPaperSuitQuestionModel *)examPaperSuitQuestionModel{
    
    //问题id截掉"q_"
    NSString *psqId = HXSafeString([examPaperSuitQuestionModel.psq_id substringFromIndex:2]);
    
    NSString *url = [NSString stringWithFormat:@"%@/exam/student/exam/myanswer/newSave/%@/%@",self.examPaperModel.domain,self.examPaperModel.userExamId,psqId];
   
    NSString *keyStr =[NSString stringWithFormat:@"%@%@",psqId,self.examPaperModel.userExamId];
    
    
    NSString *answer = HXSafeString(examPaperSuitQuestionModel.answer);
    //获取当前时间戳
    NSString *stime = [HXCommonUtil getNowTimeTimestamp];
    //用于加密的参数,生成m
    NSDictionary *md5Dic= @{
        @"answer":answer,
        @"psqId":psqId,
        @"stime":stime,
    };

    NSString *md5Str = [HXCommonUtil getMd5String:md5Dic pingKey:[NSString stringWithFormat:@"key=%@",keyStr]];
    //拼接请求地址
    NSString *pingDicUrl = [NSString stringWithFormat:@"%@?answer=%@&psqId=%@&stime=%@&m=%@",url,answer,psqId,stime,md5Str];
    
    [self.view showLoading];
    
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//json请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//json返回
    
    
    
    [manager POST:pingDicUrl parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dictionary = responseObject;
        [self.view hideLoading];
        if ([dictionary boolValueForKey:@"success"]) {
            
        }else{
            [self.view showErrorWithMessage:[dictionary stringValueForKey:@"errMsg"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.description.lowercaseString];
    }];
}

#pragma mark - Event
//交卷
-(void)jiaoJuan:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
    
    
    NSString *url = [NSString stringWithFormat:@"%@/exam/student/exam/submit/%@",self.examPaperModel.domain,self.examPaperModel.userExamId];
   
    
    [self.view showLoading];
    
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//json请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//json返回
    
    [manager POST:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dictionary = responseObject;
        [self.view hideLoading];
        if ([dictionary boolValueForKey:@"success"]) {
            
        }else{
            [self.view showErrorWithMessage:[dictionary stringValueForKey:@"errMsg"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.description.lowercaseString];
    }];
    
}


//点击答题卡
-(void)clickAnswerSheet:(UIButton *)sender{
    HXAnswerSheetViewController *vc = [[HXAnswerSheetViewController alloc] init];
    vc.examPaperModel = self.examPaperModel;
    vc.isEnterExam = YES;
    vc.examVc = self;
    //点击答题卡题目回调
    WeakSelf(weakSelf);
    vc.answerSheetBlock = ^(NSInteger position, NSInteger fuhe_position, BOOL isFuhe) {
        StrongSelf(strongSelf);
        [strongSelf.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:position inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        CGPoint pInView = [self.view convertPoint:self.mainCollectionView.center toView:self.mainCollectionView];
        self.indexPathNow = [self.mainCollectionView indexPathForItemAtPoint:pInView];
        if (isFuhe) {
            //滑动复合题型子题到相应位置
            [self.mainCollectionView reloadItemsAtIndexPaths:@[self.indexPathNow]];
            HXExamFuHeCell *fuHeCell = (HXExamFuHeCell *)[self.mainCollectionView cellForItemAtIndexPath:self.indexPathNow];
            [fuHeCell scrollSubPosition:fuhe_position];
        }
    };
    [self presentViewController:vc animated:NO completion:nil];
}





- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGPoint pInView = [self.view convertPoint:self.mainCollectionView.center toView:self.mainCollectionView];
    self.indexPathNow = [self.mainCollectionView indexPathForItemAtPoint:pInView];
    if (self.indexPathNow.row == 0) {
        [self.view showTostWithMessage:@"已经是第一题了"];
    }
    
    if (self.indexPathNow.row == self.dataArray.count - 1) {
        [self.view showTostWithMessage:@"已经是最后一题了"];
    }
    
    HXExamPaperSuitQuestionModel *examPaperSuitQuestionModel = self.dataArray[self.indexPathNow.row-1];
    [self saveQuestion:examPaperSuitQuestionModel];
}
//上一题
- (void)upClick {
    
    if (self.indexPathNow.row > 0) {
        [self.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.indexPathNow.item - 1 inSection:self.indexPathNow.section] atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];
        self.indexPathNow = [NSIndexPath indexPathForItem:self.indexPathNow.item - 1 inSection:self.indexPathNow.section];
        [self.mainCollectionView reloadItemsAtIndexPaths:@[self.indexPathNow]];
        
    }else {
        [self.view showTostWithMessage:@"已经是第一题了"];
    }
    
}
//下一题
- (void)downClick {
    if (self.indexPathNow.row < self.dataArray.count - 1) {
        [self.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.indexPathNow.item + 1 inSection:self.indexPathNow.section] atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];
        self.indexPathNow = [NSIndexPath indexPathForItem:self.indexPathNow.item + 1 inSection:self.indexPathNow.section];
        [self.mainCollectionView reloadItemsAtIndexPaths:@[self.indexPathNow]];
    }else {
        [self.view showTostWithMessage:@"已经是最后一题了"];
    }
    
}

#pragma mark - <HXFloatButtonViewDelegate>点击错反馈按钮
- (void)didClickFloatButtonView:(HXFloatButtonView *)floatView
{
    if (floatView == self.errorReportButton) {
        
        //        if (self.curQuestion && self.examAdminPath) {
        //
        //            NSString *questionId = [NSString stringWithFormat:@"%d",self.curQuestion._id];
        //
        //            if ([self.curQuestion isComplex] && self.subPosition >= 0) {
        //                //
        //                HXQuestionInfo *sub = [self.curQuestion.subs objectAtIndex:self.subPosition];
        //                questionId = [NSString stringWithFormat:@"%d",sub._id];
        //            }
        //            //弹出错题反馈界面
        HXExamErrorReportView *reportView = [[HXExamErrorReportView alloc] init];
        [reportView showInViewController:self];
        //        }
    }
}

#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HXExamPaperSuitQuestionModel *examPaperSuitQuestionModel = self.dataArray [indexPath.row];
    if (examPaperSuitQuestionModel.isFuHe) {
        HXExamFuHeCell *fuHeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXExamFuHeCell" forIndexPath:indexPath];
        return fuHeCell;
    }else if (examPaperSuitQuestionModel.isWenDa) {
        HXExamAnswerCell *answerCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXExamAnswerCell" forIndexPath:indexPath];
        return answerCell;
    }else{
        HXExamChoiceCell *choiceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXExamChoiceCell" forIndexPath:indexPath];
        return choiceCell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    HXExamPaperSuitQuestionModel *examPaperSuitQuestionModel = self.dataArray [indexPath.row];
    if (examPaperSuitQuestionModel.isFuHe) {
        HXExamFuHeCell *fuHeCell = (HXExamFuHeCell *)cell;
        fuHeCell.examPaperSuitQuestionModel = examPaperSuitQuestionModel;
        
    }else if (examPaperSuitQuestionModel.isWenDa) {
        HXExamAnswerCell *answerCell = (HXExamAnswerCell *)cell;
        answerCell.examPaperSuitQuestionModel = examPaperSuitQuestionModel;
    }else{
        HXExamChoiceCell *choiceCell = (HXExamChoiceCell *)cell;
        choiceCell.examPaperSuitQuestionModel = examPaperSuitQuestionModel;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
    
}

#pragma mark - UI
-(void)createUI{
    
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.mainCollectionView];
    [self.view addSubview:self.bottomView];
    
    
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.jiaoJuanBtn];
    [self.navBarView addSubview:self.answerSheetBtn];
    
    [self.bottomView addSubview:self.upBtn];
    [self.bottomView addSubview:self.downBtn];
    
    
    
    
    self.navBarView.sd_layout
        .topEqualToView(self.view)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .heightIs(kNavigationBarHeight);
    
    self.bottomView.sd_layout
        .bottomSpaceToView(self.view, 0)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .heightIs(ExamBottomViewHeight);
    
    self.mainCollectionView.sd_layout
        .topSpaceToView(self.navBarView, 0)
        .bottomSpaceToView(self.bottomView, 0)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view);
    
    
    self.jiaoJuanBtn.sd_layout
        .centerYEqualToView(self.titleLabel)
        .leftSpaceToView(self.navBarView, 12)
        .widthIs(65)
        .heightIs(30);
    
    
    self.answerSheetBtn.sd_layout
        .centerYEqualToView(self.titleLabel)
        .rightEqualToView(self.navBarView)
        .widthIs(60)
        .heightIs(44);
    
    self.titleLabel.sd_layout
        .topSpaceToView(self.navBarView, kStatusBarHeight)
        .leftSpaceToView(self.jiaoJuanBtn,10)
        .rightSpaceToView(self.answerSheetBtn,10)
        .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.upBtn.sd_layout
        .centerYEqualToView(self.bottomView).offset(-(kScreenBottomMargin*0.5))
        .leftSpaceToView(self.bottomView, 20)
        .widthIs(130)
        .heightIs(40);
    self.upBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.upBtn.imageView.sd_layout
        .centerYEqualToView(self.upBtn)
        .leftSpaceToView(self.upBtn, 32)
        .widthIs(6)
        .heightIs(11);
    
    self.upBtn.titleLabel.sd_layout
        .centerYEqualToView(self.upBtn)
        .leftSpaceToView(self.self.upBtn.imageView, 6)
        .rightEqualToView(self.upBtn)
        .heightIs(20);
    
    
    self.downBtn.sd_layout
        .centerYEqualToView(self.upBtn)
        .rightSpaceToView(self.bottomView, 20)
        .widthRatioToView(self.upBtn, 1)
        .heightRatioToView(self.upBtn, 1);
    self.downBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.downBtn.imageView.sd_layout
        .centerYEqualToView(self.downBtn)
        .rightSpaceToView(self.downBtn, 32)
        .widthIs(6)
        .heightIs(11);
    
    self.downBtn.titleLabel.sd_layout
        .centerYEqualToView(self.downBtn)
        .rightSpaceToView(self.self.downBtn.imageView, 6)
        .leftEqualToView(self.downBtn)
        .heightIs(20);
    
    //创建错题反馈按钮
    [self createErrorReportButtonView];
    
    [self.view bringSubviewToFront:self.navBarView];
    [self.view bringSubviewToFront:self.bottomView];
}

// 创建错题反馈按钮
- (void)createErrorReportButtonView {
    if (!self.errorReportButton) {
        self.errorReportButton = [[HXFloatButtonView alloc] initWithFrame:CGRectMake(kScreenWidth - 70, kScreenHeight - ExamBottomViewHeight- 120, 60, 60)];
        self.errorReportButton.delegate = self;
        self.errorReportButton.contentImage = [UIImage imageNamed:@"exam_error_report_btn"];
        self.errorReportButton.marginBottom = ExamBottomViewHeight;
        [self.view addSubview:self.errorReportButton];
    }
}



#pragma mark - LazyLoad
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc] init];
        _navBarView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    }
    return _navBarView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _titleLabel.text = self.examPaperModel.paper_title;
    }
    return _titleLabel;
}

-(UIButton *)jiaoJuanBtn{
    if (!_jiaoJuanBtn) {
        _jiaoJuanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_jiaoJuanBtn setImage:[UIImage imageNamed:@"jiaojuan_icon"] forState:UIControlStateNormal];
        [_jiaoJuanBtn addTarget:self action:@selector(jiaoJuan:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _jiaoJuanBtn;
}

-(UIButton *)answerSheetBtn{
    if (!_answerSheetBtn) {
        _answerSheetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_answerSheetBtn setImage:[UIImage imageNamed:@"exam_menu"] forState:UIControlStateNormal];
        [_answerSheetBtn addTarget:self action:@selector(clickAnswerSheet:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerSheetBtn;
}

-(UICollectionView *)mainCollectionView{
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight- kNavigationBarHeight-ExamBottomViewHeight);
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.pagingEnabled = YES;
        _mainCollectionView.scrollEnabled = YES;
        [_mainCollectionView registerClass:[HXExamChoiceCell class] forCellWithReuseIdentifier:@"HXExamChoiceCell"];
        [_mainCollectionView registerClass:[HXExamAnswerCell class] forCellWithReuseIdentifier:@"HXExamAnswerCell"];
        [_mainCollectionView registerClass:[HXExamFuHeCell class] forCellWithReuseIdentifier:@"HXExamFuHeCell"];
    }
    return _mainCollectionView;
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = UIColor.whiteColor;
        _bottomView.layer.shadowColor = COLOR_WITH_ALPHA(0x000000, 0.19).CGColor;
        _bottomView.layer.shadowOffset = CGSizeMake(0,-2);
        _bottomView.layer.shadowOpacity = 1;
        _bottomView.layer.shadowRadius = 25;
    }
    return _bottomView;
}

-(UIButton *)upBtn{
    if (!_upBtn) {
        _upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _upBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _upBtn.titleLabel.font= HXBoldFont(14);
        _upBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_upBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_upBtn setTitle:@"上一题" forState:UIControlStateNormal];
        [_upBtn setImage:[UIImage imageNamed:@"up_icon"] forState:UIControlStateNormal];
        [_upBtn addTarget:self action:@selector(upClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _upBtn;
}

-(UIButton *)downBtn{
    if (!_downBtn) {
        _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _downBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _downBtn.titleLabel.font= HXBoldFont(14);
        _downBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_downBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_downBtn setTitle:@"下一题" forState:UIControlStateNormal];
        [_downBtn setImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateNormal];
        [_downBtn addTarget:self action:@selector(downClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downBtn;
}


@end
