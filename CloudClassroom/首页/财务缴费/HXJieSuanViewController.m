//
//  HXJieSuanViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import "HXJieSuanViewController.h"
#import "HXJieSuanCell.h"



@interface HXJieSuanViewController ()<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong) UITableView *mainTableView;

@property(nonatomic,strong) UIView *btnContainerView;
@property(nonatomic,strong) UIButton *aliPayBtn;
@property(nonatomic,strong) UIImageView *aliPayIcon;
@property(nonatomic,strong) UIView *fenGeLineView;
@property(nonatomic,strong) UIButton *weChatPayBtn;
@property(nonatomic,strong) UIImageView *weChatPayIcon;

@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIView *lineView;
@property(nonatomic,strong) UILabel *selectNumLabel;
@property(nonatomic,strong) UILabel *heJiLabel;
@property(nonatomic,strong) UILabel *totalPriceLabel;
@property(nonatomic,strong) UIButton *payBtn;

@property(nonatomic,strong) UIButton *selectPayMethodBtn;

@end

@implementation HXJieSuanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UI
    [self createUI];
}


#pragma mark - Event
-(void)selectPayMethod:(UIButton *)sender{
    
    if (self.selectPayMethodBtn==sender) {
        return;
    }
    self.selectPayMethodBtn.selected = NO;
    sender.selected = YES;
    self.selectPayMethodBtn = sender;
}

//去支付
-(void)pay:(UIButton *)sender{
    
}



#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *jieSuanCellIdentifier = @"HXJieSuanCellIdentifier";
    HXJieSuanCell *cell = [tableView dequeueReusableCellWithIdentifier:jieSuanCellIdentifier];
    if (!cell) {
        cell = [[HXJieSuanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jieSuanCellIdentifier];
    }
    cell.isFirst = (indexPath.row==0);
    cell.isLast = (indexPath.row==4);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.isHaveXueQi = self.isHaveXueQi;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UI
-(void)createUI{
    
    self.sc_navigationBar.title = @"确认结算";
    
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.btnContainerView];
    
    [self.bottomView addSubview:self.lineView];
    [self.bottomView addSubview:self.selectNumLabel];
    [self.bottomView addSubview:self.heJiLabel];
    [self.bottomView addSubview:self.totalPriceLabel];
    [self.bottomView addSubview:self.payBtn];
   
    [self.btnContainerView addSubview:self.aliPayBtn];
    [self.aliPayBtn addSubview:self.aliPayIcon];
    
    [self.btnContainerView addSubview:self.fenGeLineView];
    
    [self.btnContainerView addSubview:self.weChatPayBtn];
    [self.weChatPayBtn addSubview:self.weChatPayIcon];
    
    self.bottomView.sd_layout
    .bottomEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .heightIs(80);
    
    self.lineView.sd_layout
    .topEqualToView(self.bottomView)
    .leftEqualToView(self.bottomView)
    .rightEqualToView(self.bottomView)
    .heightIs(0.5);
    
    self.payBtn.sd_layout
    .centerYEqualToView(self.bottomView).offset(-10)
    .rightSpaceToView(self.bottomView, 16)
    .widthIs(100)
    .heightIs(40);
    self.payBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    

    self.totalPriceLabel.sd_layout
    .centerYEqualToView(self.payBtn)
    .rightSpaceToView(self.payBtn, 17)
    .heightIs(20);
    
    [self.totalPriceLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    self.heJiLabel.sd_layout
    .centerYEqualToView(self.totalPriceLabel)
    .rightSpaceToView(self.totalPriceLabel, 0)
    .widthIs(30)
    .heightIs(17);
    
    self.selectNumLabel.sd_layout
    .centerYEqualToView(self.totalPriceLabel)
    .rightSpaceToView(self.heJiLabel, 20)
    .leftSpaceToView(self.bottomView, 20)
    .heightIs(17);
    
    
    self.btnContainerView.sd_layout
    .bottomSpaceToView(self.bottomView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view);
    
    self.aliPayBtn.sd_layout
    .topSpaceToView(self.btnContainerView, 0)
    .leftEqualToView(self.btnContainerView)
    .rightEqualToView(self.btnContainerView)
    .heightIs(54);
    
    self.aliPayBtn.imageView.sd_layout
    .centerYEqualToView(self.aliPayBtn)
    .rightSpaceToView(self.aliPayBtn, 28)
    .widthIs(22)
    .heightEqualToWidth();
    
    self.aliPayBtn.titleLabel.sd_layout
    .centerYEqualToView(self.aliPayBtn)
    .leftSpaceToView(self.aliPayBtn, 56)
    .widthIs(100)
    .heightIs(21);
    
    self.aliPayIcon.sd_layout
    .centerYEqualToView(self.aliPayBtn)
    .leftSpaceToView(self.aliPayBtn, 28)
    .widthIs(18)
    .heightEqualToWidth();
    
    self.fenGeLineView.sd_layout
    .topSpaceToView(self.aliPayBtn, 0)
    .leftSpaceToView(self.btnContainerView, 28)
    .rightSpaceToView(self.btnContainerView, 28)
    .heightIs(0.5);
    
    self.weChatPayBtn.sd_layout
    .topSpaceToView(self.fenGeLineView, 0)
    .leftEqualToView(self.btnContainerView)
    .rightEqualToView(self.btnContainerView)
    .heightIs(54);
    
    self.weChatPayBtn.imageView.sd_layout
    .centerYEqualToView(self.weChatPayBtn)
    .rightSpaceToView(self.weChatPayBtn, 28)
    .widthIs(22)
    .heightEqualToWidth();
    
    self.weChatPayBtn.titleLabel.sd_layout
    .centerYEqualToView(self.weChatPayBtn)
    .leftSpaceToView(self.weChatPayBtn, 56)
    .widthIs(100)
    .heightIs(21);
    
    self.weChatPayIcon.sd_layout
    .centerYEqualToView(self.weChatPayBtn)
    .leftSpaceToView(self.weChatPayBtn, 28)
    .widthIs(18)
    .heightEqualToWidth();

    [self.btnContainerView setupAutoHeightWithBottomView:self.weChatPayBtn bottomMargin:0];
    
    self.mainTableView.sd_layout
    .topSpaceToView(self.view, kNavigationBarHeight)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomSpaceToView(self.btnContainerView, 0);
    
}

#pragma mark -LazyLoad

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
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 16)];
        _mainTableView.tableHeaderView =tableHeaderView;
    }
    return _mainTableView;
}

- (UIView *)btnContainerView{
    if (!_btnContainerView) {
        _btnContainerView = [[UIView alloc] init];
        _btnContainerView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _btnContainerView;
}

- (UIView *)fenGeLineView{
    if (!_fenGeLineView) {
        _fenGeLineView = [[UIView alloc] init];
        _fenGeLineView.backgroundColor = COLOR_WITH_ALPHA(0xEDEDED, 1);
    }
    return _fenGeLineView;
}

- (UIButton *)aliPayBtn{
    if (!_aliPayBtn) {
        _aliPayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _aliPayBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        _aliPayBtn.titleLabel.font = HXBoldFont(15);
        [_aliPayBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_aliPayBtn setTitle:@"支付宝" forState:UIControlStateNormal];
        [_aliPayBtn setImage:[UIImage imageNamed:@"noselect_icon"] forState:UIControlStateNormal];
        [_aliPayBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        [_aliPayBtn addTarget:self action:@selector(selectPayMethod:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _aliPayBtn;
}

-(UIImageView *)aliPayIcon{
    if (!_aliPayIcon) {
        _aliPayIcon = [[UIImageView alloc] init];
        _aliPayIcon.userInteractionEnabled = YES;
        _aliPayIcon.image = [UIImage imageNamed:@"alipay_icon"];
    }
    return _aliPayIcon;
}

- (UIButton *)weChatPayBtn{
    if (!_weChatPayBtn) {
        _weChatPayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _weChatPayBtn.titleLabel.font = HXBoldFont(15);
        [_weChatPayBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_weChatPayBtn setTitle:@"微信" forState:UIControlStateNormal];
        [_weChatPayBtn setImage:[UIImage imageNamed:@"noselect_icon"] forState:UIControlStateNormal];
        [_weChatPayBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        [_weChatPayBtn addTarget:self action:@selector(selectPayMethod:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weChatPayBtn;
}

-(UIImageView *)weChatPayIcon{
    if (!_weChatPayIcon) {
        _weChatPayIcon = [[UIImageView alloc] init];
        _weChatPayIcon.userInteractionEnabled = YES;
        _weChatPayIcon.image = [UIImage imageNamed:@"wechatpay_icon"];
    }
    return _weChatPayIcon;
}



- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _bottomView;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = COLOR_WITH_ALPHA(0xEDEDED, 1);
    }
    return _lineView;
}


- (UIButton *)payBtn{
    if (!_payBtn) {
        _payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _payBtn.titleLabel.font = HXBoldFont(15);
        _payBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_payBtn setTitleColor:COLOR_WITH_ALPHA(0xFFFFFF, 1) forState:UIControlStateNormal];
        [_payBtn setTitle:@"去支付" forState:UIControlStateNormal];
        [_payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payBtn;
}


- (UILabel *)heJiLabel{
    if (!_heJiLabel) {
        _heJiLabel = [[UILabel alloc] init];
        _heJiLabel.textAlignment = NSTextAlignmentRight;
        _heJiLabel.font = HXFont(12);
        _heJiLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _heJiLabel.text = @"合计:";
    }
    return _heJiLabel;
}

- (UILabel *)totalPriceLabel{
    if (!_totalPriceLabel) {
        _totalPriceLabel = [[UILabel alloc] init];
        _totalPriceLabel.font = HXBoldFont(14);
        _totalPriceLabel.textColor = COLOR_WITH_ALPHA(0xED4F4F, 1);
        _totalPriceLabel.textAlignment = NSTextAlignmentRight;
        _totalPriceLabel.isAttributedContent = YES;
        _totalPriceLabel.attributedText = [HXCommonUtil getAttributedStringWith:@"100." needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:@"￥100.00" defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    }
    return _totalPriceLabel;
}


- (UILabel *)selectNumLabel{
    if (!_selectNumLabel) {
        _selectNumLabel = [[UILabel alloc] init];
        _selectNumLabel.textAlignment = NSTextAlignmentLeft;
        _selectNumLabel.font = HXFont(12);
        _selectNumLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _selectNumLabel.text = @"共2个";
    }
    return _selectNumLabel;
}


@end


