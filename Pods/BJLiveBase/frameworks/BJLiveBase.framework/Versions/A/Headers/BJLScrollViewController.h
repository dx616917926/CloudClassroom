//
//  BJLScrollViewController.h
//  M9Dev
//
//  Created by MingLQ on 2017-03-06.
//  Copyright (c) 2017 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>
#import "BJLViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLScrollViewController: BJLViewController {
@protected
    UIScrollView *_scrollView;
}

// [self.scrollView bjl_removeAllConstraints] to remove default constraints
@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic, nullable) UIRefreshControl *refreshControl;

@end

#pragma mark -

@protocol BJLScrollViewDelegate <UIScrollViewDelegate>
@optional
- (BOOL)bjl_scrollView:(UIScrollView *)scrollView
    touchesShouldCancelInContentView:(UIView *)view
                        superDefault:(BOOL)superDefault;
@end

NS_ASSUME_NONNULL_END
