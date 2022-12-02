//
//  BJLiveBase.h
//  BJLiveBase
//
//  Created by MingLQ on 2018-09-10.
//  Copyright (c) 2018 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <Foundation/Foundation.h>

// Base
#if __has_include("BJL_EXTScope.h") // extobjc
    #import "BJL_metamacros.h"
    #import "BJL_EXTScope.h"
#endif
#if __has_include("BJLiveBase+Foundation.h") // Foundation
    #import "BJLiveBase+Foundation.h"
#endif
#if __has_include("BJLiveBase+UIKit.h") // UIKit
    #import "BJLiveBase+UIKit.h"
#endif

#if __has_include("BJLAuthorization.h") // Auth
    #import "BJLAuthorization.h"
    #import "BJLLocalNetworkAccessChecker.h"
#endif

#if __has_include("BJLDownloadManager.h") // Download
    #import "BJLDownloadManager.h"
#endif

#if __has_include("BJLProgressHUD.h") // HUD
    #import "BJLProgressHUD.h"
#endif

#if __has_include("BJLNetworking.h") // Networking
    // #import "BJLAFNetworking.h"
    // #import "UIKit+BJLAFNetworking.h"
    #import "BJLNetworking.h"
    #import "BJLUserAgent.h"
    #import "UIKit+BJLAFNetworking.h"
    #if __has_include("BJLNetworking+BaijiaYun.h") // Networking+BaijiaYun
        #import "BJLNetworking+BaijiaYun.h"
    #endif
#endif

#if __has_include("BJLPSWebSocket.h") // PocketSocket
    #if __has_include("BJLPSWebSocketDriver.h") // PocketSocket/Core
        #import "BJLPSWebSocketDriver.h"
        // #import "BJLPSWebSocketTypes.h"
    #endif
    #if __has_include("BJLPSWebSocket.h") // PocketSocket/Client
        #import "BJLPSWebSocket.h"
    #endif
    #if __has_include("BJLPSWebSocketServer.h") // PocketSocket/Server
        #import "BJLPSWebSocketServer.h"
    #endif
#endif

#if __has_include("BJLWebImage.h") // WebImage
    #if __has_include("BJLWebImageLoader_AF.h") // WebImage/BJLWebImage
        #import "BJLWebImageLoader.h"
        // #import "BJLWebImage.h"
        // #import "BJLWebImageLoaderReceipt.h"
    #endif
    #if __has_include("BJLWebImageLoader_AF.h") // WebImage/AFNetworking
        #import "BJLWebImageLoader_AF.h"
    #endif
    #if __has_include("BJLWebImageLoader_SD.h") // WebImage/SDWebImage
        #import "BJLWebImageLoader_SD.h"
    #endif
    #if __has_include("BJLWebImageLoader_YY.h") // WebImage/YYWebImage
        #import "BJLWebImageLoader_YY.h"
    #endif
#endif

#if __has_include("BJLYYFPSLabel.h") // YYFPSLabel
    #import "BJLYYWeakProxy.h"
    #import "BJLYYFPSLabel.h"
#endif

#if __has_include("BJLYYModel.h") // YYModel
    #import "BJLYYModel.h"
#endif

#if __has_include("BJLBundle.h")
    #import "BJLBundle.h"
#endif

#if __has_include("BJLSlideshowUI.h")
    #import "BJLSlideshowUI.h"
    #import "BJLDocument.h"
    #import "BJLSlidePage.h"
    #import "BJLBlackboardUI.h"
    #import "BJLWritingBoardUI.h"
#endif

