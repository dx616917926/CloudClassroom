//
//  HXPersonalInforViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXPersonalInforViewController.h"
#import "HXPersonalInforCell.h"
#import "HXXinXiYouWuShowView.h"

@interface HXPersonalInforViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *backBtn;

@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) UIImageView *topBgImageView;
@property(nonatomic,strong) UIView *containerView;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UILabel *basicInforLabel;

@property(nonatomic,strong) UIView *tableFooterView;
@property(nonatomic,strong) UIButton *xinXiYouWuBtn;
@property(nonatomic,strong) UIButton *xinXiWuWuBtn;

@property(nonatomic,strong) NSArray *basicInfoArray;
@property(nonatomic,strong) NSArray *xuexiInfoArray;

@end

@implementation HXPersonalInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
    
    //
    [self dataInitialization];
}

-(void)dataInitialization{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"personalInfor" ofType:@"plist"];
    NSDictionary *personalInforDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *array1 = [personalInforDictionary objectForKey:@"basicInfoArray"];//基础信息
    NSArray *array2 = [personalInforDictionary objectForKey:@"xuexiInfoArray"];//学习信息
    
    
    self.basicInfoArray = [HXPersonalInforModel mj_objectArrayWithKeyValuesArray:array1];
    self.xuexiInfoArray = [HXPersonalInforModel mj_objectArrayWithKeyValuesArray:array2];
    
    [self.mainTableView reloadData];
}

#pragma mark - Event
-(void)popBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showXinXiYouWuShowView{
    HXXinXiYouWuShowView *xinXiYouWuShowView = [[HXXinXiYouWuShowView alloc] init];
    [xinXiYouWuShowView show];
}

#pragma mark - <UIScrollViewDelegate>根据滑动距离来变化导航栏背景色的alpha
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
    CGFloat y = scrollView.contentOffset.y;
    CGFloat alpha =(y*1.0)/kNavigationBarHeight;
    self.navBarView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, alpha);
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?self.basicInfoArray.count:self.xuexiInfoArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==1?60:0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
        view.backgroundColor = UIColor.whiteColor;
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = HXBoldFont(17);
        titleLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        titleLabel.text = @"学习信息";
        [view addSubview:titleLabel];
        titleLabel.sd_layout
        .bottomSpaceToView(view, 10)
        .leftSpaceToView(view, 20)
        .rightSpaceToView(view, 20)
        .heightIs(24);
        return view;
    }else{
        return nil;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HXPersonalInforModel *personalInforModel =(indexPath.section==0?self.basicInfoArray[indexPath.row]:self.xuexiInfoArray[indexPath.row]);
    CGFloat rowHeight = [tableView cellHeightForIndexPath:indexPath
                                                    model:personalInforModel keyPath:@"personalInforModel"
                                                cellClass:([HXPersonalInforCell class])
                                         contentViewWidth:kScreenWidth];
    return rowHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *personalInforCellIdentifier = @"HXPersonalInforCellIdentifier";
    HXPersonalInforCell *cell = [tableView dequeueReusableCellWithIdentifier:personalInforCellIdentifier];
    if (!cell) {
        cell = [[HXPersonalInforCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:personalInforCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HXPersonalInforModel *personalInforModel =(indexPath.section==0?self.basicInfoArray[indexPath.row]:self.xuexiInfoArray[indexPath.row]);
    cell.personalInforModel = personalInforModel;
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UI
-(void)createUI{
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.navBarView];
    
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.backBtn];
    
    self.navBarView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(kNavigationBarHeight);
    
    self.titleLabel.sd_layout
    .topSpaceToView(self.navBarView, kStatusBarHeight)
    .centerXEqualToView(self.navBarView)
    .widthIs(100)
    .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.backBtn.sd_layout
    .centerYEqualToView(self.titleLabel)
    .leftEqualToView(self.navBarView)
    .widthIs(60)
    .heightIs(44);
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.view, 0);
    
}

#pragma mark - LazyLoad
-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc] init];
        _navBarView.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 0);
    }
    return _navBarView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HXBoldFont(17);
        _titleLabel.textColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
        _titleLabel.text = @"个人信息";
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


-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.bounces = NO;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
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
        _mainTableView.tableHeaderView = self.tableHeaderView;
        _mainTableView.tableFooterView = self.tableFooterView;
        _mainTableView.showsVerticalScrollIndicator = NO;
       
    }
    return _mainTableView;
}

-(UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] init];
        _tableHeaderView.sd_layout.widthIs(kScreenWidth);
        [_tableHeaderView addSubview:self.topBgImageView];
        [_tableHeaderView addSubview:self.containerView];
        [_tableHeaderView addSubview:self.headImageView];
        [self.containerView addSubview:self.basicInforLabel];
       
        
        self.topBgImageView.sd_layout
        .topSpaceToView(_tableHeaderView, 0)
        .leftEqualToView(_tableHeaderView)
        .rightEqualToView(_tableHeaderView)
        .heightIs(183);
        
        self.containerView.sd_layout
        .topSpaceToView(_tableHeaderView, 160)
        .leftEqualToView(_tableHeaderView)
        .rightEqualToView(_tableHeaderView)
        .heightIs(90);
        [self.containerView updateLayout];
        
        self.headImageView.sd_layout
        .centerXEqualToView(_tableHeaderView)
        .topEqualToView(self.containerView).offset(-40)
        .widthIs(80)
        .heightEqualToWidth();
        self.headImageView.sd_cornerRadiusFromHeightRatio = @0.5;
        
        self.basicInforLabel.sd_layout
        .bottomSpaceToView(self.containerView, 20)
        .leftSpaceToView(self.containerView, 20)
        .rightSpaceToView(self.containerView, 20)
        .heightIs(24);
       
        
        // 左上和右上为圆角
        UIBezierPath *cornerRadiusPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(17, 17)];
        CAShapeLayer *cornerRadiusLayer = [ [CAShapeLayer alloc ] init];
        cornerRadiusLayer.frame = self.containerView.bounds;
        cornerRadiusLayer.path = cornerRadiusPath.CGPath;
        self.containerView.layer.mask = cornerRadiusLayer;
        
        // 模糊
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualView.layer.cornerRadius = 8;
        visualView.frame = self.containerView.bounds;
        [self.containerView addSubview:visualView];
        [self.containerView insertSubview:visualView belowSubview:self.basicInforLabel];
       
    
        [_tableHeaderView setupAutoHeightWithBottomView:self.containerView bottomMargin:0];
        
        [_tableHeaderView setNeedsLayout];
        [_tableHeaderView layoutIfNeeded];
    }
    return _tableHeaderView;
}

-(UIImageView *)topBgImageView{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.clipsToBounds = YES;
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.image = [UIImage imageNamed:@"personalinforbg_icon"];
    }
    return _topBgImageView;
}



-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.clipsToBounds = YES;
        _containerView.layer.borderWidth = 1;
        _containerView.layer.borderColor = UIColor.whiteColor.CGColor;
        _containerView.backgroundColor =COLOR_WITH_ALPHA(0xFFFFFF, 0.3);
    }
    return _containerView;
}

-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.layer.borderWidth = 2;
        _headImageView.layer.borderColor = UIColor.whiteColor.CGColor;
        _headImageView.image = [UIImage imageNamed:@"defaulthead_icon"];
    }
    return _headImageView;
}

-(UILabel *)basicInforLabel{
    if (!_basicInforLabel) {
        _basicInforLabel = [[UILabel alloc] init];
        _basicInforLabel.textAlignment = NSTextAlignmentLeft;
        _basicInforLabel.font = HXBoldFont(17);
        _basicInforLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _basicInforLabel.text = @"基础信息";
    }
    return _basicInforLabel;
}



-(UIView *)tableFooterView{
    if (!_tableFooterView) {
        _tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        _tableFooterView.backgroundColor=UIColor.whiteColor;
        _tableFooterView.clipsToBounds = YES;
        [_tableFooterView addSubview:self.xinXiWuWuBtn];
        [_tableFooterView addSubview:self.xinXiYouWuBtn];
        
       self.xinXiYouWuBtn.sd_layout
        .topSpaceToView(_tableFooterView, 30)
        .leftSpaceToView(_tableFooterView, _kpw(63))
        .widthIs(113)
        .heightIs(36);
        self.xinXiYouWuBtn.sd_cornerRadiusFromHeightRatio=@0.5;
        
        self.xinXiWuWuBtn.sd_layout
         .centerYEqualToView(self.xinXiYouWuBtn)
         .rightSpaceToView(_tableFooterView, _kpw(63))
         .widthRatioToView(self.xinXiYouWuBtn, 1)
         .heightRatioToView(self.xinXiYouWuBtn, 1);
         self.xinXiWuWuBtn.sd_cornerRadiusFromHeightRatio=@0.5;
    
    }
    return _tableFooterView;
}

-(UIButton *)xinXiYouWuBtn{
    if (!_xinXiYouWuBtn) {
        _xinXiYouWuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _xinXiYouWuBtn.titleLabel.font = HXBoldFont(14);
        _xinXiYouWuBtn.backgroundColor= UIColor.whiteColor;
        _xinXiYouWuBtn.layer.borderWidth =1;
        _xinXiYouWuBtn.layer.borderColor =COLOR_WITH_ALPHA(0x2E5BFD, 1).CGColor;
        [_xinXiYouWuBtn setTitleColor:COLOR_WITH_ALPHA(0x2E5BFD, 1) forState:UIControlStateNormal];
        [_xinXiYouWuBtn setTitle:@"信息有误" forState:UIControlStateNormal];
        [_xinXiYouWuBtn setImage:[UIImage imageNamed:@"dacha_icon"] forState:UIControlStateNormal];
        [_xinXiYouWuBtn addTarget:self action:@selector(showXinXiYouWuShowView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _xinXiYouWuBtn;
}

-(UIButton *)xinXiWuWuBtn{
    if (!_xinXiWuWuBtn) {
        _xinXiWuWuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _xinXiWuWuBtn.titleLabel.font = HXBoldFont(14);
        _xinXiWuWuBtn.backgroundColor= COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_xinXiWuWuBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_xinXiWuWuBtn setTitle:@"信息无误" forState:UIControlStateNormal];
        [_xinXiWuWuBtn setImage:[UIImage imageNamed:@"dagou_icon"] forState:UIControlStateNormal];
    }
    return _xinXiWuWuBtn;
}


@end
