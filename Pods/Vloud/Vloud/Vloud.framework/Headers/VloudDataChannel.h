//
//  VloudDataChannel.h
//  sources
//
//  Created by lw0717 on 2020/11/3.
//

#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class VloudDataChannel;

RTC_OBJC_EXPORT
@protocol VloudDataChannelDelegate <NSObject>
@optional

- (void)onConnectCompleted:(VloudDataChannel *)vloudDataChannel;

- (void)onDisconnect:(VloudDataChannel *)vloudDataChannel;

- (void)receiveMessage:(NSString *)message on:(VloudDataChannel *)vloudDataChannel;

- (void)failedCode:(NSInteger)code message:(NSString *)msg on:(VloudDataChannel *)vloudDataChannel;

@end

RTC_OBJC_EXPORT
@interface VloudDataChannel : NSObject

@property(nonatomic, weak) id<VloudDataChannelDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUrl:(NSString *)url token:(NSString *)token;

- (void)destroy;

- (void)connect;

- (void)sendMessage:(NSString *)message;

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
