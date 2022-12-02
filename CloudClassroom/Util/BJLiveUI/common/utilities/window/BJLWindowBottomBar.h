//
//  BJLWindowBottomBar.h
//  BJLiveUI
//
//  Created by MingLQ on 2018-09-25.
//  Copyright © 2018 BaijiaYun. All rights reserved.
//

#if __has_feature(modules) && BJL_USE_SEMANTIC_IMPORT
@import BJLiveBase;
#else
#import <BJLiveBase/BJLiveBase.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BJLWindowBottomBar: UIView

@property (nonatomic, readonly) UIView *resizeHandleView;
@property (nonatomic, readonly) UIView *resizeHandleImageView;

@property (nonatomic, readonly) UIView *backgroundView;

@end

NS_ASSUME_NONNULL_END
