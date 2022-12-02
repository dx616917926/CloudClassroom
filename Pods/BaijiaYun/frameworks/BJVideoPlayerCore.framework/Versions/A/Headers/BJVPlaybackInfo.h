//
//  _BJVPlaybackInfo.h
//  BJVideoPlayerCore
//
//  Created by HuangJie on 2018/5/19.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveBase/BJLYYModel.h>

#import "BJVPlayInfo.h"
#import "BJVUserVideo.h"
#import "BJVConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJVPlaybackInfo: BJVPlayInfo <BJLYYModel>

// 信令文件 URL
@property (nonatomic, readonly) NSString *signalFileURL;

// 回放是否要支持答题器和小测
@property (nonatomic, readonly) BOOL enableQuizAndAnswer;

// 是否显示问答
@property (nonatomic, readonly) BOOL enableQuestion;

// 学生视频列表
@property (nonatomic, readonly) NSArray<BJVUserVideo *> *userVideoList;

// 回放的班型
@property (nonatomic, readonly) BJVRoomType roomType;

// 小班课 1v1 是不是信令录制
@property (nonatomic, readonly) BOOL isInteractiveClass1v1SignalingRecord;

// 小班课 1v1 黑板数量
@property (nonatomic, readonly) NSInteger interactiveClass1v1BlackboardPages;

// 白板背景图片 url
@property (nonatomic, readonly) NSString *whiteboardURL;

// 是否开启隐藏学生消息中的手机号功能
@property (nonatomic, readonly) BOOL enableHideStudentPhoneNumber;

@end

NS_ASSUME_NONNULL_END
