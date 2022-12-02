//
//  NSAttributedString+BJLYYText.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 14/10/7.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSAttributedString+BJLYYText.h"
#import "NSParagraphStyle+BJLYYText.h"
#import "BJLYYTextArchiver.h"
#import "BJLYYTextRunDelegate.h"
#import "BJLYYTextUtilities.h"
#import <CoreFoundation/CoreFoundation.h>

// Dummy class for category
@interface NSAttributedString_BJLYYText: NSObject
@end
@implementation NSAttributedString_BJLYYText
@end

static double _BJLYYDeviceSystemVersion() {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

#ifndef kSystemVersion
#define kSystemVersion _BJLYYDeviceSystemVersion()
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif

@implementation NSAttributedString (YYText)

- (NSData *)bjlyy_archiveToData {
    NSData *data = nil;
    @try {
        data = [BJLYYTextArchiver archivedDataWithRootObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return data;
}

+ (instancetype)bjlyy_unarchiveFromData:(NSData *)data {
    NSAttributedString *one = nil;
    @try {
        one = [BJLYYTextUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return one;
}

- (NSDictionary *)bjlyy_attributesAtIndex:(NSUInteger)index {
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attributesAtIndex:index effectiveRange:NULL];
}

- (id)bjlyy_attribute:(NSString *)attributeName atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attribute:attributeName atIndex:index effectiveRange:NULL];
}

- (NSDictionary *)bjlyy_attributes {
    return [self bjlyy_attributesAtIndex:0];
}

- (UIFont *)bjlyy_font {
    return [self bjlyy_fontAtIndex:0];
}

- (UIFont *)bjlyy_fontAtIndex:(NSUInteger)index {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    UIFont *font = [self bjlyy_attribute:NSFontAttributeName atIndex:index];
    if (kSystemVersion <= 6) {
        if (font) {
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) {
                CTFontRef CTFont = (__bridge CTFontRef)(font);
                CFStringRef name = CTFontCopyPostScriptName(CTFont);
                CGFloat size = CTFontGetSize(CTFont);
                if (!name) {
                    font = nil;
                }
                else {
                    font = [UIFont fontWithName:(__bridge NSString *)(name) size:size];
                    CFRelease(name);
                }
            }
        }
    }
    return font;
}

- (NSNumber *)bjlyy_kern {
    return [self bjlyy_kernAtIndex:0];
}

- (NSNumber *)bjlyy_kernAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:NSKernAttributeName atIndex:index];
}

- (UIColor *)bjlyy_color {
    return [self bjlyy_colorAtIndex:0];
}

- (UIColor *)bjlyy_colorAtIndex:(NSUInteger)index {
    UIColor *color = [self bjlyy_attribute:NSForegroundColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self bjlyy_attribute:(NSString *)kCTForegroundColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    if (color && ![color isKindOfClass:[UIColor class]]) {
        if (CFGetTypeID((__bridge CFTypeRef)(color)) == CGColorGetTypeID()) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        }
        else {
            color = nil;
        }
    }
    return color;
}

- (UIColor *)bjlyy_backgroundColor {
    return [self bjlyy_backgroundColorAtIndex:0];
}

- (UIColor *)bjlyy_backgroundColorAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:NSBackgroundColorAttributeName atIndex:index];
}

- (NSNumber *)bjlyy_strokeWidth {
    return [self bjlyy_strokeWidthAtIndex:0];
}

- (NSNumber *)bjlyy_strokeWidthAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:NSStrokeWidthAttributeName atIndex:index];
}

- (UIColor *)bjlyy_strokeColor {
    return [self bjlyy_strokeColorAtIndex:0];
}

- (UIColor *)bjlyy_strokeColorAtIndex:(NSUInteger)index {
    UIColor *color = [self bjlyy_attribute:NSStrokeColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self bjlyy_attribute:(NSString *)kCTStrokeColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSShadow *)bjlyy_shadow {
    return [self bjlyy_shadowAtIndex:0];
}

- (NSShadow *)bjlyy_shadowAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:NSShadowAttributeName atIndex:index];
}

- (NSUnderlineStyle)bjlyy_strikethroughStyle {
    return [self bjlyy_strikethroughStyleAtIndex:0];
}

- (NSUnderlineStyle)bjlyy_strikethroughStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self bjlyy_attribute:NSStrikethroughStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)bjlyy_strikethroughColor {
    return [self bjlyy_strikethroughColorAtIndex:0];
}

- (UIColor *)bjlyy_strikethroughColorAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self bjlyy_attribute:NSStrikethroughColorAttributeName atIndex:index];
    }
    return nil;
}

- (NSUnderlineStyle)bjlyy_underlineStyle {
    return [self bjlyy_underlineStyleAtIndex:0];
}

- (NSUnderlineStyle)bjlyy_underlineStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self bjlyy_attribute:NSUnderlineStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)bjlyy_underlineColor {
    return [self bjlyy_underlineColorAtIndex:0];
}

- (UIColor *)bjlyy_underlineColorAtIndex:(NSUInteger)index {
    UIColor *color = nil;
    if (kSystemVersion >= 7) {
        color = [self bjlyy_attribute:NSUnderlineColorAttributeName atIndex:index];
    }
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self bjlyy_attribute:(NSString *)kCTUnderlineColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSNumber *)bjlyy_ligature {
    return [self bjlyy_ligatureAtIndex:0];
}

- (NSNumber *)bjlyy_ligatureAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:NSLigatureAttributeName atIndex:index];
}

- (NSString *)bjlyy_textEffect {
    return [self bjlyy_textEffectAtIndex:0];
}

- (NSString *)bjlyy_textEffectAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self bjlyy_attribute:NSTextEffectAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)bjlyy_obliqueness {
    return [self bjlyy_obliquenessAtIndex:0];
}

- (NSNumber *)bjlyy_obliquenessAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self bjlyy_attribute:NSObliquenessAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)bjlyy_expansion {
    return [self bjlyy_expansionAtIndex:0];
}

- (NSNumber *)bjlyy_expansionAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self bjlyy_attribute:NSExpansionAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)bjlyy_baselineOffset {
    return [self bjlyy_baselineOffsetAtIndex:0];
}

- (NSNumber *)bjlyy_baselineOffsetAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self bjlyy_attribute:NSBaselineOffsetAttributeName atIndex:index];
    }
    return nil;
}

- (BOOL)bjlyy_verticalGlyphForm {
    return [self bjlyy_verticalGlyphFormAtIndex:0];
}

- (BOOL)bjlyy_verticalGlyphFormAtIndex:(NSUInteger)index {
    NSNumber *num = [self bjlyy_attribute:NSVerticalGlyphFormAttributeName atIndex:index];
    return num.boolValue;
}

- (NSString *)bjlyy_language {
    return [self bjlyy_languageAtIndex:0];
}

- (NSString *)bjlyy_languageAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self bjlyy_attribute:(id)kCTLanguageAttributeName atIndex:index];
    }
    return nil;
}

- (NSArray *)bjlyy_writingDirection {
    return [self bjlyy_writingDirectionAtIndex:0];
}

- (NSArray *)bjlyy_writingDirectionAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:(id)kCTWritingDirectionAttributeName atIndex:index];
}

- (NSParagraphStyle *)bjlyy_paragraphStyle {
    return [self bjlyy_paragraphStyleAtIndex:0];
}

- (NSParagraphStyle *)bjlyy_paragraphStyleAtIndex:(NSUInteger)index {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    NSParagraphStyle *style = [self bjlyy_attribute:NSParagraphStyleAttributeName atIndex:index];
    if (style) {
        if (CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) {
            style = [NSParagraphStyle bjlyy_styleWithCTStyle:(__bridge CTParagraphStyleRef)(style)];
        }
    }
    return style;
}

#define ParagraphAttribute(_attr_)                                \
    NSParagraphStyle *style = self.bjlyy_paragraphStyle;          \
    if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
    return style._attr_;

#define ParagraphAttributeAtIndex(_attr_)                               \
    NSParagraphStyle *style = [self bjlyy_paragraphStyleAtIndex:index]; \
    if (!style) style = [NSParagraphStyle defaultParagraphStyle];       \
    return style._attr_;

- (NSTextAlignment)bjlyy_alignment {
    ParagraphAttribute(alignment);
}

- (NSLineBreakMode)bjlyy_lineBreakMode {
    ParagraphAttribute(lineBreakMode);
}

- (CGFloat)bjlyy_lineSpacing {
    ParagraphAttribute(lineSpacing);
}

- (CGFloat)bjlyy_paragraphSpacing {
    ParagraphAttribute(paragraphSpacing);
}

- (CGFloat)bjlyy_paragraphSpacingBefore {
    ParagraphAttribute(paragraphSpacingBefore);
}

- (CGFloat)bjlyy_firstLineHeadIndent {
    ParagraphAttribute(firstLineHeadIndent);
}

- (CGFloat)bjlyy_headIndent {
    ParagraphAttribute(headIndent);
}

- (CGFloat)bjlyy_tailIndent {
    ParagraphAttribute(tailIndent);
}

- (CGFloat)bjlyy_minimumLineHeight {
    ParagraphAttribute(minimumLineHeight);
}

- (CGFloat)bjlyy_maximumLineHeight {
    ParagraphAttribute(maximumLineHeight);
}

- (CGFloat)bjlyy_lineHeightMultiple {
    ParagraphAttribute(lineHeightMultiple);
}

- (NSWritingDirection)bjlyy_baseWritingDirection {
    ParagraphAttribute(baseWritingDirection);
}

- (float)bjlyy_hyphenationFactor {
    ParagraphAttribute(hyphenationFactor);
}

- (CGFloat)bjlyy_defaultTabInterval {
    if (!kiOS7Later) return 0;
    ParagraphAttribute(defaultTabInterval);
}

- (NSArray *)bjlyy_tabStops {
    if (!kiOS7Later) return nil;
    ParagraphAttribute(tabStops);
}

- (NSTextAlignment)bjlyy_alignmentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(alignment);
}

- (NSLineBreakMode)bjlyy_lineBreakModeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineBreakMode);
}

- (CGFloat)bjlyy_lineSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineSpacing);
}

- (CGFloat)bjlyy_paragraphSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacing);
}

- (CGFloat)bjlyy_paragraphSpacingBeforeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacingBefore);
}

- (CGFloat)bjlyy_firstLineHeadIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(firstLineHeadIndent);
}

- (CGFloat)bjlyy_headIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(headIndent);
}

- (CGFloat)bjlyy_tailIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(tailIndent);
}

- (CGFloat)bjlyy_minimumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(minimumLineHeight);
}

- (CGFloat)bjlyy_maximumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(maximumLineHeight);
}

- (CGFloat)bjlyy_lineHeightMultipleAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineHeightMultiple);
}

- (NSWritingDirection)bjlyy_baseWritingDirectionAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(baseWritingDirection);
}

- (float)bjlyy_hyphenationFactorAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(hyphenationFactor);
}

- (CGFloat)bjlyy_defaultTabIntervalAtIndex:(NSUInteger)index {
    if (!kiOS7Later) return 0;
    ParagraphAttributeAtIndex(defaultTabInterval);
}

- (NSArray *)bjlyy_tabStopsAtIndex:(NSUInteger)index {
    if (!kiOS7Later) return nil;
    ParagraphAttributeAtIndex(tabStops);
}

#undef ParagraphAttribute
#undef ParagraphAttributeAtIndex

- (BJLYYTextShadow *)bjlyy_textShadow {
    return [self bjlyy_textShadowAtIndex:0];
}

- (BJLYYTextShadow *)bjlyy_textShadowAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:BJLYYTextShadowAttributeName atIndex:index];
}

- (BJLYYTextShadow *)bjlyy_textInnerShadow {
    return [self bjlyy_textInnerShadowAtIndex:0];
}

- (BJLYYTextShadow *)bjlyy_textInnerShadowAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:BJLYYTextInnerShadowAttributeName atIndex:index];
}

- (BJLYYTextDecoration *)bjlyy_textUnderline {
    return [self bjlyy_textUnderlineAtIndex:0];
}

- (BJLYYTextDecoration *)bjlyy_textUnderlineAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:BJLYYTextUnderlineAttributeName atIndex:index];
}

- (BJLYYTextDecoration *)bjlyy_textStrikethrough {
    return [self bjlyy_textStrikethroughAtIndex:0];
}

- (BJLYYTextDecoration *)bjlyy_textStrikethroughAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:BJLYYTextStrikethroughAttributeName atIndex:index];
}

- (BJLYYTextBorder *)bjlyy_textBorder {
    return [self bjlyy_textBorderAtIndex:0];
}

- (BJLYYTextBorder *)bjlyy_textBorderAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:BJLYYTextBorderAttributeName atIndex:index];
}

- (BJLYYTextBorder *)bjlyy_textBackgroundBorder {
    return [self bjlyy_textBackgroundBorderAtIndex:0];
}

- (BJLYYTextBorder *)bjlyy_textBackgroundBorderAtIndex:(NSUInteger)index {
    return [self bjlyy_attribute:BJLYYTextBackedStringAttributeName atIndex:index];
}

- (CGAffineTransform)bjlyy_textGlyphTransform {
    return [self bjlyy_textGlyphTransformAtIndex:0];
}

- (CGAffineTransform)bjlyy_textGlyphTransformAtIndex:(NSUInteger)index {
    NSValue *value = [self bjlyy_attribute:BJLYYTextGlyphTransformAttributeName atIndex:index];
    if (!value) return CGAffineTransformIdentity;
    return [value CGAffineTransformValue];
}

- (NSString *)bjlyy_plainTextForRange:(NSRange)range {
    if (range.location == NSNotFound || range.length == NSNotFound) return nil;
    NSMutableString *result = [NSMutableString string];
    if (range.length == 0) return result;
    NSString *string = self.string;
    [self enumerateAttribute:BJLYYTextBackedStringAttributeName inRange:range options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
        BJLYYTextBackedString *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        }
        else {
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}

+ (NSMutableAttributedString *)bjlyy_attachmentStringWithContent:(id)content
                                                     contentMode:(UIViewContentMode)contentMode
                                                           width:(CGFloat)width
                                                          ascent:(CGFloat)ascent
                                                         descent:(CGFloat)descent {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:BJLYYTextAttachmentToken];

    BJLYYTextAttachment *attach = [BJLYYTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr bjlyy_setTextAttachment:attach range:NSMakeRange(0, atr.length)];

    BJLYYTextRunDelegate *delegate = [BJLYYTextRunDelegate new];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr bjlyy_setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);

    return atr;
}

+ (NSMutableAttributedString *)bjlyy_attachmentStringWithContent:(id)content
                                                     contentMode:(UIViewContentMode)contentMode
                                                  attachmentSize:(CGSize)attachmentSize
                                                     alignToFont:(UIFont *)font
                                                       alignment:(BJLYYTextVerticalAlignment)alignment {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:BJLYYTextAttachmentToken];

    BJLYYTextAttachment *attach = [BJLYYTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr bjlyy_setTextAttachment:attach range:NSMakeRange(0, atr.length)];

    BJLYYTextRunDelegate *delegate = [BJLYYTextRunDelegate new];
    delegate.width = attachmentSize.width;
    switch (alignment) {
        case BJLYYTextVerticalAlignmentTop: {
            delegate.ascent = font.ascender;
            delegate.descent = attachmentSize.height - font.ascender;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case BJLYYTextVerticalAlignmentCenter: {
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            delegate.ascent = attachmentSize.height * 0.5 + yOffset;
            delegate.descent = attachmentSize.height - delegate.ascent;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case BJLYYTextVerticalAlignmentBottom: {
            delegate.ascent = attachmentSize.height + font.descender;
            delegate.descent = -font.descender;
            if (delegate.ascent < 0) {
                delegate.ascent = 0;
                delegate.descent = attachmentSize.height;
            }
        } break;
        default: {
            delegate.ascent = attachmentSize.height;
            delegate.descent = 0;
        } break;
    }

    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr bjlyy_setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);

    return atr;
}

+ (NSMutableAttributedString *)bjlyy_attachmentStringWithEmojiImage:(UIImage *)image
                                                           fontSize:(CGFloat)fontSize {
    if (!image || fontSize <= 0) return nil;

    BOOL hasAnim = NO;
    if (image.images.count > 1) {
        hasAnim = YES;
    }
    else if (NSProtocolFromString(@"YYAnimatedImage") &&
             [image conformsToProtocol:NSProtocolFromString(@"YYAnimatedImage")]) {
        NSNumber *frameCount = [image valueForKey:@"animatedImageFrameCount"];
        if (frameCount.intValue > 1) hasAnim = YES;
    }

    CGFloat ascent = BJLYYTextEmojiGetAscentWithFontSize(fontSize);
    CGFloat descent = BJLYYTextEmojiGetDescentWithFontSize(fontSize);
    CGRect bounding = BJLYYTextEmojiGetGlyphBoundingRectWithFontSize(fontSize);

    BJLYYTextRunDelegate *delegate = [BJLYYTextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width + 2 * bounding.origin.x;

    BJLYYTextAttachment *attachment = [BJLYYTextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), bounding.origin.x, descent + bounding.origin.y, bounding.origin.x);
    if (hasAnim) {
        Class imageClass = NSClassFromString(@"YYAnimatedImageView");
        if (!imageClass) imageClass = [UIImageView class];
        UIImageView *view = (id)[imageClass new];
        view.frame = bounding;
        view.image = image;
        view.contentMode = UIViewContentModeScaleAspectFit;
        attachment.content = view;
    }
    else {
        attachment.content = image;
    }

    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:BJLYYTextAttachmentToken];
    [atr bjlyy_setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr bjlyy_setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);

    return atr;
}

- (NSRange)bjlyy_rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (BOOL)bjlyy_isSharedAttributesInAllRange {
    __block BOOL shared = YES;
    __block NSDictionary *firstAttrs = nil;
    [self enumerateAttributesInRange:self.bjlyy_rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (range.location == 0) {
            firstAttrs = attrs;
        }
        else {
            if (firstAttrs.count != attrs.count) {
                shared = NO;
                *stop = YES;
            }
            else if (firstAttrs) {
                if (![firstAttrs isEqualToDictionary:attrs]) {
                    shared = NO;
                    *stop = YES;
                }
            }
        }
    }];
    return shared;
}

- (BOOL)bjlyy_canDrawWithUIKit {
    static NSMutableSet *failSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        failSet = [NSMutableSet new];
        [failSet addObject:(id)kCTGlyphInfoAttributeName];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [failSet addObject:(id)kCTCharacterShapeAttributeName];
#pragma clang diagnostic pop
        if (kiOS7Later) {
            [failSet addObject:(id)kCTLanguageAttributeName];
        }
        [failSet addObject:(id)kCTRunDelegateAttributeName];
        [failSet addObject:(id)kCTBaselineClassAttributeName];
        [failSet addObject:(id)kCTBaselineInfoAttributeName];
        [failSet addObject:(id)kCTBaselineReferenceInfoAttributeName];
        if (kiOS8Later) {
            [failSet addObject:(id)kCTRubyAnnotationAttributeName];
        }
        [failSet addObject:BJLYYTextShadowAttributeName];
        [failSet addObject:BJLYYTextInnerShadowAttributeName];
        [failSet addObject:BJLYYTextUnderlineAttributeName];
        [failSet addObject:BJLYYTextStrikethroughAttributeName];
        [failSet addObject:BJLYYTextBorderAttributeName];
        [failSet addObject:BJLYYTextBackgroundBorderAttributeName];
        [failSet addObject:BJLYYTextBlockBorderAttributeName];
        [failSet addObject:BJLYYTextAttachmentAttributeName];
        [failSet addObject:BJLYYTextHighlightAttributeName];
        [failSet addObject:BJLYYTextGlyphTransformAttributeName];
    });

#define Fail         \
    {                \
        result = NO; \
        *stop = YES; \
        return;      \
    }
    __block BOOL result = YES;
    [self enumerateAttributesInRange:self.bjlyy_rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs.count == 0) return;
        for (NSString *str in attrs.allKeys) {
            if ([failSet containsObject:str]) Fail;
        }
        if (!kiOS7Later) {
            UIFont *font = attrs[NSFontAttributeName];
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) Fail;
        }
        if (attrs[(id)kCTForegroundColorAttributeName] && !attrs[NSForegroundColorAttributeName]) Fail;
        if (attrs[(id)kCTStrokeColorAttributeName] && !attrs[NSStrokeColorAttributeName]) Fail;
        if (attrs[(id)kCTUnderlineColorAttributeName]) {
            if (!kiOS7Later) Fail;
            if (!attrs[NSUnderlineColorAttributeName]) Fail;
        }
        NSParagraphStyle *style = attrs[NSParagraphStyleAttributeName];
        if (style && CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) Fail;
    }];
    return result;
#undef Fail
}

@end

@implementation NSMutableAttributedString (YYText)

- (void)bjlyy_setAttributes:(NSDictionary *)attributes {
    [self setBjlyy_attributes:attributes];
}

- (void)setBjlyy_attributes:(NSDictionary *)attributes {
    if (attributes == (id)[NSNull null]) attributes = nil;
    [self setAttributes:@{} range:NSMakeRange(0, self.length)];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self bjlyy_setAttribute:key value:obj];
    }];
}

- (void)bjlyy_setAttribute:(NSString *)name value:(id)value {
    [self bjlyy_setAttribute:name value:value range:NSMakeRange(0, self.length)];
}

- (void)bjlyy_setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value])
        [self addAttribute:name value:value range:range];
    else
        [self removeAttribute:name range:range];
}

- (void)bjlyy_removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

#pragma mark - Property Setter

- (void)setBjlyy_font:(UIFont *)font {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self bjlyy_setFont:font range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_kern:(NSNumber *)kern {
    [self bjlyy_setKern:kern range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_color:(UIColor *)color {
    [self bjlyy_setColor:color range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_backgroundColor:(UIColor *)backgroundColor {
    [self bjlyy_setBackgroundColor:backgroundColor range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_strokeWidth:(NSNumber *)strokeWidth {
    [self bjlyy_setStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_strokeColor:(UIColor *)strokeColor {
    [self bjlyy_setStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_shadow:(NSShadow *)shadow {
    [self bjlyy_setShadow:shadow range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_strikethroughStyle:(NSUnderlineStyle)strikethroughStyle {
    [self bjlyy_setStrikethroughStyle:strikethroughStyle range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_strikethroughColor:(UIColor *)strikethroughColor {
    [self bjlyy_setStrikethroughColor:strikethroughColor range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_underlineStyle:(NSUnderlineStyle)underlineStyle {
    [self bjlyy_setUnderlineStyle:underlineStyle range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_underlineColor:(UIColor *)underlineColor {
    [self bjlyy_setUnderlineColor:underlineColor range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_ligature:(NSNumber *)ligature {
    [self bjlyy_setLigature:ligature range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textEffect:(NSString *)textEffect {
    [self bjlyy_setTextEffect:textEffect range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_obliqueness:(NSNumber *)obliqueness {
    [self bjlyy_setObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_expansion:(NSNumber *)expansion {
    [self bjlyy_setExpansion:expansion range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_baselineOffset:(NSNumber *)baselineOffset {
    [self bjlyy_setBaselineOffset:baselineOffset range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_verticalGlyphForm:(BOOL)verticalGlyphForm {
    [self bjlyy_setVerticalGlyphForm:verticalGlyphForm range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_language:(NSString *)language {
    [self bjlyy_setLanguage:language range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_writingDirection:(NSArray *)writingDirection {
    [self bjlyy_setWritingDirection:writingDirection range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self bjlyy_setParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_alignment:(NSTextAlignment)alignment {
    [self bjlyy_setAlignment:alignment range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_baseWritingDirection:(NSWritingDirection)baseWritingDirection {
    [self bjlyy_setBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_lineSpacing:(CGFloat)lineSpacing {
    [self bjlyy_setLineSpacing:lineSpacing range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_paragraphSpacing:(CGFloat)paragraphSpacing {
    [self bjlyy_setParagraphSpacing:paragraphSpacing range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_paragraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    [self bjlyy_setParagraphSpacing:paragraphSpacingBefore range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_firstLineHeadIndent:(CGFloat)firstLineHeadIndent {
    [self bjlyy_setFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_headIndent:(CGFloat)headIndent {
    [self bjlyy_setHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_tailIndent:(CGFloat)tailIndent {
    [self bjlyy_setTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_lineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self bjlyy_setLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_minimumLineHeight:(CGFloat)minimumLineHeight {
    [self bjlyy_setMinimumLineHeight:minimumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_maximumLineHeight:(CGFloat)maximumLineHeight {
    [self bjlyy_setMaximumLineHeight:maximumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_lineHeightMultiple:(CGFloat)lineHeightMultiple {
    [self bjlyy_setLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_hyphenationFactor:(float)hyphenationFactor {
    [self bjlyy_setHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_defaultTabInterval:(CGFloat)defaultTabInterval {
    [self bjlyy_setDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_tabStops:(NSArray *)tabStops {
    [self bjlyy_setTabStops:tabStops range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textShadow:(BJLYYTextShadow *)textShadow {
    [self bjlyy_setTextShadow:textShadow range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textInnerShadow:(BJLYYTextShadow *)textInnerShadow {
    [self bjlyy_setTextInnerShadow:textInnerShadow range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textUnderline:(BJLYYTextDecoration *)textUnderline {
    [self bjlyy_setTextUnderline:textUnderline range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textStrikethrough:(BJLYYTextDecoration *)textStrikethrough {
    [self bjlyy_setTextStrikethrough:textStrikethrough range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textBorder:(BJLYYTextBorder *)textBorder {
    [self bjlyy_setTextBorder:textBorder range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textBackgroundBorder:(BJLYYTextBorder *)textBackgroundBorder {
    [self bjlyy_setTextBackgroundBorder:textBackgroundBorder range:NSMakeRange(0, self.length)];
}

- (void)setBjlyy_textGlyphTransform:(CGAffineTransform)textGlyphTransform {
    [self bjlyy_setTextGlyphTransform:textGlyphTransform range:NSMakeRange(0, self.length)];
}

#pragma mark - Range Setter

- (void)bjlyy_setFont:(UIFont *)font range:(NSRange)range {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self bjlyy_setAttribute:NSFontAttributeName value:font range:range];
}

- (void)bjlyy_setKern:(NSNumber *)kern range:(NSRange)range {
    [self bjlyy_setAttribute:NSKernAttributeName value:kern range:range];
}

- (void)bjlyy_setColor:(UIColor *)color range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
    [self bjlyy_setAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)bjlyy_setBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self bjlyy_setAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)bjlyy_setStrokeWidth:(NSNumber *)strokeWidth range:(NSRange)range {
    [self bjlyy_setAttribute:NSStrokeWidthAttributeName value:strokeWidth range:range];
}

- (void)bjlyy_setStrokeColor:(UIColor *)strokeColor range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTStrokeColorAttributeName value:(id)strokeColor.CGColor range:range];
    [self bjlyy_setAttribute:NSStrokeColorAttributeName value:strokeColor range:range];
}

- (void)bjlyy_setShadow:(NSShadow *)shadow range:(NSRange)range {
    [self bjlyy_setAttribute:NSShadowAttributeName value:shadow range:range];
}

- (void)bjlyy_setStrikethroughStyle:(NSUnderlineStyle)strikethroughStyle range:(NSRange)range {
    NSNumber *style = strikethroughStyle == 0 ? nil : @(strikethroughStyle);
    [self bjlyy_setAttribute:NSStrikethroughStyleAttributeName value:style range:range];
}

- (void)bjlyy_setStrikethroughColor:(UIColor *)strikethroughColor range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSStrikethroughColorAttributeName value:strikethroughColor range:range];
    }
}

- (void)bjlyy_setUnderlineStyle:(NSUnderlineStyle)underlineStyle range:(NSRange)range {
    NSNumber *style = underlineStyle == 0 ? nil : @(underlineStyle);
    [self bjlyy_setAttribute:NSUnderlineStyleAttributeName value:style range:range];
}

- (void)bjlyy_setUnderlineColor:(UIColor *)underlineColor range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTUnderlineColorAttributeName value:(id)underlineColor.CGColor range:range];
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    }
}

- (void)bjlyy_setLigature:(NSNumber *)ligature range:(NSRange)range {
    [self bjlyy_setAttribute:NSLigatureAttributeName value:ligature range:range];
}

- (void)bjlyy_setTextEffect:(NSString *)textEffect range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSTextEffectAttributeName value:textEffect range:range];
    }
}

- (void)bjlyy_setObliqueness:(NSNumber *)obliqueness range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSObliquenessAttributeName value:obliqueness range:range];
    }
}

- (void)bjlyy_setExpansion:(NSNumber *)expansion range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSExpansionAttributeName value:expansion range:range];
    }
}

- (void)bjlyy_setBaselineOffset:(NSNumber *)baselineOffset range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSBaselineOffsetAttributeName value:baselineOffset range:range];
    }
}

- (void)bjlyy_setVerticalGlyphForm:(BOOL)verticalGlyphForm range:(NSRange)range {
    NSNumber *v = verticalGlyphForm ? @(YES) : nil;
    [self bjlyy_setAttribute:NSVerticalGlyphFormAttributeName value:v range:range];
}

- (void)bjlyy_setLanguage:(NSString *)language range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:(id)kCTLanguageAttributeName value:language range:range];
    }
}

- (void)bjlyy_setWritingDirection:(NSArray *)writingDirection range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTWritingDirectionAttributeName value:writingDirection range:range];
}

- (void)bjlyy_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self bjlyy_setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

#define ParagraphStyleSet(_attr_)                                                                                      \
    [self enumerateAttribute:NSParagraphStyleAttributeName                                                             \
                     inRange:range                                                                                     \
                     options:kNilOptions                                                                               \
                  usingBlock:^(NSParagraphStyle * value, NSRange subRange, BOOL * stop) {                              \
                      NSMutableParagraphStyle *style = nil;                                                            \
                      if (value) {                                                                                     \
                          if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) {               \
                              value = [NSParagraphStyle bjlyy_styleWithCTStyle:(__bridge CTParagraphStyleRef)(value)]; \
                          }                                                                                            \
                          if (value._attr_ == _attr_) return;                                                          \
                          if ([value isKindOfClass:[NSMutableParagraphStyle class]]) {                                 \
                              style = (id)value;                                                                       \
                          }                                                                                            \
                          else {                                                                                       \
                              style = value.mutableCopy;                                                               \
                          }                                                                                            \
                      }                                                                                                \
                      else {                                                                                           \
                          if ([NSParagraphStyle defaultParagraphStyle]._attr_ == _attr_) return;                       \
                          style = [NSParagraphStyle defaultParagraphStyle].mutableCopy;                                \
                      }                                                                                                \
                      style._attr_ = _attr_;                                                                           \
                      [self bjlyy_setParagraphStyle:style range:subRange];                                             \
                  }];

- (void)bjlyy_setAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    ParagraphStyleSet(alignment);
}

- (void)bjlyy_setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    ParagraphStyleSet(baseWritingDirection);
}

- (void)bjlyy_setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    ParagraphStyleSet(lineSpacing);
}

- (void)bjlyy_setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacing);
}

- (void)bjlyy_setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacingBefore);
}

- (void)bjlyy_setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    ParagraphStyleSet(firstLineHeadIndent);
}

- (void)bjlyy_setHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    ParagraphStyleSet(headIndent);
}

- (void)bjlyy_setTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    ParagraphStyleSet(tailIndent);
}

- (void)bjlyy_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    ParagraphStyleSet(lineBreakMode);
}

- (void)bjlyy_setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    ParagraphStyleSet(minimumLineHeight);
}

- (void)bjlyy_setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    ParagraphStyleSet(maximumLineHeight);
}

- (void)bjlyy_setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    ParagraphStyleSet(lineHeightMultiple);
}

- (void)bjlyy_setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    ParagraphStyleSet(hyphenationFactor);
}

- (void)bjlyy_setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    if (!kiOS7Later) return;
    ParagraphStyleSet(defaultTabInterval);
}

- (void)bjlyy_setTabStops:(NSArray *)tabStops range:(NSRange)range {
    if (!kiOS7Later) return;
    ParagraphStyleSet(tabStops);
}

#undef ParagraphStyleSet

- (void)bjlyy_setSuperscript:(NSNumber *)superscript range:(NSRange)range {
    if ([superscript isEqualToNumber:@(0)]) {
        superscript = nil;
    }
    [self bjlyy_setAttribute:(id)kCTSuperscriptAttributeName value:superscript range:range];
}

- (void)bjlyy_setGlyphInfo:(CTGlyphInfoRef)glyphInfo range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTGlyphInfoAttributeName value:(__bridge id)glyphInfo range:range];
}

- (void)bjlyy_setCharacterShape:(NSNumber *)characterShape range:(NSRange)range {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self bjlyy_setAttribute:(id)kCTCharacterShapeAttributeName value:characterShape range:range];
#pragma clang diagnostic pop
}

- (void)bjlyy_setRunDelegate:(CTRunDelegateRef)runDelegate range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
}

- (void)bjlyy_setBaselineClass:(CFStringRef)baselineClass range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTBaselineClassAttributeName value:(__bridge id)baselineClass range:range];
}

- (void)bjlyy_setBaselineInfo:(CFDictionaryRef)baselineInfo range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTBaselineInfoAttributeName value:(__bridge id)baselineInfo range:range];
}

- (void)bjlyy_setBaselineReferenceInfo:(CFDictionaryRef)referenceInfo range:(NSRange)range {
    [self bjlyy_setAttribute:(id)kCTBaselineReferenceInfoAttributeName value:(__bridge id)referenceInfo range:range];
}

- (void)bjlyy_setRubyAnnotation:(CTRubyAnnotationRef)ruby range:(NSRange)range {
    if (kSystemVersion >= 8) {
        [self bjlyy_setAttribute:(id)kCTRubyAnnotationAttributeName value:(__bridge id)ruby range:range];
    }
}

- (void)bjlyy_setAttachment:(NSTextAttachment *)attachment range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSAttachmentAttributeName value:attachment range:range];
    }
}

- (void)bjlyy_setLink:(id)link range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self bjlyy_setAttribute:NSLinkAttributeName value:link range:range];
    }
}

- (void)bjlyy_setTextBackedString:(BJLYYTextBackedString *)textBackedString range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextBackedStringAttributeName value:textBackedString range:range];
}

- (void)bjlyy_setTextBinding:(BJLYYTextBinding *)textBinding range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextBindingAttributeName value:textBinding range:range];
}

- (void)bjlyy_setTextShadow:(BJLYYTextShadow *)textShadow range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextShadowAttributeName value:textShadow range:range];
}

- (void)bjlyy_setTextInnerShadow:(BJLYYTextShadow *)textInnerShadow range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextInnerShadowAttributeName value:textInnerShadow range:range];
}

- (void)bjlyy_setTextUnderline:(BJLYYTextDecoration *)textUnderline range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextUnderlineAttributeName value:textUnderline range:range];
}

- (void)bjlyy_setTextStrikethrough:(BJLYYTextDecoration *)textStrikethrough range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextStrikethroughAttributeName value:textStrikethrough range:range];
}

- (void)bjlyy_setTextBorder:(BJLYYTextBorder *)textBorder range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextBorderAttributeName value:textBorder range:range];
}

- (void)bjlyy_setTextBackgroundBorder:(BJLYYTextBorder *)textBackgroundBorder range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextBackgroundBorderAttributeName value:textBackgroundBorder range:range];
}

- (void)bjlyy_setTextAttachment:(BJLYYTextAttachment *)textAttachment range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextAttachmentAttributeName value:textAttachment range:range];
}

- (void)bjlyy_setTextHighlight:(BJLYYTextHighlight *)textHighlight range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextHighlightAttributeName value:textHighlight range:range];
}

- (void)bjlyy_setTextBlockBorder:(BJLYYTextBorder *)textBlockBorder range:(NSRange)range {
    [self bjlyy_setAttribute:BJLYYTextBlockBorderAttributeName value:textBlockBorder range:range];
}

- (void)bjlyy_setTextRubyAnnotation:(BJLYYTextRubyAnnotation *)ruby range:(NSRange)range {
    if (kiOS8Later) {
        CTRubyAnnotationRef rubyRef = [ruby CTRubyAnnotation];
        [self bjlyy_setRubyAnnotation:rubyRef range:range];
        if (rubyRef) CFRelease(rubyRef);
    }
}

- (void)bjlyy_setTextGlyphTransform:(CGAffineTransform)textGlyphTransform range:(NSRange)range {
    NSValue *value = CGAffineTransformIsIdentity(textGlyphTransform) ? nil : [NSValue valueWithCGAffineTransform:textGlyphTransform];
    [self bjlyy_setAttribute:BJLYYTextGlyphTransformAttributeName value:value range:range];
}

- (void)bjlyy_setTextHighlightRange:(NSRange)range
                              color:(UIColor *)color
                    backgroundColor:(UIColor *)backgroundColor
                           userInfo:(NSDictionary *)userInfo
                          tapAction:(BJLYYTextAction)tapAction
                    longPressAction:(BJLYYTextAction)longPressAction {
    BJLYYTextHighlight *highlight = [BJLYYTextHighlight highlightWithBackgroundColor:backgroundColor];
    highlight.userInfo = userInfo;
    highlight.tapAction = tapAction;
    highlight.longPressAction = longPressAction;
    if (color) [self bjlyy_setColor:color range:range];
    [self bjlyy_setTextHighlight:highlight range:range];
}

- (void)bjlyy_setTextHighlightRange:(NSRange)range
                              color:(UIColor *)color
                    backgroundColor:(UIColor *)backgroundColor
                          tapAction:(BJLYYTextAction)tapAction {
    [self bjlyy_setTextHighlightRange:range
                                color:color
                      backgroundColor:backgroundColor
                             userInfo:nil
                            tapAction:tapAction
                      longPressAction:nil];
}

- (void)bjlyy_setTextHighlightRange:(NSRange)range
                              color:(UIColor *)color
                    backgroundColor:(UIColor *)backgroundColor
                           userInfo:(NSDictionary *)userInfo {
    [self bjlyy_setTextHighlightRange:range
                                color:color
                      backgroundColor:backgroundColor
                             userInfo:userInfo
                            tapAction:nil
                      longPressAction:nil];
}

- (void)bjlyy_insertString:(NSString *)string atIndex:(NSUInteger)location {
    [self replaceCharactersInRange:NSMakeRange(location, 0) withString:string];
    [self bjlyy_removeDiscontinuousAttributesInRange:NSMakeRange(location, string.length)];
}

- (void)bjlyy_appendString:(NSString *)string {
    NSUInteger length = self.length;
    [self replaceCharactersInRange:NSMakeRange(length, 0) withString:string];
    [self bjlyy_removeDiscontinuousAttributesInRange:NSMakeRange(length, string.length)];
}

- (void)bjlyy_setClearColorToJoinedEmoji {
    NSString *str = self.string;
    if (str.length < 8) return;

    // Most string do not contains the joined-emoji, test the joiner first.
    BOOL containsJoiner = NO;
    {
        CFStringRef cfStr = (__bridge CFStringRef)str;
        BOOL needFree = NO;
        UniChar *chars = NULL;
        chars = (void *)CFStringGetCharactersPtr(cfStr);
        if (!chars) {
            chars = malloc(str.length * sizeof(UniChar));
            if (chars) {
                needFree = YES;
                CFStringGetCharacters(cfStr, CFRangeMake(0, str.length), chars);
            }
        }
        if (!chars) { // fail to get unichar..
            containsJoiner = YES;
        }
        else {
            for (int i = 0, max = (int)str.length; i < max; i++) {
                if (chars[i] == 0x200D) { // 'ZERO WIDTH JOINER' (U+200D)
                    containsJoiner = YES;
                    break;
                }
            }
            if (needFree) free(chars);
        }
    }
    if (!containsJoiner) return;

    // NSRegularExpression is designed to be immutable and thread safe.
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((👨‍👩‍👧‍👦|👨‍👩‍👦‍👦|👨‍👩‍👧‍👧|👩‍👩‍👧‍👦|👩‍👩‍👦‍👦|👩‍👩‍👧‍👧|👨‍👨‍👧‍👦|👨‍👨‍👦‍👦|👨‍👨‍👧‍👧)+|(👨‍👩‍👧|👩‍👩‍👦|👩‍👩‍👧|👨‍👨‍👦|👨‍👨‍👧))" options:kNilOptions error:nil];
    });

    UIColor *clear = [UIColor clearColor];
    [regex enumerateMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self bjlyy_setColor:clear range:result.range];
    }];
}

- (void)bjlyy_removeDiscontinuousAttributesInRange:(NSRange)range {
    NSArray *keys = [NSMutableAttributedString bjlyy_allDiscontinuousAttributeKeys];
    for (NSString *key in keys) {
        [self removeAttribute:key range:range];
    }
}

+ (NSArray *)bjlyy_allDiscontinuousAttributeKeys {
    static NSMutableArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[(id)kCTSuperscriptAttributeName,
            (id)kCTRunDelegateAttributeName,
            BJLYYTextBackedStringAttributeName,
            BJLYYTextBindingAttributeName,
            BJLYYTextAttachmentAttributeName]
                   .mutableCopy;
        if (kiOS8Later) {
            [keys addObject:(id)kCTRubyAnnotationAttributeName];
        }
        if (kiOS7Later) {
            [keys addObject:NSAttachmentAttributeName];
        }
    });
    return keys;
}

@end
