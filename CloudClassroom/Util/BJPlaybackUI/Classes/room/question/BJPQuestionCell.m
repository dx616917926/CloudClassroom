//
//  BJPQuestionCell.m
//  BJPlaybackUI
//
//  Created by xijia dai on 2019/12/5.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

#import "BJPQuestionCell.h"
#import "BJPAppearance.h"

NSString
    *const BJPQuestionCellReuseIdentifier = @"kQuestionCellReuseIdentifier",
           *const BJPQuestionReplyCellReuseIdentifier = @"kQuestionReplyCellReuseIdentifier";

@interface BJPQuestionCell ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *contentLabel;

@end

@implementation BJPQuestionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeSubviewsAndConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.attributedText = nil;
    self.contentLabel.text = nil;
}

- (void)makeSubviewsAndConstraints {
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    bjl_weakify(self);
    UILongPressGestureRecognizer *longPressGestureRecognizer = [UILongPressGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (gesture.state == UIGestureRecognizerStateBegan && self.longPressCallback) {
            self.longPressCallback(self.contentLabel.text);
        }
    }];
    [self addGestureRecognizer:longPressGestureRecognizer];
    UITapGestureRecognizer *singleTapGestureRecognizer = [UITapGestureRecognizer bjl_gestureWithHandler:^(UITapGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        gesture.numberOfTapsRequired = 1;
        if (self.singleTapCallback) {
            self.singleTapCallback();
        }
    }];
    [self addGestureRecognizer:singleTapGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];

    if ([self.reuseIdentifier isEqualToString:BJPQuestionCellReuseIdentifier]) {
        self.titleLabel = ({
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            label;
        });
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.left.right.equalTo(self.contentView).inset(16.0);
            make.height.equalTo(@16.0);
        }];
        self.contentLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:15.0];
            label.textColor = [UIColor blackColor];
            label;
        });
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.titleLabel.bjl_bottom).offset(8.0);
            make.left.bottom.right.equalTo(self.contentView).inset(16.0);
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJPQuestionReplyCellReuseIdentifier]) {
        UIView *containerView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor bjp_lightGrayBackgroundColor];
            view.layer.borderWidth = 1.0;
            view.layer.borderColor = [UIColor bjp_grayImagePlaceholderColor].CGColor;
            view;
        });
        [self.contentView addSubview:containerView];
        [containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.bottom.right.equalTo(self.contentView).inset(16.0);
            make.top.equalTo(self.contentView);
        }];
        self.titleLabel = ({
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            label;
        });
        [containerView addSubview:self.titleLabel];
        [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(containerView).inset(10.0);
            make.top.equalTo(containerView).offset(16.0);
            make.height.equalTo(@16.0);
        }];
        self.contentLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor blackColor];
            label;
        });
        [containerView addSubview:self.contentLabel];
        [self.contentLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.titleLabel.bjl_bottom).offset(8.0);
            make.left.right.equalTo(containerView).inset(10.0);
            make.bottom.equalTo(containerView).offset(-16.0);
        }];
    }
}

- (void)updateWithQuestion:(nullable BJVQuestion *)question questionReply:(nullable BJVQuestionReply *)questionReply {
    if ([self.reuseIdentifier isEqualToString:BJPQuestionCellReuseIdentifier]) {
        self.titleLabel.attributedText = [self attributedStringWithImage:[UIImage bjp_imageNamed:@"bjp_ic_text_question"] content:question.fromUser.displayName contentFont:[UIFont boldSystemFontOfSize:14.0] timeInterval:question.createTime timeIntervalFont:[UIFont systemFontOfSize:12.0]];
        self.contentLabel.text = question.content;
    }
    else if ([self.reuseIdentifier isEqualToString:BJPQuestionReplyCellReuseIdentifier]) {
        self.titleLabel.attributedText = [self attributedStringWithImage:[UIImage bjp_imageNamed:@"bjp_ic_text_questionreply"] content:[NSString stringWithFormat:BJLLocalizedString(@"%@回复"), questionReply.fromUser.displayName] contentFont:[UIFont boldSystemFontOfSize:12.0] timeInterval:questionReply.createTime timeIntervalFont:[UIFont systemFontOfSize:12.0]];
        self.contentLabel.text = questionReply.content;
    }
}

- (NSAttributedString *)attributedStringWithImage:(UIImage *)image content:(NSString *)content contentFont:(UIFont *)contentFont timeInterval:(NSTimeInterval)timeInterval timeIntervalFont:(UIFont *)timeIntervalFont {
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(0, -2.0, 14.0, 14.0);
    [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    NSAttributedString *userName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", content]
                                                                   attributes:@{NSFontAttributeName: contentFont,
                                                                       NSForegroundColorAttributeName: [UIColor bjp_darkGrayTextColor]}];
    [attributedString appendAttributedString:userName];
    NSAttributedString *createTime = [[NSAttributedString alloc] initWithString:[self timeStringWithTimeInterval:timeInterval]
                                                                     attributes:@{NSFontAttributeName: timeIntervalFont,
                                                                         NSForegroundColorAttributeName: [UIColor bjp_lightGrayTextColor]}];
    [attributedString appendAttributedString:createTime];
    return attributedString;
}

- (NSString *)timeStringWithTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSArray<NSString *> *)allCellIdentifiers {
    return @[BJPQuestionCellReuseIdentifier,
        BJPQuestionReplyCellReuseIdentifier];
}
@end
