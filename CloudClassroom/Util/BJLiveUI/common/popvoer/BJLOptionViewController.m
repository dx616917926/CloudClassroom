//
//  BJLOptionViewController.m
//  BJLiveUI-Base
//
//  Created by Ney on 7/27/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLOptionViewController.h"
#import "BJLAppearance.h"

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

@implementation BJLOptionConfig
+ (instancetype)defaultConfig {
    BJLOptionConfig *config = [[BJLOptionConfig alloc] init];
    config.optionColor = BJLTheme.viewTextColor;
    config.selectedoptionColor = BJLTheme.brandColor;
    config.backgroudColor = BJLTheme.windowBackgroundColor;
    config.selectedBackgroudColor = BJLTheme.separateLineColor;
    config.preselectedIndex = 0;
    config.optionHeight = 24;
    config.optionWidth = 80;
    return config;
}
@end

@interface BJLOptionViewController () <UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) BJLOptionConfig *config;
@property (nonatomic, readwrite) NSArray<NSString *> *options;
@property (nonatomic, strong) NSMutableArray *optionsUIArray;
@property (nonatomic, strong) UIStackView *vstackView;

@property (nonatomic, assign) NSInteger currentSelectedIndex;
@property (nonatomic, assign) NSInteger previousSelectedIndex;
@property (nonatomic, assign) BOOL manuallyDismiss;
@end

@implementation BJLOptionViewController
- (instancetype)initWithConfig:(BJLOptionConfig *)config options:(NSArray<NSString *> *)options {
    self = [super init];
    if (self) {
        if (options == nil || config == nil) { return nil; }

        self.config = config;
        self.options = options;
    }
    return self;
}

- (CGSize)popoverMenuSize {
    return CGSizeMake(self.config.optionWidth, self.options.count * self.config.optionHeight);
}

+ (instancetype)viewControllerWithOptions:(NSArray<NSString *> *)options preselectedIndex:(NSInteger)preselectedIndex eventBlock:(void (^)(BJLOptionViewController *vc, NSInteger selectedIndex, NSInteger previousSelectedIndex, BOOL isCancel))eventBlock {
    BJLOptionConfig *config = [BJLOptionConfig defaultConfig];
    config.preselectedIndex = preselectedIndex;
    BJLOptionViewController *vc = [[self alloc] initWithConfig:config options:options];
    vc.eventBlock = eventBlock;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    self.view.backgroundColor = self.config.backgroudColor;
    [self.view addSubview:self.vstackView];
    [self.vstackView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        if (self.popoverPresentationController.arrowDirection == UIPopoverArrowDirectionUp) {
            make.bottom.equalTo(self.view);
        }
        else {
            make.top.equalTo(self.view);
        }
        make.centerX.equalTo(self.view);
    }];
}

- (void)setSourceView:(UIView *)sourceView {
    _sourceView = sourceView;
    [self updatePopoverProperty];
}

- (void)updatePopoverProperty {
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.preferredContentSize = [self popoverMenuSize];

    self.popoverPresentationController.backgroundColor = self.config.backgroudColor;
    self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
    self.popoverPresentationController.delegate = self;
    self.popoverPresentationController.sourceView = _sourceView;
    self.popoverPresentationController.sourceRect = _sourceView.bounds;
}

#pragma mark - helper
- (void)setupUI {
    NSInteger idx = 0;
    for (NSString *o in self.options) {
        UIControl *ctrl = nil;
        if (self.optionCellBuilderBlock) {
            ctrl = self.optionCellBuilderBlock(self, idx, o);
        }
        if (ctrl == nil) {
            ctrl = [self defaultCellForOption:o index:idx];
        }

        [ctrl bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.width.equalTo(@(self.config.optionWidth));
            make.height.equalTo(@(self.config.optionHeight));
        }];

        if (self.config.preselectedIndex >= 0
            && self.config.preselectedIndex < self.options.count
            && idx == self.config.preselectedIndex) {
            ctrl.selected = YES;
            self.currentSelectedIndex = idx;
        }

        ctrl.tag = idx++;

        [self.vstackView addArrangedSubview:ctrl];
        [self.optionsUIArray addObject:ctrl];
    }
}

- (UIButton *)defaultCellForOption:(NSString *)option index:(NSInteger)index {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = index;
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setTitleColor:self.config.optionColor forState:UIControlStateNormal];
    [btn setTitleColor:self.config.selectedoptionColor forState:UIControlStateSelected];
    [btn bjl_setBackgroundColor:self.config.backgroudColor forState:UIControlStateNormal];
    [btn bjl_setBackgroundColor:self.config.selectedBackgroudColor forState:UIControlStateSelected];
    [btn setTitle:option forState:UIControlStateNormal];

    bjl_weakify(self);
    [btn bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        if (button.tag == self.currentSelectedIndex) {
            if (self.eventBlock) {
                self.eventBlock(self, self.currentSelectedIndex, self.currentSelectedIndex, NO);
            }
        }
        else {
            if (self.eventBlock) {
                self.previousSelectedIndex = self.currentSelectedIndex;
                self.currentSelectedIndex = button.tag;
                [self select:NO forIndex:self.previousSelectedIndex];
                [self select:YES forIndex:self.currentSelectedIndex];
                self.eventBlock(self, self.currentSelectedIndex, self.previousSelectedIndex, NO);
            }
        }

        if (self.presentingViewController) {
            self.manuallyDismiss = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    return btn;
}

- (void)select:(BOOL)select forIndex:(NSInteger)index {
    UIButton *btn = self.optionsUIArray[index];
    btn.selected = select;
}

#pragma mark - <UIPopoverPresentationControllerDelegate>
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

//before ios 13.0
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if (!self.manuallyDismiss) {
        if (self.eventBlock) {
            self.eventBlock(self, self.currentSelectedIndex, self.currentSelectedIndex, YES);
        }
    }
    self.manuallyDismiss = NO;
    return YES;
}

//after ios 13.0
- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController {
    if (!self.manuallyDismiss) {
        if (self.eventBlock) {
            self.eventBlock(self, self.currentSelectedIndex, self.currentSelectedIndex, YES);
        }
    }
    self.manuallyDismiss = NO;
}

#pragma mark - getter
- (NSMutableArray *)optionsUIArray {
    if (!_optionsUIArray) {
        _optionsUIArray = [[NSMutableArray alloc] init];
    }
    return _optionsUIArray;
}

- (UIStackView *)vstackView {
    if (!_vstackView) {
        _vstackView = [[UIStackView alloc] init];
        _vstackView.distribution = UIStackViewDistributionFillEqually;
        _vstackView.alignment = UIStackViewAlignmentFill;
        _vstackView.axis = UILayoutConstraintAxisVertical;
    }
    return _vstackView;
}
@end
