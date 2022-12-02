//
//  BJLTableViewController+style.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-15.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLTableViewController+style.h"

#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJLTableViewController (style)

- (void)bjl_setUpCommonTableView {
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    self.tableView.separatorColor = BJLTheme.separateLineColor;
    self.tableView.tableFooterView = [UIView new];
}

@end

NS_ASSUME_NONNULL_END
