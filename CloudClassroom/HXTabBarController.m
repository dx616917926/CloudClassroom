//
//  HXTabBarController.m
//  HXMinedu
//
//  Created by Mac on 2020/10/30.
//

#import "HXTabBarController.h"
#import "HXHomePageViewController.h"//首页
#import "HXLearnCenterViewController.h"//学习中心
#import "HXPersonalCenterViewController.h"//个人中心
#import "HXLoginViewController.h"

@interface HXTabBarController ()<UITabBarControllerDelegate>
{
    BOOL notControlRotate;
}
@property(nonatomic, strong) NSMutableArray *rootArray;

@end

@implementation HXTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [HXNotificationCenter addObserver:self selector:@selector(showLogin) name:SHOWLOGIN object:nil];

    self.rootArray = [[NSMutableArray alloc] init];
    self.tabBar.tintColor = [UIColor blackColor];
    self.delegate = self;
}

-(void)dealloc{
    [HXNotificationCenter removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    notControlRotate = YES;
}

- (void)showLogin{
    
    //重置选择，默认选择第一个
    if ([self.selectedViewController isKindOfClass:[HXNavigationController class]]) {
        HXNavigationController *nav = self.selectedViewController;
        [nav popToRootViewControllerAnimated:NO];
        NSLog(@"%@",nav);
        self.selectedIndex = 0;
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

- (void)viewWillLayoutSubviews
{
    if (self.viewControllers == nil) {
        //初始化TabBar -- 必须等屏幕旋转完毕之后再调用，否则获取的kScreenHeight值不正确⚠️
        [self setUpTabBarItems];
    }
}

- (void)setUpTabBarItems{
    [self.rootArray removeAllObjects];
    [self setViewControllers:self.rootArray];
    
    //首页
    HXHomePageViewController *homePage = [HXHomePageViewController new];
    homePage.sc_navigationBarHidden = YES;//隐藏导航栏
    HXNavigationController *homePageNav = [[HXNavigationController alloc] initWithRootViewController:homePage];
    homePageNav.tabBarItem.title = @"首页";
    homePageNav.tabBarItem.image = [UIImage getOriImage:@"tabbar_0"];
    homePageNav.tabBarItem.selectedImage = [UIImage getOriImage:@"tabbarSelect_0"];
    
    //学习中心
    HXLearnCenterViewController *study = [HXLearnCenterViewController new];
    HXNavigationController *studyNav = [[HXNavigationController alloc] initWithRootViewController:study];
    studyNav.tabBarItem.title = @"学习中心";
    studyNav.tabBarItem.image = [UIImage getOriImage:@"tabbar_1"];
    studyNav.tabBarItem.selectedImage = [UIImage getOriImage:@"tabbarSelect_1"];
    


    //个人中心
    HXPersonalCenterViewController *personal = [HXPersonalCenterViewController new];
    personal.sc_navigationBarHidden = YES;//隐藏导航栏
    HXNavigationController *personalNav = [[HXNavigationController alloc] initWithRootViewController:personal];
    personalNav.tabBarItem.title = @"个人中心";
    personalNav.tabBarItem.image = [UIImage getOriImage:@"tabbar_4"];
    personalNav.tabBarItem.selectedImage = [UIImage getOriImage:@"tabbarSelectImage_4"];

    [self.rootArray addObjectsFromArray:@[homePageNav,studyNav,personalNav]];
    [self setViewControllers:self.rootArray];
    
    
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = COLOR_WITH_ALPHA(0x5E6065, 1);
    textAttrs[NSFontAttributeName] =  [UIFont fontWithName:@"PingFang SC" size:14.0f];
    
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = COLOR_WITH_ALPHA(0x5E6065, 1);
    selectTextAttrs[NSFontAttributeName] = [UIFont fontWithName:@"PingFang SC" size:14.0f];
    
    [[UITabBarItem appearance] setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
//    [self.tabBar setTintColor:UIColor.whiteColor];
    [self.tabBar setBarTintColor:[UIColor whiteColor]];


    

}


//#pragma mark - <UITabBarControllerDelegate>
//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//        CGFloat offset = _kpw(5)+(IS_iPhoneX?3:0);
//        if ([tabBarController.selectedViewController.tabBarItem.title isEqualToString:@"我的"]) {
//            for (UITabBarItem *item in self.tabBar.items) {
//                if ([item.title isEqualToString:@"我的"]) {
//                    item.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
//                    item.titlePositionAdjustment = UIOffsetMake(0, 100);
//                }
//            }
//        }else{
//            for (UITabBarItem *item in self.tabBar.items) {
//                if ([item.title isEqualToString:@"我的"]) {
//                    item.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//                    item.titlePositionAdjustment = UIOffsetMake(0, 0);
//                }
//            }
//        }
//}

- (BOOL)shouldAutorotate
{
    if (!notControlRotate) {
        return YES;
    }
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if (!notControlRotate) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return [self.selectedViewController supportedInterfaceOrientations];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
