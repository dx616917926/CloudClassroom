//
//  BJPRoomViewController+observer.h
//  BJPlaybackUI
//
//  Created by 辛亚鹏 on 2017/8/28.
//
//

#import "BJPRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJPRoomViewController (observer)

- (void)addObserversForPlaybackRoom;
- (void)updateLamp;
@end

NS_ASSUME_NONNULL_END
