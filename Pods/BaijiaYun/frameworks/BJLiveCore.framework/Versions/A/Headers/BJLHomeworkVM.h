//
//  BJLHomeworkVM.h
//  BJLiveCore
//
//  Created by 凡义 on 2020/8/25.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLBaseVM.h"
#import "BJLHomework.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLHomeworkVM: BJLBaseVM

#pragma mark - homework

/** 直播间作业列表 */
@property (nonatomic, readonly, copy, nullable) NSArray<BJLHomework *> *allHomeworks;

/**
 重新加载所有作业
 #discussion 连接直播间后、掉线重新连接后自动调用加载
 #discussion 加载成功后更新 `allHomeworks`、调用 `allHomeworksDidOverwrite:`
 */
- (nullable BJLError *)reloadAllHomeworks;

/**
 `allHomeworks` 被覆盖更新
 #discussion 覆盖更新才调用，增量更新不调用
 #param allHomeworks 所有课件
 */
- (BJLObservable)allHomeworksDidOverwrite:(nullable NSArray<BJLHomework *> *)homeworks;

@property (nonatomic, readonly) BOOL hasMoreHomeworks;

/** 分页加载更多作业 */
- (nullable BJLError *)loadMoreHomeworksWithCount:(NSUInteger)count;

/**
 当前直播间是否所有学生都支持作业功能
 #discussion NO 表示当前直播间存在不支持作业功能的用户
 */
@property (nonatomic, readonly) BOOL allStudentsSupportHomework;

/** 是否支持学生上传作业 */
@property (nonatomic, readonly) BOOL allowStudentUploadHomework;

/**
 学生能否上传作业
 #discussion 设置成功将回调 `BJLHomeworkVM` 的 `didReceiveAllowStudentUploadHomework:`
 #return BJLError:
 BJLErrorCode_invalidUserRole  仅支持老师/助教身份操作
 */
- (nullable BJLError *)requestAllowStudentUploadHomework:(BOOL)allow;

/**
 学生是否被允许上传作业通知
 */
- (BJLObservable)didReceiveAllowStudentUploadHomework:(BOOL)allow;

/**
 根据关键字`keywork`搜索
 #discussion 搜索范围: 作业名称和作业上传者用户名
 #param lastHomework 上次分页请求的最后一个作业数据, 传nil表示首次拉取分页数据
 */
- (nullable BJLError *)searchHomeworksWithKeyword:(NSString *)keyword
                                     lastHomework:(nullable BJLHomework *)lastHomework
                                            count:(NSUInteger)count;

/** 搜索结果返回*/
- (BJLObservable)didReceiveHomeworkSearchResultWithKeyword:(NSString *)keywork
                                                      list:(nullable NSArray<BJLHomework *> *)homeworks
                                                   hasmore:(BOOL)hasmore;

/**
 添加作业通知
 #discussion 同时更新 `allHomeworks`
 #param homeworks 作业列表
 */
- (BJLObservable)didAddHomeworks:(NSArray<BJLHomework *> *)homeworks;

/**
 添加作业
 #discussion 添加成功将调用 `BJLHomeworkVM` 的 `didAddHomeworks:`
 #param homework 作业
 #return BJLError:
 BJLErrorCode_invalidArguments  错误参数
 */
- (nullable BJLError *)addHomework:(BJLHomework *)homework;

/**
 删除作业通知
 #discussion 同时更新 `allHomeworks`
 #param homeworks 作业列表
 */
- (BJLObservable)didDeleteHomework:(BJLHomework *)document;

/**
 删除作业
 #discussion 添加成功将调用 `BJLHomeworkVM` 的 `didDeleteHomework:`
 #param homeworkID 作业ID
 */
- (nullable NSURLSessionDataTask *)requestDeleteHomeworkWithHomeworkID:(nullable NSString *)homeworkID
                                                            completion:(nullable void (^)(BOOL success, BJLError *_Nullable error))completion;

#pragma mark -

/**
 上传作业文档
 #discussion 图片作为文档上传没有转码过程，其余的作业等文档需要等待转码过程
 #discussion 转码服务器主动进行，不需要调用其他接口
 #param fileURL 本地文档路径
 #param mimeType 文档类型
 #param fileName 文件名
 #param progress 进度 0.0 ~ 1.0
 #param finish 结束回调
 - homework         非 nil 即为成功，用于 `addHomework:`
 - document         非 nil 即为成功，可按需调用`BJLDocumentVM`的`addDocument:`同步到直播间内文件打开
 - error            错误
 #return task
 */
- (nullable NSURLSessionUploadTask *)uploadHomeworkFile:(NSURL *)fileURL
                                               mimeType:(NSString *)mimeType
                                               fileName:(NSString *)fileName
                                               progress:(nullable void (^)(CGFloat progress))progress
                                                 finish:(void (^)(BJLHomework *_Nullable homework, BJLDocument *_Nullable document, BJLError *_Nullable error))finish;

/**
 请求下载作业
 #param finish 结束回调
 - downloadUrl       下载地址
 */
- (nullable NSURLSessionDataTask *)requestDownloadURLWithHomeworkID:(nullable NSString *)homeworkID
                                                         completion:(nullable void (^)(BOOL success, BJLError *_Nullable error, NSString *_Nullable downloadUrl))completion;

/**
 用于强制同步直播间内作业
 #return BJLError:
 BJLErrorCode_invalidUserRole  仅支持老师/助教身份操作
 */
- (nullable NSURLSessionDataTask *)requestForceRefreshHomeworkListWithCompletion:(nullable void (^)(BOOL success, BJLError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
