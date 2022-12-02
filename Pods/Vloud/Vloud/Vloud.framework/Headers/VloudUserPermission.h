/***********************
auth: cszdlt@qq.com
date: 2020-05-11 11:16:11
name: VloudUserPermission.h
************************/
#import <Foundation/Foundation.h>

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * R read
 * W write
 * P publish
 * S subscribe
 * A audio
 * V video
 * M manage
 * O own
 */
RTC_OBJC_EXPORT
@interface VloudUserPermission : NSObject

@property(nonatomic, assign) BOOL hasRead;

@property(nonatomic, assign) BOOL hasWrite;

@property(nonatomic, assign) BOOL hasPublish;

@property(nonatomic, assign) BOOL hasSubscribe;

@property(nonatomic, assign) BOOL hasManage;

@property(nonatomic, assign) BOOL hasAudio;

@property(nonatomic, assign) BOOL hasVideo;

@property(nonatomic, assign) BOOL hasOwn;

@property(nonatomic, copy) NSString *permissionStr;

- (instancetype)initWithString:(NSString *)permissionStr;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
