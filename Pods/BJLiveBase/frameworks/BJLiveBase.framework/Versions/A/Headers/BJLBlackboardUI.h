//
//  BJLBlackboardUI.h
//  BJLiveCore
//
//  Created by 凡义 on 2018/12/7.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** ### 专业版小班课黑板 API */
@protocol BJLBlackboardUI <NSObject>

/// 黑板的总页码，翻页行为是竖直滑动
@property (nonatomic, readonly) NSInteger pageCount;

/// 当前黑板页码，不能超过黑板总页码，否则滑动到底部
@property (nonatomic) CGFloat localPageIndex;

/// 黑板是否支持滑动，默认不可滑动，滑动情况下会同步直播间黑板状态
/// #discussion 开启画笔的情况下，不能滑动翻页
@property (nonatomic, readonly) BOOL scrollEnabled;
- (void)updateScrollEnabled:(BOOL)scrollEnabled;

#pragma mark -

/// 画笔开关状态，默认为 NO，不可使用画笔
@property (nonatomic, readonly) BOOL drawingEnabled;
- (void)updateDrawingEnabled:(BOOL)drawingEnabled;

/// 设置黑板的背景图片，显示成填充模式
/// @param image 图片数据，存在时忽略图片 URL，显示大小和黑板实际高度相同
/// @param imageURLString 图片 URL，显示大小和黑板可见高度相同
- (void)updateBlackboardImage:(nullable UIImage *)image imageURLString:(nullable NSString *)imageURLString;

@end

NS_ASSUME_NONNULL_END
