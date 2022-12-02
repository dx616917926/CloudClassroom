//
//  BJLMessage.h
//  BJLiveCore
//
//  Created by MingLQ on 2016-12-10.
//  Copyright © 2016 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import "BJLUser.h"
#import "BJLEmoticon.h"

NS_ASSUME_NONNULL_BEGIN

/** 聊天消息内容 */
typedef NS_ENUM(NSInteger, BJLMessageType) {
    /** 文字 */
    BJLMessageType_text,
    /** 自定义表情 */
    BJLMessageType_emoticon,
    /** 图片 */
    BJLMessageType_image
};

/** 聊天消息翻译 */
typedef NS_ENUM(NSInteger, BJLMessageTranslateType) {
    /** 中译英 */
    BJLMessageTranslateTypeZHtoEN,
    /** 英译中 */
    BJLMessageTranslateTypeENtoZH
} DEPRECATED_MSG_ATTRIBUTE("使用 BJLMessageLanguageType");

/** 语种列表 */
typedef NS_ENUM(NSInteger, BJLMessageLanguageType) {
    /** 未知语言 */
    BJLMessageLanguageType_NONE,
    /** 中文简体 */
    BJLMessageLanguageType_ZH,
    /** 中文繁体 */
    BJLMessageLanguageType_CHT,
    /** 英语 */
    BJLMessageLanguageType_EN,
    /** 日语 */
    BJLMessageLanguageType_JP,
    /** 越南语 */
    BJLMessageLanguageType_VIE,
    /** 印尼语 */
    BJLMessageLanguageType_ID,
    /** 柬埔寨语 */
    BJLMessageLanguageType_HKM
};

@interface BJLMessage: NSObject <BJLYYModel>

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic, readonly, nullable) NSString *channel;
@property (nonatomic, readonly) NSTimeInterval timeInterval; // seconds since 1970
@property (nonatomic, readonly) BJLUser *fromUser;
@property (nonatomic, readonly) BJLUser *toUser; // 群聊消息：nil；私聊消息：私聊对象
@property (nonatomic, readonly) BJLMessage *reference; //引用的消息

@property (nonatomic, readonly) BJLMessageType type;
@property (nonatomic, readonly, nullable) NSString *text; // BJLMessageType_text
@property (nonatomic, readonly, nullable) BJLEmoticon *emoticon; // BJLMessageType_emoticon
@property (nonatomic, readonly, nullable) NSString *imageURLString; // BJLMessageType_image
@property (nonatomic, readonly) CGFloat imageWidth, imageHeight; // BJLMessageType_image

/** 翻译 */
@property (nonatomic, readonly, nullable) NSString *translation;
/** 翻译源语言 和 目标语言 */
@property (nonatomic, readonly) BJLMessageLanguageType fromType, toType;

/** 聊天 */
+ (nullable NSDictionary *)messageDataWithMessage:(nullable NSString *)message;
+ (nullable NSDictionary *)messageDataWithEmoticonKey:(nullable NSString *)emoticonKey;
+ (nullable NSDictionary *)messageDataWithImageURLString:(nullable NSString *)imageURLString imageSize:(CGSize)imageSize;

+ (nullable NSString *)displayingStringWithData:(nullable NSDictionary *)data;

/** 表情文字混排，默认不处理手机号码 */
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
+ (nullable BJLEmoticon *)singleEmoticonWithText:(NSString *)text;

/** 判断 message 是否是纯表情 */
- (BOOL)isPureEmoji;

/** 翻译 */
- (void)updateTranslationString:(nullable NSString *)translation DEPRECATED_MSG_ATTRIBUTE("使用 updateTranslationString:from:to");

/**
 更新 message 数据
 
 #param from 翻译源语言
 #param to 翻译目标语言
 */
- (void)updateTranslationString:(nullable NSString *)translation from:(BJLMessageLanguageType)from to:(BJLMessageLanguageType)to;

/**
 获取对应语言的代码
 
 如果没有找到, 则返回空
 */
+ (nullable NSString *)languageCodeStringWithType:(BJLMessageLanguageType)type;

/**
 获取指定key对应的语言类型
 */

+ (BJLMessageLanguageType)languageTypeWithCode:(NSString *)code;

/**
 `text`处理手机号码之后的文本 
 */
+ (nullable NSString *)displayContentOfText:(nullable NSString *)text;

@end

NS_ASSUME_NONNULL_END
