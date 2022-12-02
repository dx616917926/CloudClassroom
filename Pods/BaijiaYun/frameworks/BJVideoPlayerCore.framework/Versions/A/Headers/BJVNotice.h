//
//  BJVNotice.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJVNoticeModel: NSObject

@property (nonatomic, readonly, nullable) NSString *noticeText;
@property (nonatomic, readonly, nullable) NSURL *linkURL;
@property (nonatomic, readonly) NSInteger groupID;

@end

@interface BJVNotice: NSObject

//大班的公告信息
@property (nonatomic, nullable) NSString *noticeText;
@property (nonatomic, nullable) NSURL *linkURL;

//小组内通知信息
@property (nonatomic, nullable) NSArray<BJVNoticeModel *> *groupNoticeList;

@end

NS_ASSUME_NONNULL_END
