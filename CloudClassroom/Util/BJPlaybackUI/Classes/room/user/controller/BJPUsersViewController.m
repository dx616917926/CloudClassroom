//
//  BJPUsersViewController.m
//  BJPlaybackUI
//
//  Created by HuangJie on 2018/7/2.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import "BJPUsersViewController.h"
#import "BJPUserCell.h"
#import "BJPAppearance.h"

static NSString *const cellIdentifier = @"userCell";

@interface BJPUsersViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) BJVRoom *room;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray<BJVUser *> *userList;

@end

@implementation BJPUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self addObservers];
}

#pragma mark - subviews

- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
    }];
}

#pragma mark - observers

- (void)setupObserversWithRoom:(BJVRoom *)room {
    self.room = room;
    [self addObservers];
}

- (void)addObservers {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, onlineUsers)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.playbackInfo || self.room.downloadItem.playInfo) {
                 BOOL isShowUserList = self.room.isLocalVideo ? self.room.downloadItem.playInfo.isShowUserList : self.room.playbackInfo.isShowUserList;
                 if (isShowUserList) {
                     self.userList = [self.room.onlineUsersVM.onlineUsers copy];
                     [self.tableView reloadData];
                 }
                 else {
                     return NO;
                 }
             }
             return YES;
         }];
}

#pragma mark - actions

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.count;
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJVUser *user = [self.userList bjl_objectAtIndex:indexPath.row];
    BJPUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell updateWithUser:user];
    return cell;
}

#pragma mark - getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.cellLayoutMarginsFollowReadableWidth = NO;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorInset = UIEdgeInsetsMake(0.0, BJPViewSpaceL, 0.0, 0.0);
            tableView.separatorColor = [UIColor bjp_grayLineColor];
            tableView.tableFooterView = [UIView new];
            tableView.rowHeight = 44.0;
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.allowsSelection = NO;
            [tableView registerClass:[BJPUserCell class] forCellReuseIdentifier:cellIdentifier];
            tableView;
        });
    }
    return _tableView;
}

@end
