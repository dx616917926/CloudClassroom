//
//  BJLNotice.h
//  BJLiveCore
//
//  Created by MingLQ on 2017-03-09.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLNoticeModel: NSObject

@property (nonatomic, readonly, nullable) NSString *noticeText;
@property (nonatomic, readonly, nullable) NSURL *linkURL;
@property (nonatomic, readonly) NSInteger groupID;

@end

@interface BJLNotice: NSObject

//大班的公告信息
@property (nonatomic, nullable) NSString *noticeText;
@property (nonatomic, nullable) NSURL *linkURL;

//小组内通知信息
@property (nonatomic, nullable) NSArray<BJLNoticeModel *> *groupNoticeList;

@end

NS_ASSUME_NONNULL_END
