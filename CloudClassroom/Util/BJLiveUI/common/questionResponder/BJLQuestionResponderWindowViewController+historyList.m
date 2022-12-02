//
//  BJLQuestionResponderWindowViewController+historyList.m
//  BJLiveUI
//
//  Created by 凡义 on 2020/1/19.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLQuestionResponderWindowViewController+historyList.h"
#import "BJLQuestionResponderWindowViewController+protected.h"
#import "BJLAppearance.h"

@implementation BJLQuestionResponderWindowViewController (historyList)

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.questionResponderList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLQuestionRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BJLQuestionRecordCell class]) forIndexPath:indexPath];

    NSDictionary *dic = [self.questionResponderList bjl_objectAtIndex:indexPath.row];
    BJLUser *user = [BJLUser bjlyy_modelWithDictionary:[dic bjl_dictionaryForKey:kQuestionRecordUserKey]];
    NSUInteger count = [dic bjl_unsignedIntegerForKey:kQuestionRecordCountKey];
    BJLUserGroup *groupInfo = nil;
    for (BJLUserGroup *group in self.room.onlineUsersVM.groupList) {
        if (user.groupID == group.groupID) {
            groupInfo = group;
            break;
        }
    }

    cell.onlineUsersVM = self.room.onlineUsersVM;
    [cell updateWithIndex:indexPath.row + 1 user:user groupInfo:groupInfo participateUserCount:count];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 28.0;
}

@end
