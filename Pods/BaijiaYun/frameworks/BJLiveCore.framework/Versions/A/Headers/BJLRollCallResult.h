//
//  BJLRollCallResult.h
//  BJLiveCore
//
//  Created by Ney on 1/11/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLRollCallResultItem: NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *number;
@end

@interface BJLRollCallResult: NSObject <NSCopying>
@property (nonatomic, assign, readonly) BOOL hasHistory; //是否有点名的记录。如果该直播间内有过点名，会返回YES，如果从未点名，则会NO
@property (nonatomic, copy, readonly) NSArray<BJLRollCallResultItem *> *ackList; // 应答列表
@property (nonatomic, copy, readonly) NSArray<BJLRollCallResultItem *> *nackList; // 未应答列表
@end

NS_ASSUME_NONNULL_END
