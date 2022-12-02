/*
 * Module:   美颜与图像处理参数设置类
 *
 * Function: 修改美颜、滤镜、绿幕等参数
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef UIImage BRTCImage;

NS_ASSUME_NONNULL_BEGIN

/// 美颜及动效参数管理
@interface BRTCBeautyManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * 设置美颜级别
 * @param level 美颜级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setBeautyLevel:(float)level;

/**
 * 设置美白级别
 *
 * @param level 美白级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setWhitenessLevel:(float)level;
@end

NS_ASSUME_NONNULL_END
