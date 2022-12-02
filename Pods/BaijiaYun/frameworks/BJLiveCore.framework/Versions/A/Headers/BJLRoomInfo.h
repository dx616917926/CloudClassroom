//
//  BJLRoomInfo.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-05.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJLConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BJLRoomInfo <NSObject>

@property (nonatomic, readonly) NSString *ID, *title;
@property (nonatomic, readonly) NSTimeInterval startTimeInterval, startTimeMillisecond, endTimeInterval;

@property (nonatomic, readonly) BJLRoomType roomType; // 直播间类型
@property (nonatomic, readonly) BOOL hasStudentRaise; //有无学生上麦
@property (nonatomic, readonly) BOOL isMockLive; // 是否是伪直播，仅大班课
@property (nonatomic, readonly) BOOL isPushLive; // 是否是推流直播，仅大班课
@property (nonatomic, readonly) BOOL isVideoWall; // 是否是视频墙直播，仅大班课
@property (nonatomic, readonly) BOOL isPureVideo; // 是否是纯视频模板（纯视频不能切换布局，视频墙可以切换），仅大班课
@property (nonatomic, readonly) BOOL isLongTerm; // 是否为长期大班课，仅大班课
@property (nonatomic, readonly) BOOL isDoubleCamera; // 是否为双摄像头模板，仅大班课
@property (nonatomic, readonly) BJLRoomGroupType roomGroupType; // 直播间分组类型
@property (nonatomic, readonly) BJLRoomNewGroupType newRoomGroupType; // 新版分组直播间分组类型
@property (nonatomic, readonly) BOOL enableGroupUser; // 分组用户可见
@property (nonatomic, readonly) BOOL enableGroupInSmallRoom; // 大小班切换到大班之后是否允许分组，该设置仅对旧版分组直播有效
@property (nonatomic, readonly) BOOL enableGroupInNewSmallRoom; // 大小班切换到大班之后是否允许分组，该设置对新版线上双师和分组课堂有效
@property (nonatomic, readonly) BJLIcTemplateType interactiveClassTemplateType; // 专业版小班课布局模板

@property (nonatomic, readonly) NSString *partnerID; // 客户ID
@property (nonatomic, readonly) NSString *environmentName; // 账号环境
@property (nonatomic, readonly, nullable) NSString *customerSupportMessage; // 定制支持信息
@end

NS_ASSUME_NONNULL_END
