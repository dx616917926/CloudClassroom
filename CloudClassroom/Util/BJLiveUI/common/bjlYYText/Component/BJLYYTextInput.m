//
//  BJLYYTextInput.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/17.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "BJLYYTextInput.h"
#import "BJLYYTextUtilities.h"

@implementation BJLYYTextPosition

+ (instancetype)positionWithOffset:(NSInteger)offset {
    return [self positionWithOffset:offset affinity:BJLYYTextAffinityForward];
}

+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(BJLYYTextAffinity)affinity {
    BJLYYTextPosition *p = [self new];
    p->_offset = offset;
    p->_affinity = affinity;
    return p;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class positionWithOffset:_offset affinity:_affinity];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@%@)", self.class, self, @(_offset), _affinity == BJLYYTextAffinityForward ? @"F" : @"B"];
}

- (NSUInteger)hash {
    return _offset * 2 + (_affinity == BJLYYTextAffinityForward ? 1 : 0);
}

- (BOOL)isEqual:(BJLYYTextPosition *)object {
    if (!object) return NO;
    return _offset == object.offset && _affinity == object.affinity;
}

- (NSComparisonResult)compare:(BJLYYTextPosition *)otherPosition {
    if (!otherPosition) return NSOrderedAscending;
    if (_offset < otherPosition.offset) return NSOrderedAscending;
    if (_offset > otherPosition.offset) return NSOrderedDescending;
    if (_affinity == BJLYYTextAffinityBackward && otherPosition.affinity == BJLYYTextAffinityForward) return NSOrderedAscending;
    if (_affinity == BJLYYTextAffinityForward && otherPosition.affinity == BJLYYTextAffinityBackward) return NSOrderedDescending;
    return NSOrderedSame;
}

@end

@implementation BJLYYTextRange {
    BJLYYTextPosition *_start;
    BJLYYTextPosition *_end;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _start = [BJLYYTextPosition positionWithOffset:0];
    _end = [BJLYYTextPosition positionWithOffset:0];
    return self;
}

- (BJLYYTextPosition *)start {
    return _start;
}

- (BJLYYTextPosition *)end {
    return _end;
}

- (BOOL)isEmpty {
    return _start.offset == _end.offset;
}

- (NSRange)asRange {
    return NSMakeRange(_start.offset, _end.offset - _start.offset);
}

+ (instancetype)rangeWithRange:(NSRange)range {
    return [self rangeWithRange:range affinity:BJLYYTextAffinityForward];
}

+ (instancetype)rangeWithRange:(NSRange)range affinity:(BJLYYTextAffinity)affinity {
    BJLYYTextPosition *start = [BJLYYTextPosition positionWithOffset:range.location affinity:affinity];
    BJLYYTextPosition *end = [BJLYYTextPosition positionWithOffset:range.location + range.length affinity:affinity];
    return [self rangeWithStart:start end:end];
}

+ (instancetype)rangeWithStart:(BJLYYTextPosition *)start end:(BJLYYTextPosition *)end {
    if (!start || !end) return nil;
    if ([start compare:end] == NSOrderedDescending) {
        YYTEXT_SWAP(start, end);
    }
    BJLYYTextRange *range = [BJLYYTextRange new];
    range->_start = start;
    range->_end = end;
    return range;
}

+ (instancetype)defaultRange {
    return [self new];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class rangeWithStart:_start end:_end];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@, %@)%@", self.class, self, @(_start.offset), @(_end.offset - _start.offset), _end.affinity == BJLYYTextAffinityForward ? @"F" : @"B"];
}

- (NSUInteger)hash {
    return (sizeof(NSUInteger) == 8 ? OSSwapInt64(_start.hash) : OSSwapInt32(_start.hash)) + _end.hash;
}

- (BOOL)isEqual:(BJLYYTextRange *)object {
    if (!object) return NO;
    return [_start isEqual:object.start] && [_end isEqual:object.end];
}

@end

@implementation BJLYYTextSelectionRect

@synthesize rect = _rect;
@synthesize writingDirection = _writingDirection;
@synthesize containsStart = _containsStart;
@synthesize containsEnd = _containsEnd;
@synthesize isVertical = _isVertical;

- (id)copyWithZone:(NSZone *)zone {
    BJLYYTextSelectionRect *one = [self.class new];
    one.rect = _rect;
    one.writingDirection = _writingDirection;
    one.containsStart = _containsStart;
    one.containsEnd = _containsEnd;
    one.isVertical = _isVertical;
    return one;
}

@end
