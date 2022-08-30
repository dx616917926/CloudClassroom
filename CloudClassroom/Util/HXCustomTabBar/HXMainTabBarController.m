//
//  HXMainTabBarController.m
//  HXXiaoGuan
//
//  Created by mac on 2021/5/31.
//

#import "HXMainTabBarController.h"
#import "HXMainTabBar.h"
#import "HXHomePageViewController.h"//首页
#import "HXLearnCenterViewController.h"//学习中心
#import "HXPersonalCenterViewController.h"//个人中心
#import "HXLoginViewController.h"
#import "AppDelegate.h"
@interface HXMainTabBarController ()

@property(nonatomic,strong) HXMainTabBar *mainTabBar;

@end



@implementation HXMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //强制竖屏，防止横屏启动时，界面横屏导致布局错乱
    [self forcedPortrait];
    
    [HXNotificationCenter addObserver:self selector:@selector(showLogin) name:SHOWLOGIN object:nil];
    [self setUpChildVC];
    [self setValue:self.mainTabBar forKey:@"tabBar"];
    
}

#pragma mark - 强制竖屏，防止横屏启动时，界面横屏导致布局错乱
-(void)forcedPortrait{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    //强制竖屏：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - 重新登陆
- (void)showLogin{
    
    //重置选择，默认选择第一个
    if ([self.selectedViewController isKindOfClass:[HXNavigationController class]]) {
        HXNavigationController *nav = self.selectedViewController;
        [nav popToRootViewControllerAnimated:NO];
        NSLog(@"%@",nav);
        [self setTabIndex:0];
    }
    //删除用户名密码
    [[HXPublicParamTool sharedInstance] logOut];
    //删除cookies
    [[HXBaseURLSessionManager sharedClient] clearCookies];
    //登录页面
    HXLoginViewController *loginVC = [[HXLoginViewController alloc]init];
    loginVC.sc_navigationBarHidden = YES;
    HXNavigationController *navVC = [[HXNavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}


-(void)setUpChildVC{
    //首页
    HXHomePageViewController *homePage = [HXHomePageViewController new];
    homePage.sc_navigationBarHidden = YES;//隐藏导航栏
    HXNavigationController *homePageNav = [[HXNavigationController alloc] initWithRootViewController:homePage];
    [self addChildViewController:homePageNav];
    
    //学习中心
    HXLearnCenterViewController *study = [HXLearnCenterViewController new];
    HXNavigationController *studyNav = [[HXNavigationController alloc] initWithRootViewController:study];
    [self addChildViewController:studyNav];
    


    //个人中心
    HXPersonalCenterViewController *personal = [HXPersonalCenterViewController new];
    personal.sc_navigationBarHidden = YES;//隐藏导航栏
    HXNavigationController *personalNav = [[HXNavigationController alloc] initWithRootViewController:personal];
    [self addChildViewController:personalNav];
    
}

-(HXMainTabBar *)mainTabBar{
    if (!_mainTabBar) {
        NSArray *titArr = @[@"首页",@"学习中心",@"个人中心"];
        NSArray *imgArr = @[@"tabbar_0",@"tabbar_1",@"tabbar_2"];
        NSArray *sImgArr = @[@"tabbarSelect_0",@"tabbarSelect_1",@"tabbarSelect_2"];

        HXMainTabBar *mainTabBar = [[HXMainTabBar alloc]initWithTitArr:titArr imgArr:imgArr sImgArr:sImgArr];
        mainTabBar.delegate = self;
        _mainTabBar = mainTabBar;
    }
    return _mainTabBar;
}
#pragma mark -TabBar Delegate
-(void)changeIndex:(NSInteger)index{
    self.selectedIndex = index;
}


-(void)setTabIndex:(NSInteger)tabIndex{
    _tabIndex = tabIndex;
    self.selectedIndex = tabIndex;
    self.mainTabBar.tabIndex = tabIndex;
}


- (BOOL)shouldAutorotate{
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}




@end
