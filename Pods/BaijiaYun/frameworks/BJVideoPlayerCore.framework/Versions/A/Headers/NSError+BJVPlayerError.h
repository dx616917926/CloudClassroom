//
//  NSError+BJVPlayerError.h
//  Pods
//
//  Created by DLM on 2017/2/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJVErrorCode) {
    BJVErrorCode_unknown = -999, // 未知错误
    BJVErrorCode_requestFailed = 1000, // 网络请求失败
    BJVErrorCode_invalidToken = 1010, // token 参数错误
    BJVErrorCode_invalidAccessKey = 1020, // 鉴权验证失败
    BJVErrorCode_invalidPlayInfo = 1030, // 播放信息解析错误
    BJVErrorCode_invalidVideoURL = 1040, // 在线播放，视频地址失效
    BJVErrorCode_fileLost = 1050, // 本地播放，播放文件不存在
    BJVErrorCode_playFailed = 1060 // 视频播放失败
};

#define BJPMErrorDomain @"BJPMErrorDomain"

static inline NSError *_Nullable BJVErrorMake(BJVErrorCode errorCode, NSString *_Nullable reason) {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (reason) {
        [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    return [NSError errorWithDomain:@"BJLErrorDomain" code:errorCode userInfo:userInfo];
}

@interface NSError (BJVPlayerError)

+ (NSError *)errorWithErrorCode:(BJVErrorCode)code;

+ (NSError *)errorWithErrorCode:(BJVErrorCode)code message:(NSString *_Nullable)msg;

+ (NSError *)errorWithErrorCode:(BJVErrorCode)code andError:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
