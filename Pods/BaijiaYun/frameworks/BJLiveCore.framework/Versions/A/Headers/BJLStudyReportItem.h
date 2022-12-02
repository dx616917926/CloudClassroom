//
//  BJLStudyReportItem.h
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2019/8/20.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLStudyReportItem: NSObject

@property (nonatomic, readonly, copy) NSString *reportSerialNumber;
@property (nonatomic, readonly, copy) NSString *userNumber;
@property (nonatomic, readonly, copy) NSString *userName;
@property (nonatomic, readonly, copy) NSString *userAvatar;
@property (nonatomic, readonly, copy) NSString *reportStatus;
@property (nonatomic, readonly, copy) NSString *reportUrl;

@end

NS_ASSUME_NONNULL_END
