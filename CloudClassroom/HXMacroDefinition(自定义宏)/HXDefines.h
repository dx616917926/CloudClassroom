//
//  HXDefines.h
//  HXMinedu
//
//  Created by Mac on 2020/10/30.
//

#ifndef HXDefines_h
#define HXDefines_h



#define NETWORK_AVAILIABLE ([[AFNetworkReachabilityManager sharedManager] isReachable])
#define NETWORK_ViaWWAN    ([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN])
#define NETWORK_ViaWiFi    ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi])

//判断是否是刘海屏
#define IS_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})





//非DEBUG模式不打印日志⚠️
#ifndef DEBUG
#define NSLog(...)
#endif

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IsIOS14 ({BOOL isIOS14 = NO; if(@available(iOS 14.0, *)){isIOS14 = YES;}(isIOS14);})


#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)


//状态栏高度
#define kStatusBarHeight           (IS_iPhoneX?(IsIOS14?48:44):20)  //状态高度  iPhone X高44(iOS 14高48)，其它的高20
//导航栏
#define kNavigationBarHeight       (IS_iPhoneX?88:64)   //导航栏高度  iPhone X高88(iOS 14高92)，其它的高64
//底部边距
#define kScreenBottomMargin        (IS_iPhoneX?34:0) //屏幕底部边距  iPhone X边距34，其它的0
//tabbar高度
#define kTabBarHeight              ((IS_iPhoneX)?83:49)      //tabbar高度  iPhone X高83，其它的高49



///App名称
#define    APP_NAME          ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"])
///App版本
#define    APP_VERSION       ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
///APP build版本
#define    APP_BUILDVERSION  ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])
///操作系统
#define    kPlatformName     @"ios"


#pragma mark - 新版新定义的常用宏


///弱引用和强引用
#define WeakSelf(weakSelf)      __weak __typeof(&*self)     weakSelf  = self
#define StrongSelf(strongSelf)  __strong __typeof(&*self)   strongSelf = weakSelf

///字符串保护
#define HXSafeString(__string_) ([__string_ isKindOfClass:[NSNull class]] ? @"" : (__string_ ? __string_ : @""))

//url字符串转码处理
#define HXSafeURL(urlStr)   [NSURL URLWithString:[HXCommonUtil stringEncoding:urlStr]]

///自定义颜色
#define COLOR_WITH_ALPHA(colorValue, alphaValue) [UIColor colorWithRed:((float)((colorValue & 0xFF0000) >> 16))/255.0 green:((float)((colorValue & 0xFF00) >> 8))/255.0 blue:((float)(colorValue & 0xFF))/255.0 alpha:alphaValue]

//自定义字体
#define HXFont(fontSize)      [UIFont systemFontOfSize:fontSize];
#define HXBoldFont(fontSize)  [UIFont boldSystemFontOfSize:fontSize];


// 美工的标准375
#define _kpw(__width_) ([UIScreen mainScreen].bounds.size.width * (__width_) / 375.0)
// 美工的标准667
#define _kph(__height_) ([UIScreen mainScreen].bounds.size.height * (__height_) / 667.0)
// 根据屏幕宽度适配字体大小
#define _kpAdaptationWidthFont(__font_) ([UIScreen mainScreen].bounds.size.width * (__font_) / 375.0)
// 根据高度度适配字体大小
#define _kpAdaptationHeightFont(__font_) ([[UIScreen mainScreen].bounds.size.height * (__font_) / 667.0)

#define  HXUserDefaults        [NSUserDefaults standardUserDefaults]
#define  HXNotificationCenter  [NSNotificationCenter defaultCenter]

#ifndef KHXUserDefaultsForValue
#define KHXUserDefaultsForValue(___key_) ({   \
    NSString *__value_ = [HXUserDefaults valueForKey:___key_];   \
    __value_ ? __value_ : @""; \
})
#endif

#endif /* HXDefines_h */
