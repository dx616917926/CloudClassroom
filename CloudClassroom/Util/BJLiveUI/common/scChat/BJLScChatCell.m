
//
//  BJLScChatCell.m
//  BJLiveUI
//
//  Created by 凡义 on 2019/9/25.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLAnimatedImage.h"
#import "BJLAnimatedImageView+emoticon.h"
#import "BJLYYText.h"
#import "BJLMessage+YYTextAttribute.h"

#import "BJLScChatCell.h"
#import "BJLScAppearance.h"
#import "BJLScLabel.h"
#import "BJLAvatarBackgroundColorGenerator.h"

NSString
    *const BJLScTextCellReuseIdentifier = @"kScReceiveTextCellReuseIdentifier",
           *const BJLScTextAndTranslationCellReuseIdentifier = @"kScReceiveTextAndTranslationCellReuseIdentifier",
           *const BJLScImageCellReuseIdentifier = @"kScReceiveImageCellReuseIdentifier",
           *const BJLScEmoticonCellReuseIdentifier = @"kScReceiveEmoticonCellReuseIdentifier",
           *const BJLScMessageUploadingImageIdentifier = @"kScUploadingImageIdentifier";

static const CGFloat verMargins = (10.0 + 5.0 + 10.0) + 5.0; // last 5.0: bgView.top+bottom

static const CGFloat avtarIconSize = 24.0;
static const CGFloat deviceIconSize = 13.0;

static const CGFloat imageMinWidth = 50.0, imageMinHeight = 50.0;
static const CGFloat imageMessageCellMinHeight = imageMinHeight + verMargins;

static const CGFloat emoticonSize = 32.0;
static const CGFloat emoticonMessageCellHeight = emoticonSize + verMargins;

@interface BJLScChatCell () <UITextViewDelegate>

@property (nonatomic) BJLMessage *message;

@property (nonatomic) UIView *bgView, *messageContentView;
@property (nonatomic) UILabel *timeLabel, *groupInfoLabel;
@property (nonatomic) BJLScLabel *nameLabel;
@property (nonatomic, readwrite) UIImageView *iconImageView, *deviceImageView;
@property (nonatomic) BJLAnimatedImageView *emoticonImageView, *messageImageView;
@property (nonatomic) BJLYYLabel *textView;

@property (nonatomic) UIView *imgProgressView;
@property (nonatomic) BJLConstraint *imgProgressViewHeightConstraint;
@property (nonatomic) UIButton *failedBadgeButton;

/** 英汉互译*/
@property (nonatomic) UIView *translationSepratorline;
@property (nonatomic) UITextView *translationTextView;

@property (nonatomic) BJLChatStatus chatStatus;

/** 消息引用*/
@property (nonatomic, nullable) BJLAnimatedImageView *referenceEmoticonImageView, *referenceMessageImageView;
@property (nonatomic, nullable) BJLYYLabel *referenceLabel;
@property (nonatomic, nullable) UIView *lineView;
@property (nonatomic) NSInteger limitLine, currentLineNumber;

@property (nonatomic) UIButton *translateButton;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognize;

@end

@implementation BJLScChatCell

static CGFloat fontSize = 12.0;

+ (void)setMessageFontSize:(CGFloat)messageFontSize {
    fontSize = messageFontSize;
}

+ (CGFloat)messageFontSize {
    return fontSize;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.limitLine = 3;
        self.currentLineNumber = 3;
        [self setUpSubviews];
        [self prepareForReuse];
    }
    return self;
}

- (void)setUpSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    if ([self.reuseIdentifier isEqualToString:BJLScTextCellReuseIdentifier]) {
        [self makeMessageLabelAndConstraints];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScImageCellReuseIdentifier]) {
        [self makeMessageImageViewAndConstraints];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScEmoticonCellReuseIdentifier]) {
        [self makeEmoticonImageViewAndConstraints];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScTextAndTranslationCellReuseIdentifier]) {
        [self makeTranslationMessageLabelAndConstraints];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScMessageUploadingImageIdentifier]) {
        [self makeUploadingImageMessageLabelAndConstraints];
    }

    bjl_weakify(self);
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGesture];
    singleTapGesture.delegate = self;
    self.tapGestureRecognize = singleTapGesture;

    UILongPressGestureRecognizer *longPressGesture = [UILongPressGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.longPressCallback && gesture.state == UIGestureRecognizerStateBegan) {
            self.longPressCallback(self.message, (self.message.type == BJLMessageType_emoticon) ? self.emoticonImageView.image : self.messageImageView.image, [gesture locationInView:self]);
        }
    }];
    longPressGesture.delegate = self;
    [self addGestureRecognizer:longPressGesture];
    [singleTapGesture requireGestureRecognizerToFail:longPressGesture];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.textView.text = nil;
    self.textView.attributedText = nil;
    [self.nameLabel updateText:nil styleText:nil];
    self.timeLabel.text = nil;
    self.iconImageView.image = nil;
    self.deviceImageView.image = nil;
    self.emoticonImageView.image = nil;
    self.emoticonImageView.animatedImage = nil;
    self.translationTextView.text = nil;
    self.messageImageView.image = nil;
    self.messageImageView.animatedImage = nil;
    self.failedBadgeButton.hidden = YES;

    [self.referenceLabel removeFromSuperview];
    [self.referenceMessageImageView removeFromSuperview];
    [self.referenceEmoticonImageView removeFromSuperview];
    [self.lineView removeFromSuperview];
    self.referenceLabel = nil;
    self.referenceMessageImageView = nil;
    self.referenceEmoticonImageView = nil;
    self.lineView = nil;
}

- (void)makeCommonViewsAndConstraints {
    self.bgView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, bgView);
        [self.contentView addSubview:view];
        view;
    });

    self.timeLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, timeLabel);
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentRight;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:12];
        [self.bgView addSubview:label];
        bjl_return label;
    });

    self.nameLabel = ({
        BJLScLabel *label = [[BJLScLabel alloc] initWitMinHeadCount:2 headStyle:@" [" tailStyle:@"]" fontSize:12.0 textColor:BJLTheme.viewTextColor];
        label.accessibilityIdentifier = BJLKeypath(self, nameLabel);
        [self.bgView addSubview:label];
        label;
    });

    self.iconImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.accessibilityIdentifier = BJLKeypath(self, iconImageView);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = avtarIconSize / 2;
        imageView.layer.masksToBounds = YES;
        imageView.backgroundColor = BJLTheme.separateLineColor;
        [self.bgView addSubview:imageView];
        bjl_return imageView;
    });

    self.deviceImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.accessibilityIdentifier = BJLKeypath(self, deviceImageView);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.layer.masksToBounds = YES;
        [self.bgView addSubview:imageView];
        bjl_return imageView;
    });

    self.messageContentView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 8.0;
        view.accessibilityIdentifier = BJLKeypath(self, messageContentView);
        [self.bgView addSubview:view];
        view;
    });

    self.translateButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button bjl_setImage:[UIImage bjl_imageNamed:@"bjl_chat_translated_normal"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [button setImage:[UIImage bjl_imageNamed:@"bjl_chat_translated_selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(translateAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:button];
        button;
    });

    [self.bgView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        CGFloat spaceLeft = BJLScScrollIndicatorSize;
        make.left.top.bottom.equalTo(self.contentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, spaceLeft, BJLScViewSpaceM, 0));
        make.right.equalTo(self.contentView);
    }];

    [self.iconImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.equalTo(self.bgView);
        make.height.width.equalTo(@(avtarIconSize));
    }];

    [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.deviceImageView.bjl_left);
        make.top.equalTo(self.iconImageView);
        make.width.equalTo(@0.0);
    }];

    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.bottom.equalTo(self.timeLabel);
        make.left.equalTo(self.iconImageView.bjl_right).offset(BJLScViewSpaceS);
        make.right.equalTo(self.timeLabel.bjl_left).offset(-BJLScViewSpaceS);
    }];

    [self.deviceImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.iconImageView);
        make.right.equalTo(self.bgView);
        make.width.height.equalTo(@(deviceIconSize));
    }];

    [self.messageContentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.iconImageView.bjl_right).offset(BJLScViewSpaceS);
        make.top.equalTo(self.timeLabel.bjl_bottom).offset(BJLScViewSpaceS);
        make.right.lessThanOrEqualTo(self.translateButton);
        make.bottom.equalTo(self.bgView);
    }];
    [self.translateButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.messageContentView.bjl_right).offset(BJLScViewSpaceS);
        make.top.equalTo(self.messageContentView);
        make.right.lessThanOrEqualTo(self.bgView);
        make.width.height.equalTo(@0); // todo update
    }];
}

- (void)makeMessageLabelAndConstraints {
    [self makeCommonViewsAndConstraints];

    self.groupInfoLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, groupInfoLabel);
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:10];
        label.hidden = YES;
        [self.bgView addSubview:label];
        bjl_return label;
    });

    self.textView = ({
        BJLYYLabel *textView = [BJLYYLabel new];
        textView.textAlignment = NSTextAlignmentLeft;
        textView.font = [UIFont systemFontOfSize:BJLScChatCell.messageFontSize];
        textView.textColor = [UIColor bjl_colorWithHex:0X4A4A4A];
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.backgroundColor = [UIColor clearColor];
        textView.userInteractionEnabled = YES;
        textView.numberOfLines = 0;
        textView.accessibilityIdentifier = BJLKeypath(self, textView);
        [self.messageContentView addSubview:textView];
        textView;
    });

    [self.textView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.bottom.left.right.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, BJLScViewSpaceS, BJLScViewSpaceM));
        make.right.lessThanOrEqualTo(self.deviceImageView);
    }];
}

- (void)makeTranslationMessageLabelAndConstraints {
    [self makeCommonViewsAndConstraints];

    self.groupInfoLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, groupInfoLabel);
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:10];
        label.hidden = YES;
        [self.bgView addSubview:label];
        bjl_return label;
    });

    self.textView = ({
        BJLYYLabel *textView = [BJLYYLabel new];
        textView.textAlignment = NSTextAlignmentLeft;
        textView.font = [UIFont systemFontOfSize:BJLScChatCell.messageFontSize];
        textView.textColor = [UIColor bjl_colorWithHex:0X4A4A4A];
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.backgroundColor = [UIColor clearColor];
        textView.userInteractionEnabled = YES;
        textView.numberOfLines = 0;
        [self.messageContentView addSubview:textView];
        textView.accessibilityIdentifier = BJLKeypath(self, textView);
        textView;
    });

    self.translationSepratorline = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_colorWithHex:0X9FA8B5 alpha:0.4];
        [self.messageContentView addSubview:view];
        view;
    });

    self.translationTextView = ({
        UITextView *textView = [UITextView new];
        textView.textAlignment = NSTextAlignmentLeft;
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.textContainer.lineFragmentPadding = 0;
        textView.backgroundColor = [UIColor clearColor];
        textView.selectable = YES;
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.userInteractionEnabled = YES;
        textView.accessibilityIdentifier = BJLKeypath(self, translationTextView);
        [self.messageContentView addSubview:textView];
        textView;
    });

    [self.textView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, 0, BJLScViewSpaceM));
    }];

    [self.translationSepratorline bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.textView);
        make.height.equalTo(@(1));
        make.top.equalTo(self.textView.bjl_bottom).with.offset(BJLScViewSpaceS);
    }];
    [self.translationTextView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.textView);
        make.top.equalTo(self.translationSepratorline.bjl_bottom).with.offset(BJLScViewSpaceS);
        make.bottom.equalTo(self.messageContentView).with.offset(-BJLScViewSpaceS);
    }];
}

- (void)makeMessageImageViewAndConstraints {
    [self makeCommonViewsAndConstraints];

    self.groupInfoLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, groupInfoLabel);
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:10];
        label.hidden = YES;
        [self.bgView addSubview:label];
        bjl_return label;
    });

    self.messageImageView = ({
        BJLAnimatedImageView *imageView = [BJLAnimatedImageView new];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.messageContentView addSubview:imageView];
        imageView.accessibilityIdentifier = BJLKeypath(self, messageImageView);
        imageView;
    });

    [self.messageImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, BJLScViewSpaceS, BJLScViewSpaceM));
        make.width.equalTo(@(imageMinWidth));
        make.height.equalTo(@(imageMinHeight)).priorityHigh();
    }];
}

- (void)makeEmoticonImageViewAndConstraints {
    [self makeCommonViewsAndConstraints];

    self.groupInfoLabel = ({
        UILabel *label = [UILabel new];
        label.accessibilityIdentifier = BJLKeypath(self, groupInfoLabel);
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.textColor = BJLTheme.viewSubTextColor;
        label.font = [UIFont systemFontOfSize:10];
        label.hidden = YES;
        [self.bgView addSubview:label];
        bjl_return label;
    });

    self.emoticonImageView = ({
        BJLAnimatedImageView *imageView = [BJLAnimatedImageView new];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.messageContentView addSubview:imageView];
        imageView.accessibilityIdentifier = BJLKeypath(self, emoticonImageView);
        imageView;
    });

    [self.emoticonImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
        make.top.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
        make.bottom.equalTo(self.messageContentView).offset(-BJLScViewSpaceM);
        make.width.equalTo(@(emoticonSize));
        make.height.equalTo(@(emoticonSize)).priorityHigh();
        make.right.lessThanOrEqualTo(self.messageContentView).offset(-BJLScViewSpaceM).priorityHigh();
    }];
}

- (void)makeUploadingImageMessageLabelAndConstraints {
    [self makeCommonViewsAndConstraints];

    self.messageImageView = ({
        BJLAnimatedImageView *imageView = [BJLAnimatedImageView new];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.messageContentView addSubview:imageView];
        imageView.accessibilityIdentifier = BJLKeypath(self, messageImageView);
        imageView;
    });
    self.imgProgressView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjlsc_darkDimColor];
        [self.messageContentView addSubview:view];
        view.accessibilityIdentifier = BJLKeypath(self, imgProgressView);
        view;
    });
    self.failedBadgeButton = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"!" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = BJLTheme.warningColor;
        button.layer.cornerRadius = BJLScBadgeSize / 2;
        button.layer.masksToBounds = YES;
        [self.bgView addSubview:button];
        button.accessibilityIdentifier = BJLKeypath(self, failedBadgeButton);
        button;
    });
    bjl_weakify(self);
    [self.failedBadgeButton bjl_addHandler:^(__kindof UIControl *_Nullable sender) {
        bjl_strongify(self);
        if (self.retryUploadingCallback) self.retryUploadingCallback(self);
    }];

    [self.messageContentView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.lessThanOrEqualTo(self.bgView).offset(-(2 * BJLScViewSpaceS + BJLScBadgeSize));
    }];

    [self.messageImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, BJLScViewSpaceS, BJLScViewSpaceM));
        make.width.equalTo(@(imageMinWidth));
        make.height.equalTo(@(imageMinHeight)).priorityHigh();
    }];

    [self.imgProgressView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.messageImageView);
        self.imgProgressViewHeightConstraint = make.height.equalTo(@0.0).constraint;
    }];

    [self.failedBadgeButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.messageContentView.bjl_right).with.offset(BJLScViewSpaceS);
        make.right.lessThanOrEqualTo(self.bgView).offset(-BJLScViewSpaceS);
        make.centerY.equalTo(self.messageImageView);
        make.width.height.equalTo(@(BJLScBadgeSize));
    }];
}

#pragma mark - public

+ (NSArray<NSString *> *)allCellIdentifiers {
    return @[
        BJLScTextCellReuseIdentifier,
        BJLScTextAndTranslationCellReuseIdentifier,
        BJLScImageCellReuseIdentifier,
        BJLScEmoticonCellReuseIdentifier,
        BJLScMessageUploadingImageIdentifier
    ];
}

- (void)updatReferenceLabelLineNumber:(NSInteger)number {
    self.currentLineNumber = number;
}

- (void)updateMessageBackgroundColorWithIsSender:(BOOL)isSender {
    if (isSender) {
        self.messageContentView.backgroundColor = BJLTheme.brandColor;
        self.textView.textColor = BJLTheme.buttonTextColor;
        self.translationTextView.textColor = BJLTheme.buttonTextColor;
    }
    else {
        self.messageContentView.backgroundColor = BJLTheme.separateLineColor;
        self.textView.textColor = BJLTheme.viewTextColor;
        self.translationTextView.textColor = BJLTheme.viewTextColor;
    }

    if (self.message.reference) {
        self.messageContentView.backgroundColor = BJLTheme.separateLineColor;
        self.textView.textColor = BJLTheme.viewTextColor;
        self.translationTextView.textColor = BJLTheme.viewTextColor;
    }
}

- (void)updateWithMessage:(BJLMessage *)message
            fromLoginUser:(BOOL)fromLoginUser
             customString:(nullable NSString *)customString
               chatStatus:(BJLChatStatus)chatStatus
                 isSender:(BOOL)isSender
        shouldHiddenPhone:(BOOL)hidden
    enableChatTranslation:(BOOL)enableChatTranslation
      shouldShowGroupInfo:(BOOL)shouldShowGroupInfo
                groupInfo:(nullable BJLUserGroup *)groupInfo
                cellWidth:(CGFloat)cellWidth {
    self.chatStatus = chatStatus;
    self.message = message;
    [self updateMessageBackgroundColorWithIsSender:isSender];
    NSString *urlString = BJLAliIMG_aspectFit(CGSizeMake(avtarIconSize, avtarIconSize),
        0.0,
        message.fromUser.avatar,
        nil);
    [self.iconImageView bjl_setImageWithURL:[NSURL URLWithString:urlString]];
    if (message.fromUser.isAssistant) {
        self.iconImageView.backgroundColor = [BJLAvatarBackgroundColorGenerator backgroundColorWithUserNumber:message.fromUser.number];
    }

    [self.deviceImageView setImage:[self deviceImageWith:message.fromUser.clientType]];
    self.timeLabel.text = [self timeStringWithTimeInterval:message.timeInterval];
    [self.timeLabel bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.width.equalTo(@(self.timeLabel.intrinsicContentSize.width));
    }];

    [self.groupInfoLabel bjl_removeAllConstraints];
    self.groupInfoLabel.hidden = !shouldShowGroupInfo;
    self.groupInfoLabel.text = [NSString stringWithFormat:@"%@: %@", BJLLocalizedString(@"组"), groupInfo.name];
    if (shouldShowGroupInfo) {
        [self.nameLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.timeLabel);
            make.bottom.equalTo(self.iconImageView.bjl_centerY);
            make.left.equalTo(self.iconImageView.bjl_right).offset(BJLScViewSpaceS);
            make.right.equalTo(self.timeLabel.bjl_left).offset(-BJLScViewSpaceS);
        }];

        [self.groupInfoLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.nameLabel);
            make.top.equalTo(self.iconImageView.bjl_centerY);
            make.bottom.equalTo(self.iconImageView);
            make.right.equalTo(self.deviceImageView);
        }];

        [self.messageContentView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.iconImageView.bjl_right).offset(BJLScViewSpaceS);
            make.top.equalTo(self.iconImageView.bjl_bottom).offset(BJLScViewSpaceS);
            make.right.lessThanOrEqualTo(self.translateButton);
            make.bottom.equalTo(self.bgView);
        }];
    }
    else {
        [self.nameLabel bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.bottom.equalTo(self.timeLabel);
            make.left.equalTo(self.iconImageView.bjl_right).offset(BJLScViewSpaceS);
            make.right.equalTo(self.timeLabel.bjl_left).offset(-BJLScViewSpaceS);
        }];

        [self.messageContentView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.iconImageView.bjl_right).offset(BJLScViewSpaceS);
            make.top.equalTo(self.timeLabel.bjl_bottom).offset(BJLScViewSpaceS);
            make.right.lessThanOrEqualTo(self.translateButton);
            make.bottom.equalTo(self.bgView);
        }];
    }

    NSString *name = message.fromUser.displayName.length ? message.fromUser.displayName : @"";
    self.nameLabel.canLayout = NO;
    [self.nameLabel updateText:name styleText:customString.length ? [NSString stringWithFormat:@"%@", customString] : nil];

    switch (message.type) {
        case BJLMessageType_text: {
            if (message.text.length) {
                // 是否为私聊消息
                BOOL isWisperMessage = (message.toUser.ID.length > 0 && ![message.toUser.ID isEqualToString:@"-1"]);

                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];

                NSDictionary<NSAttributedStringKey, id> *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:BJLScChatCell.messageFontSize], NSForegroundColorAttributeName: self.textView.textColor ?: [UIColor clearColor]};
                if (isWisperMessage && self.chatStatus != BJLChatStatus_private) {
                    NSAttributedString *whisperTipString = [[NSMutableAttributedString alloc] initWithString:BJLLocalizedString(@"私聊") attributes:attributes];
                    [string appendAttributedString:whisperTipString];

                    NSString *toName = fromLoginUser ? ([NSString stringWithFormat:@" %@", message.toUser.displayName ?: @"-"]) : BJLLocalizedString(@" 我");
                    NSAttributedString *toUserName = [[NSMutableAttributedString alloc] initWithString:toName
                                                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                                                                                NSForegroundColorAttributeName: isSender ? BJLTheme.buttonTextColor : BJLTheme.brandColor}];
                    [string appendAttributedString:toUserName];

                    NSAttributedString *nextLine = [[NSMutableAttributedString alloc] initWithString:@"\n"];
                    [string appendAttributedString:nextLine];
                    NSAttributedString *messageText = [message attributedEmoticonCoreTextWithEmoticonSize:16.0 attributes:attributes hidePhone:hidden cached:YES cachedKey:@"cache"];
                    [string appendAttributedString:messageText];
                }
                else {
                    NSAttributedString *messageText = [message attributedEmoticonCoreTextWithEmoticonSize:16.0 attributes:attributes hidePhone:hidden cached:YES cachedKey:@"cache"];
                    [string appendAttributedString:messageText];
                }

                bjl_weakify(self);
                self.textView.highlightTapAction = ^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
                    bjl_strongify(self);
                    NSString *linkString = [text.string substringWithRange:range];
                    if (self.linkURLCallback && linkString) {
                        self.linkURLCallback(self, [NSURL URLWithString:linkString]);
                    }
                };
                self.textView.attributedText = string;
                CGFloat preferredMaxLayoutWidth = cellWidth - (BJLScScrollIndicatorSize + avtarIconSize + BJLScViewSpaceS + 2 * BJLScViewSpaceM + BJLScViewSpaceS + 16);
                self.textView.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
            }
            if (message.translation.length) {
                self.translationTextView.text = hidden ? [BJLMessage displayContentOfText:message.translation] : message.translation;
            }
            break;
        }
        case BJLMessageType_emoticon: {
            [self.emoticonImageView updateBJLAnimatedImageViewEmotion:message.emoticon emotionURLString:nil loopCount:0 completed:nil];
        }
        case BJLMessageType_image: {
            [self _updateImageViewWithImageURLString:message.imageURLString
                                                size:CGSizeMake(message.imageWidth, message.imageHeight)
                                         placeholder:nil];
        }
        default:
            break;
    }

    if (message.reference) {
        [self makeReferenceViewWithReferenceMessage:message.reference];
    }
    else {
        [self.referenceLabel removeFromSuperview];
        [self.referenceMessageImageView removeFromSuperview];
        [self.referenceEmoticonImageView removeFromSuperview];
        [self.lineView removeFromSuperview];
        self.referenceLabel = nil;
        self.referenceMessageImageView = nil;
        self.referenceEmoticonImageView = nil;
        self.lineView = nil;

        if ([self.reuseIdentifier isEqualToString:BJLScTextCellReuseIdentifier]) {
            [self.textView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.top.bottom.left.right.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, BJLScViewSpaceS, BJLScViewSpaceM));
                make.right.lessThanOrEqualTo(self.deviceImageView);
            }];
        }
        else if ([self.reuseIdentifier isEqualToString:BJLScImageCellReuseIdentifier]) {
            [self.messageImageView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, BJLScViewSpaceS, BJLScViewSpaceM));
                make.width.equalTo(@(imageMinWidth));
                make.height.equalTo(@(imageMinHeight)).priorityHigh();
            }];
        }
        else if ([self.reuseIdentifier isEqualToString:BJLScEmoticonCellReuseIdentifier]) {
            [self.emoticonImageView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, BJLScViewSpaceS, BJLScViewSpaceM));
                make.width.equalTo(@(emoticonSize));
                make.height.equalTo(@(emoticonSize)).priorityHigh();
            }];
        }
        else if ([self.reuseIdentifier isEqualToString:BJLScTextAndTranslationCellReuseIdentifier]) {
            [self.textView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.top.left.right.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, 0, BJLScViewSpaceM));
            }];

            [self.translationSepratorline bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.right.equalTo(self.textView);
                make.height.equalTo(@(1));
                make.top.equalTo(self.textView.bjl_bottom).with.offset(BJLScViewSpaceS);
            }];
            [self.translationTextView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.right.equalTo(self.textView);
                make.top.equalTo(self.translationSepratorline.bjl_bottom).with.offset(BJLScViewSpaceS);
                make.bottom.equalTo(self.messageContentView).with.offset(-BJLScViewSpaceS);
            }];
        }
        else if ([self.reuseIdentifier isEqualToString:BJLScMessageUploadingImageIdentifier]) {
            [self.messageImageView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.edges.equalTo(self.messageContentView).insets(UIEdgeInsetsMake(BJLScViewSpaceS, BJLScViewSpaceM, BJLScViewSpaceS, BJLScViewSpaceM));
                make.width.equalTo(@(imageMinWidth));
                make.height.equalTo(@(imageMinHeight)).priorityHigh();
            }];

            [self.imgProgressView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.messageImageView);
                self.imgProgressViewHeightConstraint = make.height.equalTo(@0.0).constraint;
            }];

            [self.failedBadgeButton bjl_remakeConstraints:^(BJLConstraintMaker *make) {
                make.left.equalTo(self.messageContentView.bjl_right).with.offset(BJLScViewSpaceS);
                make.right.lessThanOrEqualTo(self.bgView).offset(-BJLScViewSpaceS);
                make.centerY.equalTo(self.messageImageView);
                make.width.height.equalTo(@(BJLScBadgeSize));
            }];
        }
    }

    // 翻译按钮, tools里打开翻译开关 且 是文本消息 且 不是纯表情
    if (enableChatTranslation
        && message.type == BJLMessageType_text
        && !message.isPureEmoji) {
        [self translateButtonShouldShow:YES];
    }
    else {
        [self translateButtonShouldShow:NO];
    }
}

- (void)makeReferenceViewWithReferenceMessage:(BJLMessage *)message {
    self.lineView = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor bjl_colorWithHex:0X9FA8B5 alpha:0.4];
        line.accessibilityIdentifier = BJLKeypath(self, lineView);
        [self.messageContentView addSubview:line];
        line;
    });

    [self.lineView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.messageContentView);
        make.height.equalTo(@1);
    }];

    if (BJLMessageType_text == message.type) {
        self.referenceLabel = ({
            BJLYYLabel *label = [BJLYYLabel new];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:BJLScChatCell.messageFontSize];
            label.textColor = BJLTheme.subButtonTextColor;
            label.backgroundColor = [UIColor clearColor];
            label.userInteractionEnabled = YES;
            // 至少显示3行
            label.numberOfLines = self.currentLineNumber < self.limitLine ? self.limitLine : self.currentLineNumber;
            label.accessibilityIdentifier = BJLKeypath(self, referenceLabel);
            [self.messageContentView addSubview:label];
            label;
        });

        if (message.text.length) {
            self.referenceLabel.attributedText = [message attributedEmoticonCoreTextWithEmoticonSize:16.0 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:BJLScChatCell.messageFontSize], NSForegroundColorAttributeName: self.referenceLabel.textColor} hidePhone:NO cached:YES cachedKey:@"cache"];

            bjl_weakify(self);
            UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
                bjl_strongify(self);
                CGFloat totalHeight = [self bjl_suitableSizeWithText:nil attributedText:self.referenceLabel.attributedText maxWidth:self.referenceLabel.bounds.size.width].height;
                NSInteger line = totalHeight / self.referenceLabel.font.lineHeight;
                if (line > self.limitLine
                    && self.reloadCellCallback) {
                    self.reloadCellCallback(self, self.currentLineNumber < line ? line : self.limitLine);
                }
            }];
            [self.referenceLabel addGestureRecognizer:tap];
        }

        [self.referenceLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
            make.right.equalTo(self.messageContentView).offset(-BJLScViewSpaceM);
            make.top.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
            make.bottom.equalTo(self.lineView).offset(-BJLScViewSpaceM);
            make.right.lessThanOrEqualTo(self.deviceImageView);
        }];
    }
    else if (BJLMessageType_emoticon == message.type) {
        self.referenceEmoticonImageView = ({
            BJLAnimatedImageView *imageView = [BJLAnimatedImageView new];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.messageContentView addSubview:imageView];
            imageView.accessibilityIdentifier = BJLKeypath(self, referenceEmoticonImageView);
            imageView;
        });

        [self.referenceEmoticonImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
            make.top.equalTo(self.messageContentView).offset(BJLScViewSpaceS);
            make.bottom.equalTo(self.lineView).offset(-BJLScViewSpaceS);
            make.width.equalTo(@(emoticonSize));
            make.height.equalTo(@(emoticonSize)).priorityHigh();
            make.right.lessThanOrEqualTo(self.messageContentView).offset(-BJLScViewSpaceM);
        }];

        [self.referenceEmoticonImageView updateBJLAnimatedImageViewEmotion:message.emoticon emotionURLString:nil loopCount:0 completed:nil];
    }

    if ([self.reuseIdentifier isEqualToString:BJLScTextCellReuseIdentifier]) {
        [self.textView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.lineView.bjl_bottom).offset(BJLScViewSpaceS);
            make.left.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
            make.bottom.equalTo(self.messageContentView).offset(-BJLScViewSpaceS);
            make.right.equalTo(self.messageContentView).offset(-BJLScViewSpaceM).priority(UILayoutPriorityRequired - 1.0);
            make.right.lessThanOrEqualTo(self.deviceImageView);
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScEmoticonCellReuseIdentifier]) {
        [self.emoticonImageView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.lineView.bjl_bottom).offset(BJLScViewSpaceS);
            make.left.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
            make.bottom.equalTo(self.messageContentView).offset(-BJLScViewSpaceS);
            make.right.equalTo(self.messageContentView).offset(-BJLScViewSpaceM).priorityLow();
            make.right.lessThanOrEqualTo(self.deviceImageView);

            make.width.equalTo(@(emoticonSize));
            make.height.equalTo(@(emoticonSize)).priorityHigh();
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScTextAndTranslationCellReuseIdentifier]) {
        [self.textView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.lineView.bjl_bottom).offset(BJLScViewSpaceS);
            make.left.equalTo(self.messageContentView).offset(BJLScViewSpaceM);
            make.right.equalTo(self.messageContentView).offset(-BJLScViewSpaceM);
            make.right.lessThanOrEqualTo(self.deviceImageView);
        }];
        [self.translationSepratorline bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.textView);
            make.height.equalTo(@(1));
            make.top.equalTo(self.textView.bjl_bottom).with.offset(BJLScViewSpaceS);
        }];
        [self.translationTextView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.textView);
            make.top.equalTo(self.translationSepratorline.bjl_bottom).with.offset(BJLScViewSpaceS);
            make.bottom.equalTo(self.messageContentView).with.offset(-BJLScViewSpaceS);
        }];
    }
}

- (void)updateWithUploadingTask:(BJLChatUploadingTask *)task
                     chatStatus:(BJLChatStatus)chatStatus
                       fromUser:(BJLUser *)fromUser {
    self.chatStatus = chatStatus;
    [self updateMessageBackgroundColorWithIsSender:YES];

    [self.nameLabel updateText:fromUser.displayName.length ? fromUser.displayName : nil styleText:nil];
    NSString *urlString = BJLAliIMG_aspectFit(CGSizeMake(avtarIconSize, avtarIconSize),
        0.0,
        fromUser.avatar,
        nil);
    [self.iconImageView bjl_setImageWithURL:[NSURL URLWithString:urlString]];

    [self.deviceImageView setImage:[self deviceImageWith:fromUser.clientType]];
    self.timeLabel.text = [self timeStringWithTimeInterval:[[NSDate date] timeIntervalSince1970]];

    [self _updateImageViewWithImageOrNil:task.thumbnail size:task.thumbnail.size];
    self.failedBadgeButton.hidden = !task.error;

    [self.imgProgressView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        [self.imgProgressViewHeightConstraint uninstall];
        self.imgProgressViewHeightConstraint = make.height.equalTo(self.messageImageView).multipliedBy(1.0 - task.progress * 0.9).constraint;
    }];
}

+ (CGFloat)estimatedRowHeightForMessageType:(BJLMessageType)type {
    switch (type) {
        case BJLMessageType_emoticon:
            return emoticonMessageCellHeight;
        case BJLMessageType_image:
            return imageMessageCellMinHeight;
        default:
            return BJLScChatCell.messageFontSize + verMargins;
    }
}

+ (NSString *)cellIdentifierForMessageType:(BJLMessageType)type hasTranslation:(BOOL)hasTranslation {
    switch (type) {
        case BJLMessageType_image:
            return BJLScImageCellReuseIdentifier;
        case BJLMessageType_emoticon:
            return BJLScEmoticonCellReuseIdentifier;
        default: {
            if (hasTranslation) {
                return BJLScTextAndTranslationCellReuseIdentifier;
            }
            else {
                return BJLScTextCellReuseIdentifier;
            }
        }
    }
}

+ (NSString *)cellIdentifierForUploadingImage {
    return BJLScMessageUploadingImageIdentifier;
}

#pragma mark - text view delegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
    textView.selectedTextRange = nil;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if (self.linkURLCallback) {
        return self.linkURLCallback(self, URL);
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.tapGestureRecognize) {
        return ([self shouldhandleUserSelectWithTapPoint:[touch locationInView:self]]
                || [self shouldhandleImageSelectWithTapPoint:[touch locationInView:self]]);
    }
    return YES;
}

#pragma mark - private

- (UIImage *)deviceImageWith:(BJLClientType)type {
    switch (type) {
        case BJLClientType_PCWeb:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_web"];

        case BJLClientType_PCApp:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_win"];

        case BJLClientType_iOSApp:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_iphone"];

        case BJLClientType_AndroidApp:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_andriod"];

        case BJLClientType_MacApp:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_mac"];

        case BJLClientType_MobileWeb:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_h5"];

        case BJLClientType_MiniProgram:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_Applet"];

        default:
            return [UIImage bjl_imageNamed:@"bjl_sc_device_default"];
    }
}

- (NSString *)timeStringWithTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void)_updateImageViewWithImageURLString:(NSString *)imageURLString
                                      size:(CGSize)size
                               placeholder:(UIImage *)placeholder {
    size = (CGSizeEqualToSize(size, CGSizeZero)
                ? CGSizeMake(imageMinWidth, imageMinHeight)
                : size);

    [self _updateImageViewWithImageOrNil:placeholder size:size];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxSize = MAX(screenSize.width, screenSize.height);
    NSString *aliURLString = BJLAliIMG_aspectFit(CGSizeMake(maxSize, maxSize),
        0.0,
        imageURLString,
        nil);
    bjl_weakify(self);
    self.messageImageView.backgroundColor = BJLTheme.toolButtonTitleColor;
    [self.messageImageView updateBJLAnimatedImageViewEmotion:nil
                                            emotionURLString:aliURLString
                                                   loopCount:0
                                                   completed:^(UIImage *_Nullable image, NSError *_Nullable error, NSURL *_Nullable imageURL) {
                                                       bjl_strongify(self);
                                                       if (image) {
                                                           self.messageImageView.backgroundColor = BJLTheme.toolButtonTitleColor;
                                                       }
                                                       [self _updateImageViewWithImageOrNil:self.messageImageView.animatedImage ? nil : image size:image.size];
                                                   }];
}

- (void)_updateImageViewWithImageOrNil:(nullable UIImage *)image size:(CGSize)size {
    if (image) {
        self.messageImageView.image = image;
    }
}

- (BOOL)shouldhandleUserSelectWithTapPoint:(CGPoint)point {
    if (CGRectContainsPoint(self.iconImageView.frame, point)
        || CGRectContainsPoint(self.nameLabel.frame, point)) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldhandleImageSelectWithTapPoint:(CGPoint)point {
    CGRect messageImageViewFrame = [self convertRect:self.messageImageView.frame fromView:self.messageContentView];
    if (CGRectContainsPoint(messageImageViewFrame, point)) {
        return YES;
    }
    return NO;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    if (self.userSelectCallback && [self shouldhandleUserSelectWithTapPoint:point]) {
        self.userSelectCallback(self);
        return;
    }

    CGRect messageImageViewFrame = [self convertRect:self.messageImageView.frame fromView:self.messageContentView];
    if (CGRectContainsPoint(messageImageViewFrame, point)) {
        if (self.imageSelectCallback && [self shouldhandleImageSelectWithTapPoint:point]) {
            self.imageSelectCallback(self);
        }
    }
}

- (void)translateButtonShouldShow:(BOOL)show {
    if (show) {
        [self.translateButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            [self.translateButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.width.height.equalTo(@16);
            }];
        }];
        if ([self.reuseIdentifier isEqualToString:BJLScTextAndTranslationCellReuseIdentifier]) {
            self.translateButton.selected = YES;
        }
        else {
            self.translateButton.selected = NO;
        }
    }
    else {
        [self.translateButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
            [self.translateButton bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.width.height.equalTo(@0);
            }];
        }];
    }
}

- (void)translateAction:(UIButton *)button {
    if (self.translateCallback) {
        self.translateCallback(self.message, [self.reuseIdentifier isEqualToString:BJLScTextAndTranslationCellReuseIdentifier]);
    }
}

@end
