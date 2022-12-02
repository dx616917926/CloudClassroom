
#import <Foundation/Foundation.h>

#import "RTCMacros.h"

#import "VloudStream.h"
@class VloudStreamConfig;
@class VloudVideoRenderer;
@protocol VloudVideoCapture;

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@protocol VloudScreenDelegate <NSObject>
@optional
- (void)vloudScreenRemoteStreamAdded;
- (void)vloudScreenRemoteStreamRemoved;
- (void)vloudScreenRemoteLeave;
- (void)vloudScreenError:(int)code message:(NSString *)message;
- (void)vloudScreenChannelConnected;
- (void)vloudScreenChannelConnectFailed:(int)code message:(NSString *)message;
- (void)vloudScreenChannelDisconnected:(BOOL)manual_close;
- (void)vloudScreenChannelReconnectComplete:(BOOL)has_change;
- (void)vloudScreenChannelReconnectFailed;
- (void)vloudScreenIceConnectionChanged:(VloudStreamConnectionState)state;
@end

RTC_OBJC_EXPORT
@interface VloudScreen : NSObject

/// 用于接收 VloudClient 事件回调
@property(nonatomic, weak, nullable) id<VloudScreenDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDelegate:(id<VloudScreenDelegate>)delegate;

- (void)joinChannel:(NSString *)url
          channelId:(NSString *)channelId
              token:(NSString *)token
             config:(VloudStreamConfig *)config
            timeOut:(NSInteger)timeOut;

- (void)destroy;

- (void)disconnect;

/**
 * 设置视频源
 * @param capture 视频源
 */
- (void)setVideoCaptrue:(id<VloudVideoCapture>)capture;

// /**
//  * 添加当前流的渲染 View
//  * @param renderer @see <VloudVideoRenderer>
//  */
// - (void)addRenderer:(VloudVideoRenderer *)renderer;

// /**
//  * 为当前流移除视频渲染 View
//  * @param renderer @see <VloudVideoRenderer>
//  */
// - (void)removeRenderer:(VloudVideoRenderer *)renderer;

/**
 * 退出房间
 * 退出后关闭与服务器建立的连接
 */
- (void)leaveChannel;

- (void)publish;

- (void)unpublish;

- (void)publishAudioEnable:(BOOL)audioEnable;
@end

NS_ASSUME_NONNULL_END
