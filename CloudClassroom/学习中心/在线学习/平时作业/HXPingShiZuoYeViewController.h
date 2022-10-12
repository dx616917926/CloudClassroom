//
//  HXPingShiZuoYeViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/9/2.
//

#import "HXBaseViewController.h"
#import "HXCourseInfoModel.h"
#import "HXBuKaoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXPingShiZuoYeViewController : HXBaseViewController
//是否是补考
@property(nonatomic,assign) BOOL isBuKao;

@property(nonatomic,strong) HXCourseInfoModel *courseInfoModel;

@property(nonatomic,strong) HXBuKaoModel *buKaoModel;

@end

NS_ASSUME_NONNULL_END
