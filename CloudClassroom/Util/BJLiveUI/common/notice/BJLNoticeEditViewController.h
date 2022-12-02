//
//  BJLNoticeEditViewController.h
//  BJLiveUI
//
//  Created by fanyi on 2019/9/18.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 老师/助教角色，仅可以对公告和通知进行编辑
 全体公告由大班助教/老师进行编辑，全部成员可见
 小组通知为组内成员可见，由分组的助教（小班老师）进行编辑，其他组不可见
 */

@interface BJLNoticeEditViewController: BJLScrollViewController
@property (nonatomic, copy, nullable) void (^keyboardShowCallback)(void);
@property (nonatomic, copy, nullable) void (^keyboardHideCallback)(void);
@property (nonatomic, nullable) void (^closeCallback)(void);
- (instancetype)initWithRoom:(BJLRoom *)room;
- (BOOL)closeKeyboardIfNeeded;
- (void)showEditView;
@end

NS_ASSUME_NONNULL_END
