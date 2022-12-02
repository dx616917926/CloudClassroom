//
//  BJLStudyRoomReconnectParameters.h
//  BJLiveCore
//
//  Created by Ney on 12/22/20.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface BJLStudyRoomReconnectParameterItem: NSObject
@property (nonatomic, copy, readonly) NSString *joinCode;
@property (nonatomic, copy, readonly) NSString *directEnterUrl;
@property (nonatomic, copy, readonly) NSString *enterUrl;
@end

/** ### 重进直播间的参数 */
@interface BJLStudyRoomReconnectParameters: NSObject

/// 助教身份重进直播间参数
@property (nonatomic, strong, readonly) BJLStudyRoomReconnectParameterItem *assistant;

/// 老师身份重进直播间参数
@property (nonatomic, strong, readonly) BJLStudyRoomReconnectParameterItem *teacher;
@end
NS_ASSUME_NONNULL_END
