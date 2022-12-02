//
//  BJLQuestionResponderManager.h
//  BJLiveUIBase
//
//  Created by HuXin on 2022/2/25.
//  Copyright © 2022 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLRoom.h>
#import <BJLiveCore/BJLUser.h>
NS_ASSUME_NONNULL_BEGIN

@interface BJLQuestionResponderManager: NSObject
@property (nonatomic, nullable) void (^showErrorMessageCallback)(NSString *message);
@property (nonatomic, nullable) void (^questionResponderInviteSpeakCallback)(BJLUser *user);
@property (nonatomic, nullable) void (^questionResponderSuccessCallback)(BJLUser *user, UIButton *_Nullable button);
- (instancetype)initWithRoom:(BJLRoom *)room roomViewController:(UIViewController *)roomViewController superView:(UIView *)superView;
- (void)makeObservingForQuestionResponder;
- (void)openQuestionResponder;
- (void)destoryStudentQuestionResponderViewController;
- (void)showQuestionResponderEffectViewControllerUser:(BJLUser *)user likeButton:(UIButton *_Nullable)button fullscreenLayer:(UIView *)fullscreenLayer;
@end

NS_ASSUME_NONNULL_END
