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
@property(nonatomic,strong) UIButton *backBtn;
@property(nonatomic,strong) UIButton *jiaoJuanBtn;
@property(nonatomic,strong) UIButton *rightBtn;

//提示
@property(nonatomic,strong) UIView *tipView;
//正确提示
@property(nonatomic,strong) UIView *rightView;
@property(nonatomic,strong) UIImageView *rightImageView;
@property(nonatomic,strong) UILabel *rightLabel;
//错误提示
@property(nonatomic,strong) UIView *errorView;
@property(nonatomic,strong) UIImageView *errorImageView;
@property(nonatomic,strong) UILabel *errorLabel;

//已作答提示
@property(nonatomic,strong) UIView *answerView;
@property(nonatomic,strong) UIImageView *answerImageView;
@property(nonatomic,strong) UILabel *answerLabel;
//未作答提示
@property(nonatomic,strong) UIView *noAnswerView;
@property(nonatomic,strong) UIImageView *noAnswerImageView;
@property(nonatomic,strong) UILabel *noAnswerLabel;

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



#pragma mark - 返回
-(void)popBack{
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.examVc.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - 关闭答题卡
-(void)close:(UIButton *)sender{
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

#pragma mark -交卷
-(void)jiaoJuan:(UIButton *)sender{
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.examVc jiaoJuan];
    }];
    
}

#pragma mark - 点击题目
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
    [self.view addSubview:self.tipView];
    [self.view addSubview:self.mainScrollView];
   
    [self.tipView addSubview:self.rightView];
    [self.tipView addSubview:self.errorView];
    [self.tipView addSubview:self.answerView];
    [self.tipView addSubview:self.noAnswerView];
   
    
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.backBtn];
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
    
    self.backBtn.sd_layout
        .centerYEqualToView(self.titleLabel)
        .leftSpaceToView(self.navBarView, 0)
        .widthIs(70)
        .heightIs(40);
    
    self.backBtn.imageView.sd_layout
        .centerYEqualToView(self.backBtn)
        .leftSpaceToView(self.backBtn, 12)
        .widthIs(15)
        .heightIs(20);
    [self.backBtn.imageView updateLayout];
    
    
    self.rightBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .rightEqualToView(self.navBarView)
    .widthIs(60)
    .heightIs(44);
    
    self.tipView.sd_layout
     .topSpaceToView(self.navBarView , 0)
     .leftEqualToView(self.view)
     .rightEqualToView(self.view)
     .heightIs(30);
    
    self.noAnswerView.sd_layout
    .rightSpaceToView(self.tipView, 16)
    .centerYEqualToView(self.tipView)
    .heightIs(25);
    
    self.noAnswerImageView.sd_layout
    .leftEqualToView(self.noAnswerView)
    .centerYEqualToView(self.noAnswerView)
    .widthIs(20)
    .heightEqualToWidth();
    self.noAnswerImageView.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.noAnswerLabel.sd_layout
    .leftSpaceToView(self.noAnswerImageView, 3)
    .centerYEqualToView(self.noAnswerView)
    .heightIs(15);
    [self.noAnswerLabel setSingleLineAutoResizeWithMaxWidth:60];
    
    [self.noAnswerView setupAutoWidthWithRightView:self.noAnswerLabel rightMargin:5];
    
    
    self.answerView.sd_layout
    .rightSpaceToView(self.noAnswerView, 10)
    .centerYEqualToView(self.tipView)
    .heightRatioToView(self.noAnswerView, 1);
    
    self.answerImageView.sd_layout
    .leftEqualToView(self.answerView)
    .centerYEqualToView(self.answerView)
    .widthRatioToView(self.noAnswerImageView, 1)
    .heightEqualToWidth();
    self.answerImageView.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.answerLabel.sd_layout
    .leftSpaceToView(self.answerImageView, 3)
    .centerYEqualToView(self.answerView)
    .heightRatioToView(self.noAnswerLabel, 1);
    [self.answerLabel setSingleLineAutoResizeWithMaxWidth:60];
    
    [self.answerView setupAutoWidthWithRightView:self.answerLabel rightMargin:5];
    
    
    self.errorView.sd_layout
    .rightSpaceToView(self.noAnswerView, 10)
    .centerYEqualToView(self.tipView)
    .heightRatioToView(self.noAnswerView, 1);
    
    self.errorImageView.sd_layout
    .leftEqualToView(self.errorView)
    .centerYEqualToView(self.errorView)
    .widthRatioToView(self.noAnswerImageView, 1)
    .heightEqualToWidth();
    self.errorImageView.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.errorLabel.sd_layout
    .leftSpaceToView(self.errorImageView, 3)
    .centerYEqualToView(self.errorView)
    .heightRatioToView(self.noAnswerLabel, 1);
    [self.errorLabel setSingleLineAutoResizeWithMaxWidth:60];
    
    [self.errorView setupAutoWidthWithRightView:self.errorLabel rightMargin:5];
    
    
    self.rightView.sd_layout
    .rightSpaceToView(self.errorView, 10)
    .centerYEqualToView(self.tipView)
    .heightRatioToView(self.noAnswerView, 1);
    
    self.rightImageView.sd_layout
    .leftEqualToView(self.rightView)
    .centerYEqualToView(self.rightView)
    .widthRatioToView(self.noAnswerImageView, 1)
    .heightEqualToWidth();
    self.rightImageView.sd_cornerRadiusFromHeightRatio=@0.5;
    
    self.rightLabel.sd_layout
    .leftSpaceToView(self.rightImageView, 3)
    .centerYEqualToView(self.rightView)
    .heightRatioToView(self.noAnswerLabel, 1);
    [self.rightLabel setSingleLineAutoResizeWithMaxWidth:60];
    
    [self.rightView setupAutoWidthWithRightView:self.rightLabel rightMargin:5];
    
    
    
    
    
    
   self.mainScrollView.sd_layout
    .topSpaceToView(self.tipView , 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    
    [self.mainScrollView updateLayout];
    
    self.backBtn.hidden = self.rightView.hidden = self.errorView.hidden = self.examPaperModel.isContinuerExam;
    self.jiaoJuanBtn.hidden = self.answerView.hidden = !self.examPaperModel.isContinuerExam;
    
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
                        
                        if (self.examPaperModel.isContinuerExam) {//开始考试或者继续考试
                            //有答案
                            if (![HXCommonUtil isNull:qInfo.answer]||qInfo.fuJianImages.count>0) {
                                [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img3"] forState:UIControlStateNormal];
                                [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            }else{
                                [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
                                [qbtn setTitleColor:COLOR_WITH_ALPHA(0x62a4f7, 1) forState:UIControlStateNormal];
                            }
                            
                        }else{//查看答卷
                            if (qInfo.answerModel!=nil) {
                                [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                if (qInfo.answerModel.right) {
                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img5"] forState:UIControlStateNormal];
                                }else{
                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img6"] forState:UIControlStateNormal];
                                }
                            }else{
                                [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
                                [qbtn setTitleColor:[UIColor colorWithRed:0.38 green:0.64 blue:0.97 alpha:1.00] forState:UIControlStateNormal];//@"#62a4f7"
                            }
                        }
                        
                        [qbtn addTarget:self action:@selector(qbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                        qbtn.frame = CGRectMake((i2%rowNum)*(itemMargin+itemHeight)+itemMargin, (i2/rowNum)*(itemMargin+itemHeight)+qTitle.bottom, itemHeight, itemHeight);
                        [self.mainScrollView addSubview:qbtn];
            
                        contentHeight = qbtn.bottom;
                    }else{
                        //先绘制题号 横线+半圆的那个
                        //横线
                        UILabel *fhTitle = [[UILabel alloc]initWithFrame:CGRectMake(20,contentHeight+10, kScreenWidth-40,30 )];
                        fhTitle.backgroundColor = [UIColor clearColor];
                        UIImage * fuheQImg2 = [UIImage imageNamed:@"exam_img2"];
                        fuheQImg2 = [fuheQImg2 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
                        UIImageView * fuheView2 = [[UIImageView alloc]initWithImage:fuheQImg2];
                        fuheView2.frame = fhTitle.frame;
                        [self.mainScrollView addSubview:fuheView2];
                        //半圆
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
                            
                            if (self.examPaperModel.isContinuerExam) {//开始考试或者继续考试
                                if (![HXCommonUtil isNull:subInfo.answer]||qInfo.fuJianImages.count>0) {
                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img3"] forState:UIControlStateNormal];
                                    [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                }else{
                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
                                    [qbtn setTitleColor:COLOR_WITH_ALPHA(0x62a4f7, 1) forState:UIControlStateNormal];
                                }
                            }else{//查看答卷
                                if (subInfo.answerModel!=nil) {
                                    [qbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                    if (subInfo.answerModel.right) {
                                        [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img5"] forState:UIControlStateNormal];
                                    }else{
                                        [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img6"] forState:UIControlStateNormal];
                                    }
                                }else{
                                    [qbtn setBackgroundImage:[UIImage imageNamed:@"exam_img4"] forState:UIControlStateNormal];
                                    [qbtn setTitleColor:[UIColor colorWithRed:0.38 green:0.64 blue:0.97 alpha:1.00] forState:UIControlStateNormal];//@"#62a4f7"
                                }
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

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navi_whiteback"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
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

-(UIView *)tipView{
    if (!_tipView) {
        _tipView = [[UIView alloc] init];
        _tipView.backgroundColor = COLOR_WITH_ALPHA(0xffffff, 1);
    }
    return _tipView;
}


-(UIView *)rightView{
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        [_rightView addSubview:self.rightImageView];
        [_rightView addSubview:self.rightLabel];
        _rightView.hidden = YES;
    }
    return _rightView;
}

-(UIImageView *)rightImageView{
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.backgroundColor=COLOR_WITH_ALPHA(0x4ed838, 1);
        _rightImageView.clipsToBounds = YES;
    }
    return _rightImageView;
}

-(UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = HXFont(13);
        _rightLabel.textColor = COLOR_WITH_ALPHA(0xA4A4A4, 1);
        _rightLabel.text = @"作答正确";
    }
    return _rightLabel;
}

-(UIView *)errorView{
    if (!_errorView) {
        _errorView = [[UIView alloc] init];
        [_errorView addSubview:self.errorImageView];
        [_errorView addSubview:self.errorLabel];
        _errorView.hidden = YES;
    }
    return _errorView;
}

-(UIImageView *)errorImageView{
    if (!_errorImageView) {
        _errorImageView = [[UIImageView alloc] init];
        _errorImageView.backgroundColor= COLOR_WITH_ALPHA(0xfe624b, 1);
        _errorImageView.clipsToBounds = YES;
    }
    return _errorImageView;
}

-(UILabel *)errorLabel{
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.font = HXFont(13);
        _errorLabel.textColor = COLOR_WITH_ALPHA(0xA4A4A4, 1);
        _errorLabel.text = @"作答错误";
    }
    return _errorLabel;
}

-(UIView *)noAnswerView{
    if (!_noAnswerView) {
        _noAnswerView = [[UIView alloc] init];
        [_noAnswerView addSubview:self.noAnswerImageView];
        [_noAnswerView addSubview:self.noAnswerLabel];
    }
    return _noAnswerView;
}

-(UIImageView *)noAnswerImageView{
    if (!_noAnswerImageView) {
        _noAnswerImageView = [[UIImageView alloc] init];
        _noAnswerImageView.backgroundColor= COLOR_WITH_ALPHA(0xffffff, 1);
        _noAnswerImageView.layer.borderWidth=1;
        _noAnswerImageView.layer.borderColor = COLOR_WITH_ALPHA(0x4ba4fe, 1).CGColor;
        _noAnswerImageView.clipsToBounds = YES;
    }
    return _noAnswerImageView;
}

-(UILabel *)noAnswerLabel{
    if (!_noAnswerLabel) {
        _noAnswerLabel = [[UILabel alloc] init];
        _noAnswerLabel.font = HXFont(13);
        _noAnswerLabel.textColor = COLOR_WITH_ALPHA(0xA4A4A4, 1);
        _noAnswerLabel.text = @"未作答";
    }
    return _noAnswerLabel;
}

-(UIView *)answerView{
    if (!_answerView) {
        _answerView = [[UIView alloc] init];
        [_answerView addSubview:self.answerImageView];
        [_answerView addSubview:self.answerLabel];
        _answerView.hidden = YES;
    }
    return _answerView;
}

-(UIImageView *)answerImageView{
    if (!_answerImageView) {
        _answerImageView = [[UIImageView alloc] init];
        _answerImageView.backgroundColor= COLOR_WITH_ALPHA(0x4ba4fe, 1);
        _answerImageView.clipsToBounds = YES;
    }
    return _answerImageView;
}

-(UILabel *)answerLabel{
    if (!_answerLabel) {
        _answerLabel = [[UILabel alloc] init];
        _answerLabel.font = HXFont(13);
        _answerLabel.textColor = COLOR_WITH_ALPHA(0xA4A4A4, 1);
        _answerLabel.text = @"已作答";
    }
    return _answerLabel;
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
