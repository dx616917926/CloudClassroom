//
//  BJLYYTextTransaction.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/18.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "BJLYYTextTransaction.h"

@interface BJLYYTextTransaction ()
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@end

static NSMutableSet *transactionSet = nil;

static void BJLYYRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [NSMutableSet new];
    [currentSet enumerateObjectsUsingBlock:^(BJLYYTextTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector];
#pragma clang diagnostic pop
    }];
}

static void BJLYYTextTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet new];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;

        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
            kCFRunLoopBeforeWaiting | kCFRunLoopExit,
            true, // repeat
            0xFFFFFF, // after CATransaction(2000000)
            BJLYYRunLoopObserverCallBack,
            NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

@implementation BJLYYTextTransaction

+ (BJLYYTextTransaction *)transactionWithTarget:(id)target selector:(SEL)selector {
    if (!target || !selector) return nil;
    BJLYYTextTransaction *t = [BJLYYTextTransaction new];
    t.target = target;
    t.selector = selector;
    return t;
}

- (void)commit {
    if (!_target || !_selector) return;
    BJLYYTextTransactionSetup();
    [transactionSet addObject:self];
}

- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    BJLYYTextTransaction *other = object;
    return other.selector == _selector && other.target == _target;
}

@end
