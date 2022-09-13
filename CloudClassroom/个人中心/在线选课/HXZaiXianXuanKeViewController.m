//
//  HXZaiXianXuanKeViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXZaiXianXuanKeViewController.h"
#import "XLPageViewController.h"
#import "HXZaiXianXuanKeViewChildController.h"//在线选课
#import "HXYiJiaoFeiViewController.h"//已缴费
#import "HXLearnCenterPageTitleCell.h"

@interface HXZaiXianXuanKeViewController ()<XLPageViewControllerDelegate,XLPageViewControllerDataSrouce>

@property (nonatomic, strong) XLPageViewController *pageViewController;

@end

@implementation HXZaiXianXuanKeViewController

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
    
    self.sc_navigationBar.title = @"在线选课";
    //初始化控制器
    [self initPageViewController];
}

//初始化控制器
- (void)initPageViewController {
    XLPageViewControllerConfig *config = [XLPageViewControllerConfig defaultConfig];
    config.titleViewBackgroundColor = UIColor.whiteColor;
    config.titleViewHeight = 44;
    //设置标题间距
    config.titleSpace = 100;
    //设置标题栏缩进
    config.titleViewInset = UIEdgeInsetsMake(0, 20, 0, 20);
    config.titleViewAlignment = XLPageTitleViewAlignmentCenter;
    //隐藏底部分割线
    config.separatorLineHidden =YES;
    ////设置标题颜色
    config.titleSelectedColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
    config.titleNormalColor = COLOR_WITH_ALPHA(0x333333, 1);;
    config.titleNormalFont = HXFont(14);
    config.titleSelectedFont =HXBoldFont(14);
    //隐藏底部阴影
    config.shadowLineHidden = true;
    self.pageViewController = [[XLPageViewController alloc] initWithConfig:config];
    self.pageViewController.view.frame =CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight);
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
        HXZaiXianXuanKeViewChildController *zaiXianXuanKeViewChildVc = [[HXZaiXianXuanKeViewChildController alloc] init];
        zaiXianXuanKeViewChildVc.controlScrollBlock = ^(BOOL scrollEnabled) {
            self.pageViewController.scrollEnabled = scrollEnabled;
        };
        return zaiXianXuanKeViewChildVc;
    }else if (index==1) {
        HXYiJiaoFeiViewController *yiJiaoFeiVC = [[HXYiJiaoFeiViewController alloc] init];
        return yiJiaoFeiVC;
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
    return @[@"在线选课",@"已缴费"];
}

@end


