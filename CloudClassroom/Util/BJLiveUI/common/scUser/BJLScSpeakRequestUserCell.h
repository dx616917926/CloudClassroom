//
//  BJLScSpeakRequestUserCell.h
//  BJLiveUI
//
//  Created by 凡义 on 2019/9/24.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

#define BJLScSpeakRequestUserCellOnePixel ({                \
    static CGFloat _BJLScOnePixel;                          \
    static dispatch_once_t onceToken;                       \
    dispatch_once(&onceToken, ^{                            \
        _BJLScOnePixel = 1.0 / [UIScreen mainScreen].scale; \
    });                                                     \
    _BJLScOnePixel;                                         \
})

#define BJLScSpeakRequestUserCellViewSpaceL 15.0
#define BJLScSpeakRequestUserCellViewSpaceM 10.0

NS_ASSUME_NONNULL_BEGIN

@interface BJLScSpeakRequestUserCell: UITableViewCell

@property (nonatomic, copy, nullable) void (^agreeRequestCallback)(BJLScSpeakRequestUserCell *cell, BOOL allow);

- (void)updateWithUser:(BJLUser *)user;

@end

NS_ASSUME_NONNULL_END
