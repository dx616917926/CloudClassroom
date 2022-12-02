//
//  BJPPPTCatalogueModel.h
//  BJPlaybackUI
//
//  Created by 凡义 on 2021/1/12.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 某一页PPT的翻页信息 */
@interface BJPPPTCatalogueModel: NSObject <BJLYYModel>

@property (readonly, nonatomic, copy) NSString *docID;

@property (readonly, nonatomic) NSInteger msOffsetTimestamp; // 毫秒级翻页时间
@property (readonly, nonatomic) NSInteger pageIndex; // 在当前课件中的页码, 从0开始
@property (readonly, nonatomic, nullable, copy) NSString *title; // ppt大纲标题

@end

NS_ASSUME_NONNULL_END
