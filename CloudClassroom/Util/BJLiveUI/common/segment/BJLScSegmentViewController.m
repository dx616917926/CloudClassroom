//
//  BJLScSegmentViewController.m
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/23.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import "BJLScSegmentViewController.h"
#import "BJLScGroupUserViewController.h"
#import "BJLScUserViewController.h"
#import "BJLScAppearance.h"
#import "BJLScSegment.h"
#import "BJLScUserOperateView.h"
#import "BJLMutableAwardsView.h"

#define kMaxSegmentCount 2
#define kIngnoreCount    1

typedef NS_ENUM(NSInteger, BJLScSegmentPosition) {
    BJLScSegmentPosition_top,
    BJLScSegmentPosition_middle,
    BJLScSegmentPosition_bottom,
};

@interface BJLScSegmentViewController () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) BJLRoom *room;
@property (nonatomic) BJLScSegment *topSegment;
@property (nonatomic) UIView *singleLine;
@property (nonatomic, nullable) BJLScSegment *middleSegment;
@property (nonatomic) BJLScSegmentPosition middleSegmentPosition;
@property (nonatomic, readwrite) BJLScChatViewController *chatViewController;
@property (nonatomic, readwrite) BJLScUserViewController *userViewController;
@property (nonatomic, readwrite) BJLScGroupUserViewController *groupUserViewController;
@property (nonatomic) NSInteger totalUserCount;

@property (nonatomic) NSMutableArray<NSString *> *topSegmentTitle, *middleSegmentTitle;
@property (nonatomic) UIImage *middleSegmentImage;
@property (nonatomic) NSMutableArray<UIViewController *> *topSegmentViewContollers, *middleSegmentViewContollers;
@property (nonatomic) UIViewController *optionViewController;

// 禁言用户
@property (nonatomic, readwrite, copy, nullable) NSArray<NSString *> *forbidUsers;
@property (nonatomic, readonly) NSMutableArray<NSString *> *mutableforbidUsers;

// 邀请发言中的用户
@property (nonatomic, nullable) NSMutableArray<NSString *> *inviteSpeakingUsers;

@property (nonatomic, strong) UIViewController *awardsViewController;

@end

@implementation BJLScSegmentViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    if (self = [super init]) {
        self.room = room;
        [self reset];
        bjl_weakify(self);
        [self bjl_kvo:BJLMakeProperty(self.room, state)
             observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
                 bjl_strongify(self);
                 if (self.room.state == BJLRoomState_connected) {
                     [self remakeSubviewsAndConstraints];
                     [self remakeObserving];
                 }
                 return YES;
             }];
    }
    return self;
}

- (void)reset {
    self.middleSegmentPosition = BJLScSegmentPosition_bottom;
    self.totalUserCount = 0;
    self.topSegmentTitle = [NSMutableArray new];
    self.middleSegmentTitle = [NSMutableArray new];
    self.topSegmentViewContollers = [NSMutableArray new];
    self.middleSegmentViewContollers = [NSMutableArray new];
    if (self.chatViewController) {
        [self.chatViewController bjl_removeFromParentViewControllerAndSuperiew];
        self.chatViewController = nil;
    }
    if (self.userViewController) {
        [self.userViewController bjl_removeFromParentViewControllerAndSuperiew];
        self.userViewController = nil;
    }
    if (self.groupUserViewController) {
        [self.groupUserViewController bjl_removeFromParentViewControllerAndSuperiew];
        self.groupUserViewController = nil;
    }
    if (self.topSegment) {
        [self.topSegment removeFromSuperview];
        self.topSegment = nil;
        [self.singleLine removeFromSuperview];
        self.singleLine = nil;
    }
    if (self.middleSegment) {
        [self.middleSegment removeFromSuperview];
        self.middleSegment = nil;
    }
    self.forbidUsers = nil;
    self->_mutableforbidUsers = [NSMutableArray new];
    self.inviteSpeakingUsers = [NSMutableArray new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.accessibilityIdentifier = NSStringFromClass(self.class);
    self.view.backgroundColor = BJLTheme.windowBackgroundColor;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowOpacity = 0.1;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(-2.0, 0.0);
    self.view.layer.shadowRadius = 2.0;
}

- (void)remakeSubviewsAndConstraints {
    [self reset];
    NSArray<NSString *> *liveTabs = nil;
    if (self.room.loginUser.isStudent) {
        liveTabs = [self.room.featureConfig.liveTabsOfStudent componentsSeparatedByString:@","];
    }
    else {
        liveTabs = [self.room.featureConfig.liveTabs componentsSeparatedByString:@","];
    }

    for (NSInteger count = 0; count < liveTabs.count; count++) {
        BJLTuple *value = [self segmentTitleWithString:[liveTabs bjl_objectAtIndex:count]];
        BJLTupleUnpack(value) = ^(NSString *title, UIImage *image, UIViewController *viewController) {
            if (self.topSegmentTitle.count < kMaxSegmentCount) {
                [self.topSegmentTitle bjl_addObject:title];
                [self.topSegmentViewContollers bjl_addObject:viewController];
            }
            else {
                [self.middleSegmentTitle bjl_addObject:title];
                self.middleSegmentImage = image;
                [self.middleSegmentViewContollers bjl_addObject:viewController];
            }
        };
    }

    self.topSegment = [[BJLScSegment alloc] initWithItems:self.topSegmentTitle
                                                    width:0.0
                                                 fontSize:14.0
                                                textColor:BJLTheme.viewTextColor
                                                    style:BJLSegmentStyleUnderline];
    self.topSegment.accessibilityIdentifier = BJLKeypath(self, topSegment);
    [self.view addSubview:self.topSegment];
    [self.topSegment bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@32.0);
    }];

    self.singleLine = ({
        UIView *view = [UIView new];
        view.accessibilityIdentifier = @"singleLine";
        view.backgroundColor = BJLTheme.separateLineColor;
        view;
    });
    [self.view addSubview:self.singleLine];
    [self.singleLine bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.left.right.bottom.equalTo(self.topSegment);
        make.height.equalTo(@(BJLScOnePixel));
    }];

    if (self.middleSegmentTitle.count) {
        self.middleSegment = ({
            BJLScSegment *segment = [[BJLScSegment alloc] initWithItems:self.middleSegmentTitle
                                                                  width:0.0
                                                               fontSize:14.0
                                                              textColor:BJLTheme.viewTextColor
                                                                  style:BJLSegmentStyleUnderline];
            segment.accessibilityIdentifier = BJLKeypath(self, middleSegment);
            segment.layer.masksToBounds = NO;
            segment.layer.shadowOpacity = 0.3;
            segment.layer.shadowColor = [UIColor blackColor].CGColor;
            segment.layer.shadowOffset = CGSizeMake(0.0, -2.0);
            segment.layer.shadowRadius = 2.0;

            [segment setImage:self.middleSegmentImage forSegmentAtIndex:0];
            segment;
        });
        [self.view addSubview:self.middleSegment];
        [self.middleSegment bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.equalTo(self.view);
            make.height.equalTo(@32.0);
            make.bottom.equalTo(self.view);
        }];
        UIViewController *middleViewController = self.middleSegmentViewContollers.firstObject;
        [self bjl_addChildViewController:middleViewController superview:self.view];
        [middleViewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.middleSegment.bjl_bottom);
        }];

        [self setupGestureWithSegment];
    }
}

- (void)remakeObserving {
    [self bjl_stopAllKeyValueObserving];
    [self bjl_stopAllMethodParametersObserving];
    bjl_weakify(self);

    // 切换大小班之后 需要更新segmen里面的userController的数据
    [self bjl_kvo:BJLMakeProperty(self.room, state)
        filter:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
            return now.integerValue != old.integerValue && old;
        }
        observer:^BJLControlObserving(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
            bjl_strongify(self);
            if (self.room.state == BJLRoomState_connected) {
                [self remakeSubviewsAndConstraints];
                [self remakeObserving];
            }
            return YES;
        }];

    [self bjl_kvo:BJLMakeProperty(self.topSegment, selectedIndex)
         observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self updateListWithTopSegmentIndex];
             [self updateControllersWithMiddleSegmentPosition];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self, middleSegmentPosition)
         observer:^BOOL(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self updateControllersWithMiddleSegmentPosition];
             return YES;
         }];

    [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, onlineUsersTotalCount)
         observer:^BOOL(NSNumber *_Nullable now, NSNumber *_Nullable old, BJLPropertyChange *_Nullable change) {
             bjl_strongify(self);
             [self updateTitleWithOnlineUsersTotalCount];
             return YES;
         }];

    [self bjl_observe:BJLMakeMethod(self.room.chatVM, didReceiveForbidUser:fromUser:duration:) observer:^BOOL(BJLUser *user, BJLUser *fromUser, NSTimeInterval duration) {
        bjl_strongify(self);
        // !!!:不进行禁言时间的倒计时，只要禁言就认为一直禁言，除非被解除
        BOOL forbid = duration > 0;
        if (!forbid) {
            if ([self.mutableforbidUsers containsObject:user.number]) {
                [self.mutableforbidUsers bjl_removeObject:user.number];
            }

            self.forbidUsers = [self.mutableforbidUsers copy];
            return YES;
        }

        BOOL changed = [self addForbidUser:user.number];
        if (changed) {
            self.forbidUsers = [self.mutableforbidUsers copy];
        }
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.chatVM, didReceiveForbidUserList:) observer:^BOOL(NSDictionary<NSString *, NSNumber *> *_Nullable forbidUserList) {
        bjl_strongify(self);
        [self.mutableforbidUsers removeAllObjects];
        self.forbidUsers = [self.mutableforbidUsers copy];
        if (!forbidUserList || ![forbidUserList.allKeys count]) {
            return YES;
        }

        NSMutableArray<NSString *> *userList = [NSMutableArray new];
        [forbidUserList enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSNumber *_Nonnull obj, BOOL *_Nonnull stop) {
            NSInteger duration = obj.integerValue;
            if (duration > 0) {
                [userList bjl_addObject:key];
            }
        }];

        [self addForbidUsers:[userList copy]];
        self.forbidUsers = [self.mutableforbidUsers copy];
        return YES;
    }];

    [self bjl_observe:BJLMakeMethod(self.room.speakingRequestVM, didReceiveSpeakingInviteResultWithUserID:accept:) observer:(BJLMethodObserver) ^ BOOL(NSString * userID, BOOL accept) {
        bjl_strongify(self);
        if (!userID.length) {
            return YES;
        }

        [self removeInvitingUser:userID];
        return YES;
    }];
}

#pragma mark - update

- (void)updateTitleWithOnlineUsersTotalCount {
    NSInteger totalCount = MAX((NSInteger)self.room.onlineUsersVM.onlineUsersTotalCount,
        (NSInteger)self.totalUserCount);
    [self segmentWithController:self.userListViewController handler:^(BJLScSegment *_Nullable segment, NSArray<UIViewController *> *_Nullable controllers, NSInteger index) {
        [segment setTitle:(totalCount <= 0 ? BJLLocalizedString(@"用户") : [NSString stringWithFormat:BJLLocalizedString(@"用户(%td)"), totalCount]) forSegmentAtIndex:index];
    }];
}

- (void)updateControllersWithMiddleSegmentPosition {
    bjl_weakify(self);
    [self segmentWithController:self.chatViewController handler:^(BJLScSegment *_Nullable segment, NSArray<UIViewController *> *_Nullable controllers, NSInteger index) {
        bjl_strongify(self);
        // 显示时不隐藏聊天输入
        [self.chatViewController updateInputViewHidden:![self appearInViewWithSegment:segment index:index]];
    }];
    if (self.middleSegmentPosition != BJLScSegmentPosition_bottom) {
        [self.middleSegment updateRedDotAtIndex:self.middleSegment.selectedIndex count:0 ignoreCount:YES];
    }
    else if (self.middleSegmentPosition != BJLScSegmentPosition_top) {
        [self.topSegment updateRedDotAtIndex:self.topSegment.selectedIndex count:0 ignoreCount:YES];
    }
}

// 根据索引显示 controller，暂时只支持 top
- (void)updateListWithTopSegmentIndex {
    NSInteger segmentIndex = self.topSegment.selectedIndex;
    UIViewController *viewController = [self.topSegmentViewContollers bjl_objectAtIndex:segmentIndex];
    bjl_weakify(self);
    [self segmentWithController:viewController handler:^(BJLScSegment *_Nullable segment, NSArray<UIViewController *> *_Nullable controllers, NSInteger index) {
        bjl_strongify(self);
        // 隐藏其他控制器
        for (UIViewController *controller in controllers) {
            if (controller != viewController) {
                [controller bjl_removeFromParentViewControllerAndSuperiew];
            }
        }
        // 隐藏当前 tab 红点
        [segment updateRedDotAtIndex:index count:0 ignoreCount:YES];
        // 展示当前控制器
        [self bjl_addChildViewController:viewController superview:self.view];
        [viewController.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.top.equalTo(self.topSegment.bjl_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.middleSegment.bjl_top ?: self.view);
        }];
        if (self.middleSegment) {
            [self.view bringSubviewToFront:self.middleSegment];
        }
    }];
}

#pragma mark - make

- (BJLTupleType(NSString *_Nullable, UIImage *_Nullable, UIViewController *_Nullable))segmentTitleWithString:(NSString *)string {
    NSString *title = nil;
    UIViewController *viewController = nil;
    UIImage *image = nil;
    if ([string isEqualToString:@"chat"]) {
        title = BJLLocalizedString(@"聊天");
        image = [UIImage bjl_imageNamed:@"bjl_sc_chat_icon"];
        viewController = [self makeChatViewController];
    }
    else if ([string isEqualToString:@"user"] && !self.room.featureConfig.hideUserList) {
        title = BJLLocalizedString(@"用户");
        image = [UIImage bjl_imageNamed:@"bjl_sc_userlist_icon"];
        viewController = [self makeUserViewController];
    }
    return BJLTuplePack((NSString *, UIImage *, UIViewController *), title, image, viewController);
}

- (UIViewController *)makeChatViewController {
    if (self.chatViewController) {
        return self.chatViewController;
    }

    bjl_weakify(self);
    self.chatViewController = [[BJLScChatViewController alloc] initWithRoom:self.room];
    [self.chatViewController setNewMessageCallback:^(NSInteger count) {
        bjl_strongify(self);
        [self segmentWithController:self.chatViewController handler:^(BJLScSegment *_Nullable segment, NSArray<UIViewController *> *_Nullable controllers, NSInteger index) {
            bjl_strongify(self);
            if (![self appearInViewWithSegment:segment index:index]) {
                BOOL shouldIgnoreCount = (segment == self.middleSegment);
                [segment updateRedDotAtIndex:index count:count ignoreCount:shouldIgnoreCount];
            }
        }];
    }];
    [self.chatViewController setShowImageViewCallback:^(BJLMessage *currentImageMessage, NSArray<BJLMessage *> *imageMessages, BOOL isStickyMessage) {
        bjl_strongify(self);
        if (self.showImageViewCallback) {
            self.showImageViewCallback(currentImageMessage, imageMessages, isStickyMessage);
        }
    }];
    [self.chatViewController setShowChatInputViewCallback:^(BOOL whisperChatUserExpend, BJLCommandLotteryBegin *_Nullable commandLottery) {
        bjl_strongify(self);
        if (self.showChatInputViewCallback) {
            self.showChatInputViewCallback(whisperChatUserExpend, commandLottery);
        }
    }];

    [self.chatViewController setTapCommandLotteryCallback:^(BJLCommandLotteryBegin *_Nonnull commandLottery) {
        bjl_strongify(self);
        if (self.tapCommandLotteryCallback) {
            self.tapCommandLotteryCallback(commandLottery);
        }
    }];

    [self.chatViewController setChangeChatStatusCallback:^(BJLChatStatus chatStatus, BJLUser *_Nullable targetUser) {
        bjl_strongify(self);
        if (self.changeChatStatusCallback) {
            self.changeChatStatusCallback(chatStatus, targetUser);
        }
    }];

    [self.chatViewController setUserSelectCallback:^(__kindof BJLUser *_Nonnull user, CGPoint point) {
        bjl_strongify(self);
        CGPoint realPoint = [self.view convertPoint:point fromView:self.chatViewController.view];
        [self showChatMenuWithUser:user point:realPoint enabelStudent:YES];
    }];

    [self.chatViewController setReceiveNewUnreadMessageCallback:^(NSArray<BJLMessage *> *_Nonnull unreadMessage) {
        bjl_strongify(self);
        if (self.receiveNewUnreadMessageCallback) {
            self.receiveNewUnreadMessageCallback(unreadMessage);
        }
    }];

    [self.chatViewController setRevokeMessageCallback:^(NSString *_Nonnull messageID) {
        bjl_strongify(self);
        if (self.revokeMessageCallback) {
            self.revokeMessageCallback(messageID);
        }
    }];
    return self.chatViewController;
}

- (UIViewController *)makeUserViewController {
    if (self.userListViewController) {
        return self.userListViewController;
    }

    bjl_weakify(self);
    if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_normal) {
        self.userViewController = [[BJLScUserViewController alloc] initWithRoom:self.room];
        [self.userViewController setUserCountChangeCallback:^(NSInteger totalCount) {
            bjl_strongify(self);
            if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_normal) {
                self.totalUserCount = totalCount;
                [self updateTitleWithOnlineUsersTotalCount];
            }
        }];
        [self.userViewController setUserSelectCallback:^(__kindof BJLUser *_Nonnull user, CGPoint point) {
            bjl_strongify(self);
            CGPoint realPoint = [self.view convertPoint:point fromView:self.userViewController.view];
            [self showChatMenuWithUser:user point:realPoint enabelStudent:NO];
        }];
        [self.userViewController setUserLikeCallback:^(__kindof BJLUser *_Nonnull user, CGPoint point) {
            bjl_strongify(self);
            CGPoint realPoint = [self.view convertPoint:point fromView:self.userViewController.view];
            [self sendLikeForUser:user menuPosition:realPoint];
        }];
    }
    else {
        self.groupUserViewController = [[BJLScGroupUserViewController alloc] initWithRoom:self.room];
        [self.groupUserViewController setUserCountChangeCallback:^(NSInteger totalCount) {
            bjl_strongify(self);
            if (self.room.roomInfo.newRoomGroupType != BJLRoomNewGroupType_normal) {
                self.totalUserCount = totalCount;
                [self updateTitleWithOnlineUsersTotalCount];
            }
        }];
        [self.groupUserViewController setUserSelectCallback:^(__kindof BJLUser *_Nonnull user, CGPoint point) {
            bjl_strongify(self);
            CGPoint realPoint = [self.view convertPoint:point fromView:self.groupUserViewController.view];
            [self showChatMenuWithUser:user point:realPoint enabelStudent:NO];
        }];
        [self.groupUserViewController setUserLikeCallback:^(__kindof BJLUser *_Nonnull user, CGPoint point) {
            bjl_strongify(self);
            CGPoint realPoint = [self.view convertPoint:point fromView:self.groupUserViewController.view];
            [self sendLikeForUser:user menuPosition:realPoint];
        }];
    }
    return self.userListViewController;
}

#pragma mark - getter

- (UIViewController *)userListViewController {
    return (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_normal) ? self.userViewController : self.groupUserViewController;
}

// segment 的 index 所指向的 viewController 是否正在页面展示
- (BOOL)appearInViewWithSegment:(BJLScSegment *)segment index:(NSInteger)index {
    if (segment.selectedIndex != index) {
        return NO;
    }
    else if (segment == self.topSegment && self.middleSegmentPosition == BJLScSegmentPosition_top) {
        return NO;
    }
    else if (segment == self.middleSegment && self.middleSegmentPosition == BJLScSegmentPosition_bottom) {
        return NO;
    }
    return YES;
}

// segment 是否全部显示 index 所指的控制器
- (BOOL)fullAppearInViewWithSegment:(BJLScSegment *)segment index:(NSInteger)index {
    if (segment.selectedIndex != index) {
        return NO;
    }
    if (segment == self.topSegment && self.middleSegmentPosition == BJLScSegmentPosition_bottom) {
        return YES;
    }
    else if (segment == self.middleSegment && self.middleSegmentPosition == BJLScSegmentPosition_top) {
        return YES;
    }
    return NO;
}

#pragma mark -

- (void)removeInvitingUser:(NSString *)userID {
    for (NSString *userid in [self.inviteSpeakingUsers copy]) {
        if ([userID isEqualToString:userid]) {
            [self.inviteSpeakingUsers bjl_removeObject:userID];
        }
    }
}

- (void)addForbidUsers:(NSArray<NSString *> *)users {
    if (!users.count) {
        [self.mutableforbidUsers removeAllObjects];
        return;
    }

    for (NSString *userNumber in users) {
        [self addForbidUser:userNumber];
    }
}

- (BOOL)addForbidUser:(NSString *)userNumber {
    if (!userNumber.length) {
        return NO;
    }

    /* 去重:
     *  1. 掉线又登录用户 - number 相同、但 ID 可能不同, 以新换旧
     */

    for (NSString *forbidUserNumber in [self.mutableforbidUsers copy]) {
        if ([forbidUserNumber isEqualToString:userNumber]) {
            [self.mutableforbidUsers removeObject:userNumber];
            //            break; //也许有重合的?
        }
    }
    [self.mutableforbidUsers bjl_addObject:userNumber];
    return YES;
}

- (BOOL)isForebidChatUser:(BJLUser *)user {
    for (NSString *forbidUserNumber in self.forbidUsers) {
        if ([forbidUserNumber isEqualToString:user.number]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSpeakingWitUser:(BJLUser *)user {
    if (self.room.playingVM.playMixedVideo) {
        for (BJLUser *playingUser in self.room.playingVM.mixedPlayingUsers) {
            if ([playingUser isSameUserWithID:user.ID number:user.number]) {
                return YES;
            }
        }
    }
    else {
        for (BJLUser *playingUser in self.room.playingVM.playingUsers) {
            if ([playingUser isSameUserWithID:user.ID number:user.number]) {
                return YES;
            }
        }
    }
    return NO;
}

// 取消邀请
- (void)shouldCancelInvite:(BJLUser *)user {
    BOOL accept = [self isSpeakingWitUser:user];
    if (!accept) {
        [self.room.speakingRequestVM sendSpeakingInviteToUserID:user.ID invite:NO];
        [self removeInvitingUser:user.ID];
    }
}

- (BOOL)isInvitingWithUsers:(BJLUser *)user {
    BOOL accept = [self isSpeakingWitUser:user];
    if (accept && [self.inviteSpeakingUsers containsObject:user.ID]) {
        [self removeInvitingUser:user.ID];
        return NO;
    }
    else if (!accept && [self.inviteSpeakingUsers containsObject:user.ID]) {
        return YES;
    }
    return NO;
}

// enabelStudent : 用户列表是否允许学生用户操作
- (void)showChatMenuWithUser:(__kindof BJLUser *)user point:(CGPoint)point enabelStudent:(BOOL)enabelStudent {
    if (self.room.loginUser.isStudent
        && (!enabelStudent || !self.room.featureConfig.enableWhisper || user.isStudent)) {
        return;
    }

    if (!user || [user.ID isEqualToString:self.room.loginUser.ID]) {
        return;
    }

    BOOL isInviting = [self isInvitingWithUsers:user];
    BOOL speakingEnable = [self isSpeakingWitUser:user];
    BOOL hasStudentRaise = self.room.featureConfig.isWebRTC ? self.room.roomInfo.hasStudentRaise : YES;
    BOOL disableForbidChatButton = !user.isStudent || (self.room.loginUser.isAssistant && ![self.room.roomVM getAssistantaAuthorityWithForbidandKick]);
    BOOL enableWhisper = self.room.featureConfig.enableWhisper && !!self.chatViewController;
    // 老师有设置/收回主讲的权限/助教有设置其他助教为主讲的权限
    BOOL showPresentChangeButton = (self.room.loginUser.isTeacher
                                       && user.isAssistant
                                       && self.room.roomVM.liveStarted
                                       && self.room.featureConfig.canChangePresenter)
                                   || (self.room.loginUser.isAssistant
                                       && self.room.loginUserIsPresenter
                                       && user.isAssistant
                                       && self.room.featureConfig.canChangePresenter
                                       && self.room.featureConfig.enableAssistantChangePresenter);
    BJLScUserOperateView *operationView = [[BJLScUserOperateView alloc] initWithUser:user];
    // 需要查看本地记录
    operationView.isInviting = isInviting; //是否还在邀请中
    operationView.speakingEnable = speakingEnable; //发言状态
    operationView.forceSpeak = self.room.featureConfig.inviteSpeakByForce; //强制发言
    operationView.forbidChat = [self isForebidChatUser:user]; //禁言
    operationView.enableWhisper = enableWhisper;
    operationView.disableKickoutButton = !user.isStudent;
    operationView.disableForbidChatButton = disableForbidChatButton;
    operationView.disableinviteSpeakButton = (!user.isStudent
                                              || !self.room.roomVM.liveStarted
                                              || self.room.roomInfo.isMockLive
                                              || self.room.roomInfo.isPushLive
                                              || !hasStudentRaise);
    operationView.disableSetPresentButton = !showPresentChangeButton;
    operationView.isSetPresent = ![user isSameUser:self.room.onlineUsersVM.currentPresenter];
    [operationView updateButtonConstraints];
    if (![operationView.buttons count]) {
        return;
    }

    bjl_weakify(self);
    [operationView setInvateSpeakCallback:^BOOL(BOOL force) {
        bjl_strongify(self);
        [self hideOptionViewController];

        BJLError *error = nil;
        // 强制发言，失败返回
        if (force) {
            BOOL openVideo = !speakingEnable && self.room.featureConfig.autoPublishVideoStudent;
            error = [self.room.recordingVM remoteChangeRecordingWithUser:user audioOn:!speakingEnable videoOn:openVideo];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
            return !error;
        }

        // 邀请发言，失败返回
        BOOL invite = YES;
        if (isInviting || speakingEnable) {
            invite = NO;
        }
        else {
            invite = YES;
        }
        error = [self.room.speakingRequestVM sendSpeakingInviteToUserID:user.ID invite:invite];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            return !error;
        }
        if (isInviting) { // 邀请中 -> 取消邀请
            [self removeInvitingUser:user.ID];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shouldCancelInvite:) object:user];
        }
        else { // 不在邀请中 :发言 / 台下
            if (speakingEnable) { // 发言中
                error = [self.room.recordingVM remoteChangeRecordingWithUser:user audioOn:NO videoOn:NO];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                }
            }
            else { // 台下
                [self.inviteSpeakingUsers bjl_addObject:user.ID];
                // 延时30s判断学生一直不响应, 就取消邀请
                [self performSelector:@selector(shouldCancelInvite:) withObject:user afterDelay:30.0];
            }
        }
        return YES;
    }];

    [operationView setForbidChatCallback:^BOOL(BOOL forbid) {
        bjl_strongify(self);
        [self hideOptionViewController];
        // 禁言某人，大班课是禁言一天
        CGFloat duration = forbid ? 60 * 60 * 24 : 0.0;
        BJLError *error = [self.room.chatVM sendForbidUser:user duration:duration];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        return !error;
    }];

    [operationView setWhisperCallback:^BOOL {
        bjl_strongify(self);
        [self hideOptionViewController];
        if (!self.chatViewController) {
            return NO;
        }

        [self segmentWithController:self.chatViewController handler:^(BJLScSegment *_Nullable segment, NSArray<UIViewController *> *_Nullable controllers, NSInteger index) {
            bjl_strongify(self);
            if (![self appearInViewWithSegment:segment index:index]) {
                if (segment == self.topSegment) {
                    self.topSegment.selectedIndex = index;
                }
            }
        }];

        [self.chatViewController updateChatStatus:BJLChatStatus_private withTargetUser:user];
        if (self.changeChatStatusCallback) {
            self.changeChatStatusCallback(BJLChatStatus_private, user);
        }

        if (self.showChatInputViewCallback) {
            self.showChatInputViewCallback(NO, nil);
        }
        return YES;
    }];

    [operationView setKickoutCallback:^BOOL {
        bjl_strongify(self);
        [self hideOptionViewController];
        BJLError *error = [self.room.onlineUsersVM blockUserWithID:user.ID];
        if (error) {
            [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
        }
        return !error;
    }];

    [operationView setPresentCallback:^BOOL(BOOL isSet) {
        bjl_strongify(self);
        [self hideOptionViewController];
        BJLError *error = nil;
        if (isSet) {
            error = [self.room.onlineUsersVM requestChangePresenterWithUserID:user.ID];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        }
        else {
            error = [self.room.onlineUsersVM requestChangePresenterWithUserID:self.room.loginUser.ID];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        }
        return !error;
    }];

    CGFloat height = BJLScUserOperateViewButtonHeight * ([operationView.buttons count] + 1);

    self.optionViewController = ({
        UIViewController *viewController = [[UIViewController alloc] init];
        viewController.view.backgroundColor = [UIColor clearColor];
        viewController.popoverPresentationController.containerView.backgroundColor = [UIColor clearColor];
        viewController.modalPresentationStyle = UIModalPresentationPopover;
        viewController.preferredContentSize = CGSizeMake(BJLScSegmentWidth, height);
        viewController.popoverPresentationController.backgroundColor = BJLTheme.toolboxBackgroundColor;
        viewController.popoverPresentationController.delegate = self;
        viewController.popoverPresentationController.sourceView = self.view;
        viewController.popoverPresentationController.sourceRect = CGRectMake(point.x, point.y, 1.0, 1.0);
        viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown | UIPopoverArrowDirectionRight;
        viewController;
    });

    [self.optionViewController.view addSubview:operationView];
    [operationView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.optionViewController.view.bjl_safeAreaLayoutGuide ?: self.optionViewController.view);
    }];

    if (self.presentedViewController) {
        [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
    }
    [self presentViewController:self.optionViewController
                       animated:YES
                     completion:nil];
}

- (void)hideOptionViewController {
    [self.optionViewController bjl_dismissAnimated:YES completion:nil];
}

#pragma mark - like
- (void)sendLikeForUser:(BJLUser *)user menuPosition:(CGPoint)position {
    if (!self.room.roomVM.liveStarted) { return; }

    // !!!: [BJLAward allAwards]里面至少有一个, 当大于1的时候, 把图标换成钻石, 点击显示多种奖励
    if ([BJLAward allAwards].count > 1) {
        BJLMutableAwardsView *mutableAwardsView = [[BJLMutableAwardsView alloc] initWithRoom:self.room user:user];
        self.awardsViewController = ({
            UIViewController *viewController = [[UIViewController alloc] init];
            viewController.view.backgroundColor = [UIColor clearColor];
            viewController.modalPresentationStyle = UIModalPresentationPopover;
            viewController.preferredContentSize = mutableAwardsView.size;
            viewController.popoverPresentationController.backgroundColor = BJLTheme.toolboxBackgroundColor;
            viewController.popoverPresentationController.delegate = self;
            viewController.popoverPresentationController.sourceView = self.view;
            viewController.popoverPresentationController.sourceRect = CGRectMake(position.x, position.y, 1.0, 1.0);
            viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
            viewController;
        });

        [self.awardsViewController.view addSubview:mutableAwardsView];
        [mutableAwardsView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.awardsViewController.view.bjl_safeAreaLayoutGuide ?: self.awardsViewController.view);
        }];

        bjl_weakify(self);
        [mutableAwardsView setAwardKeyCallback:^(NSString *_Nonnull key) {
            bjl_strongify(self);
            [self.room.roomVM sendLikeForUserNumber:user.number key:key];
            [self hideAwardsViewController];
        }];

        if (self.presentedViewController) {
            [self.presentedViewController bjl_dismissAnimated:YES completion:nil];
        }
        [self presentViewController:self.awardsViewController animated:YES completion:nil];
    }
    else {
        BOOL enableSendLike = YES;
        if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_onlinedoubleTeachers) {
            enableSendLike = self.room.loginUser.isTeacherOrAssistant && self.room.loginUser.groupID == 0;
        }
        else if (self.room.roomInfo.newRoomGroupType == BJLRoomNewGroupType_group) {
            enableSendLike = self.room.loginUser.isTeacher || (self.room.loginUser.isAssistant && self.room.loginUser.groupID == user.groupID);
        }
        if (enableSendLike) {
            [self.room.roomVM sendLikeForUserNumber:user.number];
        }
    }
}

- (void)hideAwardsViewController {
    [self.awardsViewController bjl_dismissAnimated:YES completion:nil];
}

#pragma mark - wheel

// 根据 controller 获取索引
- (void)segmentWithController:(UIViewController *)controller handler:(void (^__nullable)(BJLScSegment *_Nullable segment, NSArray<UIViewController *> *_Nullable controllers, NSInteger index))handler {
    if (!controller) {
        return;
    }
    for (NSInteger index = 0; index < self.topSegmentViewContollers.count; index++) {
        if (controller == [self.topSegmentViewContollers bjl_objectAtIndex:index]) {
            handler(self.topSegment, self.topSegmentViewContollers, index);
            return;
        }
    }
    for (NSInteger index = 0; index < self.middleSegmentViewContollers.count; index++) {
        if (controller == [self.middleSegmentViewContollers bjl_objectAtIndex:index]) {
            handler(self.middleSegment, self.middleSegmentViewContollers, index);
            return;
        }
    }
}

#pragma mark - gesture

//  middle segment 的手势
- (void)setupGestureWithSegment {
    bjl_weakify(self);
    __block CGFloat originOffsetY = 0.0;
    __block CGPoint movingTranslation = CGPointZero;
    UIPanGestureRecognizer *panGesture = [UIPanGestureRecognizer bjl_gestureWithHandler:^(__kindof UIPanGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [gesture setTranslation:CGPointZero inView:self.view];
            originOffsetY = self.middleSegment.frame.origin.y;
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            movingTranslation = [gesture translationInView:self.view];
            CGFloat offsetY = MAX(self.topSegment.frame.size.height, MIN(self.view.frame.size.height - self.middleSegment.frame.size.height, movingTranslation.y + originOffsetY));
            CGFloat offsetCenterY = offsetY - self.view.frame.size.height / 2;
            [self.middleSegment bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.right.equalTo(self.view);
                make.height.equalTo(@32.0);
                make.top.equalTo(self.view.bjl_centerY).offset(offsetCenterY);
            }];
        }
        else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            movingTranslation = [gesture translationInView:self.view];
            CGFloat offsetY = MAX(self.topSegment.frame.size.height, MIN(self.view.frame.size.height - self.middleSegment.frame.size.height, movingTranslation.y + originOffsetY));
            CGFloat contentHeight = self.view.frame.size.height - self.topSegment.frame.size.height;
            if (offsetY <= (contentHeight / 4 + self.topSegment.frame.size.height)) {
                // 上 1/4 位置
                [self.middleSegment bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                    make.left.right.equalTo(self.view);
                    make.height.equalTo(@32.0);
                    make.top.equalTo(self.view).offset(self.topSegment.frame.size.height);
                }];
                self.middleSegmentPosition = BJLScSegmentPosition_top;
            }
            else if ((contentHeight / 4 + self.topSegment.frame.size.height) < offsetY && offsetY < (contentHeight * 3.0 / 4 + self.topSegment.frame.size.height)) {
                // 1/4 - 3/4位置
                [self.middleSegment bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                    make.left.right.equalTo(self.view);
                    make.height.equalTo(@32.0);
                    make.top.equalTo(self.view.bjl_centerY);
                }];
                self.middleSegmentPosition = BJLScSegmentPosition_middle;
            }
            else if (offsetY >= (contentHeight * 3.0 / 4 + self.topSegment.frame.size.height)) {
                // 后 1/4 位置
                [self.middleSegment bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                    make.left.right.equalTo(self.view);
                    make.height.equalTo(@32.0);
                    make.bottom.equalTo(self.view);
                }];
                self.middleSegmentPosition = BJLScSegmentPosition_bottom;
            }
        }
    }];
    [self.middleSegment addGestureRecognizer:panGesture];

    UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
        bjl_strongify(self);
        if (self.middleSegmentPosition != BJLScSegmentPosition_middle) {
            [self.middleSegment bjl_remakeConstraints:^(BJLConstraintMaker *_Nonnull make) {
                make.left.right.equalTo(self.view);
                make.height.equalTo(@32.0);
                make.top.equalTo(self.view.bjl_centerY);
            }];
            self.middleSegmentPosition = BJLScSegmentPosition_middle;
        }
    }];
    [self.middleSegment addGestureRecognizer:tapGesture];
    [self.middleSegment addGestureRecognizer:panGesture];
    [tapGesture requireGestureRecognizerToFail:panGesture];
}

#pragma mark - <UIPopoverPresentationControllerDelegate>

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

@end
