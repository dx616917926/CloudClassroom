//
//  HXLearnCenterViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "HXLearnCenterViewController.h"
#import "HXOnlineLearnViewController.h"
#import "HXTeachPlanViewController.h"
#import "HXFaceTimeTableViewController.h"
#import "XLPageViewController.h"
#import "HXLearnCenterPageTitleCell.h"

@interface HXLearnCenterViewController ()<XLPageViewControllerDelegate,XLPageViewControllerDataSrouce>

@property (nonatomic, strong) XLPageViewController *pageViewController;

@end

@implementation HXLearnCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    [self createUI];
}

-(void)dealloc{
    ///重新初始化子视图控制器,这里会多次调用，在调用之前先移除原先的，避免多次添加
    [self.pageViewController removeFromParentViewController];
    self.pageViewController = nil;
    self.pageViewController.delegate = nil;
    self.pageViewController.dataSource = nil;
    [self.pageViewController.view removeFromSuperview];
}

#pragma mark - UI
-(void)createUI{
    self.sc_navigationBar.leftBarButtonItem = nil;
    self.sc_navigationBar.title = @"学习中心";
    //初始化控制器
    [self initPageViewController];
}

//初始化控制器
- (void)initPageViewController {
    XLPageViewControllerConfig *config = [XLPageViewControllerConfig defaultConfig];
    config.titleViewBackgroundColor = UIColor.whiteColor;
    config.titleViewHeight = 44;
    //设置标题间距
    config.titleSpace = 60;
    //设置标题栏缩进
    config.titleViewInset = UIEdgeInsetsMake(0, 20, 0, 20);
    config.titleViewAlignment = XLPageTitleViewAlignmentCenter;
    //隐藏底部分割线
    config.separatorLineHidden =NO;
    ////设置标题颜色
    config.titleSelectedColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    config.titleNormalColor = COLOR_WITH_ALPHA(0x333333, 1);;
    config.titleNormalFont = HXFont(14);
    config.titleSelectedFont =HXBoldFont(14);
    //隐藏底部阴影
    config.shadowLineHidden = true;
    self.pageViewController = [[XLPageViewController alloc] initWithConfig:config];
    self.pageViewController.view.frame =CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight-kTabBarHeight);
    self.pageViewController.bounces = NO;
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [self.pageViewController registerClass:HXLearnCenterPageTitleCell.class forTitleViewCellWithReuseIdentifier:@"HXLearnCenterPageTitleCell"];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
}

#pragma mark -
#pragma mark TableViewDelegate&DataSource
- (UIViewController *)pageViewController:(XLPageViewController *)pageViewController viewControllerForIndex:(NSInteger)index {
    if (index==0) {
        HXOnlineLearnViewController *onlineLearnVc = [[HXOnlineLearnViewController alloc] init];
        return onlineLearnVc;
    }else if (index==1) {
        HXTeachPlanViewController *teachPlanVC = [[HXTeachPlanViewController alloc] init];
        return teachPlanVC;
    }else if (index==2) {
        HXFaceTimeTableViewController *faceTimeTableViewVc = [[HXFaceTimeTableViewController alloc] init];
        return faceTimeTableViewVc;
    }
    return nil;
}

- (NSString *)pageViewController:(XLPageViewController *)pageViewController titleForIndex:(NSInteger)index {
    return self.titles[index];
}

- (NSInteger)pageViewControllerNumberOfPage {
    return self.titles.count;
}

- (XLPageTitleCell *)pageViewController:(XLPageViewController *)pageViewController titleViewCellForItemAtIndex:(NSInteger)index {
    HXLearnCenterPageTitleCell *cell = [pageViewController dequeueReusableTitleViewCellWithIdentifier:@"HXLearnCenterPageTitleCell" forIndex:index];
    cell.textLabel.text = [self titles][index];
    return cell;
}

- (void)pageViewController:(XLPageViewController *)pageViewController didSelectedAtIndex:(NSInteger)index {
    NSLog(@"切换到了：%@",[self titles][index]);
}

#pragma mark -
#pragma mark 标题数据
- (NSArray *)titles {
    return @[@"在线学习",@"教学计划",@"面授课表"];
}

@end
