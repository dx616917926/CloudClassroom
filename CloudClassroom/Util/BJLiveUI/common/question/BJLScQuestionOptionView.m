//
//  BJLScQuestionOptionView.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/27.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScQuestionOptionView.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLScQuestionOptionView ()

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) BJLQuestion *question;
@property (nonatomic, nullable) BJLQuestionReply *reply;
@property (nonatomic) UIButton *replyButton, *publishButton, *copyingButton;

@end

@implementation BJLScQuestionOptionView

- (instancetype)initWithRoom:(BJLRoom *)room question:(BJLQuestion *)question reply:(nonnull BJLQuestionReply *)reply {
    if (self = [super initWithFrame:CGRectZero]) {
        self.room = room;
        self.question = question;
        self.reply = reply;
        [self makeSubviewsAndConstraints];
    }
    return self;
}

- (void)makeSubviewsAndConstraints {
    self.backgroundColor = [UIColor clearColor];

    NSString *replyTitle = self.question.replies.count > 0 ? BJLLocalizedString(@"追加回复") : BJLLocalizedString(@"回复");
    NSString *publishTitle = self.question.state & BJLQuestionPublished ? BJLLocalizedString(@"取消发布") : BJLLocalizedString(@"发布");
    self.replyButton = [self makeButtonWithTitle:replyTitle selectedTitle:nil action:@selector(sendReply)];
    self.publishButton = [self makeButtonWithTitle:publishTitle selectedTitle:nil action:@selector(updatePublish:)];
    self.copyingButton = [self makeButtonWithTitle:BJLLocalizedString(@"复制") selectedTitle:nil action:@selector(copyQuestion)];
    [self makeConstraintsWithButtons:@[self.replyButton, self.publishButton, self.copyingButton]];
}

- (void)sendReply {
    if (self.replyCallback) {
        self.replyCallback(self.question, nil);
    }
}

- (void)updatePublish:(UIButton *)button {
    BOOL publish = self.question.state & BJLQuestionPublished;
    if (self.publishCallback) {
        self.publishCallback(self.question, !publish);
    }
}

- (void)copyQuestion {
    if (self.copyCallback) {
        self.copyCallback(self.question);
    }
}

- (UIButton *)makeButtonWithTitle:(nullable NSString *)title selectedTitle:(nullable NSString *)selectedTitle action:(SEL)selector {
    UIButton *button = [UIButton new];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    if (selectedTitle) {
        [button setTitle:selectedTitle forState:UIControlStateSelected];
    }
    if (selector) {
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

- (void)makeConstraintsWithButtons:(nullable NSArray *)buttons {
    UIView *last = nil;
    for (UIButton *button in buttons) {
        [self addSubview:button];
        [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            if (last) {
                make.left.right.height.equalTo(last);
                make.top.equalTo(last.bjl_bottom);
            }
            else {
                make.top.equalTo(self).offset(10.0);
                make.left.right.equalTo(self);
                make.height.equalTo(@30.0).priorityHigh();
            }
        }];
        if (button == buttons.lastObject) {
            [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.bottom.equalTo(self).offset(-10.0);
            }];
        }
        last = button;
    }
}

- (CGSize)viewSize {
    CGFloat height = 100.0;
    return CGSizeMake(85.0, height);
}

@end

NS_ASSUME_NONNULL_END
