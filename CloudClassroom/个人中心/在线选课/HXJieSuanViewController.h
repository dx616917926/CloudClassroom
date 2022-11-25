//
//  HXJieSuanViewController.h
//  CloudClassroom
//
//  Created by mac on 2022/9/21.
//

#import "HXBaseViewController.h"
#import "HXCourseJieSuanModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXJieSuanViewController : HXBaseViewController

//是否有学期
@property(nonatomic,assign) BOOL isHaveXueQi;

@property(nonatomic,strong) HXCourseJieSuanModel *jieSuanModel;





@end

NS_ASSUME_NONNULL_END
