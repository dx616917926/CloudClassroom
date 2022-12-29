//
//  HXSignView.h
//  CloudClassroom
//
//  Created by mac on 2022/12/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXSignView : UIView

/**
 * 获取签名图片
 */
- (UIImage *)getSignatureImage;
/**
 * 清除签名
 */
- (void)clearSignature;

@end

NS_ASSUME_NONNULL_END
