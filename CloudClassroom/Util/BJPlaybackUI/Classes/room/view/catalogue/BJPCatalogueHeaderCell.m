//
//  BJPCatalogueHeaderCell.m
//  BJPlaybackUI
//
//  Created by 凡义 on 2021/1/12.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJPCatalogueHeaderCell.h"
#import "BJPAppearance.h"

@interface BJPCatalogueHeaderCell ()

@property (nonatomic) UILabel *colorLabel, *textTitleLabel;

@end

@implementation BJPCatalogueHeaderCell

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
    self.textTitleLabel.text = nil;
}

#pragma mark - private

- (void)setupSubview {
    [self.contentView addSubview:self.colorLabel];
    [self.contentView addSubview:self.textTitleLabel];

    [self.colorLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@6.0);
        make.left.equalTo(self.contentView).offset(12.0);
    }];

    [self.textTitleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.colorLabel.bjl_right).offset(5.0);
        make.right.lessThanOrEqualTo(self.contentView).offset(-12.0);
    }];
}

#pragma mark - public

- (void)updateCellWithModel:(BJLDocument *)document {
    self.textTitleLabel.text = [document.fileID isEqualToString:BJLBlackboardID] ? @"白板" : document.fileName;
}

#pragma mark - get

- (UILabel *)colorLabel {
    if (!_colorLabel) {
        _colorLabel = [UILabel new];
        _colorLabel.accessibilityIdentifier = BJLKeypath(self, colorLabel);
        _colorLabel.backgroundColor = [UIColor bjl_colorWithHex:0X1795FF];
        _colorLabel.layer.cornerRadius = 3.0;
        _colorLabel.layer.masksToBounds = YES;
    }
    return _colorLabel;
}

- (UILabel *)textTitleLabel {
    if (!_textTitleLabel) {
        _textTitleLabel = [UILabel new];
        _textTitleLabel.accessibilityIdentifier = BJLKeypath(self, textTitleLabel);
        _textTitleLabel.backgroundColor = [UIColor clearColor];
        _textTitleLabel.textColor = [UIColor whiteColor];
        _textTitleLabel.font = [UIFont systemFontOfSize:14.0];
        _textTitleLabel.textAlignment = NSTextAlignmentLeft;
        _textTitleLabel.numberOfLines = 2;
    }
    return _textTitleLabel;
}

@end
