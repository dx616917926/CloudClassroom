//
//  BJLChatQuickReplyWordsViewController.m
//  BJLiveUIBigClass
//
//  Created by HuXin on 2021/9/17.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLChatQuickReplyWordsViewController.h"
#import "BJLChatQuickReplyWordCell.h"
#import <BJLiveBase/BJLiveBase.h>
#import <BJLiveCore/BJLChatVM.h>
#import "BJLTheme.h"

static NSString *const CellReuseIdentifier = @"CellReuseIdentifier";

@interface BJLChatQuickReplyWordsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) UICollectionView *quickReplyWordsCollectionView;
@property (nonatomic) NSMutableArray *quickReplyStrings;
@property (nonatomic) NSMutableDictionary *wordsFrequency;
@end

@implementation BJLChatQuickReplyWordsViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super init];
    if (self) {
        self.room = room;
        [self makeSubviewsAndConstraints];
        self.quickReplyStrings = [NSMutableArray new];
        self.wordsFrequency = [NSMutableDictionary new];
        [self getQuickReplyWords];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self quickReplyStringsSortedByUsageFrequency];
    [self.quickReplyWordsCollectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSDictionary *dict = @{@"words": self.quickReplyStrings, @"usageFrequency": self.wordsFrequency};

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dict forKey:self.room.loginUser.number];
    [userDefaults synchronize];
}

- (void)makeSubviewsAndConstraints {
    self.quickReplyWordsCollectionView = ({
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                              collectionViewLayout:({
                                                                  UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
                                                                  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                                                                  layout.minimumLineSpacing = 20.0;
                                                                  layout.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
                                                                  layout;
                                                              })];
        collectionView.backgroundColor = BJLTheme.windowBackgroundColor;
        collectionView.alwaysBounceHorizontal = YES;
        collectionView.alwaysBounceVertical = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerClass:[BJLChatQuickReplyWordCell class]
            forCellWithReuseIdentifier:CellReuseIdentifier];
        collectionView;
    });
    [self.view addSubview:self.quickReplyWordsCollectionView];

    [self.quickReplyWordsCollectionView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Action

- (void)getQuickReplyWords {
    bjl_weakify(self);
    [self.room.chatVM getQuickReplyWordsWithCompletion:^(NSArray<NSString *> *_Nullable quickReplyWords, BJLError *_Nullable error) {
        bjl_strongify(self);
        self.quickReplyStrings = [NSMutableArray arrayWithArray:quickReplyWords];
        if (quickReplyWords.count > 0) {
            self.view.hidden = NO;
            if (quickReplyWords.count > 1) {
                [self quickReplyStringsSortedByUsageFrequency];
            }
        }
        else {
            self.view.hidden = YES;
        }
        [self.quickReplyWordsCollectionView reloadData];
    }];
}

- (void)quickReplyStringsSortedByUsageFrequency {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults dictionaryForKey:self.room.loginUser.number];
    NSArray *words = [dict bjl_arrayForKey:@"words"];
    NSDictionary *usageFrequency = [dict bjl_dictionaryForKey:@"usageFrequency"];
    if (dict == nil) {
        return;
    }

    for (NSString *word in self.quickReplyStrings) {
        if ([words containsObject:word]) {
            [self.wordsFrequency bjl_setObject:[usageFrequency bjl_objectForKey:word] forKey:word];
        }
    }
    NSArray *array = [self.quickReplyStrings sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        NSInteger count1 = [self.wordsFrequency bjl_integerForKey:obj1];
        NSInteger count2 = [self.wordsFrequency bjl_integerForKey:obj2];
        return [@(count2) compare:@(count1)];
    }];
    self.quickReplyStrings = [NSMutableArray arrayWithArray:array];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BJLChatQuickReplyWordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    NSString *replyString = [self.quickReplyStrings bjl_objectAtIndex:indexPath.row];

    [cell updateReplyWordWithString:replyString];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.quickReplyStrings.count;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectedWordCallback) {
        BJLChatQuickReplyWordCell *cell = (BJLChatQuickReplyWordCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSString *word = cell.replyWordLabel.text;
        self.didSelectedWordCallback(self, word);

        NSInteger wordSelectedCount = [self.wordsFrequency bjl_integerForKey:word] + 1;
        [self.wordsFrequency bjl_setObject:@(wordSelectedCount) forKey:word];
    }
}

// 系统计算下的快捷回复词显示错误，最后几条会显示不出来，改为手动计算
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize fontSize = [self.quickReplyStrings[indexPath.row] sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12.0]}];
    fontSize.width += 20.0;
    fontSize.height = 25.0;
    if (fontSize.width > 268.0) {
        fontSize.width = 268.0;
    }
    return fontSize;
}
@end
