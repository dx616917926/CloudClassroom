//
//  BJLLocalNetworkPrivacyChecker.h
//  CodeLab
//
//  Created by Ney on 10/11/21.
//  Copyright © 2021 Ney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BJLLocalNetworkAccessChecker;

typedef void(^BJLLocalNetworkAccessCheckerResultBlock)(BJLLocalNetworkAccessChecker * _Nonnull checker, BOOL granted);

NS_ASSUME_NONNULL_BEGIN


/// BJLLocalNetworkAccessChecker 是用来检测是否打开本地局域网权限的工具类
/// 需要下列权限，否则结果可能是错误的结果
/// Privacy - Local Network Usage Description
/// NSBonjourServices _lnp._tcp.
@interface BJLLocalNetworkAccessChecker : NSObject
- (void)requestAccess:(BJLLocalNetworkAccessCheckerResultBlock)completion;
@end

NS_ASSUME_NONNULL_END
