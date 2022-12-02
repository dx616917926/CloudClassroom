//
//  BJVDefinitionInfo.h
//  BJVideoPlayerCore
//
//  Created by HuangJie on 2018/8/24.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BJVDefinitionInfo: NSObject <BJLYYModel>

// 是否为纯音频
@property (nonatomic, readonly) BOOL isAudio;
// 清晰度名称，与 definitionKey 一一对应
@property (nonatomic, readonly) NSString *definitionName;
// 清晰度标识符：low（标清），high（高清），superHD（超清），720p，1080p，audio（纯音频）
@property (nonatomic, readonly) NSString *definitionKey;
// 总时长
@property (nonatomic, readonly) NSInteger duration;
// 文件大小
@property (nonatomic, readonly) NSInteger fileSize;
// 视频画面长度、宽度
@property (nonatomic, readonly) NSInteger width, height;

@end

NS_ASSUME_NONNULL_END
