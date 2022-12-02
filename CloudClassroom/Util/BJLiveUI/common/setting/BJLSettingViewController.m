//
//  BJLSettingViewController.m
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/10/15.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLSettingViewController.h"
#import "BJLAppearance.h"
#import "BJLSettingCell.h"
#import "BJLViewControllerImports.h"

static NSString *const cellIdentifier = @"kSettingsCellIdentifier";
NSString *const BJLSettingMenuOptionKey_camera = @"camera";
NSString *const BJLSettingMenuOptionKey_mic = @"mic";
NSString *const BJLSettingMenuOptionKey_roomcontrol = @"roomcontrol";
NSString *const BJLSettingMenuOptionKey_ppt = @"ppt";
NSString *const BJLSettingMenuOptionKey_beauty = @"beauty";
NSString *const BJLSettingMenuOptionKey_other = @"other";
NSString *const BJLSettingMenuOptionKey_debug = @"debug";

NSString *const BJLSettingMenuOptionKeyString = @"key";
NSString *const BJLSettingMenuOptionNameString = @"value";

@interface BJLSettingViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UIView *topContainerView, *bottomContainerView;
@property (nonatomic) UICollectionView *leftCollectionView;
@property (nonatomic) UILabel *titleLabel, *roomInfoLabel;
@property (nonatomic) UIButton *roomInfoButton;
@property (nonatomic) NSInteger currentSettingIndex; // 当前是选择的哪一栏设置,对应leftContainerViewDataSource

@end

@implementation BJLSettingViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
        self.currentSettingIndex = 0;
    }
    return self;
}

- (instancetype)initWithRoom:(BJLRoom *)room
              leftDataSource:(NSArray<NSDictionary *> *)leftDataSource
             rightDataSource:(NSDictionary<NSString *, NSArray<__kindof UIView *> *> *)rightDataSource {
    self = [super init];
    if (self) {
        self->_room = room;
        self.currentSettingIndex = 0;
        self.leftContainerViewDataSource = leftDataSource;
        self.rightDataSource = rightDataSource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.accessibilityIdentifier = NSStringFromClass(self.class);
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    self.view.layer.cornerRadius = 4;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = UIColor.blackColor.CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowOpacity = 0.2;
    self.view.layer.shadowRadius = 2;

    self.scrollView.alwaysBounceVertical = YES;
    [self makeSubviewsAndConstraints];
}

- (void)makeSubviewsAndConstraints {
#pragma mark - top

    self.topContainerView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, topContainerView);
        [self.view addSubview:view];
        bjl_return view;
    });

    UIView *separatorLine = ({
        UIView *line = [UIView new];
        line.backgroundColor = BJLTheme.separateLineColor;
        [self.topContainerView addSubview:line];
        bjl_return line;
    });

    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = BJLLocalizedString(@"设置");
        label.textColor = BJLTheme.viewTextColor;
        label.accessibilityIdentifier = BJLKeypath(self, titleLabel);
        [self.topContainerView addSubview:label];
        bjl_return label;
    });

    UIButton *closeButton = ({
        UIButton *closeButton = [UIButton new];
        [closeButton bjl_setImage:[UIImage bjl_imageNamed:@"window_close_gray"] forState:UIControlStateNormal possibleStates:UIControlStateHighlighted];
        [self.topContainerView addSubview:closeButton];
        bjl_return closeButton;
    });

    bjl_weakify(self);
    [closeButton bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self) if (self.closeCallback) {
            self.closeCallback();
        }
    }];

    [self.topContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(30));
    }];

    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.horizontal.compressionResistance.required();
        make.left.equalTo(self.topContainerView).with.inset(15.0);
        make.top.bottom.equalTo(self.topContainerView);
    }];

    [closeButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.centerY.equalTo(self.topContainerView);
        make.right.equalTo(self.topContainerView).offset(-5);
    }];

    [separatorLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.bottom.left.right.equalTo(self.topContainerView);
        make.height.equalTo(@(BJLScOnePixel));
    }];

#pragma mark - left

    self.leftCollectionView = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        layout.itemSize = CGSizeMake(96, 28);
        layout.sectionInset = UIEdgeInsetsMake(12, 0, 0, 0);

        UICollectionView *collectioinView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectioinView.backgroundColor = [UIColor bjl_colorWithHex:0X9FA8B5 alpha:0.1];
        collectioinView.delegate = self;
        collectioinView.dataSource = self;
        collectioinView.showsVerticalScrollIndicator = NO;
        [collectioinView registerClass:[BJLSettingCell class] forCellWithReuseIdentifier:cellIdentifier];
        [self.view addSubview:collectioinView];
        bjl_return collectioinView;
    });

    [self.leftCollectionView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.bottom.equalTo(self.view);
        make.width.equalTo(@(120));
        make.top.equalTo(self.topContainerView.bjl_bottom);
    }];

#pragma mark - bottom

    self.bottomContainerView = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = BJLKeypath(self, bottomContainerView);
        [self.view addSubview:view];
        bjl_return view;
    });

    [self.bottomContainerView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.leftCollectionView.bjl_right);
        make.bottom.right.equalTo(self.view);
        make.height.equalTo(@(32));
    }];

    UIView *bottomSeparatorLine = ({
        UIView *line = [UIView new];
        line.backgroundColor = BJLTheme.separateLineColor;
        [self.bottomContainerView addSubview:line];
        bjl_return line;
    });

    [bottomSeparatorLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.bottomContainerView);
        make.height.equalTo(@(BJLScOnePixel));
    }];

    UIView *view = [UIView new];
    view.accessibilityIdentifier = @"view";
    [self.bottomContainerView addSubview:view];
    [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.center.height.equalTo(self.bottomContainerView);
        make.left.greaterThanOrEqualTo(self.bottomContainerView);
        make.right.lessThanOrEqualTo(self.bottomContainerView);
    }];

    self.roomInfoLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = BJLTheme.viewTextColor;
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:12];
        label.text = [NSString stringWithFormat:BJLLocalizedString(@"课程ID: %@"), self.room.roomInfo.ID];
        label.accessibilityIdentifier = BJLKeypath(self, roomInfoLabel);
        [view addSubview:label];
        bjl_return label;
    });

    self.roomInfoButton = ({
        UIButton *button = [UIButton new];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:BJLLocalizedString(@"点击复制") attributes:@{NSForegroundColorAttributeName: BJLTheme.brandColor,
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]}];
        [button setAttributedTitle:string forState:UIControlStateNormal];
        button.accessibilityIdentifier = BJLKeypath(self, roomInfoButton);
        [view addSubview:button];
        bjl_return button;
    });
    [self.roomInfoLabel bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.height.bottom.equalTo(view);
        make.right.equalTo(self.roomInfoButton.bjl_left).offset(-5);
    }];
    [self.roomInfoButton bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.right.height.bottom.equalTo(view);
    }];

    [self bjl_kvo:BJLMakeProperty(self.room, roomInfo) observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
        bjl_strongify(self);
        self.roomInfoLabel.text = [NSString stringWithFormat:BJLLocalizedString(@"课程ID：%@"), self.room.roomInfo.ID];
        return YES;
    }];
    [self.roomInfoButton bjl_addHandler:^(UIButton *_Nonnull button) {
        bjl_strongify(self);
        UIPasteboard.generalPasteboard.string = self.roomInfoLabel.text;
        [self showProgressHUDWithText:BJLLocalizedString(@"复制成功")];
    }];

    [self.scrollView bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.equalTo(self.leftCollectionView.bjl_right);
        make.right.equalTo(self.view);
        make.top.equalTo(self.topContainerView.bjl_bottom);
        make.bottom.equalTo(self.bottomContainerView.bjl_top).offset(-20);
    }];
}

#pragma mark -

- (void)clearOptionsView {
    [self.rightDataSource enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSArray *_Nonnull obj, BOOL *_Nonnull stop) {
        for (UIView *view in obj) {
            if ([view respondsToSelector:@selector(removeFromSuperview)]) {
                [view removeFromSuperview];
            }
        }
    }];
}

- (void)upadteCurrentOptionViews {
    NSString *key = [[self.leftContainerViewDataSource bjl_objectAtIndex:self.currentSettingIndex] bjl_stringForKey:BJLSettingMenuOptionKeyString];
    NSArray<__kindof UIView *> *options = [self.rightDataSource bjl_arrayForKey:key];

    [self clearOptionsView];

    CGFloat verticalMargin = 16.0;
    CGFloat leftHorizontalMargin = 20.0;
    CGFloat rightHorizontalMargin = 30.0;
    CGFloat viewHeight = 28.0;

    if ([key isEqualToString:BJLSettingMenuOptionKey_beauty]) {
        viewHeight = 48.0;
    }

    UIView *preView = nil;
    UIView *lastView = options.lastObject;

    for (UIView *view in options) {
        [self.scrollView addSubview:view];
        [view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            if (preView) {
                make.top.equalTo(preView.bjl_bottom).offset(verticalMargin);
                make.size.centerX.equalTo(preView);
            }
            else {
                make.left.equalTo(self.leftCollectionView.bjl_right).offset(leftHorizontalMargin);
                make.top.equalTo(self.scrollView).offset(verticalMargin);
                make.right.equalTo(self.view).offset(-rightHorizontalMargin);
                make.height.equalTo(@(viewHeight));
            }

            if (lastView == view) {
                make.bottom.equalTo(self.scrollView).offset(-verticalMargin);
            }
        }];
        preView = view;
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentSettingIndex == indexPath.row) {
        return;
    }

    // 取消之前的选择状态
    BJLSettingCell *preSelectCell = bjl_as([self.leftCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentSettingIndex inSection:0]], BJLSettingCell);
    NSString *preSelectTitle = [self getleftViewTitleWithIndex:self.currentSettingIndex];
    [preSelectCell updateContentWithTitle:preSelectTitle selectd:NO];

    self.currentSettingIndex = indexPath.row;
    BJLSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *title = [self getleftViewTitleWithIndex:indexPath.row];
    [cell updateContentWithTitle:title selectd:(self.currentSettingIndex == indexPath.row)];

    // 更新左侧操作界面
    [self upadteCurrentOptionViews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.leftContainerViewDataSource count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BJLSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *title = [self getleftViewTitleWithIndex:indexPath.row];
    [cell updateContentWithTitle:title selectd:(self.currentSettingIndex == indexPath.row)];
    return cell;
}

- (NSString *)getleftViewTitleWithIndex:(NSInteger)index {
    NSDictionary *dic = [self.leftContainerViewDataSource bjl_objectAtIndex:index];
    NSString *title = [dic bjl_objectForKey:BJLSettingMenuOptionNameString];
    return title;
}

@end
