//
//  BJLDrawTextOptionView.h
//  BJLiveUI
//
//  Created by HuangJie on 2018/11/12.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLDrawSelectionBaseView.h"
#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLDrawTextOptionView: BJLHitTestView

@property (nonatomic, readonly) CGSize fitableSize;

- (instancetype)initWithRoom:(BJLRoom *)room;

- (void)remarkConstraintsWithPosition:(BJLRectPosition)position;

- (instancetype)init NS_UNAVAILABLE;

- (CGSize)expectedSize;

- (CGSize)textOptionSize;

@end

NS_ASSUME_NONNULL_END
