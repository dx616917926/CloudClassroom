//
//  BJVideoPlayerCore.h
//  BaijiaYun
//
//  Created by MingLQ on 2018-04-17.
//

#import <Foundation/Foundation.h>

#import "BJVDownloadManager.h"

#if __has_include("BJVPlayerManager.h")
#import "BJVPlayerManager.h"
#endif

#if __has_include("BJVRoom.h")
#import "BJVRoom.h"
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *BJVideoPlayerCoreName(void);
FOUNDATION_EXPORT NSString *BJVideoPlayerCoreVersion(void);

#pragma mark -

@protocol BJVRequestTokenDelegate <NSObject>

@optional
- (void)requestTokenWithVideoID:(NSString *)videoID
                     completion:(void (^)(NSString *_Nullable token, NSError *_Nullable error))completion;
- (void)requestTokenWithClassID:(NSString *)classID
                      sessionID:(nullable NSString *)sessionID
                     completion:(void (^)(NSString *_Nullable token, NSError *_Nullable error))completion;

@end

@interface BJVideoPlayerCore: NSObject

@property (class, nonatomic, weak, nullable) id<BJVRequestTokenDelegate> tokenDelegate;

@end

NS_ASSUME_NONNULL_END
