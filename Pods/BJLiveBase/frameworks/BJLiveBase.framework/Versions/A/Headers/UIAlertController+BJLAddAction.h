//
//  UIAlertController+BJLAddAction.h
//  M9Dev
//
//  Created by MingLQ on 2017-01-20.
//  Copyright (c) 2017 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (BJLAddAction)

- (UIAlertAction *)bjl_addActionWithTitle:(nullable NSString *)title
                                    style:(UIAlertActionStyle)style
                                  handler:(void (^_Nullable)(UIAlertAction *action))handler;

@end

#pragma mark -

@interface UIAlertAction (BJLAddAction)

@property (nonatomic, setter=bjl_setChecked:) BOOL bjl_checked;

@end

#pragma mark -

@interface UIPopoverPresentationController (BJLAlertController)

- (void)bjl_setSourceView:(UIView *)sourceView sourceRect:(CGRect (^_Nullable)(UIView *sourceView))sourceRect;

@end

#pragma mark -

@interface UIWindow (BJLAlertController)

+ (void)bjl_presentAlertController:(UIAlertController *)alert
                          animated:(BOOL)flag
                        completion:(void (^_Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
