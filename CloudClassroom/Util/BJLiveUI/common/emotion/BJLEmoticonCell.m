//
//  BJLEmoticonCell.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-04-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLEmoticonCell.h"

#import "BJLViewImports.h"
#import "BJLAnimatedImageView+emoticon.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLEmoticonCell ()

@property (nonatomic) BJLAnimatedImageView *imageView;

@end

@implementation BJLEmoticonCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = ({
            BJLAnimatedImageView *imageView = [BJLAnimatedImageView new];
            [self.contentView addSubview:imageView];
            [imageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            imageView;
        });
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    [self.imageView bjl_cancelCurrentImageLoading];
}

- (void)updateWithEmoticon:(BJLEmoticon *)emoticon {
    [self.imageView updateBJLAnimatedImageViewEmotion:emoticon
                                     emotionURLString:emoticon.urlString
                                            loopCount:0
                                            completed:^(UIImage *_Nullable image, NSError *_Nullable error, NSURL *_Nullable imageURL) {
                                                if (image) {
                                                    //SDWebImage如果已经有缓存就会直接获取缓存数据，所以这里可以直接这么写
                                                    emoticon.cachedImage = image;
                                                }
                                            }];
}

@end

NS_ASSUME_NONNULL_END
