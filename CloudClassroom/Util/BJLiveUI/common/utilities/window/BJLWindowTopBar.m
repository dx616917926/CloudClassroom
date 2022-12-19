//
//  BJLWindowTopBar.m
//  BJLiveUI
//
//  Created by MingLQ on 2018-09-25.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase+Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLWindowTopBar.h"

#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJLWindowTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self->_backgroundView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.userInteractionEnabled = NO;
            imageView.accessibilityIdentifier = BJLKeypath(self, backgroundView);
            [self addSubview:imageView];
            bjl_return imageView;
        });

        self->_captionLabel = ({
            UILabel *label = [UILabel new];
            label.accessibilityIdentifier = BJLKeypath(self, captionLabel);
            label.textColor = BJLTheme.viewTextColor;
            label.font = [UIFont systemFontOfSize:14];
            [self addSubview:label];
            bjl_return label;
        });

        self->_maximizeButton = ({
            UIButton *button = [BJLImageButton new];
            button.accessibilityIdentifier = BJLKeypath(self, maximizeButton);
            [button setImage:[UIImage bjl_imageNamed:@"window_maximize"] forState:UIControlStateNormal];
            [button setImage:[UIImage bjl_imageNamed:@"window_maximize_restore"] forState:UIControlStateSelected];
            [self addSubview:button];
            bjl_return button;
        });

        self->_fullscreenButton = ({
            UIButton *button = [BJLImageButton new];
            button.accessibilityIdentifier = BJLKeypath(self, fullscreenButton);
            [button setImage:[UIImage bjl_imageNamed:@"window_fullscreen"] forState:UIControlStateNormal];
            [button setImage:[UIImage bjl_imageNamed:@"window_fullscreen_restore"] forState:UIControlStateSelected];
            [self addSubview:button];
            bjl_return button;
        });

        self->_closeButton = ({
            UIButton *button = [BJLImageButton new];
            button.accessibilityIdentifier = BJLKeypath(self, closeButton);
            [button setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
            [self addSubview:button];
            bjl_return button;
        });

        [self.backgroundView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)updateConstraints {
    NSMutableArray *buttons = [NSMutableArray new];
    if (!self.closeButton.hidden) {
        [buttons bjl_addObject:self.closeButton];
    }
    if (!self.fullscreenButton.hidden) {
        [buttons bjl_addObject:self.fullscreenButton];
    }
    if (!self.maximizeButton.hidden) {
        [buttons bjl_addObject:self.maximizeButton];
    }

    UIButton *last = nil;
    for (UIButton *button in buttons) {
        [button bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            if (last) {
                make.right.equalTo(last.bjl_left);
            }
            else {
                make.right.equalTo(self).offset(-5.0);
            }
            make.centerY.equalTo(self);
            make.width.lessThanOrEqualTo(button.bjl_height);
            make.width.equalTo(button.bjl_height).priorityHigh();
        }];
        last = button;
    }

    [self.captionLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        //        make.horizontal.compressionResistance.required();
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(10.0);
        make.right.equalTo(last.bjl_left ?: self);
    }];

    [super updateConstraints];
}

@end

NS_ASSUME_NONNULL_END