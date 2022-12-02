//
//  BJLChatPanelViewController.m
//  BJLiveUI
//
//  Created by 凡义 on 2021/4/6.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLChatPanelViewController.h"
#import "BJLChatPanelTableViewCell.h"
#import "BJLAppearance.h"

@interface BJLChatPanelViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray<BJLChatPanelModel *> *prompts;
@property (nonatomic, nullable) BJLChatPanelModel *specialPrompt;
@property (nonatomic) BJLRoomType roomType;

@end

@implementation BJLChatPanelViewController

- (instancetype)initWithRoomType:(BJLRoomType)roomType {
    if (self = [super init]) {
        self.prompts = [NSMutableArray new];
        self.roomType = roomType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [BJLHitTestView viewWithHitTestBlock:^UIView *_Nullable(UIView *_Nullable hitView, CGPoint point, UIEvent *_Nullable event) {
        UITableViewCell *cell = [hitView bjl_closestViewOfClass:[UITableViewCell class] includeSelf:NO];
        if (cell && hitView != cell.contentView) {
            return hitView;
        }
        return nil;
    }];
    [self makeSubviewsAndConstraints];
}

- (void)makeSubviewsAndConstraints {
    // table view
    [self.tableView removeFromSuperview];
    self.tableView.transform = CGAffineTransformMakeScale(1, -1);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[BJLChatPanelTableViewCell class] forCellReuseIdentifier:kChatPanelTableViewCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.view).offset(BJLAppearance.promptCellLargeSpace);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - actions

- (void)revokeMessageWithMessageID:(NSString *)messageID {
    for (BJLChatPanelModel *prompt in self.prompts.copy) {
        if ([prompt.message.ID isEqualToString:messageID]) {
            [self.prompts removeObject:prompt];
            break;
        }
    }
    [self reloadTableView];
}

- (void)enqueueWithNewMessage:(BJLMessage *)newMessage {
    BOOL exit = NO;
    for (BJLChatPanelModel *prompt in self.prompts.copy) {
        if ([prompt.message.ID isEqualToString:newMessage.ID]) {
            exit = YES;
            break;
        }
    }

    if (!exit) {
        [self enqueueWithMessage:newMessage duration:BJLAppearance.chatPromptDuration important:NO];
    }
}

- (void)enqueueWithNewMessage:(BJLMessage *)newMessage duration:(NSInteger)duration {
    BOOL exit = NO;
    for (BJLChatPanelModel *prompt in self.prompts.copy) {
        if ([prompt.message.ID isEqualToString:newMessage.ID]) {
            exit = YES;
            break;
        }
    }

    if (!exit) {
        [self enqueueWithMessage:newMessage duration:duration important:NO];
    }
}

- (void)enqueueWithMessage:(BJLMessage *)message duration:(NSInteger)duration important:(BOOL)important {
    while (self.prompts.count >= BJLAppearance.chatPromptCellMaxCount) {
        [self.prompts bjl_removeObjectAtIndex:BJLAppearance.chatPromptCellMaxCount - 1];
    }
    // 入队新消息的时候，如果队列中存在显示时长无限的消息，移除掉这条消息
    for (BJLChatPanelModel *model in self.prompts.copy) {
        if (model.maxDuration <= 0) {
            [self.prompts removeObject:model];
        }
    }
    BJLChatPanelModel *model = [[BJLChatPanelModel alloc] initWithMessage:message duration:duration important:important];
    [self.prompts bjl_insertObject:model atIndex:0];
    [self reloadTableView];
}

- (void)enqueueWithSpecialPromptMessage:(BJLMessage *)message duration:(NSInteger)duration important:(BOOL)important {
    if (message.text <= 0) {
        self.specialPrompt = nil;
    }
    else {
        self.specialPrompt = [[BJLChatPanelModel alloc] initWithMessage:message duration:duration important:important];
    }
    [self reloadTableView];
}

- (void)clearDatasource {
    [self.prompts removeAllObjects];
    [self reloadTableView];
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = (self.specialPrompt && !self.specialPrompt.reachMaxDuration) ? 1 : 0;
            break;

        case 1:
            count = self.prompts.count;
            break;

        default:
            count = 0;
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kChatPanelTableViewCellReuseIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.transform = CGAffineTransformMakeScale(1, -1);
    if (indexPath.section == 1) {
        BJLChatPanelModel *model = [self.prompts bjl_objectAtIndex:indexPath.row];
        [bjl_as(cell, BJLChatPanelTableViewCell) updateWithMessagePanelModel:model roomType:self.roomType];
    }
    else {
        [bjl_as(cell, BJLChatPanelTableViewCell) updateWithMessagePanelModel:self.specialPrompt roomType:self.roomType];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.clickCellCallback) {
        self.clickCellCallback();
    }
    [self clearDatasource];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLChatPanelModel *model = self.specialPrompt;
    if (indexPath.section == 1) {
        model = [self.prompts bjl_objectAtIndex:indexPath.row];
    }

    NSString *key = [self keyWithIndexPath:indexPath message:model.message];
    if (model.message) {
        NSString *identifier = kChatPanelTableViewCellReuseIdentifier;
        bjl_weakify(self);
        CGFloat height = [tableView bjl_cellHeightWithKey:key identifier:identifier configuration:^(BJLChatPanelTableViewCell *cell) {
            bjl_strongify(self);
            cell.bjl_autoSizing = YES;
            BJLChatPanelModel *model = self.specialPrompt;
            if (indexPath.section == 1) {
                model = [self.prompts bjl_objectAtIndex:indexPath.row];
            }
            [cell updateWithMessagePanelModel:model roomType:self.roomType];
        }];
        return height;
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - private

- (NSString *)keyWithIndexPath:(NSIndexPath *)indexPath message:(BJLMessage *)message {
    return [NSString stringWithFormat:@"%@-%@-%f", message.ID, message.fromUser.ID, message.timeInterval];
}

- (void)reloadTableView {
    if (self.tableView) {
        bjl_dispatch_on_main_queue(^{
            [self.tableView reloadData];
        });
    }
}

@end
