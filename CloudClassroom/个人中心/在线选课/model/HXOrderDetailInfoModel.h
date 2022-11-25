//
//  HXOrderDetailInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXOrderDetailInfoModel : NSObject

///课程名称
@property(nonatomic, copy) NSString *termCourseName;
///学期
@property(nonatomic, copy) NSString *term;
///单价
@property(nonatomic, assign) CGFloat price;
///显示的单价（如果有学校不需要显示单价，则该字段为空
@property(nonatomic, copy) NSString *priceShow;

@end

NS_ASSUME_NONNULL_END
