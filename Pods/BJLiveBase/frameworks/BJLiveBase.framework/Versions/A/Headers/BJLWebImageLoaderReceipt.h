//
//  BJLWebImageLoaderReceipt.h
//  BJLiveBase
//
//  Created by HuangJie on 2018/10/23.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLWebImageLoaderReceipt : NSObject

- (instancetype)initWithCancelBlock:(void(^)(void))cancelBlock;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
