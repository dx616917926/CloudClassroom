//
//  BJLStudyReportDataSource.h
//  BJLiveCore
//
//  Created by HuXin on 11/1/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJLStudyReportItem.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, BJLStudyReportStage) {
    BJLStudyReportStageInit,
    BJLStudyReportStageGenerating,
    BJLStudyReportStageDownloading,
    BJLStudyReportStageCancel
};

typedef NS_ENUM(NSInteger, BJLStudyReportPollingState) {
    BJLStudyReportPollingStateNotExit = -1,
    BJLStudyReportPollingStateNormal,
    BJLStudyReportPollingStatePreparing,
    BJLStudyReportPollingStateBuilding,
    BJLStudyReportPollingStateSuccess,
    BJLStudyReportPollingStateFailed
};

typedef void (^BJLStudyReportDataSourceBlock)(BJLStudyReportPollingState pollingState, NSArray<BJLStudyReportItem *> *_Nullable reportList, NSError *_Nullable error);

@interface BJLStudyReportDataSource: NSObject
@property (nonatomic, assign, readonly) BJLStudyReportStage stage;

// 请用 BJLRoomVM 里面的 getStudyReportDataSource 来获取实例
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
    老师获取学情报告的步骤为：提交任务、轮询状态、获取结果，对应的步骤状态可以在 stage 中查询，
    用户只需调用该方法，即可自动完成所有步骤，若有中断继续调用该方法会继续步骤直到获取结果。
    任务结果后重复调用该方法只会获取最后得到的结果，
    一个对象只能用一次，下一次获取学情报告需要重新生成一个对象。
 */
- (void)generateStudyReportWithCompletion:(BJLStudyReportDataSourceBlock)completion;

- (void)cancel;
@end

NS_ASSUME_NONNULL_END
