//
//  BJLMutableAwardsView.m
//  BJLiveUI
//
//  Created by xyp on 2020/7/31.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLMutableAwardsView.h"
#import "BJLTheme.h"

@interface BJLMutableAwardsView ()

@property (nonatomic) NSArray<BJLAward *> *awards;
@property (nonatomic) NSMutableArray<UIButton *> *buttons;
@property (nonatomic) NSDictionary *mutableAwardsInfo;
@property (nonatomic) __kindof BJLUser *user;
@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) CGSize size;

@end

@implementation BJLMutableAwardsView

CGFloat itemH = 24.0;
CGFloat margin = 6.0;

- (instancetype)initWithRoom:(BJLRoom *)room user:(__kindof BJLUser *)user {
    self = [super init];
    if (self) {
        self.room = room;
        self.user = user;
        self.awards = [BJLAward allAwards];
        self.mutableAwardsInfo = self.room.roomVM.mutableAwardsInfo;
        self.buttons = [NSMutableArray new];
        CGFloat width = 60.0;
        CGFloat height = self.awards.count * (itemH + margin) + margin;
        self.size = CGSizeMake(width, height);
        [self setupUI];
        [self setupObserving];
    }
    return self;
}

- (void)setupUI {
    for (int i = 0; i < self.awards.count; i++) {
        BJLAward *award = [self.awards bjl_objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.accessibilityIdentifier = award.key;
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.enabled = self.room.loginUser.isTeacherOrAssistant;
        if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_onlinedoubleTeachers) {
            button.enabled = self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.groupID == 0;
        }
        else if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_group) {
            button.enabled = self.room.loginUser.isTeacher || (self.room.loginUser.isAssistant && self.room.loginUser.groupID == self.user.groupID);
        }
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 4.0, 0.0, 0.0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 20.0);
        if (@available(iOS 11.0, *)) {
            [button bjl_setImageWithURL:[NSURL URLWithString:award.logo] forState:UIControlStateNormal];
            [button bjl_setImageWithURL:[NSURL URLWithString:award.logo] forState:UIControlStateDisabled];
            [button bjl_setImageWithURL:[NSURL URLWithString:award.logo] forState:UIControlStateNormal | UIControlStateDisabled];
            [button bjl_setImageWithURL:[NSURL URLWithString:award.logo] forState:UIControlStateNormal | UIControlStateHighlighted];
        }
        else {
            //iOS10 上 从web加载的图片很大的话，会导致label显示不出来
            //这里需要下载后重新resize一下
            [BJLWebImageLoader.sharedImageLoader bjl_loadImageWithURL:[NSURL URLWithString:award.logo] completion:^(UIImage *_Nullable image, NSError *_Nullable error, NSURL *_Nullable imageURL) {
                if (image) {
                    UIImage *resizedImage = [image bjl_imageFillSize:CGSizeMake(24, 24) enlarge:NO];
                    [button setImage:resizedImage forState:UIControlStateNormal];
                    [button setImage:resizedImage forState:UIControlStateHighlighted];
                }
            }];
        }

        [button setTitleColor:[UIColor bjl_colorWithHexString:@"#F7E123"] forState:UIControlStateNormal];
        if (self.room.roomInfo.roomType == BJLRoomType_1vNClass) {
            [button setTitleColor:BJLTheme.viewTextColor forState:UIControlStateNormal];
        }

        [self updateButton:button awardKey:award.key];

        [button addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self).offset(margin + i * (itemH + margin));
            make.left.equalTo(self).offset(margin);
            make.right.equalTo(self).offset(-margin);
            make.height.equalTo(@(itemH));
        }];
        [self.buttons bjl_addObject:button];
    }
}

- (void)setupObserving {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, mutableAwardsInfo)
         observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             self.mutableAwardsInfo = self.room.roomVM.mutableAwardsInfo;
             [self reloadAwardsInfo];
             return YES;
         }];
}

- (void)reloadAwardsInfo {
    for (int i = 0; i < self.awards.count; i++) {
        BJLAward *award = [self.awards bjl_objectAtIndex:i];
        UIButton *button = [self.buttons bjl_objectAtIndex:i];
        [self updateButton:button awardKey:award.key];
    }
}

- (void)updateButton:(UIButton *)button awardKey:(NSString *)awardKey {
    NSNumber *count = [[self.mutableAwardsInfo bjl_dictionaryForKey:self.user.number] bjl_objectForKey:awardKey];
    NSString *countString = [NSString stringWithFormat:@"%@", count ?: @0];
    [button setTitle:countString forState:UIControlStateNormal];
}

- (void)likeAction:(UIButton *)button {
    NSString *key = button.accessibilityIdentifier;
    if (self.awardKeyCallback) {
        self.awardKeyCallback(key);
    }
}

@end
