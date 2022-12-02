//
//  BJLMediaCheckBaseView.m
//  BJLiveUIBase
//
//  Created by xijia dai on 2021/10/26.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLMediaCheckBaseView.h"
#import "BJLAppearance.h"

const CGFloat cellHeight = 32.0;

@interface BJLMediaDeviceCell ()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UIImageView *checkImageView;

@end

@implementation BJLMediaDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentLeft;
        label;
    });
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.contentView).offset(10.0);
        make.top.bottom.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.contentView).offset(-20.0);
    }];
    self.checkImageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_check_pass"]];
    self.checkImageView.hidden = YES;
    [self.contentView addSubview:self.checkImageView];
    [self.checkImageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.contentView).offset(-5.0);
        make.centerY.equalTo(self.contentView);
        make.size.equal.sizeOffset(CGSizeMake(16.0, 16.0));
    }];
}

- (void)updateName:(NSString *)name selected:(BOOL)selected {
    self.nameLabel.text = name;
    self.checkImageView.hidden = !selected;
}

@end

@implementation BJLMediaCheckBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)setupSubviews {
    bjl_weakify(self);
    self.tipLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = BJLTheme.viewSubTextColor;
        label;
    });
    [self addSubview:self.tipLabel];
    [self.tipLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self);
        make.height.equalTo(@20.0);
    }];

    self.arrowButton = ({
        UIButton *button = [UIButton new];
        button.layer.borderColor = BJLTheme.roomBackgroundColor.CGColor;
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = 5.0;
        button.clipsToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button bjl_setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage bjl_imageNamed:@"bjl_check_arrow"]];
        [button addSubview:imageView];
        [imageView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.centerY.equalTo(button);
            make.right.equalTo(button).offset(-10.0);
            make.size.equal.sizeOffset(CGSizeMake(24.0, 24.0));
        }];
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.dataSource.count <= 1) {
                return;
            }
            button.selected = !button.selected;
            if (button.selected) {
                [self addSubview:self.tableView];
                [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                    make.left.right.equalTo(self.arrowButton);
                    make.top.equalTo(self.arrowButton);
                    make.height.equalTo(@(cellHeight * self.dataSource.count));
                }];
                [self.tableView reloadData];
            }
            else {
                [self.tableView removeFromSuperview];
            }
        }];
        button;
    });
    [self addSubview:self.arrowButton];
    [self.arrowButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self);
        make.size.equal.sizeOffset(CGSizeMake(320.0, cellHeight));
        make.top.equalTo(self.tipLabel.bjl_bottom).offset(8.0);
        make.left.equalTo(self.tipLabel);
    }];

    self.tableView = ({
        UITableView *tableView = [UITableView new];
        tableView.layer.borderWidth = 1.0;
        tableView.layer.borderColor = BJLTheme.roomBackgroundColor.CGColor;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = cellHeight;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView;
    });
    [self addSubview:self.tableView];
}

- (void)makeCheckedViewWithTitle:(NSString *)title
                  confirmMessage:(NSString *)confirmMessage
                   confirmHander:(void (^)(UIButton *button))confirmHander
                   opposeMessage:(NSString *)oppseMessage
                    opposeHander:(void (^)(UIButton *button))opposeHander
                           error:(nullable BJLError *)error {
    [self.checkLabel removeFromSuperview];
    [self.opposeButton removeFromSuperview];
    [self.confirmButton removeFromSuperview];

    self.opposeButton = [self makeButtonWithMessage:oppseMessage focus:!!error disable:NO];
    [self.opposeButton bjl_addHandler:opposeHander];
    [self addSubview:self.opposeButton];
    [self.opposeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self).multipliedBy(0.75);
        make.right.equalTo(self.bjl_centerX).offset(-16.0);
        make.size.equal.sizeOffset(CGSizeMake(144.0, 40.0));
    }];

    self.confirmButton = [self makeButtonWithMessage:confirmMessage focus:NO disable:!!error];
    [self.confirmButton bjl_addHandler:confirmHander];
    [self addSubview:self.confirmButton];
    [self.confirmButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.bottom.width.equalTo(self.opposeButton);
        make.left.equalTo(self.bjl_centerX).offset(16.0);
    }];

    self.checkLabel = ({
        UILabel *label = [UILabel new];
        label.text = error ? (error.localizedDescription ?: error.localizedFailureReason) : title;
        label.textColor = error ? BJLTheme.warningColor : BJLTheme.viewTextColor;
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self addSubview:self.checkLabel];
    [self.checkLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.equalTo(self.opposeButton.bjl_top).offset(-10.0);
        make.centerX.equalTo(self);
        make.height.equalTo(@20.0);
    }];
}

#pragma mark -

- (NSArray *)dataSource {
    return [NSArray new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark -

- (UIButton *)makeButtonWithMessage:(NSString *)message focus:(BOOL)focus disable:(BOOL)disable {
    UIButton *button = [UIButton new];
    button.layer.cornerRadius = 8.0;
    button.layer.masksToBounds = YES;
    button.enabled = !disable;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button bjl_setTitle:message forState:UIControlStateNormal];
    if (focus) {
        [button bjl_setTitleColor:BJLTheme.buttonTextColor forState:UIControlStateNormal];
        [button bjl_setBackgroundColor:BJLTheme.brandColor forState:UIControlStateNormal];
    }
    else if (disable) {
        [button bjl_setTitleColor:BJLTheme.viewSubTextColor forState:UIControlStateNormal];
        [button bjl_setBackgroundColor:BJLTheme.roomBackgroundColor forState:UIControlStateNormal];
    }
    else {
        button.layer.borderColor = BJLTheme.brandColor.CGColor;
        button.layer.borderWidth = 1.0;
        [button bjl_setTitleColor:BJLTheme.brandColor forState:UIControlStateNormal];
    }
    return button;
}

@end
