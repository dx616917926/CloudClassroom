//
//  BJLCloudDiskVM.h
//  BJLiveCore
//
//  Created by 凡义 on 2020/9/18.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"
#import "BJLCloudFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLCloudDiskVM: BJLBaseVM

/**
 当前直播间是否支持云盘功能
 */
@property (nonatomic, readonly) BOOL enableCloudStorage;

/**
 上传云盘文档
 #discussion 图片作为文档上传没有转码过程，其余的作业等文档需要等待转码过程
 #discussion 转码服务器主动进行，不需要调用其他接口
 #param fileURL 文档路径
 #param mimeType 文档类型
 #param fileName 文件名
 #param isAnimated 动态文件 or 静态文件
 #param progress 进度 0.0 ~ 1.0
 #param finish 结束回调
 - homework         非 nil 即为成功
 - document         非 nil 即为成功，可按需调用`BJLDocumentVM`的`addDocument:`同步到直播间内文件打开
 - error            错误
 #return task
 */
- (nullable NSURLSessionUploadTask *)uploadCloudFile:(NSURL *)fileURL
                                            mimeType:(NSString *)mimeType
                                            fileName:(NSString *)fileName
                                          isAnimated:(BOOL)isAnimated
                                            progress:(nullable void (^)(CGFloat progress))progress
                                              finish:(void (^)(BJLCloudFile *_Nullable cloudFile, BJLError *_Nullable error))finish;

/**
 请求云盘文件列表
 #param targetFinderID 请求目录的finderID，为空表示请求根目录列表
 #param page 从第一页开始
 */
- (nullable NSURLSessionDataTask *)requestCloudListWithTargetFinderID:(nullable NSString *)targetFinderID
                                                                 page:(NSUInteger)page
                                                             pagesize:(NSUInteger)pagesize
                                                           completion:(nullable void (^)(NSArray<BJLCloudFile *> *_Nullable documentList, BJLError *_Nullable error))completion;

/**
 请求删除云盘文件，仅支持删除文件，不支持删除文件夹
 */
- (nullable NSURLSessionDataTask *)requestDeleteCloudFileWithFileID:(NSString *)fileID
                                                         completion:(nullable void (^)(BOOL success, BJLError *_Nullable error))completion;

/**
 请求搜索云盘文件
 #param keyword 搜索关键词
 #param targetFinderID 搜索目录的finderID，为空表示在根目录搜索
 #param page 从第一页开始
 */
- (nullable NSURLSessionDataTask *)requestSearchCloudFileListWithKeyword:(NSString *)keyword
                                                          targetFinderID:(nullable NSString *)targetFinderID
                                                                    page:(NSUInteger)page
                                                                pagesize:(NSUInteger)pagesize
                                                              completion:(nullable void (^)(NSString *keyword, NSArray<BJLCloudFile *> *_Nullable documentList, BJLError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
