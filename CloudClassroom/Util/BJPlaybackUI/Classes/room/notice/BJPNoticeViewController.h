//
//  BJPNoticeViewController.h
//  BJPlaybackUI
//
//  Created by xyp on 2021/5/17.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLTableViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class BJVRoom;

@interface BJPNoticeViewController: UIViewController

- (instancetype)initWithRoom:(BJVRoom *)room;

@property (nonatomic, nullable) void (^noticeLinkCallback)(NSURL *_Nullable linkURL);

// 公告内容改变的时候, 弹出公告页面
@property (nonatomic, nullable) void (^noticeChangeCallback)(void);

@end

NS_ASSUME_NONNULL_END
