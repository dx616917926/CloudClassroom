//
//  BJLChatPanelViewController.h
//  BJLiveUI
//
//  Created by 凡义 on 2021/4/6.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLChatPanelViewController: BJLTableViewController

@property (nonatomic, nullable) void (^clickCellCallback)(void);
- (instancetype)initWithRoomType:(BJLRoomType)roomType;

/**
 新增提示，默认时长 BJLIcAppearance.chatPromptDuration(=3)

 #param message 新消息
 */
- (void)enqueueWithNewMessage:(BJLMessage *)message;

/**
 新增提示，默认不重要

 #param message 新消息
 #param duration 指定提示时长，传 <=0 的值代表不计时长
 */
- (void)enqueueWithNewMessage:(BJLMessage *)message duration:(NSInteger)duration;

/**
 新增提示

 #param message 提示消息
 #param duration 指定提示时长，传 <=0 的值代表不计时长
 #param important 是否是重要提示，重要提示标红显示
 */
- (void)enqueueWithMessage:(BJLMessage *)message duration:(NSInteger)duration important:(BOOL)important;

/**
 新增特殊提示，不在入队列中，始终在最上方

 #param prompt 提示文本
 #param duration 指定提示时长，传 <=0 的值代表不计时长
 #param important 是否是重要提示，重要提示标红显示
 */
- (void)enqueueWithSpecialPromptMessage:(BJLMessage *)message duration:(NSInteger)duration important:(BOOL)important;

/**
 清空飘窗数据源
 */
- (void)clearDatasource;

/**
 撤回消息
 */
- (void)revokeMessageWithMessageID:(NSString *)messageID;

@end

NS_ASSUME_NONNULL_END
