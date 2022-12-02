//
//  BJLScChatViewController.h
//  BJLiveUI
//
//  Created by xijia dai on 2019/9/17.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@class ICLImageFile;

@interface BJLScChatViewController: BJLTableViewController

- (instancetype)initWithRoom:(BJLRoom *)room;
- (instancetype)initWithRoom:(BJLRoom *)room sizeRegular:(BOOL)sizeRegular;

@property (nonatomic, readonly) UIView *chatStatusView;

@property (nonatomic, copy, nullable) void (^newMessageCallback)(NSInteger count);
@property (nonatomic, copy, nullable) void (^showChatInputViewCallback)(BOOL whisperChatUserExpend, BJLCommandLotteryBegin *_Nullable commandLottery);
@property (nonatomic, copy, nullable) void (^showImageViewCallback)(BJLMessage *currentImageMessage, NSArray<BJLMessage *> *imageMessages, BOOL isStickyMessage);
@property (nonatomic, copy, nullable) void (^changeChatStatusCallback)(BJLChatStatus chatStatus, BJLUser *_Nullable targetUser);
@property (nonatomic, copy, nullable) void (^tapCommandLotteryCallback)(BJLCommandLotteryBegin *commandLottery);
@property (nonatomic, copy, nullable) void (^revokeMessageCallback)(NSString *messageID);
/**
 收到新的未读消息, 增量式回调, 用于聊天飘窗
 */
@property (nonatomic, copy, nullable) void (^receiveNewUnreadMessageCallback)(NSArray<BJLMessage *> *unreadMessage);

// 1v1 phone
@property (nonatomic, copy, nullable) void (^backToVideoCallback)(void);

@property (nonatomic, copy, nullable) void (^userSelectCallback)(__kindof BJLUser *user, CGPoint point);

- (void)refreshMessages;
- (void)sendImageFile:(ICLImageFile *)file image:(nullable UIImage *)image;

- (void)updateChatStatus:(BJLChatStatus)chatStatus withTargetUser:(nullable BJLUser *)targetUser;
- (void)updateInputViewHidden:(BOOL)hidden;
- (void)showChatInputView;

- (void)addSecretForbidMessage:(NSString *)message targetUser:(nullable BJLUser *)targetUser;

@end

NS_ASSUME_NONNULL_END
