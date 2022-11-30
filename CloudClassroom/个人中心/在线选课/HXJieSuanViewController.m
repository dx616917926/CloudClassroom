//
//  HXJieSuanViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import "HXJieSuanViewController.h"
#import "HXJieSuanCell.h"
#import "WXApi.h"
# import <AlipaySDK/AlipaySDK.h>

@interface HXJieSuanViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *mainTableView;
//可选的支付方式 在线支付方式选择（0：支付宝+微信 1支付宝 2微信 3银联）
@property(nonatomic,strong) UIView *btnContainerView;
//支付宝
@property(nonatomic,strong) UIButton *aliPayBtn;
@property(nonatomic,strong) UIImageView *aliPayIcon;
@property(nonatomic,strong) UIView *lineView1;
//微信
@property(nonatomic,strong) UIButton *weChatPayBtn;
@property(nonatomic,strong) UIImageView *weChatPayIcon;
@property(nonatomic,strong) UIView *lineView2;
//银联
@property(nonatomic,strong) UIButton *unionPayBtn;
@property(nonatomic,strong) UIImageView *unionPayIcon;

@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIView *lineView;
@property(nonatomic,strong) UILabel *selectNumLabel;
@property(nonatomic,strong) UILabel *heJiLabel;
@property(nonatomic,strong) UILabel *totalPriceLabel;
@property(nonatomic,strong) UIButton *payBtn;

@property(nonatomic,strong) UIButton *selectPayMethodBtn;

@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,assign) NSInteger payType;

@end

@implementation HXJieSuanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.payType = 0;
    //UI
    [self createUI];
}
#pragma mark - Setter
-(void)setJieSuanModel:(HXCourseJieSuanModel *)jieSuanModel{
    _jieSuanModel = jieSuanModel;
    
}


#pragma mark - Event
-(void)selectPayMethod:(UIButton *)sender{
    
    NSInteger tag = sender.tag;
    self.payType = tag-1000;
    if (self.selectPayMethodBtn==sender) {
        return;
    }
    self.selectPayMethodBtn.selected = NO;
    sender.selected = YES;
    self.selectPayMethodBtn = sender;
    
}

//去支付
-(void)pay:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    if (self.payType==0) {
        [self.view showTostWithMessage:@"请选择支付方式"];
        sender.userInteractionEnabled = YES;
        return;
    }
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    NSDictionary *dic =@{
        @"studentid":HXSafeString(studentId),
        @"orderno":HXSafeString(self.jieSuanModel.orderNo),
        @"payType":@(self.payType),//1支付宝 2微信 3银联
        @"revision":@(1)//终端 PC=0 APP = 1 H5=2
    };
    [self.view showLoading];
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_CourseOrderPay needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        sender.userInteractionEnabled = YES;
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            NSLog(@"支付参数%@",dictionary);
            if (self.payType==1) {//支付宝支付
                [self aliPay:[dictionary stringValueForKey:@"data"]];
            }else if (self.payType==2) {//微信支付
                [self weiXinPay:[dictionary dictionaryValueForKey:@"data"]];
            }
            
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view hideLoading];
        sender.userInteractionEnabled = YES;
    }];
    
    
    
}

#pragma mark - 支付宝支付
-(void)aliPay:(NSString *)orderStr{
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderStr fromScheme:APPScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
    }];
    
}
#pragma mark - 微信支付
-(void)weiXinPay:(NSDictionary *)dic{
    if (![WXApi isWXAppInstalled]) {
        [self.view showTostWithMessage:@"未安装微信"];
    }
    PayReq *request = [[PayReq alloc] init] ;
    request.partnerId = [dic stringValueForKey:@"partnerid"];
    request.prepayId= [dic stringValueForKey:@"prepayid"];
    request.package = @"Sign=WXPay";
    request.nonceStr= [dic stringValueForKey:@"noncestr"];
    request.timeStamp = [[dic stringValueForKey:@"timestamp"] intValue];
    request.sign= [dic stringValueForKey:@"sign"];
    [WXApi sendReq:request completion:^(BOOL success) {
        NSLog(@"%d",success);
    }];
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
    static NSString *jieSuanCellIdentifier = @"HXJieSuanCellIdentifier";
    HXJieSuanCell *cell = [tableView dequeueReusableCellWithIdentifier:jieSuanCellIdentifier];
    if (!cell) {
        cell = [[HXJieSuanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jieSuanCellIdentifier];
    }
    cell.isFirst = (indexPath.row==0);
    cell.isLast = (indexPath.row==self.dataArray.count-1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.isHaveXueQi = self.isHaveXueQi;
    //fromFalg 1:在线选课  2:财务缴费
    if (self.jieSuanModel.fromFalg==1) {
        cell.orderDetailInfoModel = self.dataArray[indexPath.row];
    }else if (self.jieSuanModel.fromFalg==2) {
        cell.feeDetailInfoModel = self.dataArray[indexPath.row];
    }
   
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
    
    //支付宝
    [self.btnContainerView addSubview:self.aliPayBtn];
    [self.aliPayBtn addSubview:self.aliPayIcon];
    
    [self.btnContainerView addSubview:self.lineView1];
    //微信
    [self.btnContainerView addSubview:self.weChatPayBtn];
    [self.weChatPayBtn addSubview:self.weChatPayIcon];
    
    [self.btnContainerView addSubview:self.lineView2];
    //银联
    [self.btnContainerView addSubview:self.unionPayBtn];
    [self.unionPayBtn addSubview:self.unionPayIcon];
    
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
    
    //支付宝
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
    
    self.lineView1.sd_layout
        .topSpaceToView(self.aliPayBtn, 0)
        .leftSpaceToView(self.btnContainerView, 28)
        .rightSpaceToView(self.btnContainerView, 28)
        .heightIs(0.5);
    
    //微信
    self.weChatPayBtn.sd_layout
        .topSpaceToView(self.lineView1, 0)
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
    
    self.lineView2.sd_layout
        .topSpaceToView(self.weChatPayBtn, 0)
        .leftSpaceToView(self.btnContainerView, 28)
        .rightSpaceToView(self.btnContainerView, 28)
        .heightIs(0.5);
    
    //银联
    self.unionPayBtn.sd_layout
        .topSpaceToView(self.lineView2, 0)
        .leftEqualToView(self.btnContainerView)
        .rightEqualToView(self.btnContainerView)
        .heightIs(54);
    
    self.unionPayBtn.imageView.sd_layout
        .centerYEqualToView(self.unionPayBtn)
        .rightSpaceToView(self.unionPayBtn, 28)
        .widthIs(22)
        .heightEqualToWidth();
    
    self.unionPayBtn.titleLabel.sd_layout
        .centerYEqualToView(self.unionPayBtn)
        .leftSpaceToView(self.unionPayBtn, 56)
        .widthIs(100)
        .heightIs(21);
    
    self.unionPayIcon.sd_layout
        .centerYEqualToView(self.unionPayBtn)
        .leftSpaceToView(self.unionPayBtn, 28)
        .widthIs(20)
        .heightIs(12);
    
    [self.btnContainerView setupAutoHeightWithBottomView:self.unionPayBtn bottomMargin:0];
    
    self.mainTableView.sd_layout
        .topSpaceToView(self.view, kNavigationBarHeight)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .bottomSpaceToView(self.btnContainerView, 0);
    
    
    ///可选的支付方式 在线支付方式选择（0：支付宝+微信   1支付宝    2微信   3银联）
    if (self.jieSuanModel.payType==0) {
        self.aliPayBtn.sd_layout.heightIs(54);
        self.lineView1.sd_layout.heightIs(0.5);
        self.weChatPayBtn.sd_layout.heightIs(54);
        self.lineView2.sd_layout.heightIs(0);
        self.unionPayBtn.sd_layout.heightIs(0);
    }else if (self.jieSuanModel.payType==1) {
        self.aliPayBtn.sd_layout.heightIs(54);
        self.lineView1.sd_layout.heightIs(0);
        self.weChatPayBtn.sd_layout.heightIs(0);
        self.lineView2.sd_layout.heightIs(0);
        self.unionPayBtn.sd_layout.heightIs(0);
    }else if (self.jieSuanModel.payType==2) {
        self.aliPayBtn.sd_layout.heightIs(0);
        self.lineView1.sd_layout.heightIs(0);
        self.weChatPayBtn.sd_layout.heightIs(54);
        self.lineView2.sd_layout.heightIs(0);
        self.unionPayBtn.sd_layout.heightIs(0);
    }else if (self.jieSuanModel.payType==3) {
        self.aliPayBtn.sd_layout.heightIs(0);
        self.lineView1.sd_layout.heightIs(0);
        self.weChatPayBtn.sd_layout.heightIs(0);
        self.lineView2.sd_layout.heightIs(0.5);
        self.unionPayBtn.sd_layout.heightIs(54);
    }
    [self.btnContainerView updateLayout];
    
    [self.dataArray removeAllObjects];
    
    //fromFalg 1:在线选课  2:财务缴费
    if (self.jieSuanModel.fromFalg==1) {
        [self.dataArray addObjectsFromArray:self.jieSuanModel.courseInfo];
    }else if (self.jieSuanModel.fromFalg==1) {
        [self.dataArray addObjectsFromArray:self.jieSuanModel.feeInfo];
    }

    //计算合计
    __block CGFloat total = 0.00;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.jieSuanModel.fromFalg==1) {
            HXOrderDetailInfoModel *model = obj;
            total+=model.price;
        }else if (self.jieSuanModel.fromFalg==2) {
            HXFeeDetailInfoModel *model = obj;
            total+=model.price;
        }
    }];
    
    NSString *content = [NSString stringWithFormat:@"￥%.2f",total];
    NSArray *tempArray = [HXFloatToString(total) componentsSeparatedByString:@"."];
    NSString *needStr = [tempArray.firstObject stringByAppendingString:@"."];
    self.totalPriceLabel.attributedText = [HXCommonUtil getAttributedStringWith:needStr needAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} content:content defaultAttributed:@{NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0xED4F4F, 1),NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    
    self.selectNumLabel.text = [NSString stringWithFormat:@"共%lu个",(unsigned long)self.dataArray.count];
    
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

- (UIView *)lineView1{
    if (!_lineView1) {
        _lineView1 = [[UIView alloc] init];
        _lineView1.backgroundColor = COLOR_WITH_ALPHA(0xEDEDED, 1);
    }
    return _lineView1;
}

- (UIButton *)aliPayBtn{
    if (!_aliPayBtn) {
        _aliPayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _aliPayBtn.clipsToBounds = YES;
        _aliPayBtn.tag = 1001;
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
        _weChatPayBtn.clipsToBounds = YES;
        _weChatPayBtn.tag = 1002;
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

- (UIView *)lineView2{
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = COLOR_WITH_ALPHA(0xEDEDED, 1);
    }
    return _lineView2;
}

- (UIButton *)unionPayBtn{
    if (!_unionPayBtn) {
        _unionPayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _unionPayBtn.clipsToBounds = YES;
        _unionPayBtn.tag = 1003;
        _unionPayBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        _unionPayBtn.titleLabel.font = HXBoldFont(15);
        [_unionPayBtn setTitleColor:COLOR_WITH_ALPHA(0x333333, 1) forState:UIControlStateNormal];
        [_unionPayBtn setTitle:@"银联" forState:UIControlStateNormal];
        [_unionPayBtn setImage:[UIImage imageNamed:@"noselect_icon"] forState:UIControlStateNormal];
        [_unionPayBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        [_unionPayBtn addTarget:self action:@selector(selectPayMethod:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unionPayBtn;
}

-(UIImageView *)unionPayIcon{
    if (!_unionPayIcon) {
        _unionPayIcon = [[UIImageView alloc] init];
        _unionPayIcon.userInteractionEnabled = YES;
        _unionPayIcon.image = [UIImage imageNamed:@"unionpay_icon"];
    }
    return _unionPayIcon;
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
    }
    return _totalPriceLabel;
}


- (UILabel *)selectNumLabel{
    if (!_selectNumLabel) {
        _selectNumLabel = [[UILabel alloc] init];
        _selectNumLabel.textAlignment = NSTextAlignmentLeft;
        _selectNumLabel.font = HXFont(12);
        _selectNumLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        
    }
    return _selectNumLabel;
}


@end


