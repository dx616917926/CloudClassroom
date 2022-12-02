//
//  BJLRollCallViewController.h
//  BJLiveUI
//
//  Created by Ney on 1/11/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>
#import <BJLiveBase/BJLViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLRollCallViewController: BJLViewController
@property (nonatomic, copy) void (^rollCallActiveStateChangeBlock)(BJLRollCallViewController *vc, BOOL rollCallActive);
@property (nonatomic, copy) void (^rollCallAgainBlock)(void);

- (instancetype)initWithRoom:(BJLRoom *)room;
- (void)hideRollCall;
- (CGSize)presentationSize;
- (void)addObserverForStudentIfNeededParentVC:(UIViewController *)parentVC;
- (void)addObserverForTeacherIfNeeded;
@end

NS_ASSUME_NONNULL_END
