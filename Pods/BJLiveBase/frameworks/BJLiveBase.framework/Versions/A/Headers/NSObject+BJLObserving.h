//
//  NSObject+M9Observing.h
//  M9Dev
//
//  Created by MingLQ on 2017-01-04.
//  Copyright (c) 2017 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  !!!: avoid retain cycle - bjl_kvo:..., bjl_kvoMerge:..., bjl_observe:..., bjl_observeMerge:...
 *  // recommended: observation as property
 *  bjl_weakify(self, target); // weakify self and target
 *  self.observation = // observation property
 *  [self bjl_kvo:BJLMakeProperty(target, property)
 *       observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange * _Nullable change) {
 *           bjl_strongify(self, target); // strongify self and target
 *           [self.observation stopObserving];
 *           self.observation = nil;
 *           return YES;
 *       }];
 *  // DEPRECATED: observation as __block ivar
 *  // bjl_weakify(self, target); // weakify self and target
 *  __block id<BJLObservation> observation = // __block observation
 *  [self bjl_kvo:BJLMakeProperty(target, property)
 *       observer:^(id _Nullable value, id _Nullable oldValue, BJLPropertyChange * _Nullable change) {
 *           // bjl_strongify(self, target); // strongify self and target
 *           { // !!!: these two lines are required, and MUST be called
 *               [observation stopObserving];
 *               observation = nil;
 *           }
 *           return YES;
 *       }];
 *
 *  KVO - Key-Value Observing
 *  MPO - Method-Parameters Observing
 *  TODO: KVO & MPO returns observation (a mutable array?), then you can add observer-s to observation?
 */

@protocol BJLObservation;
@class BJLPropertyMeta, BJLMethodMeta;

@interface BJLPropertyChange<ObjectType>: NSObject // : BJLPropertyMeta?
@property (nonatomic, readonly) BJLPropertyMeta *property ;
@property (nonatomic, readonly) NSKeyValueChange kind; // NSKeyValueChangeKindKey
@property (nonatomic, readonly, nullable) ObjectType value, oldValue; // NSKeyValueChangeNewKey, NSKeyValueChangeOldKey
@property (nonatomic, readonly, nullable) NSIndexSet *indexes; // NSKeyValueChangeIndexesKey
@property (nonatomic, readonly, getter=isPrior) BOOL prior; // NSKeyValueChangeNotificationIsPriorKey
@property (nonatomic, readonly, nullable) void *context;
@property (nonatomic, readonly, getter=isChanged) BOOL changed; // value != oldValue
@property (nonatomic, readonly, getter=isDifferent) BOOL different; // value != oldValue && ![value isEqual:oldValue]
@end

typedef NS_ENUM(BOOL, BJLControlObserving) {
    BJLStop = NO,
    BJLKeep = YES,
    BJLStopObserving DEPRECATED_MSG_ATTRIBUTE("use `BJLStop` instead") = BJLStop,
    BJLKeepObserving DEPRECATED_MSG_ATTRIBUTE("use `BJLKeep` instead") = BJLKeep
};

// !!!: value/oldValue is nil if change.value/change.oldValue is NSNull
typedef BOOL (^BJLPropertyFilter)(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change);
typedef BJLControlObserving (^BJLPropertyObserver)(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change);
typedef void (^BJLPropertiesObserver)(id _Nullable value, id _Nullable oldValue, BJLPropertyChange *_Nullable change);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef BOOL (^BJLMethodFilter)();
typedef BJLControlObserving (^BJLMethodObserver)();
typedef void (^BJLMethodsObserver)();
#pragma clang diagnostic pop

#define BJLMakeProperty(TARGET, PROPERTY) ({                                                                  \
    /* NSCParameterAssert(TARGET); */                                                                         \
    (void)(NO && ((void)TARGET.PROPERTY, NO)); /* auto-complete: copied from libextobjc/EXTKeyPathCoding.h */ \
    [BJLPropertyMeta instanceWithTarget:TARGET name:@ #PROPERTY];                                             \
})

#define BJLMakeMethod(TARGET, METHOD) ({                                                         \
    /* NSCParameterAssert([TARGET respondsToSelector:@selector(METHOD)]); */ /* auto-complete */ \
    [TARGET respondsToSelector:@selector(METHOD)]; /* auto-complete */                           \
    [BJLMethodMeta instanceWithTarget:TARGET name:@ #METHOD];                                    \
})

/**
 *  Nesting change notifications for multiple keys -  https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOCompliance.html#//apple_ref/doc/uid/20001844-188627
 *  bjl_kvset without ivar and value, requires set ivar (or associated-object etc.) with value in __VA_ARGS__
 *  bjl_kvset(self, finished, {
 *      self->_finished = YES;
 *      bjl_kvset(self, progress, {
 *          self->_progress = 1.0;
 *      });
 *  });
 */
/*
#define bjl_kvset(OBJECT, KEY, ...) { \
    NSString *keyString = @#KEY; \
    [OBJECT willChangeValueForKey:keyString]; \
    { __VA_ARGS__ } \
    [OBJECT didChangeValueForKey:keyString]; \
} // */

/**
 *  Nesting change notifications for multiple keys -  https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOCompliance.html#//apple_ref/doc/uid/20001844-188627
 *  bjl_kvset(self, finished, YES, {
 *      bjl_kvset(self, progress, 1.0);
 *  });
 */
#define bjl_kvset(OBJECT, KEY, VALUE, ...)        \
    {                                             \
        NSString *keyString = @ #KEY;             \
        [OBJECT willChangeValueForKey:keyString]; \
        OBJECT->_##KEY = VALUE;                   \
        {__VA_ARGS__}                             \
        [OBJECT didChangeValueForKey:keyString];  \
    }

typedef void BJLObservable;
#define BJLMethodNotify(TYPE, ...) _BJLMethodNotify(BOOL(^) TYPE, __VA_ARGS__)
#define _BJLMethodNotify(TYPE, ...)                                                                                                              \
    if (NSObject.bjl_mpoLogsEnabled || self.bjl_mpoLogsEnabled) {                                                                                \
        NSLog(@"BJLMethodNotify: [%@ <#%@#>]", self, NSStringFromSelector(_cmd));                                                                \
    }                                                                                                                                            \
    _Pragma("clang diagnostic push")                                                                                                             \
        _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")                                                                        \
            [self _bjl_notifyMethodForSelector:_cmd callback:^BOOL(BJLMethodFilter filter, BJLMethodObserver observer, BOOL ignoreReturnValue) { \
                return (!filter || ((TYPE)filter)(__VA_ARGS__)) ? (((TYPE)observer)(__VA_ARGS__) || ignoreReturnValue) : YES;                    \
            }];                                                                                                                                  \
    _Pragma("clang diagnostic pop")

// #define BJLMethodNotifyVoid() BJLMethodNotify((void))

/* BJLKVODefaultOptions = New | Old | Initial */
FOUNDATION_EXPORT const NSKeyValueObservingOptions BJLKVODefaultOptions;

/**
 *  KVO with block.
 *  Auto stop observing before either self or the observing object is deallocated.
 */
@interface NSObject (BJLKeyValueObserving)

@property (class, nonatomic, setter=bjl_setKVOLogsEnabled:) BOOL bjl_kvoLogsEnabled;
@property (nonatomic, setter=bjl_setKVOLogsEnabled:) BOOL bjl_kvoLogsEnabled;

- (nullable id<BJLObservation>)bjl_kvo:(BJLPropertyMeta *)meta
                              observer:(BJLPropertyObserver)observer;
- (nullable id<BJLObservation>)bjl_kvo:(BJLPropertyMeta *)meta
                                filter:(nullable BJLPropertyFilter)filter
                              observer:(BJLPropertyObserver)observer;
- (nullable id<BJLObservation>)bjl_kvo:(BJLPropertyMeta *)meta
                               options:(NSKeyValueObservingOptions)options
                              observer:(BJLPropertyObserver)observer;
/**
 *  #param meta        target-property, #see `BJLMakeProperty(TARGET, PROPERTY)`
 *  #param options     default new | old | initial
 *  #param filter      return NO to ignore, retaind by self, target and returned id<BJLObservation>
 *  #param observer    return NO to stop observing, retaind by self, target and returned id<BJLObservation>
 *  #return id<BJLObservation> for `stopObserving`
 */
- (nullable id<BJLObservation>)bjl_kvo:(BJLPropertyMeta *)meta
                               options:(NSKeyValueObservingOptions)options
                                filter:(nullable BJLPropertyFilter)filter
                              observer:(BJLPropertyObserver)observer;

- (nullable id<BJLObservation>)bjl_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas
                                   observer:(BJLPropertiesObserver)observer;
- (nullable id<BJLObservation>)bjl_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas
                                     filter:(nullable BJLPropertyFilter)filter
                                   observer:(BJLPropertiesObserver)observer;
- (nullable id<BJLObservation>)bjl_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas
                                    options:(NSKeyValueObservingOptions)options
                                   observer:(BJLPropertiesObserver)observer;
- (nullable id<BJLObservation>)bjl_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas
                                    options:(NSKeyValueObservingOptions)options
                                     filter:(nullable BJLPropertyFilter)filter
                                   observer:(BJLPropertiesObserver)observer;

- (nullable NSArray<BJLPropertyMeta *> *)bjl_propertiesFromKeys:(NSArray<NSString *> *)whitelist;
- (nullable NSArray<BJLPropertyMeta *> *)bjl_allPropertiesExceptKeys:(NSArray<NSString *> *)blacklist;

- (void)bjl_stopAllKeyValueObservingOfTarget:(nullable id)target;
- (void)bjl_stopAllKeyValueObserving;

@end

/**
 *  Method-Parameters Observing with block.
 *  Auto stop observing before either self or the observing object is deallocated.
 */
@interface NSObject (BJLMethodParametersObserving)

@property (class, nonatomic, setter=bjl_setMpoLogsEnabled:) BOOL bjl_mpoLogsEnabled;
@property (nonatomic, setter=bjl_setMpoLogsEnabled:) BOOL bjl_mpoLogsEnabled;

- (nullable id<BJLObservation>)bjl_observe:(BJLMethodMeta *)meta
                                  observer:(BJLMethodObserver)observer;
/**
 *  #param meta        target-method, #see `BJLMakeMethod(TARGET, METHOD)`
 *  #param filter      return NO to ignore, retaind by self, target and returned id<BJLObservation>
 *  #param observer    return NO to stop observing, retaind by self, target and returned id<BJLObservation>
 *  #return id<BJLObservation> for `stopObserving`
 */
- (nullable id<BJLObservation>)bjl_observe:(BJLMethodMeta *)meta
                                    filter:(nullable BJLMethodFilter)filter
                                  observer:(BJLMethodObserver)observer;

/**
 *  merged methods should have same parameters
 */
- (nullable id<BJLObservation>)bjl_observeMerge:(NSArray<BJLMethodMeta *> *)metas
                                       observer:(BJLMethodsObserver)observer;
- (nullable id<BJLObservation>)bjl_observeMerge:(NSArray<BJLMethodMeta *> *)metas
                                         filter:(nullable BJLMethodFilter)filter
                                       observer:(BJLMethodsObserver)observer;

- (void)bjl_stopAllMethodParametersObservingOfTarget:(nullable id)target;
- (void)bjl_stopAllMethodParametersObserving;

- (void)_bjl_notifyMethodForSelector:(SEL)selector callback:(BOOL (^)(BJLMethodFilter _Nullable filter, BJLMethodObserver observer, BOOL ignoreReturnValue))callback DEPRECATED_MSG_ATTRIBUTE("use `BJLMethodNotify(TYPE, ...)`");

@end

#pragma mark -

@protocol BJLObservation <NSObject>
- (void)stopObserving;
@end

#pragma mark -

@interface BJLObservingMeta: NSObject
@property (nonatomic, readonly, weak) id target;
@property (nonatomic, readonly, copy) NSString *name;
+ (instancetype)instanceWithTarget:(id)target name:(NSString *)name;
@end

@interface BJLPropertyMeta: BJLObservingMeta
- (BOOL)isEqualToProperty:(BJLPropertyMeta *)meta;
@end

@interface BJLMethodMeta: BJLObservingMeta
- (BOOL)isEqualToMethod:(BJLMethodMeta *)meta;
@end

#pragma mark - compatibility

/**
 *  BJLiveBase 1.* > BJLiveBase 2.*
 *  1. find 'BJLProp' and replace with 'BJLV1Prop'
 *  2. find 'bjl_kvo' and replace with 'bjlv1_kvo'
 */

typedef BOOL (^BJLV1PropertyFilter)(id _Nullable old, id _Nullable now);
typedef BOOL (^BJLV1PropertyObserver)(id _Nullable old, id _Nullable now);
typedef void (^BJLV1PropertiesObserver)(id _Nullable old, id _Nullable now);

@interface NSObject (BJLV1KeyValueObserving)

- (id<BJLObservation>)bjlv1_kvo:(BJLPropertyMeta *)meta observer:(BJLV1PropertyObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");
- (id<BJLObservation>)bjlv1_kvo:(BJLPropertyMeta *)meta filter:(nullable BJLV1PropertyFilter)filter observer:(BJLV1PropertyObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");
- (id<BJLObservation>)bjlv1_kvo:(BJLPropertyMeta *)meta options:(NSKeyValueObservingOptions)options observer:(BJLV1PropertyObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");
- (id<BJLObservation>)bjlv1_kvo:(BJLPropertyMeta *)meta options:(NSKeyValueObservingOptions)options filter:(nullable BJLV1PropertyFilter)filter observer:(BJLV1PropertyObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");

- (nullable id<BJLObservation>)bjlv1_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas observer:(BJLV1PropertiesObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");
- (nullable id<BJLObservation>)bjlv1_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas filter:(nullable BJLV1PropertyFilter)filter observer:(BJLV1PropertiesObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");
- (nullable id<BJLObservation>)bjlv1_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas options:(NSKeyValueObservingOptions)options observer:(BJLV1PropertiesObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");
- (nullable id<BJLObservation>)bjlv1_kvoMerge:(NSArray<BJLPropertyMeta *> *)metas options:(NSKeyValueObservingOptions)options filter:(nullable BJLV1PropertyFilter)filter observer:(BJLV1PropertiesObserver)observer NS_SWIFT_UNAVAILABLE("Objective-C ONLY");

@end

NS_ASSUME_NONNULL_END
