//
//  HXSchoolVerifyViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/9/13.
//

#import "HXBaseViewController.h"
#import "HXSchoolModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^scanSuccessBlock) (HXSchoolModel *school);

@interface HXSchoolVerifyViewController : HXBaseViewController

@property (nonatomic,assign) BOOL canGoBack;//能否返回上一个页面

@property (nonatomic,copy) scanSuccessBlock scanSuccessBlock;

@end

NS_ASSUME_NONNULL_END
