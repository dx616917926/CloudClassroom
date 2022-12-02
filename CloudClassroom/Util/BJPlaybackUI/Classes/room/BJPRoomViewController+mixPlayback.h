//
//  BJPRoomViewController+mixPlayback.h
//  BJPlaybackUI
//
//  Created by Ney on 8/28/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJPRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJPRoomViewController (mixPlayback)
- (void)updateMixPlaybackUIForNewSlice;
- (void)setupSubviewsForMixPlaybackUI;
@end

NS_ASSUME_NONNULL_END
