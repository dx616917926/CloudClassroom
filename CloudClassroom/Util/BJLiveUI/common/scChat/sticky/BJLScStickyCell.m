//
//  BJLScStickyCell.m
//  BJLiveUI
//
//  Created by xyp on 2020/8/12.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLScStickyCell.h"
#import "BJLScAppearance.h"
#import "BJLScLabel.h"
#import "BJLScChatCell.h"
#import "BJLYYText.h"
#import "BJLAnimatedImage.h"
#import "BJLAnimatedImageView+emoticon.h"
#import "BJLMessage+YYTextAttribute.h"

NSString
    *const BJLScStudentStickyCellIdentifier = @"BJLScStudentStickyCellIdentifier",
           *const BJLScTeacherStickyCellIdentifier = @"BJLScTeacherStickyCellIdentifier";

@interface BJLScStickyCell () <UIGestureRecognizerDelegate>
@property (nonatomic) BJLMessage *message;
@property (nonatomic) BJLScLabel *nameLabel;
@property (nonatomic, nullable) UIButton *cancelStickyButton;
@property (nonatomic) UIView *messageContentView;
@property (nonatomic) BJLYYLabel *textView;
//避免个系统属性重名
@property (nonatomic) BJLAnimatedImageView *imgView;
@property (nonatomic) UIImageView *stickyImageView;

@end

@implementation BJLScStickyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeSubviewsAndConstraints];
        [self prepareForReuse];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imgView.image = nil;
    self.imgView.animatedImage = nil;
    [self.nameLabel updateText:nil styleText:nil];
    self.textView.text = @"";
}

- (void)updateWithMessage:(BJLMessage *)message
             customString:(NSString *)customString
                cellWidth:(CGFloat)cellWidth {
    self.message = message;
    NSString *name = message.fromUser.displayName.length ? message.fromUser.displayName : @"";
    [self.nameLabel updateText:name styleText:customString.length ? [NSString stringWithFormat:@"%@", customString] : nil];
    [self.messageContentView bjl_uninstallConstraints];
    [self.imgView bjl_uninstallConstraints];
    [self.textView bjl_uninstallConstraints];
    self.textView.hidden = message.type == BJLMessageType_image;
    self.imgView.hidden = !self.textView.hidden;

    NSDictionary<NSAttributedStringKey, id> *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12.0], NSForegroundColorAttributeName: self.textView.textColor ?: [UIColor clearColor]};
    if (message.type != BJLMessageType_image) {
        NSAttributedString *messageText = [message attributedEmoticonCoreTextWithEmoticonSize:16.0
                                                                                   attributes:attributes
                                                                                    hidePhone:NO
                                                                                       cached:YES
                                                                                    cachedKey:@"cache"];

        bjl_weakify(self);
        self.textView.highlightTapAction = ^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
            bjl_strongify(self);
            NSString *linkString = [text.string substringWithRange:range];
            if (self.linkURLCallback && linkString) {
                self.linkURLCallback([NSURL URLWithString:linkString]);
            }
        };
        CGFloat preferredMaxLayoutWidth = cellWidth - (BJLScViewSpaceS + 2 * BJLScViewSpaceM + BJLScViewSpaceS);

        BJLYYTextContainer *container = [BJLYYTextContainer containerWithSize:CGSizeMake(preferredMaxLayoutWidth, CGFLOAT_MAX)];
        BJLYYTextLayout *layout = [BJLYYTextLayout layoutWithContainer:container text:messageText];
        self.textView.ignoreCommonProperties = YES;
        self.textView.textLayout = layout;
        CGSize suitableSize = layout.textBoundingSize;

        [self.textView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.messageContentView).offset(BJLScViewSpaceS);
            make.bottom.equalTo(self.messageContentView).offset(-BJLScViewSpaceS);
            make.left.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
            make.right.lessThanOrEqualTo(self.messageContentView).offset(-BJLScViewSpaceM);
            make.size.equal.sizeOffset(suitableSize);
        }];

        [self.messageContentView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.nameLabel.bjl_bottom).offset(1.0);
            make.right.equalTo(self.contentView).offset(-BJLScViewSpaceS);
            make.bottom.equalTo(self.contentView).offset(-BJLScViewSpaceM);
            make.left.equalTo(self.contentView).offset(BJLScViewSpaceS);
        }];
    }
    else {
        [self.imgView updateBJLAnimatedImageViewEmotion:nil emotionURLString:message.imageURLString loopCount:0 completed:nil];
        // 图片大小同聊天页面大小一致
        [self.imgView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.height.equalTo(@(50.0));
            make.width.equalTo(@(50.0));
            make.top.bottom.left.right.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceS, BJLScViewSpaceS, BJLScViewSpaceS));
        }];

        [self.messageContentView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.nameLabel.bjl_bottom).offset(1.0);
            make.left.equalTo(self.contentView).offset(BJLScViewSpaceS);
            make.right.bottom.lessThanOrEqualTo(self.contentView).offset(-BJLScViewSpaceS);
        }];
    }
}

- (void)makeSubviewsAndConstraints {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.stickyImageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_sc_chat_sticky"]];

    self.nameLabel = ({
        BJLScLabel *label = [[BJLScLabel alloc] initWitMinHeadCount:2 headStyle:@" [" tailStyle:@"]" fontSize:14.0 textColor:BJLTheme.viewTextColor];
        label.accessibilityIdentifier = BJLKeypath(self, nameLabel);
        label;
    });

    self.messageContentView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, messageContentView);
        view.backgroundColor = BJLTheme.separateLineColor;
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 4.0;
        view.accessibilityIdentifier = BJLKeypath(self, messageContentView);
        view;
    });

    self.textView = ({
        BJLYYLabel *textView = [BJLYYLabel new];
        textView.accessibilityIdentifier = BJLKeypath(self, textView);
        textView.textAlignment = NSTextAlignmentLeft;
        textView.font = [UIFont systemFontOfSize:BJLScChatCell.messageFontSize];
        textView.textColor = BJLTheme.viewTextColor;
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.backgroundColor = [UIColor clearColor];
        textView.userInteractionEnabled = YES;
        textView.accessibilityIdentifier = BJLKeypath(self, textView);
        textView.numberOfLines = 0;
        [self.messageContentView addSubview:textView];
        textView;
    });

    if ([self.reuseIdentifier isEqualToString:BJLScTeacherStickyCellIdentifier]) {
        self.cancelStickyButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.accessibilityIdentifier = BJLKeypath(self, cancelStickyButton);
            button.titleLabel.textAlignment = NSTextAlignmentRight;
            [button bjl_setTitle:BJLLocalizedString(@"取消置顶") forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
            [button setTitleColor:BJLTheme.viewSubTextColor forState:UIControlStateNormal];
            [button setTitleColor:BJLTheme.warningColor forState:UIControlStateHighlighted];
            button.titleLabel.font = [UIFont systemFontOfSize:BJLScChatCell.messageFontSize];
            [button addTarget:self action:@selector(cancelStickyAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }

    self.imgView = [[BJLAnimatedImageView alloc] init];
    self.imgView.accessibilityIdentifier = BJLKeypath(self, imgView);
    self.imgView.userInteractionEnabled = YES;
    [self.messageContentView addSubview:self.imgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
    [self.imgView addGestureRecognizer:tap];
    tap.delegate = self;

    [self.contentView addSubview:self.stickyImageView];
    [self.contentView addSubview:self.nameLabel];
    if (self.cancelStickyButton) {
        [self.contentView addSubview:self.cancelStickyButton];
    }
    [self.contentView addSubview:self.messageContentView];

    [self.stickyImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.contentView).offset(BJLScViewSpaceM);
        make.height.width.equalTo(@16);
        make.top.equalTo(self.contentView).offset(BJLScViewSpaceS);
    }];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.stickyImageView.bjl_right).offset(BJLScViewSpaceM);
        make.right.equalTo(self.cancelStickyButton ? self.cancelStickyButton.bjl_left : self.contentView).offset(-BJLScViewSpaceS);
        make.height.equalTo(@20);
        make.centerY.equalTo(self.stickyImageView);
    }];

    if (self.cancelStickyButton) {
        [self.cancelStickyButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(self.contentView).offset(-BJLScViewSpaceS);
            make.centerY.equalTo(self.stickyImageView);
            make.height.equalTo(@18);
            make.hugging.compressionResistance.required();
        }];
    }
}

#pragma mark -

- (void)cancelStickyAction:(UIButton *)button {
    if (self.cancelStickyCallback) {
        self.cancelStickyCallback();
    }
}

- (void)tapImageViewAction:(UITapGestureRecognizer *)tap {
    if (self.imageTapCallback) {
        self.imageTapCallback(self.message);
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.imgView.frame, point)) {
        return YES;
    }
    return NO;
}

@end
