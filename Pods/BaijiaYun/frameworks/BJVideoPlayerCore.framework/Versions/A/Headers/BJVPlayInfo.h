//
//  BJVPlayInfo.h
//  Pods
//
//  Created by 辛亚鹏 on 2016/11/14.
//
//

#import <Foundation/Foundation.h>

#import "BJVDefinitionInfo.h"
#import "BJVSubtitle.h"
#import "BJVUserVideo.h"
#import "BJVLamp.h"

typedef NS_ENUM(NSInteger, BJRecordType) {
    BJRecordType_Common = 0, // 普通录制 -> 所有非webrtc课程
    BJRecordType_CompositeVideo = 1, // 拼接所有人视频录制, 不包括PPT,画笔,聊天 -> webrtc大班课
    BJRecordType_WholeScreen = 2, // 整屏抓取录制,包括PPT,画笔,聊天 -> 除了webrtc大班课之外的其他webrtc课程
    BJRecordType_Mixed = 3, // 合流录制
};

typedef NS_ENUM(NSInteger, BJVLayoutTemplate) {
    BJVTemplateUndefine = 0, //
    BJVTemplateLiveWall = 1, // 视频墙，老师可以切换布局
    BJVTemplateVideoOnly = 2, // 纯视频
    BJVTemplateDoubleCamera = 3, // 双摄像头
};

NS_ASSUME_NONNULL_BEGIN

@interface BJVPlayInfo: NSObject <BJLYYModel, NSCopying>

@property (nonatomic, readonly) NSString *videoID;
@property (nonatomic, readonly) NSString *classID, *sessionID;
@property (nonatomic, readonly) BOOL encrypted;

/**
 裁剪后的回放视频的version
 #discussion  -1: 裁剪后的主版本,  0: 裁剪前的原始视频.
 */
@property (nonatomic, readonly) NSInteger clipedVersion;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *coverURL; // 视频封面图片
@property (nonatomic, readonly) NSArray<BJVDefinitionInfo *> *definitionList;
@property (nonatomic, nullable, readonly) NSArray<BJVSubtitleInfo *> *subtitleInfo;
@property (nonatomic, readonly) NSString *format; // 文件格式: mp4, ev1, mp3
@property (nonatomic, readonly) BJRecordType recordType; //录制方式
@property (nonatomic, readonly, nullable) BJVLamp *lamp; // 后台配置的跑马灯

// 是否展示用户列表, 聊天列表
@property (nonatomic, readonly) BOOL isShowUserList, isShowChatList;

// 是否开启禁止录屏功能
@property (nonatomic, readonly) BOOL enablePreventScreenCapture;

- (instancetype)initWithUserVideoInfo:(BJVUserVideo *)userVideoInfo;

// 房间界面布局类型
@property (nonatomic, readonly) BJVLayoutTemplate layoutTemplate;
@end

NS_ASSUME_NONNULL_END
