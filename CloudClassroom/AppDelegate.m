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
# import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()<WXApiDelegate>

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



#pragma mark - <UIApplicationDelegate>
//低于iOS 13版本，微信处理通用链接，会走此回调
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    
    if ([url.host isEqualToString:@"safepay"]) {//  判断一下这个host，safepay就是支付宝的
        // resultStatus支付状态
        //  9000 ：支付成功
        //  8000 ：订单处理中
        //  4000 ：订单支付失败
        //  6001 ：用户中途取消
        //  6002 ：网络连接出错
        //  这里的话，就可以根据状态，去处理自己的业务了
        //跳转支付宝客户端进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            NSInteger resultStatus = [[resultDic stringValueForKey:@"resultStatus"] integerValue];
            switch (resultStatus) {
                case 9000:
                {
                    [self.window showTostWithMessage:@"支付成功"];
                }
                    break;
                case 8000:
                {
                    [self.window showTostWithMessage:@"订单处理中"];
                }
                    break;
                case 4000:
                {
                    [self.window showTostWithMessage:@"支付失败"];
                }
                    break;
                case 6001:
                {
                    [self.window showTostWithMessage:@"支付取消"];
                }
                    break;
                case 6002:
                {
                    [self.window showTostWithMessage:@"网络连接出错"];
                }
                    break;
                default:
                    break;
            }
            
        }];
    }else if ([url.absoluteString rangeOfString:@"www.edu-edu.com"].location != NSNotFound) {//H5微信支付
        //此处发送通知，哪里需要接受通知处理，哪里就接受
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatH5PayNotification" object:url.absoluteString];
    }else if ([url.scheme rangeOfString:WeiXin_APP_ID].length!=0) {////低于iOS 13版本，这里处理通用链接回调
        NSLog(@"再次跳回。。。");
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

//iOS 13以上版本，微信处理通用链接，会走此回调
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable
                                                                                                                                 restorableObjects))restorationHandler {
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webUrl = userActivity.webpageURL;
        NSLog(@"continueUserActivity:%@",webUrl);
    }
    
    //处理通用链接
    //当APP被UniversalLink调起后，
    BOOL ret = [WXApi handleOpenUniversalLink:userActivity delegate:self];
    NSLog(@"处理微信通过Universal Link启动App时传递的数据:%d",ret);
    return ret;
}

#pragma mark - <WXApiDelegate>
//收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
- (void)onReq:(BaseReq*)req
{
    NSLog(@"微信请求App提供内容onReq:%@",req);
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        //        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        //        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%lu bytes\n\n", msg.title, msg.description, obj.extInfo, (unsigned long)msg.thumbData.length];
        NSLog(@"%@ %@",strTitle,strMsg);
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        NSLog(@"%@ %@",strTitle,strMsg);
    }
}

//收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
- (void)onResp:(BaseResp *)resp {
    /*
     enum  WXErrCode {
     WXSuccess           = 0,    成功
     WXErrCodeCommon     = -1,  普通错误类型
     WXErrCodeUserCancel = -2,    用户点击取消并返回
     WXErrCodeSentFail   = -3,   发送失败
     WXErrCodeAuthDeny   = -4,    授权失败
     WXErrCodeUnsupport  = -5,   微信不支持
     };
     */
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp * response = (PayResp *)resp;  // 微信终端返回给第三方的关于支付结果的结构体
        switch (response.errCode) {
            case WXSuccess:
            {// 支付成功，向后台发送消息
                [self.window showTostWithMessage:@"支付成功"];
            }
                break;
            case WXErrCodeCommon:
            { //签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等
                [self.window showTostWithMessage:@"支付失败"];
            }
                break;
            case WXErrCodeUserCancel:
            { //用户点击取消并返回
                [self.window showTostWithMessage:@"取消支付"];
            }
                break;
            case WXErrCodeSentFail:
            { //发送失败
                [self.window showTostWithMessage:@"支付失败"];
            }
                break;
            case WXErrCodeAuthDeny:
            { //授权失败
                [self.window showTostWithMessage:@"授权失败"];
            }
                break;
            case WXErrCodeUnsupport:
            { //微信不支持
                [self.window showTostWithMessage:@"微信不支持"];
            }
                break;
            default:
                break;
        }
    }
    
}




-  (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
