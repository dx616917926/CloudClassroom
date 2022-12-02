//
//  BJLWindowDisplayInfo.h
//  BJLiveCore
//
//  Created by HuangJie on 2018/11/22.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** ### 专业版小班课窗口显示信息 */
@interface BJLWindowDisplayInfo: NSObject

/**
 窗口标识符
 
 #discussion 视频窗口：ID 为 `BJLMeidaUser` 的 `mediaID`
 #discussion 文档窗口：ID 为 `BJLDoucument` 的 `documentID`
 */
@property (nonatomic) NSString *ID;

// 是否为视频窗口信息
@property (nonatomic) BOOL isVideo;

// 窗口位置
@property (nonatomic) CGFloat x, y;

// 窗口宽高
@property (nonatomic) CGFloat width, height;

// 是否全屏
@property (nonatomic) BOOL isFullScreen;

// 是否最大化
@property (nonatomic) BOOL isMaximized;

// 视图标题
@property (nonatomic) NSString *name;

@end

NS_ASSUME_NONNULL_END
