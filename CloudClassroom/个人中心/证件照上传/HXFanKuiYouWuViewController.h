//
//  HXFanKuiYouWuViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/9/13.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FanKuiYouWuCallBack)(void);

@interface HXFanKuiYouWuViewController : HXBaseViewController

@property(nonatomic,copy) FanKuiYouWuCallBack fanKuiYouWuCallBack;

@end

NS_ASSUME_NONNULL_END
