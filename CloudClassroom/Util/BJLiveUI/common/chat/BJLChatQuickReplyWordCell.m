//
//  BJLChatQuickReplyWordCell.m
//  BJLiveUIBigClass
//
//  Created by HuXin on 2021/9/17.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLChatQuickReplyWordCell.h"
#import <BJLiveBase/BJLiveBase.h>
#import "BJLTheme.h"

@interface BJLChatQuickReplyWordCell ()

@property (nonatomic) UIView *contrainerView;

@end

@implementation BJLChatQuickReplyWordCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self makeSubviewsAndConstraints];
    }
    return self;
}

- (void)makeSubviewsAndConstraints {
    self.contrainerView = [UIView new];
    self.contrainerView.backgroundColor = [UIColor bjl_colorWithHexString:@"#9FA8B5" alpha:0.05];
    self.contrainerView.layer.cornerRadius = 4;
    self.contrainerView.layer.borderColor = BJLTheme.separateLineColor.CGColor;
    self.contrainerView.layer.borderWidth = 1;
    [self.contentView addSubview:self.contrainerView];

    [self.contrainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.contentView);
    }];

    self.replyWordLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = BJLTheme.viewSubTextColor;
        label;
    });
    [self.contrainerView addSubview:self.replyWordLabel];

    [self.replyWordLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.equalTo(self.contrainerView).offset(5);
        make.bottom.right.equalTo(self.contrainerView).offset(-5);
    }];
}

- (void)updateReplyWordWithString:(NSString *)string {
    self.replyWordLabel.text = string;
}

@end
