//
//  BJLWindowsUpdateModel.h
//  BJLiveCore
//
//  Created by HuangJie on 2018/11/22.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BJLWindowDisplayInfo.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_open; // 打开
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_updateRect; // 移动 & 缩放
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_stick; // 置顶
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_fullScreen; // 全屏
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_maximize; // 最大化
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_restore; // 还原
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_close; // 关闭
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_rename; // 视图标题更新
FOUNDATION_EXPORT NSString *const BJLWindowsUpdateAction_min; // 视图最小化

/** ### 专业版小班课窗口更新 */
@interface BJLWindowUpdateModel: NSObject

/**
 窗口标识符
 
 #discussion 视频窗口：ID 为 `BJLMediaUser` 的 `mediaID`
 #discussion 文档窗口：ID 为 `BJLDoucument` 的 `documentID`
 */
@property (nonatomic) NSString *ID;

// 更新操作，参考 BJLWindowsUpdateAction
@property (nonatomic) NSString *action;

// 如果是连续的更新操作，有下一个操作时，该字段有值，参考 BJLWindowsUpdateAction，仅为了兼容使用，内部收到带有这个字段的信令直接忽略，不会抛出
@property (nonatomic, nullable) NSString *nextAction;

// 是否为视频窗口信息
@property (nonatomic) BOOL isVideo;

// 窗口展示信息
@property (nonatomic) NSArray<BJLWindowDisplayInfo *> *displayInfos;

@end

NS_ASSUME_NONNULL_END
