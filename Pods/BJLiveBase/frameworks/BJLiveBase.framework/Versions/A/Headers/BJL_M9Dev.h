//
//  BJL_M9Dev.h
//  M9Dev
//
//  Created by MingLQ on 2016-04-20.
//  Copyright (c) 2016 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

// #see M9Dev - https://github.com/iwill/

NS_ASSUME_NONNULL_BEGIN

/** for statement-expression */

#define bjl_return

/** cast */

#define bjl_as(_OBJECT, CLASS) ({                                 \
    __typeof__(_OBJECT) OBJECT = _OBJECT;                         \
    ([OBJECT isKindOfClass:CLASS.class] ? (CLASS *)OBJECT : nil); \
})

static inline BOOL bjl_eq(id _Nullable a, id _Nullable b) {
    return a == b || [a isEqual:b];
}

/** struct */

// cast to ignore const: bjl_set((CGRect)CGRectZero, { set.size = self.intrinsicContentSize; })
#define bjl_set(_STRUCT, STATEMENTS) ({ \
    __typeof__(_STRUCT) set = _STRUCT;  \
    STATEMENTS                          \
    set;                                \
})

/** variable arguments */

#define _bjl_va_for(TYPE, VAR, FIRST, ARGS, TERMINATION) \
    for (TYPE VAR = FIRST; VAR != TERMINATION; VAR = va_arg(ARGS, TYPE))

// bjl_va_each(type, first, termination, ^(type var) { ... });
#define bjl_va_each(TYPE, FIRST, TERMINATION, BLOCK)       \
    {                                                      \
        va_list ARGS;                                      \
        va_start(ARGS, FIRST);                             \
        _bjl_va_for(TYPE, VAR, FIRST, ARGS, TERMINATION) { \
            BLOCK(VAR);                                    \
        }                                                  \
        va_end(ARGS);                                      \
    }

/** just weakify */

#define bjl_weak_var(...) \
    bjl_metamacro_foreach(bjl_weak_var_, , __VA_ARGS__)

#define bjl_weak_var_(INDEX, VAR)                              \
    __typeof__(VAR) bjl_metamacro_concat(VAR, _temp_) = (VAR); \
    __weak __typeof__(VAR) VAR = bjl_metamacro_concat(VAR, _temp_);

#define bjl_weak_block(ARGS, BLOCK) ({                          \
    _Pragma("GCC diagnostic push")                              \
        _Pragma("GCC diagnostic ignored \"-Wunused-variable\"") \
            bjl_weak_var ARGS;                                  \
    _Pragma("GCC diagnostic pop")                               \
        BLOCK;                                                  \
})

/** strongify if nil */

#define bjl_strongify_ifNil(...) \
    bjl_strongify(__VA_ARGS__);  \
    if ([NSArray arrayWithObjects:__VA_ARGS__, nil].count != bjl_metamacro_argcount(__VA_ARGS__))

/** BJLWeakRef */

@interface BJLWeakRef<ObjectType>: NSObject
@property (nonatomic, weak, nullable) ObjectType object;
+ (instancetype)weakRefWithObject:(nullable ObjectType)object;
@end

/** dispatch */

/*
static inline dispatch_time_t bjl_dispatch_time_in_seconds(NSTimeInterval seconds) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
}
static inline void bjl_dispatch_after_seconds(NSTimeInterval seconds, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_after(bjl_dispatch_time_in_seconds(seconds), queue ?: dispatch_get_main_queue(), block);
} // */

// execute immediately if on the queue, or async if not - the earlier the better
static inline void bjl_dispatch_on(dispatch_queue_t queue, dispatch_block_t block) {
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue))
        block();
    else
        dispatch_async(queue, block);
}
static inline void bjl_dispatch_on_main_queue(dispatch_block_t block) {
    bjl_dispatch_on(dispatch_get_main_queue(), block);
}

// execute immediately if on the queue, to avoid deadlock - a serial queue dispatch_sync to itself
static inline void bjl_dispatch_sync(dispatch_queue_t queue, dispatch_block_t block) {
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue))
        block();
    else
        dispatch_sync(queue, block);
}
static inline void bjl_dispatch_sync_main_queue(dispatch_block_t block) {
    bjl_dispatch_sync(dispatch_get_main_queue(), block);
}

static inline void bjl_dispatch_async_main_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}
static inline void bjl_dispatch_async_high_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}
static inline void bjl_dispatch_async_default_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
static inline void bjl_dispatch_async_low_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}
static inline void bjl_dispatch_async_background_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

/** to string */

#define BJLStringFromLiteral(...)                              @ #__VA_ARGS__
#define BJLCStringFromLiteral(...)                             #__VA_ARGS__
#define BJLStringFromValue(VALUE, DEFAULT_VALUE)               ({ VALUE ? [@(VALUE) description] : DEFAULT_VALUE; })
#define BJLObjectFromValue(VALUE, DEFAULT_VALUE)               ({ VALUE ? @(VALUE) : DEFAULT_VALUE; })
#define BJLStringFromValue_Nonnull(VALUE)                      ({ [@(VALUE) description] ?: [NSString stringWithFormat:@"%@", @(VALUE)]; }) // high-performance ?: ensure-nonnull
#define BJLObjectFromValue_Nonnull(VALUE)                      ({ @(VALUE); })
#define BJLStringFromBoolean(BOOLEAN)                          ({ BOOLEAN ? @"YES" : @"NO"; })

// !!!: use DEFAULT_VALUE if PREPROCESSOR is undefined or its value is same to itself
#define BJLStringFromPreprocessor(PREPROCESSOR, DEFAULT_VALUE) ({                 \
    NSString *string = BJLStringFromLiteral(PREPROCESSOR);                        \
    bjl_return [string isEqualToString:@ #PREPROCESSOR] ? DEFAULT_VALUE : string; \
})

#define TMIN(TYPE, A, B)                (TYPE) MIN((TYPE)A, (TYPE)B)
#define TMAX(TYPE, A, B)                (TYPE) MAX((TYPE)A, (TYPE)B)

#define MINMAX(V, L, R)                 MIN(MAX(L, V), R)
#define TMINMAX(TYPE, V, L, R)          (TYPE) MIN((TYPE)MAX((TYPE)L, (TYPE)V), (TYPE)R)

/** keypath */

#define BJLInstanceKeypath(CLASS, PATH) ({ \
    CLASS *INSTANCE = nil;                 \
    BJLKeypath(INSTANCE, PATH);            \
})

#define BJLKeypath(OBJECT, PATH) ({                                                        \
    (void)(NO && ((void)OBJECT.PATH, NO)); /* copied from libextobjc/EXTKeyPathCoding.h */ \
    @ #PATH;                                                                               \
})

/** version comparison */

// 10 < 10.0 < 10.0.0
// NO `BJLVersionGT` and `BJLVersionLE`
#define BJLVersionCMP(A, B) ({ \
    [A hasPrefix:[B stringByAppendingString:@"-"]] ? -1 \
    : [B hasPrefix:[A stringByAppendingString:@"-"]] ? 1 \
    : [A compare:B options:NSNumericSearch]; \
})
#define BJLVersionEQ(A, B) ({ BJLVersionCMP(A, B) == NSOrderedSame; })
#define BJLVersionLT(A, B) ({ BJLVersionCMP(A, B) <  NSOrderedSame; })
#define BJLVersionGE(A, B) ({ BJLVersionCMP(A, B) >= NSOrderedSame; })
#define BJLRemovingBuildMetadata(V) ({ \
    NSRange range = [V rangeOfString:@"+"]; \
    range.location == NSNotFound ? V : [V substringToIndex:range.location]; \
})

/** milliseconds */

typedef long long BJLMilliseconds;
#define BJL_MSEC_PER_SEC 1000ll // 1000ull for `unsigned long long`
// Conversions between NSTimeInterval and BJLMilliseconds
static inline NSTimeInterval BJLTimeIntervalFromMilliseconds(BJLMilliseconds milliseconds) {
    return (NSTimeInterval)((double)milliseconds / BJL_MSEC_PER_SEC);
}
static inline BJLMilliseconds BJLMillisecondsFromTimeInterval(NSTimeInterval timeInterval) {
    return (BJLMilliseconds)(timeInterval * BJL_MSEC_PER_SEC);
}
// NSTimeInterval/BJLMilliseconds between 1970 and 2001
#define BJLTimeIntervalBetween1970AndReferenceDate NSTimeIntervalSince1970
#define BJLMillisecondsBetween1970AndReferenceDate BJLMillisecondsFromTimeInterval(BJLTimeIntervalBetween1970AndReferenceDate)
// NSTimeInterval/BJLMilliseconds between 2001 and now
static inline NSTimeInterval BJLTimeIntervalSinceReferenceDate(void) {
    return NSDate.timeIntervalSinceReferenceDate;
}
static inline BJLMilliseconds BJLMillisecondsSinceReferenceDate(void) {
    return BJLMillisecondsFromTimeInterval(BJLTimeIntervalSinceReferenceDate());
}
// NSTimeInterval/BJLMilliseconds between 1970 and now, but NOT between 1970 and 2001
static inline NSTimeInterval BJLTimeIntervalSince1970(void) {
    return NSDate.timeIntervalSinceReferenceDate + BJLTimeIntervalBetween1970AndReferenceDate;
}
static inline BJLMilliseconds BJLMillisecondsSince1970(void) {
    return BJLMillisecondsFromTimeInterval(BJLTimeIntervalSince1970());
}

/** safe range */

static inline NSRange BJLMakeSafeRange(NSUInteger loc, NSUInteger len, NSUInteger length) {
    loc = MIN(loc, length);
    len = MIN(len, length - loc);
    return NSMakeRange(loc, len);
}
static inline NSRange BJLSafeRangeForLength(NSRange range, NSUInteger length) {
    return BJLMakeSafeRange(range.location, range.length, length);
}

/** progress */

typedef struct {
    long long totalUnitCount, completedUnitCount;
    BOOL determinate; // NOT indeterminate
    double fractionCompleted;
    BOOL finished;
} BJLProgress;

static inline BJLProgress
BJLProgressMake(long long totalUnitCount, long long completedUnitCount) {
    BOOL indeterminate = (totalUnitCount < 0
                          || completedUnitCount < 0
                          || (completedUnitCount == 0 && totalUnitCount == 0));
    BOOL finished = (!indeterminate
                     && completedUnitCount >= totalUnitCount);
    double fractionCompleted = (indeterminate ? 0.0
                                : finished    ? 1.0
                                              : ((double)completedUnitCount / totalUnitCount));
    return (BJLProgress){
        .totalUnitCount = totalUnitCount,
        .completedUnitCount = completedUnitCount,
        .determinate = !indeterminate,
        .finished = finished,
        .fractionCompleted = fractionCompleted};
}
static inline BOOL
BJLProgressEqualToProgress(BJLProgress progress1, BJLProgress progress2) {
    return (progress1.totalUnitCount == progress2.totalUnitCount
            && progress1.completedUnitCount == progress2.completedUnitCount);
}

static inline BJLProgress
BJLProgressFromString(NSString *string) {
    NSRange range = [string rangeOfString:@"/"];
    if (range.location == NSNotFound) {
        return BJLProgressMake(0, 0);
    }
    long long completedUnitCount = [[string substringToIndex:range.location] longLongValue];
    long long totalUnitCount = [[string substringFromIndex:range.location + range.length] longLongValue];
    return BJLProgressMake(totalUnitCount, completedUnitCount);
}
static inline NSString *
BJLStringFromProgress(BJLProgress progress) {
    return [NSString stringWithFormat:@"%lld/%lld", progress.completedUnitCount, progress.totalUnitCount];
}

static inline NSString *
BJLProgressString(BJLProgress progress) {
    return [NSString stringWithFormat:@"%.2f%%",
                     progress.fractionCompleted * 100];
}
static inline NSString *
BJLProgressDescription(BJLProgress progress) {
    return [NSString stringWithFormat:@"<BJLProgress: %.2f%% = %lld / %lld (determinate: %d, finished: %d)>",
                     progress.fractionCompleted * 100,
                     progress.completedUnitCount,
                     progress.totalUnitCount,
                     progress.determinate,
                     progress.finished];
}

/** this class */

#define bjl_this_class_name ({                                                          \
    static NSString *ClassName = nil;                                                   \
    if (!ClassName) {                                                                   \
        NSString *prettyFunction = [NSString stringWithUTF8String:__PRETTY_FUNCTION__]; \
        NSUInteger loc = [prettyFunction rangeOfString:@"["].location + 1;              \
        NSUInteger len = [prettyFunction rangeOfString:@" "].location - loc;            \
        NSRange range = BJLMakeSafeRange(loc, len, prettyFunction.length);              \
        ClassName = [prettyFunction substringWithRange:range];                          \
    }                                                                                   \
    ClassName;                                                                          \
})
#define bjl_this_class                       NSClassFromString(bjl_this_class_name)

/** runtime */

/* invoking at runtime & invoking log
 !!!: ENABLE after all `import` statements and DISABLE after using likes `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END`
 
 // ENABLE invoking at runtime:
 #undef  bjl_invoke_at_runtime
 #define bjl_invoke_at_runtime 1
 
 // DISABLE invoking at runtime:
 #undef  bjl_invoke_at_runtime
 #define bjl_invoke_at_runtime 0
 
 // ENABLE invoking log:
 #undef  bjl_invoke_log
 #define bjl_invoke_log 1
 
 // DISABLE invoking log:
 #undef  bjl_invoke_log
 #define bjl_invoke_log 0
 */
#define bjl_invoke_at_runtime                0
#define bjl_invoke_log                       0

// bjl_invoke(self, setA:, a, b:, b); // [self setA:a b:b];
#define bjl_invoke(OBJ, ...)                 bjl_metamacro_concat(bjl_invoke_, bjl_metamacro_if_eq(0, bjl_invoke_at_runtime)(ct)(rt))(OBJ, __VA_ARGS__)
// o = bjl_invoke_obj(id, self, getA); // o = [self getA];
#define bjl_invoke_obj(TYPE, OBJ, ...)       bjl_metamacro_concat(bjl_invoke_obj_, bjl_metamacro_if_eq(0, bjl_invoke_at_runtime)(ct)(rt))(TYPE, OBJ, __VA_ARGS__)
// a = bjl_invoke_val(int, 0, self, getA); // a = [self getA];
#define bjl_invoke_val(TYPE, INIT, OBJ, ...) bjl_metamacro_concat(bjl_invoke_val_, bjl_metamacro_if_eq(0, bjl_invoke_at_runtime)(ct)(rt))(TYPE, INIT, OBJ, __VA_ARGS__)

// ct: compile-time
#define bjl_invoke_ct(OBJ, ...)                                                               \
    {                                                                                         \
        if (bjl_invoke_log) NSLog(@bjl_metamacro_stringify(bjl_invoke_ct(OBJ, __VA_ARGS__))); \
        [OBJ bjl_metamacro_foreach_concat(, , __VA_ARGS__)];                                  \
    }
#define bjl_invoke_obj_ct(TYPE, OBJ, ...)       bjl_invoke_val_ct(TYPE, nil, OBJ, __VA_ARGS__)
#define bjl_invoke_val_ct(TYPE, INIT, OBJ, ...) ({                                                        \
    if (bjl_invoke_log) NSLog(@bjl_metamacro_stringify(bjl_invoke_val_ct(TYPE, INIT, OBJ, __VA_ARGS__))); \
    [OBJ bjl_metamacro_foreach_concat(, , __VA_ARGS__)];                                                  \
})

// rt: run-time
#define bjl_invoke_rt(OBJ, ...) \
    { bjl_invoke_val_rt(void *, nil, OBJ, __VA_ARGS__); }
#define bjl_invoke_obj_rt(TYPE, OBJ, ...)       (__bridge TYPE) bjl_invoke_val_rt(void *, nil, OBJ, __VA_ARGS__)
#define bjl_invoke_val_rt(TYPE, INIT, OBJ, ...) ({                                                                     \
    if (bjl_invoke_log) NSLog(@bjl_metamacro_stringify(bjl_invoke_val_rt(TYPE, INIT, OBJ, __VA_ARGS__)));              \
    TYPE res = INIT;                                                                                                   \
    _Pragma("GCC diagnostic push")                                                                                     \
        _Pragma("GCC diagnostic ignored \"-Wundeclared-selector\"")                                                    \
            SEL sel = bjl_invoke_sel(__VA_ARGS__);                                                                     \
    _Pragma("GCC diagnostic pop")                                                                                      \
        NSMethodSignature *methodSignature = [OBJ methodSignatureForSelector:sel];                                     \
    if (methodSignature) {                                                                                             \
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];                       \
        [invocation setTarget:OBJ];                                                                                    \
        [invocation setSelector:sel];                                                                                  \
        [invocation retainArguments];                                                                                  \
        NSUInteger index = 2; /* args start at 2 */                                                                    \
        if (invocation.methodSignature.numberOfArguments > index) bjl_invoke_args(__VA_ARGS__);                        \
        [invocation invoke];                                                                                           \
        if (strcmp(invocation.methodSignature.methodReturnType, @encode(void)) != 0) [invocation getReturnValue:&res]; \
    }                                                                                                                  \
    res;                                                                                                               \
})

// ???: DOES NOT work when `pod package`
// #define bjl_pointer(VAR) ({ __typeof__(VAR) x = VAR; &x; })

#define bjl_invoke_sel(...) \
    @selector(bjl_metamacro_foreach(bjl_invoke_sel_iter, , __VA_ARGS__))
#define bjl_invoke_sel_iter(INDEX, VAR) \
    bjl_metamacro_if_eq(bjl_metamacro_is_even(INDEX), 1) /* ? */ (VAR) /* : */ ()

#define bjl_invoke_args(...)                                        \
    {                                                               \
        bjl_metamacro_foreach(bjl_invoke_args_iter, , __VA_ARGS__); \
    }
#define bjl_invoke_args_iter(INDEX, VAR) \
    bjl_metamacro_if_eq(0, bjl_metamacro_is_even(INDEX)) /* ? */ ({ __typeof__(VAR) arg = VAR; [invocation setArgument:&arg atIndex:index++]; }) /* : */ ()

/** swizzle */

FOUNDATION_EXPORT void BJLSwizzleMethod(Class theClass, SEL originalSelector, SEL swizzledSelector);

/** debugger */

static inline BOOL BJLIsDebuggerAttached(void) {
    return getppid() != 1;
}

/** assert */

#define BJLAssert(CONDITION, DESCRIPTION, ...) ({                                 \
    if (BJLIsDebuggerAttached()) NSAssert(CONDITION, DESCRIPTION, ##__VA_ARGS__); \
    CONDITION;                                                                    \
})
#define BJLCAssert(CONDITION, DESCRIPTION, ...) ({                                 \
    if (BJLIsDebuggerAttached()) NSCAssert(CONDITION, DESCRIPTION, ##__VA_ARGS__); \
    CONDITION;                                                                     \
})

#define BJLParamAssert(CONDITION) ({                           \
    if (BJLIsDebuggerAttached()) NSParameterAssert(CONDITION); \
    CONDITION;                                                 \
})
#define BJLCParamAssert(CONDITION) ({                           \
    if (BJLIsDebuggerAttached()) NSCParameterAssert(CONDITION); \
    CONDITION;                                                  \
})

/** @dynamic property with associated-object */

// #import <objc/runtime.h>

#define bjl_associate_primitive_type(TYPE, PROPERTY, GETTER, DECODE, SETTER, ENCODE)                    \
    @dynamic PROPERTY;                                                                                  \
    -TYPE GETTER {                                                                                      \
        id PROPERTY = objc_getAssociatedObject(self, @selector(PROPERTY));                              \
        return DECODE;                                                                                  \
    }                                                                                                   \
    -(void)SETTER TYPE PROPERTY {                                                                       \
        objc_setAssociatedObject(self, @selector(PROPERTY), ENCODE, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    }

#define bjl_associate_reference_type(TYPE, PROPERTY, GETTER, SETTER, POLICY)   \
    @dynamic PROPERTY;                                                         \
    -TYPE GETTER {                                                             \
        return objc_getAssociatedObject(self, @selector(PROPERTY));            \
    }                                                                          \
    -(void)SETTER TYPE PROPERTY {                                              \
        objc_setAssociatedObject(self, @selector(PROPERTY), PROPERTY, POLICY); \
    }

/** MD5 */

FOUNDATION_EXPORT NSString *BJLMD5FromString(NSString *string);
FOUNDATION_EXPORT NSString *BJLMD5FromData(NSData *data);
FOUNDATION_EXPORT NSString *_Nullable BJLMD5FromFile(NSString *filePath);

/** Base64 */

FOUNDATION_EXPORT char BJLBase64Encode6Bits(UInt8 n);
FOUNDATION_EXPORT UInt8 BJLBase64Decode6Bits(char c);

FOUNDATION_EXPORT NSString *BJLBase64Encode64Bits(UInt64 bits64);
FOUNDATION_EXPORT UInt64 BJLBase64Decode64Bits(NSString *base64, NSUInteger offset); // reads 11 chars: 64 bits ~= 11 chars * 6 bits

/**
 *  M9TuplePack & M9TupleUnpack
 *  1. define:
 *      - (BJLTupleType(BOOL state1, BOOL state2))states;
 *  or:
 *      - (BJLTuple<BJLTupleGeneric(BOOL state1, BOOL state2> *)states;
 *  or:
 *      - (BJLTuple<void (^)(BOOL state1, BOOL state2> *)states;
 *  2. pack:
 *      BOOL state1 = self.state1, state2 = self.state2;
 *      return BJLTuplePack((BOOL, BOOL), state1, state2);
 *  3. unpack:
 *      BJLTupleUnpack(tuple) = ^(BOOL state1, BOOL state2) {
 *          // ...
 *      };
 * !!!:
 *  1. BJLTuplePack 中不要使用 `.`，否则会断言失败，例如
 *      BJLTuplePack((BOOL, BOOL), self.state1, self.state2);
 *  原因是
 *      a. self 将被 tuple 持有、直到 tuple 被释放
 *      b. self.state1、self.state2 的值在拆包时才读取，取到的值可能与打包时不同
 *  为避免出现不可预期的结果，定义临时变量提前读取属性值、然后打包，例如
 *      BOOL state1 = self.state1, state2 = self.state2;
 *      BJLTuple *tuple = BJLTuplePack((BOOL, BOOL), state1, state2);
 *  2. BJLTupleUnpack 中不需要 weakify、strongify，因为 unpack block 会被立即执行
 */

// 1. define:
/** - (BJLTupleType(NSString *string, NSInteger integer))aTuple; */
#define BJLTupleType(...)        BJLTuple<void (^)(__VA_ARGS__)> *
/** - (BJLTuple<BJLTupleGeneric(NSString *string, NSInteger integer)> *)aTuple; */
#define BJLTupleGeneric          void(^)
// 2. pack:
#define BJLTuplePack(TYPE, ...)  _BJLTuplePack(void(^) TYPE, __VA_ARGS__)
#define _BJLTuplePack(TYPE, ...) ({                                                          \
    NSCAssert([BJLStringFromLiteral(__VA_ARGS__) rangeOfString:@"."].location == NSNotFound, \
        @"DONOT use `.` in BJLTuplePack(%@)",                                                \
        BJLStringFromLiteral(__VA_ARGS__));                                                  \
    [BJLTuple tupleWithPack:^(BJLTupleUnpackBlock NS_NOESCAPE unpack) {                      \
        if (unpack) ((TYPE)unpack)(__VA_ARGS__);                                             \
    }];                                                                                      \
})
// 3. unpack:
// 用 (BJLTuple.defaultTuple, TUPLE) 而不是 (TUPLE ?: BJLTuple.defaultTuple)，因为后者会导致 TUPLE 被编译器认为是 nullable 的
#define BJLTupleUnpack(TUPLE) (BJLTuple.defaultTuple, TUPLE).unpack
// 4. internal:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^BJLTupleUnpackBlock)(/* ... */);
#pragma clang diagnostic pop
typedef void (^BJLTuplePackBlock)(BJLTupleUnpackBlock NS_NOESCAPE unpack);
@interface BJLTuple<T>: NSObject
@property (nonatomic /* , writeonly */, assign, setter=unpack:) id /* <T NS_NOESCAPE> */ unpack;
@property (class, nonatomic, readonly) BJLTuple<T> *defaultTuple;
+ (instancetype)tupleWithPack:(BJLTuplePackBlock)pack;
@end

/** RACTupleUnpack without unused warning */
#define BJL_RACTupleUnpack(...)                                 \
    _Pragma("GCC diagnostic push")                              \
        _Pragma("GCC diagnostic ignored \"-Wunused-variable\"") \
            RACTupleUnpack(__VA_ARGS__)                         \
                _Pragma("GCC diagnostic pop")

/** hardware */

// iPhone X: iPhone10,3 || iPhone10,6
// Simultor.Any: i386 || x86_64
FOUNDATION_EXPORT NSString *BJLHardwareType(void);
FOUNDATION_EXPORT NSString *BJLDeviceUUID(void);

NS_ASSUME_NONNULL_END
