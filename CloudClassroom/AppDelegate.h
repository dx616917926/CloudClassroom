//
//  AppDelegate.h
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import <UIKit/UIKit.h>
#import "HXMainTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

@property (strong, nonatomic) HXMainTabBarController *mainTabBarController;

/***  是否允许横屏的标记 */
@property (nonatomic,assign)BOOL allowRotation;

@end

