//
//  HXClassRankViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/5.
//

#import "HXClassRankViewController.h"
#import "HXClassRankCell.h"
#import "UIView+TransitionColor.h"
#import "SDWebImage.h"

@interface HXClassRankViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIButton *backBtn;
@property(nonatomic,strong) UILabel *titleLabel;
//射线
@property(nonatomic,strong) UIImageView *sheXianImageView;
//皇冠
@property(nonatomic,strong) UIImageView *crownImageView;

//第一名
@property(nonatomic,strong) UIView *firstView;
@property(nonatomic,strong) UIImageView *firstHeadImageView;
@property(nonatomic,strong) UIImageView *firstRingImageView;
@property(nonatomic,strong) UIImageView *firstRankImageView;
@property(nonatomic,strong) UILabel *firstNameLabel;
@property(nonatomic,strong) UILabel *firstDeFenLabel;
//第二名
@property(nonatomic,strong) UIView *secondView;
@property(nonatomic,strong) UIImageView *secondHeadImageView;
@property(nonatomic,strong) UIImageView *secondRingImageView;
@property(nonatomic,strong) UIImageView *secondRankImageView;
@property(nonatomic,strong) UILabel *secondNameLabel;
@property(nonatomic,strong) UILabel *secondDeFenLabel;

//第三名
@property(nonatomic,strong) UIView *thirdView;
@property(nonatomic,strong) UIImageView *thirdHeadImageView;
@property(nonatomic,strong) UIImageView *thirdRingImageView;
@property(nonatomic,strong) UIImageView *thirdRankImageView;
@property(nonatomic,strong) UILabel *thirdNameLabel;
@property(nonatomic,strong) UILabel *thirdDeFenLabel;

@property(nonatomic,strong) UIView *containerView;
@property(nonatomic,strong) UIView *whiteView;
@property(nonatomic,strong) UIView *touYingView;
@property(nonatomic,strong) UILabel *rankLabel;//排名
@property(nonatomic,strong) UILabel *nameLabel;//姓名
@property(nonatomic,strong) UILabel *deFenLabel;//分数

@property(nonatomic,strong) UITableView *mainTableView;

//底部固定区域
@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIImageView *jiangPaiImageView;
@property(nonatomic,strong) UILabel *myRankLabel;
@property(nonatomic,strong) UIImageView *myHeadImageView;
@property(nonatomic,strong) UILabel *myNameLabel;
@property(nonatomic,strong) UILabel *encourageLabel;//太厉害啦！你是第 名
@property(nonatomic,strong) UILabel *myDeFenLabel;

@property(nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HXClassRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UI
    [self createUI];
    
    //获取班级排名
    [self getClassRank];
}

#pragma mark -Setter
-(void)setCourseInfoModel:(HXCourseInfoModel *)courseInfoModel{
    _courseInfoModel = courseInfoModel;
}

#pragma mark - 班级排名
-(void)getClassRank{

    NSDictionary *dic =@{
        @"termcourse_id":HXSafeString(self.courseInfoModel.termCourseID),
        @"student_id":HXSafeString(self.courseInfoModel.student_id),
    };
    
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetClassRank withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSArray *list = [HXCourseScoreRankModel mj_objectArrayWithKeyValuesArray:[dictionary dictionaryValueForKey:@"data"]];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:list];
            [self.mainTableView reloadData];
            
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //前三名
                HXCourseScoreRankModel *model = obj;
                if(model.rownum==1){
                    self.firstNameLabel.text = model.name;
                    self.firstDeFenLabel.text = [NSString stringWithFormat:@"%.0f分",model.finalScore];
                    [self.firstHeadImageView sd_setImageWithURL:HXSafeURL(model.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
                }else if(model.rownum==2){
                    self.secondNameLabel.text = model.name;
                    self.secondDeFenLabel.text = [NSString stringWithFormat:@"%.0f分",model.finalScore];
                    [self.secondHeadImageView sd_setImageWithURL:HXSafeURL(model.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
                }else if(model.rownum==3){
                    self.thirdNameLabel.text = model.name;
                    self.thirdDeFenLabel.text = [NSString stringWithFormat:@"%.0f分",model.finalScore];
                    [self.thirdHeadImageView sd_setImageWithURL:HXSafeURL(model.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
                }
                
                
                //自己
                if(model.state==1){
                    [self.myHeadImageView sd_setImageWithURL:HXSafeURL(model.imgUrl) placeholderImage:[UIImage imageNamed:@"defaulthead_icon"] options:SDWebImageRefreshCached];
                    self.myNameLabel.text = model.name;
                    self.myDeFenLabel.text = [NSString stringWithFormat:@"%.0f分",model.finalScore];
                    self.jiangPaiImageView.hidden = YES;
                    self.myRankLabel.hidden = YES;
                    
                    if(model.rownum==1){
                        self.jiangPaiImageView.hidden = NO;
                        self.jiangPaiImageView.image = [UIImage imageNamed:@"jinpai_icon"];
                    }else if(model.rownum==2){
                        self.jiangPaiImageView.hidden = NO;
                        self.jiangPaiImageView.image = [UIImage imageNamed:@"yinpai_icon"];
                    }else if(model.rownum==3){
                        self.jiangPaiImageView.hidden = NO;
                        self.jiangPaiImageView.image = [UIImage imageNamed:@"tongpai_icon"];
                    }else{
                        self.myRankLabel.hidden = NO;
                        self.myRankLabel.text = [NSString stringWithFormat:@"%ld",(long)model.rownum];
                    }
                    
                    if(model.rownum<=3){
                        self.myNameLabel.sd_layout.centerYEqualToView(self.jiangPaiImageView).offset(-10);
                        [self.myNameLabel updateLayout];
                        NSString *rank = [NSString stringWithFormat:@"%ld",(long)model.rownum];
                        NSString *content = [NSString stringWithFormat:@"太厉害啦！你是第 %ld 名",(long)model.rownum];
                        self.encourageLabel.attributedText = [HXCommonUtil getAttributedStringWith:rank needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x2E5BFD, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]} content:content defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x999999, 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
                    }else{
                        self.myNameLabel.sd_layout.centerYEqualToView(self.jiangPaiImageView).offset(0);
                        [self.myNameLabel updateLayout];
                        self.encourageLabel.attributedText = nil;
                    }
                }
                            
            }];
        }
    } failure:^(NSError * _Nonnull error) {
       
    }];
}


#pragma mark - Event
-(void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
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
    return 50;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classRankCellIdentifier = @"HXClassRankCellIdentifier";
    HXClassRankCell *cell = [tableView dequeueReusableCellWithIdentifier:classRankCellIdentifier];
    if (!cell) {
        cell = [[HXClassRankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classRankCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.idx = (indexPath.row+1);
    cell.courseScoreRankModel = self.dataArray[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI
-(void)createUI{
    
    self.view.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    [self.view addSubview:self.sheXianImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.crownImageView];
    [self.view addSubview:self.secondView];
    [self.view addSubview:self.thirdView];
    [self.view addSubview:self.firstView];
    [self.view addSubview:self.bottomView];
    
    [self.firstView addSubview:self.firstHeadImageView];
    [self.firstView addSubview:self.firstRingImageView];
    [self.firstView addSubview:self.firstRankImageView];
    [self.firstView addSubview:self.firstNameLabel];
    [self.firstView addSubview:self.firstDeFenLabel];
    
    [self.secondView addSubview:self.secondHeadImageView];
    [self.secondView addSubview:self.secondRingImageView];
    [self.secondView addSubview:self.secondRankImageView];
    [self.secondView addSubview:self.secondNameLabel];
    [self.secondView addSubview:self.secondDeFenLabel];
    
    [self.thirdView addSubview:self.thirdHeadImageView];
    [self.thirdView addSubview:self.thirdRingImageView];
    [self.thirdView addSubview:self.thirdRankImageView];
    [self.thirdView addSubview:self.thirdNameLabel];
    [self.thirdView addSubview:self.thirdDeFenLabel];
    
    [self.containerView addSubview:self.mainTableView];
    [self.containerView addSubview:self.whiteView];
    [self.containerView addSubview:self.touYingView];
    [self.whiteView addSubview:self.rankLabel];
    [self.whiteView addSubview:self.nameLabel];
    [self.whiteView addSubview:self.deFenLabel];
    
    [self.bottomView addSubview:self.jiangPaiImageView];
    [self.bottomView addSubview:self.myRankLabel];
    [self.bottomView addSubview:self.myHeadImageView];
    [self.bottomView addSubview:self.myNameLabel];
    [self.bottomView addSubview:self.encourageLabel];
    [self.bottomView addSubview:self.myDeFenLabel];
    
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.view, kStatusBarHeight)
    .centerXEqualToView(self.view)
    .widthIs(100)
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.backBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftEqualToView(self.view)
    .widthIs(60)
    .heightIs(44);
    
    self.sheXianImageView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(210);
    
    self.crownImageView.sd_layout
    .topSpaceToView(self.view, 50)
    .centerXEqualToView(self.view)
    .widthIs(98)
    .heightIs(123);
    
    self.firstView.sd_layout
    .topSpaceToView(self.view, 136)
    .centerXEqualToView(self.view)
    .widthIs(109)
    .heightIs(161);
    [self.firstView updateLayout];
    
    // 模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *firstVisualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    firstVisualView.clipsToBounds = YES;
    firstVisualView.layer.cornerRadius = 6;
    firstVisualView.frame = self.firstView.bounds;
    [self.firstView addSubview:firstVisualView];
    [self.firstView insertSubview:firstVisualView belowSubview:self.firstHeadImageView];
    
    
    self.secondView.sd_layout
    .bottomEqualToView(self.firstView)
    .rightSpaceToView(self.firstView, -6)
    .widthIs(97)
    .heightIs(145);
    [self.secondView updateLayout];
    
    UIVisualEffectView *secondVisualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    secondVisualView.clipsToBounds = YES;
    secondVisualView.layer.cornerRadius = 6;
    secondVisualView.frame = self.secondView.bounds;
    [self.secondView addSubview:secondVisualView];
    [self.secondView insertSubview:secondVisualView belowSubview:self.secondHeadImageView];
    
    self.thirdView.sd_layout
    .bottomEqualToView(self.firstView)
    .leftSpaceToView(self.firstView, -6)
    .widthIs(97)
    .heightIs(145);
    [self.thirdView updateLayout];
    
    UIVisualEffectView *thirdVisualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    thirdVisualView.clipsToBounds = YES;
    thirdVisualView.layer.cornerRadius = 6;
    thirdVisualView.frame = self.thirdView.bounds;
    [self.thirdView addSubview:thirdVisualView];
    [self.thirdView insertSubview:thirdVisualView belowSubview:self.thirdHeadImageView];
    
    self.firstRingImageView.sd_layout
    .centerXEqualToView(self.firstView)
    .topSpaceToView(self.firstView, 12)
    .widthIs(60)
    .heightEqualToWidth();
    
    self.firstHeadImageView.sd_layout
    .centerXEqualToView(self.firstRingImageView)
    .centerYEqualToView(self.firstRingImageView)
    .widthIs(58)
    .heightEqualToWidth();
    self.firstHeadImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.firstRankImageView.sd_layout
    .topSpaceToView(self.firstRingImageView, -7)
    .centerXEqualToView(self.firstView)
    .widthIs(91)
    .heightIs(34);
    
    self.firstNameLabel.sd_layout
    .topSpaceToView(self.firstRankImageView, 1)
    .leftSpaceToView(self.firstView, 10)
    .rightSpaceToView(self.firstView, 10)
    .heightIs(21);
    
    self.firstDeFenLabel.sd_layout
    .topSpaceToView(self.firstNameLabel, 1)
    .leftSpaceToView(self.firstView, 10)
    .rightSpaceToView(self.firstView, 10)
    .heightIs(17);
    
    
    self.secondRingImageView.sd_layout
    .centerXEqualToView(self.secondView)
    .topSpaceToView(self.secondView, 20)
    .widthIs(48)
    .heightEqualToWidth();
    
    self.secondHeadImageView.sd_layout
    .centerXEqualToView(self.secondRingImageView)
    .centerYEqualToView(self.secondRingImageView)
    .widthIs(46)
    .heightEqualToWidth();
    self.secondHeadImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.secondRankImageView.sd_layout
    .topSpaceToView(self.secondRingImageView, -7)
    .centerXEqualToView(self.secondView)
    .widthIs(73)
    .heightIs(27);
    
    self.secondNameLabel.sd_layout
    .topSpaceToView(self.secondRankImageView, 1)
    .leftSpaceToView(self.secondView, 10)
    .rightSpaceToView(self.secondView, 10)
    .heightIs(21);
    
    self.secondDeFenLabel.sd_layout
    .topSpaceToView(self.secondNameLabel, 1)
    .leftSpaceToView(self.secondView, 10)
    .rightSpaceToView(self.secondView, 10)
    .heightIs(17);
    
    self.thirdRingImageView.sd_layout
    .centerXEqualToView(self.thirdView)
    .topSpaceToView(self.thirdView, 20)
    .widthIs(48)
    .heightEqualToWidth();
    
    self.thirdHeadImageView.sd_layout
    .centerXEqualToView(self.thirdRingImageView)
    .centerYEqualToView(self.thirdRingImageView)
    .widthIs(46)
    .heightEqualToWidth();
    self.thirdHeadImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.thirdRankImageView.sd_layout
    .topSpaceToView(self.thirdRingImageView, -7)
    .centerXEqualToView(self.thirdView)
    .widthIs(73)
    .heightIs(27);
    
    self.thirdNameLabel.sd_layout
    .topSpaceToView(self.thirdRankImageView, 1)
    .leftSpaceToView(self.thirdView, 10)
    .rightSpaceToView(self.thirdView, 10)
    .heightIs(21);
    
    self.thirdDeFenLabel.sd_layout
    .topSpaceToView(self.thirdNameLabel, 1)
    .leftSpaceToView(self.thirdView, 10)
    .rightSpaceToView(self.thirdView, 10)
    .heightIs(17);
    
    self.containerView.sd_layout
    .topSpaceToView(self.firstView, -54)
    .bottomSpaceToView(self.view, 40)
    .leftSpaceToView(self.view, 20)
    .rightSpaceToView(self.view, 20);
    
    self.containerView.sd_cornerRadius = @12;
    
    self.whiteView.sd_layout
    .topEqualToView(self.containerView)
    .leftEqualToView(self.containerView)
    .rightEqualToView(self.containerView)
    .heightIs(112);
    
    self.touYingView.sd_layout
    .topSpaceToView(self.whiteView, 0)
    .leftEqualToView(self.containerView)
    .rightEqualToView(self.containerView)
    .heightIs(27);
    [self.touYingView updateLayout];
    // 渐变
    [self.touYingView addTransitionColorTopToBottom:COLOR_WITH_ALPHA(0x000000, 0.9) endColor:COLOR_WITH_ALPHA(0x000000, 0.1)];
    
    self.rankLabel.sd_layout
    .bottomEqualToView(self.whiteView)
    .leftEqualToView(self.whiteView)
    .widthIs(76)
    .heightIs(32);
    
    
    self.nameLabel.sd_layout
    .centerYEqualToView(self.rankLabel)
    .leftSpaceToView(self.rankLabel, 20)
    .widthIs(76)
    .heightIs(32);
    
    self.deFenLabel.sd_layout
    .centerYEqualToView(self.rankLabel)
    .rightEqualToView(self.whiteView)
    .widthIs(98)
    .heightIs(32);
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.whiteView, 0)
    .leftEqualToView(self.containerView)
    .rightEqualToView(self.containerView)
    .bottomEqualToView(self.containerView);
    
    self.bottomView.sd_layout
    .bottomEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(75);
    
    
    self.jiangPaiImageView.sd_layout
    .centerYEqualToView(self.bottomView).offset(-10)
    .leftSpaceToView(self.bottomView, 45)
    .widthIs(27)
    .heightIs(35);
    
    self.myRankLabel.sd_layout
    .centerXEqualToView(self.jiangPaiImageView)
    .centerYEqualToView(self.jiangPaiImageView)
    .widthIs(50)
    .heightIs(21);
    
    self.myHeadImageView.sd_layout
    .centerYEqualToView(self.jiangPaiImageView)
    .leftSpaceToView(self.jiangPaiImageView, 40)
    .widthIs(30)
    .heightEqualToWidth();
    self.myHeadImageView.sd_cornerRadiusFromHeightRatio = @0.5;
    
    self.myNameLabel.sd_layout
    .centerYEqualToView(self.jiangPaiImageView).offset(-10)
    .leftSpaceToView(self.myHeadImageView, 20)
    .widthIs(100)
    .heightIs(21);
    
    self.encourageLabel.sd_layout
    .bottomEqualToView(self.myHeadImageView)
    .leftEqualToView(self.myNameLabel)
    .widthIs(120)
    .heightIs(16);
    
    self.myDeFenLabel.sd_layout
    .centerYEqualToView(self.jiangPaiImageView)
    .rightSpaceToView(self.bottomView, 55)
    .widthIs(40)
    .heightIs(21);
    
    
    
}



#pragma mark -LazyLoad
-(NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(UIImageView *)sheXianImageView{
    if (!_sheXianImageView) {
        _sheXianImageView = [[UIImageView alloc] init];
        _sheXianImageView.clipsToBounds = YES;
        _sheXianImageView.userInteractionEnabled = YES;
        _sheXianImageView.contentMode = UIViewContentModeScaleAspectFill;
        _sheXianImageView.image = [UIImage imageNamed:@"shexian_icon"];
    }
    return _sheXianImageView;
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navi_whiteback"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.text = @"班级排名";
    }
    return _titleLabel;
}

-(UIImageView *)crownImageView{
    if (!_crownImageView) {
        _crownImageView = [[UIImageView alloc] init];
        _crownImageView.userInteractionEnabled = YES;
        _crownImageView.image = [UIImage imageNamed:@"crown_icon"];
    }
    return _crownImageView;
}

-(UIView *)firstView{
    if (!_firstView) {
        _firstView = [[UIView alloc] init];
        _firstView.layer.borderWidth = 1;
        _firstView.layer.borderColor = UIColor.whiteColor.CGColor;
        _firstView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 0.7);
        _firstView.layer.cornerRadius = 6;
        _firstView.layer.shadowColor = COLOR_WITH_ALPHA(0xB6C3DB, 0.24).CGColor;
        _firstView.layer.shadowOffset = CGSizeMake(0,2);
        _firstView.layer.shadowOpacity = 1;
        _firstView.layer.shadowRadius = 15;
    }
    return _firstView;
}

-(UIImageView *)firstHeadImageView{
    if (!_firstHeadImageView) {
        _firstHeadImageView = [[UIImageView alloc] init];
        _firstHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
        _firstHeadImageView.clipsToBounds = YES;
        _firstHeadImageView.userInteractionEnabled = YES;
        _firstHeadImageView.image = [UIImage imageNamed:@"defaulthead_icon"];
    }
    return _firstHeadImageView;
}

-(UIImageView *)firstRingImageView{
    if (!_firstRingImageView) {
        _firstRingImageView = [[UIImageView alloc] init];
        _firstRingImageView.clipsToBounds = YES;
        _firstRingImageView.userInteractionEnabled = YES;
        _firstRingImageView.image = [UIImage imageNamed:@"firstring_icon"];
    }
    return _firstRingImageView;
}

-(UIImageView *)firstRankImageView{
    if (!_firstRankImageView) {
        _firstRankImageView = [[UIImageView alloc] init];
        _firstRankImageView.clipsToBounds = YES;
        _firstRankImageView.userInteractionEnabled = YES;
        _firstRankImageView.image = [UIImage imageNamed:@"firstrank_icon"];
    }
    return _firstRankImageView;
}


-(UILabel *)firstNameLabel{
    if (!_firstNameLabel) {
        _firstNameLabel = [[UILabel alloc] init];
        _firstNameLabel.textAlignment = NSTextAlignmentCenter;
        _firstNameLabel.font = HXFont(15);
        _firstNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _firstNameLabel;
}

-(UILabel *)firstDeFenLabel{
    if (!_firstDeFenLabel) {
        _firstDeFenLabel = [[UILabel alloc] init];
        _firstDeFenLabel.textAlignment = NSTextAlignmentCenter;
        _firstDeFenLabel.font = HXFont(12);
        _firstDeFenLabel.textColor = COLOR_WITH_ALPHA(0xF14E4E, 1);
        
    }
    return _firstDeFenLabel;
}


-(UIView *)secondView{
    if (!_secondView) {
        _secondView = [[UIView alloc] init];
        _secondView.layer.borderWidth = 1;
        _secondView.layer.borderColor = UIColor.whiteColor.CGColor;
        _secondView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 0.7);
        _secondView.layer.cornerRadius = 6;
        _secondView.layer.shadowColor = COLOR_WITH_ALPHA(0xB6C3DB, 0.24).CGColor;
        _secondView.layer.shadowOffset = CGSizeMake(0,2);
        _secondView.layer.shadowOpacity = 1;
        _secondView.layer.shadowRadius = 15;
    }
    return _secondView;
}

-(UIImageView *)secondHeadImageView{
    if (!_secondHeadImageView) {
        _secondHeadImageView = [[UIImageView alloc] init];
        _secondHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
        _secondHeadImageView.clipsToBounds = YES;
        _secondHeadImageView.userInteractionEnabled = YES;
        _secondHeadImageView.image = [UIImage imageNamed:@"defaulthead_icon"];
    }
    return _secondHeadImageView;
}

-(UIImageView *)secondRingImageView{
    if (!_secondRingImageView) {
        _secondRingImageView = [[UIImageView alloc] init];
        _secondRingImageView.clipsToBounds = YES;
        _secondRingImageView.userInteractionEnabled = YES;
        _secondRingImageView.image = [UIImage imageNamed:@"secondring_icon"];
    }
    return _secondRingImageView;
}

-(UIImageView *)secondRankImageView{
    if (!_secondRankImageView) {
        _secondRankImageView = [[UIImageView alloc] init];
        _secondRankImageView.clipsToBounds = YES;
        _secondRankImageView.userInteractionEnabled = YES;
        _secondRankImageView.image = [UIImage imageNamed:@"secondrank_icon"];
    }
    return _secondRankImageView;
}


-(UILabel *)secondNameLabel{
    if (!_secondNameLabel) {
        _secondNameLabel = [[UILabel alloc] init];
        _secondNameLabel.textAlignment = NSTextAlignmentCenter;
        _secondNameLabel.font = HXFont(15);
        _secondNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);

    }
    return _secondNameLabel;
}

-(UILabel *)secondDeFenLabel{
    if (!_secondDeFenLabel) {
        _secondDeFenLabel = [[UILabel alloc] init];
        _secondDeFenLabel.textAlignment = NSTextAlignmentCenter;
        _secondDeFenLabel.font = HXFont(12);
        _secondDeFenLabel.textColor = COLOR_WITH_ALPHA(0xF14E4E, 1);

    }
    return _secondDeFenLabel;
}

-(UIView *)thirdView{
    if (!_thirdView) {
        _thirdView = [[UIView alloc] init];
        _thirdView.layer.borderWidth = 1;
        _thirdView.layer.borderColor = UIColor.whiteColor.CGColor;
        _thirdView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 0.7);
        _thirdView.layer.cornerRadius = 6;
        _thirdView.layer.shadowColor = COLOR_WITH_ALPHA(0xB6C3DB, 0.24).CGColor;
        _thirdView.layer.shadowOffset = CGSizeMake(0,2);
        _thirdView.layer.shadowOpacity = 1;
        _thirdView.layer.shadowRadius = 15;
    }
    return _thirdView;
}

-(UIImageView *)thirdHeadImageView{
    if (!_thirdHeadImageView) {
        _thirdHeadImageView = [[UIImageView alloc] init];
        _thirdHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thirdHeadImageView.clipsToBounds = YES;
        _thirdHeadImageView.userInteractionEnabled = YES;
        _thirdHeadImageView.image = [UIImage imageNamed:@"defaulthead_icon"];
    }
    return _thirdHeadImageView;
}

-(UIImageView *)thirdRingImageView{
    if (!_thirdRingImageView) {
        _thirdRingImageView = [[UIImageView alloc] init];
        _thirdRingImageView.clipsToBounds = YES;
        _thirdRingImageView.userInteractionEnabled = YES;
        _thirdRingImageView.image = [UIImage imageNamed:@"thirdring_icon"];
    }
    return _thirdRingImageView;
}

-(UIImageView *)thirdRankImageView{
    if (!_thirdRankImageView) {
        _thirdRankImageView = [[UIImageView alloc] init];
        _thirdRankImageView.clipsToBounds = YES;
        _thirdRankImageView.userInteractionEnabled = YES;
        _thirdRankImageView.image = [UIImage imageNamed:@"thirdrank_icon"];
    }
    return _thirdRankImageView;
}


-(UILabel *)thirdNameLabel{
    if (!_thirdNameLabel) {
        _thirdNameLabel = [[UILabel alloc] init];
        _thirdNameLabel.textAlignment = NSTextAlignmentCenter;
        _thirdNameLabel.font = HXFont(15);
        _thirdNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _thirdNameLabel;
}

-(UILabel *)thirdDeFenLabel{
    if (!_thirdDeFenLabel) {
        _thirdDeFenLabel = [[UILabel alloc] init];
        _thirdDeFenLabel.textAlignment = NSTextAlignmentCenter;
        _thirdDeFenLabel.font = HXFont(12);
        _thirdDeFenLabel.textColor = COLOR_WITH_ALPHA(0xF14E4E, 1);
        
    }
    return _thirdDeFenLabel;
}


-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.clipsToBounds = YES;
        _containerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _containerView;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.bounces = YES;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = UIColor.whiteColor;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.showsVerticalScrollIndicator = NO;
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
        _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
        _mainTableView.scrollIndicatorInsets = _mainTableView.contentInset;

    }
    return _mainTableView;
}

-(UIView *)whiteView{
    if (!_whiteView) {
        _whiteView = [[UIView alloc] init];
        _whiteView.clipsToBounds = YES;
        _whiteView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _whiteView;
}

-(UIView *)touYingView{
    if (!_touYingView) {
        _touYingView = [[UIView alloc] init];
        _touYingView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.01);
        _touYingView.clipsToBounds = YES;
        
    }
    return _touYingView;
}

-(UILabel *)rankLabel{
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc] init];
        _rankLabel.textAlignment = NSTextAlignmentCenter;
        _rankLabel.font = HXFont(14);
        _rankLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _rankLabel.text = @"排名";
    }
    return _rankLabel;
}

-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = HXFont(14);
        _nameLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _nameLabel.text = @"姓名";
    }
    return _nameLabel;
}

-(UILabel *)deFenLabel{
    if (!_deFenLabel) {
        _deFenLabel = [[UILabel alloc] init];
        _deFenLabel.textAlignment = NSTextAlignmentCenter;
        _deFenLabel.font = HXFont(14);
        _deFenLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _deFenLabel.text = @"分数";
    }
    return _deFenLabel;
}


-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _bottomView.layer.shadowColor = COLOR_WITH_ALPHA(0x000000, 0.06).CGColor;
        _bottomView.layer.shadowOffset = CGSizeMake(0,-2);
        _bottomView.layer.shadowOpacity = 1;
        _bottomView.layer.shadowRadius = 10;
    }
    return _bottomView;
}

-(UIImageView *)jiangPaiImageView{
    if (!_jiangPaiImageView) {
        _jiangPaiImageView = [[UIImageView alloc] init];
        _jiangPaiImageView.userInteractionEnabled = YES;
        _jiangPaiImageView.hidden = YES;
    }
    return _jiangPaiImageView;
}


-(UILabel *)myRankLabel{
    if (!_myRankLabel) {
        _myRankLabel = [[UILabel alloc] init];
        _myRankLabel.textAlignment = NSTextAlignmentCenter;
        _myRankLabel.font = HXFont(15);
        _myRankLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _myNameLabel.hidden = YES;
    }
    return _myRankLabel;
}

-(UIImageView *)myHeadImageView{
    if (!_myHeadImageView) {
        _myHeadImageView = [[UIImageView alloc] init];
        _myHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
        _myHeadImageView.clipsToBounds = YES;
        _myHeadImageView.userInteractionEnabled = YES;
        _myHeadImageView.image = [UIImage imageNamed:@"defaulthead_icon"];
    }
    return _myHeadImageView;
}

-(UILabel *)myNameLabel{
    if (!_myNameLabel) {
        _myNameLabel = [[UILabel alloc] init];
        _myNameLabel.textAlignment = NSTextAlignmentLeft;
        _myNameLabel.font = HXFont(15);
        _myNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
    
    }
    return _myNameLabel;
}

-(UILabel *)encourageLabel{
    if (!_encourageLabel) {
        _encourageLabel = [[UILabel alloc] init];
        _encourageLabel.textAlignment = NSTextAlignmentLeft;
        _encourageLabel.font = HXFont(11);
        _encourageLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        
    }
    return _encourageLabel;
}


-(UILabel *)myDeFenLabel{
    if (!_myDeFenLabel) {
        _myDeFenLabel = [[UILabel alloc] init];
        _myDeFenLabel.textAlignment = NSTextAlignmentLeft;
        _myDeFenLabel.font = HXFont(15);
        _myDeFenLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        
    }
    return _myDeFenLabel;
}


@end
