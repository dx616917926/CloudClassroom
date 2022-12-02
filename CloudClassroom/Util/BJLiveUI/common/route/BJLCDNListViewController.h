//
//  BJLSwitchRouteViewController.h
//  Alamofire
//
//  Created by HuXin on 2021/11/30.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLCDNListViewController: UIViewController

@property (nonatomic, copy, nullable) void (^switchRouteCallback)(NSInteger index);
@property (nonatomic, copy, nullable) void (^closeCallback)(void);

- (instancetype)initWithRoom:(BJLRoom *)room shouldFullScreent:(BOOL)shouldFullScreent;

@end

NS_ASSUME_NONNULL_END
