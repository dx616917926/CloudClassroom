//
//  BJLIcPromptViewController.m
//  BJLiveUI-BJLInteractiveClass
//
//  Created by xijia dai on 2018/11/7.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLPromptViewController.h"
#import "BJLPromptTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPromptVCDefaultAppearance: NSObject <BJLPromptVCAppearance>
@property (nonatomic) CGFloat promptCellHeiht;
@property (nonatomic) CGFloat promptCellSmallSpace;
@property (nonatomic) CGFloat promptCellLargeSpace;
@property (nonatomic) NSInteger promptDuration;
@property (nonatomic) NSInteger promptCellMaxCount;
@property (nonatomic) CGFloat promptViewHeight;
@end

@interface BJLPromptViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSMutableArray<BJLPromptCellModel *> *prompts;
@property (nonatomic, nullable) BJLPromptCellModel *specialPrompt;
@property (nonatomic, strong) id<BJLPromptVCAppearance> appearance;
@end

@implementation BJLPromptViewController
+ (id<BJLPromptVCAppearance>)defaultAppearance {
    return BJLPromptVCDefaultAppearance.new;
}

- (instancetype)initWithAppearance:(id<BJLPromptVCAppearance>)appearance {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.prompts = [NSMutableArray new];
        self.appearance = appearance;
    }
    return self;
}

- (instancetype)init {
    self = [self initWithAppearance:self.class.defaultAppearance];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [BJLHitTestView viewWithHitTestBlock:^UIView *_Nullable(UIView *_Nullable hitView, CGPoint point, UIEvent *_Nullable event) {
        if ([hitView isKindOfClass:[UIButton class]]) {
            return hitView;
        }
        return nil;
    }];
    [self makeSubviewsAndConstraints];
}

- (void)makeSubviewsAndConstraints {
    // table view
    [self.tableView removeFromSuperview];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = [self.appearance promptCellHeiht];
    [self.tableView registerClass:[BJLPromptTableViewCell class] forCellReuseIdentifier:kIcPromptTableViewCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.view).offset([self.appearance promptCellLargeSpace]);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - actions

- (void)enqueueWithPrompt:(NSString *)prompt {
    [self enqueueWithPrompt:prompt duration:[self.appearance promptDuration]];
}

- (void)enqueueWithPrompt:(NSString *)prompt duration:(NSInteger)duration {
    [self enqueueWithPrompt:prompt duration:duration important:NO];
}

- (void)enqueueWithPrompt:(NSString *)prompt duration:(NSInteger)duration important:(BOOL)important {
    while (self.prompts.count >= [self.appearance promptCellMaxCount]) {
        [self.prompts bjl_removeObjectAtIndex:[self.appearance promptCellMaxCount] - 1];
    }
    // 入队新消息的时候，如果队列中存在显示时长无限的消息，移除掉这条消息
    for (BJLPromptCellModel *model in self.prompts.copy) {
        if (model.maxDuration <= 0) {
            [self.prompts removeObject:model];
        }
    }
    BJLPromptCellModel *model = [[BJLPromptCellModel alloc] initWithPrompt:prompt duration:duration important:important];
    [self.prompts bjl_insertObject:model atIndex:0];
    [self reloadTableView];
}

- (void)enqueueWithSpecialPrompt:(NSString *)prompt duration:(NSInteger)duration important:(BOOL)important {
    if (prompt.length <= 0) {
        self.specialPrompt = nil;
    }
    else {
        self.specialPrompt = [[BJLPromptCellModel alloc] initWithPrompt:prompt duration:duration important:important];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIcPromptTableViewCellReuseIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        BJLPromptCellModel *model = [self.prompts bjl_objectAtIndex:indexPath.row];
        [bjl_as(cell, BJLPromptTableViewCell) updateWithPromptModel:model];
        [(BJLPromptTableViewCell *)cell setupAppearance:self.appearance];
    }
    else {
        [bjl_as(cell, BJLPromptTableViewCell) updateWithSpecialPromptModel:self.specialPrompt];
        [(BJLPromptTableViewCell *)cell setupAppearance:self.appearance];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -

- (void)reloadTableView {
    if (self.tableView) {
        bjl_dispatch_on_main_queue(^{
            [self.tableView reloadData];
        });
    }
}

@end

@implementation BJLPromptVCDefaultAppearance
- (instancetype)init {
    self = [super init];
    if (self) {
        self.promptCellHeiht = 42;
        self.promptCellSmallSpace = 6;
        self.promptCellLargeSpace = 12;
        self.promptDuration = 3;
        self.promptCellMaxCount = 3;
        self.promptViewHeight = 138;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
