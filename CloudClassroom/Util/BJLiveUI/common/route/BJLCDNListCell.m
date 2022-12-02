//
//  BJLCDNListCell.m
//  BJLiveUIBigClass
//
//  Created by HuXin on 2021/11/30.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLCDNListCell.h"
#import <BJLiveCore/BJLiveCore.h>
#import "BJLScAppearance.h"

@interface BJLCDNListCell ()

@property (nonatomic) UILabel *routeLabel;
@property (nonatomic) NSArray *routeArray;

@end

@implementation BJLCDNListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeSubViews];
        self.routeArray = @[@"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十"];
    }
    return self;
}

- (void)makeSubViews {
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;

    self.selectedImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage bjl_imageNamed:@"bjl_button_unselected"];
        imageView.backgroundColor = UIColor.clearColor;
        imageView;
    });
    [self.contentView addSubview:self.selectedImageView];

    self.routeLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"线路");
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self.contentView addSubview:self.routeLabel];

    [self.selectedImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15.0);
    }];

    [self.routeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.selectedImageView);
        make.left.equalTo(self.selectedImageView.bjl_right).offset(10.0);
    }];
}

- (void)updateRouteLabel:(NSInteger)index {
    self.routeLabel.text = [NSString stringWithFormat:@"线路%@（%@）", index < 10 ? self.routeArray[index] : @(index), index == 0 ? @"主" : @"副"];
}

@end
