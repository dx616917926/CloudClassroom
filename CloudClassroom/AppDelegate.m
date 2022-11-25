//
//  AppDelegate.m
//  CloudClassroom
//
//  Created by mac on 2022/8/30.
//

#import "AppDelegate.h"
#import "HXLoginViewController.h"
#import "IQKeyboardManager.h"
#import "IDLFaceSDK/IDLFaceSDK.h"
#import "FaceParameterConfig.h"
#import "WXApi.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //iOS 15 TableView sectionHeaderTopPadding 统一 处理
    if (@available(iOS 15.0, *)) {
      [UITableView appearance].sectionHeaderTopPadding = 0;
    }
    
    //判断是否登录、是否需要显示引导页
    [self firstEnterHandle];
    //第三方配置
    [self thirdPartyConfiguration];
    
   
    
    return YES;
}

#pragma mark – 判断是否登录、是否需要显示引导页
- (void)firstEnterHandle {
    
    if ([HXPublicParamTool sharedInstance].isLogin) {
        [self.window setRootViewController:self.mainTabBarController];
    }else{
        HXLoginViewController * loginVC = [[HXLoginViewController alloc]init];
        loginVC.sc_navigationBarHidden = YES;
        HXNavigationController *navVC = [[HXNavigationController alloc] initWithRootViewController:loginVC];
        [self.window setRootViewController:navVC];
    }
    
    [self.window makeKeyAndVisible];
    
    

}

#pragma mark -第三方配置
- (void)thirdPartyConfiguration {

    
    ///键盘（IQKeyboardManager）全局管理，针对键盘遮挡问题
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.enableAutoToolbar = NO;///是否显示键盘上方工具条
    manager.shouldResignOnTouchOutside = YES;///是否点击空白区域收起键盘
    manager.shouldShowToolbarPlaceholder = NO;
    manager.keyboardDistanceFromTextField = IS_iPhoneX?50:40;/// 键盘距离文本输入框距离
    
    //注册百度活体检测SDK
    NSString* licensePath = [NSString stringWithFormat:@"%@.%@", FACE_LICENSE_NAME, FACE_LICENSE_SUFFIX ];
    [[FaceSDKManager sharedInstance] setLicenseID:FACE_LICENSE_ID andLocalLicenceFile:licensePath andRemoteAuthorize:true];
    NSLog(@"canWork = %d",[[FaceSDKManager sharedInstance] canWork]);
    NSLog(@"version = %@",[[FaceSDKManager sharedInstance] getVersion]);
    
    
#if 1
    //微信配置
#ifdef DEBUG
    //在register之前打开log, 后续可以根据log排查问题
    [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
        NSLog(@"WeChatSDK: %@", log);
    }];
#endif
    //向微信注册
    BOOL sc =  [WXApi registerApp:WeiXin_APP_ID universalLink:UNIVERSAL_LINK];
    
//    if (!PRODUCTIONMODE) {
//        //调用自检函数,仅用于新接入SDK时调试使用，请勿在正式环境的调用
//        [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
//            NSLog(@"自检函数:%@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
//        }];
//    }
#endif
}


- (HXMainTabBarController *)mainTabBarController {
    
    if (!_mainTabBarController) {
        _mainTabBarController = [[HXMainTabBarController alloc] init];
    }
    return _mainTabBarController;
}


@end
