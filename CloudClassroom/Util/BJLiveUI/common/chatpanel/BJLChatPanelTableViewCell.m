//
//  BJLChatPanelTableViewCell.m
//  BJLiveUI
//
//  Created by 凡义 on 2021/4/6.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif
#import "BJLAnimatedImage.h"
#import "BJLAnimatedImageView+emoticon.h"
#import "BJLChatPanelTableViewCell.h"
#import "BJLAppearance.h"
#import "BJLTheme.h"

#pragma mark - BJLChatPanleModel

@interface BJLChatPanelModel ()

@property (nonatomic, readwrite) BOOL reachMaxDuration;
@property (nonatomic, readwrite) BJLMessage *message;
@property (nonatomic, readwrite) NSInteger maxDuration;
@property (nonatomic, readwrite) BOOL important;

@end

/**
 有两种消失的情况, 第一种是时间到了指定时长, 不需要显示了, 从显示的数据源中会移除这个model
 第二种可能是被点击了之后消失, 这种情况目前不从数据源中移除
 */
@implementation BJLChatPanelModel

- (instancetype)initWithMessage:(BJLMessage *)message duration:(NSInteger)duration important:(BOOL)important {
    if (self = [super init]) {
        self.message = message;
        self.maxDuration = duration;
        self.reachMaxDuration = NO;
        self.important = important;
        if (duration > 0) {
            bjl_weakify(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                bjl_strongify(self);
                self.reachMaxDuration = YES;
            });
        }
    }
    return self;
}

@end

#pragma mark - BJLChatPanelTableViewCell

static const CGFloat imageMinWidth = 50.0, imageMinHeight = 50.0;
static const CGFloat imageMaxWidth = 100.0, imageMaxHeight = 100.0;
@interface BJLChatPanelTableViewCell ()

@property (nonatomic, nullable) BJLChatPanelModel *promptModel;
@property (nonatomic, nullable) id<BJLObservation> promptDurationObserver;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIButton *promptButton;
@property (nonatomic) UILabel *promptLabel, *userNameLabel;
@property (nonatomic) BJLAnimatedImageView *messageImageView;

@end

@implementation BJLChatPanelTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeSubviewsAndConstraints];
        [self makeObserving];
    }
    return self;
}

- (void)makeSubviewsAndConstraints {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.containerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view.layer.cornerRadius = 4.0;
        view.layer.masksToBounds = YES;
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor bjl_colorWithHex:0XDDDDDD alpha:0.1].CGColor;
        view;
    });
    [self.contentView addSubview:self.containerView];

    [self.contentView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self);
    }];

    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.contentView).offset(-BJLAppearance.promptCellSmallSpace);
        make.top.equalTo(self.contentView).offset(BJLAppearance.promptCellSmallSpace);
        make.left.equalTo(self.contentView).offset(BJLAppearance.promptCellSmallSpace);
        make.right.lessThanOrEqualTo(self.contentView).offset(-BJLAppearance.promptCellSmallSpace);
    }];

    self.userNameLabel = ({
        UILabel *label = [UILabel new];
        label.backgroundColor = UIColor.clearColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = BJLTheme.brandColor;
        label;
    });
    [self.containerView addSubview:self.userNameLabel];

    self.promptLabel = ({
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:12.0];
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.numberOfLines = 5;
        label.textColor = BJLTheme.viewTextColor;
        label;
    });
    [self.containerView addSubview:self.promptLabel];

    [self.userNameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.containerView).offset(BJLAppearance.promptCellSmallSpace);
        make.top.equalTo(self.containerView).offset(BJLAppearance.promptCellSmallSpace / 2);
        make.right.equalTo(self.containerView).offset(-BJLAppearance.promptCellSmallSpace);
        make.height.equalTo(@24.0);
    }];
    [self.promptLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.equalTo(self.userNameLabel);
        make.bottom.equalTo(self.containerView).offset(-BJLAppearance.promptCellSmallSpace / 2);
        make.top.equalTo(self.userNameLabel.bjl_bottom);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self clearCell];
}

- (void)makeObserving {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self, promptModel)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self stopPromptDurationObserving];
             if (!!now) {
                 [self makePromptDurationObserving];
             }
             return YES;
         }];
}

- (void)makePromptDurationObserving {
    bjl_weakify(self);
    self.promptDurationObserver = [self bjl_kvo:BJLMakeProperty(self.promptModel, reachMaxDuration)
                                       observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
                                           bjl_strongify(self);
                                           if (self.promptModel.reachMaxDuration) {
                                               [self clearCell];
                                           }
                                           return YES;
                                       }];
}

- (void)stopPromptDurationObserving {
    [self.promptDurationObserver stopObserving];
    self.promptDurationObserver = nil;
}

- (void)updateWithMessagePanelModel:(BJLChatPanelModel *)panelModel roomType:(BJLRoomType)type {
    if (panelModel.reachMaxDuration) {
        [self clearCell];
    }
    else {
        self.containerView.hidden = NO;
        self.promptModel = panelModel;
        self.containerView.backgroundColor = panelModel.important ? BJLTheme.warningColor : type == BJLRoomType_interactiveClass ? BJLTheme.toolboxBackgroundColor
                                                                                                                                 : [UIColor bjl_colorWithHexString:@"#313847" alpha:0.6];

        self.userNameLabel.text = [NSString stringWithFormat:@"%@: \n", panelModel.message.fromUser.name];

        NSAttributedString *text = [NSAttributedString new];
        UIColor *textColor = type == BJLRoomType_interactiveClass ? BJLTheme.viewTextColor : UIColor.whiteColor;
        if (panelModel.message.text) {
            text = [panelModel.message attributedEmoticonStringWithEmoticonSize:16.0 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0], NSForegroundColorAttributeName: textColor} cached:YES cachedKey:@"cache"];
        }
        if (panelModel.message.type == BJLMessageType_image) {
            [self makeMessageImageView];
            [self _updateImageViewWithImageURLString:panelModel.message.imageURLString
                                                size:CGSizeMake(panelModel.message.imageWidth, panelModel.message.imageHeight)
                                         placeholder:nil];
        }
        self.promptLabel.attributedText = text;
    }
}

- (void)clearCell {
    self.promptModel = nil;
    self.containerView.hidden = YES;
    self.promptLabel.text = nil;
    self.promptLabel.attributedText = nil;
    [self.messageImageView removeFromSuperview];
    self.messageImageView = nil;
}

- (void)makeMessageImageView {
    self.messageImageView = ({
        BJLAnimatedImageView *imageView = [BJLAnimatedImageView new];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.containerView addSubview:imageView];
        imageView.accessibilityIdentifier = BJLKeypath(self, messageImageView);
        imageView;
    });
    [self.messageImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.userNameLabel);
        make.right.equalTo(self.containerView).offset(-BJLAppearance.promptCellSmallSpace);
        make.bottom.equalTo(self.containerView).offset(-BJLAppearance.promptCellSmallSpace / 2);
        make.top.equalTo(self.userNameLabel.bjl_bottom);
    }];
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
    [self updateImgViewConstraintsWithSize:BJLImageViewSize(image ? image.size : size, CGSizeMake(imageMinWidth, imageMinHeight), ({
        CGSizeMake(imageMaxWidth, imageMaxHeight);
    }))];
}

- (void)updateImgViewConstraintsWithSize:(CGSize)size {
    [self.messageImageView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.width.equalTo(@(size.width));
        make.height.equalTo(@(size.height)).priorityHigh();
    }];
}
@end
