//
//  BJLScQuestionCell.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/25.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScQuestionCell.h"
#import "BJLAppearance.h"

NSString
    *const BJLScQuestionCellReuseIdentifier = @"kQuestionCellReuseIdentifier",
           *const BJLScQuestionReplyCellReuseIdentifier = @"kQuestionReplyCellReuseIdentifier";

@interface BJLScQuestionCell ()

@property (nonatomic) BJLQuestion *question;
@property (nonatomic) BJLQuestionReply *reply;
@property (nonatomic) UILabel *contentLabel;
@property (nonatomic) UIImageView *contentImage;

@property (nonatomic) UILabel *nameLabel, *timeLabel;

@end

@implementation BJLScQuestionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeSubviewsAndConstraints];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentLabel.attributedText = nil;
}

- (void)makeSubviewsAndConstraints {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    bjl_weakify(self);
    UILongPressGestureRecognizer *longPressGestureRecognizer = [UILongPressGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (gesture.state == UIGestureRecognizerStateBegan && self.longPressCallback) {
            self.longPressCallback(self.question, self.reply, [gesture locationInView:self]);
        }
    }];
    [self addGestureRecognizer:longPressGestureRecognizer];
    UITapGestureRecognizer *singleTapGestureRecognizer = [UITapGestureRecognizer bjl_gestureWithHandler:^(UITapGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        gesture.numberOfTapsRequired = 1;
        if (self.singleTapCallback) {
            self.singleTapCallback(self.question, self.reply, [gesture locationInView:self]);
        }
    }];
    [self addGestureRecognizer:singleTapGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];

    if ([self.reuseIdentifier isEqualToString:BJLScQuestionCellReuseIdentifier]) {
        self.contentLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.layer.masksToBounds = YES;
            label.backgroundColor = [UIColor bjl_colorWithHex:0X9FA8B5 alpha:0.1];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = BJLTheme.viewTextColor;
            label;
        });

        self.contentImage = ({
            UIImageView *view = [UIImageView new];
            view.backgroundColor = UIColor.clearColor;
            view;
        });

        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.contentImage];
        [self.contentLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.contentView).inset(8.0);
            make.bottom.top.equalTo(self.contentView);
        }];

        [self.contentImage bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.contentLabel.bjl_top).offset(-4);
            make.left.equalTo(self.contentLabel.bjl_left);
        }];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScQuestionReplyCellReuseIdentifier]) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_colorWithHex:0X9FA8B5 alpha:0.1];

        self.nameLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 1;
            label.layer.masksToBounds = YES;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = BJLTheme.viewTextColor;
            label;
        });

        self.timeLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 1;
            label.layer.masksToBounds = YES;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = BJLTheme.viewSubTextColor;
            label;
        });

        self.contentLabel = ({
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.layer.masksToBounds = YES;
            label.backgroundColor = [UIColor bjl_colorWithHex:0X9FA8B5 alpha:0.1];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = BJLTheme.subButtonTextColor;
            label;
        });

        self.contentImage = ({
            UIImageView *view = [UIImageView new];
            view.backgroundColor = UIColor.clearColor;
            view;
        });

        UIView *line = ({
            UIView *view = [UIView new];
            view.backgroundColor = BJLTheme.separateLineColor;
            view;
        });

        [self.contentView addSubview:view];
        [view addSubview:self.nameLabel];
        [view addSubview:self.timeLabel];
        [view addSubview:line];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.contentImage];

        [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.contentView).inset(8.0);
            make.height.equalTo(@28);
            make.top.equalTo(self.contentView);
        }];
        [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(view);
            make.height.equalTo(@(BJLScOnePixel));
            make.left.right.equalTo(view);
        }];
        [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(line.bjl_bottom).offset(4.0);
            make.bottom.equalTo(view).offset(-4.0);
            make.left.equalTo(view).inset(4.0);
            make.right.equalTo(view.bjl_centerX);
        }];
        [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.right.equalTo(view).inset(4.0);
            make.left.equalTo(view.bjl_centerX);
            make.top.height.equalTo(self.nameLabel);
        }];
        [self.contentLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.contentView).inset(8.0);
            make.bottom.equalTo(self.contentView);
            make.top.equalTo(view.bjl_bottom);
        }];

        [self.contentImage bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.contentLabel.bjl_top).offset(-4);
            make.left.equalTo(self.contentLabel.bjl_left);
        }];
    }
}

- (void)updateWithQuestion:(nullable BJLQuestion *)question questionReply:(nullable BJLQuestionReply *)questionReply {
    self.question = question;
    self.reply = questionReply;
    if ([self.reuseIdentifier isEqualToString:BJLScQuestionCellReuseIdentifier]) {
        self.contentImage.image = [UIImage bjl_imageNamed:@"bjl_sc_question_title"];
        self.contentLabel.text = [NSString stringWithFormat:@"        %@", question.content];
    }
    else if ([self.reuseIdentifier isEqualToString:BJLScQuestionReplyCellReuseIdentifier]) {
        // 不再做是否发布的区分
        self.contentImage.image = [UIImage bjl_imageNamed:@"bjl_sc_question_reply"];
        self.contentLabel.text = [NSString stringWithFormat:@"        %@", questionReply.content];

        self.nameLabel.text = questionReply.fromUser.displayName;
        self.timeLabel.text = [self timeStringWithTimeInterval:questionReply.createTime];
    }
}

- (NSString *)timeStringWithTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSArray<NSString *> *)allCellIdentifiers {
    return @[BJLScQuestionCellReuseIdentifier,
        BJLScQuestionReplyCellReuseIdentifier];
}

@end