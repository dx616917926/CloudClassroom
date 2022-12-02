//
//  BJPNoticeViewController.m
//  BJPlaybackUI
//
//  Created by xyp on 2021/5/17.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJVideoPlayerCore/BJVideoPlayerCore.h>

#import "BJPNoticeViewController.h"
#import "BJPAppearance.h"
#import "BJPQuestionCell.h"

@interface BJPNoticeViewController ()

@property (nonatomic, readonly, weak) BJVRoom *room;
@property (nonatomic) BJVNotice *notice;

@property (nonatomic) UIView *containerView, *labelBGView;
@property (nonatomic) UILabel *noticeLable, *linkTipLabl;
@property (nonatomic) UIImageView *emptyView;

@end

@implementation BJPNoticeViewController

- (instancetype)initWithRoom:(BJVRoom *)room {
    if (self = [super init]) {
        self->_room = room;
        [self makeSubviews];
        [self makeObserving];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateNoticeEmptyViewHidden:self.notice.noticeText.length];
}

#pragma mark - subviews

- (void)makeSubviews {
    self.view.backgroundColor = [UIColor blackColor];

    self.containerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_colorWithHexString:@"#F7F8F9"];
        view;
    });
    [self.view addSubview:self.containerView];
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    self.labelBGView = [UIView new];
    self.labelBGView.layer.cornerRadius = 8.0;
    self.labelBGView.layer.masksToBounds = YES;
    self.labelBGView.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.2];
    [self.containerView addSubview:self.labelBGView];
    [self.labelBGView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.containerView).offset(10);
        make.left.equalTo(self.containerView).offset(10);
        make.right.equalTo(self.containerView).offset(-10);
    }];

    self.noticeLable = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = [UIColor bjl_colorWithHexString:@"#333333"];
        label.userInteractionEnabled = YES;
        label;
    });
    [self.containerView addSubview:self.noticeLable];
    [self.noticeLable bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.labelBGView).offset(8);
        make.bottom.equalTo(self.labelBGView).offset(-8);
        make.left.equalTo(self.labelBGView).offset(10);
        make.right.equalTo(self.labelBGView).offset(-10);
    }];

    bjl_weakify(self);
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.noticeLinkCallback) {
            self.noticeLinkCallback(self.notice.linkURL);
        }
    }];
    [self.noticeLable addGestureRecognizer:tap];

    self.emptyView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.hidden = YES;
        imageView.image = [UIImage bjp_imageNamed:@"bjp_ic_notice_empty"];
        imageView;
    });
    [self.containerView insertSubview:self.emptyView aboveSubview:self.noticeLable];
    [self.emptyView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.containerView);
        make.centerY.equalTo(self.containerView).offset(-20);
        make.width.equalTo(self.containerView).multipliedBy(0.55);
        make.height.equalTo(self.emptyView.bjl_width).multipliedBy(self.emptyView.image.size.height / self.emptyView.image.size.width);
    }];

    self.linkTipLabl = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor bjl_colorWithHexString:@"#999999"];
        label.text = BJLLocalizedString(@"点击公告可以跳转");
        label.hidden = YES;
        label;
    });
    [self.containerView addSubview:self.linkTipLabl];
    [self.linkTipLabl bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.containerView).offset(-10);
        make.top.equalTo(self.labelBGView.bjl_bottom).offset(4);
    }];

    UILabel *emptyLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"暂无公告");
        label.textColor = [UIColor bjl_colorWithHexString:@"#9FA8B5"];
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self.emptyView addSubview:emptyLabel];
    [emptyLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.emptyView);
        make.height.equalTo(@20);
        make.top.equalTo(self.emptyView.bjl_bottom);
    }];
}

#pragma mark - observing

- (void)makeObserving {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, notice) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        self.notice = self.room.roomVM.notice;
        self.noticeLable.text = self.room.roomVM.notice.noticeText;
        [self updateNoticeEmptyViewHidden:self.noticeLable.text.length];
        [self updateLinkTipLabelHidden:(self.room.roomVM.notice.linkURL == nil)];
        if (self.noticeChangeCallback) {
            self.noticeChangeCallback();
        }
        return YES;
    }];
}

#pragma mark - actions

- (void)updateNoticeEmptyViewHidden:(BOOL)hidden {
    self.emptyView.hidden = hidden;
    self.labelBGView.hidden = !hidden;
    self.noticeLable.hidden = !hidden;
}

- (void)updateLinkTipLabelHidden:(BOOL)hidden {
    if (hidden == self.linkTipLabl.hidden) {
        return;
    }
    self.linkTipLabl.hidden = hidden;
}

@end
