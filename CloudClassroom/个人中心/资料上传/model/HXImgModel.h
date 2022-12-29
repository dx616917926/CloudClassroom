//
//  HXImgModel.h
//  CloudClassroom
//
//  Created by mac on 2022/12/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXImgModel : NSObject

///图片标题
@property(nonatomic, copy) NSString *imgTitle;
///图片地址
@property(nonatomic, copy) NSString *imgUrl;
///图片类型
@property(nonatomic, copy) NSString *typeName;


@end

NS_ASSUME_NONNULL_END
