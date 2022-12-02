//
//  BJVMessage.h
//  Pods
//
//  Created by 辛亚鹏 on 2017/1/18.
//  Copyright © 2017年 Baijia Cloud. All rights reserved.
//  聊天信息

#import <Foundation/Foundation.h>

#import "BJVUser.h"
#import "BJVEmoticon.h"

NS_ASSUME_NONNULL_BEGIN

/** 聊天消息内容 */
typedef NS_ENUM(NSInteger, BJVMessageType) {
    /** 文字 */
    BJVMessageType_text,
    /** 自定义表情 */
    BJVMessageType_emoticon,
    /** 图片 */
    BJVMessageType_image
};

/** 聊天消息翻译 */
typedef NS_ENUM(NSInteger, BJVMessageTranslateType) {
    /** 中译英 */
    BJVMessageTranslateTypeZHtoEN,
    /** 英译中 */
    BJVMessageTranslateTypeENtoZH
};

@interface BJVMessage: NSObject <BJLYYModel>

@property (readonly, nonatomic) NSInteger offsetTimestamp;

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic, readonly, nullable) NSString *channel;
@property (nonatomic, readonly) NSTimeInterval timeInterval; // seconds since 1970
@property (nonatomic, readonly) BJVUser *fromUser;
@property (nonatomic, readonly) BJVUser *toUser; // 群聊消息：nil；私聊消息：私聊对象
@property (nonatomic, readonly) BJVMessage *reference; //引用的消息

@property (nonatomic, readonly) BJVMessageType type;
@property (nonatomic, readonly, nullable) NSString *text; // BJVMessageType_text
@property (nonatomic, readonly, nullable) BJVEmoticon *emoticon; // BJVMessageType_emoticon
@property (nonatomic, readonly, nullable) NSString *imageURLString; // BJVMessageType_image
@property (nonatomic, readonly) CGFloat imageWidth, imageHeight; // BJVMessageType_image

/** 翻译 */
@property (nonatomic, readonly, nullable) NSString *translation;

/** 聊天 */
+ (nullable NSDictionary *)messageDataWithMessage:(nullable NSString *)message;
+ (nullable NSDictionary *)messageDataWithEmoticonKey:(nullable NSString *)emoticonKey;
+ (nullable NSDictionary *)messageDataWithImageURLString:(nullable NSString *)imageURLString imageSize:(CGSize)imageSize;

+ (nullable NSString *)displayingStringWithData:(nullable NSDictionary *)data;

/** 表情文字混排 */
- (NSAttributedString *)attributedEmoticonStringWithEmoticonSize:(CGFloat)emoticonSize
                                                      attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
                                                          cached:(BOOL)cached
                                                       cachedKey:(nullable NSString *)cachedKey;
/** 表情文字混排，可处理是否隐藏手机号码 */
- (NSAttributedString *)attributedEmoticonStringWithEmoticonSize:(CGFloat)emoticonSize
                                                      attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
                                                       hidePhone:(BOOL)hide
                                                          cached:(BOOL)cached
                                                       cachedKey:(nullable NSString *)cachedKey;
- (NSString *)textExceptEmoticon;
+ (nullable BJVEmoticon *)singleEmoticonWithText:(NSString *)text;

/** 翻译 */
- (void)updateTranslationString:(nullable NSString *)translation;

@end

NS_ASSUME_NONNULL_END
