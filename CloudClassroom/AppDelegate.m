//
//  AppDelegate.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //iOS 15 TableView sectionHeaderTopPadding 统一 处理
    if (@available(iOS 15.0, *)) {
      [UITableView appearance].sectionHeaderTopPadding = 0;
    }
    
    [self.window setRootViewController:self.mainTabBarController];
    
    return YES;
}



- (HXMainTabBarController *)mainTabBarController {
    
    if (!_mainTabBarController) {
        _mainTabBarController = [[HXMainTabBarController alloc] init];
    }
    return _mainTabBarController;
}


@end
