//
//  BJLChatVM.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-10.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import "BJLBaseVM.h"

#import "BJLMessage.h"

NS_ASSUME_NONNULL_BEGIN

/** ### 聊天 */
@interface BJLChatVM: BJLBaseVM

/** fromUser 能否向用户 toUser 发送私聊消息 */
- (BOOL)canSendPrivateMessageFromeUser:(BJLUser *)fromUser toUser:(BJLUser *)toUser;

#pragma mark - receive message

/**
 收到历史消息 - 需要覆盖更新本地缓存的消息
 #discussion 首次进直播间或断开重连会收到此回调
 #param receivedMessages 收到的所有消息
 */
- (BJLObservable)receivedMessagesDidOverwrite:(nullable NSArray<BJLMessage *> *)receivedMessages;

/**
 收到消息
 #param messages 消息
 */
- (BJLObservable)didReceiveMessages:(NSArray<BJLMessage *> *)messages;

#pragma mark - send message

/**
 发送文字消息，参考 `sendMessage:channel:` 方法
 #param text 消息，不能是空字符串或 nil
 #return BJLError:
 BJLErrorCode_invalidArguments  参数错误；
 BJLErrorCode_invalidCalling    错误调用，如禁言状态时调用此方法发送消息。
 */
- (nullable BJLError *)sendMessage:(NSString *)text;

/**
 指定对象，发送文字消息
 #param text 文字消息内容
 #param user 发送对象
 #return BJLError:
 BJLErrorCode_invalidArguments  参数错误；
 BJLErrorCode_invalidCalling    错误调用，如禁言状态时调用此方法发送消息。
 */
- (nullable BJLError *)sendMessage:(NSString *)text toUser:(nullable BJLUser *)user;

/**
 指定频道，发送文字消息
 #discussion 最多 BJLTextMaxLength_chat 个字符
 #discussion 成功后会收到消息通知
 #discussion 学生在禁言状态不能发送消息，参考 `forbidMe`、`forbidAll`
 #discussion 参考 `BJLMessage`
 #param text 消息，不能是空字符串或 nil
 #param channel 频道
 */
- (nullable BJLError *)sendMessage:(NSString *)text channel:(nullable NSString *)channel;

/**
 发送图片、表情等其它类型的消息
 #discussion 发送图片需事先调用 `uploadImageFile:progress:finish:` 方法上传
 #discussion 发送表情和图片需将 `(NSString *)emoticon.key` 或 `(NSString *)imageURLString` 转换成 (NSDictionary *)data，参考 `BJLMessage` 的 `messageDataWithEmoticonKey:` 和 `messageDataWithImageURLString:imageWidth:imageHeight:` 方法
 #param data 消息内容
 */
- (nullable BJLError *)sendMessageData:(NSDictionary *)data;

/**
 指定对象，发送图片、表情等其它类型的消息
 #param data 消息数据
 #param user 发送对象
 */
- (nullable BJLError *)sendMessageData:(NSDictionary *)data toUser:(nullable BJLUser *)user;

/**
 指定频道，发送图片、表情等其它类型的消息
 #param data 消息内容
 #param channel 频道
 */
- (nullable BJLError *)sendMessageData:(NSDictionary *)data channel:(nullable NSString *)channel;

/**
 上传图片，用于发送消息
 #param fileURL     图片文件路径
 #param progress    上传进度，非主线程回调、可能过于频繁
 - progress         0.0 ~ 1.0
 #param finish      结束
 - imageURLString   非 nil 即为成功
 - error            错误
 #return            upload task
 */
- (NSURLSessionUploadTask *)uploadImageFile:(NSURL *)fileURL
                                   progress:(nullable void (^)(CGFloat progress))progress
                                     finish:(void (^)(NSString *_Nullable imageURLString, BJLError *_Nullable error))finish;

#pragma mark - revoke message

/**
 撤回消息
 #discussion 老师可以撤回任意用户消息，学生可以撤回自己消息
 #param BJLMessage 聊天消息
 #return error
 */
- (nullable BJLError *)revokeMessage:(BJLMessage *)message;

/**
 撤回消息成功
 #param messageID 消息ID
 #param isCurrentUserRevoke 是否是当前用户撤回的消息
 */
- (BJLObservable)didRevokeMessageWithID:(NSString *)messageID isCurrentUserRevoke:(BOOL)isCurrentUserRevoke;

#pragma mark - 消息置顶

/** 聊天的置顶消息 */
@property (nonatomic, readonly, nullable) BJLMessage *stickyMessage;
@property (nonatomic, readonly, nullable) NSArray<BJLMessage *> *stickyMessageList;

/**
 获取置顶消息
 #discussion 连接直播间后、掉线重新连接后自动调用加载
 #discussion 获取成功后修改 `stickyMessageList`
 */
- (void)loadStickyMessage;

/**
 老师: 设置置顶消息
 #discussion 设置成功后修改 `stickyMessageList`
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)sendStickyMessage:(BJLMessage *)message;

/**
 老师: 取消某一条置顶的消息
 #discussion 设置成功后修改 `stickyMessageList`,
 @param message messgae
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限。
 */
- (nullable BJLError *)cancelStickyMessage:(BJLMessage *)message;

#pragma mark - translate message

/** 默认翻译目标语言 */
@property (nonatomic, readonly) BJLMessageLanguageType defaultTranslateToLanguageType;

/**
 翻译聊天消息，每秒最多仅允许发送一条，翻译源语言类型自动检测
 #param message 消息
 #param messageUUID 用于区分消息的唯一ID,不建议使用BJLMessage.ID, 不保证其唯一性
 #param BJLMessageLanguageType 目标翻译语言类型
 */
- (nullable BJLError *)translateMessage:(BJLMessage *)message
                            messageUUID:(nullable NSString *)messageUUID
                     targetLanguageType:(BJLMessageLanguageType)languageType;

/**
 收到消息翻译的结果
 #param translation 消息翻译的结果
 #param messageUUID 消息唯一ID
 #param from 消息翻译源语言类型
 #param to 消息翻译目标语言类型
 */
- (BJLObservable)didReceiveMessageTranslation:(NSString *)translation
                                  messageUUID:(nullable NSString *)messageUUID
                                         from:(BJLMessageLanguageType)from
                                           to:(BJLMessageLanguageType)to;

#pragma mark - forbid

/**
 全体禁言状态
 #discussion 全体或自己所在分组或个人被禁言都不能发送聊天消息，参考 `forbidMe`，`forbidMyGroup`
 */
@property (nonatomic, readonly) BOOL forbidAll;

/**
 存在分组时, 当前用户所属的分组禁言状态
 #discussion 全体或自己所在分组或个人被禁言都不能发送聊天消息，参考 `forbidMe`，`forbidAll`
 */
@property (nonatomic, readonly) BOOL forbidMyGroup;

/**
 老师: 设置全体禁言状态
 助教：设置自己所在组全组禁言
 #discussion 当前用户为老师或者大班助教设置成功后修改 `forbidAll`，否则若为分组助教设置成功后修改 `forbidMyGroup`
 #param forbidAll YES：全体或自己所在分组禁言，NO：取消全体/自己所在分组禁言
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限
 */
- (nullable BJLError *)sendForbidAll:(BOOL)forbidAll;

/**
 学生: 当前用户被禁言状态
 #discussion 全体或自己所在分组或个人被禁言都不能发送聊天消息，参考 `forbidAll`，`forbidMyGroup`
 */
@property (nonatomic, readonly) BOOL forbidMe;

/**
 所有人: 收到某人被禁言通知
 #discussion `duration` 为禁言时间
 #discussion 被禁言用户可能是他人、也可能是当前用户
 #discussion 当前用户被禁言、禁言结束时会自动更新 `forbidMe`
 #param user     被禁言用户
 #param fromUser 发起禁言用户
 #param duration 禁言时长
 */
- (BJLObservable)didReceiveForbidUser:(BJLUser *)user
                             fromUser:(nullable BJLUser *)fromUser
                             duration:(NSTimeInterval)duration;

/**
 老师: 对某人禁言
 #discussion `duration` 为禁言时间
 #param user     禁言对象
 #param duration 禁言时长
 #return BJLError:
 BJLErrorCode_invalidUserRole   错误权限，要求老师或助教权限
 */
- (nullable BJLError *)sendForbidUser:(BJLUser *)user
                             duration:(NSTimeInterval)duration;

/**
 老师: 禁言用户列表
 #param forbidUserList   <userID, 剩余禁言时间>
 */
- (BJLObservable)didReceiveForbidUserList:(nullable NSDictionary<NSString *, NSNumber *> *)forbidUserList;

#pragma mark - 私聊消息

/**
 请求私聊的历史消息
 #param user 私聊对象
 #param page  起始消息的页码 (从0开始, 每页20条)
 */
- (nullable BJLError *)loadWhisperMessagesWithTargetUser:(BJLUser *)user page:(NSUInteger)page;

/**
 收到私聊消息
 #param messages 消息
 */
- (BJLObservable)didReceiveWhisperMessages:(NSArray<BJLMessage *> *)messages targetUserNumber:(NSString *)targetUserNumber hasMore:(BOOL)hasMore;

#pragma mark - 快捷回复词

/** 获取配置的聊天快捷回复词 */
- (nullable BJLError *)getQuickReplyWordsWithCompletion:(nullable void (^)(NSArray<NSString *> *_Nullable quickReplyWords, BJLError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
