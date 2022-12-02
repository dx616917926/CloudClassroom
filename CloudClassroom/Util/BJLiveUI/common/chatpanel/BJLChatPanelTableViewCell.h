//
//  BJLChatPanelTableViewCell.h
//  BJLiveUI
//
//  Created by 凡义 on 2021/4/6.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

#import "BJLPromptTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kChatPanelTableViewCellReuseIdentifier = @"kChatPanelTableViewCellReuseIdentifier";

@interface BJLChatPanelModel: NSObject

/**
 提示是否达到显示的最大时长, 从创建时开始计时
 */
@property (nonatomic, readonly) BOOL reachMaxDuration;

/**
 消息显示最大时长, 0代表不消失
 */
@property (nonatomic, readonly) NSInteger maxDuration;

/**
 是否是重要提示
 */
@property (nonatomic, readonly) BOOL important;

/**
 提示内容
 */
@property (nonatomic, readonly) BJLMessage *message;

/**
 init
 
 #param message 信息
 #param duration 指定时长
 #param important 是否是重要提示
 #return self
 */
- (instancetype)initWithMessage:(BJLMessage *)message duration:(NSInteger)duration important:(BOOL)important;

@end

@interface BJLChatPanelTableViewCell: UITableViewCell

/**
 更新 cell

 #param panelModel BJLChatPanelModel
 */

- (void)updateWithMessagePanelModel:(BJLChatPanelModel *)panelModel roomType:(BJLRoomType)type;

@end

NS_ASSUME_NONNULL_END
