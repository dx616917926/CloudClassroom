//
//  BJLMessage+YYTextAttribute.h
//  BJLiveUIBase
//
//  Created by 凡义 on 2021/12/30.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLMessage.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLMessage (YYTextAttribute)

/** 基于YYText支持gif图文混排 */
- (nullable NSAttributedString *)attributedEmoticonCoreTextWithEmoticonSize:(CGFloat)emoticonSize
                                                                 attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
                                                                  hidePhone:(BOOL)hide
                                                                     cached:(BOOL)cached
                                                                  cachedKey:(nullable NSString *)cachedKey;

@end

NS_ASSUME_NONNULL_END
