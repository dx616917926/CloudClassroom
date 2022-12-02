//
//  BJPCatalogueViewController.h
//  BJPlaybackUI
//
//  Created by 凡义 on 2021/1/14.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJVRoom.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPCatalogueViewController: UIViewController

- (void)setupObserversWithRoom:(BJVRoom *)room;

@property (nonatomic, copy, nullable) void (^updateCatalogueProgressCallback)(BJPPPTCatalogueModel *catalogue);

@end

NS_ASSUME_NONNULL_END
