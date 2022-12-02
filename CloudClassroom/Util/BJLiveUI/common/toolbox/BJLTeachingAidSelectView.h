//
//  BJLTeachingAidSelectView.h
//  BJLiveUI
//
//  Created by 凡义 on 2020/6/4.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLDrawSelectionBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLTeachingAidOptionCell: UICollectionViewCell

@end

@interface BJLTeachingAidSelectView: BJLDrawSelectionBaseView

// 打开网页
@property (nonatomic) void (^openWebViewCallback)(void);

// 小黑板
@property (nonatomic) void (^clickWritingBoardCallback)(void);

// 答题器
@property (nonatomic) void (^questionAnswerCallback)(void);

// 抢答题
@property (nonatomic) void (^questionResponderCallback)(void);

// 计时器
@property (nonatomic) void (^countDownCallback)(void);

// 点名
@property (nonatomic) void (^rollCallCallback)(void);

// 红包
@property (nonatomic) void (^envelopeRainCallback)(void);

// badge change
@property (nonatomic) void (^badgeStateDidChangeCallback)(BJLTeachingAidSelectView *view);
- (instancetype)initWithRoom:(BJLRoom *)room fullScreenWidth:(BOOL)fullScreenWidth;
- (void)showRollCallBadge:(BOOL)show;
- (BOOL)rollCallBadgeDidShown;
@end

NS_ASSUME_NONNULL_END
