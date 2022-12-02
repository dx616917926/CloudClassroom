//
//  BJLAnimatedImageView+emoticon.h
//  BJLiveUI
//
//  Created by 凡义 on 2021/12/27.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLiveCore.h>
#import "BJLAnimatedImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLAnimatedImageView (emoticon)

- (void)updateBJLAnimatedImageViewEmotion:(nullable BJLEmoticon *)emoticon
                         emotionURLString:(nullable NSString *)emotionURLString
                                loopCount:(NSUInteger)loopCount
                                completed:(nullable void (^)(UIImage *_Nullable image, NSError *_Nullable error, NSURL *_Nullable imageURL))completedCallback;

@end

NS_ASSUME_NONNULL_END
