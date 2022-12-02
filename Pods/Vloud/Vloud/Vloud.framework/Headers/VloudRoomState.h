/***********************
auth: cszdlt@qq.com
date: 2020-05-11 11:15:24
name: VloudRoomState.h
************************/

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudRoomState : NSObject

/// 当前房间是否锁定
@property(nonatomic, assign) BOOL lock;

/// 是否允许用户自行打开麦克风
@property(nonatomic, assign) BOOL selfOpenAudio;

/// 当前房间是否已开启全员禁用麦克风
@property(nonatomic, assign) BOOL audioOff;

/// 当前房间是否已开启全员禁用摄像头
@property(nonatomic, assign) BOOL videoOff;

/// 当前房间是否已开启全员禁用文本消息
@property(nonatomic, assign) BOOL msgOff;

/// 当前房间是否允许加入
@property(nonatomic, assign) BOOL doorOpen;

/// 当前房间是否有密码。该参数仅在[VloudClientDelegate statsChangeForRoomId:roomState:]回调中可用
@property(nonatomic, assign) BOOL secret;

/// 当前房间是否添加密码， 值为 null 则表示不修改该选项，值为""则表示不使用密码。
/// 该参数仅在调用修改房间密码时可用
@property(nonatomic, copy) NSString *password;

/// 房间创建者的 userId。该参数仅在[VloudClientDelegate statsChangeForRoomId:roomState:]回调中可用
@property(nonatomic, copy) NSString *creatorId;

/// 房间主持人的 userId。该参数仅在[VloudClientDelegate statsChangeForRoomId:roomState:]回调中可用
@property(nonatomic, copy) NSString *masterId;

- (instancetype)init;
- (instancetype)initWithLock:(BOOL)lock
               selfOpenAudio:(BOOL)selfOpenAudio
                    audioOff:(BOOL)audioOff
                    videoOff:(BOOL)videoOff
                      msgOff:(BOOL)msgOff
                    doorOpen:(BOOL)doorOpen
                      secret:(BOOL)secret
                    password:(NSString *)password
                   creatorId:(NSString *)creatorId
                    masterId:(NSString *)masterId;

@end

NS_ASSUME_NONNULL_END
