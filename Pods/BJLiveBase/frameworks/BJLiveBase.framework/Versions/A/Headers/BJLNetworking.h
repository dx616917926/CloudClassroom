//
//  BJLNetworking.h
//  M9Dev
//
//  Created by MingLQ on 2016-08-20.
//  Copyright (c) 2016 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

// #if __has_include(<AFNetworking/AFNetworking.h>)
// #import <AFNetworking/AFNetworking.h>
// @compatibility_alias BJLNetworking AFHTTPSessionManager;
// @protocol BJLMultipartFormData <AFMultipartFormData>
// @end
// #else
#import "BJLAFNetworking.h"
@compatibility_alias BJLNetworking BJLAFHTTPSessionManager;
@protocol BJLMultipartFormData <BJLAFMultipartFormData>
@end
// #endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLNetworkType) {
    BJLNetworkTypeNone = 0,
    BJLNetworkTypeWiFi = 1,
    BJLNetworkType2G   = 2,
    BJLNetworkType3G   = 3,
    BJLNetworkType4G   = 4,
    BJLNetworkType5G   = 5,
    BJLNetworkTypeUnknown = - 1,
    BJLNetworkTypeUnknownWWAN = - 2
};

@interface BJLAFNeverStopReachabilityManager: BJLAFNetworkReachabilityManager

+ (instancetype)sharedManager;
- (void)stopMonitoring NS_UNAVAILABLE;

@property (nonatomic, readonly) BJLNetworkType networkType;
@property (nonatomic, readonly) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@end

#define BJLNeverStopReachability [BJLAFNeverStopReachabilityManager bjl_sharedManager]

#pragma mark -

@protocol BJLResponse;

FOUNDATION_EXPORT NSString * BJLMimeTypeForPathExtension(NSString *extension);

/*
@interface BJLNetworking <BJLResponseType: id<BJLResponse>>: AFHTTPSessionManager
@end */

// NSURLSessionTask: All task properties support key-value observing.
// NSProgress: At least totalUnitCount, completedUnitCount, and fractionCompleted, support Key-Value Observing.

@interface BJLNetworking (BJLNetworkingExt)

+ (instancetype)bjl_manager;
+ (instancetype)bjl_managerWithBaseURL:(nullable NSURL *)url;
+ (instancetype)bjl_managerWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration;
+ (instancetype)bjl_managerWithBaseURL:(nullable NSURL *)url
                  sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration;

+ (instancetype)bjl_defaultManager;

/**
 *  #return parameters to send
 */
@property (nonatomic, copy, nullable) NSDictionary * _Nullable (^parametersFilter)(NSString *urlString, NSDictionary * _Nullable parameters);
/**
 *  #return request to send
 *  !!!: return nil to cancel - will not call completion
 */
@property (nonatomic, copy, nullable) NSURLRequest * _Nullable (^requestFilter)(NSString *urlString, NSMutableURLRequest * _Nullable request, NSError * _Nullable __autoreleasing *error);
/**
 *  #param progress     progress-block from request
 *  #return progress-block to task
 */
@property (nonatomic, copy, nullable) void (^(^uploadProgressFilter)(void (^progressHandler)(__kindof NSURLSessionTask *, NSProgress *)))(__kindof NSURLSessionTask *task, NSProgress *progress);
@property (nonatomic, copy, nullable) void (^(^downloadProgressFilter)(void (^progressHandler)(__kindof NSURLSessionTask *, NSProgress *)))(__kindof NSURLSessionTask *task, NSProgress *progress);
/**
 *  #return response object for completions
 *  !!!: return nil to cancel - will not call completion
 *  e.g.
 *      return responseObject && !error ? [BJLResponse responseWithObject:responseObject] : [BJLResponse responseWithObject:responseObject error:error]
 */
@property (nonatomic, copy, nullable) __kindof NSObject<BJLResponse> * _Nullable (^responseFilter)(__kindof NSURLSessionTask * _Nullable task, id _Nullable responseObject, NSError * _Nullable error);

/** default: YES */
@property (nonatomic) BOOL autoResume;

// progress for get: download progress
- (nullable NSURLSessionDataTask *)bjl_GET:(NSString *)urlString
                                parameters:(nullable NSDictionary *)parameters
                                completion:(nullable void (^)(NSURLSessionDataTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;
- (nullable NSURLSessionDataTask *)bjl_GET:(NSString *)urlString
                                parameters:(nullable NSDictionary *)parameters
                                  progress:(nullable void (^)(NSURLSessionDataTask *task, NSProgress *downloadProgress))progress
                                completion:(nullable void (^)(NSURLSessionDataTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;

// progress for post: upload progress
- (nullable NSURLSessionDataTask *)bjl_POST:(NSString *)urlString
                                 parameters:(nullable NSDictionary *)parameters
                                 completion:(nullable void (^)(NSURLSessionDataTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;
- (nullable NSURLSessionDataTask *)bjl_POST:(NSString *)urlString
                                 parameters:(nullable NSDictionary *)parameters
                                   progress:(nullable void (^)(NSURLSessionDataTask *task, NSProgress *uploadProgress))progress
                                 completion:(nullable void (^)(NSURLSessionDataTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;

/**
 *  #param constructing Different from `AFNetworking` - Call `failure` if an error occurs when constructing the HTTP body.
 *  - #param error      Pass it directly to the method `[formData appendPartWith...:error]`.
 *  - #return           The value returned from the method `[formData appendPartWith...]`.
 *  #param progress     Note this block is called on the session queue, not the main queue.
 *  background uploading:
 *  + [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:]
 *  - [UIApplicationDelegate application:handleEventsForBackgroundURLSession:completionHandler:]
 */
- (nullable NSURLSessionUploadTask *)bjl_upload:(NSString *)urlString
                                     parameters:(nullable NSDictionary *)parameters
                                   constructing:(nullable BOOL (^)(id <BJLMultipartFormData> formData, NSError * _Nullable __autoreleasing *error))constructing
                                       progress:(nullable void (^)(NSURLSessionUploadTask *task, NSProgress *uploadProgress))progress
                                     completion:(nullable void (^)(NSURLSessionUploadTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;

/**
 *  #param progress     Note this block is called on the session queue, not the main queue.
 *  background downloading:
 *  + [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:]
 *  - [UIApplicationDelegate application:handleEventsForBackgroundURLSession:completionHandler:]
 */
- (nullable NSURLSessionDownloadTask *)bjl_download:(NSString *)urlString
                                         parameters:(nullable NSDictionary *)parameters
                                           progress:(nullable void (^)(NSURLSessionDownloadTask *task, NSProgress *downloadProgress))progress
                                        destination:(nullable NSURL * (^)(NSURLSessionDownloadTask * _Nullable task, NSURL *targetPath, NSURLResponse *response))destination
                                         completion:(nullable void (^)(NSURLSessionDownloadTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;
/**
 *  #param progress     At least one of `urlString` and `resumeData` MUST NOT be nil.
 *  #see `bjl_addHandlersForDownloadTask:progress:destination:completionHandler:`
 */
- (nullable NSURLSessionDownloadTask *)bjl_download:(nullable NSString *)urlString
                                         parameters:(nullable NSDictionary *)parameters
                                         resumeData:(nullable NSData *)resumeData
                                           progress:(nullable void (^)(NSURLSessionDownloadTask *task, NSProgress *downloadProgress))progress
                                        destination:(nullable NSURL * (^)(NSURLSessionDownloadTask * _Nullable task, NSURL *targetPath, NSURLResponse *response))destination
                                         completion:(nullable void (^)(NSURLSessionDownloadTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;

- (void)bjl_setHandlersForDataTask:(NSURLSessionDataTask *)dataTask
                    uploadProgress:(nullable void (^)(NSURLSessionDataTask *task, NSProgress *uploadProgress))uploadProgress
                  downloadProgress:(nullable void (^)(NSURLSessionDataTask *task, NSProgress *downloadProgress))downloadProgress
                        completion:(nullable void (^)(NSURLSessionDataTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;

- (void)bjl_setHandlersForUploadTask:(NSURLSessionUploadTask *)uploadTask
                      uploadProgress:(nullable void (^)(NSURLSessionUploadTask *task, NSProgress *uploadProgress))uploadProgress
                          completion:(nullable void (^)(NSURLSessionUploadTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;

- (void)bjl_setHandlersForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                      downloadProgress:(nullable void (^)(NSURLSessionDownloadTask *task, NSProgress *downloadProgress))downloadProgress
                           destination:(nullable NSURL * (^)(NSURLSessionDownloadTask * _Nullable task, NSURL *targetPath, NSURLResponse *response))destination
                            completion:(nullable void (^)(NSURLSessionDownloadTask * _Nullable task, __kindof NSObject<BJLResponse> *response))completion;

- (void)bjl_removeHandlersForTask:(NSURLSessionTask *)task;

@end

#pragma mark -

@protocol BJLResponse <NSObject>

/**
 *  #param responseObject   JSON object, or NSURL for NSURLSessionDownloadTask
 */
+ (instancetype)responseWithObject:(nullable id)responseObject;
+ (instancetype)responseWithObject:(nullable id)responseObject error:(nullable NSError *)error;
+ (instancetype)responseWithError:(nullable NSError *)error;

@property (nonatomic, readonly, getter=isSuccess) BOOL success;
@property (nonatomic, readonly, nullable) id responseObject;
@property (nonatomic, readonly, nullable) NSError *error;

@end

#pragma mark -

@interface BJLResponse: NSObject <BJLResponse>

@end

NS_ASSUME_NONNULL_END
