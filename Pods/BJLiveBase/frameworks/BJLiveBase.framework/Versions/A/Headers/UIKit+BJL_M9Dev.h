//
//  UIKit+BJL_M9Dev.h
//  M9Dev
//
//  Created by MingLQ on 2016-04-21.
//  Copyright (c) 2016 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (BJL_M9Dev)

- (nullable __kindof UIResponder *)bjl_closestResponderOfClass:(Class)clazz; // NOT include self
- (nullable __kindof UIResponder *)bjl_closestResponderOfClass:(Class)clazz includeSelf:(BOOL)includeSelf;
- (nullable __kindof UIResponder *)bjl_findResponderWithBlock:(BOOL(NS_NOESCAPE ^)(UIResponder *responder, BOOL *stop))enumerateBlock;

@end

#pragma mark -

@interface UIView (BJL_M9Dev)

@property (nonatomic, nullable, setter=bjl_setFirstResponder:) __kindof UIView *bjl_firstResponder;

- (nullable __kindof UIView *)bjl_closestViewOfClass:(Class)clazz; // NOT include self
- (nullable __kindof UIView *)bjl_closestViewOfClass:(Class)clazz includeSelf:(BOOL)includeSelf; // up to UIViewController
- (nullable __kindof UIView *)bjl_closestViewOfClass:(Class)clazz includeSelf:(BOOL)includeSelf upToResponder:(nullable UIResponder *)upToResponder; // NOT include the upToResponder, nil - up to UIViewController
- (nullable __kindof UIViewController *)bjl_closestViewController;

- (void)bjl_eachSubview:(BOOL(NS_NOESCAPE ^)(__kindof UIView *subview, NSInteger depth))callback;

@end

#pragma mark -

@interface UIViewController (BJL_M9Dev)

@property (nonatomic, setter=bjl_setHidesNavigationBarWhenPushed:) BOOL bjl_hidesNavigationBarWhenPushed;

/** generate by supportedInterfaceOrientations, statusBarOrientation and deviceOrientation */
@property (nonatomic, readonly) UIInterfaceOrientation bjl_preferredInterfaceOrientation;

- (void)bjl_addChildViewController:(UIViewController *)childViewController;
- (void)bjl_addChildViewController:(UIViewController *)childViewController superview:(UIView *)superview;
- (void)bjl_addChildViewController:(UIViewController *)childViewController superview:(UIView *)superview atIndex:(NSInteger)index;
- (void)bjl_addChildViewController:(UIViewController *)childViewController superview:(UIView *)superview belowSubview:(UIView *)siblingSubview;
- (void)bjl_addChildViewController:(UIViewController *)childViewController superview:(UIView *)superview aboveSubview:(UIView *)siblingSubview;
- (void)bjl_addChildViewController:(UIViewController *)childViewController addSubview:(void(NS_NOESCAPE ^)(UIView *parentView, UIView *childView))addSubview; // synchronous
- (void)bjl_removeFromParentViewControllerAndSuperiew;

/**
 *  differences from `presentViewController:animated:completion:`
 *  1. dismissing all presented view controllers, #see `bjl_visibleViewController`
 *  2. [optional] set modal presentation style
 */
- (void)bjl_presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^__nullable)(void))completion;
- (void)bjl_presentFullScreenViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^__nullable)(void))completion;

/**
 *  differences from `dismissViewControllerAnimated:completion:`
 *  1. always call completion although nothing to dismiss
 *  2. only dismiss self, but not parentViewController
 */
- (void)bjl_dismissAnimated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
/**
 *  differences from `dismissViewControllerAnimated:completion:`
 *  1. always call completion although nothing to dismiss
 *  2. only dismiss presentedViewController, but not self
 */
- (void)bjl_dismissPresentedViewControllerAnimated:(BOOL)animated completion:(void (^_Nullable)(void))completion;

@property (nonatomic, readonly, nullable) UIViewController
    *bjl_topViewControllerExceptPresented, // tab.selected, nav.top, EXCEPT all presented
    *bjl_visibleViewController, // tab.selected, nav.top and presented, EXCEPT presented alert
    *bjl_visibleAlertOrViewController; // tab.selected, nav.top and all presented - INCLUDE presented alert

// !!!: #see - [UINavigationController bjl_navigationControllerWithRootViewController:self];
- (UINavigationController *)bjl_wrapWithNavigationController;

@end

@interface UIWindow (BJL_M9Dev)

@property (nonatomic, readonly, nullable) UIViewController
    *bjl_topViewControllerExceptPresented,
    *bjl_visibleViewController,
    *bjl_visibleAlertOrViewController;

@property (class, nonatomic, readonly, nullable) UIWindow *bjl_mainWindow NS_SWIFT_NAME(bjl_mainWindow);
@property (class, nonatomic, readonly, nullable) UIWindow *bjl_keyWindow NS_SWIFT_NAME(bjl_keyWindow);

@end

#pragma mark -

@interface UINavigationController (BJL_M9Dev)

@property (nonatomic, readonly, nullable) UIViewController *bjl_rootViewController;

// !!!: #return instance of private subclass
// !!!: navigationController.interactivePopGestureRecognizer.delegate == navigationController
+ (UINavigationController *)bjl_navigationControllerWithRootViewController:(nullable UIViewController *)rootViewController;
+ (UINavigationController *)bjl_navigationControllerWithRootViewController:(nullable UIViewController *)rootViewController
                                                        navigationBarClass:(nullable Class)navigationBarClass
                                                              toolbarClass:(nullable Class)toolbarClass;

- (void)bjl_pushViewController:(UIViewController *)viewController
                      animated:(BOOL)animated
                    completion:(void (^_Nullable)(void))completion;

- (nullable UIViewController *)bjl_popViewControllerAnimated:(BOOL)animated
                                                  completion:(void (^_Nullable)(void))completion;
- (nullable NSArray *)bjl_popToViewController:(UIViewController *)viewController
                                     animated:(BOOL)animated
                                   completion:(void (^_Nullable)(void))completion;
- (nullable NSArray *)bjl_popToRootViewControllerAnimated:(BOOL)animated
                                               completion:(void (^_Nullable)(void))completion;

@end

#pragma mark -

@interface UITabBarController (BJL_M9Dev)

// !!!: #return instance of private subclass
+ (instancetype)bjl_tabBarController NS_SWIFT_NAME(bjl_tabBarController());

@end

#pragma mark -

@interface UISplitViewController (BJL_M9Dev)

// !!!: #return instance of private subclass
+ (instancetype)bjl_splitViewControllerWithViewDidLoadCallback:(void (^_Nullable)(UISplitViewController *splitViewController))viewDidLoadCallback NS_SWIFT_NAME(bjl_splitViewController(viewDidLoad:));

@end

#pragma mark -

@interface UIColor (BJL_M9Dev)

// @"#FFFFFF"
+ (nullable UIColor *)bjl_colorWithHexString:(NSString *)hexString;
+ (nullable UIColor *)bjl_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
// 0xFFFFFF
+ (UIColor *)bjl_colorWithHex:(unsigned)hex NS_SWIFT_NAME(bjl_color(hex:));
+ (UIColor *)bjl_colorWithHex:(unsigned)hex alpha:(CGFloat)alpha NS_SWIFT_NAME(bjl_color(hex:alpha:));

@end

#pragma mark -

@interface UIImage (BJL_M9Dev)

+ (UIImage *)bjl_imageNamed:(NSString *)name renderingMode:(UIImageRenderingMode)renderingMode;

- (UIImage *)bjl_resizableImage;

/**
 #return UIImage with the scale factor of the device’s main screen
 */
- (UIImage *)bjl_imageFillSize:(CGSize)size; // enlarge: NO
- (UIImage *)bjl_imageFillSize:(CGSize)size enlarge:(BOOL)enlarge; // aspect fill & cropped

/**
 #return UIImage with the scale factor of the device’s main screen
 */
+ (nullable UIImage *)bjl_imageWithColor:(UIColor *)color NS_SWIFT_NAME(bjl_image(color:));
+ (nullable UIImage *)bjl_imageWithColor:(UIColor *)color size:(CGSize)size NS_SWIFT_NAME(bjl_image(color:size:));

@end

#pragma mark -

@interface UIApplication (BJL_M9Dev)

- (void)bjl_openURL:(NSURL *)url;
- (void)bjl_openURL:(NSURL *)url completionHandler:(void (^__nullable)(BOOL success))completion;

@end

#pragma mark -

FOUNDATION_EXPORT CGFloat BJL1Pixel(void);

FOUNDATION_EXPORT CGFloat BJLFloorWithScreenScale(CGFloat size);
FOUNDATION_EXPORT CGFloat BJLCeilWithScreenScale(CGFloat size);

FOUNDATION_EXPORT CGSize BJLAspectFillSize(CGSize size, CGFloat aspectRatio);
FOUNDATION_EXPORT CGSize BJLAspectFitSize(CGSize size, CGFloat aspectRatio);

FOUNDATION_EXPORT CGRect BJLAspectFillFrame(CGRect frame, CGFloat aspectRatio);
FOUNDATION_EXPORT CGRect BJLAspectFitFrame(CGRect frame, CGFloat aspectRatio);

FOUNDATION_EXPORT CGSize BJLImageViewSize(CGSize imgSize, CGSize minSize, CGSize maxSize);

#pragma mark - AliIMG

static const NSInteger BJLAliIMGMinSize = 1, BJLAliIMGMaxSize = 4096;

/**
 Ali image url params
 x-oss-process=image/resize,m_mfit,w_100,h_100,limit_1/auto-orient,1/format,jpg
 /resize: m_lfit - aspect fit (default), m_mfit - aspect fill (no cut), w - width, h - height, limit_1 - no enlarge (default)
 /auto-orient: 1 - auto routate then resize (default?), 0 - resize without auto routate
 /format,jpg: jpg/png/webp/gif (lowercase!)
 https://help.aliyun.com/document_detail/44686.html?spm=5176.doc54739.3.2.kCK7Oh
 */
static inline NSString *BJLAliIMGURLParams_aspectScale(NSInteger width, NSInteger height, NSInteger scale, BOOL fill, NSString *_Nullable ext) {
    scale = MAX(1.0, scale <= 0 ? round([UIScreen mainScreen].scale) : scale);
    width *= scale;
    height *= scale;
    NSInteger max = MAX(width, height);
    if (max > BJLAliIMGMaxSize) {
        CGFloat minify = (CGFloat)BJLAliIMGMaxSize / max;
        width = floor(width * minify);
        height = floor(height * minify);
    }
    width = MAX(BJLAliIMGMinSize, width);
    height = MAX(BJLAliIMGMinSize, height);
    ext = ext.lowercaseString;
    return [NSString stringWithFormat:@"image"
                                       "/resize,m_%@,w_%td,h_%td,limit_1"
                                       "/auto-orient,1"
                                       "/format,%@",
                     fill ? @"mfit" : @"lfit",
                     width,
                     height,
                     [@[@"jpg", @"png", @"webp", @"gif"] containsObject:ext] ? ext : @"jpg"];
}

static inline NSString *BJLAliIMGURLString_aspectScale(NSInteger width, NSInteger height, NSInteger scale, BOOL fill, NSString *urlString, NSString *_Nullable ext) {
    NSString *const key = @"x-oss-process";
    if (!urlString.length) {
        return @"";
    }
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    if (!components) {
        return urlString;
    }

    // remove old @-style parameters from path
    NSRange range = [components.path rangeOfString:@"@" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        components.path = [components.path substringToIndex:range.location];
    }

    // remove existing parameters
    NSMutableArray *queryItems = [components.queryItems mutableCopy] ?: [NSMutableArray new];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:key]) {
            [queryItems removeObject:queryItem];
        }
    }

    // add new parameters
    if (width > 0.0 && height > 0.0) {
        NSString *value = BJLAliIMGURLParams_aspectScale(width, height, scale, fill, ext ?: [urlString pathExtension]);
        NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:key value:value];
        [queryItems addObject:queryItem];
        components.queryItems = queryItems;
    }

    return components.string;
}

static inline NSString *BJLAliIMG_originalSize(NSString *urlString, NSString *_Nullable ext) {
    return BJLAliIMGURLString_aspectScale(0.0, 0.0, 0.0, YES, urlString, ext);
}

static inline NSString *BJLAliIMG_aspectFill(CGSize size, CGFloat scale, NSString *urlString, NSString *_Nullable ext) {
    return BJLAliIMGURLString_aspectScale(round(size.width), round(size.height), scale, YES, urlString, ext);
}

static inline NSString *BJLAliIMG_aspectFit(CGSize size, CGFloat scale, NSString *urlString, NSString *_Nullable ext) {
    return BJLAliIMGURLString_aspectScale(round(size.width), round(size.height), scale, NO, urlString, ext);
}

NS_ASSUME_NONNULL_END
