//
//  VloudDataChannel.h
//  sources
//
//  Created by lw0717 on 2021/1/15.
//

#import <Foundation/Foundation.h>
#import "RTCMacros.h"
#import "RTCAudioSink.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface VloudAudioSink : NSObject

@property (nonatomic, weak) id<VloudAudioSinkDelegate> delegate;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *streamID;

- (instancetype)init;

- (instancetype)initWithDelegate:(id<VloudAudioSinkDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
