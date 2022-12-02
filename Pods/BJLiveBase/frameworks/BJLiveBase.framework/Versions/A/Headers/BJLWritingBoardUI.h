//
//  BJLWritingBoardUI.h
//  BJLiveCore
//
//  Created by 凡义 on 2019/3/25.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** ### 专业版小班课小黑板 API */
@protocol BJLWritingBoardUI <NSObject>

/// 使用小黑板的唯一标识符初始化
/// @param identifier 唯一标识符
- (instancetype)initWithIdentifier:(NSString *)identifier;

/// 清除当前页面小黑板所有shapes
- (void)clearShapes;

/// 更新 userNumber 对应的shapes
/// #param userNumber userNumber
- (void)updateShapesWithUserNumber:(NSString *)userNumber;

/// 设置小黑板的背景图片
/// @param image UIImage
- (void)updateBlackboardImage:(nullable UIImage *)image;

@end

NS_ASSUME_NONNULL_END
