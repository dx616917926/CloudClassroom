//
//  BJLTeachingAidSelectView.m
//  BJLiveUI
//
//  Created by 凡义 on 2020/6/4.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/NSObject+BJLObserving.h>
#import <BJLiveBase/BJL_EXTScope.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLAppearance.h"
#import "BJLTeachingAidSelectView.h"
#import "BJLUser+RollCall.h"

#define kItemWidth               50.0
#define kItemHeight              60.0
#define kItemVerticalLineSpace   12.0
#define kItemHorizontalLineSpace 8.0
#define kTeachingAidTopSpace     10.0
#define kTeachingAidBottomSpace  10.0

#pragma mark - BJLTeachingAidItem
@interface BJLTeachingAidItem: NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *normalImageName;
@property (nonatomic, copy) NSString *selectedImageName;

@property (nonatomic, assign) BOOL showBadge;
@property (nonatomic, assign) BOOL isPointBadge; //是红点的badge样式，以后可以扩展成数字
//@property (nonatomic, copy) NSString badgeString; //暂未实现，以后可以扩展

@property (nonatomic, copy) void (^eventBlock)(BOOL isSelect);

+ (instancetype)instanceWithTitle:(NSString *)title image:(NSString *)image event:(void (^)(BOOL isSelect))eventBlock;
@end

@implementation BJLTeachingAidItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.showBadge = NO;
        self.isPointBadge = YES;
    }
    return self;
}

+ (instancetype)instanceWithTitle:(NSString *)title image:(NSString *)image event:(void (^)(BOOL))eventBlock {
    BJLTeachingAidItem *item = [BJLTeachingAidItem alloc];
    item.title = title;
    item.normalImageName = image;
    item.eventBlock = eventBlock;
    return item;
}
@end

#pragma mark - BJLTeachingAidOptionCell
@interface BJLTeachingAidOptionCell ()

@property (nonatomic) UIButton *optionButton;
@property (nonatomic, nullable, copy) void (^selectCallback)(BOOL selected);

@property (nonatomic) UIImageView *icon;
@property (nonatomic) UILabel *text;
@property (nonatomic) UILabel *badgeLabel;

- (void)updateData:(BJLTeachingAidItem *)data;
@end

@implementation BJLTeachingAidOptionCell

- (void)updateData:(BJLTeachingAidItem *)data {
    if (!data) { return; }

    BJLTeachingAidItem *item = data;
    BJLTeachingAidOptionCell *cell = self;
    cell.text.text = item.title;
    [cell.icon setImage:[UIImage bjl_imageNamed:item.normalImageName]];
    self.badgeLabel.hidden = !data.showBadge;

    bjl_weakify(item);
    [cell setSelectCallback:^(BOOL selected) {
        bjl_strongify(item);
        if (item.eventBlock) {
            item.eventBlock(selected);
        }
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - subviews

- (void)setupSubviews {
    self.icon = ({
        UIImageView *view = [UIImageView new];
        view.contentMode = UIViewContentModeScaleAspectFit;
        view;
    });
    self.text = ({
        UILabel *label = [UILabel new];
        label.textColor = BJLTheme.toolButtonTitleColor;
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });

    self.optionButton = ({
        UIButton *button = [[UIButton alloc] init];

        bjl_weakify(self);
        [button bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.selectCallback) {
                self.selectCallback(!button.selected);
            }
        }];
        button;
    });
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.text];
    [self.contentView addSubview:self.badgeLabel];
    [self.icon bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.height.width.equalTo(@(40));
        make.top.centerX.equalTo(self.contentView);
    }];
    [self.text bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.equalTo(self.icon.bjl_bottom).offset(4);
        make.bottom.centerX.equalTo(self.contentView);
        make.left.greaterThanOrEqualTo(self.contentView);
        make.right.lessThanOrEqualTo(self.contentView);
    }];
    [self.badgeLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerX.equalTo(self.icon.bjl_right).offset(-7);
        make.centerY.equalTo(self.icon.bjl_top).offset(6);
        make.width.height.equalTo(@5.0);
    }];
    [self.contentView addSubview:self.optionButton];
    [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.text = @"";
        _badgeLabel.font = [UIFont systemFontOfSize:14];
        _badgeLabel.textColor = BJLTheme.brandColor;
        _badgeLabel.backgroundColor = BJLTheme.brandColor;
        _badgeLabel.clipsToBounds = YES;
        _badgeLabel.layer.cornerRadius = 2.5;
        _badgeLabel.hidden = YES;
    }
    return _badgeLabel;
}
@end

#pragma mark - BJLTeachingAidSelectView

@interface BJLTeachingAidSelectView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) UICollectionView *teachingAidCollectionView;
@property (nonatomic) NSArray<BJLTeachingAidItem *> *teachingAidItems;
@property (nonatomic, weak) BJLTeachingAidItem *rollCallItem;
@property (nonatomic, assign) BOOL needReloadOptions;
@property (nonatomic) BOOL fullScreenWidth;
@end

@implementation BJLTeachingAidSelectView
- (instancetype)initWithRoom:(BJLRoom *)room fullScreenWidth:(BOOL)fullScreenWidth {
    self.fullScreenWidth = fullScreenWidth;
    self = [super initWithRoom:room];
    if (self) {
        self.teachingAidItems = [self buildTeachingAidItems];
        // 这里需要处理大班课双师切换直播间导致助教权限变更的问题
        if (self.room.roomInfo.roomType == BJLRoomType_1vNClass
            && self.room.loginUser.isTeacherOrAssistant) {
            [self addObserverForSwitchRoom];
        }
    }
    return self;
}

- (NSArray<BJLTeachingAidItem *> *)buildTeachingAidItems {
    bjl_weakify(self);

    BJLTeachingAidItem *openWebView =
        [BJLTeachingAidItem instanceWithTitle:BJLLocalizedString(@"打开网页")
                                        image:@"bjl_toolbox_openweb_normal"
                                        event:^(BOOL isSelect) {
                                            bjl_strongify(self);
                                            if (self.openWebViewCallback) {
                                                self.openWebViewCallback();
                                            }
                                        }];

    BJLTeachingAidItem *countDownTimer =
        [BJLTeachingAidItem instanceWithTitle:BJLLocalizedString(@"计时器")
                                        image:@"bjl_toolbox_countdown_normal"
                                        event:^(BOOL isSelect) {
                                            bjl_strongify(self);
                                            if (self.countDownCallback) {
                                                self.countDownCallback();
                                            }
                                        }];

    BJLTeachingAidItem *writingBoard =
        [BJLTeachingAidItem instanceWithTitle:BJLLocalizedString(@"小黑板")
                                        image:@"bjl_toolbox_writingboard_normal"
                                        event:^(BOOL isSelect) {
                                            bjl_strongify(self);
                                            if (self.clickWritingBoardCallback) {
                                                self.clickWritingBoardCallback();
                                            }
                                        }];

    BJLTeachingAidItem *questionAnswer =
        [BJLTeachingAidItem instanceWithTitle:BJLLocalizedString(@"答题器")
                                        image:@"bjl_toolbox_questionanswer_normal"
                                        event:^(BOOL isSelect) {
                                            bjl_strongify(self);
                                            if (self.questionAnswerCallback) {
                                                self.questionAnswerCallback();
                                            }
                                        }];

    BJLTeachingAidItem *questionResponder =
        [BJLTeachingAidItem instanceWithTitle:BJLLocalizedString(@"抢答器")
                                        image:@"bjl_toolbox_questionresponder_normal"
                                        event:^(BOOL isSelect) {
                                            bjl_strongify(self);
                                            if (self.questionResponderCallback) {
                                                self.questionResponderCallback();
                                            }
                                        }];

    BJLTeachingAidItem *rollCall =
        [BJLTeachingAidItem instanceWithTitle:BJLLocalizedString(@"点名")
                                        image:@"bjl_toolbox_rollcall_normal"
                                        event:^(BOOL isSelect) {
                                            bjl_strongify(self);
                                            if (self.rollCallCallback) {
                                                self.rollCallCallback();
                                            }
                                        }];
    self.rollCallItem = rollCall;
    BJLTeachingAidItem *lottery =
        [BJLTeachingAidItem instanceWithTitle:BJLLocalizedString(@"红包雨")
                                        image:@"bjl_toolbox_lottery_normal"
                                        event:^(BOOL isSelect) {
                                            bjl_strongify(self);
                                            if (self.envelopeRainCallback) {
                                                self.envelopeRainCallback();
                                            }
                                        }];

    NSArray *tools = @[];
    if (self.room.roomInfo.roomType == BJLRoomType_interactiveClass) {
        if (self.room.loginUser.isTeacher) {
            if (BJLIcTemplateType_1v1 == self.room.roomInfo.interactiveClassTemplateType) {
                tools = @[
                    openWebView, //打开网页
                    countDownTimer //计时器
                ];
            }
            else {
                tools = @[
                    openWebView, //打开网页
                    writingBoard, //小黑板
                    questionAnswer, //答题器
                    questionResponder, //抢答器
                    countDownTimer, //计时器
                    rollCall //点名
                    //lottery              //红包雨，小班课目前红包雨只需要学生能抢红包
                ];
            }
        }
        else if (self.room.loginUser.isAssistant) {
            if (BJLIcTemplateType_1v1 == self.room.roomInfo.interactiveClassTemplateType) {
                tools = @[
                    openWebView, //打开网页
                    countDownTimer //计时器
                ];
            }
            else {
                tools = @[
                    openWebView, //打开网页
                    questionAnswer, //答题器
                    questionResponder, //抢答器
                    countDownTimer, //计时器
                    rollCall //点名
                ];
            }
        }

        NSMutableArray *toolsEnableByConfig = [tools mutableCopy];
        if (!self.room.featureConfig.enableUseWebpage) {
            [toolsEnableByConfig removeObject:openWebView];
        }
        if (!self.room.featureConfig.enableUseSnippet) {
            [toolsEnableByConfig removeObject:writingBoard];
        }
        if (!self.room.featureConfig.enableUseAnswer) {
            [toolsEnableByConfig removeObject:questionAnswer];
        }
        if (!self.room.featureConfig.enableUseRaceAnswer) {
            [toolsEnableByConfig removeObject:questionResponder];
        }
        if (!self.room.featureConfig.enableUseTimer) {
            [toolsEnableByConfig removeObject:countDownTimer];
        }
        if (!self.room.featureConfig.enableSignIn) {
            [toolsEnableByConfig removeObject:rollCall];
        }

        tools = toolsEnableByConfig ?: @[];
    }
    else {
        NSMutableArray *toolsEnableByConfig = [tools mutableCopy];
        if (self.room.loginUser.isTeacherOrAssistant) {
            if (self.room.roomInfo.roomType == BJLRoomType_1v1Class) {
                [toolsEnableByConfig addObjectsFromArray:@[countDownTimer]];
            }
            else {
                NSArray *assArr = @[questionAnswer, rollCall, questionResponder];
                NSArray *teaArr = @[countDownTimer, questionAnswer, lottery, rollCall, questionResponder];

                if (self.room.loginUser.isTeacher) {
                    [toolsEnableByConfig addObjectsFromArray:teaArr];
                }
                else {
                    [toolsEnableByConfig addObjectsFromArray:assArr];
                }
            }

            BOOL needRollCall = [self.room.loginUser canLaunchRollCallWithRoom:self.room];
            if (!needRollCall) {
                [toolsEnableByConfig removeObject:rollCall];
            }

            if (self.room.roomInfo.roomType == BJLRoomType_1vNClass) {
                if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_group
                    || self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_onlinedoubleTeachers) {
                    if (self.room.loginUser.groupID != 0) {
                        [toolsEnableByConfig removeObject:questionAnswer];
                        [toolsEnableByConfig removeObject:questionResponder];
                    }
                }
            }
        }

        if (!self.room.featureConfig.enableUseRaceAnswer) {
            [toolsEnableByConfig removeObject:questionResponder];
        }
        tools = toolsEnableByConfig ?: @[];
    }

    return tools;
}

- (void)dealloc {
    self.teachingAidCollectionView.dataSource = nil;
    self.teachingAidCollectionView.delegate = nil;
}

- (CGSize)intrinsicContentSize {
    NSInteger line = self.teachingAidItems.count > 2 ? 2 : 1;
    NSInteger column = ceil((CGFloat)self.teachingAidItems.count / (CGFloat)line);
    CGFloat w = kItemWidth * column + kItemHorizontalLineSpace * (MAX(0, column - 1) + 2);
    CGFloat h = kItemHeight * line + MAX(0, line - 1) * kItemVerticalLineSpace + kTeachingAidTopSpace + kTeachingAidBottomSpace;
    return CGSizeMake(w, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.containerView bjl_drawRectCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(BJLAppearance.toolboxCornerRadius, BJLAppearance.toolboxCornerRadius)];
}

- (void)showRollCallBadge:(BOOL)show {
    self.rollCallItem.showBadge = show;
    [self.teachingAidCollectionView reloadData];
    if (self.badgeStateDidChangeCallback) {
        self.badgeStateDidChangeCallback(self);
    }
}

- (BOOL)rollCallBadgeDidShown {
    return self.rollCallItem.showBadge;
}

- (void)setupSubviews {
    [super setupSubviews];

    self.teachingAidCollectionView = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = self.fullScreenWidth ? 30.0 : kItemHorizontalLineSpace;
        layout.minimumLineSpacing = kItemVerticalLineSpace;
        layout.sectionInset = UIEdgeInsetsMake(self.fullScreenWidth ? 20.0 : kTeachingAidTopSpace, self.fullScreenWidth ? 30.0 : 0.0, kTeachingAidBottomSpace, self.fullScreenWidth ? 30.0 : 0.0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);

        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.bounces = YES;
        collectionView.alwaysBounceVertical = YES;
        collectionView.pagingEnabled = NO;
        collectionView.scrollEnabled = NO;
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [collectionView registerClass:[BJLTeachingAidOptionCell class] forCellWithReuseIdentifier:NSStringFromClass([BJLTeachingAidOptionCell class])];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        bjl_return collectionView;
    });
    [self addSubview:self.teachingAidCollectionView];
    [self.teachingAidCollectionView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)).priorityHigh();
    }];
}

#pragma mark - observer
- (void)addObserverForSwitchRoom {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, switchingRoom)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);

             if (self.room.switchingRoom) {
                 [self removeFromSuperview];
                 self.needReloadOptions = YES;
             }
             else if (self.needReloadOptions) {
                 self.teachingAidItems = [self buildTeachingAidItems];
                 [self.teachingAidCollectionView reloadData];
                 [self invalidateIntrinsicContentSize];
                 self.needReloadOptions = NO;
             }

             return YES;
         }];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.teachingAidItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BJLTeachingAidOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BJLTeachingAidOptionCell class]) forIndexPath:indexPath];
    BJLTeachingAidItem *item = [self.teachingAidItems bjl_objectAtIndex:indexPath.row];
    [cell updateData:item];
    return cell;
}
@end
