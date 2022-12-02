//
//  BJVEmoticon.h
//  BJVideoPlayerCore
//
//  Created by 辛亚鹏 on 2021/7/3.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJVEmoticon: NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *key, *name, *name_en;
@property (nonatomic, readonly) NSString *urlString;

@property (nonatomic) UIImage *cachedImage;

+ (nullable instancetype)emoticonForKey:(NSString *)key;
+ (nullable instancetype)emoticonForName:(NSString *)name;

+ (NSArray<BJVEmoticon *> *)allEmoticons;
+ (void)setAllEmoticons:(NSArray<BJVEmoticon *> *)allEmoticons;

@end

NS_ASSUME_NONNULL_END
