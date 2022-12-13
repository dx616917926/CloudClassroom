//
//  HXPersonalInforModel.h
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXPersonalInforModel : NSObject

@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *content;
//签名图片
@property(nonatomic, copy) NSString *signImgUrl;

@end

NS_ASSUME_NONNULL_END
