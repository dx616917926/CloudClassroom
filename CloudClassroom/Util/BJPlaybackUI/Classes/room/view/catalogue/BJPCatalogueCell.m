//
//  BJPCatalogueCell.m
//  BJPlaybackUI
//
//  Created by 凡义 on 2021/1/12.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJPCatalogueCell.h"
#import "BJPAppearance.h"

@interface BJPCatalogueCell ()

@property (nonatomic) UIView *containerView;
@property (nonatomic) UILabel *contentLabel, *timeLabel;
@property (nonatomic) UIButton *tapButton;
@property (nonatomic) UIImageView *pptImageView, *placeHolderImageView;

@property (nonatomic) BJLSlidePage *slidePage;
@end

static NSString *const cellIdentifier = @"catalogueCell";
static NSString *const longCellIdentifier = @"longCatalogueCell";
@implementation BJPCatalogueCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupSubview];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentLabel.text = nil;
    self.timeLabel.text = nil;
    self.clickCallback = nil;
}

#pragma mark - subview

- (void)setupSubview {
    UIView *contentView = self.contentView;
    [contentView addSubview:self.containerView];
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(contentView);
        make.left.right.equalTo(contentView).inset(12.0);
        make.top.bottom.equalTo(contentView).inset(5.0);
    }];

    [self.containerView addSubview:self.contentLabel];
    [self.containerView addSubview:self.timeLabel];
    [self.containerView addSubview:self.placeHolderImageView];
    [self.containerView addSubview:self.pptImageView];
    [self.contentView addSubview:self.tapButton];

    CGFloat verticalMargin = 5.0;
    [self.contentLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.containerView).offset(10.0);
        make.right.lessThanOrEqualTo(self.timeLabel.bjl_left).offset(-5.0);
        make.top.equalTo(self.containerView).inset(verticalMargin);
        make.height.greaterThanOrEqualTo(@(18 * 2 - 2 * verticalMargin));
    }];

    [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentLabel);
        make.width.greaterThanOrEqualTo(@70.0);
        make.height.equalTo(self.contentLabel);
        make.right.equalTo(self.containerView).offset(-10.0);
    }];

    [self.placeHolderImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.contentLabel.bjl_bottom).offset(5.0);
        make.centerX.equalTo(self.containerView);
        make.left.equalTo(self.containerView).offset(10.0);
        make.right.equalTo(self.containerView).offset(-10.0);
        if (self.reuseIdentifier == cellIdentifier) {
            make.height.equalTo(@0.0);
            make.bottom.equalTo(self.containerView);
        }
        else {
            make.height.equalTo(@150.0);
            make.bottom.equalTo(self.containerView).offset(-10.0);
        }
    }];

    [self.pptImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.placeHolderImageView);
    }];

    [self.tapButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.equalTo(self.contentView);
    }];
}

#pragma mark - pub

- (void)updateCellWithModel:(BJPPPTCatalogueModel *)catalogue pptUrl:(nullable NSString *)pptUrl playing:(BOOL)playing {
    self.contentLabel.text = catalogue.title.length ? catalogue.title : [NSString stringWithFormat:@"第%td页", (catalogue.pageIndex + 1)];

    NSTimeInterval time = catalogue.msOffsetTimestamp;
    NSString *timeString = nil;
    int hours = time / 3600 / 1000;
    int minums = ((long long)time / 1000 % 3600) / 60;
    int seconds = ceil((time - (hours * 3600 * 1000) - (minums * 60 * 1000)) / 1000.0);
    if (hours > 0) {
        timeString = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minums, seconds];
    }
    else {
        if (minums > 0 || (minums <= 0 && seconds > 10)) {
            timeString = [NSString stringWithFormat:@"00:%02d:%02d", minums, seconds];
        }
        else {
            timeString = [NSString stringWithFormat:@"00:00:%02d", seconds];
        }
    }
    self.timeLabel.text = timeString;
    UIColor *selectedColor = [UIColor bjl_colorWithHex:0X1795FF];
    self.containerView.backgroundColor = playing ? selectedColor : [UIColor bjl_colorWithHex:0XB0BEC5 alpha:0.3];
    if (pptUrl) {
        [self.pptImageView bjl_setImageWithURL:[NSURL URLWithString:pptUrl]];
    }
}

#pragma mark - get

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.accessibilityIdentifier = BJLKeypath(self, containerView);
        _containerView.backgroundColor = [UIColor bjl_colorWithHex:0XB0BEC5 alpha:0.3];
        _containerView.layer.masksToBounds = YES;
        _containerView.layer.cornerRadius = 18.0;
    }
    return _containerView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.accessibilityIdentifier = BJLKeypath(self, contentLabel);
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.font = [UIFont systemFontOfSize:14.0];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.numberOfLines = 2;
    }
    return _contentLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.accessibilityIdentifier = BJLKeypath(self, timeLabel);
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:14.0];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.numberOfLines = 1;
    }
    return _timeLabel;
}

- (UIImageView *)placeHolderImageView {
    if (!_placeHolderImageView) {
        _placeHolderImageView = [UIImageView new];
        _placeHolderImageView.accessibilityIdentifier = BJLKeypath(self, placeHolderImageView);
        _placeHolderImageView.layer.cornerRadius = 8.0;
        _placeHolderImageView.layer.masksToBounds = YES;
        _placeHolderImageView.backgroundColor = [UIColor bjl_colorWithHexString:@"#000000" alpha:0.1];
        _placeHolderImageView.image = [UIImage bjp_imageNamed:@"bjp_sc_playback_shortcut"];
    }
    return _placeHolderImageView;
}

- (UIImageView *)pptImageView {
    if (!_pptImageView) {
        _pptImageView = [UIImageView new];
        _pptImageView.accessibilityIdentifier = BJLKeypath(self, pptImageView);
        _pptImageView.layer.cornerRadius = 8.0;
        _pptImageView.layer.masksToBounds = YES;
    }
    return _pptImageView;
}

- (UIButton *)tapButton {
    if (!_tapButton) {
        _tapButton = [UIButton new];
        bjl_weakify(self);
        [_tapButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.clickCallback) {
                self.clickCallback();
            }
        }];
    }
    return _tapButton;
}

@end
