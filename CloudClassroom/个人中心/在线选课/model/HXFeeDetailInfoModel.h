//
//  HXFeeDetailInfoModel.h
//  CloudClassroom
//
//  Created by mac on 2022/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXFeeDetailInfoModel : NSObject

///费项名称
@property(nonatomic, copy) NSString *payBackName;
///批次名称
@property(nonatomic, copy) NSString *batchName;
///单价
@property(nonatomic, assign) CGFloat price;
///显示的单价（如果有学校不需要显示单价，则该字段为空
@property(nonatomic, copy) NSString *priceShow;

@end

NS_ASSUME_NONNULL_END
