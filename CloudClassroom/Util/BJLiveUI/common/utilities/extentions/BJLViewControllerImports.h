//
//  BJLViewControllerImports.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-08.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLTableViewController+style.h"

NS_ASSUME_NONNULL_BEGIN

/**
 用于判断 BJLiveUI 是否使用横屏模式，BJLiveUI 以外可能不适用
 */
static inline BOOL BJLIsHorizontalTraitCollection(UITraitCollection *traitCollection) {
    return !(traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact
             && traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular);
}
static inline BOOL BJLIsHorizontalUI(id<UITraitEnvironment> traitEnvironment) {
    return BJLIsHorizontalTraitCollection(traitEnvironment.traitCollection);
}

static inline NSString *BJLVideoTitleWithMediaSource(BJLMediaSource mediaSource) {
    switch (mediaSource) {
        case BJLMediaSource_mainCamera:
            return BJLLocalizedString(@"摄像头");

        case BJLMediaSource_mediaFile:
        case BJLMediaSource_extraMediaFile:
            return BJLLocalizedString(@"媒体文件");

        case BJLMediaSource_extraCamera:
            return BJLLocalizedString(@"辅助摄像头");

        case BJLMediaSource_screenShare:
        case BJLMediaSource_extraScreenShare: {
            return BJLLocalizedString(@"屏幕共享");
        }

        case BJLMediaSource_all:
            return BJLLocalizedString(@"所有视频");

        default:
            return BJLLocalizedString(@"摄像头");
    }
}

@protocol BJLRoomChildViewController <NSObject>

@required

/** 初始化
 注意需要 KVO 监听 `room.vmsAvailable` 属性，当值为 YES 时 room 的 view-model 才可用
 *  bjl_weakify(self);
 *  [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
 *         filter:^BOOL(NSNumber * _Nullable now, NSNumber * _Nullable old, BJLPropertyChange * _Nullable change) {
 *             // bjl_strongify(self);
 *             return now.boolValue;
 *         }
 *       observer:^BOOL(NSNumber * _Nullable now, NSNumber * _Nullable old, BJLPropertyChange * _Nullable change) {
 *           bjl_strongify(self);
 *           // room 的 view-model 可用
 *           return NO; // 停止监听 vmsAvailable
 *       }];
 u need: 
 *  @property (nonatomic, readonly, weak) BJLRoom *room;
 *  self->_room = room;
 */
- (instancetype)initWithRoom:(BJLRoom *)room;

@end

@interface UIViewController (BJLRoomActions)

- (void)showProgressHUDWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
