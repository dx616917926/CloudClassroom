//
//  HXCheckUpdateTool.h
//  HXMinedu
//
//  Created by Mac on 2020/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXCheckUpdateTool : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, assign) BOOL hasNewVersion;  //是否有新版本

/**
 检查是否有新版本，适用于自动检测
 */
- (void)checkUpdate;

/**
 检查是否有新版本，适用于手动检测
 */
- (void)checkUpdateWithInController:(nullable UIViewController *)viewController;

/**
 检测APP Store是否有新版本
 */
- (void)checkAPPStoreUpdateWithInController:(nullable UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END
