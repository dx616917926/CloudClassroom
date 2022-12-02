//
//  BJLMajorNotice.h
//  BJLiveCore
//
//  Created by 凡义 on 2021/4/1.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLMajorNoticeModel: NSObject

@property (nonatomic, readonly, nullable) NSString *noticeID;
@property (nonatomic, readonly, nullable) NSString *noticeText;
@property (nonatomic, readonly, nullable) NSString *linkURLString;

@end

@interface BJLMajorNotice: NSObject

/** alpha 取值范围[0, 100] */
@property (nonatomic, readonly, nullable) NSString *noticeID;
@property (nonatomic, readonly) NSUInteger rollTimeInterval;
@property (nonatomic, readonly) CGFloat fontSize;
@property (nonatomic, readonly) NSString *fontColor;
@property (nonatomic, readonly) CGFloat fontAlpha;
@property (nonatomic, readonly) NSString *borderColor;
@property (nonatomic, readonly) CGFloat borderAlpha;
@property (nonatomic, readonly) NSString *backgroundColor;
@property (nonatomic, readonly) CGFloat backgroundAlpha;

@property (nonatomic, readonly) NSArray<BJLMajorNoticeModel *> *noticeList;

@end

NS_ASSUME_NONNULL_END
