//
//  HXAnswerSheetViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/11/21.
//

#import "HXAnswerSheetViewController.h"
#import "HXQuestionBtn.h"

@interface HXAnswerSheetViewController ()

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *jiaoJuanBtn;
@property(nonatomic,strong) UIButton *rightBtn;

@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) NSMutableArray *dataArray;

///当前的位置
@property (nonatomic, strong) NSIndexPath *indexPathNow;

@end

@implementation HXAnswerSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}


#pragma mark - Setter
-(void)setExamPaperModel:(HXExamPaperModel *)examPaperModel{
    _examPaperModel = examPaperModel;
}


#pragma mark - 交卷
-(void)close:(UIButton *)sender{
    
    [self dismissViewControllerAnimated:NO completion:^{
            
    }];
}

//交卷
-(void)jiaoJuan:(UIButton *)sender{
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.examVc.navigationController popViewControllerAnimated:YES];
    }];
    
}

//点击题目
-(void)qbtnClicked:(UIButton *)sender{
    HXQuestionBtn *qBtn = (HXQuestionBtn *)sender;
    WeakSelf(weakSelf);
    [self dismissViewControllerAnimated:NO completion:^{
        if (weakSelf.answerSheetBlock) {
            weakSelf.answerSheetBlock(qBtn.position, qBtn.fuhe_position,qBtn.isFuhe);
        }
    }];
}

#pragma mark - UI
-(void)createUI{
    
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.mainScrollView];
   
    
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.jiaoJuanBtn];
    [self.navBarView addSubview:self.rightBtn];
    
    
    
    self.navBarView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(kNavigationBarHeight);
    
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.navBarView, kStatusBarHeight)
    .centerXEqualToView(self.navBarView)
    .widthIs(kScreenWidth-140)
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.jiaoJuanBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftSpaceToView(self.navBarView, 12)
    .widthIs(65)
    .heightIs(30);
    
    
    self.rightBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .rightEqualToView(self.navBarView)
    .widthIs(60)
    .heightIs(44);
    
   self.mainScrollView.sd_layout
    .topSpaceToView(self.navBarView , 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    [self.mainScrollView updateLayout];
    
    //绘制答题卡
    [self drawTheMenuList];
    
    
}


#pragma mark - 绘制答题卡
- (void)drawTheMenuList{
    
    //默认 每个题的按钮size 为 48*48（4寸） title 的高度为40
    int rowNum = 5;
    if (IS_IPAD) {
        rowNum = 10;
    }
    CGFloat itemMargin = 20; //item外边距
    //适配4寸屏幕
    if (kScreenWidth<=320) {
        itemMargin = 16;
    }
    CGFloat itemHeight = 48;  //item宽高
    itemHeight = (kScreenWidth-itemMargin*(rowNum+1))/(CGFloat)rowNum; //动态计算item宽高
    
    NSArray *qGroups = self.examPaperModel.questionGroups;
    
    if (qGroups.count != 0 ) {
        
        //用来确定 scroller 的高度
        float contentHeight =0;//mainScrollView的高度
        NSInteger position = 0;
        //然后绘制其中的内容 包括题型的标题 以及其中的小题
        for (int i = 0; i<qGroups.count; i++) {
            if (i>=1) {
                contentHeight += itemMargin*2;
            }
            HXExamQuestionTypeModel *gmodel = qGroups[i];
            //绘制题目的标题
            UILabel *qTitle = [[UILabel alloc]initWithFrame:CGRectMake(itemMargin,contentHeight, kScreenWidth-itemMargin*2, 999)];
            qTitle.numberOfLines = 0;
            qTitle.text = [NSString stringWithFormat:@"%@",gmodel.pqt_title];
            [qTitle sizeToFit];
            
            //来一点高度
            if (qTitle.height<40) {
                qTitle.height = 40;
            }else{
                qTitle.height = 20 + qTitle.height;
            }
            [self.mainScrollView addSubview:qTitle];
            
            contentHeight = qTitle.bottom;
            
            //绘制每种题型下的小题
            if (gmodel.paperSuitQuestions.count !=0) {
                
                for (int i2 = 0; i2<gmodel.paperSuitQuestions.count; i2++) {
                    
                    HXExamPaperSuitQuestionModel *qInfo = gmodel.paperSuitQuestions[i2];
                    //要分2种情况 一种是普通的选择题 一种是复合题 需要做判断
                    if (qInfo.subQuestions.count == 0) { //等于0 的时候说明是普通的题
                        HXQuestionBtn *qbtn = [HXQuestionBtn buttonWithType:UIButtonTypeCustom];
                        qbtn.isFuhe = NO;
                        qbtn.tag = [NSString stringWithFormat:@"%d%d",i,i2].intValue;
                        qbtn.info = qInfo;
                        //记录题型位置
                        qbtn.position = position;
                        //判断是考试 还是查看试卷
                        [qbtn setTitle:qInfo.psq_serial_no forState:UIControlStateNormal];
                        
                        if (self.isEnterExam) {
                            if (![HXCommonUtil isNull:qInfo.answer]) {
                                [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img3"] forState:UIControlStateNormal];
                                [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            }else{
                                [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
                                [qbtn setTitleColor:COLOR_WITH_ALPHA(0x62a4f7, 1) forState:UIControlStateNormal];
                            }
                            
                        }else{
//                            NSDictionary *answer = [self.userAnswers objectForKey:[NSString stringWithFormat:@"%d",qInfo._id]];
//                            if (answer) {
//                                [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                                if ([[answer objectForKey:@"right"] boolValue]) {
//                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img5"] forState:UIControlStateNormal];
//                                }else{
//                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img6"] forState:UIControlStateNormal];
//                                }
//                            }else
//                            {
//                                [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
//                                [qbtn setTitleColor:[UIColor colorWithRed:0.38 green:0.64 blue:0.97 alpha:1.00] forState:UIControlStateNormal];//@"#62a4f7"
//                            }
                        }
                        
                        [qbtn addTarget:self action:@selector(qbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                        qbtn.frame = CGRectMake((i2%rowNum)*(itemMargin+itemHeight)+itemMargin, (i2/rowNum)*(itemMargin+itemHeight)+qTitle.bottom, itemHeight, itemHeight);
                        [self.mainScrollView addSubview:qbtn];
            
                        contentHeight = qbtn.bottom;
                    }else{
                        //先绘制题号 横线+半圆的那个
                        UILabel *fhTitle = [[UILabel alloc]initWithFrame:CGRectMake(20,contentHeight+10, kScreenWidth-40,30 )];
                        fhTitle.backgroundColor = [UIColor clearColor];
                        UIImage * fuheQImg2 = [UIImage imageNamed:@"exam_img2"];
                        fuheQImg2 = [fuheQImg2 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
                        UIImageView * fuheView2 = [[UIImageView alloc]initWithImage:fuheQImg2];
                        fuheView2.frame = fhTitle.frame;
                        [self.mainScrollView addSubview:fuheView2];
                        
                        UIImage * fuheQImg1 = [UIImage imageNamed:@"exam_img1"];
                        UIImageView * fuheView1 = [[UIImageView alloc]initWithImage:fuheQImg1];
                        fuheView1.center = fhTitle.center;
                        [self.mainScrollView addSubview:fuheView1];
                        
                        
                        fhTitle.textAlignment = NSTextAlignmentCenter;
                        fhTitle.text = [NSString stringWithFormat:@"%d.%d",i+1,i2+1];
                        fhTitle.textColor = COLOR_WITH_ALPHA(0x8A8A8A, 1);
                        [self.mainScrollView addSubview:fhTitle];
                        
                        for (int i3 = 0; i3<qInfo.subQuestions.count; i3++) {
                            HXExamPaperSubQuestionModel *subInfo = qInfo.subQuestions[i3];
                            //然后再绘制小btn
                            HXQuestionBtn *qbtn = [HXQuestionBtn buttonWithType:UIButtonTypeCustom];
                            qbtn.isFuhe = YES;
                            qbtn.fuhe_position = i3;
                            qbtn.tag = [NSString stringWithFormat:@"%d%d%d",i,i2,i3].intValue;
                            qbtn.subInfo = subInfo;
                            //记录题型位置
                            qbtn.position = position;
                            //判断是考试 还是查看试卷
                            [qbtn setTitle:subInfo.sub_serial_no forState:UIControlStateNormal];
                            
                            if (self.isEnterExam) {
                                if (![HXCommonUtil isNull:subInfo.answer]) {
                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img3"] forState:UIControlStateNormal];
                                    [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                }else{
                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
                                    [qbtn setTitleColor:COLOR_WITH_ALPHA(0x62a4f7, 1) forState:UIControlStateNormal];
                                }
                            }else{
                                
//                                NSDictionary *answer = [self.userAnswers objectForKey:[NSString stringWithFormat:@"%d",q3Info._id]];
//                                if (answer) {
//
//                                    [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                                    if ([[answer objectForKey:@"right"] boolValue]) {
//                                        [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img5"] forState:UIControlStateNormal];
//                                    }else{
//                                        [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img6"] forState:UIControlStateNormal];
//                                    }
//
//                                }else
//                                {
//                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
//                                    [qbtn setTitleColor:[UIColor colorWithRed:0.38 green:0.64 blue:0.97 alpha:1.00] forState:UIControlStateNormal];//@"#62a4f7"
//                                }
                            }
                            
                            
                            [qbtn addTarget:self action:@selector(qbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                            qbtn.frame = CGRectMake((i3%rowNum)*(itemMargin+itemHeight)+itemMargin, (i3/rowNum)*(itemMargin+itemHeight)+fhTitle.bottom+itemMargin, itemHeight, itemHeight);
                            [self.mainScrollView addSubview:qbtn];
                            contentHeight = qbtn.bottom;
                        }
                    }
                    //题位置自动+1;
                    position++;
                }
            }
        }
        
        self.mainScrollView.contentSize = CGSizeMake(kScreenWidth, contentHeight+20);
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
        _titleLabel.text = @"答题卡";
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

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"exam_menu"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.alwaysBounceVertical = YES;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _mainScrollView;
}




@end
