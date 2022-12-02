//
//  BJLRoomViewController.m
//  BJLiveUI-Base-BJLiveUI
//
//  Created by Ney on 7/8/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase.h>
#import "BJLRoomViewController.h"
#import "BJLRoomViewController+protected.h"

#pragma mark - BJLRoomViewController
#define kICRoomVCName @"BJLIcRoomViewController"
#define kSCRoomVCName @"BJLScRoomViewController"
#define kEERoomVCName @"BJLiveUIEE.BJLEERoomViewController"
#define kSellVCName   @"BJLSellViewController"

@interface BJLRoomViewController () <BJLInnerRoomVCDelegate>
@property (nonatomic, strong) UIViewController<BJLInnerRoomVCProtocol> *roomVC;

@property (nonatomic, readwrite) BJLRoomVCType roomVCType;
@property (nonatomic, strong) BJLRoomID *roomIDStorage;
@property (nonatomic, strong) BJLRoomCode *roomCodeStorage;
@end

@implementation BJLRoomViewController
@synthesize delegate = _delegate;

#pragma mark - api
+ (__kindof instancetype)instanceWithRoomType:(BJLRoomVCType)type roomCode:(BJLRoomCode *)roomCode {
    Class cls = nil;
    BJLRoomViewController *newRoomVCinstance = nil;

    if (type == BJLRoomVCTypeBigClass) {
        cls = NSClassFromString(kSCRoomVCName);
    }
    else if (type == BJLRoomVCTypeSmallClass) {
        cls = NSClassFromString(kICRoomVCName);
    }
    else if (type == BJLRoomVCTypeEnterpriseEdition) {
        cls = NSClassFromString(kEERoomVCName);
    }
    else if (type == BJLRoomVCTypeSell) {
        cls = NSClassFromString(kSellVCName);
    }

    if (cls && [cls respondsToSelector:@selector(instanceWithSecret:userName:userAvatar:)]) {
        id<BJLInnerRoomVCProtocol> scVC = (id<BJLInnerRoomVCProtocol>)cls;
        newRoomVCinstance = [[self alloc] init];
        newRoomVCinstance.roomVC = [scVC instanceWithSecret:roomCode.code userName:roomCode.userName userAvatar:roomCode.userAvatar];
        newRoomVCinstance.roomCodeStorage = roomCode.copy;
        newRoomVCinstance.roomVCType = type;
        [newRoomVCinstance setupCallbackForInnerVC];
    }
    else {
        NSLog(@"%@ 不存在, %@初始化失败", kSCRoomVCName, NSStringFromClass(self));
    }

    return newRoomVCinstance;
}

+ (__kindof instancetype)instanceWithRoomType:(BJLRoomVCType)type roomID:(BJLRoomID *)roomID {
    Class cls = nil;
    BJLRoomViewController *newRoomVCinstance = nil;

    if (type == BJLRoomVCTypeBigClass) {
        cls = NSClassFromString(kSCRoomVCName);
    }
    else if (type == BJLRoomVCTypeSmallClass) {
        cls = NSClassFromString(kICRoomVCName);
    }
    else if (type == BJLRoomVCTypeEnterpriseEdition) {
        cls = NSClassFromString(kEERoomVCName);
    }
    else if (type == BJLRoomVCTypeSell) {
        cls = NSClassFromString(kSellVCName);
    }

    if (cls && [cls respondsToSelector:@selector(instanceWithID:apiSign:user:)]) {
        id<BJLInnerRoomVCProtocol> scVC = (id<BJLInnerRoomVCProtocol>)cls;
        newRoomVCinstance = [[self alloc] init];
        newRoomVCinstance.roomVC = [scVC instanceWithID:roomID.roomID apiSign:roomID.apiSign user:roomID.user];
        newRoomVCinstance.roomIDStorage = roomID.copy;
        newRoomVCinstance.roomVCType = type;
        [newRoomVCinstance setupCallbackForInnerVC];
    }
    else {
        NSLog(@"%@ 不存在, %@初始化失败", kICRoomVCName, NSStringFromClass(self));
    }

    return newRoomVCinstance;
}

- (BJLRoom *)room {
    if ([self.roomVC respondsToSelector:@selector(room)]) {
        return [self.roomVC performSelector:@selector(room)];
    }
    return nil;
}

- (UIViewController *)controller {
    return self.roomVC;
}

- (BJLRoomID *)roomID {
    return self.roomIDStorage.copy;
}

- (BJLRoomCode *)roomCode {
    return self.roomCodeStorage.copy;
}

- (void)setCustomLampContent:(NSString *)customLampContent {
    if ([self.roomVC respondsToSelector:@selector(setCustomLampContent:)]) {
        [self.roomVC performSelector:@selector(setCustomLampContent:) withObject:customLampContent];
    }
}

- (NSString *)customLampContent {
    if ([self.roomVC respondsToSelector:@selector(customLampContent)]) {
        return [self.roomVC performSelector:@selector(customLampContent)];
    }
    return nil;
}

/** 退出直播间 */
- (void)exitWithCompletion:(void (^)(void))completion {
    if ([self.roomVC respondsToSelector:@selector(exitWithCompletion:)]) {
        [self.roomVC performSelector:@selector(exitWithCompletion:) withObject:completion];
    }
}

#pragma mark - view life
- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.roomVC) {
        [self bjl_addChildViewController:self.roomVC superview:self.view];
        [self.roomVC.view bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
            make.edges.equalTo(self.view);
        }];
    }
}

#pragma mark - UIViewControllerRotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.roomVC) {
        return [self.roomVC supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.roomVC) {
        return [self.roomVC preferredInterfaceOrientationForPresentation];
    }
    return self.bjl_preferredInterfaceOrientation;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    if (self.roomVC) {
        return [self.roomVC modalPresentationStyle];
    }
    return UIModalPresentationFullScreen;
}

#pragma mark -

- (BOOL)prefersStatusBarHidden {
    return [self.roomVC prefersStatusBarHidden];
}

#pragma mark - helper

- (void)setupObserverForInnerVC:(UIViewController *)vc {
    bjl_weakify(self);
    [self bjl_observe:BJLMakeMethod(vc, roomViewControllerEnterRoomSuccess:)
             observer:^BOOL(UIViewController<BJLInnerRoomVCProtocol> *vc) {
                 bjl_strongify(self);
                 [self roomViewControllerEnterRoomSuccess:vc];
                 return NO;
             }];
    [self bjl_observe:BJLMakeMethod(vc, roomViewController:enterRoomFailureWithError:)
             observer:^BOOL(UIViewController<BJLInnerRoomVCProtocol> *vc, BJLError *error) {
                 bjl_strongify(self);
                 [self roomViewController:vc enterRoomFailureWithError:error];
                 return NO;
             }];
    [self bjl_observe:BJLMakeMethod(vc, roomViewController:willExitWithError:)
             observer:^BOOL(UIViewController<BJLInnerRoomVCProtocol> *vc, BJLError *error) {
                 bjl_strongify(self);
                 [self roomViewController:vc willExitWithError:error];
                 return NO;
             }];
    [self bjl_observe:BJLMakeMethod(vc, roomViewController:didExitWithError:)
             observer:^BOOL(UIViewController<BJLInnerRoomVCProtocol> *vc, BJLError *error) {
                 bjl_strongify(self);
                 [self roomViewController:vc didExitWithError:error];
                 return NO;
             }];
}

- (void)setupCallbackForInnerVC {
    if (!self.roomVC) { return; }

    if ([self.roomVC respondsToSelector:@selector(setDelegate:)]) {
        self.roomVC.delegate = self;
    }

    [self setupObserverForInnerVC:self.roomVC];
}

#pragma mark sc class delegate

- (void)roomViewControllerEnterRoomSuccess:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController {
    if ([self.delegate respondsToSelector:@selector(roomViewControllerEnterRoomSuccess:)]) {
        [self.delegate roomViewControllerEnterRoomSuccess:self];
    }
}

- (void)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController enterRoomFailureWithError:(BJLError *)error {
    if ([self.delegate respondsToSelector:@selector(roomViewController:enterRoomFailureWithError:)]) {
        [self.delegate roomViewController:self enterRoomFailureWithError:error];
    }
}

- (void)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController
         willExitWithError:(nullable BJLError *)error {
    if ([self.delegate respondsToSelector:@selector(roomViewController:willExitWithError:)]) {
        [self.delegate roomViewController:self willExitWithError:error];
    }
}

- (void)roomViewController:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController
          didExitWithError:(nullable BJLError *)error {
    if ([self.delegate respondsToSelector:@selector(roomViewController:didExitWithError:)]) {
        [self.delegate roomViewController:self didExitWithError:error];
    }
}

- (nullable UIViewController *)roomViewControllerToShare:(UIViewController<BJLInnerRoomVCProtocol> *)roomViewController {
    if ([self.delegate respondsToSelector:@selector(roomViewControllerToShare:)]) {
        return [self.delegate roomViewControllerToShare:self];
    }
    return nil;
}

- (void)roomViewController:(BJLRoomViewController *)sellViewController openListFromView:(UIView *)superview closeCallback:(nullable void (^)(void))closeCallback {
    if ([self.delegate respondsToSelector:@selector(roomViewController:openListFromView:closeCallback:)]) {
        [self.delegate roomViewController:self openListFromView:superview closeCallback:closeCallback];
    }
}

- (void)roomViewController:(BJLRoomViewController *)sellViewController openSellItem:(BJLSellItem *)item {
    if ([self.delegate respondsToSelector:@selector(roomViewController:openSellItem:)]) {
        [self.delegate roomViewController:self openSellItem:item];
    }
}

@end

@implementation BJLRoomCode: NSObject
- (id)copy {
    BJLRoomCode *code = [[BJLRoomCode alloc] init];
    code.code = self.code;
    code.userName = self.userName;
    code.userAvatar = self.userAvatar;
    return code;
}
@end

@implementation BJLRoomID: NSObject
- (id)copy {
    BJLRoomID *code = [[BJLRoomID alloc] init];
    code.roomID = self.roomID;
    code.apiSign = self.apiSign;
    code.user = self.user;
    return code;
}
@end
