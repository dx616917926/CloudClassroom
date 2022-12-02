//
//  BJLCDNListViewController.m
//  Alamofire
//
//  Created by HuXin on 2021/11/30.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLCDNListViewController.h"
#import "BJLCDNListCell.h"
#import "BJLScAppearance.h"

NSString *const BJLCDNListCellReuseIdentifier = @"kScBJLCDNListCellReuseIdentifier";

@interface BJLCDNListViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic) BJLRoom *room;

@property (nonatomic) UIView *backgroundView, *containerView, *topContainerView;
@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSIndexPath *lastIndexPath;
@end

@implementation BJLCDNListViewController

- (instancetype)initWithRoom:(BJLRoom *)room shouldFullScreent:(BOOL)shouldFullScreent {
    if (self = [super init]) {
        self.room = room;
        [self makeSubViews];
        if (shouldFullScreent) {
            self.backgroundView.backgroundColor = BJLTheme.windowBackgroundColor;
            [self.containerView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.right.top.equalTo(self.backgroundView);
                make.height.equalTo(@30);
            }];
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGFloat height = self.room.mediaVM.downLinkCDNCount * self.tableView.rowHeight + 30.0;
    [self.containerView bjl_updateConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.equalTo(@(height));
    }];
    [self.tableView reloadData];
}

- (void)makeSubViews {
    bjl_weakify(self);
    self.backgroundView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
            bjl_strongify(self);
            [self close];
        }];
        tap.delegate = self;
        [view addGestureRecognizer:tap];
        view;
    });
    [self.view addSubview:self.backgroundView];
    [self.backgroundView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];

    self.containerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = BJLTheme.windowBackgroundColor;
        view.layer.cornerRadius = 3.0;
        view;
    });
    [self.backgroundView addSubview:self.containerView];
    [self.containerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.equalTo(self.backgroundView);
        make.width.height.equalTo(@240.0);
    }];

    self.topContainerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.clearColor;
        view;
    });
    [self.containerView addSubview:self.topContainerView];
    [self.topContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.containerView);
        make.centerX.equalTo(self.containerView);
        make.width.equalTo(self.containerView);
        make.height.equalTo(@30.0);
    }];

    UILabel *titleLabel = ({
        UILabel *label = [UILabel new];
        label.text = BJLLocalizedString(@"切换线路");
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14.0];
        label;
    });
    [self.topContainerView addSubview:titleLabel];
    [titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.topContainerView);
        make.left.equalTo(self.topContainerView).offset(5.0);
        make.width.equalTo(@60.0);
    }];

    UIButton *closeButton = [UIButton new];
    [closeButton setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.topContainerView addSubview:closeButton];
    [closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.equalTo(self.topContainerView).offset(-5.0);
        make.centerY.equalTo(self.topContainerView);
    }];

    UIView *line = [UIView new];
    line.backgroundColor = BJLTheme.separateLineColor;
    [self.topContainerView addSubview:line];
    [line bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.topContainerView);
        make.height.equalTo(@(BJLScOnePixel));
    }];

    self.tableView = ({
        UITableView *tableView = [UITableView new];
        tableView.accessibilityIdentifier = BJLKeypath(self, tableView);
        tableView.rowHeight = 50.0;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.backgroundColor = [UIColor clearColor];
        [tableView registerClass:[BJLCDNListCell class] forCellReuseIdentifier:BJLCDNListCellReuseIdentifier];
        tableView;
    });
    [self.containerView addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.containerView);
        make.top.equalTo(self.topContainerView.bjl_bottom);
    }];
}

- (void)close {
    if (self.closeCallback) {
        self.closeCallback();
    }
    [self bjl_removeFromParentViewControllerAndSuperiew];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.room.mediaVM.downLinkCDNCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLCDNListCell *cell = [tableView dequeueReusableCellWithIdentifier:BJLCDNListCellReuseIdentifier];
    BOOL selected = indexPath.row == self.room.mediaVM.downLinkCDNIndex;
    if (selected) {
        self.lastIndexPath = indexPath;
    }
    cell.selectedImageView.image = [UIImage bjl_imageNamed:selected ? @"bjl_button_selected" : @"bjl_button_unselected"];
    [cell updateRouteLabel:indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndexPath && self.lastIndexPath == indexPath) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (self.lastIndexPath) {
        BJLCDNListCell *lastCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        lastCell.selectedImageView.image = [UIImage bjl_imageNamed:@"bjl_button_unselected"];
    }

    BJLCDNListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImageView.image = [UIImage bjl_imageNamed:@"bjl_button_selected"];
    self.lastIndexPath = indexPath;

    if (self.switchRouteCallback) {
        self.switchRouteCallback(indexPath.row);
        [self close];
    }
}

#pragma mark - UITapGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.containerView]) {
        return NO;
    }
    return YES;
}

@end
