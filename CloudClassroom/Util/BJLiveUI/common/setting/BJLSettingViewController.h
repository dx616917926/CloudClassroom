//
//  BJLSettingViewController.h
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/10/15.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKey_camera;
FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKey_mic;
FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKey_roomcontrol;
FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKey_ppt;
FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKey_beauty;
FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKey_other;
FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKey_debug;

FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionKeyString;
FOUNDATION_EXPORT NSString *const BJLSettingMenuOptionNameString;

@interface BJLSettingViewController: BJLScrollViewController

@property (nonatomic, readonly, weak) BJLRoom *room;
@property (nonatomic) NSDictionary<NSString *, NSArray<__kindof UIView *> *> *rightDataSource; // key为左侧选中操作, array为右侧所有菜单
@property (nonatomic) NSArray<NSDictionary *> *leftContainerViewDataSource;

@property (nonatomic, nullable) void (^showHandWritingBoardViewCallback)(void);
@property (nonatomic, nullable) void (^closeCallback)(void);

- (instancetype)initWithRoom:(BJLRoom *)room;

- (void)upadteCurrentOptionViews;

@end

NS_ASSUME_NONNULL_END
