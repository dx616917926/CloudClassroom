//
//  BJPCatalogueViewController.m
//  BJPlaybackUI
//
//  Created by 凡义 on 2021/1/14.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJPCatalogueViewController.h"
#import "BJPCatalogueCell.h"
#import "BJPCatalogueHeaderCell.h"
#import "BJPAppearance.h"

static NSString *const cellIdentifier = @"catalogueCell";
static NSString *const longCellIdentifier = @"longCatalogueCell";
static NSString *const headerCellIdentifier = @"headerCellIdentifier";

@interface BJPCatalogueViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) BJVRoom *room;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, nullable) NSArray<BJPDocumentCatalogueModel *> *documentCatalogueList;
@property (nonatomic, nullable) BJPPPTCatalogueModel *currentSelectedCatalogue;
@property (nonatomic) NSIndexPath *lastIndexPath;

@end

@implementation BJPCatalogueViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentSelectedCatalogue = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor bjl_colorWithHex:0X323848 alpha:0.9];
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
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, documentCatalogueList)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             if (self.room.playbackInfo || self.room.downloadItem.playInfo) {
                 BOOL isShowList = [self.room.roomVM.documentCatalogueList count];
                 if (isShowList) {
                     self.documentCatalogueList = [self.room.roomVM.documentCatalogueList copy];
                     [self.tableView reloadData];
                 }
                 else {
                     return NO;
                 }
             }
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, lastPageChangeSignal)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);

             BOOL changeCatalogue = NO;
             BJPPageChangeModel *lastPageChangeSignal = self.room.roomVM.lastPageChangeSignal;

             if (!lastPageChangeSignal) {
                 return YES;
             }

             NSTimeInterval pageChangeSignaltms = lastPageChangeSignal.msOffsetTimestamp;
             NSString *docID = lastPageChangeSignal.documentID;

             for (BJPDocumentCatalogueModel *documentCatalogue in self.documentCatalogueList) {
                 if ([documentCatalogue.document.documentID isEqual:docID]) {
                     for (BJPPPTCatalogueModel *model in documentCatalogue.catalogueList) {
                         // 这里判断条件不加入pageIndex的比较,是因为不同的页码之前间隔不超过1s的翻页是无效的, 所以这里不强制加入pageIndex,可是能上一页或者下一页,但是msOffsetTimestamp在1s之内
                         if (self.currentSelectedCatalogue != model
                             && fabs(model.msOffsetTimestamp - pageChangeSignaltms) <= 1000) {
                             self.currentSelectedCatalogue = model;
                             changeCatalogue = YES;
                             break;
                         }
                     }
                 }
             }

             if (changeCatalogue) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //通知主线程刷新
                     [self.tableView reloadData];
                 });
             }

             return YES;
         }];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.documentCatalogueList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BJPDocumentCatalogueModel *documentCatalogueModel = [self.documentCatalogueList bjl_objectAtIndex:section];
    return [documentCatalogueModel.catalogueList count] + 1;
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJPDocumentCatalogueModel *documentCatalogueModel = [self.documentCatalogueList bjl_objectAtIndex:indexPath.section];
    NSArray<BJPPPTCatalogueModel *> *catalogueList = documentCatalogueModel.catalogueList;

    // 第一个cell总是ppt的名字
    if (indexPath.row == 0) {
        BJPCatalogueHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:headerCellIdentifier forIndexPath:indexPath];
        [cell updateCellWithModel:documentCatalogueModel.document];
        return cell;
    }

    BJPPPTCatalogueModel *catalogue = [catalogueList bjl_objectAtIndex:(indexPath.row - 1)];
    NSString *urlString = [documentCatalogueModel.document.fileID isEqualToString:@"0"] ? nil : [documentCatalogueModel.document.pageInfo pageURLStringWithPageIndex:catalogue.pageIndex];
    BJPCatalogueCell *cell = [tableView dequeueReusableCellWithIdentifier:urlString ? longCellIdentifier : cellIdentifier forIndexPath:indexPath];
    [cell updateCellWithModel:catalogue pptUrl:urlString playing:(catalogue == self.currentSelectedCatalogue && self.currentSelectedCatalogue)];
    bjl_weakify(self);
    [cell setClickCallback:^{
        bjl_strongify(self);
        BJPDocumentCatalogueModel *documentCatalogueModel = [self.documentCatalogueList bjl_objectAtIndex:indexPath.section];
        NSArray<BJPPPTCatalogueModel *> *catalogueList = documentCatalogueModel.catalogueList;
        BJPPPTCatalogueModel *catalogue = [catalogueList bjl_objectAtIndex:(indexPath.row - 1)];
        self.currentSelectedCatalogue = catalogue;
        [self.tableView reloadData];

        if (self.updateCatalogueProgressCallback) {
            self.updateCatalogueProgressCallback(catalogue);
        }
    }];
    return cell;
}

#pragma mark - getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.cellLayoutMarginsFollowReadableWidth = NO;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.tableFooterView = [UIView new];
            tableView.showsVerticalScrollIndicator = NO;
            tableView.showsHorizontalScrollIndicator = NO;
            tableView.bounces = NO;
            tableView.estimatedRowHeight = 46.0;
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[BJPCatalogueCell class] forCellReuseIdentifier:cellIdentifier];
            [tableView registerClass:[BJPCatalogueCell class] forCellReuseIdentifier:longCellIdentifier];
            [tableView registerClass:[BJPCatalogueHeaderCell class] forCellReuseIdentifier:headerCellIdentifier];
            tableView;
        });
    }
    return _tableView;
}

@end
