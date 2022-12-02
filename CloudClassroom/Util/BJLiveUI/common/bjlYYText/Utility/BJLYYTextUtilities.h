//
//  YYTextUtilities.h
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/6.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#ifndef YYTEXT_CLAMP // return the clamped value
#define YYTEXT_CLAMP(_x_, _low_, _high_) (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef YYTEXT_SWAP // swap two value
#define YYTEXT_SWAP(_a_, _b_)          \
    do {                               \
        __typeof__(_a_) _tmp_ = (_a_); \
        (_a_) = (_b_);                 \
        (_b_) = _tmp_;                 \
    }                                  \
    while (0)
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Whether the character is 'line break char':
 U+000D (\\r or CR)
 U+2028 (Unicode line separator)
 U+000A (\\n or LF)
 U+2029 (Unicode paragraph separator)
 
 @param c  A character
 @return YES or NO.
 */
static inline BOOL BJLYYTextIsLinebreakChar(unichar c) {
    switch (c) {
        case 0x000D:
        case 0x2028:
        case 0x000A:
        case 0x2029:
            return YES;
        default:
            return NO;
    }
}

/**
 Whether the string is a 'line break':
 U+000D (\\r or CR)
 U+2028 (Unicode line separator)
 U+000A (\\n or LF)
 U+2029 (Unicode paragraph separator)
 \\r\\n, in that order (also known as CRLF)
 
 @param str A string
 @return YES or NO.
 */
static inline BOOL BJLYYTextIsLinebreakString(NSString *_Nullable str) {
    if (str.length > 2 || str.length == 0) return NO;
    if (str.length == 1) {
        unichar c = [str characterAtIndex:0];
        return BJLYYTextIsLinebreakChar(c);
    }
    else {
        return ([str characterAtIndex:0] == '\r') && ([str characterAtIndex:1] == '\n');
    }
}

/**
 If the string has a 'line break' suffix, return the 'line break' length.
 
 @param str  A string.
 @return The length of the tail line break: 0, 1 or 2.
 */
static inline NSUInteger BJLYYTextLinebreakTailLength(NSString *_Nullable str) {
    if (str.length >= 2) {
        unichar c2 = [str characterAtIndex:str.length - 1];
        if (BJLYYTextIsLinebreakChar(c2)) {
            unichar c1 = [str characterAtIndex:str.length - 2];
            if (c1 == '\r' && c2 == '\n')
                return 2;
            else
                return 1;
        }
        else {
            return 0;
        }
    }
    else if (str.length == 1) {
        return BJLYYTextIsLinebreakChar([str characterAtIndex:0]) ? 1 : 0;
    }
    else {
        return 0;
    }
}

/**
 Convert `UIDataDetectorTypes` to `NSTextCheckingType`.
 
 @param types  The `UIDataDetectorTypes` type.
 @return The `NSTextCheckingType` type.
 */
static inline NSTextCheckingType BJLYYTextNSTextCheckingTypeFromUIDataDetectorType(UIDataDetectorTypes types) {
    NSTextCheckingType t = 0;
    if (types & UIDataDetectorTypePhoneNumber) t |= NSTextCheckingTypePhoneNumber;
    if (types & UIDataDetectorTypeLink) t |= NSTextCheckingTypeLink;
    if (types & UIDataDetectorTypeAddress) t |= NSTextCheckingTypeAddress;
    if (types & UIDataDetectorTypeCalendarEvent) t |= NSTextCheckingTypeDate;
    return t;
}

/**
 Whether the font is `AppleColorEmoji` font.
 
 @param font  A font.
 @return YES: the font is Emoji, NO: the font is not Emoji.
 */
static inline BOOL BJLYYTextUIFontIsEmoji(UIFont *font) {
    return [font.fontName isEqualToString:@"AppleColorEmoji"];
}

/**
 Whether the font is `AppleColorEmoji` font.
 
 @param font  A font.
 @return YES: the font is Emoji, NO: the font is not Emoji.
 */
static inline BOOL BJLYYTextCTFontIsEmoji(CTFontRef font) {
    BOOL isEmoji = NO;
    CFStringRef name = CTFontCopyPostScriptName(font);
    if (name && CFEqual(CFSTR("AppleColorEmoji"), name)) isEmoji = YES;
    if (name) CFRelease(name);
    return isEmoji;
}

/**
 Whether the font is `AppleColorEmoji` font.
 
 @param font  A font.
 @return YES: the font is Emoji, NO: the font is not Emoji.
 */
static inline BOOL BJLYYTextCGFontIsEmoji(CGFontRef font) {
    BOOL isEmoji = NO;
    CFStringRef name = CGFontCopyPostScriptName(font);
    if (name && CFEqual(CFSTR("AppleColorEmoji"), name)) isEmoji = YES;
    if (name) CFRelease(name);
    return isEmoji;
}

/**
 Whether the font contains color bitmap glyphs.
 
 @discussion Only `AppleColorEmoji` contains color bitmap glyphs in iOS system fonts.
 @param font  A font.
 @return YES: the font contains color bitmap glyphs, NO: the font has no color bitmap glyph.
 */
static inline BOOL BJLYYTextCTFontContainsColorBitmapGlyphs(CTFontRef font) {
    return (CTFontGetSymbolicTraits(font) & kCTFontTraitColorGlyphs) != 0;
}

/**
 Whether the glyph is bitmap.
 
 @param font  The glyph's font.
 @param glyph The glyph which is created from the specified font.
 @return YES: the glyph is bitmap, NO: the glyph is vector.
 */
static inline BOOL BJLYYTextCGGlyphIsBitmap(CTFontRef font, CGGlyph glyph) {
    if (!font && !glyph) return NO;
    if (!BJLYYTextCTFontContainsColorBitmapGlyphs(font)) return NO;
    CGPathRef path = CTFontCreatePathForGlyph(font, glyph, NULL);
    if (path) {
        CFRelease(path);
        return NO;
    }
    return YES;
}

/**
 Get the `AppleColorEmoji` font's ascent with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font ascent.
 */
static inline CGFloat BJLYYTextEmojiGetAscentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 1.25 * fontSize;
    }
    else if (16 <= fontSize && fontSize <= 24) {
        return 0.5 * fontSize + 12;
    }
    else {
        return fontSize;
    }
}

/**
 Get the `AppleColorEmoji` font's descent with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font descent.
 */
static inline CGFloat BJLYYTextEmojiGetDescentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 0.390625 * fontSize;
    }
    else if (16 <= fontSize && fontSize <= 24) {
        return 0.15625 * fontSize + 3.75;
    }
    else {
        return 0.3125 * fontSize;
    }
    return 0;
}

/**
 Get the `AppleColorEmoji` font's glyph bounding rect with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font glyph bounding rect.
 */
static inline CGRect BJLYYTextEmojiGetGlyphBoundingRectWithFontSize(CGFloat fontSize) {
    CGRect rect;
    rect.origin.x = 0.75;
    rect.size.width = rect.size.height = BJLYYTextEmojiGetAscentWithFontSize(fontSize);
    if (fontSize < 16) {
        rect.origin.y = -0.2525 * fontSize;
    }
    else if (16 <= fontSize && fontSize <= 24) {
        rect.origin.y = 0.1225 * fontSize - 6;
    }
    else {
        rect.origin.y = -0.1275 * fontSize;
    }
    return rect;
}

/**
 Get the character set which should rotate in vertical form.
 @return The shared character set.
 */
NSCharacterSet *BJLYYTextVerticalFormRotateCharacterSet(void);

/**
 Get the character set which should rotate and move in vertical form.
 @return The shared character set.
 */
NSCharacterSet *BJLYYTextVerticalFormRotateAndMoveCharacterSet(void);

/// Convert degrees to radians.
static inline CGFloat BJLYYTextDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

/// Convert radians to degrees.
static inline CGFloat BJLYYTextRadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

/// Get the transform rotation.
/// @return the rotation in radians [-PI,PI] ([-180°,180°])
static inline CGFloat BJLYYTextCGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// Get the transform's scale.x
static inline CGFloat BJLYYTextCGAffineTransformGetScaleX(CGAffineTransform transform) {
    return sqrt(transform.a * transform.a + transform.c * transform.c);
}

/// Get the transform's scale.y
static inline CGFloat BJLYYTextCGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

/// Get the transform's translate.x
static inline CGFloat BJLYYTextCGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

/// Get the transform's translate.y
static inline CGFloat BJLYYTextCGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

/**
 If you have 3 pair of points transformed by a same CGAffineTransform:
 p1 (transform->) q1
 p2 (transform->) q2
 p3 (transform->) q3
 This method returns the original transform matrix from these 3 pair of points.
 
 @see http://stackoverflow.com/questions/13291796/calculate-values-for-a-cgaffinetransform-from-three-points-in-each-of-two-uiview
 */
CGAffineTransform BJLYYTextCGAffineTransformGetFromPoints(CGPoint before[_Nullable 3], CGPoint after[_Nullable 3]);

/// Get the transform which can converts a point from the coordinate system of a given view to another.
CGAffineTransform BJLYYTextCGAffineTransformGetFromViews(UIView *from, UIView *to);

/// Create a skew transform.
static inline CGAffineTransform BJLYYTextCGAffineTransformMakeSkew(CGFloat x, CGFloat y) {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}

/// Negates/inverts a UIEdgeInsets.
static inline UIEdgeInsets BJLYYTextUIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

/// Convert CALayer's gravity string to UIViewContentMode.
UIViewContentMode BJLYYTextCAGravityToUIViewContentMode(NSString *gravity);

/// Convert UIViewContentMode to CALayer's gravity string.
NSString *BJLYYTextUIViewContentModeToCAGravity(UIViewContentMode contentMode);

/**
 Returns a rectangle to fit the rect with specified content mode.
 
 @param rect The constrant rect
 @param size The content size
 @param mode The content mode
 @return A rectangle for the given content mode.
 @discussion UIViewContentModeRedraw is same as UIViewContentModeScaleToFill.
 */
CGRect BJLYYTextCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/// Returns the center for the rectangle.
static inline CGPoint BJLYYTextCGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// Returns the area of the rectangle.
static inline CGFloat BJLYYTextCGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// Returns the distance between two points.
static inline CGFloat BJLYYTextCGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// Returns the minmium distance between a point to a rectangle.
static inline CGFloat BJLYYTextCGPointGetDistanceToRect(CGPoint p, CGRect r) {
    r = CGRectStandardize(r);
    if (CGRectContainsPoint(r, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(r) <= p.y && p.y <= CGRectGetMaxY(r)) {
        distV = 0;
    }
    else {
        distV = p.y < CGRectGetMinY(r) ? CGRectGetMinY(r) - p.y : p.y - CGRectGetMaxY(r);
    }
    if (CGRectGetMinX(r) <= p.x && p.x <= CGRectGetMaxX(r)) {
        distH = 0;
    }
    else {
        distH = p.x < CGRectGetMinX(r) ? CGRectGetMinX(r) - p.x : p.x - CGRectGetMaxX(r);
    }
    return MAX(distV, distH);
}

/// Get main screen's scale.
CGFloat BJLYYTextScreenScale(void);

/// Get main screen's size. Height is always larger than width.
CGSize BJLYYTextScreenSize(void);

/// Convert point to pixel.
static inline CGFloat BJLYYTextCGFloatToPixel(CGFloat value) {
    return value * BJLYYTextScreenScale();
}

/// Convert pixel to point.
static inline CGFloat BJLYYTextCGFloatFromPixel(CGFloat value) {
    return value / BJLYYTextScreenScale();
}

/// floor point value for pixel-aligned
static inline CGFloat BJLYYTextCGFloatPixelFloor(CGFloat value) {
    CGFloat scale = BJLYYTextScreenScale();
    return floor(value * scale) / scale;
}

/// round point value for pixel-aligned
static inline CGFloat BJLYYTextCGFloatPixelRound(CGFloat value) {
    CGFloat scale = BJLYYTextScreenScale();
    return round(value * scale) / scale;
}

/// ceil point value for pixel-aligned
static inline CGFloat BJLYYTextCGFloatPixelCeil(CGFloat value) {
    CGFloat scale = BJLYYTextScreenScale();
    return ceil(value * scale) / scale;
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGFloat BJLYYTextCGFloatPixelHalf(CGFloat value) {
    CGFloat scale = BJLYYTextScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}

/// floor point value for pixel-aligned
static inline CGPoint BJLYYTextCGPointPixelFloor(CGPoint point) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGPointMake(floor(point.x * scale) / scale,
        floor(point.y * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGPoint BJLYYTextCGPointPixelRound(CGPoint point) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
        round(point.y * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGPoint BJLYYTextCGPointPixelCeil(CGPoint point) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGPointMake(ceil(point.x * scale) / scale,
        ceil(point.y * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGPoint BJLYYTextCGPointPixelHalf(CGPoint point) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGPointMake((floor(point.x * scale) + 0.5) / scale,
        (floor(point.y * scale) + 0.5) / scale);
}

/// floor point value for pixel-aligned
static inline CGSize BJLYYTextCGSizePixelFloor(CGSize size) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGSizeMake(floor(size.width * scale) / scale,
        floor(size.height * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGSize BJLYYTextCGSizePixelRound(CGSize size) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGSizeMake(round(size.width * scale) / scale,
        round(size.height * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGSize BJLYYTextCGSizePixelCeil(CGSize size) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGSizeMake(ceil(size.width * scale) / scale,
        ceil(size.height * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGSize BJLYYTextCGSizePixelHalf(CGSize size) {
    CGFloat scale = BJLYYTextScreenScale();
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
        (floor(size.height * scale) + 0.5) / scale);
}

/// floor point value for pixel-aligned
static inline CGRect BJLYYTextCGRectPixelFloor(CGRect rect) {
    CGPoint origin = BJLYYTextCGPointPixelCeil(rect.origin);
    CGPoint corner = BJLYYTextCGPointPixelFloor(CGPointMake(rect.origin.x + rect.size.width,
        rect.origin.y + rect.size.height));
    CGRect ret = CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
    if (ret.size.width < 0) ret.size.width = 0;
    if (ret.size.height < 0) ret.size.height = 0;
    return ret;
}

/// round point value for pixel-aligned
static inline CGRect BJLYYTextCGRectPixelRound(CGRect rect) {
    CGPoint origin = BJLYYTextCGPointPixelRound(rect.origin);
    CGPoint corner = BJLYYTextCGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
        rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// ceil point value for pixel-aligned
static inline CGRect BJLYYTextCGRectPixelCeil(CGRect rect) {
    CGPoint origin = BJLYYTextCGPointPixelFloor(rect.origin);
    CGPoint corner = BJLYYTextCGPointPixelCeil(CGPointMake(rect.origin.x + rect.size.width,
        rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGRect BJLYYTextCGRectPixelHalf(CGRect rect) {
    CGPoint origin = BJLYYTextCGPointPixelHalf(rect.origin);
    CGPoint corner = BJLYYTextCGPointPixelHalf(CGPointMake(rect.origin.x + rect.size.width,
        rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// floor UIEdgeInset for pixel-aligned
static inline UIEdgeInsets BJLYYTextUIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = BJLYYTextCGFloatPixelFloor(insets.top);
    insets.left = BJLYYTextCGFloatPixelFloor(insets.left);
    insets.bottom = BJLYYTextCGFloatPixelFloor(insets.bottom);
    insets.right = BJLYYTextCGFloatPixelFloor(insets.right);
    return insets;
}

/// ceil UIEdgeInset for pixel-aligned
static inline UIEdgeInsets BJLYYTextUIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = BJLYYTextCGFloatPixelCeil(insets.top);
    insets.left = BJLYYTextCGFloatPixelCeil(insets.left);
    insets.bottom = BJLYYTextCGFloatPixelCeil(insets.bottom);
    insets.right = BJLYYTextCGFloatPixelCeil(insets.right);
    return insets;
}

static inline UIFont *_Nullable BJLYYTextFontWithBold(UIFont *font) {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:font.pointSize];
}

static inline UIFont *_Nullable BJLYYTextFontWithItalic(UIFont *font) {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize];
}

static inline UIFont *_Nullable BJLYYTextFontWithBoldItalic(UIFont *font) {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:font.pointSize];
}

/**
 Convert CFRange to NSRange
 @param range CFRange @return NSRange
 */
static inline NSRange BJLYYTextNSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

/**
 Convert NSRange to CFRange
 @param range NSRange @return CFRange
 */
static inline CFRange BJLYYTextCFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

/// Returns YES in App Extension.
BOOL BJLYYTextIsAppExtension(void);

/// Returns nil in App Extension.
UIApplication *_Nullable BJLYYTextSharedApplication(void);

NS_ASSUME_NONNULL_END
