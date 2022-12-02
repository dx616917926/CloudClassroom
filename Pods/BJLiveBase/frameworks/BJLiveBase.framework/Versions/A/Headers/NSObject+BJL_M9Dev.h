//
//  NSObject+BJL_M9Dev.h
//  M9Dev
//
//  Created by MingLQ on 2016-04-20.
//  Copyright (c) 2016 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

// #see M9Dev - https://github.com/iwill/

NS_ASSUME_NONNULL_BEGIN

#define bjl_orNil(_OBJECT, METHOD) ({ __typeof__(_OBJECT) OBJECT = _OBJECT; [OBJECT METHOD] ? OBJECT : nil; })

@interface NSObject (BJL_M9Dev)

- (nullable id)bjl_if:(BOOL)condition;

- (nullable id)bjl_as:(Class)clazz;
- (nullable id)bjl_asMemberOfClass:(Class)clazz;
- (nullable id)bjl_asProtocol:(Protocol *)protocol;
- (nullable id)bjl_ifRespondsToSelector:(SEL)selector;

- (nullable NSArray *)bjl_asArray;
- (nullable NSDictionary *)bjl_asDictionary;

- (nullable id)bjl_performIfRespondsToSelector:(SEL)selector;
- (nullable id)bjl_performIfRespondsToSelector:(SEL)selector withObject:(nullable id)object;
- (nullable id)bjl_performIfRespondsToSelector:(SEL)selector withObject:(nullable id)object1 withObject:(nullable id)object2;

/* C */
- (float)bjl_floatValue;
- (double)bjl_doubleValue;

/* C More */
- (long long)bjl_longLongValue;
- (unsigned long long)bjl_unsignedLongLongValue;

/* OC */
- (BOOL)bjl_boolValue;
- (NSInteger)bjl_integerValue;
- (NSInteger)bjl_integerValueOrNotFound;

/* OC More */
- (NSUInteger)bjl_unsignedIntegerValue;
- (NSUInteger)bjl_unsignedIntegerValueOrNotFound;

@end

#pragma mark -

@interface NSArray <ObjectType>(BJL_M9Dev)

@property (nonatomic, readonly, nullable) __kindof NSArray<ObjectType> *bjl_orNil;

// indexOfObject:/containsObject:/removeObject: + compareSelector:/comparator:

- (nullable ObjectType)bjl_objectAtIndex:(NSUInteger)index;
- (BOOL)bjl_containsIndex:(NSUInteger)index;

- (NSArray<ObjectType> *)bjl_arrayByRemovingObjectsWithBlock:(BOOL(NS_NOESCAPE ^)(ObjectType))block;

@end

@interface NSMutableArray <ObjectType>(BJL_M9Dev)

- (BOOL)bjl_addObject:(nullable ObjectType)anObject;
- (BOOL)bjl_insertObject:(nullable ObjectType)anObject atIndex:(NSUInteger)index;
- (BOOL)bjl_removeObjectAtIndex:(NSUInteger)index;
- (BOOL)bjl_replaceObjectAtIndex:(NSUInteger)index withObject:(nullable ObjectType)anObject;

// (NSExtendedMutableArray)

- (void)bjl_removeObject:(nullable ObjectType)anObject inRange:(NSRange)range;
- (void)bjl_removeObject:(nullable ObjectType)anObject;
- (void)bjl_removeObjectIdenticalTo:(nullable ObjectType)anObject inRange:(NSRange)range;
- (void)bjl_removeObjectIdenticalTo:(nullable ObjectType)anObject;

- (void)bjl_removeObjectsWithBlock:(BOOL(NS_NOESCAPE ^)(ObjectType))block;

@end

#pragma mark -

@interface NSMutableSet <ObjectType>(BJL_M9Dev)

- (BOOL)bjl_addObject:(nullable ObjectType)anObject;
- (BOOL)bjl_removeObject:(nullable ObjectType)anObject;

@end

#pragma mark -

@interface NSDictionary <KeyType, ObjectType>(BJL_M9Dev)

@property (nonatomic, readonly, nullable) __kindof NSDictionary<KeyType, ObjectType> *bjl_orNil;

/**
 * ???: add int, remove unsignedXxxx
 *  #see NSString+NSStringExtensionMethods @ xxxValue
 *
 * NOTE: detect CGFloat is float or double:
 *  #if defined(__LP64__) && __LP64__
 *      CGFloat is double
 *  #elif
 #      CGFloat is float
 *  #endif
 */

/* C */
- (float)bjl_floatForKey:(nullable KeyType)aKey;
- (float)bjl_floatForKey:(nullable KeyType)aKey defaultValue:(float)defaultValue;
- (double)bjl_doubleForKey:(nullable KeyType)aKey;
- (double)bjl_doubleForKey:(nullable KeyType)aKey defaultValue:(double)defaultValue;

/* C More */
- (long long)bjl_longLongForKey:(nullable KeyType)aKey;
- (long long)bjl_longLongForKey:(nullable KeyType)aKey defaultValue:(long long)defaultValue;
- (unsigned long long)bjl_unsignedLongLongForKey:(nullable KeyType)aKey;
- (unsigned long long)bjl_unsignedLongLongForKey:(nullable KeyType)aKey defaultValue:(unsigned long long)defaultValue;

/* OC */
- (BOOL)bjl_boolForKey:(nullable KeyType)aKey;
- (BOOL)bjl_boolForKey:(nullable KeyType)aKey defaultValue:(BOOL)defaultValue;
- (NSInteger)bjl_integerForKey:(nullable KeyType)aKey;
- (NSInteger)bjl_integerOrNotFoundForKey:(nullable KeyType)aKey;
- (NSInteger)bjl_integerForKey:(nullable KeyType)aKey defaultValue:(NSInteger)defaultValue;

/* OC More */
- (NSUInteger)bjl_unsignedIntegerForKey:(nullable KeyType)aKey;
- (NSUInteger)bjl_unsignedIntegerOrNotFoundForKey:(nullable KeyType)aKey;
- (NSUInteger)bjl_unsignedIntegerForKey:(nullable KeyType)aKey defaultValue:(NSUInteger)defaultValue;

/* OC Object */
- (nullable NSNumber *)bjl_numberForKey:(nullable KeyType)aKey;
- (nullable NSNumber *)bjl_numberForKey:(nullable KeyType)aKey defaultValue:(nullable NSNumber *)defaultValue;
- (nullable NSString *)bjl_stringForKey:(nullable KeyType)aKey;
- (nullable NSString *)bjl_stringOrEmptyStringForKey:(nullable KeyType)aKey;
- (nullable NSString *)bjl_stringForKey:(nullable KeyType)aKey defaultValue:(nullable NSString *)defaultValue;
- (nullable NSArray *)bjl_arrayForKey:(nullable KeyType)aKey;
- (nullable NSArray *)bjl_arrayForKey:(nullable KeyType)aKey defaultValue:(nullable NSArray *)defaultValue;
- (nullable NSDictionary *)bjl_dictionaryForKey:(nullable KeyType)aKey;
- (nullable NSDictionary *)bjl_dictionaryForKey:(nullable KeyType)aKey defaultValue:(nullable NSDictionary *)defaultValue;
- (nullable NSData *)bjl_dataForKey:(nullable KeyType)aKey;
- (nullable NSData *)bjl_dataForKey:(nullable KeyType)aKey defaultValue:(nullable NSData *)defaultValue;
- (nullable NSDate *)bjl_dateForKey:(nullable KeyType)aKey;
- (nullable NSDate *)bjl_dateForKey:(nullable KeyType)aKey defaultValue:(nullable NSDate *)defaultValue;
- (nullable NSURL *)bjl_URLForKey:(nullable KeyType)aKey;
- (nullable NSURL *)bjl_URLForKey:(nullable KeyType)aKey defaultValue:(nullable NSURL *)defaultValue;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey defaultValue:(nullable ObjectType)defaultValue;

/* OC Object More */
// !!!: Be careful when using this method on objects represented by a class cluster.
// #see `isKindOfClass:` from Documentation of `NSObject`
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey class:(nullable Class)clazz;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey class:(nullable Class)clazz defaultValue:(nullable ObjectType)defaultValue;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey protocol:(nullable Protocol *)protocol;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey protocol:(nullable Protocol *)protocol defaultValue:(nullable ObjectType)defaultValue;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey class:(nullable Class)clazz protocol:(nullable Protocol *)protocol;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey class:(nullable Class)clazz protocol:(nullable Protocol *)protocol defaultValue:(nullable ObjectType)defaultValue;
- (nullable ObjectType)bjl_objectForKey:(nullable KeyType)aKey callback:(nullable ObjectType _Nullable(NS_NOESCAPE ^)(ObjectType object))callback;

@end

@interface NSMutableDictionary <KeyType, ObjectType>(BJL_M9Dev)

- (void)bjl_removeObjectForKey:(nullable KeyType)aKey;
- (void)bjl_setObject:(nullable ObjectType)anObject forKey:(nullable KeyType<NSCopying>)aKey;

- (void)bjl_addEntriesFromDictionary:(nullable NSDictionary<KeyType, ObjectType> *)otherDictionary;
- (void)bjl_removeObjectsForKeys:(nullable NSArray<KeyType> *)keyArray;
- (void)bjl_setDictionary:(nullable NSDictionary<KeyType, ObjectType> *)otherDictionary;

@end

#pragma mark -

@interface NSString (BJL_M9Dev)

@property (nonatomic, readonly, nullable) __kindof NSString *bjl_orNil;

- (BOOL)bjl_isEqualToString:(nullable NSString *)aString;

- (NSString *)bjl_stringByAppendingURLParameterKey:(nullable NSString *)key value:(nullable id)value;

@end

@interface NSMutableString (BJL_M9Dev)

- (void)bjl_appendURLParameterKey:(nullable NSString *)key value:(nullable id)value;

@end

#pragma mark -

@interface NSURL (BJL_M9Dev)

+ (nullable instancetype)bjl_URLWithString:(nullable NSString *)URLString;

// take the first if the query contains multiple values on an identical name
@property (nonatomic, readonly, copy, nullable) NSDictionary<NSString *, NSString *> *bjl_queryDictionary;
+ (nullable NSString *)bjl_queryStringFromDictionary:(nullable NSDictionary<NSString *, id> *)dictionary;

@end

#pragma mark -

@interface NSUserDefaults (BJL_M9Dev)

- (nullable NSNumber *)bjl_numberForKey:(NSString *)defaultName;

@end

/*
#pragma mark - YYModel

@interface NSObject (BJL_M9Dev_YYModel)

+ (nullable NSArray *)bjl_modelArrayWithJSON:(id)json;
+ (nullable NSDictionary *)bjl_modelDictionaryWithJSON:(id)json;

@end */

NS_ASSUME_NONNULL_END
