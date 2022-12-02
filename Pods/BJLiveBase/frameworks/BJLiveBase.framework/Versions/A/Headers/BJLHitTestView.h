//
//  BJLHitTestView.h
//  M9Dev
//
//  Created by MingLQ on 2017-04-05.
//  Copyright (c) 2017 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef UIView *_Nullable (^_Nullable BJLHitTestBlock)(UIView *_Nullable hitView, CGPoint point, UIEvent *_Nullable event);

// #see [-hitTest:withEvent: called twice?](https://www.mail-archive.com/cocoa-dev@lists.apple.com/msg92544.html)
@interface BJLHitTestView: UIView

+ (instancetype)viewWithHitTestBlock:(UIView *_Nullable (^)(UIView *_Nullable hitView, CGPoint point, UIEvent *_Nullable event))hitTestBlock;
+ (instancetype)viewWithFrame:(CGRect)frame hitTestBlock:(UIView *_Nullable (^)(UIView *_Nullable hitView, CGPoint point, UIEvent *_Nullable event))hitTestBlock;

@property (nonatomic, readwrite, copy) BJLHitTestBlock hitTestBlock;
- (void)setHitTestBlock:(UIView *_Nullable (^)(UIView *_Nullable hitView, CGPoint point, UIEvent *_Nullable event))hitTestBlock;

@end

NS_ASSUME_NONNULL_END
