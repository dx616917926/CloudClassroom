//
//  HXCommonUtil.h
//  HXMinedu
//
//  Created by mac on 2021/3/30.
//

#import <Foundation/Foundation.h>
#import "NSString+md5.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXCommonUtil : NSObject

/**
 *  判断对象是否为空，包括 nil、空字符串、NSNull
 *  @param obj 需要进行判断的对象
 *  @return 对象为空返回YES，否则返回NO
 */
+ (BOOL)isNull:(id)obj;

/**
 字符串编码
 */
+ (NSString *)stringEncoding:(NSString *)str;
/**
 字符串解码
 */
+ (NSString*)strDecodedString:(NSString*)str;

//生成指定长度的字符串
+ (NSString *)generateTradeNO:(NSInteger)len;

/**
 属性化文字
 @param needString             需要属性化的文字
 @param needAttributedDic      添加的属性
 @param content                所有文本
 @param defaultAttributedDic   默认的属性
 @return 属性化文字
 */
+ (NSMutableAttributedString *)getAttributedStringWith:(NSString *)needString needAttributed:(NSDictionary *)needAttributedDic content:(NSString *)content defaultAttributed:(NSDictionary *)defaultAttributedDic;

/**
 属性化文字
 @param needStringArray             需要属性化的文字数组
 @param needAttributedDic      添加的属性
 @param content                所有文本
 @param defaultAttributedDic   默认的属性
 @return 属性化文字
 */
+ (NSMutableAttributedString *)getAttributedStringWithArray:(NSArray<NSString *> *)needStringArray needAttributed:(NSDictionary *)needAttributedDic content:(NSString *)content defaultAttributed:(NSDictionary *)defaultAttributedDic;

/**
 图片质量压缩到某一范围内，如果后面用到多，可以抽成分类或者工具类,这里压缩递减比二分的运行时间长，二分可以限制下限。
 */
+(UIImage *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength;

//限制UITextField输入的长度，包括汉字  一个汉字算2个字符
+(void)limitIncludeChineseTextField:(UITextField *)textField Length:(NSUInteger)kMaxLength;


//限制UITextView输入的长度，包括汉字  一个汉字算2个字符
+(void)limitIncludeChineseTextView:(UITextView *)textview Length:(NSUInteger)kMaxLength;

//判断输入的字符长度 一个汉字算2个字符
+ (NSUInteger)unicodeLengthOfString:(NSString *)text;

//字符串截到对应的长度包括中文 一个汉字算2个字符
+ (NSString *)subStringIncludeChinese:(NSString *)text ToLength:(NSUInteger)length;
////校验身份证是否合法
+(bool)checkIDCardIsOrNotLegalWithIDCard:(NSString *)identityCard;

//根据身份证号性别
+(NSString *)getIdentityCardSex:(NSString *)numberStr;

//根据身份证号获取生日
+(NSString *)birthdayStrFromIdentityCard:(NSString *)numberStr;

//根据view生成image
+ (UIImage *)getMakeImageWithView:(UIView *)view;

/**
 获取当前的日期
 默认日期格式为:yyyy-MM-dd HH-mm
 */
+ (NSString *)getCurrentDateWithFormatterStr:(NSString *)formatterStr;

/**
 将某个时间戳转化成 时间
 默认日期格式为:yyyy-MM-dd HH-mm
 */
+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:( NSString *_Nullable)format;

//获取当前时间戳有两种方法(以秒为单位)
+(NSString *)getNowTimeTimestamp;

#pragma mark -  md5=所有请求参数（除md5外）,按照ASIIC码升序排列，然后通过&拼接，最后加上密钥Md5Key，生成md5值。
+ (NSString *)getMd5String:(NSDictionary *)dic pingKey:(NSString *_Nullable)pingKey;

#pragma mark -  将包含Base64图片的富文本里的图片宽高替换成合适的宽高
+ (NSString *)getReplaceStringFromBase64ImageStr:(NSString *)base64ImageStr maxSize:(CGSize)maxSize;

@end

NS_ASSUME_NONNULL_END
