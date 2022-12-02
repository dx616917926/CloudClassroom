//
//  BJLTextImageViewAttachment.h
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/12/24.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLYYText.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLTextImageViewAttachment: BJLYYTextAttachment

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGSize size;

@end

NS_ASSUME_NONNULL_END
