//
//  BJLPromptTableViewCell.h
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/11/7.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kIcPromptTableViewCellReuseIdentifier = @"kIcPromptTableViewCellReuseIdentifier";

@protocol BJLPromptVCAppearance;

@interface BJLPromptCellModel: NSObject

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
@property (nonatomic, readonly) NSString *prompt;

/**
 init
 
 #param prompt 提示信息
 #param duration 指定时长
 #param important 是否是重要提示
 #return self
 */
- (instancetype)initWithPrompt:(NSString *)prompt duration:(NSInteger)duration important:(BOOL)important;

@end

@interface BJLPromptTableViewCell: UITableViewCell

/// 通过此方法设置一些ui外观，在初始化后就要调用。处于性能考虑尽量只在cell初始化后调用一次即可
/// @param appearance id<BJLPromptVCAppearance>
- (void)setupAppearance:(id<BJLPromptVCAppearance>)appearance;

/**
 更新 cell

 #param promptModel BJLIcPromptModel
 */
- (void)updateWithPromptModel:(BJLPromptCellModel *)promptModel;

/**
 更新 cell，cell 不会被点击消失

 #param promptModel promptModel
 */
- (void)updateWithSpecialPromptModel:(BJLPromptCellModel *)promptModel;

@end

NS_ASSUME_NONNULL_END
