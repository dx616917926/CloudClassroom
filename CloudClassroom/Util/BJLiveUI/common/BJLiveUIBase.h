//
//  BJLiveUI-Base.h
//  BJLiveUI-Base
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLiveCore.h>

#if __has_include("BJLAsCameraViewController.h")
#import "BJLAsCameraViewController.h"
#endif

#if __has_include("BJLQRCodeScanner.h")
#import "BJLQRCodeScanner.h"
#endif

#if __has_include("BJLPhotoListViewController.h")
#import "BJLPhotoListViewController.h"
#endif

#if __has_include("BJLPhotoBrowserView.h")
#import "BJLPhotoBrowserView.h"
#endif

#if __has_include("BJLRoomViewController.h")
#import "BJLRoomViewController.h"
#endif

#if __has_include("BJLCheckGuideViewController.h")
#import "BJLCheckGuideViewController.h"
#endif

#if __has_include("BJLAuthRequestViewController.h")
#import "BJLAuthRequestViewController.h"
#endif

FOUNDATION_EXPORT NSString *BJLiveUIBaseName(void);
FOUNDATION_EXPORT NSString *BJLiveUIBaseVersion(void);
