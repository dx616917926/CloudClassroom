//
//  HXHomeMenuModel.h
//  CloudClassroom
//
//  Created by mac on 2022/10/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXHomeMenuModel : NSObject

///菜单名称
@property(nonatomic, copy) NSString *moduleName;
///菜单编码
@property(nonatomic, copy) NSString *moduleCode;
///菜单Icon
@property(nonatomic, copy) NSString *moduleIcon;
///是否显示
@property(nonatomic, assign) NSInteger isShow;
///排序
@property(nonatomic, assign) NSInteger showOrder;

@end

NS_ASSUME_NONNULL_END
