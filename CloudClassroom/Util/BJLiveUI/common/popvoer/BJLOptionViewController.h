//
//  BJLOptionViewController.h
//  BJLiveUI-Base
//
//  Created by Ney on 7/27/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLOptionConfig: NSObject
@property (nonatomic, strong) UIColor *optionColor;
@property (nonatomic, strong) UIColor *selectedoptionColor;
@property (nonatomic, strong) UIColor *backgroudColor;
@property (nonatomic, strong) UIColor *selectedBackgroudColor;
@property (nonatomic, assign) NSInteger preselectedIndex;
@property (nonatomic, assign) CGFloat optionHeight;
@property (nonatomic, assign) CGFloat optionWidth;

+ (instancetype)defaultConfig;
@end

@interface BJLOptionViewController: UIViewController
@property (nonatomic, copy) void (^eventBlock)(BJLOptionViewController *vc, NSInteger selectedIndex, NSInteger previousSelectedIndex, BOOL isCancel);
@property (nonatomic, copy) UIControl * (^optionCellBuilderBlock)(BJLOptionViewController *vc, NSInteger index, NSString *option);
@property (nonatomic, readonly) NSArray<NSString *> *options;

/// pop的sourceView, rect 就是 sourceView的bounds
@property (nonatomic, strong) UIView *sourceView;

- (instancetype)initWithConfig:(BJLOptionConfig *)config options:(NSArray<NSString *> *)options;
- (void)updatePopoverProperty;
+ (instancetype)viewControllerWithOptions:(NSArray<NSString *> *)options preselectedIndex:(NSInteger)preselectedIndex eventBlock:(void (^)(BJLOptionViewController *vc, NSInteger selectedIndex, NSInteger previousSelectedIndex, BOOL isCancel))eventBlock;
- (UIButton *)defaultCellForOption:(NSString *)option index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
