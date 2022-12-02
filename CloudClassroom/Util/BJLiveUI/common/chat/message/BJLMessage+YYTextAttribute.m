//
//  BJLMessage+YYTextAttribute.m
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/12/30.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLiveCore.h>

#import "BJLMessage+YYTextAttribute.h"
#import "BJLTextImageViewAttachment.h"

@implementation BJLMessage (YYTextAttribute)

- (nullable NSAttributedString *)attributedEmoticonCoreTextWithEmoticonSize:(CGFloat)emoticonSize
                                                                 attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
                                                                  hidePhone:(BOOL)hide
                                                                     cached:(BOOL)cached
                                                                  cachedKey:(nullable NSString *)cachedKey {
    NSAttributedString *attributedString = [self attributedEmoticonStringWithEmoticonSize:emoticonSize
                                                                               attributes:attrs
                                                                                hidePhone:hide
                                                                                   cached:cached
                                                                                cachedKey:cachedKey];
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];

    [attributedString enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:0
                              usingBlock:^(id _Nullable value, NSRange range, BOOL *_Nonnull stop) {
                                  if ([value isKindOfClass:[NSTextAttachment class]]) {
                                      NSTextAttachment *attachment = (NSTextAttachment *)value;
                                      NSURL *imageUrl = [NSURL URLWithString:attachment.bjl_imageUrlString];
                                      if (attachment.bjl_imageUrlString && imageUrl) {
                                          //用空白符占一个字节位置替换原有的表情
                                          unichar objectReplacementChar = 0xFFFC;
                                          NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
                                          NSAttributedString *string = [[NSAttributedString alloc] initWithString:content];

                                          BJLTextImageViewAttachment *imageAttach = [BJLTextImageViewAttachment new];
                                          imageAttach.contentMode = UIViewContentModeScaleAspectFit;
                                          imageAttach.imageURL = imageUrl;
                                          imageAttach.size = CGSizeMake(emoticonSize, emoticonSize);

                                          //图片下载的代理
                                          BJLYYTextRunDelegate *delegate = [BJLYYTextRunDelegate new];
                                          delegate.width = emoticonSize;
                                          delegate.ascent = emoticonSize;
                                          delegate.descent = 3;
                                          CTRunDelegateRef delegateRef = delegate.CTRunDelegate;

                                          BOOL b1 = !(range.location < 0);
                                          BOOL b2 = !((range.location + range.length) > mutableAttributedString.length);
                                          if ((imageAttach != nil) && b1 && b2) {
                                              [mutableAttributedString replaceCharactersInRange:range withAttributedString:string];
                                              [mutableAttributedString bjlyy_setRunDelegate:delegateRef range:range];
                                              [mutableAttributedString bjlyy_setTextAttachment:imageAttach range:range];
                                          }
                                          if (delegate) CFRelease(delegateRef);
                                      }
                                  }
                              }];

    // 链接匹配
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSError *error = NULL;
    // 根据匹配条件，创建了一个正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    if (!regex) {
        NSLog(@"正则创建失败error！= %@", [error localizedDescription]);
    }
    else {
        NSArray *allMatches = [regex matchesInString:mutableAttributedString.string options:NSMatchingReportCompletion range:NSMakeRange(0, mutableAttributedString.string.length)];
        for (NSTextCheckingResult *match in allMatches) {
            NSString *substrinsgForMatch2 = [mutableAttributedString.string substringWithRange:match.range];
            NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:substrinsgForMatch2];

            UIColor *textColor = [mutableAttributedString attribute:NSForegroundColorAttributeName atIndex:match.range.location effectiveRange:NULL];
            UIFont *textFont = [mutableAttributedString attribute:NSFontAttributeName atIndex:match.range.location effectiveRange:NULL];
            textColor = textColor ?: [UIColor blueColor];
            textFont = textFont ?: [UIFont systemFontOfSize:12.0];

            // 设置link属性
            one.bjlyy_font = textFont;
            one.bjlyy_underlineStyle = NSUnderlineStyleSingle;
            one.bjlyy_color = textColor;
            BJLYYTextBorder *border = [BJLYYTextBorder new];
            border.cornerRadius = 3;
            border.insets = UIEdgeInsetsMake(-2, -1, -2, -1);

            BJLYYTextHighlight *highlight = [BJLYYTextHighlight new];
            [highlight setBorder:border];
            [highlight setColor:textColor];
            [one bjlyy_setTextHighlight:highlight range:one.bjlyy_rangeOfAll];
            // 根据range替换字符串
            [mutableAttributedString replaceCharactersInRange:match.range withAttributedString:one];
        }
    }

    return mutableAttributedString.copy;
}

@end
