//
//  BJLCreateRainViewController.m
//  BJLiveUI
//
//  Created by xyp on 2021/1/8.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

#import <BJLiveCore/BJLiveCore.h>

#import "BJLCreateRainViewController.h"
#import "BJLEnvelopesRainView.h"

@interface BJLCreateRainViewController () <UIGestureRecognizerDelegate>

@property (nonatomic) BJLEnvelopesRainView *envelopesRainView;
@property (nonatomic, weak) BJLRoom *room;

@end

@implementation BJLCreateRainViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super init];
    if (self) {
        self.room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor clearColor];
    [self makeSubview];
    [self makeCallback];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)makeSubview {
    self.envelopesRainView = [BJLEnvelopesRainView createEnvelopesRainViewWithRoom:self.room];
    [self.view addSubview:self.envelopesRainView];
    [self.envelopesRainView bjl_makeConstraints:^(BJLConstraintMaker *_Nonnull make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)makeCallback {
    bjl_weakify(self);
    [self.envelopesRainView setCloseCallback:^{
        bjl_strongify(self);
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [self bjl_removeFromParentViewControllerAndSuperiew];
                                 }];
    }];
    [self.envelopesRainView setCreateRainCallback:^(NSInteger count, NSInteger score, NSInteger duration) {
        bjl_strongify(self);
        [self.room.roomVM createEnvelopeRainWithAmount:count score:score duration:duration completion:^(NSInteger envelopeID, BJLError *_Nullable error) {
            bjl_strongify(self);
            [self dismissViewControllerAnimated:YES
                                     completion:^{
                                         [self.room.roomVM startEnvelopRainWithID:envelopeID duration:duration];
                                     }];
        }];
    }];
}

#pragma mark - keyboard observer
- (BOOL)keyboardDidShow {
    if (self.envelopesRainView.countTextField.isFirstResponder || self.envelopesRainView.scoreTextField.isFirstResponder) {
        if (self.envelopesRainView.countTextField.isFirstResponder) {
            [self.envelopesRainView.countTextField resignFirstResponder];
        }
        if (self.envelopesRainView.scoreTextField.isFirstResponder) {
            [self.envelopesRainView.scoreTextField resignFirstResponder];
        }
        return NO;
    }
    return YES;
}

@end
