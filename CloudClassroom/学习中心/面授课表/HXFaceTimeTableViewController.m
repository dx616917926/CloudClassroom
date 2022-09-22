//
//  HXFaceTimeTableViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/9/1.
//

#import "HXFaceTimeTableViewController.h"

@interface HXFaceTimeTableViewController ()

@end

@implementation HXFaceTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.noDataTipView.tipTitle = @"暂无面授课表～";
    self.noDataTipView.frame = CGRectMake(0, 16, kScreenWidth, kScreenHeight);
    [self.view addSubview:self.noDataTipView];
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
