//
//  HXExamPromiseView.m
//  CloudClassroom
//
//  Created by mac on 2022/10/27.
//


#import "HXExamPromiseView.h"
#import <QuartzCore/CALayer.h>
#import <WebKit/WebKit.h>
#import "HXNoDataTipView.h"

@interface  HXExamPromiseView()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,assign)  NSInteger isPoint;
@property (nonatomic,assign)  NSInteger tempTime;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) UIView *backGroudView;
@property(nonatomic,strong) UIView *navBarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *closeBtn;

@property (nonatomic,strong) UIButton *sureBtn;

@property (nonatomic,strong) WKWebView *wkWebView;

@property(nonatomic, strong) UIViewController *parentViewController;

@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;



@end

@implementation HXExamPromiseView

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight)];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        //UI
        self.isPoint=0;
        self.countDown = 3;
        [self createUI];
    }
    return self;
}


#pragma mark - 退出登录
- (void)loginOut {
    [self cancleClick];
}


#pragma mark - 关闭弹框
- (void)cancleClick{
    
    self.parentViewController = nil;
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        CGPoint point = self.center;
        self.center = point;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 确定按钮
- (void)surePromiseButton{
    
    if (!self.alterUrl || self.alterUrl.count == 0 || self.isPoint == self.alterUrl.count-1) {
        [self cancleClick];
        if (self.sureSelectBlock) {
            self.sureSelectBlock();
        }
        return;
    }
    self.isPoint++;
    [self reloadWkWebView];
}

#pragma mark - timer倒计时回调
- (void)timerEvent {
    
    if (self.tempTime >= 0) {
        self.sureBtn.userInteractionEnabled = NO;
        self.sureBtn.backgroundColor = COLOR_WITH_ALPHA(0xC6C8D0, 1);
        [self.sureBtn setTitle:[NSString stringWithFormat:@"我已阅读并了解(%lds)",self.tempTime] forState:UIControlStateNormal];
    }else{
        self.sureBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        self.sureBtn.userInteractionEnabled = YES;
        [self.sureBtn setTitle:@"我已阅读并了解" forState:UIControlStateNormal];
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    self.tempTime -= 1;
}

#pragma mark - UI
-(void)createUI{
    
    [self addSubview:self.backGroudView];
    [self.backGroudView addSubview:self.navBarView];
    [self.navBarView addSubview:self.titleLabel];
    [self.navBarView addSubview:self.closeBtn];
    [self.backGroudView addSubview:self.sureBtn];
    [self.backGroudView addSubview:self.wkWebView];
    
    self.backGroudView.sd_layout
        .topEqualToView(self)
        .leftEqualToView(self)
        .rightEqualToView(self)
        .bottomEqualToView(self);
    
    
    self.navBarView.sd_layout
        .topEqualToView(self.backGroudView)
        .leftEqualToView(self.backGroudView)
        .rightEqualToView(self.backGroudView)
        .heightIs(kNavigationBarHeight);
    
    self.titleLabel.sd_layout
        .topSpaceToView(self.navBarView, kStatusBarHeight)
        .centerXEqualToView(self.navBarView)
        .widthIs(200)
        .heightIs(kNavigationBarHeight-kStatusBarHeight);
    
    self.closeBtn.sd_layout
        .centerYEqualToView(self.titleLabel)
        .leftEqualToView(self.navBarView)
        .widthIs(60)
        .heightIs(44);
    
    self.sureBtn.sd_layout
        .bottomSpaceToView(self.backGroudView, 40+kScreenBottomMargin)
        .leftSpaceToView(self.backGroudView, 70)
        .rightSpaceToView(self.backGroudView, 70)
        .heightIs(36);
    self.sureBtn.sd_cornerRadiusFromHeightRatio = @0.5;
    
    
    self.wkWebView.sd_layout
        .topSpaceToView(self.navBarView, 0)
        .leftSpaceToView(self.backGroudView, 16)
        .rightSpaceToView(self.backGroudView, 16)
        .bottomSpaceToView(self.sureBtn, 16);
    [self.wkWebView updateLayout];
    
}

#pragma mark -  加载网页内容
- (void)reloadWkWebView{
    
    if (self.alterUrl && self.alterUrl.count > 0) {
        
        NSString *url = self.alterUrl[self.isPoint];
        [self.wkWebView loadHTMLString:url baseURL:HXSafeURL([HXPublicParamTool sharedInstance].schoolDomainURL)];
        //转圈
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator setCenter:self.wkWebView.center];
        [self.wkWebView addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
        
        if (self.countDown > 0) {
            self.tempTime = self.countDown;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }else{
            self.sureBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
            self.sureBtn.userInteractionEnabled = YES;
        }
    }else{
        //设置空白界面
        HXNoDataTipView *noDataTipView= [[HXNoDataTipView alloc] initWithFrame:self.backGroudView.bounds];
        noDataTipView.tipTitle = @"页面加载失败";
        [self.backGroudView addSubview:noDataTipView];
        
        self.sureBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        self.sureBtn.userInteractionEnabled = YES;
        [self.sureBtn setTitle:@"关闭" forState:UIControlStateNormal];
    }
}

#pragma mark - 弹出
- (void)showInViewController:(UIViewController *)viewController{
    self.parentViewController = viewController;
    [self showInView:viewController.tabBarController?viewController.tabBarController.view:viewController.view];
    [self reloadWkWebView];
}

//添加弹出移除的动画效果
- (void)showInView:(UIView *)view{
    if (self.showCancelButton) {
        self.closeBtn.hidden = NO;
    }
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [view addSubview:self];
}


#pragma mark - WKWebViewDelegate

// 页面结束加载时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    [self.activityIndicator stopAnimating];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    [self.activityIndicator stopAnimating];
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


#pragma mark - LazyLoad
-(UIView *)backGroudView{
    if (!_backGroudView) {
        _backGroudView = [[UIView alloc] init];
        _backGroudView.backgroundColor = COLOR_WITH_ALPHA(0xFFFFFF, 1);
    }
    return _backGroudView;
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
        _titleLabel.text = @"提示";
    }
    return _titleLabel;
}

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"closewhite_icon"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(cancleClick) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hidden = YES;
    }
    return _closeBtn;
}

-(WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] init];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        _wkWebView.scrollView.bounces = NO;
    }
    return _wkWebView;
}

-(UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.backgroundColor = COLOR_WITH_ALPHA(0xC6C8D0, 1);
        [_sureBtn setTintColor:[UIColor whiteColor]];
        [_sureBtn setTitle:@"我已阅读并了解" forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(surePromiseButton) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.userInteractionEnabled = NO;
    }
    return _sureBtn;
}

- (void)dealloc{
    
    NSLog(@"弹出框已经释放");
    [HXNotificationCenter removeObserver:self];
}



@end
