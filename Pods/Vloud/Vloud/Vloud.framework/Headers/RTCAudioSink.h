//
//  RTCAudioSink.h
//  sources
//
//  Created by lw0717 on 2021/1/15.
//

#import <Foundation/Foundation.h>
#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE(RTCAudioSink) <NSObject>

 - (void)onData:(const void*)audioData bitsPerSample:(int)bitsPerSample
     sampleRate:(int)sampleRate numberOfChannels:(size_t)numberOfChannels numberOfFrames:(size_t)numberOfFrames;

@end

RTC_OBJC_EXPORT
@protocol VloudAudioSinkDelegate <NSObject>

 - (void)onData:(const void*)audioData bitsPerSample:(int)bitsPerSample
     sampleRate:(int)sampleRate numberOfChannels:(size_t)numberOfChannels numberOfFrames:(size_t)numberOfFrames userID:(NSString *)userID streamID:(NSString *)streamID;

@end

NS_ASSUME_NONNULL_END
