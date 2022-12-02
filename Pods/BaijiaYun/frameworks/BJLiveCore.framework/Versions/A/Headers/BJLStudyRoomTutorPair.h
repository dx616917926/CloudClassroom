//
//  BJLStudyRoomTutorPair.h
//  BJLiveCore
//
//  Created by Ney on 1/26/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLStudyRoomTutorPair: NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSString *tutorID;
@property (nonatomic, copy, readonly) NSString *studentUserID;
@property (nonatomic, copy, readonly) NSString *assistantUserID;
@end

NS_ASSUME_NONNULL_END
