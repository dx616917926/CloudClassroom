//
//  BJVAppConfig.h
//  Pods
//
//  Created by DLM on 2016/10/25.
//
//

#import <Foundation/Foundation.h>

#define ScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJVDeployType) {
    BJVDeployType_www,
    BJVDeployType_beta,
    BJVDeployType_test
};

@interface BJVAppConfig: NSObject

+ (void)initializeInstance;
+ (instancetype)sharedInstance;

/**
 部署环境, 内部使用, 需要在初始化点播或回放之前设置
 设置 `deployType` 将导致 `privateDomainPrefix` 被重置
 */
@property (nonatomic) BJVDeployType deployType;

/**
 设置客户专属域名前缀
 #param prefix  客户专属域名前缀，例如专属域名为 `demo123.at.baijiayun.com`，则前缀为 `demo123`
 #discussion 需要在初始化点播或回放之前设置，专属域名从百家云账号中心查看
 */
@property (nonatomic, nullable) NSString *privateDomainPrefix;

@end

NS_ASSUME_NONNULL_END
