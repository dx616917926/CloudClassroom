//
//  BJLCreateRainViewController.h
//  BJLiveUI
//
//  Created by xyp on 2021/1/8.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>
#import <BJLiveBase/BJLViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLCreateRainViewController: BJLViewController

- (instancetype)initWithRoom:(BJLRoom *)room;

@property (nonatomic) void (^showResultCallback)(void);

- (BOOL)keyboardDidShow;
@end

NS_ASSUME_NONNULL_END
