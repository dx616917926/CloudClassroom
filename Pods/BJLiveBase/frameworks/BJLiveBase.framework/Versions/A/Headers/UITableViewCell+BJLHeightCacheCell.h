//
//  UITableViewCell+BJLHeightCacheCell.h
//  Pods
//
//  Created by HuangJie on 2017/6/29.
//  Copyright (c) 2017年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (BJLHeightCacheCell)

/**
 是否使用自适应布局
 */
@property (nonatomic, setter=bjl_setAutoSizing:) BOOL bjl_autoSizing;

/**
 是否为用于计算的 cell
 */
@property (nonatomic, setter=bjl_setUsedForCalculating:) BOOL bjl_usedForCalculating;

@end
