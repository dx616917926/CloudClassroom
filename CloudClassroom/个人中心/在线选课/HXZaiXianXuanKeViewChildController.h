//
//  HXZaiXianXuanKeViewChildController.h
//  CloudClassroom
//
//  Created by mac on 2022/9/8.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ControlScrollBlock) (BOOL scrollEnabled);

@interface HXZaiXianXuanKeViewChildController : HXBaseViewController

@property (nonatomic,copy) ControlScrollBlock controlScrollBlock;

@end

NS_ASSUME_NONNULL_END
