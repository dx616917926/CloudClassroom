//
//  HXExamController.m
//  CloudClassroom
//
//  Created by mac on 2022/11/16.
//

#import "HXExamViewController.h"
#import "HXExamChoiceCell.h"//选择题
#import "HXExamAnswerCell.h"//问答题
#import "HXExamFuHeCell.h"//复合题
#import "IQKeyboardManager.h"

@interface HXExamViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *closeBtn;
@property(nonatomic,strong) UIButton *rightBtn;

@property(nonatomic,strong) UIButton *upBtn;
@property(nonatomic,strong) UIButton *downBtn;

@property(nonatomic,strong) UICollectionView *mainCollectionView;

@property(nonatomic,strong) NSMutableArray *dataArray;

///当前的位置
@property (nonatomic, strong) NSIndexPath *indexPathNow;

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
            examPaperSuitQuestionModel.isDuoXuan = (examPaperSuitQuestionModel.subQuestions.count==0&&examPaperSuitQuestionModel.questionChoices.count>4);
            examPaperSuitQuestionModel.isWenDa = (examPaperSuitQuestionModel.subQuestions.count==0&&examPaperSuitQuestionModel.questionChoices.count==0);
            examPaperSuitQuestionModel.isFuHe = (examPaperSuitQuestionModel.subQuestions.count>0&&examPaperSuitQuestionModel.questionChoices.count==0);
            [self.dataArray addObject:obj];
        }];
        
    }];
}

#pragma mark - Event
-(void)close{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self.view addSubview:self.upBtn];
    [self.view addSubview:self.downBtn];
    
    
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.closeBtn];
    [self.navBarView addSubview:self.rightBtn];
    
    
    
    
    self.navBarView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(kNavigationBarHeight);
    
    self.mainCollectionView.sd_layout
    .topSpaceToView(self.navBarView, 0)
    .bottomEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view);
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.navBarView, kStatusBarHeight)
    .centerXEqualToView(self.navBarView)
    .widthIs(kScreenWidth-140)
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.closeBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftEqualToView(self.navBarView)
    .widthIs(60)
    .heightIs(44);
    
    
    self.rightBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .rightEqualToView(self.navBarView)
    .widthIs(60)
    .heightIs(44);
    
    self.upBtn.sd_layout
    .centerYEqualToView(self.view)
    .leftSpaceToView(self.view, 0)
    .widthIs(42)
    .heightIs(60);
    
    self.downBtn.sd_layout
    .centerYEqualToView(self.upBtn)
    .rightSpaceToView(self.view, 0)
    .widthIs(42)
    .heightIs(60);
    
    
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

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"closewhite_icon"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"exam_menu"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

-(UICollectionView *)mainCollectionView{
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight- kNavigationBarHeight);
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


-(UIButton *)upBtn{
    if (!_upBtn) {
        _upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upBtn setImage:[UIImage imageNamed:@"exam_left_switch"] forState:UIControlStateNormal];
        [_upBtn addTarget:self action:@selector(upClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _upBtn;
}

-(UIButton *)downBtn{
    if (!_downBtn) {
        _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downBtn setImage:[UIImage imageNamed:@"exam_right_switch"] forState:UIControlStateNormal];
        [_downBtn addTarget:self action:@selector(downClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downBtn;
}


@end
