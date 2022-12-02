//
//  BJLDrawShapeSelectView.h
//  BJLiveUI
//
//  Created by HuangJie on 2018/10/29.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLDrawSelectionBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLDrawShapeSelectView: BJLDrawSelectionBaseView

- (NSString *)shapeOptionKeyWithType:(BJLDrawingShapeType)shapeType filled:(BOOL)filled;

- (CGSize)expectedSize;

@end

NS_ASSUME_NONNULL_END
